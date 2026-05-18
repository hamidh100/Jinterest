import java.util.List;

public class Photo {
    private User owner;
    private List<User> likedBy;
    private long id;
    private String path; // ?
    public Photo(User owner, String path){
        this.owner = owner;
        this.path = path; // ?
        this.id = 0; // TODO
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
    public long getId() {
        return id;
    }
    public void setId(long id) {
        this.id = id;
    }
    public String getPath() {
        return path;
    }
    public void setPath(String path) {
        this.path = path;
    }
    /* getter setter end */
}
