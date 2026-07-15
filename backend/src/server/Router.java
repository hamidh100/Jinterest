package server;

import com.google.gson.JsonObject;

public class Router {

    public Response route(Request request) {
        try {
            if (request == null || request.getRoute() == null) {
                throw new RouteNotFoundException("Route not specified");
            }

            switch (request.getRoute()) {
                case "ping":
                    return handlePing(request);
                default:
                    throw new RouteNotFoundException("Unknown route: " + request.getRoute());
            }
        } catch (RouteNotFoundException e) {
            return Response.notFound(e.getMessage());
        } catch (Exception e) {
            return Response.serverError("Internal server error: " + e.getMessage());
        }
    }

    private Response handlePing(Request request) {
        JsonObject payload = new JsonObject();
        payload.addProperty("pong", true);
        return Response.ok("pong", payload);
    }
}
