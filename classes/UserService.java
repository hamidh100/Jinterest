import java.util.Random;

import exceptions.*;

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

    public static void checkUsername(User user) throws InvalidUsername {
        String username = user.getUsername();
        if (username == null || username.length() < 3) throw new exceptions.InvalidUsername(exceptions.InvalidUsernameTypes.TOOSHORT);
        if (username.length() > 20) throw new exceptions.InvalidUsername(exceptions.InvalidUsernameTypes.TOOLONG);
        if (!username.matches(User.USERNAME_PATTERN)) throw new exceptions.InvalidUsername(exceptions.InvalidUsernameTypes.PATTERNMISMATCH);
    }

    public static String getEmailName(User user){
        String email = user.getEmail();
        if (user == null || email == null || !email.matches(User.EMAIL_PATTERN)) return null;
        return email.split("@")[0];
    }

    public static void checkPassword(User user) throws WeakPassword {
        String username = user.getUsername();
        String password = user.getPassword();
        if (password == null || password.length() < 8) throw new exceptions.WeakPassword(exceptions.WeakPasswordTypes.TOOSHORT);
        if ((getEmailName(user) != null && password.contains(getEmailName(user))) ||
            (username != null && password.contains(username))) throw new exceptions.WeakPassword(exceptions.WeakPasswordTypes.CONTAINSUSER);
        if (!password.matches(User.PASSWORD_PATTERN)) throw new exceptions.WeakPassword(exceptions.WeakPasswordTypes.PATTERNMISMATCH); // error priority?
    }

    public static String generateRandUniqUsername(){
        String result = "user#";
        Random random = new Random();
        int charPref = 0;
        for (int it = 0; it < 8; it++){
            int r = (charPref == 2 ? random.nextInt(10) : random.nextInt(36));
            charPref++;
            if (r < 10) charPref = 0;
            result += (char)(r < 10 ? '0' + r : 'a' + r - 10);
        }
        return OurObjects.usersLowercase.containsKey(result) ? generateRandUniqUsername() : result;
    }

    public static void signup(User user) throws InvalidSignupMethod, UserAlreadyExists, WeakPassword {
        if (user.getEmail() == null && user.getPhone() == null) throw new exceptions.InvalidSignupMethod();
        if (user.getEmail() != null && user.getPhone() != null) throw new exceptions.InvalidSignupMethod(); // only one?
        if (user.getUsername() != null) throw new exceptions.InvalidSignupMethod(); // pointless ig
        if (user.getEmail() != null && OurObjects.emailToUserID.containsKey(user.getEmail())) throw new exceptions.UserAlreadyExists(user.getEmail());
        if (user.getPhone() != null && OurObjects.phoneToUserID.containsKey(user.getPhone())) throw new exceptions.UserAlreadyExists(user.getPhone());
        checkPassword(user);
        user.setUsername(generateRandUniqUsername());
        OurObjects.users.put(user.getUuid(), user);
        OurObjects.usersLowercase.put(user.getUsername(), user.getUuid());
        if (user.getEmail() != null) OurObjects.emailToUserID.put(user.getEmail(), user.getUuid());
        if (user.getPhone() != null) OurObjects.phoneToUserID.put(user.getPhone(), user.getUuid());
    }

    public static void login(User user) throws InvalidLoginMethod, UserDoesNotExist, IncorrectPassword {
        int identifierCount = (user.getEmail() == null ? 0 : 1) + (user.getPhone() == null ? 0 : 1) + (user.getUsername() == null ? 0 : 1);
        if (identifierCount != 1) throw new exceptions.InvalidLoginMethod();
        if (user.getEmail() != null){
            if (!OurObjects.emailToUserID.containsKey(user.getEmail())) throw new exceptions.UserDoesNotExist(user.getEmail());
            String realPassword = OurObjects.users.get(OurObjects.emailToUserID.get(user.getEmail())).getPassword();
            if (!realPassword.equals(user.getPassword())) throw new exceptions.IncorrectPassword();
        }
        if (user.getPhone() != null){
            if (!OurObjects.phoneToUserID.containsKey(user.getPhone())) throw new exceptions.UserDoesNotExist(user.getPhone());
            String realPassword = OurObjects.users.get(OurObjects.phoneToUserID.get(user.getPhone())).getPassword();
            if (!realPassword.equals(user.getPassword())) throw new exceptions.IncorrectPassword();
        }
        if (user.getUsername() != null){
            // lower upper
            if (!OurObjects.usersLowercase.containsKey(user.getUsername())) throw new exceptions.UserDoesNotExist(user.getUsername());
            String realPassword = OurObjects.users.get(OurObjects.usersLowercase.get(user.getUsername())).getPassword();
            if (!realPassword.equals(user.getPassword())) throw new exceptions.IncorrectPassword();
        }
    }
}
