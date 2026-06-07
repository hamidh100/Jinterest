import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

public class PatternTest {
    @BeforeEach
    public void init() {
        OurObjects.users.clear();
        OurObjects.usersLowercase.clear();
        OurObjects.emailToUserID.clear();
        OurObjects.phoneToUserID.clear();
        OurObjects.photos.clear();
        OurObjects.albums.clear();
        OurObjects.likes.clear();
        OurObjects.comments.clear();
    }

    @Test
    public void phonenumberTest(){
        String identifier = "09121234567";
        assertTrue(identifier.matches(User.PHONENUMBER_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_DEFAULT_PATTERN));
        assertFalse(identifier.matches(User.EMAIL_PATTERN));
        assertFalse(identifier.matches(User.PASSWORD_PATTERN));
        identifier = "09090000000";
        assertTrue(identifier.matches(User.PHONENUMBER_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_DEFAULT_PATTERN));
        assertFalse(identifier.matches(User.EMAIL_PATTERN));
        assertFalse(identifier.matches(User.PASSWORD_PATTERN));
        identifier = "+989101112233";
        assertTrue(identifier.matches(User.PHONENUMBER_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_DEFAULT_PATTERN));
        assertFalse(identifier.matches(User.EMAIL_PATTERN));
        assertFalse(identifier.matches(User.PASSWORD_PATTERN));
        identifier = "+98910111223";
        assertFalse(identifier.matches(User.PHONENUMBER_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_DEFAULT_PATTERN));
        assertFalse(identifier.matches(User.EMAIL_PATTERN));
        assertFalse(identifier.matches(User.PASSWORD_PATTERN));
        identifier = "0912123456";
        assertFalse(identifier.matches(User.PHONENUMBER_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_DEFAULT_PATTERN));
        assertFalse(identifier.matches(User.EMAIL_PATTERN));
        assertFalse(identifier.matches(User.PASSWORD_PATTERN));
    }

    @Test
    public void passwordTest() {
        
    }
}
