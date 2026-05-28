import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

import exceptions.InvalidUsername;
import exceptions.WeakPassword;

public class User {
    private String username, password, fullname;
    private final UUID uuid;
    private LocalDateTime accountAge;
    private List<UUID> albumIDs = new ArrayList<UUID>();
    private List<UUID> photoIDs = new ArrayList<UUID>();
    private List<UUID> followerIDs = new ArrayList<UUID>();
    private List<UUID> followingIDs = new ArrayList<UUID>();/* we have to show posts from followings to user on top of the home page */

    /* Patters for verification*/
    private static final String EMAIL_PATTERN = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    private static final String PASSWORD_PATTERN = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";
    private static final String PHONENUMBER_PATTERN = "^(0|\\+\\d{2})?9\\d{9}$";

    public User(String username, String password) throws InvalidUsername, WeakPassword {
        setUsername(username);
        setPassword(password);
        fullname = "";
        uuid = UUID.randomUUID();
        OurObjects.users.put(uuid, this);
        accountAge = LocalDateTime.now();
    }
    
    public User(String username, String password, String fullname) throws InvalidUsername, WeakPassword {
        setUsername(username);
        setPassword(password);
        this.fullname = fullname;
        uuid = UUID.randomUUID();
        OurObjects.users.put(uuid, this);
        accountAge = LocalDateTime.now();
    }
    
    /* getter setter begin */
    
    public LocalDateTime getAccountAge() {
        return accountAge;
    }

    public void setAccountAge(LocalDateTime accountAge) {
        this.accountAge = accountAge;
    }

    public List<UUID> getAlbumIDs() {
        return albumIDs;
    }

    public void setAlbumIDs(List<UUID> albumIDs) {
        this.albumIDs = albumIDs;
    }

    public List<UUID> getPhotoIDs() {
        return photoIDs;
    }

    public void setPhotoIDs(List<UUID> photoIDs) {
        this.photoIDs = photoIDs;
    }

    public List<UUID> getFollowerIDs() {
        return followerIDs;
    }

    public void setFollowerIDs(List<UUID> followerIDs) {
        this.followerIDs = followerIDs;
    }

    public List<UUID> getFollowingIDs() {
        return followingIDs;
    }

    public void setFollowingIDs(List<UUID> followingIDs) {
        this.followingIDs = followingIDs;
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
    public boolean equals(Object o) {
        if (!(o instanceof User user)) return false;
        return Objects.equals(uuid, user.uuid);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(uuid);
    }
}
