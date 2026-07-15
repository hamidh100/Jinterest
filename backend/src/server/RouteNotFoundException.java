package server;

public class RouteNotFoundException extends RuntimeException {

    public RouteNotFoundException(String message) {
        super(message);
    }
}
