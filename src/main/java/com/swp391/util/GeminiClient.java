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
     * Calls Gemini generateContent endpoint with Multimodal Image input (Base64 inline_data).
     */
    public static String generateTextWithImage(String prompt, String mimeType, String base64Image) {
        List<String> mimes = mimeType != null ? List.of(mimeType) : List.of("image/jpeg");
        List<String> imgs = base64Image != null ? List.of(base64Image) : List.of();
        return generateTextWithMultipleImages(prompt, mimes, imgs);
    }

    /**
     * Calls Gemini generateContent endpoint with up to 4 Multimodal Images (Base64 inline_data).
     */
    public static String generateTextWithMultipleImages(String prompt, List<String> mimeTypes, List<String> base64Images) {
        if (apiKey == null || apiKey.isEmpty() || base64Images == null || base64Images.isEmpty()) {
            return generateText(prompt);
        }

        StringBuilder partsBuilder = new StringBuilder();
        partsBuilder.append("{\"text\":\"").append(escapeJson(prompt)).append("\"}");

        int count = Math.min(4, base64Images.size());
        for (int i = 0; i < count; i++) {
            String b64 = base64Images.get(i);
            if (b64 == null || b64.trim().isEmpty()) continue;

            String safeMime = (mimeTypes != null && i < mimeTypes.size() && mimeTypes.get(i) != null && !mimeTypes.get(i).trim().isEmpty())
                    ? mimeTypes.get(i).trim() : "image/jpeg";
            String cleanBase64 = b64;
            if (cleanBase64.contains(",")) {
                cleanBase64 = cleanBase64.substring(cleanBase64.indexOf(",") + 1);
            }
            cleanBase64 = cleanBase64.replaceAll("\\s+", "");

            partsBuilder.append(",{\"inline_data\":{\"mime_type\":\"")
                    .append(escapeJson(safeMime)).append("\",\"data\":\"")
                    .append(cleanBase64).append("\"}}");
        }

        String payload = "{\"contents\":[{\"role\":\"user\",\"parts\":["
                + partsBuilder.toString()
                + "]}],\"generationConfig\":{\"temperature\":0.2,\"maxOutputTokens\":800}}";

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
                        .timeout(Duration.ofSeconds(12))
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
                LOGGER.log(Level.FINE, "Gemini Vision API call fallback triggered: " + e.getMessage());
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
        prompt.append("You are the expert AI Audio Shopping Assistant for Electro Headphone Store.\n");
        prompt.append("SCOPE & REJECTION POLICY:\n");
        prompt.append("- You ONLY assist with audio product purchasing, technical advice, specs comparison, and recommendations.\n");
        prompt.append("- If the customer message is greeting/social chit-chat, off-topic, gibberish, or unrelated to audio equipment, reply with standard polite refusal and return IDS: NONE.\n\n");
        prompt.append("CRITICAL RECOMMENDATION & CONSTRAINT MATCHING RULES:\n");
        prompt.append("1. Multi-language understanding: Parse user intent accurately from any language (English, Vietnamese, etc.).\n");
        prompt.append("2. Price constraint: If the user requests a budget or price cap (e.g., 'under 3 million', 'duoi 3tr', '< 3000000 VND'), ONLY recommend products with Price <= limit. NEVER recommend products exceeding the user's budget.\n");
        prompt.append("3. Water resistance constraint: If the user asks for water resistance, waterproof, sweat resistance, workout, gym, or running (e.g., 'chống nước', 'kháng nước', 'water resistance', 'IPX'), ONLY recommend products that have WaterResistance != 'None' (e.g., IPX4, IPX5). Do NOT recommend products with WaterResistance='None'.\n");
        prompt.append("4. Category & Style constraint: Respect user preference for Over-ear Headphones vs In-ear / TWS Earbuds.\n");
        prompt.append("5. Battery life constraint: If the user specifies battery life duration or range (e.g., 'over 40 hours', 'between 10 and 20 hours', 'pin trên 40h', 'từ 10 đến 20 giờ'), ONLY recommend products whose Battery specification strictly satisfies that condition. NEVER recommend products outside the requested battery range.\n");
        prompt.append("6. Weight / Lightweight constraint: If the user requests 'light' or 'lightweight' headphones (e.g., 'lightweight', 'nhẹ'), ONLY recommend models with Weight <= 250g. NEVER recommend models heavier than 250g (such as Sennheiser Momentum 4 293g, AirPods Max 385g, or JBL Quantum 810 418g).\n");
        prompt.append("7. HONESTY & UNSATISFIED / IMPOSSIBLE CRITERIA POLICY:\n");
        prompt.append("   - If the user asks for a combination of criteria that NO product in our catalog meets (e.g., 'waterproof headphones' when all our over-ear headphones have WaterResistance=None, or a budget below our cheapest item, or battery higher than our longest-lasting model):\n");
        prompt.append("     a) You MUST be 100% honest and transparent in the REPLY. Explicitly declare what is unavailable (e.g., 'Currently, our catalog does not have over-ear headphones with water resistance, as all our water-resistant models are in-ear earbuds.').\n");
        prompt.append("     b) You may propose alternative options (e.g., water-resistant earbuds, or top over-ear headphones without waterproofing), but you MUST explicitly state the compromise in the REPLY.\n");
        prompt.append("     c) NEVER claim or hallucinate that a product has water resistance, low price, or features that it lacks.\n\n");

        prompt.append("Complete Store Product Catalog (ALL active specifications):\n");
        for (Map<String, Object> p : catalog) {
            String desc = (String) p.getOrDefault("description", "");
            if (desc.length() > 120) desc = desc.substring(0, 120) + "...";
            prompt.append(String.format("- ID=%s | Name=%s | Brand=%s | Category=%s | Price=%s VND | WaterResistance=%s | ANC=%s | Battery=%sh | Mic=%s | Driver=%smm | Weight=%sg | Conn=%s | Stock=%s | Desc: %s\n",
                    p.get("productId"),
                    p.get("productName"),
                    p.get("brandName"),
                    p.get("categoryName"),
                    p.get("price"),
                    p.getOrDefault("waterResistance", "None"),
                    Boolean.TRUE.equals(p.get("noiseCancelling")) ? "Yes" : "No",
                    p.getOrDefault("batteryLife", "N/A"),
                    Boolean.TRUE.equals(p.get("microphone")) ? "Yes" : "No",
                    p.getOrDefault("driverSize", "N/A"),
                    p.getOrDefault("weight", "N/A"),
                    p.getOrDefault("connectionType", "Wireless"),
                    p.getOrDefault("stockQuantity", "10"),
                    desc));
        }
        prompt.append("\nCustomer question: \"").append(userQuery).append("\"\n");
        prompt.append("Respond in this exact 2-line format:\n");
        prompt.append("REPLY: <helpful shopping advice in 1-2 sentences matching user language, explaining why these models fit their price/features>\n");
        prompt.append("IDS: <comma-separated up to 4 best matching Product IDs, e.g. 2,14,15 or NONE>\n");

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

    /**
     * Multimodal Image Search with Gemini (Single image backward compatibility).
     */
    public static Map<String, Object> askShoppingAssistantWithImage(
            String userNote, String mimeType, String base64Image, List<Map<String, Object>> catalog) {
        List<String> mimes = mimeType != null ? List.of(mimeType) : List.of("image/jpeg");
        List<String> imgs = base64Image != null ? List.of(base64Image) : List.of();
        return askShoppingAssistantWithImages(userNote, mimes, imgs, catalog);
    }

    /**
     * Multimodal Image Search with Gemini (Supports up to 4 images):
     * Analyzes headphone photo(s) and matches with catalog products.
     */
    public static Map<String, Object> askShoppingAssistantWithImages(
            String userNote, List<String> mimeTypes, List<String> base64Images, List<Map<String, Object>> catalog) {
        if (catalog == null || catalog.isEmpty() || base64Images == null || base64Images.isEmpty()) {
            return null;
        }

        int imgCount = Math.min(4, base64Images.size());
        StringBuilder prompt = new StringBuilder();
        prompt.append("You are an expert AI headphone shopping assistant and visual search engine for an audio store.\n");
        prompt.append("The customer uploaded ").append(imgCount).append(" photo(s) of a headphone, earbud, or audio gear, with optional note: \"")
              .append(userNote != null ? userNote.trim() : "").append("\"\n\n");
        prompt.append("Below is our active store product catalog:\n");
        for (Map<String, Object> p : catalog) {
            prompt.append(String.format("- ID=%s | Name=%s | Brand=%s | Category=%s | Price=%s VND | WaterResistance=%s | ANC=%s | Battery=%sh | Mic=%s | Driver=%smm | Conn=%s\n",
                    p.get("productId"),
                    p.get("productName"),
                    p.get("brandName"),
                    p.get("categoryName"),
                    p.get("price"),
                    p.getOrDefault("waterResistance", "None"),
                    Boolean.TRUE.equals(p.get("noiseCancelling")) ? "Yes" : "No",
                    p.getOrDefault("batteryLife", "N/A"),
                    Boolean.TRUE.equals(p.get("microphone")) ? "Yes" : "No",
                    p.getOrDefault("driverSize", "N/A"),
                    p.getOrDefault("connectionType", "Wireless")));
        }
        prompt.append("\nTasks:\n");
        prompt.append("1. Analyze the uploaded image(s): identify the form factor (Over-ear headphone, In-ear TWS earbud, On-ear), color, visible brand styling, and key visual attributes.\n");
        prompt.append("2. Find the best matching or most visually similar products from our store catalog above.\n");
        prompt.append("3. Respond strictly in this format:\n");
        prompt.append("ANALYSIS: <1-2 sentences in English summarizing what type of headphone is in the image(s), color, design, and style>\n");
        prompt.append("REPLY: <1-2 sentences in English giving shopping advice or explaining why the matched products resemble the photo(s)>\n");
        prompt.append("IDS: <comma-separated up to 6 best matching Product IDs from catalog, e.g. 1, 3, 5, or NONE>\n");

        String raw = generateTextWithMultipleImages(prompt.toString(), mimeTypes, base64Images);
        if (raw == null || raw.trim().isEmpty()) {
            return null;
        }

        String analysisLine = null;
        String replyLine = null;
        List<Integer> matchedIds = new ArrayList<>();
        for (String line : raw.split("\\r?\\n")) {
            String trimmed = line.trim();
            if (trimmed.toUpperCase().startsWith("ANALYSIS:")) {
                analysisLine = trimmed.substring(9).trim();
            } else if (trimmed.toUpperCase().startsWith("REPLY:")) {
                replyLine = trimmed.substring(6).trim();
            } else if (trimmed.toUpperCase().startsWith("IDS:")) {
                String idsPart = trimmed.substring(4).trim();
                if (!idsPart.equalsIgnoreCase("NONE") && !idsPart.contains("NONE")) {
                    Matcher m = Pattern.compile("\\d+").matcher(idsPart);
                    while (m.find() && matchedIds.size() < 6) {
                        try {
                            matchedIds.add(Integer.parseInt(m.group()));
                        } catch (NumberFormatException ignored) {
                        }
                    }
                }
            }
        }

        if (analysisLine == null || analysisLine.isEmpty()) {
            analysisLine = "AI has recognized the headphone model from your uploaded image(s).";
        }
        if (replyLine == null || replyLine.isEmpty()) {
            replyLine = raw.replaceAll("(?i)(ANALYSIS|IDS):.*", "").trim();
        }

        Map<String, Object> res = new HashMap<>();
        res.put("analysis", analysisLine);
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

