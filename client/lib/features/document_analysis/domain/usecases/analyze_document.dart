import '../entities/extracted_data.dart';

class AnalyzeDocument {
  // final AiRepository repository;
  // AnalyzeDocument(this.repository);

  Future<ExtractedData> call(String filePath) async {
    // TODO: call repository or AiService to analyze the document
    return ExtractedData(text: 'sample text', metadata: {});
  }
}
