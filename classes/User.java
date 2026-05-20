import java.util.LinkedList;

import exceptions.InvalidUsername;
import exceptions.WeakPassword;

public class User {
    private String username, password, fullname;

    private LinkedList<Album> albums = new LinkedList<>();
    private LinkedList<Photo> photos = new LinkedList<>();

    /* Patters for verification*/
    private static final String EMAIL_PATTERN = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    private static final String PASSWORD_PATTERN = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";
    private static final String PHONENUMBER_PATTERN = "^(0|\\+\\d{2})?9\\d{9}$";


    public User(String username, String password) throws InvalidUsername, WeakPassword {
        setUsername(username);
        setPassword(password);
    }

    public User(String username, String password, String fullname) throws InvalidUsername, WeakPassword {
        setUsername(username);
        setPassword(password);
        this.fullname = fullname;
    }

    


    /* getter setter begin */

    public LinkedList<Album> getAlbums() {
        return albums;
    }

    public void setAlbums(LinkedList<Album> albums) {
        this.albums = albums;
    }

    public LinkedList<Photo> getPhotos() {
        return photos;
    }

    public void setPhotos(LinkedList<Photo> photos) {
        this.photos = photos;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) throws InvalidUsername {
        if (username.matches(EMAIL_PATTERN) || username.matches(PHONENUMBER_PATTERN))
            this.username = username;
        else
            throw new exceptions.InvalidUsername();
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) throws WeakPassword {
        if (password.matches(PASSWORD_PATTERN))
            this.password = password;
        else
            throw new exceptions.WeakPassword();
    }

    public String getFullname() {
        return fullname;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }
    /* getter setter end */
}
