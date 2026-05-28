import java.util.UUID;

public class AlbumService {
    public static int totalLikes(Album album){
        int totalLikes = 0;
        for (UUID photoID : album.getPhotoIDs()){
            Photo photo = OurObjects.photos.get(photoID);
            totalLikes += (photo.getLikedBy() == null ? 0 : photo.getLikedBy().size());
        }
        return totalLikes;
    }
    public static void addAlbum(User user, Album album) {
        album.setOwnerID(user.getUuid());
        user.getAlbumIDs().add(album.getUuid());
    }
}
