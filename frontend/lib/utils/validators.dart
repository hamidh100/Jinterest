class Validators {
  static const String usernamePattern =
      r'(?=.*[a-zA-Z])^[a-zA-Z0-9][a-zA-Z0-9_]+[a-zA-Z0-9]$';
  static const String usernameDefaultPattern = r'^user#[a-z0-9]{8}$';
  static const String emailPattern =
      r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
  static const String phonePattern = r'^(0|\+\d{2})?9\d{9}$';
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$';

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username required';
    }

    if (!RegExp(usernamePattern).hasMatch(value)) {
      return 'Username must:\n- Contain letters\n- Start and end with alphanumeric\n- Can contain underscores in middle';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email required';
    }

    if (!RegExp(emailPattern).hasMatch(value)) {
      return 'Invalid email format';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number required';
    }

    if (!RegExp(phonePattern).hasMatch(value)) {
      return 'Invalid phone format (e.g., 09xxxxxxxxx or +989xxxxxxxxx)';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(passwordPattern).hasMatch(value)) {
      return 'Password must contain:\n- Lowercase letter\n- Uppercase letter\n- Digit';
    }

    return null;
  }

  static String? validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email, phone, or username required';
    }

    if (value.contains('@')) {
      return validateEmail(value);
    }

    if (value.startsWith('0') || value.startsWith('+')) {
      return validatePhone(value);
    }

    return validateUsername(value);
  }
}
