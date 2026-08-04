package models;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

public class User {
    private String phone, email, username, password, fullname;
    private final UUID uuid;
    private LocalDateTime accountAge;
    private UserType userType = UserType.NORMAL;
    private boolean banned = false;
    private List<UUID> albumIDs = new ArrayList<UUID>();
    private List<UUID> photoIDs = new ArrayList<UUID>();
    private List<UUID> savedAlbums = new ArrayList<UUID>();
    private List<UUID> savedPhotos = new ArrayList<UUID>();
    private List<UUID> followerIDs = new ArrayList<UUID>();
    private List<UUID> followingIDs = new ArrayList<UUID>();/* we have to show posts from followings to user on top of the home page */

    /* Patters for verification*/
    public static final String USERNAME_PATTERN = "^(?=.*[a-zA-Z])[a-zA-Z0-9][a-zA-Z0-9_]+[a-zA-Z0-9]$";
    public static final String USERNAME_DEFAULT_PATTERN = "^user#[a-z0-9]{8}$";
    public static final String EMAIL_PATTERN = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    public static final String PHONENUMBER_PATTERN = "^(0|\\+\\d{2})?9\\d{9}$";
    public static final String PASSWORD_PATTERN = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";

    private void setIdentity(String identifier) {
        this.phone = this.email = this.username = null;
        if (identifier != null) {
            if (identifier.matches(USERNAME_PATTERN) || identifier.matches(USERNAME_DEFAULT_PATTERN)) this.username = identifier;
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

    public List<UUID> getSavedAlbums() {
        return savedAlbums;
    }

    public void setSavedAlbums(List<UUID> savedAlbums) {
        this.savedAlbums = savedAlbums;
    }

    public List<UUID> getSavedPhotoIDs() {
        return savedPhotos;
    }

    public void setSavedPhotoIDs(List<UUID> savedPhotos) {
        this.savedPhotos = savedPhotos;
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

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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

    public UserType getUserType() {
        return userType;
    }

    public void setUserType(UserType userType) {
        this.userType = userType;
    }

    public boolean isBanned() {
        return banned;
    }

    public void setBanned(boolean banned) {
        this.banned = banned;
    }
    /* getter setter end */

    @Override
    public String toString() {
        return "User{" +
                "phone='" + phone + '\'' +
                ", email='" + email + '\'' +
                ", username='" + username + '\'' +
                ", fullname='" + fullname + '\'' +
                ", uuid=" + uuid +
                ", accountAge=" + accountAge +
                ", userType=" + userType +
                ", banned=" + banned +
                '}';
    }

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
