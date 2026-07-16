import models.*;
import services.*;
import org.junit.jupiter.api.*;

import exceptions.InvalidSignupMethod;
import exceptions.UserAlreadyExists;
import exceptions.WeakPassword;

import static org.junit.jupiter.api.Assertions.*;

public class FollowTest extends initTest {
    @Test
    public void twoUsersFollowAndUnfollowEachOther() throws InvalidSignupMethod, UserAlreadyExists, WeakPassword {
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

        UserService.unfollow(user2, user1);
        assertEquals(0, UserService.followersCount(user1));
        assertEquals(1, UserService.followersCount(user2));
        assertEquals(1, UserService.followingCount(user1));
        assertEquals(0, UserService.followingCount(user2));

        assertEquals(user1.getUuid(), user2.getFollowerIDs().get(0));
        assertEquals(user2.getUuid(), user1.getFollowingIDs().get(0));
        assertEquals(0, user2.getFollowingIDs().size());
        assertEquals(0, user1.getFollowerIDs().size());
    }
    @Test
    public void fourUsers() throws InvalidSignupMethod, UserAlreadyExists, WeakPassword {
        User user1 = new User("a@gmail.com", "SDF#$%HGNx1");
        UserService.signup(user1);
        User user2 = new User("b@gmail.com", "SDF#$%HGNx1");
        UserService.signup(user2);
        User user3 = new User("c@gmail.com", "SDF#$%HGNx1");
        UserService.signup(user3);
        User user4 = new User("d@gmail.com", "SDF#$%HGNx1");
        UserService.signup(user4);

        UserService.follow(user1, user4);
        UserService.follow(user2, user4);
        UserService.follow(user3, user4);
        UserService.follow(user2, user3);
        UserService.unfollow(user2, user3);
        UserService.follow(user2, user3);
        UserService.follow(user3, user2);
        UserService.unfollow(user2, user3);
        UserService.unfollow(user3, user2);

        assertEquals(3, user4.getFollowerIDs().size());
        assertEquals(0, user4.getFollowingIDs().size());

        assertEquals(1, user1.getFollowingIDs().size());
        assertEquals(1, user2.getFollowingIDs().size());
        assertEquals(1, user3.getFollowingIDs().size());
        assertEquals(0, user1.getFollowerIDs().size());
        assertEquals(0, user2.getFollowerIDs().size());
        assertEquals(0, user3.getFollowerIDs().size());

        assertEquals(user4.getUuid(), user1.getFollowingIDs().get(0));
        assertEquals(user4.getUuid(), user2.getFollowingIDs().get(0));
        assertEquals(user4.getUuid(), user3.getFollowingIDs().get(0));
    }
}
