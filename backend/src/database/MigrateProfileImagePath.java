package database;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.IOException;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

/** One-time migration that adds profileImagePath to old user records. */
public final class MigrateProfileImagePath {
    private static final Path DATABASE_PATH = Path.of("database", "jinterest.json");

    private MigrateProfileImagePath() {
    }

    public static void main(String[] args) throws IOException {
        if (Files.notExists(DATABASE_PATH)) {
            throw new IOException("Database file was not found: " + DATABASE_PATH);
        }

        Path backupPath = DATABASE_PATH.resolveSibling(
                DATABASE_PATH.getFileName() + ".before-profile-image-path.bak"
        );
        if (Files.exists(backupPath)) {
            throw new IOException("Backup already exists: " + backupPath + ". Migration was not run.");
        }

        JsonElement rootElement = JsonParser.parseString(Files.readString(DATABASE_PATH));
        if (!rootElement.isJsonObject()) {
            throw new IOException("Database root must be a JSON object");
        }
        JsonElement usersElement = rootElement.getAsJsonObject().get("users");
        if (usersElement == null || !usersElement.isJsonObject()) {
            throw new IOException("Database does not contain a users object");
        }

        Files.copy(DATABASE_PATH, backupPath);
        int updatedCount = 0;
        for (JsonElement element : usersElement.getAsJsonObject().asMap().values()) {
            if (!element.isJsonObject()) continue;
            JsonObject user = element.getAsJsonObject();
            if (!user.has("profileImagePath")) {
                user.add("profileImagePath", null);
                updatedCount++;
            }
        }

        Path temporaryPath = Files.createTempFile(DATABASE_PATH.getParent(), "jinterest-", ".tmp");
        try {
            Files.writeString(temporaryPath, new Gson().toJson(rootElement));
            try {
                Files.move(temporaryPath, DATABASE_PATH,
                        StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
            } catch (AtomicMoveNotSupportedException ignored) {
                Files.move(temporaryPath, DATABASE_PATH, StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException error) {
            Files.deleteIfExists(temporaryPath);
            throw error;
        }

        System.out.println("Migration complete. profileImagePath added to " + updatedCount + " user(s).");
        System.out.println("Backup created at " + backupPath);
    }
}
