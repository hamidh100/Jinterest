import java.util.List;
import java.util.Objects;
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
    public int hashCode() {
        return Objects.hashCode(uuid);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (!(obj instanceof Album)) return false;
        Album other = (Album) obj;
        return Objects.equals(uuid, other.uuid);
    }
}
