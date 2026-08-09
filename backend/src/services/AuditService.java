package services;

import database.DatabaseManager;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public final class AuditService {
    public static final List<String> logs = new ArrayList<>();

    private AuditService() {}

    public static void addLog(String adminId, String action) {
        logs.add(LocalDateTime.now() + " | " + adminId + " | " + action);
        try {
            DatabaseManager.save();
        } catch (Exception e) {}
    }
}
