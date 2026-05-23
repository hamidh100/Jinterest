public class UserService {
    public static void follow(User follower, User followed) {
        if (follower == null || followed == null) return;
        if (isFollowing(follower, followed)) return;

        follower.getFollowing().add(followed);
        followed.getFollowers().add(follower);
    }

    public static void unfollow(User follower, User followed) {
        if (follower == null || followed == null) return;
        if (!isFollowing(follower, followed)) return;

        follower.getFollowing().remove(followed);
        followed.getFollowers().remove(follower);
    }

    public static boolean isFollowing(User follower, User followed) {
        return follower.getFollowing().contains(followed);
    }

    public static int followersCount(User user) {
        return user.getFollowers().size();
    }

    public static int followingCount(User user) {
        return user.getFollowing().size();
    }
}