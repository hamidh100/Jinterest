package exceptions;

import java.util.HashMap;
import java.util.Map;

public class InvalidUsername extends Exception {
    private static Map<InvalidUsernameTypes, String> invalidUsernameTypesMap = new HashMap<>();
    static { // or with Map.of
        invalidUsernameTypesMap.put(InvalidUsernameTypes.TOOSHORT, "Username is too short");
        invalidUsernameTypesMap.put(InvalidUsernameTypes.TOOLONG, "Username is too long");
        invalidUsernameTypesMap.put(InvalidUsernameTypes.PATTERNMISMATCH, "Username should only have letters, numbers and underscores and shouldn't start or end with underscores (also it should contain at least one letter)");
    }
    public InvalidUsername(InvalidUsernameTypes type){
        // The Java feature 'Flexible Constructor Bodies' is only available with source level 25 and above ==> Map instead of switch
        super(invalidUsernameTypesMap.get(type));
    }
}

