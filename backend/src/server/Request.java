package server;

import java.util.UUID;

import com.google.gson.JsonObject;

public class Request {
    private String method;
    private String route;
    private JsonObject payload;
    private UUID sessionToken;
    private UUID authUuid;

    public Request() {}

    public Request(String method, String route, String username, JsonObject payload) {
        this.method = method;
        this.route = route;
        this.payload = payload;
    }

    public String getMethod() {
        return method;
    }

    public String getRoute() {
        return route;
    }

    public JsonObject getPayload() {
        return payload == null ? new JsonObject() : payload;
    }

    public UUID getSessionToken() {
        return sessionToken;
    }

    public UUID getAuthUuid() {
        return authUuid;
    }

    public void setAuthUuid(UUID authUuid) { 
        this.authUuid = authUuid;
    }
}
