import java.time.LocalDateTime;
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
    public int hashCode(){ // TODO
        final int prime = 31;
        int result = 1;
        result = prime * result + ((user == null) ? 0 : user.hashCode());
        result = prime * result + ((time == null) ? 0 : time.hashCode());
        result = prime * result + ((uuid == null) ? 0 : uuid.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj){
        if (obj == null) return false;
        Like other = (Like)obj;
        return uuid.equals(other.uuid);
    }
}
