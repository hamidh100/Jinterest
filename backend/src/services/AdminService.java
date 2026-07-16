package services;

import models.*;

import java.util.ArrayList;
import java.util.List;

import exceptions.AdminAccessRequired;

public class AdminService {
    public static List<User> getUsers(User admin) throws AdminAccessRequired {
        verifyAdmin(admin);
        return new ArrayList<>(OurObjects.users.values());
    }

    public static int getAlbumCount(User admin, User target) throws AdminAccessRequired {
        verifyAdmin(admin);
        return target.getAlbumIDs().size();
    }

    public static int getPhotoCount(User admin, User target) throws AdminAccessRequired {
        verifyAdmin(admin);
        return target.getPhotoIDs().size();
    }

    public static void banUser(User admin, User target) throws AdminAccessRequired {
        verifyAdmin(admin);
        target.setBanned(true);
    }

    public static void unbanUser(User admin, User target) throws AdminAccessRequired {
        verifyAdmin(admin);
        target.setBanned(false);
    }

    private static void verifyAdmin(User user) throws AdminAccessRequired {
        if (user.getUserType() != UserType.ADMIN) {
            throw new AdminAccessRequired("You are not admin!");
        }
    }
}
