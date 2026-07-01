import 'dart:math';

class Helper {
  static String generateRandUniqUsername(Set<String> existingUsernames) {
    String result = "user#";
    Random random = Random();
    int charPref = 0;

    for (int i = 0; i < 8; i++) {
      int r = (charPref == 2) ? random.nextInt(10) : random.nextInt(36);
      charPref++;
      if (r < 10) charPref = 0;

      String char = String.fromCharCode(
        r < 10 ? '0'.codeUnitAt(0) + r : 'a'.codeUnitAt(0) + r - 10,
      );
      result += char;
    }

    if (existingUsernames.contains(result.toLowerCase())) {
      return generateRandUniqUsername(existingUsernames);
    }

    return result;
  }

  static String toLower(String str) {
    String result = "";
    for (int i = 0; i < str.length; i++) {
      String char = str[i];
      if (char.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
          char.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
        result += String.fromCharCode(
          char.codeUnitAt(0) - 'A'.codeUnitAt(0) + 'a'.codeUnitAt(0),
        );
      } else {
        result += char;
      }
    }
    return result;
  }

  static String? extractNameFromPath(String? str) {
    if (str == null || str.isEmpty) return null;

    String extracted = "";
    bool foundDot = false;

    for (int i = str.length - 1; i >= 0; i--) {
      String char = str[i];
      if (char == '/' || char == '\\') break;

      if (foundDot) {
        extracted += char;
      }
      if (char == '.') {
        foundDot = true;
      }
    }

    String result = "";
    for (int i = extracted.length - 1; i >= 0; i--) {
      result += extracted[i];
    }

    return result.isEmpty ? null : result;
  }

  static String? getFileExtension(String? filePath) {
    if (filePath == null || filePath.isEmpty) return null;
    int lastSeparator = max(
      filePath.lastIndexOf('/'),
      filePath.lastIndexOf('\\'),
    );
    String fileName = lastSeparator >= 0
        ? filePath.substring(lastSeparator + 1)
        : filePath;

    int lastDot = fileName.lastIndexOf('.');
    if (lastDot < 0) return null;

    return fileName.substring(lastDot + 1);
  }
}
