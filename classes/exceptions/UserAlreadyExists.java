package exceptions;

public class UserAlreadyExists extends Exception {
    public UserAlreadyExists(String identifier){
        super("User already exists : " + identifier);
    }
}
