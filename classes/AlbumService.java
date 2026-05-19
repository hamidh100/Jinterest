public class AlbumService {
    public int totalLikes(Album album){
        int totalLikes = 0;
        for (Photo photo : album.getPhotos()){
            totalLikes += (photo.getLikedBy() == null ? 0 : photo.getLikedBy().size());
        }
        return totalLikes;
    }
}
