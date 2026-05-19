import java.util.List;

public class Album {
    private User owner;
    private List<Photo> photos;

    public Album(User owner, List<Photo> photos){
        this.owner = owner;
        this.photos = photos;
    }
    
    /* getter setter begin */
    public List<Photo> getPhotos() {
        return photos;
    }
    public void setPhotos(List<Photo> photos) {
        this.photos = photos;
    }
    public User getOwner() {
        return owner;
    }
    public void setOwner(User owner) {
        this.owner = owner;
    }
    /* getter setter end */

    public int totalLikes(){
        int totalLikes = 0;
        for (Photo photo : photos){
            totalLikes += photo.getLikedCount();
        }
        return totalLikes;
    }
}
