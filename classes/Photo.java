import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

public class Photo {
    private UUID ownerID;
    private List<UUID> likeIDs;
    private final UUID uuid;
    private String path; // db???
    private List<Category> categoryList = new ArrayList<>();
    private UUID captionID;
    private final String name;
    private List<UUID> commentIDs;
    private LocalDateTime photoAge;

    public Photo(UUID ownerID, String path) {
        this.ownerID = ownerID;
        this.path = path; // ?
        this.categoryList.add(Category.OTHERS);// it should be selectable when they are posting sth.
        this.uuid = UUID.randomUUID();
        OurObjects.photos.put(uuid, this);
        likeIDs = new ArrayList<UUID>();
        captionID = null;
        name = Helper.extractNameFromPath(path);
        photoAge = LocalDateTime.now();
        commentIDs = new ArrayList<>();
    }

    public Photo(UUID ownerID, String path, List<Category> categoryList) {
        this(ownerID, path);
        this.categoryList = categoryList;// it should be selectable when they are posting sth.
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
    public List<Category> getCategoryList() {
        return categoryList;
    }
    public void setCategory(List<Category> categoryList) {
        this.categoryList = categoryList;
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
    public String getName() {
        return name;
    }
    public List<UUID> getCommentIDs() {
        return commentIDs;
    }
    public void setCommentIDs(List<UUID> commentIDs) {
        this.commentIDs = commentIDs;
    }
    public LocalDateTime getPhotoAge() {
        return photoAge;
    }
    public void setPhotoAge(LocalDateTime photoAge) {
        this.photoAge = photoAge;
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

    @Override
    public String toString() {
        // return "Photo [categoryList=" + categoryList + ", captionID=" + captionID + ", name=" + name + ", commentIDs=" + commentIDs + ", photoAge=" + photoAge + "]";
        String res = "";

        res += name + '|';

        res += (OurObjects.captions.containsKey(captionID) ? OurObjects.captions.get(captionID).getText() : "") + '|';

        for (Category category : categoryList) res += category.toString() + ',';
        if (res.charAt(res.length() - 1) == ',') res = res.substring(0, res.length() - 1);
        res += '|';

        res += photoAge.toString() + '|';

        for (UUID commentID : commentIDs){
            if (!OurObjects.comments.containsKey(commentID)) continue; //?
            res += OurObjects.comments.get(commentID).getText() + ',';
        }
        if (res.charAt(res.length() - 1) == ',') res = res.substring(0, res.length() - 1);
        res += '|';
        
        return res;
    }

    
}
