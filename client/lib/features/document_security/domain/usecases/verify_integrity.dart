import '../../data/datasources/hashing_service.dart';

class VerifyIntegrity {
  final HashingService hashingService;
  VerifyIntegrity(this.hashingService);

  Future<bool> call(String content, String expectedHash) async {
    return hashingService.verify(content, expectedHash);
  }
}
