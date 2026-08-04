package server;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.Base64;
import java.util.UUID;

import models.Helper;

public final class ImageStorage {
    private static final Path IMAGE_DIRECTORY = Path.of("database", "images");
    private static final int MAX_IMAGE_BYTES = 10 * 1024 * 1024;
    private ImageStorage() {}

    public static String saveBase64Image(String base64, String originalFileName) throws IOException {
        if (base64 == null || base64.isBlank()) {
            throw new IllegalArgumentException("Image data is required");
        }
        String extension = getSafeExtension(originalFileName);
        String cleanBase64 = removeDataPrefix(base64);
        byte[] imageBytes;
        try {
            imageBytes = Base64.getDecoder().decode(cleanBase64);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid Base64 image data");
        }
        if (imageBytes.length == 0) {
            throw new IllegalArgumentException("Image cannot be empty");
        }
        if (imageBytes.length > MAX_IMAGE_BYTES) {
            throw new IllegalArgumentException("Image is too large. Maximum size is 5 MB");
        }
        Files.createDirectories(IMAGE_DIRECTORY);
        String fileName = UUID.randomUUID() + extension;
        Path destination = IMAGE_DIRECTORY.resolve(fileName);
        Files.write(destination, imageBytes, StandardOpenOption.CREATE_NEW);
        return destination.toString();
    }

    private static String removeDataPrefix(String base64) {
        int commaIndex = base64.indexOf(',');
        if (base64.startsWith("data:") && commaIndex >= 0) {
            return base64.substring(commaIndex + 1);
        }
        return base64;
    }

    private static String getSafeExtension(String originalFileName) {
        if (originalFileName == null || originalFileName.isBlank()) {
            throw new IllegalArgumentException("File name is required");
        }
        String fileName = Helper.toLower(Path.of(originalFileName).getFileName().toString());
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex < 0) {
            throw new IllegalArgumentException("Image file must have an extension");
        }
        String extension = fileName.substring(dotIndex);
        if (!extension.equals(".jpg") && !extension.equals(".jpeg") &&
            !extension.equals(".png") && !extension.equals(".webp")) {
            throw new IllegalArgumentException("Unsupported image type");
        }
        return extension;
    }
}