import org.junit.jupiter.api.*;
import java.util.ArrayList;
import static org.junit.jupiter.api.Assertions.*;

public class PhotoAndAlbumTest extends initTest {
    @Test
    public void addPhoto() {
        User user = new User("09111111111", "Qwer1234");
        Photo photo = new Photo(user.getUuid(), "/Photos/tree.jpg");

        PhotoService.addPhoto(user, photo);

        assertTrue(user.getPhotoIDs().contains(photo.getUuid()));
        assertEquals(1, user.getPhotoIDs().size());
    }

    @Test
    public void addPhotoWithCaption() {
        User user = new User("09111111111", "Qwer1234");
        Photo photo = new Photo(user.getUuid(), "/Photos/tree.jpg");
        Caption caption = new Caption("My beautiful tree!");

        PhotoService.addPhoto(user, photo);

        assertTrue(user.getPhotoIDs().contains(photo.getUuid()));
        assertEquals(1, user.getPhotoIDs().size());

        assertNull(photo.getCaptionID());
        assertNull(caption.getPhotoID());
        assertFalse(OurObjects.captions.containsKey(caption.getUuid()));
        PhotoService.addCaption(photo, caption);
        assertTrue(OurObjects.captions.containsKey(caption.getUuid()));
        assertNotNull(photo.getCaptionID());
        assertNotNull(caption.getPhotoID());
        PhotoService.removeCaption(photo);
        assertNull(photo.getCaptionID());
        assertNull(caption.getPhotoID());
        assertFalse(OurObjects.captions.containsKey(caption.getUuid()));
    }

    @Test
    public void addAlbum() {
        User user = new User("09111111111", "Qwer1234");
        Album album = new Album(user.getUuid(), new ArrayList<>());

        AlbumService.addAlbum(user, album);

        assertEquals(user.getUuid(), album.getOwnerID());
        assertTrue(user.getAlbumIDs().contains(album.getUuid()));
        assertEquals(1, user.getAlbumIDs().size());

        Photo photo1 = new Photo(user.getUuid(), "/Photos/tree.jpg");
        Photo photo2 = new Photo(user.getUuid(), "/Photos/notabeautifultree.jpg");

        PhotoService.addPhoto(user, photo1);
        AlbumService.addPhoto(album, photo2);
        AlbumService.addPhoto(album, photo1);

        assertEquals(1, user.getPhotoIDs().size());
        assertEquals(1, user.getAlbumIDs().size());
    }

    @Test
    public void addAndRemoveLike() {
        User user = new User("09111111111", "Qwer1234");
        OurObjects.users.put(user.getUuid(), user);
        Photo photo = new Photo(user.getUuid(), "/Photos/tree.jpg");
        Like like = new Like(user.getUuid());

        PhotoService.addLike(photo, like);
        assertTrue(PhotoService.isLikedBy(photo, user));
        assertEquals(1, photo.getLikeIDs().size());

        PhotoService.removeLike(photo, like);
        assertFalse(PhotoService.isLikedBy(photo, user));
        assertEquals(0, photo.getLikeIDs().size());
    }
}
