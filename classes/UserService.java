public class UserService {
    public static void follow(User follower, User followed) {
        if (follower == null || followed == null) return;
        if (isFollowing(follower, followed)) return;

        follower.getFollowingIDs().add(followed.getUuid());
        followed.getFollowerIDs().add(follower.getUuid());
    }

    public static void unfollow(User follower, User followed) {
        if (follower == null || followed == null) return;
        if (!isFollowing(follower, followed)) return;

        follower.getFollowingIDs().remove(followed.getUuid());
        followed.getFollowerIDs().remove(follower.getUuid());
    }

    public static boolean isFollowing(User follower, User followed) {
        return follower.getFollowingIDs().contains(followed.getUuid());
    }

    public static int followersCount(User user) {
        return user.getFollowerIDs().size();
    }

    public static int followingCount(User user) {
        return user.getFollowingIDs().size();
    }
}