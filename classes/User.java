import java.sql.ClientInfoStatus;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import exceptions.InvalidUsername;
import exceptions.WeakPassword;

public class User {
    private String username, password, fullname;
    private UUID uuid;
    private List<Album> albums = new ArrayList<Album>();
    private List<Photo> photos = new ArrayList<Photo>();
    private List<User> followers = new ArrayList<>();
    private List<User> following = new ArrayList<>();/* we have to show posts from followings to user on top of the home page */

    /* Patters for verification*/
    private static final String EMAIL_PATTERN = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    private static final String PASSWORD_PATTERN = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";
    private static final String PHONENUMBER_PATTERN = "^(0|\\+\\d{2})?9\\d{9}$";

    public User(String username, String password) throws InvalidUsername, WeakPassword {
        setUsername(username);
        setPassword(password);
        fullname = "";
        uuid = UUID.randomUUID();
    }

    public User(String username, String password, String fullname) throws InvalidUsername, WeakPassword {
        setUsername(username);
        setPassword(password);
        this.fullname = fullname;
        uuid = UUID.randomUUID();
    }

    /* getter setter begin */
    public List<User> getFollowers() {
        return followers;
    }

    public void setFollowers(List<User> followers) {
        this.followers = followers;
    }

    public List<User> getFollowing() {
        return following;
    }

    public void setFollowing(List<User> following) {
        this.following = following;
    }

    public List<Album> getAlbums() {
        return albums;
    }

    public void setAlbums(List<Album> albums) {
        this.albums = albums;
    }

    public List<Photo> getPhotos() {
        return photos;
    }

    public void setPhotos(List<Photo> photos) {
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

    public UUID getUuid() {
        return uuid;
    }
    /* getter setter end */

    @Override
    public int hashCode(){ // TODO
        final int prime = 31;
        int result = 1;
        result = prime * result + ((username == null) ? 0 : username.hashCode());
        result = prime * result + ((password == null) ? 0 : password.hashCode());
        result = prime * result + ((fullname == null) ? 0 : fullname.hashCode());
        result = prime * result + ((uuid == null) ? 0 : uuid.hashCode());
        result = prime * result + ((albums == null) ? 0 : albums.hashCode());
        result = prime * result + ((photos == null) ? 0 : photos.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj){
        if (obj == null) return false;
        User other = (User)obj;
        return uuid.equals(other.uuid);
    }
}
