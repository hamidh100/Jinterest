package database;

import models.Album;
import models.Caption;
import models.Comment;
import models.Like;
import models.OurObjects;
import models.Photo;
import models.User;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

public class DatabaseSnapshot {
    public Map<UUID, User> users = new ConcurrentHashMap<>();
    public Map<String, UUID> usersLowercase = new ConcurrentHashMap<>();
    public Map<String, UUID> emailToUserID = new ConcurrentHashMap<>();
    public Map<String, UUID> phoneToUserID = new ConcurrentHashMap<>();
    public Map<UUID, Photo> photos = new ConcurrentHashMap<>();
    public Map<UUID, Album> albums = new ConcurrentHashMap<>();
    public Map<UUID, Like> likes = new ConcurrentHashMap<>();
    public Map<UUID, Comment> comments = new ConcurrentHashMap<>();
    public Map<UUID, Caption> captions = new ConcurrentHashMap<>();

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
        OurObjects.users = new ConcurrentHashMap<>(users == null ? Map.of() : users);
        OurObjects.usersLowercase = new ConcurrentHashMap<>(usersLowercase == null ? Map.of() : usersLowercase);
        OurObjects.emailToUserID = new ConcurrentHashMap<>(emailToUserID == null ? Map.of() : emailToUserID);
        OurObjects.phoneToUserID = new ConcurrentHashMap<>(phoneToUserID == null ? Map.of() : phoneToUserID);
        OurObjects.photos = new ConcurrentHashMap<>(photos == null ? Map.of() : photos);
        OurObjects.albums = new ConcurrentHashMap<>(albums == null ? Map.of() : albums);
        OurObjects.likes = new ConcurrentHashMap<>(likes == null ? Map.of() : likes);
        OurObjects.comments = new ConcurrentHashMap<>(comments == null ? Map.of() : comments);
        OurObjects.captions = new ConcurrentHashMap<>(captions == null ? Map.of() : captions);
    }
}
