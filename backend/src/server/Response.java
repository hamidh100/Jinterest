package server;

import com.google.gson.JsonObject;

public class Response {
    private int statusCode;
    private String message;
    private JsonObject payload;

    public Response(int statusCode, String message, JsonObject payload) {
        this.statusCode = statusCode;
        this.message = message;
        this.payload = payload == null ? new JsonObject() : payload;
    }

    public static Response ok(String message, JsonObject payload) {
        return new Response(200, message, payload);
    }

    public static Response ok(String message) {
        return new Response(200, message, null);
    }

    public static Response unauthorized(String message) {
        return new Response(401, message, null);
    }

    public static Response forbidden(String message) {
        return new Response(403, message, null);
    }

    public static Response notFound(String message) {
        return new Response(404, message, null);
    }

    public static Response serverError(String message) {
        return new Response(500, message, null);
    }

    public int getStatusCode() {
        return statusCode;
    }

    public String getMessage() {
        return message;
    }

    public JsonObject getPayload() {
        return payload;
    }
}
