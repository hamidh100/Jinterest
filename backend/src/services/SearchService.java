package services;

import models.*;

import java.util.ArrayList;
import java.util.List;

public class SearchService {

    public static List<Photo> globalSearch(String text) {
        List<Photo> result = new ArrayList<>();
        for (var x : OurObjects.photos.entrySet()) {
            Photo photo = x.getValue();
            if (photo.toString().contains(text)) {
                result.add(photo);
            }
        }
        return result;
    }
    public static List<Photo> searchByName(String text){
        List<Photo> result = new ArrayList<>();
        for (var x : OurObjects.photos.entrySet()) {
            Photo photo = x.getValue();
            if (photo.toString().split("\\|")[0].contains(text)) {
                result.add(photo);
            }
        }
        return result;
    }
    public static List<Photo> searchByCaption(String text){
        List<Photo> result = new ArrayList<>();
        for (var x : OurObjects.photos.entrySet()) {
            Photo photo = x.getValue();
            if (photo.toString().split("\\|")[1].contains(text)) {
                result.add(photo);
            }
        }
        return result;
    }
    public static List<Photo> searchByCategory(String text){
        List<Photo> result = new ArrayList<>();
        for (var x : OurObjects.photos.entrySet()) {
            Photo photo = x.getValue();
            if (photo.toString().split("\\|")[2].contains(text)) {
                result.add(photo);
            }
        }
        return result;
    }
    public static List<Photo> searchByTime(String text){
        List<Photo> result = new ArrayList<>();
        for (var x : OurObjects.photos.entrySet()) {
            Photo photo = x.getValue();
            if (photo.toString().split("\\|")[3].contains(text)) {
                result.add(photo);
            }
        }
        return result;
    }
    public static List<Photo> searchByComments(String text){
        List<Photo> result = new ArrayList<>();
        for (var x : OurObjects.photos.entrySet()) {
            Photo photo = x.getValue();
            if (photo.toString().split("\\|")[4].contains(text)) {
                result.add(photo);
            }
        }
        return result;
    }
}
