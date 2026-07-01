class Validators {
  static const String usernamePattern =
      r'(?=.*[a-zA-Z])^[a-zA-Z0-9][a-zA-Z0-9_]+[a-zA-Z0-9]$';
  static const String usernameDefaultPattern = r'^user#[a-z0-9]{8}$';
  static const String emailPattern =
      r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
  static const String phonePattern = r'^(0|\+\d{2})?9\d{9}$';
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$';

  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username required';
    }
    if (username.length < 3) {
      return 'Username too short (min 3 characters)';
    }
    if (username.length > 20) {
      return 'Username too long (max 20 characters)';
    }
    if (!RegExp(usernamePattern).hasMatch(username)) {
      return 'Username must contain letters, start/end with alphanumeric, can have underscores';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email required';
    }
    if (!RegExp(emailPattern).hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number required';
    }
    if (!RegExp(phonePattern).hasMatch(phone)) {
      return 'Invalid phone format (e.g., 09xxxxxxxxx or +989xxxxxxxxx)';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password required';
    }
    if (password.length < 8) {
      return 'Password too short (min 8 characters)';
    }
    if (!RegExp(passwordPattern).hasMatch(password)) {
      return 'Password must contain lowercase, uppercase, and digit';
    }
    return null;
  }

  static String? validateIdentifier(String? identifier) {
    if (identifier == null || identifier.isEmpty) {
      return 'Email, phone, or username required';
    }
    if (identifier.contains('@')) {
      return validateEmail(identifier);
    }
    if (identifier.startsWith('0') || identifier.startsWith('+')) {
      return validatePhone(identifier);
    }
    return validateUsername(identifier);
  }
}
