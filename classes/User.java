import java.util.LinkedList;

public class User {
    private String username, password, fullname;

    private LinkedList<Album> albums = new LinkedList<>();
    private LinkedList<Photo> photos = new LinkedList<>();

    private int albumsCount;
    private int photosCount;

    /* Patters for verification*/
    private static final String EMAIL_PATTERN = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    private static final String PASSWORD_PATTERN = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";
    private static final String PHONENUMBER_PATTERN = "^(0|\\+\\d{2})?9\\d{9}$";


    public User(String username, String password) {
        setUsername(username);
        setPassword(password);
    }

    public User(String username, String password, String fullname) {
        setUsername(username);
        setPassword(password);
        this.fullname = fullname;
    }

    public void addAlbum(Album album) {
        albums.add(album);
        albumsCount++;
    }

    public void addPhoto(Photo photo){
        photos.add(photo);
        photosCount++;
    }
// .


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

    public int getAlbumsCount() {
        return albumsCount;
    }

    public int getPhotosCount() {
        return photosCount;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        if (username.matches(EMAIL_PATTERN) || username.matches(PHONENUMBER_PATTERN))
            this.username = username;
        else
            throw new IllegalArgumentException("Username must be a valid email or phone number");
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        if (password.matches(PASSWORD_PATTERN))
            this.password = password;
        else
            throw new IllegalArgumentException("Password must be at least 8 characters and include uppercase, lowercase and digits");
    }

    public String getFullname() {
        return fullname;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }
    /* getter setter end */
}
