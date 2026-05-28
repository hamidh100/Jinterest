import java.util.UUID;

public class PhotoService {
    public static boolean isLikedBy(Photo photo, User user){
        if (photo.getLikedByID() == null || photo.getLikedByID().size() == 0) return false;
        for (UUID someoneID : photo.getLikedByID()){
            User someone = OurObjects.users.get(someoneID);
            if (someone != null && someone.equals(user)) return true;
        }
        return false;
    }
    public static void addLike(Photo photo, User user){
        if (isLikedBy(photo, user)) return;
        photo.getLikedByID().add(user.getUuid());
    }
    public static void removeLike(Photo photo, User user){
        if (!isLikedBy(photo, user)) return;
        photo.getLikedByID().remove(user.getUuid());
    }
    public static void addPhoto(User user, Photo photo){
        user.getPhotoIDs().add(photo.getUuid());
    }
}
