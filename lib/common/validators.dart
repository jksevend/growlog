/// Validate the input [value] from a text field.
String? validateInput(String? value, {bool isDouble = false}) {
  if (value == null || value.isEmpty) {
    return 'Please enter a value';
  }

  if (isDouble) {
    // Check if it is a double
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
  }

  return null;
}
