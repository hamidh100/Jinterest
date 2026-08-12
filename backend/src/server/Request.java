package server;

import java.util.UUID;

import com.google.gson.JsonObject;

public class Request {
    private String method;
    private String route;
    private String username;
    private JsonObject payload;
    private UUID sessionToken;

    public Request() {}

    public Request(String method, String route, String username, JsonObject payload) {
        this.method = method;
        this.route = route;
        this.username = username;
        this.payload = payload;
    }

    public String getMethod() {
        return method;
    }

    public String getRoute() {
        return route;
    }

    public String getUsername() {
        return username;
    }

    public JsonObject getPayload() {
        return payload == null ? new JsonObject() : payload;
    }

    public UUID getSessionToken() {
        return sessionToken;
    }
}
