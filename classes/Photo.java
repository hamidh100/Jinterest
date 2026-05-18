import java.util.ArrayList;
import java.util.List;

public class Photo {
    private User owner;
    private List<User> likedBy;
    private int likedCount;
    private long id;
    private String path; // ?
    public Photo(User owner, String path){
        this.owner = owner;
        this.path = path; // ?
        this.id = 0; // TODO
        likedBy = new ArrayList<User>();
        likedCount = 0;
    }

    public boolean isLikedBy(User user){
        if (likedBy == null || likedBy.size() == 0) return false;
        for (User someone : likedBy){
            if (someone != null && someone.equals(user)) return true;
        }
        return false;
    }
    public void addLike(User user){
        if (isLikedBy(user)) return;
        likedBy.add(user);
        likedCount++;
    }
    public void removeLike(User user){
        if (!isLikedBy(user)) return;
        likedBy.remove(user);
        likedCount--;
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
    public int getLikedCount() {
        return likedCount;
    }
    /* getter setter end */
}
