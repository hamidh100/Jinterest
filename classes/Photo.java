import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

public class Photo {
    private User owner;
    private List<User> likedBy;
    private UUID uuid;
    private String path; // db???
    public Photo(User owner, String path){
        this.owner = owner;
        this.path = path; // ?
        this.uuid = UUID.randomUUID();
        likedBy = new ArrayList<User>();
    }


    /* getter setter begin */
    public List<User> getLikedBy() {
        return likedBy;
    }
    public void setLikedBy(List<User> likedBy) {
        this.likedBy = likedBy;
    }
    public User getOwner() {
        return owner;
    }
    public void setOwner(User owner) {
        this.owner = owner;
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
