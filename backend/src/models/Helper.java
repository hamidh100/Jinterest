package models;

import java.util.Random;

public class Helper {
    public static String generateRandUniqUsername(){
        String result = "user#";
        Random random = new Random();
        int charPref = 0;
        for (int it = 0; it < 8; it++){
            int r = (charPref == 2 ? random.nextInt(10) : random.nextInt(36));
            charPref++;
            if (r < 10) charPref = 0;
            result += (char)(r < 10 ? '0' + r : 'a' + r - 10);
        }
        return OurObjects.usersLowercase.containsKey(result) ? generateRandUniqUsername() : result;
    }

    public static String toLower(String str){
        String res = "";
        for (int i = 0; i < str.length(); i++){
            char c = str.charAt(i);
            if (c >= 'A' && c <= 'Z') c = (char)(c - 'A' + 'a');
            res += c;
        }
        return res;
    }

    public static String extractNameFromPath(String str){
        if (str == null) return null;
        String res = "";
        boolean flag = false;
        for (int i = str.length() - 1; i >= 0; i--){
            char ch = str.charAt(i);
            if (ch == '/' || ch == '\\') break;
            if (flag) res += ch;
            if (ch == '.') flag = true;
        }
        String extractedName = "";
        for (int i = res.length() - 1; i >= 0; i--){
            extractedName += res.charAt(i);
        }
        return extractedName;
    }
}
