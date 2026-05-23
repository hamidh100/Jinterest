import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

public class Like {
    private User user;
    private LocalDateTime time; // not visible publicly, but admins can see
    private UUID uuid;

    public Like(User user){
        this.user = user;
        time = LocalDateTime.now(); // ?
        uuid = UUID.randomUUID();
    }

    public Like(User user, LocalDateTime time){
        this.user = user;
        this.time = time;
        uuid = UUID.randomUUID();
    }

    /* getter setter begin */
    public User getUser(){
        return user;
    }

    public void setUser(User user){
        this.user = user;
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

    public void setUuid(UUID uuid){
        this.uuid = uuid;
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
