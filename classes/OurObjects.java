import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class OurObjects {
    // is hashmap ok?
    public static Map<UUID, User> users = new HashMap<>();
    public static Map<UUID, User> usersLowercase = new HashMap<>(); // for uniqueness (idk20 = iDK20)
    public static Map<UUID, Photo> photos = new HashMap<>();
    public static Map<UUID, Album> albums = new HashMap<>();
    public static Map<UUID, Like> likes = new HashMap<>();
    public static Map<UUID, Comment> comments = new HashMap<>();
}
