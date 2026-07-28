package database;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonParseException;
import com.google.gson.JsonSerializer;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
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
        try {
            DatabaseSnapshot snapshot = GSON.fromJson(Files.readString(DEFAULT_DATABASE_PATH), DatabaseSnapshot.class);
            if (snapshot != null) {
                snapshot.restoreCurrentState();
            }
        } catch (JsonParseException e) {
            throw new IOException("Could not parse database file: " + DEFAULT_DATABASE_PATH, e);
        }
    }
}
