package com.swp391.util;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Google Gemini AI Client supporting both Google AI Studio keys (AIzaSy...)
 * and Vertex AI Express Mode keys (AQ....) with automatic fail-safe fallback.
 */
public class GeminiClient {

    private static final Logger LOGGER = Logger.getLogger(GeminiClient.class.getName());

    // Configured Gemini API Key (can be updated via environment variable GEMINI_API_KEY or setApiKey)
    private static volatile String apiKey = System.getenv("GEMINI_API_KEY") != null
            ? System.getenv("GEMINI_API_KEY").trim()
            : "AQ.Ab8RN6LTaTSlWj9f9kDntDlyJVj7W80JCJGa_LxNzKllLl2B3w";

    private static volatile String modelName = "gemini-2.5-flash";
    private static volatile String lastStatusMessage = "READY";

    private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(6))
            .build();

    public static String getApiKey() {
        return apiKey;
    }

    public static void setApiKey(String newKey) {
        if (newKey != null && !newKey.trim().isEmpty()) {
            apiKey = newKey.trim();
            lastStatusMessage = "UPDATED";
        }
    }

    public static String getModelName() {
        return modelName;
    }

    public static String getLastStatusMessage() {
        return lastStatusMessage;
    }

    /**
     * Calls Gemini generateContent endpoint (supports both Vertex AI Express AQ. keys and AI Studio AIzaSy keys).
     * Returns raw text response from Gemini, or null if key is unauthorized / network error.
     */
    public static String generateText(String prompt) {
        if (apiKey == null || apiKey.isEmpty()) {
            lastStatusMessage = "NO_API_KEY";
            return null;
        }

        String payload = "{\"contents\":[{\"role\":\"user\",\"parts\":[{\"text\":\""
                + escapeJson(prompt)
                + "\"}]}],\"generationConfig\":{\"temperature\":0.3,\"maxOutputTokens\":600}}";

        List<String> urls = new ArrayList<>();
        if (apiKey.startsWith("AQ.")) {
            urls.add("https://aiplatform.googleapis.com/v1/publishers/google/models/" + modelName + ":generateContent?key=" + apiKey);
            urls.add("https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":generateContent");
        } else {
            urls.add("https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":generateContent?key=" + apiKey);
        }

        for (String url : urls) {
            try {
                HttpRequest.Builder reqBuilder = HttpRequest.newBuilder()
                        .uri(URI.create(url))
                        .timeout(Duration.ofSeconds(8))
                        .header("Content-Type", "application/json; charset=UTF-8")
                        .header("x-goog-api-key", apiKey)
                        .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8));

                HttpResponse<String> resp = HTTP_CLIENT.send(reqBuilder.build(), HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
                if (resp.statusCode() == 200) {
                    String text = extractTextFromGeminiJson(resp.body());
                    if (text != null && !text.isEmpty()) {
                        lastStatusMessage = "CONNECTED (HTTP 200)";
                        return text;
                    }
                } else {
                    lastStatusMessage = "HTTP_" + resp.statusCode();
                }
            } catch (Exception e) {
                lastStatusMessage = "ERROR: " + e.getMessage();
                LOGGER.log(Level.FINE, "Gemini API call fallback triggered: " + e.getMessage());
            }
        }
        return null;
    }

    /**
     * Calls Gemini Embedding API (text-embedding-004 with outputDimensionality=512) to produce a 512-D vector.
     * Returns null if API key is unauthorized or offline so caller can fall back to local 512-D hash vector.
     */
    public static double[] generateEmbedding512(String text) {
        if (apiKey == null || apiKey.isEmpty() || text == null || text.isEmpty()) {
            return null;
        }

        String url = "https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key=" + apiKey;
        String payload = "{\"model\":\"models/text-embedding-004\","
                + "\"content\":{\"parts\":[{\"text\":\"" + escapeJson(text) + "\"}]},"
                + "\"outputDimensionality\":512}";

        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(6))
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .header("x-goog-api-key", apiKey)
                    .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> resp = HTTP_CLIENT.send(req, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (resp.statusCode() == 200 && resp.body() != null) {
                Matcher m = Pattern.compile("\"values\"\\s*:\\s*\\[([^\\]]+)\\]").matcher(resp.body());
                if (m.find()) {
                    String[] parts = m.group(1).split(",");
                    if (parts.length == 512) {
                        double[] vec = new double[512];
                        double normSq = 0.0;
                        for (int i = 0; i < 512; i++) {
                            vec[i] = Double.parseDouble(parts[i].trim());
                            normSq += vec[i] * vec[i];
                        }
                        double norm = Math.sqrt(normSq);
                        if (norm > 0) {
                            for (int i = 0; i < 512; i++) {
                                vec[i] = Math.round((vec[i] / norm) * 1000000.0) / 1000000.0;
                            }
                        }
                        lastStatusMessage = "CONNECTED (EMBEDDING 512-D)";
                        return vec;
                    }
                }
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    /**
     * Uses Gemini AI to answer a user's shopping query and pick the best matching product IDs from the catalog.
     * Returns Map with "reply" (String) and "productIds" (List<Integer>), or null if Gemini is unreachable.
     */
    public static Map<String, Object> askShoppingAssistantWithGemini(String userQuery, List<Map<String, Object>> catalog) {
        if (catalog == null || catalog.isEmpty()) return null;

        StringBuilder prompt = new StringBuilder();
        prompt.append("You are the dedicated English AI Audio Shopping Assistant for Electro Headphone Store.\n");
        prompt.append("SCOPE RULE: You ONLY provide product purchasing advice, recommendations, and technical comparisons for headphones, earbuds, and audio accessories in our catalog.\n");
        prompt.append("STRICT REJECTION POLICY: If the customer message is greeting, small talk, social conversation (e.g., 'hello', 'how are you', 'what's up'), off-topic, unrelated to buying audio products (e.g., weather, food, math, news, coding), gibberish, keyboard mash, or meaningless characters (e.g., 'asdfgh', '123456', '???'):\n");
        prompt.append("You MUST NOT answer or entertain the topic, and MUST NOT recommend any products.\n");
        prompt.append("Instead, you must reply: 'I am an AI shopping assistant dedicated to audio products. I cannot answer social, off-topic, or non-shopping inquiries. Please ask me about buying headphones, earbuds, or audio gear (e.g., budget, noise cancelling, battery life, brand).' and return IDS: NONE.\n\n");
        prompt.append("Below is our active product catalog:\n");
        for (Map<String, Object> p : catalog) {
            prompt.append(String.format("- ID=%s | Name=%s | Brand=%s | Category=%s | Price=%s VND | ANC=%s | Battery=%sh | Conn=%s\n",
                    p.get("productId"),
                    p.get("productName"),
                    p.get("brandName"),
                    p.get("categoryName"),
                    p.get("price"),
                    Boolean.TRUE.equals(p.get("noiseCancelling")) ? "Yes" : "No",
                    p.get("batteryLife"),
                    p.get("connectionType")));
        }
        prompt.append("\nCustomer question: \"").append(userQuery).append("\"\n");
        prompt.append("Respond in this exact 2-line format:\n");
        prompt.append("REPLY: <your English response (either polite out-of-scope refusal OR helpful product advice, max 2 sentences)>\n");
        prompt.append("IDS: <comma-separated up to 4 best matching Product IDs, e.g. 1,3,8 or NONE>\n");

        String raw = generateText(prompt.toString());
        if (raw == null || raw.trim().isEmpty()) {
            return null;
        }

        String replyLine = null;
        List<Integer> matchedIds = new ArrayList<>();
        for (String line : raw.split("\\r?\\n")) {
            String trimmed = line.trim();
            if (trimmed.toUpperCase().startsWith("REPLY:")) {
                replyLine = trimmed.substring(6).trim();
            } else if (trimmed.toUpperCase().startsWith("IDS:")) {
                String idsPart = trimmed.substring(4).trim();
                if (!idsPart.equalsIgnoreCase("NONE") && !idsPart.contains("NONE")) {
                    Matcher m = Pattern.compile("\\d+").matcher(idsPart);
                    while (m.find() && matchedIds.size() < 4) {
                        try {
                            matchedIds.add(Integer.parseInt(m.group()));
                        } catch (NumberFormatException ignored) {
                        }
                    }
                }
            }
        }

        if (replyLine == null || replyLine.isEmpty()) {
            replyLine = raw.replaceAll("(?i)IDS:.*", "").trim();
        }

        Map<String, Object> res = new HashMap<>();
        res.put("reply", replyLine);
        res.put("productIds", matchedIds);
        return res;
    }

    private static String extractTextFromGeminiJson(String json) {
        if (json == null) return null;
        Matcher m = Pattern.compile("\"text\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"").matcher(json);
        if (m.find()) {
            String raw = m.group(1);
            return raw.replace("\\n", "\n")
                      .replace("\\r", "\r")
                      .replace("\\t", "\t")
                      .replace("\\\"", "\"")
                      .replace("\\\\", "\\");
        }
        return null;
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}

