package models;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

public class Album {
    private UUID ownerID;
    private List<UUID> photoIDs;
    private final UUID uuid;
    private LocalDateTime albumAge;
    private String name;
    private String description;

    public Album(UUID ownerID, List<UUID> photoIDs){
        this(ownerID, photoIDs, "Untitled Album", null);
    }

    public Album(UUID ownerID, List<UUID> photoIDs, String name, String description){
        this.ownerID = ownerID;
        this.photoIDs = photoIDs;
        this.name = name;
        this.description = description;
        uuid = UUID.randomUUID();
        albumAge = LocalDateTime.now();
        OurObjects.albums.put(uuid, this);
    }
    
    /* getter setter begin */
    public UUID getOwnerID() {
        return ownerID;
    }
    public void setOwnerID(UUID ownerID) {
        this.ownerID = ownerID;
    }
    public List<UUID> getPhotoIDs() {
        return photoIDs;
    }
    public void setPhotoIDs(List<UUID> photoIDs) {
        this.photoIDs = photoIDs;
    }
    public UUID getUuid() {
        return uuid;
    }
    public LocalDateTime getAlbumAge() {
        return albumAge;
    }
    public void setAlbumAge(LocalDateTime albumAge) {
        this.albumAge = albumAge;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    /* getter setter end */

    @Override
    public int hashCode() {
        return Objects.hashCode(uuid);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (!(obj instanceof Album other)) return false;
        return Objects.equals(uuid, other.uuid);
    }
}
