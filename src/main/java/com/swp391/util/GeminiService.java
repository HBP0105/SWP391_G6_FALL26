package com.swp391.util;

import com.swp391.model.AIRecommendationItem;
import com.swp391.model.Product;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Service to interact with Google Gemini AI for smart product recommendations.
 * Pure Java implementation (No external SDK required).
 */
public class GeminiService {

    private static final Logger LOGGER = Logger.getLogger(GeminiService.class.getName());

    public static final String API_KEY = "AQ.Ab8RN6LTaTSlWj9f9kDntDlyJVj7W80JCJGa_LxNzKllLl2B3w";
    public static final String[] CANDIDATE_MODELS = {"gemini-3.5-flash", "gemini-3.5-flash-lite", "gemini-3.1-flash-lite"};
    private static final int TIMEOUT_MS = 3500;

    /**
     * Recommend products for a user based on purchase history and wishlist.
     *
     * @param customerId Customer ID (or 0 if guest)
     * @param purchased List of purchased products
     * @param wishlist List of wishlist products
     * @param catalog Full product catalog to choose from
     * @param limit Number of recommendations (default 8)
     * @return List of AIRecommendationItem
     */
    public static List<AIRecommendationItem> recommendForUser(int customerId,
                                                              List<Product> purchased,
                                                              List<Product> wishlist,
                                                              List<Product> catalog,
                                                              int limit) {
        if (catalog == null || catalog.isEmpty()) {
            return Collections.emptyList();
        }

        Set<Integer> excludedIds = new HashSet<>();
        if (purchased != null) {
            for (Product p : purchased) {
                if (p != null) excludedIds.add(p.getProductId());
            }
        }

        // Build prompt
        StringBuilder prompt = new StringBuilder();
        prompt.append("You are an expert audio AI consultant recommending headphones and earbuds for our store.\n");

        if (purchased != null && !purchased.isEmpty()) {
            prompt.append("Customer previously purchased:\n");
            for (Product p : purchased) {
                prompt.append(String.format("- %s (Brand: %s, Cat: %s, ANC: %s, Conn: %s)\n",
                        p.getProductName(), p.getBrandName(), p.getCategoryName(),
                        p.isNoiseCancelling() ? "Yes" : "No", p.getConnectionType()));
            }
        }

        if (wishlist != null && !wishlist.isEmpty()) {
            prompt.append("Customer wishlist / saved items:\n");
            for (Product p : wishlist) {
                prompt.append(String.format("- %s (Brand: %s, Price: %.0f VND)\n",
                        p.getProductName(), p.getBrandName(), (p.getPrice() != null ? p.getPrice().doubleValue() : 0.0)));
            }
        }

        if ((purchased == null || purchased.isEmpty()) && (wishlist == null || wishlist.isEmpty())) {
            prompt.append("New visitor with no history. Select popular trending headphones with diverse features.\n");
        }

        prompt.append("\nSelect exactly ").append(limit).append(" distinct recommended products from the Catalog below.\n");
        prompt.append("Do NOT recommend products already purchased by this user.\n");
        prompt.append("Catalog available:\n");

        for (Product p : catalog) {
            if (!excludedIds.contains(p.getProductId())) {
                prompt.append(String.format("[%d] %s | Brand: %s | Cat: %s | Price: %.0f | ANC: %s | Conn: %s\n",
                        p.getProductId(), p.getProductName(), p.getBrandName(), p.getCategoryName(),
                        (p.getPrice() != null ? p.getPrice().doubleValue() : 0.0), p.isNoiseCancelling() ? "ANC" : "Standard", p.getConnectionType()));
            }
        }

        prompt.append("\nOutput ONLY valid JSON in format:\n");
        prompt.append("{\n  \"recommendations\": [\n    {\"productId\": 1, \"reason\": \"Matched your preference for Sony ANC with comfortable lightweight design.\"}\n  ]\n}\n");

        List<AIRecommendationItem> result = callGeminiForRecommendations(prompt.toString(), limit);

        // Fallback if AI call failed or returned empty
        if (result == null || result.isEmpty()) {
            result = fallbackUserRecommendations(purchased, wishlist, catalog, excludedIds, limit);
        }

        return result;
    }

