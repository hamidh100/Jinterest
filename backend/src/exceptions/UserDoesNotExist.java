package exceptions;

public class UserDoesNotExist extends Exception {
    public UserDoesNotExist(String identifier) {
        super("User does not exist: " + identifier);
    }
}
