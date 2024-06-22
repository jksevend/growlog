import 'package:easy_localization/easy_localization.dart';

/// Validate the input [value] from a text field.
String? validateInput(String? value, {bool isDouble = false}) {
  if (value == null || value.isEmpty) {
    return tr('validators.required');
  }

  if (isDouble) {
    // Check if it is a double
    if (double.tryParse(value) == null) {
      return tr('validators.number');
    }
  }

  return null;
}
