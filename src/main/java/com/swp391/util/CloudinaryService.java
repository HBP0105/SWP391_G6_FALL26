package com.swp391.util;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Service to upload and delete images directly to Cloudinary using their REST API.
 * Pure Java implementation (no external SDK required).
 */
public class CloudinaryService {

    private static final Logger LOGGER = Logger.getLogger(CloudinaryService.class.getName());

    public static final String CLOUD_NAME = "aaowu8ou";
    public static final String API_KEY = "751882945856129";
    public static final String API_SECRET = "yC3mqF-eERizhEw21XkpBiGJxUI";
    public static final String UPLOAD_FOLDER = "headphone_shop/reviews";

    public static class UploadResult {
        private final String secureUrl;
        private final String publicId;

        public UploadResult(String secureUrl, String publicId) {
            this.secureUrl = secureUrl;
            this.publicId = publicId;
        }

        public String getSecureUrl() {
            return secureUrl;
        }

        public String getPublicId() {
            return publicId;
        }

        @Override
        public String toString() {
            return "UploadResult{" +
                    "secureUrl='" + secureUrl + '\'' +
                    ", publicId='" + publicId + '\'' +
                    '}';
        }
    }

    /**
     * Upload an image to Cloudinary.
     *
     * @param fileBytes Binary content of the image.
     * @param fileName Original file name or extension.
     * @return UploadResult containing secure_url and public_id, or null on failure.
     */
    public static UploadResult upload(byte[] fileBytes, String fileName) {
        if (fileBytes == null || fileBytes.length == 0) {
            return null;
        }

        String safeFileName = (fileName != null && !fileName.trim().isEmpty()) ? fileName.trim() : "review_image.jpg";
        long timestamp = System.currentTimeMillis() / 1000L;

        // Signature format: sorted string parameters + api_secret
        String toSign = "folder=" + UPLOAD_FOLDER + "&timestamp=" + timestamp + API_SECRET;
        String signature = sha1Hex(toSign);

        String uploadUrl = "https://api.cloudinary.com/v1_1/" + CLOUD_NAME + "/image/upload";
        String boundary = "----CloudinaryBoundary" + System.currentTimeMillis();

        try {
            URL url = new URL(uploadUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setDoOutput(true);
            conn.setDoInput(true);
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(30000);
            conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

            try (OutputStream os = conn.getOutputStream()) {
                // Add text fields
                writeFormField(os, boundary, "api_key", API_KEY);
                writeFormField(os, boundary, "timestamp", String.valueOf(timestamp));
                writeFormField(os, boundary, "folder", UPLOAD_FOLDER);
                writeFormField(os, boundary, "signature", signature);

                // Add file field
                writeFileField(os, boundary, "file", safeFileName, fileBytes);

                // End boundary
                os.write(("\r\n--" + boundary + "--\r\n").getBytes(StandardCharsets.UTF_8));
                os.flush();
            }

            int responseCode = conn.getResponseCode();
            InputStream is = (responseCode >= 200 && responseCode < 300) ? conn.getInputStream() : conn.getErrorStream();
            String responseBody = readStreamToString(is);

            if (responseCode >= 200 && responseCode < 300) {
                String secureUrl = extractJsonField(responseBody, "secure_url");
                if (secureUrl == null || secureUrl.isEmpty()) {
                    secureUrl = extractJsonField(responseBody, "url");
                }
                String publicId = extractJsonField(responseBody, "public_id");

                if (secureUrl != null && !secureUrl.isEmpty()) {
                    // Unescape JSON slashes if present
                    secureUrl = secureUrl.replace("\\/", "/");
                    return new UploadResult(secureUrl, publicId);
                }
            } else {
                LOGGER.severe("Cloudinary upload failed (HTTP " + responseCode + "): " + responseBody);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Exception during Cloudinary upload", e);
        }

        return null;
    }

    /**
     * Delete an image from Cloudinary using its public_id.
     *
     * @param publicId Cloudinary public ID.
     * @return true if deleted or handled, false on network/auth error.
     */
    public static boolean destroy(String publicId) {
        if (publicId == null || publicId.trim().isEmpty()) {
            return false;
        }

        try {
            long timestamp = System.currentTimeMillis() / 1000L;
            String toSign = "public_id=" + publicId.trim() + "&timestamp=" + timestamp + API_SECRET;
            String signature = sha1Hex(toSign);

            String destroyUrl = "https://api.cloudinary.com/v1_1/" + CLOUD_NAME + "/image/destroy";
            URL url = new URL(destroyUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setDoOutput(true);
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(15000);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            String postData = "public_id=" + java.net.URLEncoder.encode(publicId.trim(), StandardCharsets.UTF_8.name())
                    + "&timestamp=" + timestamp
                    + "&api_key=" + API_KEY
                    + "&signature=" + signature;

            try (OutputStream os = conn.getOutputStream()) {
                os.write(postData.getBytes(StandardCharsets.UTF_8));
                os.flush();
            }

            int responseCode = conn.getResponseCode();
            return (responseCode >= 200 && responseCode < 300);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to delete image from Cloudinary: " + publicId, e);
            return false;
        }
    }

    private static void writeFormField(OutputStream os, String boundary, String name, String value) throws Exception {
        os.write(("--" + boundary + "\r\n").getBytes(StandardCharsets.UTF_8));
        os.write(("Content-Disposition: form-data; name=\"" + name + "\"\r\n\r\n").getBytes(StandardCharsets.UTF_8));
        os.write((value + "\r\n").getBytes(StandardCharsets.UTF_8));
    }

    private static void writeFileField(OutputStream os, String boundary, String fieldName, String fileName, byte[] data) throws Exception {
        os.write(("--" + boundary + "\r\n").getBytes(StandardCharsets.UTF_8));
        os.write(("Content-Disposition: form-data; name=\"" + fieldName + "\"; filename=\"" + fileName + "\"\r\n").getBytes(StandardCharsets.UTF_8));
        os.write(("Content-Type: application/octet-stream\r\n\r\n").getBytes(StandardCharsets.UTF_8));
        os.write(data);
    }

    private static String sha1Hex(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-1");
            byte[] digest = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("SHA-1 algorithm not available", e);
        }
    }

    private static String readStreamToString(InputStream is) throws Exception {
        if (is == null) return "";
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buf = new byte[4096];
        int n;
        while ((n = is.read(buf)) != -1) {
            baos.write(buf, 0, n);
        }
        return baos.toString(StandardCharsets.UTF_8.name());
    }

    private static String extractJsonField(String json, String fieldName) {
        if (json == null) return null;
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(fieldName) + "\"\\s*:\\s*\"([^\"]+)\"");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }
}
