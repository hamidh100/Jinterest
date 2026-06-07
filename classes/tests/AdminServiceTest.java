import exceptions.AdminAccessRequired;
import exceptions.UserBanned;
import org.junit.jupiter.api.*;

import static org.junit.jupiter.api.Assertions.*;

public class AdminServiceTest {
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
    public void adminCanReadCountsAndBanUser() throws Exception {
        User admin = new User("admin@gmail.com", "Qwer1234");
        admin.setUserType(UserType.ADMIN);
        User user = new User("09111111111", "Qwer1234");
        Photo photo = new Photo(user.getUuid(), "/Photos/tree.jpg");

        UserService.signup(admin);
        UserService.signup(user);
        PhotoService.addPhoto(user, photo);

        assertEquals(1, AdminService.getPhotoCount(admin, user));
        assertEquals(0, AdminService.getAlbumCount(admin, user));

        AdminService.banUser(admin, user);
        assertTrue(user.isBanned());
        assertThrows(UserBanned.class, () -> UserService.login("09111111111", "Qwer1234"));

        AdminService.unbanUser(admin, user);
        assertFalse(user.isBanned());
        UserService.login("09111111111", "Qwer1234");
    }

    @Test
    public void normalUserCannotUseAdminService() {
        User normalUser = new User("09111111111", "Qwer1234");
        User target = new User("09122222222", "Qwer1234");

        assertThrows(AdminAccessRequired.class, () -> AdminService.banUser(normalUser, target));
    }
}
