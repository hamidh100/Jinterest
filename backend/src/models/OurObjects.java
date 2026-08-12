package models;

import java.io.IOException;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import database.DatabaseManager;

public class OurObjects {
    // is hashmap ok?
    public static final ReentrantReadWriteLock DATABASE_LOCK = new ReentrantReadWriteLock();
    public static Map<UUID, User> users = new ConcurrentHashMap<>();
    public static Map<String, UUID> usersLowercase = new ConcurrentHashMap<>(); // for uniqueness (idk20 = iDK20)
    public static Map<String, UUID> emailToUserID = new ConcurrentHashMap<>();
    public static Map<String, UUID> phoneToUserID = new ConcurrentHashMap<>();
    public static Map<UUID, Photo> photos = new ConcurrentHashMap<>();
    public static Map<UUID, Album> albums = new ConcurrentHashMap<>();
    public static Map<UUID, Like> likes = new ConcurrentHashMap<>();
    public static Map<UUID, Comment> comments = new ConcurrentHashMap<>();
    public static Map<UUID, Caption> captions = new ConcurrentHashMap<>();
    public static Map<UUID, Session> sessions = new ConcurrentHashMap<>();
    static {
        try {
            DatabaseManager.load();
        } catch (IOException e){
            System.out.println(e);
        }
    }
}
