public class AlbumService {
    public static int totalLikes(Album album){
        int totalLikes = 0;
        for (Photo photo : album.getPhotos()){
            totalLikes += (photo.getLikedBy() == null ? 0 : photo.getLikedBy().size());
        }
        return totalLikes;
    }
    public static void addAlbum(User user, Album album) {
        album.setOwner(user);
        user.getAlbumIDs().add(album.getUuid());
    }
}
