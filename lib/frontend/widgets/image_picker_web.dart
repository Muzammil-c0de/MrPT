// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

/// Opens the browser file picker and returns the chosen image encoded as a
/// data URL (`data:image/...;base64,...`) suitable for [Image.network], or
/// `null` if the user cancelled.
Future<String?> pickImageAsDataUrl() async {
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.click();

  // Wait for the user to pick a file (or dismiss the dialog).
  await input.onChange.first;
  final files = input.files;
  if (files == null || files.isEmpty) return null;

  final reader = html.FileReader()..readAsDataUrl(files.first);
  await reader.onLoad.first;
  final result = reader.result;
  return result is String ? result : null;
}
