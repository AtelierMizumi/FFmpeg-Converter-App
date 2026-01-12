import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility functions for hashing sensitive data
class CryptoUtils {
  /// Generate SHA256 hash of input string
  /// Used for device IDs and user IDs to protect privacy
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate hash from multiple inputs
  /// Useful for creating unique identifiers from combined values
  static String sha256HashMultiple(List<String> inputs) {
    final combined = inputs.join('|');
    return sha256Hash(combined);
  }
}
