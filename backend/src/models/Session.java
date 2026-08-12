package models;

import java.time.LocalDateTime;
import java.util.UUID;

public class Session {
    private UUID userId;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;

    public Session(UUID userId, LocalDateTime createdAt, LocalDateTime expiresAt) {
        this.userId = userId;
        this.createdAt = createdAt;
        this.expiresAt = expiresAt;
    }

    public UUID getUserId() {
        return userId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }
}