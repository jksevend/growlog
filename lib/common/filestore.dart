import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Parameters for encryption of app data.
class EncryptionParams {
  final String encryptionKey;
  final String iv;

  const EncryptionParams({
    required this.encryptionKey,
    required this.iv,
  });
}

/// Attempt to read a JSON file from the device's file system called [name].
/// If the file does not exist, create it with the provided [preset] content.
Future<Map<String, dynamic>> readJsonFile({
  required String name,
  required String preset,
  required EncryptionParams params,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  var file = File('${directory.path}/$name');

  if (!await file.exists()) {
    final encryptedPreset = encrypt(preset, params);
    file = await file.writeAsString(encryptedPreset);
  }
  final content = await file.readAsString();
  final decryptedContent = decrypt(content, params);
  return json.decode(decryptedContent);
}

/// Attempt to write json [content] to the device's file system called [name].
Future<void> writeJsonFile({
  required String name,
  required Map<String, dynamic> content,
  required EncryptionParams params,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$name');
  final encryptedContent = encrypt(json.encode(content), params);
  await file.writeAsString(encryptedContent);
}

/// Add a field in a JSON object called [jsonContent].
void addField<T>({
  required Map<String, dynamic> jsonContent,
  required String field,
  required T defaultValue,
}) {
  if (!jsonContent.containsKey(field)) {
    jsonContent[field] = defaultValue;
  }
  throw Exception('Field $field already exists.');
}

/// Delete a field in a JSON object called [jsonContent].
void deleteField({
  required Map<String, dynamic> jsonContent,
  required String field,
}) {
  if (jsonContent.containsKey(field)) {
    jsonContent.remove(field);
  }
  throw Exception('Field $field does not exist.');
}

/// Perform a list of migration functions on a JSON object called [jsonContent].
Future<void> migrateFileStore({
  required String name,
  required Function(Map<String, dynamic>) migration,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$name');

  if (await file.exists()) {
    final content = await file.readAsString();
    final jsonContent = json.decode(content);

    // Migrations
    migration(jsonContent);

    await file.writeAsString(json.encode(jsonContent));
  }
}

/// Encrypts a [content] using the provided [params].
String encrypt(String content, EncryptionParams params) {
  final key = crypto.Key.fromUtf8(params.encryptionKey);
  final iv = crypto.IV.fromUtf8(params.iv);
  final encrypter = crypto.Encrypter(crypto.AES(key));
  return encrypter.encrypt(content, iv: iv).base64;
}

/// Decrypts a [content] using the provided [params].
String decrypt(String content, EncryptionParams params) {
  final key = crypto.Key.fromUtf8(params.encryptionKey);
  final iv = crypto.IV.fromUtf8(params.iv);
  final encrypter = crypto.Encrypter(crypto.AES(key));
  return encrypter.decrypt(crypto.Encrypted.fromBase64(content), iv: iv);
}

/// Options for Android secure storage.
AndroidOptions getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

/// Retrieve the encryption key from the secure storage.
Future<String> _getEncryptionKey() async {
  final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
  final encryptionKey = await storage.read(key: 'uniqueEncryptionKey');
  if (encryptionKey == null) {
    throw Exception('Encryption key not found.');
  }
  return encryptionKey;
}

/// Retrieve the initialization vector from the secure storage.
Future<String> _getIv() async {
  final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
  final iv = await storage.read(key: 'iv');
  if (iv == null) {
    throw Exception('IV not found.');
  }
  return iv;
}

/// Retrieve the encryption parameters from the secure storage.
Future<EncryptionParams> getEncryptionParams() async {
  final encryptionKey = await _getEncryptionKey();
  final iv = await _getIv();
  return EncryptionParams(encryptionKey: encryptionKey, iv: iv);
}

/// Generate a new encryption key and store it in the secure storage.
String generateEncryptionKey() {
  final encryptionKey = generateSecureRandomString(32);
  debugPrint('Encryption key: $encryptionKey');
  return encryptionKey;
}

/// Generate a secure random string of [length].
String generateSecureRandomString(final int length) {
  final random = Random.secure();
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+{}|:"<>?`~-=[]\\;\',./';
  var result = '';
  for (var i = 0; i < length; i++) {
    final value = random.nextInt(chars.length);
    result += chars[value];
  }
  return result;
}
