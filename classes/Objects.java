import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class Objects {
    // is hashmap ok?
    public static Map<UUID, User> users = new HashMap<>();
    public static Map<UUID, Photo> photos = new HashMap<>();
    public static Map<UUID, Album> albums = new HashMap<>();
    public static Map<UUID, Like> likes = new HashMap<>();
    public static Map<UUID, Comment> comments = new HashMap<>();
}
