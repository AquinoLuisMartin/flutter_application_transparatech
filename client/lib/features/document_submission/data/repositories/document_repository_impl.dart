import '../../domain/entities/document.dart';

/// Repository implementation connecting data sources with domain
class DocumentRepositoryImpl implements DocumentRepository {
  // TODO: accept datasources via constructor

  @override
  Future<String> upload(Document doc) async {
    // TODO: implement upload flow using remote/local datasources
    return 'document-id';
  }

  @override
  Future<Document?> track(String id) async {
    // TODO: implement tracking logic
    return null;
  }
}

abstract class DocumentRepository {
  Future<String> upload(Document doc);
  Future<Document?> track(String id);
}