    /**
     * Recommend similar products for Product Detail page.
     *
     * @param currentProduct Product currently being viewed
     * @param catalog Full catalog
     * @param limit Number of similar products (e.g. 4-6)
     * @return List of AIRecommendationItem
     */
    public static List<AIRecommendationItem> recommendSimilarProducts(Product currentProduct,
                                                                      List<Product> catalog,
                                                                      int limit) {
        if (currentProduct == null || catalog == null || catalog.isEmpty()) {
            return Collections.emptyList();
        }

        StringBuilder prompt = new StringBuilder();
        prompt.append("You are an audio engineer recommending similar headphones/earbuds for a customer viewing:\n");
        prompt.append(String.format("Current Item: %s (Brand: %s, Category: %s, Price: %.0f VND, ANC: %s, Connection: %s, Driver: %.1fmm)\n",
                currentProduct.getProductName(), currentProduct.getBrandName(), currentProduct.getCategoryName(),
                currentProduct.getPrice(), currentProduct.isNoiseCancelling() ? "Yes" : "No",
                currentProduct.getConnectionType(), currentProduct.getDriverSize()));

        prompt.append("\nSelect ").append(limit).append(" closest matching products from this catalog with similar sound signature, form factor, or competitive price:\n");

        for (Product p : catalog) {
            if (p.getProductId() != currentProduct.getProductId()) {
                prompt.append(String.format("[%d] %s | Brand: %s | Cat: %s | Price: %.0f | ANC: %s | Conn: %s\n",
                        p.getProductId(), p.getProductName(), p.getBrandName(), p.getCategoryName(),
                        (p.getPrice() != null ? p.getPrice().doubleValue() : 0.0), p.isNoiseCancelling() ? "ANC" : "Standard", p.getConnectionType()));
            }
        }

        prompt.append("\nOutput ONLY valid JSON in format:\n");
        prompt.append("{\n  \"recommendations\": [\n    {\"productId\": 2, \"reason\": \"Alternative ANC model with comparable driver size and warm bass signature.\"}\n  ]\n}\n");

        List<AIRecommendationItem> result = callGeminiForRecommendations(prompt.toString(), limit);

        if (result == null || result.isEmpty()) {
            result = fallbackSimilarProducts(currentProduct, catalog, limit);
        }

        return result;
    }

    private static List<AIRecommendationItem> callGeminiForRecommendations(String promptText, int expectedCount) {
        for (String model : CANDIDATE_MODELS) {
            try {
                String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent";
                URL url = new URL(endpoint);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setConnectTimeout(TIMEOUT_MS);
                conn.setReadTimeout(TIMEOUT_MS);
                conn.setDoOutput(true);
                conn.setRequestProperty("Content-Type", "application/json");
                conn.setRequestProperty("x-goog-api-key", API_KEY);

                String requestBody = "{\n"
                        + "  \"contents\": [\n"
                        + "    {\n"
                        + "      \"parts\": [\n"
                        + "        {\n"
                        + "          \"text\": " + escapeJson(promptText) + "\n"
                        + "        }\n"
                        + "      ]\n"
                        + "    }\n"
                        + "  ],\n"
                        + "  \"generationConfig\": {\n"
                        + "    \"responseMimeType\": \"application/json\"\n"
                        + "  }\n"
                        + "}";

                try (OutputStream os = conn.getOutputStream()) {
                    os.write(requestBody.getBytes(StandardCharsets.UTF_8));
                    os.flush();
                }

                int code = conn.getResponseCode();
                if (code >= 200 && code < 300) {
                    String responseBody = readStreamToString(conn.getInputStream());
                    String jsonText = extractCandidateText(responseBody);
                    if (jsonText != null && !jsonText.isEmpty()) {
                        List<AIRecommendationItem> parsed = parseRecommendationsJson(jsonText);
                        if (!parsed.isEmpty()) {
                            return parsed;
                        }
                    }
                } else {
                    String err = readStreamToString(conn.getErrorStream());
                    LOGGER.info("Gemini model " + model + " returned " + code + ", trying next candidate if available.");
                }
            } catch (Exception e) {
                LOGGER.info("Gemini model " + model + " attempt failed (" + e.getMessage() + "), trying fallback.");
            }
        }
        return Collections.emptyList();
    }

    private static String extractCandidateText(String apiResponseJson) {
        if (apiResponseJson == null) return null;
        // Find text property inside candidates
        Pattern p = Pattern.compile("\"text\"\\s*:\\s*\"([\\s\\S]*?)\"\\s*\\}\\s*\\]\\s*\\}\\s*\\]");
        Matcher m = p.matcher(apiResponseJson);
        if (m.find()) {
            String raw = m.group(1);
            return unescapeJson(raw);
        }
        return null;
    }

