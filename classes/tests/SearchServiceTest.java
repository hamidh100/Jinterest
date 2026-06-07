import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

import java.util.List;

public class SearchServiceTest extends initTest {
    @Test
    public void searchByName() {
        Photo photo = new Photo(null, "/Photos/tree.jpg");

        List<Photo> result = SearchService.searchByName("tree");

        assertEquals(1, result.size());
        assertEquals(photo, result.get(0));
    }

    @Test
    public void searchByCaption() {
        Photo photo = new Photo(null, "/Photos/tree.jpg");
        Caption caption = new Caption("Beautiful tree");
        PhotoService.addCaption(photo, caption);

        List<Photo> result = SearchService.searchByCaption("Beautiful tree");

        assertEquals(1, result.size());
        assertEquals(photo, result.get(0));
    }

    @Test
    public void searchByCategory() {
        Photo photo = new Photo(null, "/Photos/tree.jpg");
        PhotoService.addCategory(photo, Category.NATURE);

        List<Photo> result = SearchService.searchByCategory("OTHERS,NATURE");

        assertEquals(1, result.size());
        assertEquals(photo, result.get(0));
    }
}
