import java.util.ArrayList;
import java.util.List;

import static java.util.regex.Pattern.matches;

public class SearchService {

    public static List<Photo> search(String text) {
        List<Photo> result = new ArrayList<>();

        for (Photo photo : OurObjects.photos.values()) {
            if (matches(photo, text)) {
                result.add(photo);
            }
        }

        return result;
    }
}