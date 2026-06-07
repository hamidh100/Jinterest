import java.util.List;
import java.util.Scanner;
import java.util.UUID;

import exceptions.AdminAccessRequired;

public class AdminPanel {
    public static void run(User admin) {
        Scanner scanner = new Scanner(System.in);

        while (true) {
            printMenu();
            String input = scanner.nextLine().trim();

            switch (input) {
                case "1" -> printUsers(admin);
                case "2" -> printCounts(admin, scanner);
                case "3" -> setBan(admin, scanner, true);
                case "4" -> setBan(admin, scanner, false);
                case "0" -> {
                    return;
                }
                default -> System.out.println("Invalid input");
            }
        }
    }

    private static void printMenu() {
        System.out.println();
        System.out.println("Admin Panel");
        System.out.println("0. Exit");
        System.out.println("1. List users");
        System.out.println("2. Show user album/photo count");
        System.out.println("3. Ban user");
        System.out.println("4. Unban user");
        System.out.print("Choose: ");
    }

    private static void printUsers(User admin) {
        try {
            List<User> users = AdminService.getUsers(admin);
            for (User user : users) {
                System.out.println(user.toString());
            }
        } catch (AdminAccessRequired e) {
            System.out.println(e.getMessage());
        }
    }

    private static void printCounts(User admin, Scanner scanner) {
        User target = getTargetUser(scanner);
        if (target == null) return;

        try {
            int albumCount = AdminService.getAlbumCount(admin, target);
            int photoCount = AdminService.getPhotoCount(admin, target);
            System.out.println("Albums: " + albumCount);
            System.out.println("Photos: " + photoCount);
        } catch (AdminAccessRequired e) {
            System.out.println(e.getMessage());
        }
    }

    private static void setBan(User admin, Scanner scanner, boolean banned) {
        User target = getTargetUser(scanner);
        if (target == null) return;

        try {
            if (banned) {
                AdminService.banUser(admin, target);
                System.out.println("User banned");
            } else {
                AdminService.unbanUser(admin, target);
                System.out.println("User unbanned");
            }
        } catch (AdminAccessRequired e) {
            System.out.println(e.getMessage());
        }
    }

    private static User getTargetUser(Scanner scanner) {
        System.out.print("User UUID: ");
        String input = scanner.nextLine().trim();
        UUID uuid = UUID.fromString(input);
        User user = OurObjects.users.get(uuid);

        if (user != null)
            return user;

        System.out.println("User not found");
        return null;
    }

}
