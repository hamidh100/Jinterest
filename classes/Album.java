import java.util.List;
import java.util.Objects;
import java.util.UUID;

public class Album {
    private UUID ownerID;
    private List<UUID> photoIDs;
    private final UUID uuid;

    public Album(UUID ownerID, List<UUID> photoIDs){
        this.ownerID = ownerID;
        this.photoIDs = photoIDs;
        uuid = UUID.randomUUID();
        OurObjects.albums.put(uuid, this);
    }
    
    /* getter setter begin */
    public UUID getOwnerID() {
        return ownerID;
    }
    public void setOwnerID(UUID ownerID) {
        this.ownerID = ownerID;
    }
    public List<UUID> getPhotoIDs() {
        return photoIDs;
    }
    public void setPhotoIDs(List<UUID> photoIDs) {
        this.photoIDs = photoIDs;
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
        if (!(obj instanceof Album other)) return false;
        return Objects.equals(uuid, other.uuid);
    }
}
