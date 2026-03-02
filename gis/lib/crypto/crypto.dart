import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashString(String input) {
  final bytes = utf8.encode(input); // Преобразуем строку в байты
  final digest = sha256.convert(bytes); // Хешируем
  return digest.toString();
}