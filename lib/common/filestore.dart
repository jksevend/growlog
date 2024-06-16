import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Attempt to read a JSON file from the device's file system called [name].
/// If the file does not exist, create it with the provided [preset] content.
Future<Map<String, dynamic>> readJsonFile({
  required String name,
  required String preset,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  var file = File('${directory.path}/$name');
  if (!await file.exists()) {
    file = await file.writeAsString(preset);
  }
  final content = await file.readAsString();
  return json.decode(content);
}

/// Attempt to write json [content] to the device's file system called [name].
Future<void> writeJsonFile({
  required String name,
  required Map<String, dynamic> content,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$name');
  await file.writeAsString(json.encode(content));
}

/// Migrate a field in a JSON object called [jsonContent].
void migrateField<T>({
  required Map<String, dynamic> jsonContent,
  required String field,
  required T defaultValue,
}) {
  if (!jsonContent.containsKey(field)) {
    jsonContent[field] = defaultValue;
  }
}

/// Migrate a list in a JSON object called [jsonContent].
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
