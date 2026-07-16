package exceptions;

public class PhotoDoesNotExist extends Exception {
    public PhotoDoesNotExist(String identifier) {
        super("Photo does not exist" + identifier);
    }
}
