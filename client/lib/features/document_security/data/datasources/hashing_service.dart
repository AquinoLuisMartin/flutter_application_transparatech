import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Provides hashing utilities for documents (SHA-256)
class HashingService {
  /// Generate a SHA-256 hex hash for given bytes
  String generateHashFromBytes(List<int> bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a SHA-256 hex hash for a string
  String generateHash(String input) => generateHashFromBytes(utf8.encode(input));

  /// Verify that the provided hash matches the input
  bool verify(String input, String expectedHash) => generateHash(input) == expectedHash;
}
