import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

public class Photo {
    private UUID ownerID;
    private List<UUID> likeIDs;
    private final UUID uuid;
    private String path; // db???
    private Category category;
    private UUID captionID;
    private final String name;

    public Photo(UUID ownerID, String path) {
        this.ownerID = ownerID;
        this.path = path; // ?
        this.category = Category.OTHERS;// it should be selectable when they are posting sth.
        this.uuid = UUID.randomUUID();
        OurObjects.photos.put(uuid, this);
        likeIDs = new ArrayList<UUID>();
        captionID = null;
        name = Helper.extractNameFromPath(path);
    }

    public Photo(UUID ownerID, String path, Category category) {
        this(ownerID, path);
        this.category = category;// it should be selectable when they are posting sth.
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
    public Category getCategory() {
        return category;
    }
    public void setCategory(Category category) {
        this.category = category;
    }
    public UUID getCaptionID() {
        return captionID;
    }
    public void setCaptionID(UUID captionID){
        this.captionID = captionID;
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
