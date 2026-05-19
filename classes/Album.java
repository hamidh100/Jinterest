import java.util.List;
import java.util.UUID;

public class Album {
    private User owner;
    private List<Photo> photos;
    private UUID uuid;

    public Album(User owner, List<Photo> photos){
        this.owner = owner;
        this.photos = photos;
        uuid = null; // TODO
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
    public UUID getUuid() {
        return uuid;
    }
    /* getter setter end */
}
