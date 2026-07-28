package database;

import models.Album;
import models.Caption;
import models.Comment;
import models.Like;
import models.OurObjects;
import models.Photo;
import models.User;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class DatabaseSnapshot {
    public Map<UUID, User> users = new HashMap<>();
    public Map<String, UUID> usersLowercase = new HashMap<>();
    public Map<String, UUID> emailToUserID = new HashMap<>();
    public Map<String, UUID> phoneToUserID = new HashMap<>();
    public Map<UUID, Photo> photos = new HashMap<>();
    public Map<UUID, Album> albums = new HashMap<>();
    public Map<UUID, Like> likes = new HashMap<>();
    public Map<UUID, Comment> comments = new HashMap<>();
    public Map<UUID, Caption> captions = new HashMap<>();

    public DatabaseSnapshot() {
    }

    public static DatabaseSnapshot fromCurrentState() {
        DatabaseSnapshot snapshot = new DatabaseSnapshot();
        snapshot.users.putAll(OurObjects.users);
        snapshot.usersLowercase.putAll(OurObjects.usersLowercase);
        snapshot.emailToUserID.putAll(OurObjects.emailToUserID);
        snapshot.phoneToUserID.putAll(OurObjects.phoneToUserID);
        snapshot.photos.putAll(OurObjects.photos);
        snapshot.albums.putAll(OurObjects.albums);
        snapshot.likes.putAll(OurObjects.likes);
        snapshot.comments.putAll(OurObjects.comments);
        snapshot.captions.putAll(OurObjects.captions);
        return snapshot;
    }

    public void restoreCurrentState() {
        OurObjects.users = new HashMap<>(users == null ? Map.of() : users);
        OurObjects.usersLowercase = new HashMap<>(usersLowercase == null ? Map.of() : usersLowercase);
        OurObjects.emailToUserID = new HashMap<>(emailToUserID == null ? Map.of() : emailToUserID);
        OurObjects.phoneToUserID = new HashMap<>(phoneToUserID == null ? Map.of() : phoneToUserID);
        OurObjects.photos = new HashMap<>(photos == null ? Map.of() : photos);
        OurObjects.albums = new HashMap<>(albums == null ? Map.of() : albums);
        OurObjects.likes = new HashMap<>(likes == null ? Map.of() : likes);
        OurObjects.comments = new HashMap<>(comments == null ? Map.of() : comments);
        OurObjects.captions = new HashMap<>(captions == null ? Map.of() : captions);
    }
}
