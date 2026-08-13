package services;

import models.*;

import java.util.ArrayList;
import java.util.List;

public class SearchService {

    public static List<Photo> globalSearch(String text) {
        List<Photo> result = new ArrayList<>();
        for (Photo photo : OurObjects.photos.values()) {
            if (matches(photo.getName(), text) || matches(captionText(photo), text) ||
                    matches(categoryText(photo), text) || matches(timeText(photo), text) ||
                    matches(commentText(photo), text)) {
                result.add(photo);
            }
        }
        return result;
    }

    public static List<Photo> searchByName(String text) {
        List<Photo> result = new ArrayList<>();
        for (Photo photo : OurObjects.photos.values()) {
            if (matches(photo.getName(), text)) result.add(photo);
        }
        return result;
    }

    public static List<Photo> searchByCaption(String text) {
        List<Photo> result = new ArrayList<>();
        for (Photo photo : OurObjects.photos.values()) {
            if (matches(captionText(photo), text)) result.add(photo);
        }
        return result;
    }

    public static List<Photo> searchByCategory(String text) {
        List<Photo> result = new ArrayList<>();
        for (Photo photo : OurObjects.photos.values()) {
            if (matches(categoryText(photo), text)) result.add(photo);
        }
        return result;
    }

    public static List<Photo> searchByTime(String text) {
        List<Photo> result = new ArrayList<>();
        for (Photo photo : OurObjects.photos.values()) {
            if (matches(timeText(photo), text)) result.add(photo);
        }
        return result;
    }

    public static List<Photo> searchByComments(String text) {
        List<Photo> result = new ArrayList<>();
        for (Photo photo : OurObjects.photos.values()) {
            if (matches(commentText(photo), text)) result.add(photo);
        }
        return result;
    }

    public static List<User> userSearch(String text) {
        List<User> result = new ArrayList<>();
        for (User user : OurObjects.users.values()) {
            boolean flag = false;
            if (matches(user.getFullname(), text)) flag = true;
            if (matches(user.getUsername(), text)) flag = true;
            /*if (matches(user.getUuid().toString(), text)) flag = true;
            if (matches(user.getEmail(), text)) flag = true;
            if (matches(user.getPhone(), text)) flag = true;*/
            if (flag) result.add(user);
        }
        return result;
    }

    private static boolean matches(String value, String text) {
        return value != null && text != null && value.toLowerCase().contains(text.toLowerCase());
    }

    private static String captionText(Photo photo) {
        Caption caption = photo.getCaptionID() == null ? null : OurObjects.captions.get(photo.getCaptionID());
        return caption == null ? "" : caption.getText();
    }

    private static String categoryText(Photo photo) {
        StringBuilder text = new StringBuilder();
        if (photo.getCategoryList() == null) return "";
        for (Category category : photo.getCategoryList()) {
            text.append(category.name()).append(' ');
        }
        return text.toString();
    }

    private static String timeText(Photo photo) {
        return photo.getPhotoAge() == null ? "" : photo.getPhotoAge().toString();
    }

    private static String commentText(Photo photo) {
        StringBuilder text = new StringBuilder();
        if (photo.getCommentIDs() == null) return "";
        for (var commentId : photo.getCommentIDs()) {
            Comment comment = OurObjects.comments.get(commentId);
            if (comment != null) text.append(comment.getText()).append(' ');
        }
        return text.toString();
    }
}
