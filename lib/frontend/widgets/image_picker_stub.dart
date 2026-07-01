/// Non-web fallback. Real image picking is only implemented for the web build
/// (see `image_picker_web.dart`), which the app targets.
Future<String?> pickImageAsDataUrl() async => null;
