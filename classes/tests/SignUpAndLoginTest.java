import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

import java.util.UUID;

public class SignUpAndLoginTest {
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
        OurObjects.captions.clear();
    }

    @Test
    public void simpleValidSignUp(){
        String phone = "09121234567";
        User user = new User(phone, "aStrongPASS!!!#22");
        try {
            UserService.signup(user);
        } catch (Exception e){
            fail();
        }
        assertTrue(OurObjects.users.containsKey(user.getUuid()));
        UUID uuid = OurObjects.phoneToUserID.get("0912123456");
        assertNull(uuid);
        uuid = OurObjects.phoneToUserID.get("09121234567");
        assertTrue(OurObjects.users.containsKey(uuid));
        User inObjsUser = OurObjects.users.get(uuid);
        assertNotNull(inObjsUser);
        assertEquals(user.getPhone(), phone);
        assertEquals(user, inObjsUser);
        assertNotNull(inObjsUser.getUsername());
        assertTrue(inObjsUser.getUsername().matches(User.USERNAME_DEFAULT_PATTERN));
        assertFalse(inObjsUser.getUsername().matches(User.USERNAME_PATTERN));
    }

    @Test
    public void userSignUpAndLogin() {
        String identifier = "09111111111";
        String password = "Qwer1234";
        User user = new User(identifier, password);
        try {
            UserService.signup(user);
            UserService.login(identifier, password);
        } catch (Exception e) {
            fail();
        }

        assertNotNull(user.getUuid());
        assertEquals("09111111111", user.getPhone());
    }
}
