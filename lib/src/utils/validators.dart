/// Form validators shared by the auth screen.
///
/// Pure functions with no Flutter or Firebase dependency, so they are easy to
/// unit-test.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  static String? displayName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your name';
    if (name.length < 2) return 'That name looks too short';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!_email.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  /// Firebase rejects passwords shorter than 6 characters.
  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Use at least 6 characters';
    return null;
  }
}
