import org.junit.jupiter.api.*;

import exceptions.InvalidSignupMethod;
import exceptions.UserAlreadyExists;
import exceptions.WeakPassword;

import static org.junit.jupiter.api.Assertions.*;

public class FollowTest extends initTest {
    @Test
    public void twoUsersFollowEachOther() throws InvalidSignupMethod, UserAlreadyExists, WeakPassword {
        User user1 = new User("a@gmail.com", "SDF#$%HGNx1");
        UserService.signup(user1);
        User user2 = new User("b@gmail.com", "SDF#$%HGNx1");
        UserService.signup(user2);
        assertEquals(0, UserService.followersCount(user1));
        assertEquals(0, UserService.followersCount(user2));
        assertEquals(0, UserService.followingCount(user1));
        assertEquals(0, UserService.followingCount(user2));

        UserService.follow(user2, user1);
        assertEquals(1, UserService.followersCount(user1));
        assertEquals(0, UserService.followersCount(user2));
        assertEquals(0, UserService.followingCount(user1));
        assertEquals(1, UserService.followingCount(user2));

        UserService.unfollow(user1, user2);
        assertEquals(1, UserService.followersCount(user1));
        assertEquals(0, UserService.followersCount(user2));
        assertEquals(0, UserService.followingCount(user1));
        assertEquals(1, UserService.followingCount(user2));

        UserService.unfollow(user2, user1);
        assertEquals(0, UserService.followersCount(user1));
        assertEquals(0, UserService.followersCount(user2));
        assertEquals(0, UserService.followingCount(user1));
        assertEquals(0, UserService.followingCount(user2));

        UserService.follow(user1, user2);
        UserService.follow(user1, user2);
        UserService.follow(user1, user2);
        UserService.follow(user2, user1);
        assertEquals(1, UserService.followersCount(user1));
        assertEquals(1, UserService.followersCount(user2));
        assertEquals(1, UserService.followingCount(user1));
        assertEquals(1, UserService.followingCount(user2));
    }
}
