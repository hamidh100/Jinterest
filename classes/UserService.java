import exceptions.InvalidUsername;
import exceptions.WeakPassword;

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

    public static void saveAlbum(User user, Album album) {
        user.getSavedAlbums().add(album.getUuid());
    }

    public static void savePhoto(User user, Photo photo) {
        user.getSavedPhotoIDs().add(photo.getUuid());
    }

    public void checkUsername(User user) throws InvalidUsername {
        String username = user.getUsername();
        if (username == null || username.length() < 3) throw new exceptions.InvalidUsername(exceptions.InvalidUsernameTypes.TOOSHORT);
        if (username.length() > 20) throw new exceptions.InvalidUsername(exceptions.InvalidUsernameTypes.TOOLONG);
        if (!username.matches(User.USERNAME_PATTERN)) throw new exceptions.InvalidUsername(exceptions.InvalidUsernameTypes.PATTERNMISMATCH);
    }

    public String getEmailName(User user){
        String email = user.getEmail();
        if (user == null || email == null || !email.matches(User.EMAIL_PATTERN)) return null;
        return email.split("@")[0];
    }

    public void checkPassword(User user) throws WeakPassword {
        String username = user.getUsername();
        String password = user.getPassword();
        if (password == null || password.length() < 8) throw new exceptions.WeakPassword(exceptions.WeakPasswordTypes.TOOSHORT);
        if ((getEmailName(user) != null && password.contains(getEmailName(user))) ||
            (username != null && password.contains(username))) throw new exceptions.WeakPassword(exceptions.WeakPasswordTypes.CONTAINSUSER);
        if (!password.matches(User.PASSWORD_PATTERN)) throw new exceptions.WeakPassword(exceptions.WeakPasswordTypes.PATTERNMISMATCH); // error priority?
    }

    public static void signup(User user){ // user as input? add to map after signup
        
    }

    public static void login(User user){ // with throws

    }
}
