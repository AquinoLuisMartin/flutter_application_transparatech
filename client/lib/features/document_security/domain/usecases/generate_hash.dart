import '../../data/datasources/hashing_service.dart';

class GenerateHash {
  final HashingService hashingService;
  GenerateHash(this.hashingService);

  Future<String> call(String content) async {
    // In a real implementation this could accept file bytes instead
    return hashingService.generateHash(content);
  }
}
