import models.*;
import services.*;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

public class PatternTest extends initTest {
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
    public void emailTest(){
        String identifier = "h@h.h";
        assertFalse(identifier.matches(User.PHONENUMBER_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_DEFAULT_PATTERN));
        assertFalse(identifier.matches(User.EMAIL_PATTERN));
        assertFalse(identifier.matches(User.PASSWORD_PATTERN));

        identifier = "h@h.ho";
        assertTrue(identifier.matches(User.EMAIL_PATTERN));

        identifier = "h09121112233.idk@some.thing";
        assertFalse(identifier.matches(User.PHONENUMBER_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_PATTERN));
        assertFalse(identifier.matches(User.USERNAME_DEFAULT_PATTERN));
        assertTrue(identifier.matches(User.EMAIL_PATTERN));
        assertFalse(identifier.matches(User.PASSWORD_PATTERN));
    }

    @Test
    public void passwordTest() {
        String password = "weakPASSWORD";
        assertFalse(password.matches(User.PASSWORD_PATTERN));
        password = "wPAS1!";
        assertFalse(password.matches(User.PASSWORD_PATTERN));
        password = "aaaaaaaaaaaaaaaaaaaa";
        assertFalse(password.matches(User.PASSWORD_PATTERN));
        password = "";
        assertFalse(password.matches(User.PASSWORD_PATTERN));
        password = "strongPASSWORD1";
        assertTrue(password.matches(User.PASSWORD_PATTERN));
    }
}
