package database;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonParseException;
import com.google.gson.JsonSerializer;

import java.io.IOException;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public final class DatabaseManager {
    private static final Path DEFAULT_DATABASE_PATH = Path.of("backend", "database", "jinterest.json");

    private static final Gson GSON = createGson();

    private DatabaseManager() {
    }

    private static Gson createGson() {
        GsonBuilder builder = new GsonBuilder();

        builder.registerTypeAdapter(
                LocalDateTime.class,
                (JsonSerializer<LocalDateTime>) (dateTime, type, context) ->
                        context.serialize(dateTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME))
        );
        builder.registerTypeAdapter(
                LocalDateTime.class,
                (JsonDeserializer<LocalDateTime>) (json, type, context) ->
                        LocalDateTime.parse(json.getAsString(), DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        );

        return builder.create();
    }

    public static synchronized void load() throws IOException {
        if (Files.notExists(DEFAULT_DATABASE_PATH) || Files.size(DEFAULT_DATABASE_PATH) == 0) {
            return;
        }

        try {
            DatabaseSnapshot snapshot = GSON.fromJson(Files.readString(DEFAULT_DATABASE_PATH), DatabaseSnapshot.class);
            if (snapshot != null) {
                snapshot.restoreCurrentState();
            }
        } catch (JsonParseException e) {
            throw new IOException("Could not parse database file: " + DEFAULT_DATABASE_PATH, e);
        }
    }

    public static synchronized void save() throws IOException {
        Path directory = DEFAULT_DATABASE_PATH.getParent();
        Files.createDirectories(directory);

        Path temporaryFile = Files.createTempFile(directory, "jinterest-", ".tmp");
        boolean saved = false;

        try {
            DatabaseSnapshot snapshot = DatabaseSnapshot.fromCurrentState();
            Files.writeString(temporaryFile, GSON.toJson(snapshot));

            try {
                Files.move(temporaryFile, DEFAULT_DATABASE_PATH,
                        StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
            } catch (AtomicMoveNotSupportedException e) {
                Files.move(temporaryFile, DEFAULT_DATABASE_PATH, StandardCopyOption.REPLACE_EXISTING);
            }

            saved = true;
        } finally {
            if (!saved) {
                Files.deleteIfExists(temporaryFile);
            }
        }
    }
}
