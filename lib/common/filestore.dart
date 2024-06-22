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
