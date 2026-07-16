package exceptions;

public class UserBanned extends Exception {
    public UserBanned(String identifier) {
        super("User is banned: " + identifier);
    }
}
