package exceptions;

public class AdminAccessRequired extends Exception {
    public AdminAccessRequired(String identifier) {
        super("AdminAccessRequired : " + identifier);
    }

}
