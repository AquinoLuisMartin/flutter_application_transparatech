/// Remote data source for uploading and fetching documents
class DocumentRemoteDataSource {
  Future<String> uploadDocument(String filePath) async {
    // TODO: implement remote upload
    return 'remote-document-id';
  }

  Future<Map<String, dynamic>> fetchDocument(String id) async {
    // TODO: implement remote fetch
    return {'id': id};
  }
}
