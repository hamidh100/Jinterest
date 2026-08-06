package server;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

import javax.imageio.ImageIO;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

import database.DatabaseManager;
import exceptions.IncorrectPassword;
import exceptions.InvalidLoginMethod;
import exceptions.InvalidSignupMethod;
import exceptions.InvalidUsername;
import exceptions.UserAlreadyExists;
import exceptions.UserBanned;
import exceptions.UserDoesNotExist;
import exceptions.WeakPassword;
import models.Album;
import models.Caption;
import models.Category;
import models.Comment;
import models.Helper;
import models.Like;
import models.OurObjects;
import models.Photo;
import models.User;
import services.AlbumService;
import services.PhotoService;
import services.SearchService;
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
                /*
                    /photos/{id}/image
                    /photos/{id}
                 */
                if (isPhotoImageRoute(route)) {
                    String photoId = getPart(route, 2);
                    return handleGetPhotoImage(request, photoId);
                }
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

    private boolean isPhotoImageRoute(String route) {
        String[] parts = splitRoute(route);
        return parts.length == 3 && parts[0].equals("photos") && parts[2].equals("image");
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
                isPhotoImageRoute(route) || isPhotoRoute(route) || isAlbumRoute(route) || isUserRoute(route) || isCommentRoute(route) ||
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
        JsonArray photosJson = new JsonArray();
        for (Photo photo : OurObjects.photos.values()) {
            photosJson.add(photoToJson(photo));
        }
        JsonObject payload = new JsonObject();
        payload.add("photos", photosJson);
        return Response.ok("Photos found", payload);
    }

    private Response handleGetPhotoImage(Request request, String photoId) {
        try {
            UUID photoUuid = parseUuid(photoId);
            Photo photo = OurObjects.photos.get(photoUuid);
            if (photo == null) return Response.notFound("Photo does not exist");
            String imagePath = photo.getPath();
            if (imagePath == null || imagePath.isBlank()) {
                return Response.notFound("Photo image does not exist");
            }
            Path path = Path.of(imagePath);
            if (!Files.exists(path) || !Files.isRegularFile(path)) {
                return Response.notFound("Photo image file does not exist");
            }
            byte[] imageBytes = Files.readAllBytes(path);
            JsonObject payload = new JsonObject();
            payload.addProperty("fileName", path.getFileName().toString());
            payload.addProperty("imageBase64", Base64.getEncoder().encodeToString(imageBytes));
            return Response.ok("Photo image found", payload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest("Photo ID must be a valid UUID");
        } catch (IOException e) {
            System.err.println("Could not read photo image:");
            e.printStackTrace();
            return Response.serverError("Could not read photo image");
        } catch (Exception e) {
            System.err.println("Unexpected get-photo-image error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }


    private Response handleGetPhoto(Request request, String photoId) {
        try {
            UUID uuid = parseUuid(photoId);
            Photo photo = OurObjects.photos.get(uuid);
            if (photo == null) return Response.notFound("Photo does not exist");
            JsonObject payload = new JsonObject();
            payload.add("photo", photoToJson(photo));
            return Response.ok("Photo found", payload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest("Photo ID must be a valid UUID");
        }
    }

    private Response handleCreatePhoto(Request request) {
        try {
            JsonObject payload = request.getPayload();
            UUID ownerId = parseUuid(getRequiredString(payload, "ownerId"));
            User owner = OurObjects.users.get(ownerId);
            if (owner == null) return Response.notFound("Owner user does not exist");
            String imageBase64 = getOptionalString(payload, "imageBase64");
            String fileName = getOptionalString(payload, "fileName");
            String path;
            List<Category> categories = readCategories(payload);
            if (imageBase64 != null) {
                if (fileName == null) {
                    return Response.badRequest("fileName is required with imageBase64");
                }
                path = ImageStorage.saveBase64Image(imageBase64, fileName);
            } else {
                path = getRequiredString(payload, "path");
            }
            Photo photo = (categories == null) ? new Photo(ownerId, path) : new Photo(ownerId, path, categories);
            BufferedImage image = ImageIO.read(Path.of(path).toFile());
            if (image == null) {
                return Response.badRequest("Uploaded file is not a readable image");
            }
            photo.setWidth(image.getWidth());
            photo.setHeight(image.getHeight());
            String name = getOptionalString(payload, "name");
            if (name != null) {
                photo.setName(name);
            } else {
                photo.setName(Helper.extractNameFromPath(fileName));
            }
            boolean isPublic = true;
            if (payload.has("isPublic") &&
                    !payload.get("isPublic").isJsonNull()) {
                isPublic = payload.get("isPublic").getAsBoolean();
            }
            photo.setPublic(isPublic);
            if (payload.has("commentsAllowed") &&
                    !payload.get("commentsAllowed").isJsonNull()) {
                photo.setCommentsAllowed(payload.get("commentsAllowed").getAsBoolean());
            }
            PhotoService.addPhoto(owner, photo);
            String captionText = getOptionalString(payload, "caption");
            if (captionText != null) {
                Caption caption = new Caption(captionText);
                PhotoService.addCaption(photo, caption);
            }
            DatabaseManager.save();
            JsonObject responsePayload = new JsonObject();
            responsePayload.add("photo", photoToJson(photo));
            return Response.created("Photo created successfully", responsePayload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save photo:");
            e.printStackTrace();
            return Response.serverError("Could not save photo");
        } catch (Exception e) {
            System.err.println("Unexpected create-photo error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleUpdatePhoto(Request request, String photoId) {
        try {
            UUID uuid = parseUuid(photoId);
            Photo photo = OurObjects.photos.get(uuid);
            if (photo == null) return Response.notFound("Photo does not exist");
            JsonObject payload = request.getPayload();
            boolean updated = false;
            if (payload.has("path") && !payload.get("path").isJsonNull()) {
                String path = getRequiredString(payload, "path");
                photo.setPath(path);
                updated = true;
            }
            if (payload.has("categories") && !payload.get("categories").isJsonNull()) {
                List<Category> categories = readCategories(payload);
                photo.setCategory(categories);
                updated = true;
            }
            if (payload.has("caption") && !payload.get("caption").isJsonNull()) {
                String captionText = getRequiredString(payload, "caption");
                if (photo.getCaptionID() != null) {
                    Caption caption = OurObjects.captions.get(
                            photo.getCaptionID()
                    );
                    if (caption != null) {
                        caption.setText(captionText);
                        caption.setTime(LocalDateTime.now());
                    } else {
                        Caption newCaption = new Caption(captionText);
                        PhotoService.addCaption(photo, newCaption);
                    }
                } else {
                    Caption newCaption = new Caption(captionText);
                    PhotoService.addCaption(photo, newCaption);
                }
                updated = true;
            }
            if (payload.has("commentsAllowed") &&
                    !payload.get("commentsAllowed").isJsonNull()) {
                photo.setCommentsAllowed(payload.get("commentsAllowed").getAsBoolean());
                updated = true;
            }
            if (!updated) return Response.badRequest("No valid fields were provided for update");
            DatabaseManager.save();
            JsonObject responsePayload = new JsonObject();
            responsePayload.add("photo", photoToJson(photo));
            return Response.ok("Photo updated successfully", responsePayload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save photo update:");
            e.printStackTrace();
            return Response.serverError("Could not save photo changes");
        } catch (Exception e) {
            System.err.println("Unexpected update-photo error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleDeletePhoto(Request request, String photoId) {
        try {
            UUID uuid = parseUuid(photoId);
            Photo photo = OurObjects.photos.get(uuid);
            if (photo == null) return Response.notFound("Photo does not exist");
            User owner = OurObjects.users.get(photo.getOwnerID());
            if (owner != null) {
                owner.getPhotoIDs().remove(photo.getUuid());
            }
            if (photo.getCaptionID() != null) {
                OurObjects.captions.remove(photo.getCaptionID());
            }
            for (UUID commentId : new ArrayList<>(photo.getCommentIDs())) {
                OurObjects.comments.remove(commentId);
            }
            for (UUID likeId : new ArrayList<>(photo.getLikeIDs())) {
                OurObjects.likes.remove(likeId);
            }
            for (Album album : OurObjects.albums.values()) {
                if (album.getPhotoIDs() != null) {
                    album.getPhotoIDs().remove(photo.getUuid());
                }
            }
            for (User user : OurObjects.users.values()) {
                if (user.getSavedPhotoIDs() != null) {
                    user.getSavedPhotoIDs().remove(photo.getUuid());
                }
            }
            OurObjects.photos.remove(photo.getUuid());
            DatabaseManager.save();
            return Response.ok("Photo deleted successfully");
        } catch (IllegalArgumentException e) {
            return Response.badRequest("Photo ID must be a valid UUID");
        } catch (IOException e) {
            System.err.println("Could not save after deleting photo:");
            e.printStackTrace();
            return Response.serverError("Could not save photo deletion");
        } catch (Exception e) {
            System.err.println("Unexpected delete-photo error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleLikePhoto(Request request, String photoId) {
        try {
            UUID photoUuid = parseUuid(photoId);
            Photo photo = OurObjects.photos.get(photoUuid);
            if (photo == null) return Response.notFound("Photo does not exist");
            String userIdText = getRequiredString(request.getPayload(), "userId");
            UUID userUuid = parseUuid(userIdText);
            User user = OurObjects.users.get(userUuid);
            if (user == null) return Response.notFound("User does not exist");
            if (PhotoService.isLikedBy(photo, user)) {
                return Response.conflict("Photo is already liked by this user");
            }
            Like like = new Like(userUuid);
            PhotoService.addLike(photo, like);
            DatabaseManager.save();
            JsonObject payload = new JsonObject();
            payload.addProperty("photoId", photo.getUuid().toString());
            payload.addProperty("likeCount", photo.getLikeIDs().size());
            return Response.created("Photo liked successfully", payload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save like:");
            e.printStackTrace();
            return Response.serverError("Could not save like");
        } catch (Exception e) {
            System.err.println("Unexpected like error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleUnlikePhoto(Request request, String photoId) {
        try {
            UUID photoUuid = parseUuid(photoId);
            Photo photo = OurObjects.photos.get(photoUuid);
            if (photo == null) return Response.notFound("Photo does not exist");
            String userIdText = getRequiredString(request.getPayload(), "userId");
            UUID userUuid = parseUuid(userIdText);
            User user = OurObjects.users.get(userUuid);
            if (user == null) return Response.notFound("User does not exist");
            UUID likeToRemove = null;
            for (UUID likeId : new ArrayList<>(photo.getLikeIDs())) {
                Like like = OurObjects.likes.get(likeId);
                if (like != null && userUuid.equals(like.getUserID())) {
                    likeToRemove = likeId;
                    break;
                }
            }
            if (likeToRemove == null) return Response.notFound("This user has not liked the photo");
            photo.getLikeIDs().remove(likeToRemove);
            OurObjects.likes.remove(likeToRemove);
            DatabaseManager.save();
            JsonObject payload = new JsonObject();
            payload.addProperty("photoId", photo.getUuid().toString());
            payload.addProperty("likeCount", photo.getLikeIDs().size());
            return Response.ok("Photo unliked successfully", payload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save unlike:");
            e.printStackTrace();
            return Response.serverError("Could not save unlike");
        } catch (Exception e) {
            System.err.println("Unexpected unlike error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleGetPhotoComments(Request request, String photoId) {
        try {
            UUID photoUuid = parseUuid(photoId);
            Photo photo = OurObjects.photos.get(photoUuid);
            if (photo == null) return Response.notFound("Photo does not exist");
            JsonArray commentsJson = new JsonArray();
            for (UUID commentId : photo.getCommentIDs()) {
                Comment comment = OurObjects.comments.get(commentId);
                if (comment != null) {
                    commentsJson.add(commentToJson(comment));
                }
            }
            JsonObject payload = new JsonObject();
            payload.add("comments", commentsJson);
            return Response.ok("Comments found", payload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest("Photo ID must be a valid UUID");
        }
    }


    private Response handleCreateComment(Request request, String photoId) {
        try {
            UUID photoUuid = parseUuid(photoId);
            Photo photo = OurObjects.photos.get(photoUuid);
            if (photo == null) return Response.notFound("Photo does not exist");
            JsonObject payload = request.getPayload();
            UUID userUuid = parseUuid(getRequiredString(payload, "userId"));
            User user = OurObjects.users.get(userUuid);
            if (user == null) return Response.notFound("User does not exist");
            if (!photo.isCommentsAllowed() && !userUuid.equals(photo.getOwnerID())) {
                return Response.forbidden("Comments are disabled for this photo");
            }
            String text = getRequiredString(payload, "text");
            Comment comment = new Comment(userUuid, text);
            PhotoService.addComment(photo, comment);
            DatabaseManager.save();
            JsonObject responsePayload = new JsonObject();
            responsePayload.add("comment", commentToJson(comment));
            return Response.created("Comment created successfully", responsePayload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save comment:");
            e.printStackTrace();
            return Response.serverError("Could not save comment");
        } catch (Exception e) {
            System.err.println("Unexpected create-comment error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }


    private Response handleDeleteComment(Request request, String commentId) {
        try {
            UUID commentUuid = parseUuid(commentId);
            Comment comment = OurObjects.comments.get(commentUuid);
            if (comment == null) return Response.notFound("Comment does not exist");
            if (comment.getPhotoID() != null) {
                Photo photo = OurObjects.photos.get(comment.getPhotoID());
                if (photo != null) {
                    photo.getCommentIDs().remove(comment.getUuid());
                }
            }
            OurObjects.comments.remove(comment.getUuid());
            DatabaseManager.save();
            return Response.ok("Comment deleted successfully");
        } catch (IllegalArgumentException e) {
            return Response.badRequest("Comment ID must be a valid UUID");
        } catch (IOException e) {
            System.err.println("Could not save comment deletion:");
            e.printStackTrace();
            return Response.serverError("Could not delete comment");
        } catch (Exception e) {
            System.err.println("Unexpected delete-comment error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleGetAlbums(Request request) {
        JsonArray albumsJson = new JsonArray();
        for (Album album : OurObjects.albums.values()) {
            albumsJson.add(albumToJson(album));
        }
        JsonObject payload = new JsonObject();
        payload.add("albums", albumsJson);
        return Response.ok("Albums found", payload);
    }

    private Response handleGetAlbum(Request request, String albumId) {
        try {
            UUID uuid = parseUuid(albumId);
            Album album = OurObjects.albums.get(uuid);
            if (album == null) return Response.notFound("Album does not exist");
            JsonObject payload = new JsonObject();
            payload.add("album", albumToJson(album));
            return Response.ok("Album found", payload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest("Album ID must be a valid UUID");
        }
    }

    private Response handleCreateAlbum(Request request) {
        try {
            JsonObject payload = request.getPayload();
            UUID ownerId = parseUuid(getRequiredString(payload, "ownerId"));
            User owner = OurObjects.users.get(ownerId);
            if (owner == null) return Response.notFound("Owner user does not exist");
            List<UUID> photoIds = readPhotoIds(payload, "photoIds");
            for (UUID photoId : photoIds) {
                if (!OurObjects.photos.containsKey(photoId)) {
                    return Response.notFound("Photo does not exist: " + photoId);
                }
            }
            String name = getOptionalString(payload, "name");
            String description = getOptionalString(payload, "description");
            boolean isPublic = true;
            if (payload.has("isPublic") &&
                    !payload.get("isPublic").isJsonNull()) {
                isPublic = payload.get("isPublic").getAsBoolean();
            }
            Album album = new Album(ownerId, photoIds,
                    name == null ? "Untitled Album" : name, description, isPublic);
            AlbumService.addAlbum(owner, album);
            DatabaseManager.save();
            JsonObject responsePayload = new JsonObject();
            responsePayload.add("album", albumToJson(album));
            return Response.created("Album created successfully", responsePayload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save album:");
            e.printStackTrace();
            return Response.serverError("Could not save album");
        } catch (Exception e) {
            System.err.println("Unexpected create-album error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleUpdateAlbum(Request request, String albumId) {
        try {
            UUID albumUuid = parseUuid(albumId);
            Album album = OurObjects.albums.get(albumUuid);
            if (album == null) return Response.notFound("Album does not exist");
            JsonObject payload = request.getPayload();
            if (!payload.has("photoIds") || payload.get("photoIds").isJsonNull()) {
                return Response.badRequest("Field 'photoIds' is required");
            }
            List<UUID> photoIds = readPhotoIds(payload, "photoIds");
            for (UUID photoId : photoIds) {
                if (!OurObjects.photos.containsKey(photoId)) {
                    return Response.notFound("Photo does not exist: " + photoId);
                }
            }
            album.setPhotoIDs(photoIds);
            if (payload.has("name") && !payload.get("name").isJsonNull()) {
                album.setName(getRequiredString(payload, "name"));
            }
            if (payload.has("description") && !payload.get("description").isJsonNull()) {
                album.setDescription(getRequiredString(payload, "description"));
            }
            if (payload.has("isPublic") && !payload.get("isPublic").isJsonNull()) {
                album.setPublic(payload.get("isPublic").getAsBoolean());
            }
            DatabaseManager.save();
            JsonObject responsePayload = new JsonObject();
            responsePayload.add("album", albumToJson(album));
            return Response.ok("Album updated successfully", responsePayload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save album update:");
            e.printStackTrace();
            return Response.serverError("Could not save album changes");
        } catch (Exception e) {
            System.err.println("Unexpected update-album error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleDeleteAlbum(Request request, String albumId) {
        try {
            UUID albumUuid = parseUuid(albumId);
            Album album = OurObjects.albums.get(albumUuid);
            if (album == null) return Response.notFound("Album does not exist");
            User owner = OurObjects.users.get(album.getOwnerID());
            if (owner != null) {
                owner.getAlbumIDs().remove(album.getUuid());
            }
            OurObjects.albums.remove(album.getUuid());
            DatabaseManager.save();
            return Response.ok("Album deleted successfully");
        } catch (IllegalArgumentException e) {
            return Response.badRequest("Album ID must be a valid UUID");
        } catch (IOException e) {
            System.err.println("Could not save album deletion:");
            e.printStackTrace();
            return Response.serverError("Could not delete album");
        } catch (Exception e) {
            System.err.println("Unexpected delete-album error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleFollowUser(Request request, String userId) {
        try {
            UUID followedId = parseUuid(userId);
            User followed = OurObjects.users.get(followedId);
            if (followed == null) return Response.notFound("User to follow does not exist");
            UUID followerId = parseUuid(getRequiredString(request.getPayload(), "followerId"));
            User follower = OurObjects.users.get(followerId);
            if (follower == null) return Response.notFound("Follower user does not exist");
            if (follower.equals(followed)) return Response.badRequest("A user cannot follow themselves");
            if (UserService.isFollowing(follower, followed)) {
                return Response.conflict("User is already being followed");
            }
            UserService.follow(follower, followed);
            JsonObject payload = new JsonObject();
            payload.addProperty("followerId", follower.getUuid().toString());
            payload.addProperty("followedId", followed.getUuid().toString());
            return Response.created("User followed successfully", payload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save follow:");
            e.printStackTrace();
            return Response.serverError("Could not save follow");
        } catch (Exception e) {
            System.err.println("Unexpected follow error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleUnfollowUser(Request request, String userId) {
        try {
            UUID followedId = parseUuid(userId);
            User followed = OurObjects.users.get(followedId);
            if (followed == null) return Response.notFound("User does not exist");
            UUID followerId = parseUuid(getRequiredString(request.getPayload(), "followerId"));
            User follower = OurObjects.users.get(followerId);
            if (follower == null) return Response.notFound("Follower user does not exist");
            if (follower.equals(followed)) return Response.badRequest("A user cannot unfollow themselves");
            if (!UserService.isFollowing(follower, followed)) {
                return Response.notFound("User is not currently being followed");
            }
            UserService.unfollow(follower, followed);
            JsonObject payload = new JsonObject();
            payload.addProperty("followerId", follower.getUuid().toString());
            payload.addProperty("followedId", followed.getUuid().toString());
            return Response.ok("User unfollowed successfully", payload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (IOException e) {
            System.err.println("Could not save unfollow:");
            e.printStackTrace();
            return Response.serverError("Could not save unfollow");
        } catch (Exception e) {
            System.err.println("Unexpected unfollow error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
    }

    private Response handleSearch(Request request) {
        try {
            JsonObject payload = request.getPayload();
            String type = Helper.toLower(getRequiredString(payload, "type"));
            String text = getRequiredString(payload, "text");
            List<Photo> results;
            switch (type) {
                case "global":
                    results = SearchService.globalSearch(text);
                    break;
                case "name":
                    results = SearchService.searchByName(text);
                    break;
                case "caption":
                    results = SearchService.searchByCaption(text);
                    break;
                case "category":
                    results = SearchService.searchByCategory(text);
                    break;
                case "time":
                    results = SearchService.searchByTime(text);
                    break;
                case "comments":
                    results = SearchService.searchByComments(text);
                    break;
                default:
                    return Response.badRequest("Unknown search type: " + type);
            }
            JsonArray photosJson = new JsonArray();
            for (Photo photo : results) {
                photosJson.add(photoToJson(photo));
            }
            JsonObject responsePayload = new JsonObject();
            responsePayload.add("photos", photosJson);
            return Response.ok("Search completed", responsePayload);
        } catch (IllegalArgumentException e) {
            return Response.badRequest(e.getMessage());
        } catch (Exception e) {
            System.err.println("Unexpected search error:");
            e.printStackTrace();
            return Response.serverError("Internal server error");
        }
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
        JsonArray followerIds = new JsonArray();
        for (UUID followerId : user.getFollowerIDs()) {
            followerIds.add(followerId.toString());
        }
        json.add("followerIds", followerIds);
        JsonArray followingIds = new JsonArray();
        for (UUID followingId : user.getFollowingIDs()) {
            followingIds.add(followingId.toString());
        }
        json.add("followingIds", followingIds);
        return json;
    }

    private JsonObject photoToJson(Photo photo) {
        JsonObject json = new JsonObject();
        json.addProperty("id", photo.getUuid().toString());
        if (photo.getOwnerID() != null) {
            json.addProperty("ownerId", photo.getOwnerID().toString());
            User owner = OurObjects.users.get(photo.getOwnerID());
            if (owner != null && owner.getUsername() != null) {
                json.addProperty("ownerUsername", owner.getUsername());
            }
        }
        json.addProperty("name", photo.getName());
        json.addProperty("path", photo.getPath());
        json.addProperty("isPublic", photo.isPublic());
        json.addProperty("commentsAllowed", photo.isCommentsAllowed());
        if (photo.getPhotoAge() != null) {
            json.addProperty("photoAge", photo.getPhotoAge().toString());
        }
        JsonArray categories = new JsonArray();
        if (photo.getCategoryList() != null) {
            for (Category category : photo.getCategoryList()) {
                categories.add(category.name());
            }
        }
        json.add("categories", categories);
        if (photo.getCaptionID() != null) {
            Caption caption = OurObjects.captions.get(photo.getCaptionID());
            if (caption != null) {
                json.add("caption", captionToJson(caption));
            }
        }
        JsonArray likedByUserIds = new JsonArray();
        if (photo.getLikeIDs() != null) {
            for (UUID likeId : photo.getLikeIDs()) {
                Like like = OurObjects.likes.get(likeId);
                if (like != null && like.getUserID() != null) {
                    likedByUserIds.add(like.getUserID().toString());
                }
            }
        }
        json.add("likedByUserIds", likedByUserIds);
        json.addProperty("likeCount", photo.getLikeIDs() == null ? 0 : photo.getLikeIDs().size());
        json.addProperty("commentCount", photo.getCommentIDs() == null ? 0 : photo.getCommentIDs().size());
        json.addProperty("imageWidth", photo.getWidth());
        json.addProperty("imageHeight", photo.getHeight());
        return json;
    }

    private JsonObject captionToJson(Caption caption) {
        JsonObject json = new JsonObject();
        json.addProperty("id", caption.getUuid().toString());
        json.addProperty("text", caption.getText());
        if (caption.getTime() != null) {
            json.addProperty("time", caption.getTime().toString());
        }
        return json;
    }

    private JsonObject commentToJson(Comment comment) {
        JsonObject json = new JsonObject();
        json.addProperty("id", comment.getUuid().toString());
        if (comment.getPhotoID() != null) {
            json.addProperty("photoId", comment.getPhotoID().toString());
        }
        if (comment.getUserID() != null) {
            json.addProperty("userId", comment.getUserID().toString());
            User user = OurObjects.users.get(comment.getUserID());
            if (user != null && user.getUsername() != null) {
                json.addProperty("username", user.getUsername());
            }
        }
        json.addProperty("text", comment.getText());
        if (comment.getTime() != null) {
            json.addProperty("time", comment.getTime().toString());
        }
        return json;
    }

    private List<Category> readCategories(JsonObject payload) {
        List<Category> categories = new ArrayList<>();
        if (payload == null || !payload.has("categories") ||
            payload.get("categories").isJsonNull()) {
            return categories;
        }
        JsonElement categoriesElement = payload.get("categories");
        if (!categoriesElement.isJsonArray()) throw new IllegalArgumentException("'categories' must be an array");
        JsonArray categoriesArray = categoriesElement.getAsJsonArray();
        for (JsonElement element : categoriesArray) {
            if (!element.isJsonPrimitive() || !element.getAsJsonPrimitive().isString()) {
                throw new IllegalArgumentException("Each category must be a string");
            }
            String categoryText = Helper.toUpper(element.getAsString().trim());
            if (categoryText.isEmpty()) {
                throw new IllegalArgumentException("Category cannot be empty");
            }
            try {
                Category category = Category.valueOf(categoryText);
                if (!categories.contains(category)) {
                    categories.add(category);
                }
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Unknown category: " + categoryText);
            }
        }
        return categories;
    }

    private List<UUID> readPhotoIds(JsonObject payload, String field) {
        if (!payload.has(field) || payload.get(field).isJsonNull()) {
            throw new IllegalArgumentException("Field '" + field + "' is required");
        }
        JsonElement element = payload.get(field);
        if (!element.isJsonArray()) {
            throw new IllegalArgumentException("Field '" + field + "' must be an array");
        }
        JsonArray array = element.getAsJsonArray();
        List<UUID> result = new ArrayList<>();
        for (JsonElement item : array) {
            if (!item.isJsonPrimitive()) {
                throw new IllegalArgumentException("Every photo ID must be a string");
            }
            String value = item.getAsString().trim();
            if (value.isEmpty()) {
                throw new IllegalArgumentException("Photo ID cannot be empty");
            }
            UUID photoId = parseUuid(value);
            if (!result.contains(photoId)) {
                result.add(photoId);
            }
        }
        return result;
    }

    private JsonObject albumToJson(Album album) {
        JsonObject json = new JsonObject();
        json.addProperty("id", album.getUuid().toString());
        json.addProperty("name", album.getName());
        if (album.getDescription() != null) {
            json.addProperty("description", album.getDescription());
        }
        json.addProperty("isPublic", album.isPublic());
        if (album.getOwnerID() != null) {
            json.addProperty("ownerId", album.getOwnerID().toString());
            User owner = OurObjects.users.get(album.getOwnerID());
            if (owner != null && owner.getUsername() != null) {
                json.addProperty("ownerUsername", owner.getUsername());
            }
        }
        JsonArray photos = new JsonArray();
        int totalLikes = 0;
        if (album.getPhotoIDs() != null) {
            for (UUID photoId : album.getPhotoIDs()) {
                Photo photo = OurObjects.photos.get(photoId);
                if (photo == null) continue;
                photos.add(photoToJson(photo));
                totalLikes += (photo.getLikeIDs() == null) ? 0 : photo.getLikeIDs().size();
            }
        }
        json.add("photos", photos);
        json.addProperty("photoCount", photos.size());
        json.addProperty("totalLikes", totalLikes);
        if (album.getAlbumAge() != null) {
            json.addProperty("albumAge", album.getAlbumAge().toString());
        }
        return json;
    }
}
