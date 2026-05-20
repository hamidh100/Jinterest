import java.util.List;
import java.util.UUID;

public class Album {
    private User owner;
    private List<Photo> photos;
    private UUID uuid;

    public Album(User owner, List<Photo> photos){
        this.owner = owner;
        this.photos = photos;
        uuid = UUID.randomUUID();
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

    @Override
    public int hashCode(){ // TODO
        final int prime = 31;
        int result = 1;
        result = prime * result + ((owner == null) ? 0 : owner.hashCode());
        result = prime * result + ((photos == null) ? 0 : photos.hashCode());
        result = prime * result + ((uuid == null) ? 0 : uuid.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj){
        if (obj == null) return false;
        Album other = (Album)obj;
        return uuid.equals(other.uuid);
    }
}
