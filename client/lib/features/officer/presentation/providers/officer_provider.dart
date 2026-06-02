import 'package:flutter/foundation.dart';
import 'package:flutter_application_transparatech/core/network/http_client.dart';
import 'package:flutter_application_transparatech/features/officer/data/models/officer_models.dart';

class OfficerProvider extends ChangeNotifier {
  final HttpClient _httpClient = ApiClient();
  
  bool _isLoading = false;
  String? _errorMessage;
  OfficerStats? _stats;
  List<OfficerDocument> _documents = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OfficerStats? get stats => _stats;
  List<OfficerDocument> get documents => _documents;

  Future<void> fetchStats(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _httpClient.get(
        '/api/officer/stats',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        _stats = OfficerStats.fromJson(response.data);
      } else {
        _errorMessage = response.data['error'] ?? 'Failed to fetch stats';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDocuments(String token, {String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String url = '/api/officer/documents';
      if (search != null && search.isNotEmpty) {
        url += '?search=${Uri.encodeComponent(search)}';
      }

      final response = await _httpClient.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        _documents = data.map((json) => OfficerDocument.fromJson(json)).toList();
      } else {
        _errorMessage = response.data['error'] ?? 'Failed to fetch documents';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OfficerDocument?> fetchDocumentDetails(String token, int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _httpClient.get(
        '/api/officer/documents/$id',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        return OfficerDocument.fromJson(response.data);
      } else {
        _errorMessage = response.data['error'] ?? 'Failed to fetch document details';
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument(String token, Map<String, dynamic> docData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _httpClient.post(
        '/api/officer/documents',
        body: docData,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        await fetchDocuments(token);
        await fetchStats(token);
        return true;
      } else {
        _errorMessage = response.data['error'] ?? 'Upload failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> archiveDocument(String token, int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _httpClient.delete(
        '/api/officer/documents/$id',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        await fetchDocuments(token);
        await fetchStats(token);
        return true;
      } else {
        _errorMessage = response.data['error'] ?? 'Failed to archive document';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
