package server;

import com.google.gson.JsonObject;

import models.Helper;

public class Router {
    public Response route(Request request) {
        try {
            if (request == null) return Response.badRequest("Request is required");
            if (request.getMethod() == null) return Response.badRequest("Method is required");
            if (request.getRoute() == null) return Response.badRequest("Route is required");
            String method = Helper.toUpper(request.getMethod().trim());
            String route = normalizeRoute(request.getRoute());
            switch (method) {
                case "GET": return handleGet(request, route);
                case "POST": return handlePost(request, route);
                case "PUT": return handlePut(request, route);
                case "DELETE": return handleDelete(request, route);
                default: return Response.methodNotAllowed("Unsupported method: " + method);
            }
        } catch (Exception e) {
            System.err.println("Router error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleGet(Request request, String route) {
        switch (route) {
            case "/ping": return handlePing();
            case "/photos": return handleGetPhotos(request);
            case "/albums": return handleGetAlbums(request);
            case "/search": return handleSearch(request);
            default:
                if (isPhotoRoute(route)) {
                    String photoId = getPart(route, 2);
                    return handleGetPhoto(request, photoId);
                }
                if (isAlbumRoute(route)) {
                    String albumId = getPart(route, 2);
                    return handleGetAlbum(request, albumId);
                }
                if (isPhotoCommentsRoute(route)) {
                    String photoId = getPart(route, 2);
                    return handleGetPhotoComments(request, photoId);
                }
                if (isUserRoute(route)) {
                    String userId = getPart(route, 2);
                    return handleGetUser(request, userId);
                }
                return Response.notFound("Route not found: GET " + route);
        }
    }

    private Response handlePost(Request request, String route) {
        switch (route) {
            case "/auth/signup": return handleSignup(request);
            case "/auth/login": return handleLogin(request);
            case "/photos": return handleCreatePhoto(request);
            case "/albums": return handleCreateAlbum(request);
            case "/search": return handleSearch(request);
            default:
                if (isPhotoLikesRoute(route)) {
                    String photoId = getPart(route, 2);
                    return handleLikePhoto(request, photoId);
                }
                if (isPhotoCommentsRoute(route)) {
                    String photoId = getPart(route, 2);
                    return handleCreateComment(request, photoId);
                }
                if (isUserFollowRoute(route)) {
                    String userId = getPart(route, 2);
                    return handleFollowUser(request, userId);
                }
                if (pathExists(route)) {
                    return Response.methodNotAllowed(
                            "POST is not allowed for " + route
                    );
                }
                return Response.notFound("Route not found: POST " + route);
        }
    }

    private Response handlePut(Request request, String route) {
        if (isPhotoRoute(route)) {
            String photoId = getPart(route, 2);
            return handleUpdatePhoto(request, photoId);
        }
        if (isAlbumRoute(route)) {
            String albumId = getPart(route, 2);
            return handleUpdateAlbum(request, albumId);
        }
        if (isUserRoute(route)) {
            String userId = getPart(route, 2);
            return handleUpdateUser(request, userId);
        }
        if (pathExists(route)) {
            return Response.methodNotAllowed(
                    "PUT is not allowed for " + route
            );
        }
        return Response.notFound("Route not found: PUT " + route);
    }

    private Response handleDelete(Request request, String route) {
        if (isPhotoRoute(route)) {
            String photoId = getPart(route, 2);
            return handleDeletePhoto(request, photoId);
        }
        if (isAlbumRoute(route)) {
            String albumId = getPart(route, 2);
            return handleDeleteAlbum(request, albumId);
        }
        if (isPhotoLikesRoute(route)) {
            String photoId = getPart(route, 2);
            return handleUnlikePhoto(request, photoId);
        }
        if (isUserFollowRoute(route)) {
            String userId = getPart(route, 2);
            return handleUnfollowUser(request, userId);
        }
        if (isCommentRoute(route)) {
            String commentId = getPart(route, 2);
            return handleDeleteComment(request, commentId);
        }
        if (pathExists(route)) return Response.methodNotAllowed("DELETE is not allowed for " + route);
        return Response.notFound("Route not found: DELETE " + route);
    }

    private String normalizeRoute(String route) {
        String result = route.trim();
        if (!result.startsWith("/")) result = "/" + result;
        if (result.length() > 1 && result.endsWith("/")) {
            result = result.substring(0, result.length() - 1);
        }
        return result;
    }

    private boolean isPhotoRoute(String route) {
        String[] parts = splitRoute(route);
        return parts.length == 2 && parts[0].equals("photos");
    }

    private boolean isAlbumRoute(String route) {
        String[] parts = splitRoute(route);
        return parts.length == 2 && parts[0].equals("albums");
    }

    private boolean isUserRoute(String route) {
        String[] parts = splitRoute(route);
        return parts.length == 2 && parts[0].equals("users");
    }

    private boolean isCommentRoute(String route) {
        String[] parts = splitRoute(route);
        return parts.length == 2 && parts[0].equals("comments");
    }

    private boolean isPhotoLikesRoute(String route) {
        String[] parts = splitRoute(route);
        return parts.length == 3 && parts[0].equals("photos") && parts[2].equals("likes");
    }

    private boolean isPhotoCommentsRoute(String route) {
        String[] parts = splitRoute(route);
        return parts.length == 3 && parts[0].equals("photos") && parts[2].equals("comments");
    }

    private boolean isUserFollowRoute(String route) {
        String[] parts = splitRoute(route);
        return parts.length == 3 && parts[0].equals("users") && parts[2].equals("follow");
    }

    private String[] splitRoute(String route) {
        if (route.equals("/")) return new String[0];
        return route.substring(1).split("/");
    }

    private String getPart(String route, int position) {
        String[] parts = splitRoute(route);
        if (position < 1 || position > parts.length) return null;
        return parts[position - 1];
    }

    private boolean pathExists(String route) {
        return route.equals("/ping") || route.equals("/photos") || route.equals("/albums") ||
                route.equals("/search") || route.equals("/auth/signup") || route.equals("/auth/login") ||
                isPhotoRoute(route) ||isAlbumRoute(route) || isUserRoute(route) || isCommentRoute(route) ||
                isPhotoLikesRoute(route) || isPhotoCommentsRoute(route) || isUserFollowRoute(route);
    }

    private Response handlePing() {
        JsonObject payload = new JsonObject();
        payload.addProperty("pong", true);
        return Response.ok("pong", payload);
    }

    private Response handleSignup(Request request) {
        return Response.notImplemented(
                "Signup has not been implemented yet"
        );
    }

    private Response handleLogin(Request request) {
        return Response.notImplemented(
                "Login has not been implemented yet"
        );
    }

    private Response handleGetUser(Request request, String userId) {
        return Response.notImplemented(
                "Get user has not been implemented yet"
        );
    }

    private Response handleUpdateUser(Request request, String userId) {
        return Response.notImplemented(
                "Update user has not been implemented yet"
        );
    }

    private Response handleGetPhotos(Request request) {
        return Response.notImplemented(
                "Get photos has not been implemented yet"
        );
    }

    private Response handleGetPhoto(Request request, String photoId) {
        return Response.notImplemented(
                "Get photo has not been implemented yet"
        );
    }

    private Response handleCreatePhoto(Request request) {
        return Response.notImplemented(
                "Create photo has not been implemented yet"
        );
    }

    private Response handleUpdatePhoto(Request request, String photoId) {
        return Response.notImplemented(
                "Update photo has not been implemented yet"
        );
    }

    private Response handleDeletePhoto(Request request, String photoId) {
        return Response.notImplemented(
                "Delete photo has not been implemented yet"
        );
    }

    private Response handleLikePhoto(Request request, String photoId) {
        return Response.notImplemented(
                "Like photo has not been implemented yet"
        );
    }

    private Response handleUnlikePhoto(Request request, String photoId) {
        return Response.notImplemented(
                "Unlike photo has not been implemented yet"
        );
    }

    private Response handleGetPhotoComments(Request request, String photoId) {
        return Response.notImplemented(
                "Get comments has not been implemented yet"
        );
    }

    private Response handleCreateComment(Request request, String photoId) {
        return Response.notImplemented(
                "Create comment has not been implemented yet"
        );
    }

    private Response handleDeleteComment(Request request, String commentId) {
        return Response.notImplemented(
                "Delete comment has not been implemented yet"
        );
    }

    private Response handleGetAlbums(Request request) {
        return Response.notImplemented(
                "Get albums has not been implemented yet"
        );
    }

    private Response handleGetAlbum(Request request, String albumId) {
        return Response.notImplemented(
                "Get album has not been implemented yet"
        );
    }

    private Response handleCreateAlbum(Request request) {
        return Response.notImplemented(
                "Create album has not been implemented yet"
        );
    }

    private Response handleUpdateAlbum(Request request, String albumId) {
        return Response.notImplemented(
                "Update album has not been implemented yet"
        );
    }

    private Response handleDeleteAlbum(Request request, String albumId) {
        return Response.notImplemented(
                "Delete album has not been implemented yet"
        );
    }

    private Response handleFollowUser(Request request, String userId) {
        return Response.notImplemented(
                "Follow user has not been implemented yet"
        );
    }

    private Response handleUnfollowUser(Request request, String userId) {
        return Response.notImplemented(
                "Unfollow user has not been implemented yet"
        );
    }

    private Response handleSearch(Request request) {
        return Response.notImplemented(
                "Search has not been implemented yet"
        );
    }
}