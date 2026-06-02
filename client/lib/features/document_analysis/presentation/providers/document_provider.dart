import 'package:flutter/foundation.dart';
import '../../../../core/network/http_client.dart';
import '../../data/models/document_model.dart';
import '../../data/models/officer_stats_model.dart';
import '../../data/models/organization_model.dart';

class DocumentProvider extends ChangeNotifier {
  final HttpClient _httpClient = ApiClient();
  
  List<Document> _documents = [];
  OfficerStats? _stats;
  OrganizationBudget? _organizationBudget;
  bool _isLoading = false;
  String? _errorMessage;

  List<Document> get documents => _documents;
  OfficerStats? get stats => _stats;
  OrganizationBudget? get organizationBudget => _organizationBudget;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDocuments(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch documents
      final docResponse = await _httpClient.get('/api/officer/documents', headers: {
        'Authorization': 'Bearer $token',
      });

      if (docResponse.isSuccess) {
        final List<dynamic> dataList = docResponse.data ?? [];
        _documents = dataList.map((e) => Document.fromJson(e)).toList();
      }

      // Fetch stats
      final statsResponse = await _httpClient.get('/api/officer/stats', headers: {
        'Authorization': 'Bearer $token',
      });

      if (statsResponse.isSuccess) {
        _stats = OfficerStats.fromJson(statsResponse.data);
      }

      // Fetch organization
      final orgResponse = await _httpClient.get('/api/officer/organization', headers: {
        'Authorization': 'Bearer $token',
      });

      if (orgResponse.isSuccess) {
        _organizationBudget = OrganizationBudget.fromJson(orgResponse.data);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshOfficerData(String token) async {
    await fetchDocuments(token);
  }

  Future<bool> uploadDocument({
    required String token,
    required String title,
    required String description,
    required String filePath,
    int? fileSize,
    String? fileType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _httpClient.post(
        '/api/officer/documents',
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {
          'title': title,
          'description': description,
          'filePath': filePath,
          'fileSize': fileSize ?? 1024 * 100, // Default 100 KB
          'fileType': fileType ?? 'application/pdf',
        },
      );

      if (response.isSuccess) {
        await fetchDocuments(token);
        return true;
      } else {
        _errorMessage = response.data['error'] ?? 'Failed to upload document';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
