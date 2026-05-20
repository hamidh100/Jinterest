public class PhotoService {
    public static boolean isLikedBy(Photo photo, User user){
        if (photo.getLikedBy() == null || photo.getLikedBy().size() == 0) return false;
        for (User someone : photo.getLikedBy()){
            if (someone != null && someone.equals(user)) return true;
        }
        return false;
    }
    public static void addLike(Photo photo, User user){
        if (isLikedBy(photo, user)) return;
        photo.getLikedBy().add(user);
    }
    public static void removeLike(Photo photo, User user){
        if (!isLikedBy(photo, user)) return;
        photo.getLikedBy().remove(user);
    }
    public static void addPhoto(User user, Photo photo){
        user.getPhotos().add(photo);
    }
}
