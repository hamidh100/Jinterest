import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

public class Like {
    private UUID userID;
    private LocalDateTime time; // not visible publicly, but admins can see
    private final UUID uuid;

    public Like(UUID userID){
        this.userID = userID;
        time = LocalDateTime.now(); // ?
        uuid = UUID.randomUUID();
        OurObjects.likes.put(uuid, this);
    }

    public Like(UUID userID, LocalDateTime time){
        this.userID = userID;
        this.time = time;
        uuid = UUID.randomUUID();
        OurObjects.likes.put(uuid, this);
    }

    /* getter setter begin */
    public UUID getUserID() {
        return userID;
    }

    public void setUserID(UUID userID) {
        this.userID = userID;
    }

    public LocalDateTime getTime(){
        return time;
    }

    public void setTime(LocalDateTime time){
        this.time = time;
    }

    public UUID getUuid(){
        return uuid;
    }
    /* getter setter end */

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Like like)) return false;
        return Objects.equals(uuid, like.uuid);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(uuid);
    }
}
