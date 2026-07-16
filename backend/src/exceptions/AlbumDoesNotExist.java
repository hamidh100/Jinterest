package exceptions;

public class AlbumDoesNotExist extends Exception {
    public AlbumDoesNotExist(String identifier) {
        super("Album does not exist" + identifier);
    }
}
