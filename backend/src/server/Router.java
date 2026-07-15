package server;

import com.google.gson.JsonObject;

public class Router {

    public Response route(Request request) {
        try {
            if (request == null || request.getRoute() == null) {
                throw new RouteNotFoundException("Route not specified");
            }

            switch (request.getRoute()) {
                default:
                    throw new RouteNotFoundException("Unknown route: " + request.getRoute());
            }
        } catch (RouteNotFoundException e) {
            return Response.notFound(e.getMessage());
        } catch (Exception e) {
            return Response.serverError("Internal server error: " + e.getMessage());
        }
    }

}
