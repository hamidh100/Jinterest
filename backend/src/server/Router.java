package server;

import java.io.IOException;
import java.util.UUID;

import com.google.gson.JsonObject;

import database.DatabaseManager;
import exceptions.IncorrectPassword;
import exceptions.InvalidLoginMethod;
import exceptions.InvalidSignupMethod;
import exceptions.InvalidUsername;
import exceptions.UserAlreadyExists;
import exceptions.UserBanned;
import exceptions.UserDoesNotExist;
import exceptions.WeakPassword;
import models.Helper;
import models.OurObjects;
import models.User;
import services.UserService;

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
        JsonObject payload = request.getPayload();
        try {
            String email = getOptionalString(payload, "email");
            String phone = getOptionalString(payload, "phone");
            String password = getRequiredString(payload, "password");
            String fullname = getOptionalString(payload, "fullname");
            boolean hasEmail = (email != null);
            boolean hasPhone = (phone != null);
            if (hasEmail == hasPhone) {
                return Response.badRequest("Signup requires exactly one email or phone number");
            }
            String identifier = hasEmail ? email : phone;
            User user = new User(identifier, password, fullname);
            UserService.signup(user);
            JsonObject responsePayload = new JsonObject();
            responsePayload.add("user", userToJson(user));
            return Response.created("Account created successfully", responsePayload);
        } catch (InvalidSignupMethod e) {
            return Response.badRequest("Invalid signup method");
        } catch (UserAlreadyExists e) {
            return Response.conflict(e.getMessage());
        } catch (WeakPassword e) {
            return Response.badRequest(e.getMessage());
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save account:");
            e.printStackTrace();
            return Response.serverError("Could not save account");
        } catch (Exception e) {
            System.err.println("Unexpected signup error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleLogin(Request request) {
        JsonObject payload = request.getPayload();
        try {
            String identifier = getRequiredString(payload, "identifier");
            String password = getRequiredString(payload, "password");
            UserService.login(identifier, password);
            User user = findUserByIdentifier(identifier);
            if (user == null) return Response.serverError("Logged-in user could not be found");
            JsonObject responsePayload = new JsonObject();
            responsePayload.add("user", userToJson(user));
            return Response.ok("Login successful", responsePayload);
        } catch (InvalidLoginMethod e) {
            return Response.badRequest("Invalid login method");
        } catch (UserDoesNotExist e) {
            return Response.unauthorized(e.getMessage());
        } catch (IncorrectPassword e) {
            return Response.unauthorized(e.getMessage());
        } catch (UserBanned e) {
            return Response.forbidden(e.getMessage());
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (Exception e) {
            System.err.println("Unexpected login error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleGetUser(Request request, String userId) {
        try {
            UUID uuid = parseUuid(userId);
            User user = OurObjects.users.get(uuid);
            if (user == null) return Response.notFound("User does not exist");
            JsonObject responsePayload = new JsonObject();
            responsePayload.add("user", userToJson(user));
            return Response.ok("User found", responsePayload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest("User ID must be a valid UUID");
        } catch (Exception e) {
            System.err.println("Unexpected get-user error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleUpdateUser(Request request, String userId) {
        try {
            UUID uuid = parseUuid(userId);
            User user = OurObjects.users.get(uuid);
            if (user == null) return Response.notFound("User does not exist");
            JsonObject payload = request.getPayload();
            boolean updated = false;
            if (payload.has("username") && !payload.get("username").isJsonNull()) {
                String newUsername = getRequiredString(payload, "username");
                UserService.changeUsername(user, newUsername);
                updated = true;
            }
            if (payload.has("password") && !payload.get("password").isJsonNull()) {
                String newPassword = getRequiredString(payload, "password");
                UserService.changePassword(user, newPassword);
                updated = true;
            }
            if (payload.has("fullname") && !payload.get("fullname").isJsonNull()) {
                String newFullname = getRequiredString(payload, "fullname");
                user.setFullname(newFullname);
                DatabaseManager.save();
                updated = true;
            }
            if (payload.has("email") || payload.has("phone")) {
                return Response.notImplemented("Changing email or phone is not supported yet");
            }
            if (!updated) return Response.badRequest("No valid fields were provided for update");
            JsonObject responsePayload = new JsonObject();
            responsePayload.add("user", userToJson(user));
            return Response.ok("User updated successfully", responsePayload);
        } catch (InvalidUsername e) {
            return Response.badRequest(e.getMessage());
        } catch (UserAlreadyExists e) {
            return Response.conflict(e.getMessage());
        } catch (WeakPassword e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save user update:");
            e.printStackTrace();
            return Response.serverError("Could not save user changes");
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (Exception e) {
            System.err.println("Unexpected update-user error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
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

    private String getRequiredString( JsonObject payload, String field) {
        if (payload == null || !payload.has(field) || payload.get(field).isJsonNull()){
            throw new IllegalArgumentException("Field '" + field + "' is required");
        }
        String value = payload.get(field).getAsString().trim();
        if (value.isEmpty()) {
            throw new IllegalArgumentException("Field '" + field + "' cannot be empty");
        }
        return value;
    }

    private String getOptionalString(JsonObject payload, String field) {
        if (payload == null || !payload.has(field) || payload.get(field).isJsonNull()) {
            return null;
        }
        String value = payload.get(field).getAsString().trim();
        return value.isEmpty() ? null : value;
    }

    private UUID parseUuid(String value) {
        if (value == null || value.equals("")) {
            throw new IllegalArgumentException("UUID is required");
        }
        return UUID.fromString(value);
    }

    private User findUserByIdentifier(String identifier) {
        if (identifier == null || identifier.equals("")) return null;
        String value = identifier.trim();
        String lowercaseValue = Helper.toLower(value);
        UUID userId = OurObjects.usersLowercase.get(lowercaseValue);
        if (userId != null) return OurObjects.users.get(userId);
        userId = OurObjects.emailToUserID.get(value);
        if (userId != null) return OurObjects.users.get(userId);
        userId = OurObjects.phoneToUserID.get(value);
        if (userId != null) return OurObjects.users.get(userId);
        return null;
    }

private JsonObject userToJson(User user) {
    JsonObject json = new JsonObject();
    json.addProperty("id", user.getUuid().toString());
    if (user.getUsername() != null) {
        json.addProperty("username", user.getUsername());
    }
    if (user.getEmail() != null) {
        json.addProperty("email", user.getEmail());
    }
    if (user.getPhone() != null) {
        json.addProperty("phone", user.getPhone());
    }
    if (user.getFullname() != null) {
        json.addProperty("fullname", user.getFullname());
    }
    if (user.getAccountAge() != null) {
        json.addProperty("accountAge", user.getAccountAge().toString());
    }
    if (user.getUserType() != null) {
        json.addProperty("userType", user.getUserType().toString());
    }
    return json;
}
}