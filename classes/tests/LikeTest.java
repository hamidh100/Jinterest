import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

public class LikeTest extends initTest {
    @Test
    public void addAndRemoveLike() {
        User user = new User("09111111111", "Qwer1234");
        OurObjects.users.put(user.getUuid(), user);
        Photo photo = new Photo(user.getUuid(), "/Photos/tree.jpg");
        Like like = new Like(user.getUuid());

        PhotoService.addLike(photo, like);
        assertTrue(PhotoService.isLikedBy(photo, user));
        assertEquals(1, photo.getLikeIDs().size());

        PhotoService.removeLike(photo, like);
        assertFalse(PhotoService.isLikedBy(photo, user));
        assertEquals(0, photo.getLikeIDs().size());
    }
}
