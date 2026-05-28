import java.util.UUID;

public class PhotoService {
    public static boolean isLikedBy(Photo photo, User user){
        if (photo.getLikeIDs() == null || photo.getLikeIDs().size() == 0) return false;
        for (UUID likeID : photo.getLikeIDs()){
            UUID someoneID = OurObjects.likes.get(likeID).getUserID();
            User someone = OurObjects.users.get(someoneID);
            if (someone != null && someone.equals(user)) return true;
        }
        return false;
    }
    public static void addLike(Photo photo, Like like){
        if (isLikedBy(photo, OurObjects.users.get(like.getUserID()))) return;
        photo.getLikeIDs().add(like.getUuid());
    }
    public static void removeLike(Photo photo, Like like){
        if (isLikedBy(photo, OurObjects.users.get(like.getUserID()))) return;
        photo.getLikeIDs().remove(like.getUuid());
    }
    public static void addPhoto(User user, Photo photo){
        user.getPhotoIDs().add(photo.getUuid());
    }
}
