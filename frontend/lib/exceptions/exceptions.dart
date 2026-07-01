abstract class JinterestException implements Exception {
  final String message;
  JinterestException(this.message);

  @override
  String toString() => message;
}

class AdminAccessRequired extends JinterestException {
  AdminAccessRequired(String identifier)
    : super("AdminAccessRequired : $identifier");
}

class UserAlreadyExists extends JinterestException {
  UserAlreadyExists(String identifier)
    : super("User already exists : $identifier");
}

class UserDoesNotExist extends JinterestException {
  UserDoesNotExist(String identifier)
    : super("User does not exist: $identifier");
}

class UserBanned extends JinterestException {
  UserBanned(String identifier) : super("User is banned: $identifier");
}

class InvalidLoginMethod extends JinterestException {
  InvalidLoginMethod()
    : super("You must login with a valid email, phone number or username");
}

class InvalidSignupMethod extends JinterestException {
  InvalidSignupMethod()
    : super("You must create account with a valid email or phone number");
}

class IncorrectPassword extends JinterestException {
  IncorrectPassword() : super("Password is incorrect");
}

enum InvalidUsernameTypes { TOOSHORT, TOOLONG, PATTERNMISMATCH }

const Map<InvalidUsernameTypes, String> _invalidUsernameMessages = {
  InvalidUsernameTypes.TOOSHORT: "Username is too short",
  InvalidUsernameTypes.TOOLONG: "Username is too long",
  InvalidUsernameTypes.PATTERNMISMATCH:
      "Username should only have letters, numbers and underscores and shouldn't start or end with underscores (also it should contain at least one letter)",
};

class InvalidUsername extends JinterestException {
  InvalidUsername(InvalidUsernameTypes type)
    : super(_invalidUsernameMessages[type] ?? "Invalid username");
}

enum WeakPasswordTypes { TOOSHORT, CONTAINSUSER, PATTERNMISMATCH }

const Map<WeakPasswordTypes, String> _weakPasswordMessages = {
  WeakPasswordTypes.TOOSHORT:
      "Password is too short. It should contain at least 8 characters",
  WeakPasswordTypes.CONTAINSUSER:
      "Password shouldn't contain your username or email",
  WeakPasswordTypes.PATTERNMISMATCH:
      "Password should include uppercase, lowercase and digits",
};

class WeakPassword extends JinterestException {
  WeakPassword(WeakPasswordTypes type)
    : super(_weakPasswordMessages[type] ?? "Password is weak");
}

class AlbumDoesNotExist extends JinterestException {
  AlbumDoesNotExist(String identifier)
    : super("Album does not exist: $identifier");
}

class PhotoDoesNotExist extends JinterestException {
  PhotoDoesNotExist(String identifier)
    : super("Photo does not exist: $identifier");
}