    private static List<AIRecommendationItem> parseRecommendationsJson(String json) {
        List<AIRecommendationItem> list = new ArrayList<>();
        if (json == null) return list;

        Pattern p = Pattern.compile("\\{\\s*\"productId\"\\s*:\\s*(\\d+)\\s*,\\s*\"reason\"\\s*:\\s*\"([^\"]+)\"\\s*\\}");
        Matcher m = p.matcher(json);
        Set<Integer> added = new HashSet<>();

        while (m.find()) {
            try {
                int pid = Integer.parseInt(m.group(1));
                String reason = m.group(2);
                if (added.add(pid)) {
                    list.add(new AIRecommendationItem(pid, reason));
                }
            } catch (Exception ignored) {
            }
        }
        return list;
    }

    /**
     * Smart heuristic fallback for user recommendations.
     */
    private static List<AIRecommendationItem> fallbackUserRecommendations(List<Product> purchased,
                                                                          List<Product> wishlist,
                                                                          List<Product> catalog,
                                                                          Set<Integer> excluded,
                                                                          int limit) {
        List<AIRecommendationItem> list = new ArrayList<>();
        Set<Integer> added = new HashSet<>(excluded);

        // 1. From wishlist (if not bought yet)
        if (wishlist != null) {
            for (Product p : wishlist) {
                if (p != null && added.add(p.getProductId())) {
                    list.add(new AIRecommendationItem(p.getProductId(), "From your wishlist. High interest audio match."));
                    if (list.size() >= limit) return list;
                }
            }
        }

        // 2. Matching favorite brand/category from purchased
        Set<Integer> preferredBrands = new HashSet<>();
        if (purchased != null) {
            for (Product p : purchased) {
                if (p != null) preferredBrands.add(p.getBrandId());
            }
        }

        for (Product p : catalog) {
            if (p != null && preferredBrands.contains(p.getBrandId()) && added.add(p.getProductId())) {
                list.add(new AIRecommendationItem(p.getProductId(), "Recommended based on your preferred brand " + p.getBrandName() + "."));
                if (list.size() >= limit) return list;
            }
        }

        // 3. Fill up with top products
        for (Product p : catalog) {
            if (p != null && added.add(p.getProductId())) {
                String reason = p.isNoiseCancelling() ? "High-performance active noise cancelling audio gear." : "Popular balanced studio sound profile.";
                list.add(new AIRecommendationItem(p.getProductId(), reason));
                if (list.size() >= limit) break;
            }
        }

        return list;
    }

    /**
     * Smart heuristic fallback for similar products.
     */
    private static List<AIRecommendationItem> fallbackSimilarProducts(Product current, List<Product> catalog, int limit) {
        List<AIRecommendationItem> list = new ArrayList<>();
        Set<Integer> added = new HashSet<>();
        added.add(current.getProductId());

        // Same category and ANC
        for (Product p : catalog) {
            if (p != null && p.getCategoryId() == current.getCategoryId()
                    && p.isNoiseCancelling() == current.isNoiseCancelling()
                    && added.add(p.getProductId())) {
                String reason = "Similar " + p.getCategoryName() + " with matching " + (p.isNoiseCancelling() ? "ANC technology" : "acoustic profile") + ".";
                list.add(new AIRecommendationItem(p.getProductId(), reason));
                if (list.size() >= limit) return list;
            }
        }

        // Same brand
        for (Product p : catalog) {
            if (p != null && p.getBrandId() == current.getBrandId() && added.add(p.getProductId())) {
                list.add(new AIRecommendationItem(p.getProductId(), "Companion audio product from " + p.getBrandName() + "."));
                if (list.size() >= limit) return list;
            }
        }

        // Fill remaining
        for (Product p : catalog) {
            if (p != null && added.add(p.getProductId())) {
                list.add(new AIRecommendationItem(p.getProductId(), "Comparable audio quality in the same price range."));
                if (list.size() >= limit) break;
            }
        }

        return list;
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

    private static String escapeJson(String s) {
        if (s == null) return "\"\"";
        StringBuilder sb = new StringBuilder("\"");
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '\\': sb.append("\\\\"); break;
                case '"': sb.append("\\\""); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < ' ') {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
                    break;
            }
        }
        sb.append("\"");
        return sb.toString();
    }

    private static String unescapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\\"", "\"")
                .replace("\\n", "\n")
                .replace("\\r", "\r")
                .replace("\\t", "\t")
                .replace("\\\\", "\\");
    }
}
