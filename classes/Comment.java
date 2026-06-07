import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

public class Comment {
    private UUID photoID;
    private UUID userID;
    private String text;
    private LocalDateTime time;
    private final UUID uuid;

    public Comment(UUID userID, String text) {
        this.photoID = null;
        this.userID = userID;
        this.text = text;
        time = LocalDateTime.now();
        uuid = UUID.randomUUID();
    }

    /* getter setter begin */
    public UUID getPhotoID() {
        return photoID;
    }

    public void setPhotoID(UUID photoID) {
        this.photoID = photoID;
    }

    public UUID getUserID() {
        return userID;
    }

    public void setUserID(UUID userID) {
        this.userID = userID;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public LocalDateTime getTime() {
        return time;
    }

    public void setTime(LocalDateTime time) {
        this.time = time;
    }

    public UUID getUuid() {
        return uuid;
    }
    /* getter setter end */
    
    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Comment comment)) return false;
        return Objects.equals(uuid, comment.uuid);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(uuid);
    }
}
