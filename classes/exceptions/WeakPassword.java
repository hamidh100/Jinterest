package exceptions;

public class WeakPassword extends Exception {
    public WeakPassword(){
        super("Password must be at least 8 characters and include uppercase, lowercase and digits");
    }
}
