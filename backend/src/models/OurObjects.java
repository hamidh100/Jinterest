package models;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import database.DatabaseManager;

public class OurObjects {
    // is hashmap ok?
    public static Map<UUID, User> users = new HashMap<>();
    public static Map<String, UUID> usersLowercase = new HashMap<>(); // for uniqueness (idk20 = iDK20)
    public static Map<String, UUID> emailToUserID = new HashMap<>();
    public static Map<String, UUID> phoneToUserID = new HashMap<>();
    public static Map<UUID, Photo> photos = new HashMap<>();
    public static Map<UUID, Album> albums = new HashMap<>();
    public static Map<UUID, Like> likes = new HashMap<>();
    public static Map<UUID, Comment> comments = new HashMap<>();
    public static Map<UUID, Caption> captions = new HashMap<>();
    static {
        try {
            DatabaseManager.load();
        } catch (IOException e){
            System.out.println(e);
        }
    }
}
