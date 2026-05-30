package exceptions;

import java.util.HashMap;
import java.util.Map;

public class WeakPassword extends Exception {
    private static Map<WeakPasswordTypes, String> weakPasswordTypesMap = new HashMap<>();
    static { // or with Map.of
        weakPasswordTypesMap.put(WeakPasswordTypes.TOOSHORT, "Password is too short. It should contain at least 8 characters");
        weakPasswordTypesMap.put(WeakPasswordTypes.CONTAINSUSER, "Password shouldn't contain your username or email");
        weakPasswordTypesMap.put(WeakPasswordTypes.PATTERNMISMATCH, "Password should include uppercase, lowercase and digits");
    }
    public WeakPassword(WeakPasswordTypes type){
        // The Java feature 'Flexible Constructor Bodies' is only available with source level 25 and above ==> Map instead of switch
        super(weakPasswordTypesMap.get(type));
    }
}
