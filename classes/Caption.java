import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

public class Caption {
    private UUID photoID;
    private String text;
    private LocalDateTime time;
    private final UUID uuid;
    
    public Caption(String text) {
        this.photoID = null;
        this.text = text;
        time = null;
        uuid = UUID.randomUUID();
    }
    
    /* getter setter begin */
    public UUID getPhotoID() {
        return photoID;
    }

    public void setPhotoID(UUID photoID) {
        this.photoID = photoID;
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
        if (!(o instanceof Caption caption)) return false;
        return Objects.equals(uuid, caption.uuid);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(uuid);
    }
}
