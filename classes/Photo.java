import java.util.ArrayList;
import java.util.List;
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
    public int hashCode(){ // TODO
        final int prime = 31;
        int result = 1;
        result = prime * result + ((owner == null) ? 0 : owner.hashCode());
        result = prime * result + ((likedBy == null) ? 0 : likedBy.hashCode());
        result = prime * result + ((uuid == null) ? 0 : uuid.hashCode());
        result = prime * result + ((path == null) ? 0 : path.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj){
        if (obj == null) return false;
        Photo other = (Photo)obj;
        return uuid.equals(other.uuid);
    }
}
