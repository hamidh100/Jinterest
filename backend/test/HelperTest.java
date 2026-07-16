import models.*;
import services.*;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

public class HelperTest extends initTest {
    @Test
    public void extractNameFromPathTest() {
        String path = "aaaaaaaa/b.c";
        assertEquals("b", Helper.extractNameFromPath(path));
        path = "/b.c";
        assertEquals("b", Helper.extractNameFromPath(path));
        path = "tree.jpeg";
        assertEquals("tree", Helper.extractNameFromPath(path));
        path = "tree.me.png";
        assertEquals("tree.me", Helper.extractNameFromPath(path));
        path = "///tree.me.";
        assertEquals("tree.me", Helper.extractNameFromPath(path));
        path = "\\aaa\\tree.c";
        assertEquals("tree", Helper.extractNameFromPath(path));
        path = "";
        assertEquals("", Helper.extractNameFromPath(path));
        path = null;
        assertNull(Helper.extractNameFromPath(path));
    }
}
