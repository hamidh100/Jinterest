import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

public class Photo {
    private UUID ownerID;
    private List<UUID> likeIDs;
    private final UUID uuid;
    private String path; // db???
    public Photo(UUID ownerID, String path){
        this.ownerID = ownerID;
        this.path = path; // ?
        this.uuid = UUID.randomUUID();
        OurObjects.photos.put(uuid, this);
        likeIDs = new ArrayList<UUID>();
    }
    
    /* getter setter begin */
    public UUID getOwnerID() {
        return ownerID;
    }
    public void setOwnerID(UUID ownerID) {
        this.ownerID = ownerID;
    }
    public List<UUID> getLikeIDs() {
        return likeIDs;
    }
    public void setLikeIDs(List<UUID> likeIDs) {
        this.likeIDs = likeIDs;
    }
    public String getPath() {
        return path;
    }
    public void setPath(String path) {
        this.path = path;
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
        if (!(obj instanceof Photo other)) return false;
        return Objects.equals(uuid, other.uuid);
    }
}
