import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

import exceptions.InvalidUsername;
import exceptions.WeakPassword;

public class User {
    private String phone, email, username, password, fullname;
    private final UUID uuid;
    private LocalDateTime accountAge;
    private List<UUID> albumIDs = new ArrayList<UUID>();
    private List<UUID> photoIDs = new ArrayList<UUID>();
    private List<UUID> followerIDs = new ArrayList<UUID>();
    private List<UUID> followingIDs = new ArrayList<UUID>();/* we have to show posts from followings to user on top of the home page */

    /* Patters for verification*/
    private static final String USERNAME_PATTERN = "^[a-zA-Z0-9][a-zA-Z0-9_]+[a-zA-Z0-9]$";
    private static final String EMAIL_PATTERN = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    private static final String PHONENUMBER_PATTERN = "^(0|\\+\\d{2})?9\\d{9}$";
    private static final String PASSWORD_PATTERN = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";

    private void setIdentity(String identifier){
        this.phone = this.email = this.username = null;
        if (identifier != null){
            if (identifier.matches(USERNAME_PATTERN)) this.username = identifier;
            if (identifier.matches(EMAIL_PATTERN)) this.email = identifier;
            if (identifier.matches(PHONENUMBER_PATTERN)) this.phone = identifier;
        }
    }

    public User(String identifier, String password) {
        setIdentity(identifier);
        this.password = password;
        fullname = "";
        uuid = UUID.randomUUID();
    }
    
    public User(String identifier, String password, String fullname) {
        setIdentity(identifier);
        this.password = password;
        this.fullname = fullname;
        uuid = UUID.randomUUID();
    }

    public User(String identifier, String password, String fullname, UUID uuid, LocalDateTime accountAge) { // made after original user
        setIdentity(identifier);
        this.password = password;
        this.fullname = fullname;
        this.uuid = uuid;
        this.accountAge = accountAge;
    }
    
    /* getter setter begin */
    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
    
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
        if (username == null || username.length() < 3) throw new exceptions.InvalidUsername(exceptions.InvalidUsernameTypes.TOOSHORT);
        if (username.length() > 20) throw new exceptions.InvalidUsername(exceptions.InvalidUsernameTypes.TOOLONG);
        if (!username.matches(USERNAME_PATTERN)) throw new exceptions.InvalidUsername(exceptions.InvalidUsernameTypes.PATTERNMISMATCH);
        this.username = username;
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
