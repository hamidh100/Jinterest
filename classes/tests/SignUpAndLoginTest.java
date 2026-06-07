import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

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
    }

    @Test
    public void simpleValidSignUp(){
        User user = new User("09121234567", "aStrongPASS!!!#22");
        try {
            UserService.signup(user);
        } catch (Exception e){
            fail();
        }
        assertTrue(OurObjects.users.containsKey(user.getUuid()));
    }

    @Test
    public void userSignUpAndLogin() {
        User user = new User("09111111111", "Qwer1234");
        try {
            UserService.signup(user);
            UserService.login(user);
        } catch (Exception e) {
            fail();
        }

        assertNotNull(user.getUuid());
        assertEquals("09111111111", user.getPhone());
    }
}
