import models.*;
import services.*;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

import exceptions.IncorrectPassword;
import exceptions.InvalidLoginMethod;
import exceptions.InvalidSignupMethod;
import exceptions.UserAlreadyExists;
import exceptions.UserBanned;
import exceptions.UserDoesNotExist;
import exceptions.WeakPassword;

import java.util.UUID;

public class SignUpAndLoginChangeUserPassTest extends initTest {
    @Test
    public void simpleSignUp(){
        String phone = "09121234567";
        User user = new User(phone, "Qwer1234");
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
        User inObjectssUser = OurObjects.users.get(uuid);
        assertNotNull(inObjectssUser);
        assertEquals(phone, user.getPhone());
        assertEquals(user, inObjectssUser);
        assertNotNull(inObjectssUser.getUsername());
        assertTrue(inObjectssUser.getUsername().matches(User.USERNAME_DEFAULT_PATTERN));
        assertFalse(inObjectssUser.getUsername().matches(User.USERNAME_PATTERN));
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

    @Test
    public void signupFail() {
        String identifier = "someone@h.co";
        String password = "Qwer1234";
        User user = new User(identifier, password);
        try {
            UserService.signup(user);
            UserService.login(identifier, password);
        } catch (Exception e) {
            fail();
        }
        try {
            UserService.signup(user);
            fail();
        } catch (exceptions.UserAlreadyExists e){

        } catch (Exception e){
            fail();
        }
    }

    @Test
    public void changeUsernameLogin() throws Exception {
        String identifier = "09111111111";
        String password = "Qwer1234";
        User user = new User(identifier, password);

        UserService.signup(user);
        String oldUsername = user.getUsername();
        UserService.changeUsername(user, "newusername2");

        assertFalse(OurObjects.usersLowercase.containsKey(Helper.toLower(oldUsername)));
        assertEquals(user.getUuid(), OurObjects.usersLowercase.get("newusername2"));
        assertDoesNotThrow(() -> UserService.login("newUSERNAme2", password));
    }

    @Test
    public void changeUsernameRejectsDuplicateUsername() throws Exception {
        User firstUser = new User("09111111111", "Qwer1234");
        User secondUser = new User("09122222222", "Qwer1234");

        UserService.signup(firstUser);
        UserService.signup(secondUser);
        UserService.changeUsername(firstUser, "FirstUser1");

        assertThrows(UserAlreadyExists.class, () -> UserService.changeUsername(secondUser, "firstuser1"));
    }

    @Test
    public void changePasswordRejectsWeakPasswordAndKeepsOldPassword() throws Exception {
        String identifier = "09111111111";
        String oldPassword = "Qwer1234";
        User user = new User(identifier, oldPassword);

        UserService.signup(user);

        assertThrows(WeakPassword.class, () -> UserService.changePassword(user, "short"));
        assertDoesNotThrow(() -> UserService.login(identifier, oldPassword));
    }
}
