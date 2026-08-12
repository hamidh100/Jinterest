package services;

import models.OurObjects;
import models.Session;

import java.time.LocalDateTime;
import java.util.UUID;

public class SessionService {
    private static final long SESSION_DURATION = 24; // hour

    private SessionService() {}

    public static UUID createSession(UUID userId) { // login
        UUID token = UUID.randomUUID();
        LocalDateTime now = LocalDateTime.now();
        Session session = new Session(userId, now, now.plusHours(SESSION_DURATION));
        OurObjects.sessions.put(token, session);
        return token;
    }

    public static UUID getUserId(UUID token) {
        if (token == null) return null;
        Session session = OurObjects.sessions.get(token);
        if (session == null) return null;
        if (LocalDateTime.now().isAfter(session.getExpiresAt())) {
            OurObjects.sessions.remove(token);
            return null;
        }
        return session.getUserId();
    }

    public static void invalidate(UUID token) { // logout
        if (token != null) OurObjects.sessions.remove(token);
    }
}