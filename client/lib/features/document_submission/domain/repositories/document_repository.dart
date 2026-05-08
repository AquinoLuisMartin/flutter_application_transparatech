import '../entities/document.dart';

abstract class DocumentRepository {
  Future<String> upload(Document document);
  Future<Document?> track(String id);
}
