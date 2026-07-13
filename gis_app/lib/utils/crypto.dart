import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateSalt() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

String hashString(String input) {
  final bytes = utf8.encode(input); // Преобразуем строку в байты
  final digest = sha256.convert(bytes); // Хешируем
  return digest.toString();
}