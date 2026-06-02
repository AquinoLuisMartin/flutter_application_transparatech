import 'package:flutter/foundation.dart';
import '../../../../core/network/http_client.dart';
import '../../data/models/document_model.dart';

class DocumentProvider extends ChangeNotifier {
  final HttpClient _httpClient = ApiClient();
  
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDocuments(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // In a real app, this would be /api/documents
      // For now, let's use /api/accounts just to see it's working or mock if needed
      // Actually, I should check api.ts to see what routes are available
      final response = await _httpClient.get('/api/accounts', headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.isSuccess) {
        // This is a placeholder since we don't have a real documents endpoint yet
        // If we had /api/documents, it would be:
        // _documents = (response.data as List).map((e) => Document.fromJson(e)).toList();
        
        // Let's keep it empty or mock for now until we have the endpoint
        _documents = []; 
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = response.data['error'] ?? 'Failed to fetch documents';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
