package com.swp391.service.Admin;

import com.swp391.dao.Admin.AIPerformanceDAO;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AIPerformanceService {

    private static final Logger LOGGER = Logger.getLogger(AIPerformanceService.class.getName());

    private final AIPerformanceDAO aiPerformanceDAO;

    private static double similarityWeight = 0.50;
    private static double behaviorWeight = 0.50;
    private static double minSimilarityThreshold = 0.60;
    private static int topKLimit = 10;
    private static String fallbackStrategy = "COLD_START";
    private static String algorithmStatus = "ACTIVE";

    public AIPerformanceService() {
        this.aiPerformanceDAO = new AIPerformanceDAO();
        syncConfigurationFromDatabase();
    }

    public AIPerformanceService(AIPerformanceDAO aiPerformanceDAO) {
        this.aiPerformanceDAO = aiPerformanceDAO;
        syncConfigurationFromDatabase();
    }

    /**
     * Đồng bộ cấu hình AI từ cơ sở dữ liệu (Persistent DB State) vào bộ nhớ ứng dụng.
     */
    public synchronized void syncConfigurationFromDatabase() {
        try {
            Map<String, Object> dbConfig = aiPerformanceDAO.getActiveAIConfiguration();
            if (dbConfig != null && !dbConfig.isEmpty()) {
                if (dbConfig.get("similarityWeight") != null) {
                    similarityWeight = ((Number) dbConfig.get("similarityWeight")).doubleValue();
                }
                if (dbConfig.get("behaviorWeight") != null) {
                    behaviorWeight = ((Number) dbConfig.get("behaviorWeight")).doubleValue();
                }
                if (dbConfig.get("minSimilarityThreshold") != null) {
                    minSimilarityThreshold = ((Number) dbConfig.get("minSimilarityThreshold")).doubleValue();
                }
                if (dbConfig.get("topKLimit") != null) {
                    topKLimit = ((Number) dbConfig.get("topKLimit")).intValue();
                }
                if (dbConfig.get("fallbackStrategy") != null) {
                    fallbackStrategy = (String) dbConfig.get("fallbackStrategy");
                }
                if (dbConfig.get("algorithmStatus") != null) {
                    algorithmStatus = (String) dbConfig.get("algorithmStatus");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Không thể tải cấu hình AI từ database, sử dụng cấu hình mặc định trong bộ nhớ: " + e.getMessage());
        }
    }

    private String formatStartDate(String startDate) {
        if (startDate == null || startDate.trim().isEmpty()) {
            return null;
        }
        return startDate.trim() + " 00:00:00";
    }

    private String formatEndDate(String endDate) {
        if (endDate == null || endDate.trim().isEmpty()) {
            return null;
        }
        try {
            LocalDate endLocalDate = LocalDate.parse(endDate.trim());
            LocalDate nextDay = endLocalDate.plusDays(1);
            return nextDay.toString() + " 00:00:00";
        } catch (Exception e) {
            return endDate.trim() + " 23:59:59";
        }
    }

    public String validateDateRange(String startDate, String endDate) {
        LocalDate today = LocalDate.now();
        if (startDate != null && !startDate.trim().isEmpty()) {
            try {
                LocalDate start = LocalDate.parse(startDate.trim());
                if (start.isAfter(today)) {
                    return "\"From Date\" cannot be in the future!";
                }
            } catch (Exception e) {
                return "Invalid \"From Date\" format!";
            }
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            try {
                LocalDate end = LocalDate.parse(endDate.trim());
                if (end.isAfter(today)) {
                    return "\"To Date\" cannot be in the future!";
                }
            } catch (Exception e) {
                return "Invalid \"To Date\" format!";
            }
        }
        if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
            try {
                LocalDate start = LocalDate.parse(startDate.trim());
                LocalDate end = LocalDate.parse(endDate.trim());
                if (start.isAfter(end)) {
                    return "\"From Date\" cannot be later than \"To Date\"!";
                }
            } catch (Exception e) {
                return "Invalid date range!";
            }
        }
        return null;
    }

    /**
     * Bundles all data needed for Screen 4 (AI Performance & Configuration View).
     */
    public Map<String, Object> getAIPerformanceBundle(String startDate, String endDate, String recommendationType) {
        Map<String, Object> bundle = new HashMap<>();

        String msgError = validateDateRange(startDate, endDate);
        String startForQuery = startDate;
        String endForQuery = endDate;
        if (msgError != null) {
            bundle.put("msgError", msgError);
            startForQuery = "";
            endForQuery = "";
        }

        String formattedStart = formatStartDate(startForQuery);
        String formattedEnd = formatEndDate(endForQuery);

        try {
            // 1. Summary Metrics Map
            Map<String, Object> summary = aiPerformanceDAO.getAIPerformanceSummary(formattedStart, formattedEnd, recommendationType);
            calculatePerformanceSummary(summary);

            // 2. Breakdown by Recommendation Type
            List<Map<String, Object>> byType = aiPerformanceDAO.getPerformanceByType(formattedStart, formattedEnd);
            calculateTypeBreakdownRates(byType);

            // 3. Top Recommended Products (Cố định lấy Top 10 sản phẩm cho báo cáo dashboard)
            List<Map<String, Object>> topProducts = aiPerformanceDAO.getTopRecommendedProducts(formattedStart, formattedEnd, recommendationType, 10);
            calculateTopProductRates(topProducts);

            // 4. Recent Recommendation Logs
            List<Map<String, Object>> recentLogs = aiPerformanceDAO.getRecentRecommendationLogs(formattedStart, formattedEnd, recommendationType, 20);

            // 5. Active AI Model Parameters Map
            Map<String, Object> aiConfig = getAIConfigurationMap();

            bundle.put("summary", summary);
            bundle.put("byType", byType);
            bundle.put("topProducts", topProducts);
            bundle.put("recentLogs", recentLogs);
            bundle.put("aiConfig", aiConfig);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error querying AI performance data from database", e);
            bundle.put("msgError", "Failed to connect or load AI performance data from database. Please verify SQL Server connection!");
            bundle.put("summary", new HashMap<String, Object>());
            bundle.put("byType", new ArrayList<Map<String, Object>>());
            bundle.put("topProducts", new ArrayList<Map<String, Object>>());
            bundle.put("recentLogs", new ArrayList<Map<String, Object>>());
            bundle.put("aiConfig", getAIConfigurationMap());
        }
        bundle.put("selectedStartDate", startDate != null ? startDate : "");
        bundle.put("selectedEndDate", endDate != null ? endDate : "");
        bundle.put("selectedType", recommendationType != null ? recommendationType : "ALL");

        return bundle;
    }

    /**
     * Returns current AI configuration parameters, synced with database.
     */
    public Map<String, Object> getAIConfigurationMap() {
        syncConfigurationFromDatabase();
        Map<String, Object> config = new HashMap<>();
        config.put("similarityWeight", similarityWeight);
        config.put("behaviorWeight", behaviorWeight);
        config.put("minSimilarityThreshold", minSimilarityThreshold);
        config.put("topKLimit", topKLimit);
        config.put("fallbackStrategy", fallbackStrategy);
        config.put("algorithmStatus", algorithmStatus);
        return config;
    }

    /**
     * Updates AI Configuration parameters in database and records AuditLog in a single atomic transaction.
     */
    public String updateAIConfiguration(double newSimWeight, double newBehWeight, double newMinThreshold, 
            int newTopK, String newFallback, Integer adminStaffId) {
        // Validation: Standards [0.0 - 1.0], sum must be 1.0
        if (newSimWeight < 0.0 || newSimWeight > 1.0 || newBehWeight < 0.0 || newBehWeight > 1.0) {
            return "Similarity Weight and Behavior Weight must be numbers between 0.0 and 1.0!";
        }

        double weightSum = newSimWeight + newBehWeight;
        if (Math.abs(weightSum - 1.0) > 0.001) {
            return "The sum of Similarity Weight and Behavior Weight must equal 1.0 (e.g. 0.7 and 0.3)!";
        }

        if (newMinThreshold < 0.0 || newMinThreshold > 1.0) {
            return "Minimum Similarity Threshold must be a number between 0.0 and 1.0!";
        }

        if (newTopK < 1 || newTopK > 50) {
            return "Recommendation limit (Top K) must be between 1 and 50!";
        }

        // Whitelist validation for Fallback Strategy
        String cleanFallback = newFallback != null ? newFallback.trim().toUpperCase(java.util.Locale.ROOT) : "";
        if (!"COLD_START".equals(cleanFallback) && !"BEST_SELLER".equals(cleanFallback)) {
            return "Invalid Fallback Strategy! Allowed values are COLD_START or BEST_SELLER.";
        }

        String oldData = String.format("SimWeight=%.2f, BehWeight=%.2f, MinThreshold=%.2f, TopK=%d, Fallback=%s",
                similarityWeight, behaviorWeight, minSimilarityThreshold, topKLimit, fallbackStrategy);

        String newData = String.format("SimWeight=%.2f, BehWeight=%.2f, MinThreshold=%.2f, TopK=%d, Fallback=%s",
                newSimWeight, newBehWeight, newMinThreshold, newTopK, cleanFallback);

        // Save to AIConfigurations and record AuditLogs in transaction
        boolean success = aiPerformanceDAO.saveAIConfigurationWithTransaction(
                newSimWeight, newBehWeight, newMinThreshold, newTopK, cleanFallback, adminStaffId, oldData, newData);

        if (!success) {
            return "Failed to save configuration and audit log to database. All changes safely rolled back!";
        }

        // CSDL commit thành công 100% -> đồng bộ lại biến trong RAM
        similarityWeight = newSimWeight;
        behaviorWeight = newBehWeight;
        minSimilarityThreshold = newMinThreshold;
        topKLimit = newTopK;
        fallbackStrategy = cleanFallback;

        return null; // Thành công hoàn toàn
    }

    /**
     * Business Calculation: Compute CTR, Conversion Rate, and Click-to-Purchase Rate for Summary.
     */
    private void calculatePerformanceSummary(Map<String, Object> summary) {
        if (summary == null || summary.isEmpty()) return;
        long totalRecs = (long) summary.getOrDefault("totalRecommendations", 0L);
        long totalClicked = (long) summary.getOrDefault("totalClicked", 0L);
        long totalPurchased = (long) summary.getOrDefault("totalPurchased", 0L);

        double avgSim = (double) summary.getOrDefault("avgSimilarityScore", 0.0);
        double avgBeh = (double) summary.getOrDefault("avgBehaviorScore", 0.0);
        double avgFinal = (double) summary.getOrDefault("avgFinalScore", 0.0);

        double ctrRate = totalRecs > 0 ? (totalClicked * 100.0 / totalRecs) : 0.0;
        double conversionRate = totalRecs > 0 ? (totalPurchased * 100.0 / totalRecs) : 0.0;
        double clickToPurchaseRate = totalClicked > 0 ? (totalPurchased * 100.0 / totalClicked) : 0.0;

        summary.put("ctrRate", round(ctrRate, 2));
        summary.put("conversionRate", round(conversionRate, 2));
        summary.put("clickToPurchaseRate", round(clickToPurchaseRate, 2));

        summary.put("avgSimilarityScore", round(avgSim, 4));
        summary.put("avgBehaviorScore", round(avgBeh, 4));
        summary.put("avgFinalScore", round(avgFinal, 4));
    }

    /**
     * Business Calculation: Compute CTR and Conversion Rate for each recommendation type.
     */
    private void calculateTypeBreakdownRates(List<Map<String, Object>> byType) {
        if (byType == null) return;
        for (Map<String, Object> row : byType) {
            long total = (long) row.getOrDefault("totalCount", 0L);
            long clicked = (long) row.getOrDefault("clickedCount", 0L);
            long purchased = (long) row.getOrDefault("purchasedCount", 0L);
            double avgScore = (double) row.getOrDefault("avgScore", 0.0);

            double ctr = total > 0 ? (clicked * 100.0 / total) : 0.0;
            double conv = total > 0 ? (purchased * 100.0 / total) : 0.0;

            row.put("ctrRate", round(ctr, 2));
            row.put("conversionRate", round(conv, 2));
            row.put("avgScore", round(avgScore, 4));
        }
    }

    /**
     * Business Calculation: Compute CTR and Conversion Rate for top recommended products.
     */
    private void calculateTopProductRates(List<Map<String, Object>> topProducts) {
        if (topProducts == null) return;
        for (Map<String, Object> row : topProducts) {
            long total = (long) row.getOrDefault("recommendCount", 0L);
            long clicked = (long) row.getOrDefault("clickedCount", 0L);
            long purchased = (long) row.getOrDefault("purchasedCount", 0L);
            double avgScore = (double) row.getOrDefault("avgFinalScore", 0.0);

            double ctr = total > 0 ? (clicked * 100.0 / total) : 0.0;
            double conv = total > 0 ? (purchased * 100.0 / total) : 0.0;

            row.put("ctrRate", round(ctr, 2));
            row.put("conversionRate", round(conv, 2));
            row.put("avgFinalScore", round(avgScore, 4));
        }
    }

    private double round(double val, int places) {
        if (Double.isNaN(val) || Double.isInfinite(val)) return 0.0;
        return BigDecimal.valueOf(val).setScale(places, RoundingMode.HALF_UP).doubleValue();
    }

    /**
     * Calculates Cosine Similarity between two 512-dimension unit/feature vectors.
     * Formula: Cosine(A, B) = (A . B) / (||A|| * ||B||) -> Normalized in [0.0, 1.0].
     */
    public double calculateCosineSimilarity(double[] vecA, double[] vecB) {
        if (vecA == null || vecB == null || vecA.length == 0 || vecB.length == 0) return 0.0;
        int len = Math.min(vecA.length, vecB.length);
        double dotProduct = 0.0;
        double normA = 0.0;
        double normB = 0.0;
        for (int i = 0; i < len; i++) {
            dotProduct += vecA[i] * vecB[i];
            normA += vecA[i] * vecA[i];
            normB += vecB[i] * vecB[i];
        }
        if (normA == 0.0 || normB == 0.0) return 0.0;
        double sim = dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
        return Math.max(0.0, Math.min(1.0, sim));
    }

    /**
     * Dynamically generates an L2-normalized 512-dimension feature vector from product specifications.
     * Primary: Google Gemini Embedding API (text-embedding-004, 512-D).
     * Fallback: Local L2-normalized 512-D feature hash vector.
     */
    public double[] generateProduct512Vector(Map<String, Object> p) {
        String text = String.format("Product: %s. Brand: %s. Category: %s. Connection: %s. ANC: %s. Battery: %s hrs. WaterResistance: %s. Mic: %s. Price: %s. %s",
                p.getOrDefault("productName", ""),
                p.getOrDefault("brandName", ""),
                p.getOrDefault("categoryName", ""),
                p.getOrDefault("connectionType", ""),
                Boolean.TRUE.equals(p.get("noiseCancelling")) ? "Active Noise Cancelling ANC" : "Standard",
                p.getOrDefault("batteryLife", "30"),
                p.getOrDefault("waterResistance", "None"),
                Boolean.TRUE.equals(p.get("microphone")) ? "Microphone" : "No Mic",
                p.getOrDefault("price", "0"),
                p.getOrDefault("description", ""));

        double[] geminiVec = com.swp391.util.GeminiClient.generateEmbedding512(text);
        if (geminiVec != null && geminiVec.length == 512) {
            return geminiVec;
        }

        double[] vec = new double[512];
        double sumSq = 0.0;
        for (int i = 0; i < 512; i++) {
            String salt = "dim_" + i + "_swp391_headphone";
            int h = (text + salt).hashCode();
            double val = (double) h / Integer.MAX_VALUE;
            vec[i] = val;
            sumSq += val * val;
        }
        double norm = Math.sqrt(sumSq);
        if (norm > 0) {
            for (int i = 0; i < 512; i++) {
                vec[i] = Math.round((vec[i] / norm) * 1000000.0) / 1000000.0;
            }
        }
        return vec;
    }

    /**
     * Parses stored vector string or auto-generates 512-D vector on the fly and saves to DB.
     */
    public double[] parseOrGenerateVector(Map<String, Object> p) {
        String emb = (String) p.get("embeddingVector");
        if (emb != null && emb.startsWith("[") && emb.endsWith("]")) {
            try {
                String clean = emb.substring(1, emb.length() - 1).trim();
                if (!clean.isEmpty()) {
                    String[] tokens = clean.split(",");
                    double[] vec = new double[tokens.length];
                    for (int i = 0; i < tokens.length; i++) {
                        vec[i] = Double.parseDouble(tokens[i].trim());
                    }
                    return vec;
                }
            } catch (Exception ignored) {
            }
        }
        // Tự động phân tích và sinh vector 512 chiều nếu sản phẩm chưa có
        double[] newVec = generateProduct512Vector(p);
        int pid = (int) p.get("productId");
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < newVec.length; i++) {
            sb.append(newVec[i]);
            if (i < newVec.length - 1) sb.append(", ");
        }
        sb.append("]");
        aiPerformanceDAO.updateProductEmbeddingVector(pid, sb.toString());
        return newVec;
    }

    /**
     * Generates Top K AI Hybrid Recommendations for Product Detail page using 512-Vector Semantic Matching & User Behavior.
     */
    public List<Map<String, Object>> getRecommendedProductsForDetail(int currentProductId, Integer customerId, String sessionId) {
        syncConfigurationFromDatabase();
        List<Map<String, Object>> allProducts = aiPerformanceDAO.getAllProductsForRecommendation();
        if (allProducts == null || allProducts.isEmpty()) {
            return new ArrayList<>();
        }

        Map<String, Object> currentProduct = null;
        for (Map<String, Object> p : allProducts) {
            if ((int) p.get("productId") == currentProductId) {
                currentProduct = p;
                break;
            }
        }

        double[] currentVec = currentProduct != null ? parseOrGenerateVector(currentProduct) : null;
        Map<Integer, Double> behaviorScores = aiPerformanceDAO.getProductBehaviorScores();

        List<Map<String, Object>> candidates = new ArrayList<>();
        for (Map<String, Object> p : allProducts) {
            int pid = (int) p.get("productId");
            if (pid == currentProductId) continue; // Bỏ qua chính sản phẩm đang xem

            double[] otherVec = parseOrGenerateVector(p);
            double simScore = currentVec != null ? calculateCosineSimilarity(currentVec, otherVec) : 0.50;
            double behScore = behaviorScores.getOrDefault(pid, 0.50);

            // Hybrid formula: FinalScore = w_sim * S_sim + w_beh * S_beh
            double finalScore = (similarityWeight * simScore) + (behaviorWeight * behScore);
            finalScore = Math.max(0.0, Math.min(1.0, finalScore));

            Map<String, Object> item = new HashMap<>(p);
            item.put("similarityScore", round(simScore, 4));
            item.put("behaviorScore", round(behScore, 4));
            item.put("finalScore", round(finalScore, 4));
            item.put("matchPercentage", (int) Math.round(finalScore * 100));
            candidates.add(item);
        }

        // Lọc theo MinSimilarityThreshold và sắp xếp giảm dần theo finalScore
        List<Map<String, Object>> filtered = new ArrayList<>();
        for (Map<String, Object> c : candidates) {
            double fs = (double) c.get("finalScore");
            if (fs >= minSimilarityThreshold) {
                filtered.add(c);
            }
        }
        filtered.sort((a, b) -> Double.compare((double) b.get("finalScore"), (double) a.get("finalScore")));

        // Giới hạn theo TopKLimit (mặc định lấy 4 hoặc theo cấu hình)
        int limit = Math.max(1, Math.min(topKLimit, 8));
        List<Map<String, Object>> result = new ArrayList<>();
        for (int i = 0; i < filtered.size() && i < limit; i++) {
            result.add(filtered.get(i));
        }

        // Áp dụng Fallback Strategy nếu số lượng chưa đủ
        if (result.size() < limit && "BEST_SELLER".equalsIgnoreCase(fallbackStrategy)) {
            for (Map<String, Object> c : candidates) {
                if (!result.contains(c)) {
                    c.put("recommendationType", "BEST_SELLER");
                    result.add(c);
                    if (result.size() >= limit) break;
                }
            }
        }

        // Ghi log AIRecommendations và gắn recommendationId vào từng sản phẩm
        for (Map<String, Object> item : result) {
            int pid = (int) item.get("productId");
            double sim = (double) item.get("similarityScore");
            double beh = (double) item.get("behaviorScore");
            double fs = (double) item.get("finalScore");
            String recType = (String) item.getOrDefault("recommendationType", "SIMILAR");
            long recId = aiPerformanceDAO.recordAIRecommendation(customerId, sessionId, pid, recType, sim, beh, fs, "AI 512-Vector Semantic Recommender");
            item.put("recommendationId", recId);
        }

        return result;
    }

    /**
     * Generates Personalized AI Hybrid Recommendations for the Home page based on Customer / Session behavior profile
     * (UserBehaviors, Favorites/Wishlist, Past Orders) combined with 512-Vector Semantic Matching.
     */
    public List<Map<String, Object>> getRecommendedProductsForHome(
            Integer customerId, String sessionId, java.util.Collection<Integer> sessionWishlistIds) {
        syncConfigurationFromDatabase();
        if ("PAUSED".equalsIgnoreCase(algorithmStatus) || "INACTIVE".equalsIgnoreCase(algorithmStatus)) {
            return new ArrayList<>();
        }

        List<Map<String, Object>> allProducts = aiPerformanceDAO.getAllProductsForRecommendation();
        if (allProducts == null || allProducts.isEmpty()) {
            return new ArrayList<>();
        }

        Map<Integer, Double> globalBehaviorScores = aiPerformanceDAO.getProductBehaviorScores();
        Map<Integer, Double> userWeights = aiPerformanceDAO.getUserPersonalBehaviorWeights(customerId, sessionId);

        if (sessionWishlistIds != null) {
            for (Integer wid : sessionWishlistIds) {
                if (wid != null && wid > 0) {
                    userWeights.put(wid, userWeights.getOrDefault(wid, 0.0) + 3.5);
                }
            }
        }

        boolean isPersonalized = !userWeights.isEmpty();
        String baseRecType = isPersonalized ? "PERSONALIZED" : fallbackStrategy;

        // Xây dựng vector hồ sơ sở thích người dùng 512 chiều (User Preference 512-D Centroid Vector)
        double[] userProfileVec = new double[512];
        double totalWeight = 0.0;
        Map<Integer, Double> categoryAffinity = new HashMap<>();
        Map<Integer, Double> brandAffinity = new HashMap<>();

        if (isPersonalized) {
            for (Map<String, Object> p : allProducts) {
                int pid = (int) p.get("productId");
                Double w = userWeights.get(pid);
                if (w != null && w > 0) {
                    double[] pVec = parseOrGenerateVector(p);
                    for (int i = 0; i < 512 && i < pVec.length; i++) {
                        userProfileVec[i] += pVec[i] * w;
                    }
                    totalWeight += w;

                    int catId = (int) p.getOrDefault("categoryId", 0);
                    int brId = (int) p.getOrDefault("brandId", 0);
                    categoryAffinity.put(catId, categoryAffinity.getOrDefault(catId, 0.0) + w);
                    brandAffinity.put(brId, brandAffinity.getOrDefault(brId, 0.0) + w);
                }
            }
        } else {
            // Cold-start: Tạo centroid từ các sản phẩm có điểm hành vi toàn cục cao nhất
            for (Map<String, Object> p : allProducts) {
                int pid = (int) p.get("productId");
                double w = globalBehaviorScores.getOrDefault(pid, 0.50);
                double[] pVec = parseOrGenerateVector(p);
                for (int i = 0; i < 512 && i < pVec.length; i++) {
                    userProfileVec[i] += pVec[i] * w;
                }
                totalWeight += w;
            }
        }

        if (totalWeight > 0) {
            double normSq = 0.0;
            for (int i = 0; i < 512; i++) {
                userProfileVec[i] /= totalWeight;
                normSq += userProfileVec[i] * userProfileVec[i];
            }
            double norm = Math.sqrt(normSq);
            if (norm > 0) {
                for (int i = 0; i < 512; i++) {
                    userProfileVec[i] /= norm;
                }
            }
        }

        List<Map<String, Object>> candidates = new ArrayList<>();
        for (Map<String, Object> p : allProducts) {
            int pid = (int) p.get("productId");
            int catId = (int) p.getOrDefault("categoryId", 0);
            int brId = (int) p.getOrDefault("brandId", 0);

            double[] pVec = parseOrGenerateVector(p);
            double rawCosine = calculateCosineSimilarity(userProfileVec, pVec);

            // Cộng điểm tương đồng ngữ nghĩa theo Danh mục & Thương hiệu yêu thích của người dùng
            double catBonus = (totalWeight > 0 && categoryAffinity.containsKey(catId))
                    ? 0.14 * (categoryAffinity.get(catId) / totalWeight) : 0.0;
            double brandBonus = (totalWeight > 0 && brandAffinity.containsKey(brId))
                    ? 0.10 * (brandAffinity.get(brId) / totalWeight) : 0.0;

            double simScore = Math.min(0.98, Math.max(0.55, (rawCosine * 0.65) + 0.25 + catBonus + brandBonus));
            double globalBeh = globalBehaviorScores.getOrDefault(pid, 0.55);
            double personalBeh = userWeights.containsKey(pid)
                    ? Math.min(1.0, 0.65 + (userWeights.get(pid) / Math.max(1.0, totalWeight)) * 0.35)
                    : globalBeh;
            double behScore = isPersonalized ? (0.60 * personalBeh + 0.40 * globalBeh) : globalBeh;

            double finalScore = (similarityWeight * simScore) + (behaviorWeight * behScore);
            finalScore = Math.max(0.0, Math.min(0.99, finalScore));

            Map<String, Object> item = new HashMap<>(p);
            item.put("similarityScore", round(simScore, 4));
            item.put("behaviorScore", round(behScore, 4));
            item.put("finalScore", round(finalScore, 4));
            item.put("matchPercentage", Math.max(60, Math.min(99, (int) Math.round(finalScore * 100))));
            item.put("recommendationType", baseRecType);
            item.put("aiReason", isPersonalized
                    ? "Based on your activity & preferences"
                    : "Trending smart pick for you");
            candidates.add(item);
        }

        candidates.sort((a, b) -> Double.compare((double) b.get("finalScore"), (double) a.get("finalScore")));

        List<Map<String, Object>> filtered = new ArrayList<>();
        for (Map<String, Object> c : candidates) {
            if ((double) c.get("finalScore") >= minSimilarityThreshold) {
                filtered.add(c);
            }
        }

        int limit = Math.max(4, Math.min(topKLimit, 12));
        List<Map<String, Object>> result = new ArrayList<>();
        for (int i = 0; i < filtered.size() && i < limit; i++) {
            result.add(filtered.get(i));
        }

        // Bổ sung dự phòng nếu số lượng sản phẩm vượt ngưỡng chưa đủ cho Carousel trang chủ
        if (result.size() < Math.min(8, candidates.size())) {
            for (Map<String, Object> c : candidates) {
                if (!result.contains(c)) {
                    if (!isPersonalized) {
                        c.put("recommendationType", fallbackStrategy);
                    }
                    result.add(c);
                    if (result.size() >= limit) break;
                }
            }
        }

        // Ghi nhận top 4 gợi ý đầu tiên vào bảng AIRecommendations để theo dõi hiệu năng AI
        for (int i = 0; i < result.size(); i++) {
            Map<String, Object> item = result.get(i);
            if (i < 4) {
                int pid = (int) item.get("productId");
                double sim = (double) item.get("similarityScore");
                double beh = (double) item.get("behaviorScore");
                double fs = (double) item.get("finalScore");
                String recType = (String) item.getOrDefault("recommendationType", baseRecType);
                String reason = (String) item.getOrDefault("aiReason", "Home AI Personalized Recommender");
                long recId = aiPerformanceDAO.recordAIRecommendation(customerId, sessionId, pid, recType, sim, beh, fs, reason);
                item.put("recommendationId", recId);
            } else {
                item.put("recommendationId", 0L);
            }
        }

        return result;
    }

    /**
     * Tracks a click on an AI-recommended product.
     */
    public void trackRecommendationClick(long recId, int productId, Integer customerId, String sessionId) {
        aiPerformanceDAO.trackRecommendationClick(recId, productId, customerId, sessionId);
    }

    /**
     * Natural Language AI Shopping Assistant: parses user query for intent, category, brand, features, and budget,
     * scores products using 512-Vector Semantic Matching + Hybrid Behavior Scoring, and returns AI response + product cards.
     */
    public static class IntentCriteria {
        public boolean wantHeadphone;
        public boolean wantEarbud;
        public boolean wantANC;
        public boolean wantBattery;
        public Integer minBatteryHours;
        public Integer maxBatteryHours;
        public boolean wantWaterRes;
        public boolean wantSport;
        public boolean wantGamingOrCalls;
        public boolean wantWireless;
        public boolean wantWired;
        public boolean wantBudget;
        public boolean wantPremium;
        public Double maxPriceLimit;
        public Double minPriceLimit;
        public boolean wantLightweight;
        public boolean wantComfortable;
        public boolean wantBass;
        public String matchedBrand;
        public List<String> keywords = new ArrayList<>();
    }

    public IntentCriteria extractIntentCriteria(String query, String qLower, List<Map<String, Object>> allProducts) {
        IntentCriteria c = new IntentCriteria();
        c.wantHeadphone = qLower.contains("headphone") || qLower.contains("over-ear") || qLower.contains("over ear")
                || qLower.contains("on-ear") || qLower.contains("on ear") || qLower.contains("headset") || qLower.contains("studio")
                || qLower.contains("audiophile") || qLower.contains("tai nghe chụp") || qLower.contains("chụp tai");
        c.wantEarbud = qLower.contains("earbud") || qLower.contains("in-ear") || qLower.contains("in ear")
                || qLower.contains("tws") || qLower.contains("earphone") || qLower.contains("true wireless") || qLower.contains("buds")
                || qLower.contains("nhét tai");

        c.wantANC = qLower.contains("anc") || qLower.contains("noise cancelling") || qLower.contains("noise cancellation")
                || qLower.contains("chống ồn") || qLower.contains("khử ồn") || qLower.contains("chong on")
                || qLower.contains("noise") || qLower.contains("quiet") || qLower.contains("isolation")
                || qLower.contains("study") || qLower.contains("flight") || qLower.contains("airplane") || qLower.contains("office");
        
        // Extract numeric and keyword battery constraints
        extractBatteryConstraints(qLower, c);

        c.wantWaterRes = qLower.contains("water") || qLower.contains("waterproof") || qLower.contains("water-resistant")
                || qLower.contains("chống nước") || qLower.contains("kháng nước") || qLower.contains("chong nuoc")
                || qLower.contains("sweat") || qLower.contains("sweatproof") || qLower.contains("ipx") || qLower.contains("splash");
        c.wantSport = qLower.contains("sport") || qLower.contains("gym") || qLower.contains("run")
                || qLower.contains("running") || qLower.contains("workout") || qLower.contains("exercise") || c.wantWaterRes;
        c.wantGamingOrCalls = qLower.contains("game") || qLower.contains("gaming") || qLower.contains("mic")
                || qLower.contains("microphone") || qLower.contains("call") || qLower.contains("calls")
                || qLower.contains("meeting") || qLower.contains("zoom") || qLower.contains("voice");
        c.wantWireless = qLower.contains("wireless") || qLower.contains("bluetooth") || qLower.contains("cordless")
                || qLower.contains("không dây");
        c.wantWired = qLower.contains("wired") || qLower.contains("cable") || qLower.contains("3.5mm")
                || qLower.contains("có dây");
        c.wantBudget = qLower.contains("cheap") || qLower.contains("budget") || qLower.contains("affordable")
                || qLower.contains("low price") || qLower.contains("inexpensive") || qLower.contains("entry level")
                || qLower.contains("giá rẻ") || qLower.contains("gia re");
        c.wantPremium = qLower.contains("premium") || qLower.contains("luxury") || qLower.contains("high-end")
                || qLower.contains("high end") || qLower.contains("flagship") || qLower.contains("best") || qLower.contains("pro")
                || qLower.contains("cao cấp");

        // Word-boundary match so "flight", "highlight", "lightning" do NOT trigger the lightweight filter
        c.wantLightweight = java.util.regex.Pattern.compile("(?<![a-z])light(?:weight|er|est)?(?![a-z])").matcher(qLower).find()
                || qLower.contains("nhẹ");
        c.wantComfortable = qLower.contains("comfort") || qLower.contains("comfortable") || qLower.contains("êm") || qLower.contains("dễ chịu");
        c.wantBass = qLower.contains("bass") || qLower.contains("heavy bass") || qLower.contains("deep bass");

        extractPriceConstraints(qLower, c);

        if (allProducts != null) {
            for (Map<String, Object> p : allProducts) {
                String bName = (String) p.get("brandName");
                if (bName != null && !bName.isEmpty() && qLower.contains(bName.toLowerCase(java.util.Locale.ROOT))) {
                    c.matchedBrand = bName;
                    break;
                }
            }
        }

        String[] rawTokens = qLower.replaceAll("[^a-z0-9\\s]", " ").split("\\s+");
        List<String> stopWords = java.util.Arrays.asList(
                "i", "want", "need", "looking", "for", "a", "an", "the", "me", "find", "show", "recommend",
                "suggest", "some", "good", "with", "and", "or", "to", "in", "on", "of", "under", "below",
                "over", "above", "around", "about", "can", "you", "please", "what", "is", "are", "which", "buy"
        );
        for (String tk : rawTokens) {
            if (tk.length() >= 2 && !stopWords.contains(tk) && !tk.matches("^\\d+$")) {
                c.keywords.add(tk);
            }
        }
        return c;
    }

    public int calculateIntentMatchScore(Map<String, Object> p, IntentCriteria c, int rank) {
        if (p == null) return 50;

        int score = 99 - (rank * 2); // Rank 0 starts at 99%, rank 1 at 97%, rank 2 at 95%...
        String pCat = ((String) p.getOrDefault("categoryName", "")).toLowerCase(java.util.Locale.ROOT);
        String pBrand = ((String) p.getOrDefault("brandName", "")).toLowerCase(java.util.Locale.ROOT);
        String pWater = ((String) p.getOrDefault("waterResistance", "None")).trim();
        boolean hasWater = !pWater.equalsIgnoreCase("None") && !pWater.isEmpty();
        boolean pAnc = Boolean.TRUE.equals(p.get("noiseCancelling"));
        double pPrice = p.get("price") instanceof Number ? ((Number) p.get("price")).doubleValue() : 0.0;
        int pBat = p.get("batteryLife") instanceof Number ? ((Number) p.get("batteryLife")).intValue() : 0;

        // 1. Water resistance constraint (Heavy penalty if user explicitly asked for water resistance but item lacks it)
        if (c.wantWaterRes) {
            if (!hasWater) {
                score -= 42; // Major penalty: does not meet primary waterproof criterion
            }
        }

        // 2. Category mismatch (Over-ear vs In-ear)
        if (c.wantHeadphone && !c.wantEarbud) {
            if (pCat.contains("earbud") || pCat.contains("in-ear")) {
                score -= 28;
            }
        } else if (c.wantEarbud && !c.wantHeadphone) {
            if (pCat.contains("headphone") || pCat.contains("over-ear")) {
                score -= 28;
            }
        }

        // 3. Price constraint violation
        if (c.maxPriceLimit != null) {
            if (pPrice > c.maxPriceLimit) {
                double overRatio = (pPrice - c.maxPriceLimit) / c.maxPriceLimit;
                if (overRatio > 0.50) {
                    score -= 40; // Way over budget
                } else if (overRatio > 0.15) {
                    score -= 25;
                } else {
                    score -= 12;
                }
            }
        }

        // 4. ANC requirement
        if (c.wantANC && !pAnc) {
            score -= 18;
        }

        // 5. Brand requirement
        if (c.matchedBrand != null && !pBrand.equalsIgnoreCase(c.matchedBrand)) {
            score -= 25;
        }

        // 6. Battery requirement
        if (c.minBatteryHours != null && pBat < c.minBatteryHours) {
            int diff = c.minBatteryHours - pBat;
            score -= Math.min(45, 25 + diff);
        } else if (c.maxBatteryHours != null && pBat > c.maxBatteryHours) {
            int diff = pBat - c.maxBatteryHours;
            score -= Math.min(45, 25 + diff);
        } else if (c.wantBattery && pBat < 20) {
            score -= 14;
        }

        // 7. Qualitative ergonomic criteria (Weight / Lightweight, Comfort, Bass)
        double pWeight = p.get("weight") instanceof Number ? ((Number) p.get("weight")).doubleValue() : 250.0;
        String pDesc = ((String) p.getOrDefault("description", "")).toLowerCase(java.util.Locale.ROOT);

        if (c.wantLightweight && pWeight > 250.0) {
            double excess = pWeight - 250.0;
            if (excess > 100.0) {
                score -= 35; // Excessively heavy models (>350g, e.g. AirPods Max 385g, JBL Quantum 418g)
            } else if (excess > 35.0) {
                score -= 24; // Noticeably heavy models (>285g, e.g. Sennheiser Momentum 293g, ATH-M50xBT2 307g)
            } else {
                score -= 15; // Moderately over 250g (e.g. 254g)
            }
        }
        if (c.wantComfortable && pWeight > 320.0) {
            score -= 15;
        }
        if (c.wantBass && !pDesc.contains("bass")) {
            score -= 10;
        }

        // 8. Connection constraint (Wireless vs Wired)
        String pConn = ((String) p.getOrDefault("connectionType", "BLUETOOTH")).toUpperCase(java.util.Locale.ROOT);
        if (c.wantWireless && pConn.contains("WIRED") && !pConn.contains("BLUETOOTH") && !pConn.contains("WIRELESS")) {
            score -= 32;
        } else if (c.wantWired && (!pConn.contains("WIRED") || pConn.contains("BLUETOOTH"))) {
            score -= 32;
        }

        return Math.max(30, Math.min(99, score));
    }

    public Map<String, Object> askAIShoppingAssistant(String rawQuery, Integer customerId, String sessionId) {
        syncConfigurationFromDatabase();
        Map<String, Object> responseMap = new HashMap<>();
        String query = rawQuery != null ? rawQuery.trim() : "";
        String qLower = query.toLowerCase(java.util.Locale.ROOT);

        List<Map<String, Object>> allProducts = aiPerformanceDAO.getAllProductsForRecommendation();
        if (allProducts == null || allProducts.isEmpty()) {
            responseMap.put("reply", "I'm sorry, our product catalog is currently unavailable. Please try again shortly!");
            responseMap.put("products", new ArrayList<Map<String, Object>>());
            return responseMap;
        }

        // Record search behavior event
        if (!query.isEmpty() && query.length() >= 2) {
            aiPerformanceDAO.recordSearchBehavior(customerId, sessionId, query);
        }

        Map<Integer, Double> behaviorScores = aiPerformanceDAO.getProductBehaviorScores();
        IntentCriteria criteria = extractIntentCriteria(query, qLower, allProducts);

        // 0. Try Google Gemini AI first (RAG over active product catalog)
        if (!query.isEmpty()) {
            Map<String, Object> geminiRes = com.swp391.util.GeminiClient.askShoppingAssistantWithGemini(query, allProducts);
            if (geminiRes != null && geminiRes.get("reply") != null) {
                @SuppressWarnings("unchecked")
                List<Integer> geminiIds = (List<Integer>) geminiRes.get("productIds");
                List<Map<String, Object>> geminiPicks = new ArrayList<>();
                if (geminiIds != null && !geminiIds.isEmpty()) {
                    int rank = 0;
                    for (Integer gid : geminiIds) {
                        for (Map<String, Object> p : allProducts) {
                            if (gid.equals(p.get("productId"))) {
                                int pBat = p.get("batteryLife") instanceof Number ? ((Number) p.get("batteryLife")).intValue() : 0;
                                double pPrice = p.get("price") instanceof Number ? ((Number) p.get("price")).doubleValue() : 0.0;
                                double pW = p.get("weight") instanceof Number ? ((Number) p.get("weight")).doubleValue() : 250.0;
                                // Reject Gemini pick if it contradicts hard constraints
                                if (criteria.wantLightweight && pW > 250.0) continue;
                                if (criteria.minBatteryHours != null && pBat < criteria.minBatteryHours) continue;
                                if (criteria.maxBatteryHours != null && pBat > criteria.maxBatteryHours) continue;
                                if (criteria.maxPriceLimit != null && pPrice > criteria.maxPriceLimit * 1.05) continue;

                                Map<String, Object> item = new HashMap<>(p);
                                int matchPct = calculateIntentMatchScore(p, criteria, rank);
                                double sim = round(matchPct / 100.0, 4);
                                double beh = behaviorScores.getOrDefault(gid, 0.70);
                                double fs = sim;

                                item.put("similarityScore", sim);
                                item.put("behaviorScore", round(beh, 4));
                                item.put("finalScore", round(fs, 4));
                                item.put("matchPercentage", matchPct);
                                long recId = aiPerformanceDAO.recordAIRecommendation(
                                        customerId, sessionId, gid, "AI_CHAT", sim, beh, fs,
                                        "Gemini AI Assistant: " + (query.length() > 80 ? query.substring(0, 80) : query));
                                item.put("recommendationId", recId);
                                geminiPicks.add(item);
                                rank++;
                                break;
                            }
                        }
                    }
                }
                // Return Gemini response only if valid picks remain, or if intent was conversational rejection
                if (!geminiPicks.isEmpty() || (geminiIds != null && geminiIds.isEmpty())) {
                    responseMap.put("reply", geminiRes.get("reply"));
                    responseMap.put("products", geminiPicks);
                    return responseMap;
                }
            }
        }

        // 1. Guard against empty / gibberish / small talk / off-topic queries in local fallback
        if (isOutOfScopeOrGibberish(query, qLower)) {
            responseMap.put("reply", "I am an AI shopping assistant dedicated to audio products. I cannot answer social, off-topic, or non-shopping inquiries. Please ask me about buying headphones, earbuds, or audio gear (e.g., budget, noise cancelling, battery life, brand).");
            responseMap.put("products", new ArrayList<Map<String, Object>>());
            return responseMap;
        }

        // 2. LOCAL SEARCH BY INTENT & TRUTHFUL REASONING ENGINE
        // Check for specific unsatisfiable combinations in our catalog:
        boolean impossibleWaterproofHeadphones = criteria.wantWaterRes && criteria.wantHeadphone && !criteria.wantEarbud;
        boolean impossibleBudget = criteria.maxPriceLimit != null && criteria.maxPriceLimit < 1500000;
        boolean impossibleBattery = criteria.minBatteryHours != null && criteria.minBatteryHours > 80;

        // Perform strict criteria filtering
        List<Map<String, Object>> strictMatches = new ArrayList<>();
        if (!impossibleWaterproofHeadphones && !impossibleBudget && !impossibleBattery) {
            for (Map<String, Object> p : allProducts) {
                String pCat = ((String) p.getOrDefault("categoryName", "")).toLowerCase(java.util.Locale.ROOT);
                String pBrand = ((String) p.getOrDefault("brandName", "")).toLowerCase(java.util.Locale.ROOT);
                String pWater = ((String) p.getOrDefault("waterResistance", "None")).trim();
                boolean hasWater = !pWater.equalsIgnoreCase("None") && !pWater.isEmpty();
                boolean pAnc = Boolean.TRUE.equals(p.get("noiseCancelling"));
                double pPrice = p.get("price") instanceof Number ? ((Number) p.get("price")).doubleValue() : 0.0;
                int pBat = p.get("batteryLife") instanceof Number ? ((Number) p.get("batteryLife")).intValue() : 0;

                // Category constraint
                if (criteria.wantHeadphone && !criteria.wantEarbud && (pCat.contains("earbud") || pCat.contains("in-ear"))) {
                    continue;
                }
                if (criteria.wantEarbud && !criteria.wantHeadphone && (pCat.contains("headphone") || pCat.contains("over-ear"))) {
                    continue;
                }
                // Water resistance constraint
                if (criteria.wantWaterRes && !hasWater) {
                    continue;
                }
                // Price constraint
                if (criteria.maxPriceLimit != null && pPrice > criteria.maxPriceLimit * 1.05) {
                    continue;
                }
                if (criteria.minPriceLimit != null && pPrice < criteria.minPriceLimit * 0.95) {
                    continue;
                }
                // Battery constraint
                if (criteria.minBatteryHours != null && pBat < criteria.minBatteryHours) {
                    continue;
                }
                if (criteria.maxBatteryHours != null && pBat > criteria.maxBatteryHours) {
                    continue;
                }
                // Brand constraint
                if (criteria.matchedBrand != null && !pBrand.equalsIgnoreCase(criteria.matchedBrand)) {
                    continue;
                }
                // ANC constraint
                if (criteria.wantANC && !pAnc) {
                    continue;
                }
                // Weight constraint: If user asked for lightweight, exclude products heavier than 250g
                double pWeight = p.get("weight") instanceof Number ? ((Number) p.get("weight")).doubleValue() : 250.0;
                if (criteria.wantLightweight && pWeight > 250.0) {
                    continue;
                }

                // Connection constraint (Wireless vs Wired)
                String pConn = ((String) p.getOrDefault("connectionType", "BLUETOOTH")).toUpperCase(java.util.Locale.ROOT);
                if (criteria.wantWireless && (pConn.contains("WIRED") && !pConn.contains("BLUETOOTH") && !pConn.contains("WIRELESS"))) {
                    continue;
                }
                if (criteria.wantWired && (!pConn.contains("WIRED") || pConn.contains("BLUETOOTH"))) {
                    continue;
                }

                strictMatches.add(p);
            }
        }

        List<Map<String, Object>> finalPicks = new ArrayList<>();
        StringBuilder reply = new StringBuilder();

        // SCENARIO A: Strict matches exist! All user criteria are fully met.
        if (!strictMatches.isEmpty()) {
            // Rank strict matches: lightweight (if requested) first, then battery life, then popularity
            strictMatches.sort((a, b) -> {
                double wA = a.get("weight") instanceof Number ? ((Number) a.get("weight")).doubleValue() : 250.0;
                double wB = b.get("weight") instanceof Number ? ((Number) b.get("weight")).doubleValue() : 250.0;
                if (criteria.wantLightweight) {
                    if (Double.compare(wA, wB) != 0) {
                        return Double.compare(wA, wB); // lighter first
                    }
                }
                int batA = a.get("batteryLife") instanceof Number ? ((Number) a.get("batteryLife")).intValue() : 0;
                int batB = b.get("batteryLife") instanceof Number ? ((Number) b.get("batteryLife")).intValue() : 0;
                if (criteria.minBatteryHours != null || criteria.wantBattery) {
                    if (batA != batB) {
                        return Integer.compare(batB, batA);
                    }
                }
                int pidA = (int) a.get("productId");
                int pidB = (int) b.get("productId");
                double behA = behaviorScores.getOrDefault(pidA, 0.50);
                double behB = behaviorScores.getOrDefault(pidB, 0.50);
                return Double.compare(behB, behA);
            });

            int limit = Math.min(4, strictMatches.size());
            for (int i = 0; i < limit; i++) {
                Map<String, Object> p = strictMatches.get(i);
                int pid = (int) p.get("productId");
                Map<String, Object> item = new HashMap<>(p);

                // High match percentage reflecting full criteria satisfaction: 99%, 97%, 95%, 93%
                int matchPct = calculateIntentMatchScore(p, criteria, i);
                double sim = round(matchPct / 100.0, 4);
                double beh = behaviorScores.getOrDefault(pid, 0.55);

                item.put("similarityScore", sim);
                item.put("behaviorScore", round(beh, 4));
                item.put("finalScore", sim);
                item.put("matchPercentage", matchPct);

                long recId = aiPerformanceDAO.recordAIRecommendation(
                        customerId, sessionId, pid, "AI_CHAT", sim, beh, sim,
                        "AI Chatbot Intent Search: " + (query.length() > 80 ? query.substring(0, 80) : query));
                item.put("recommendationId", recId);
                finalPicks.add(item);
            }

            List<String> criteriaParts = new ArrayList<>();
            if (criteria.matchedBrand != null) criteriaParts.add(criteria.matchedBrand);
            if (criteria.wantWireless) criteriaParts.add("wireless");
            else if (criteria.wantWired) criteriaParts.add("wired");
            if (criteria.wantHeadphone && !criteria.wantEarbud) criteriaParts.add("over-ear headphones");
            else if (criteria.wantEarbud && !criteria.wantHeadphone) criteriaParts.add("in-ear earbuds");
            else criteriaParts.add("audio models");

            if (criteria.wantWaterRes) criteriaParts.add("with certified water resistance (IPX)");
            if (criteria.wantANC) criteriaParts.add("with Active Noise Cancelling (ANC)");
            if (criteria.minBatteryHours != null && criteria.maxBatteryHours != null) {
                criteriaParts.add("battery life between " + criteria.minBatteryHours + " and " + criteria.maxBatteryHours + " hours");
            } else if (criteria.minBatteryHours != null) {
                criteriaParts.add("battery life over " + criteria.minBatteryHours + " hours");
            } else if (criteria.maxBatteryHours != null) {
                criteriaParts.add("battery life under " + criteria.maxBatteryHours + " hours");
            } else if (criteria.wantBattery) {
                criteriaParts.add("with long battery life");
            }
            if (criteria.minPriceLimit != null && criteria.maxPriceLimit != null) {
                criteriaParts.add("priced between " + String.format("%,d", criteria.minPriceLimit.longValue()) + " and " + String.format("%,d", criteria.maxPriceLimit.longValue()) + " VND");
            } else if (criteria.maxPriceLimit != null) {
                criteriaParts.add("under " + String.format("%,d", criteria.maxPriceLimit.longValue()) + " VND");
            } else if (criteria.minPriceLimit != null) {
                criteriaParts.add("over " + String.format("%,d", criteria.minPriceLimit.longValue()) + " VND");
            }
            if (criteria.wantLightweight) {
                criteriaParts.add("lightweight ergonomic design");
            }
            if (criteria.wantComfortable) {
                criteriaParts.add("comfortable fit");
            }

            reply.append("Great news! I found ").append(finalPicks.size())
                 .append(" models in our catalog that perfectly match all your criteria (")
                 .append(String.join(", ", criteriaParts)).append("):");

        } else {
            // SCENARIO B: FALLBACK WITH 100% HONESTY & TRANSPARENCY

            if (impossibleWaterproofHeadphones) {
                // Truthful explanation for waterproof over-ear headphones
                reply.append("Currently, our store does not carry any over-ear headphones with water resistance (IPX rating), as virtually all water-resistant audio models in our catalog are in-ear earbuds. ")
                     .append("To help you choose, here are our best water-resistant earbuds (IPX4/IPX5) for active use, alongside our top-rated over-ear headphones (note: they do not offer water resistance):");

                // 1. Pick top water-resistant earbuds
                int earbudCount = 0;
                for (Map<String, Object> p : allProducts) {
                    String pCat = ((String) p.getOrDefault("categoryName", "")).toLowerCase(java.util.Locale.ROOT);
                    String pWater = ((String) p.getOrDefault("waterResistance", "None")).trim();
                    boolean hasWater = !pWater.equalsIgnoreCase("None") && !pWater.isEmpty();
                    if ((pCat.contains("earbud") || pCat.contains("in-ear")) && hasWater) {
                        Map<String, Object> item = new HashMap<>(p);
                        int matchPct = calculateIntentMatchScore(p, criteria, earbudCount);
                        item.put("matchPercentage", matchPct);
                        item.put("similarityScore", round(matchPct / 100.0, 4));
                        item.put("finalScore", round(matchPct / 100.0, 4));
                        item.put("aiReason", "Alternative: In-Ear with " + pWater + " Water Resistance");
                        finalPicks.add(item);
                        earbudCount++;
                        if (earbudCount >= 2) break;
                    }
                }

                // 2. Pick top over-ear headphones (truthfully penalized for lacking water resistance)
                int hpCount = 0;
                for (Map<String, Object> p : allProducts) {
                    String pCat = ((String) p.getOrDefault("categoryName", "")).toLowerCase(java.util.Locale.ROOT);
                    if (pCat.contains("headphone") || pCat.contains("over-ear")) {
                        Map<String, Object> item = new HashMap<>(p);
                        int matchPct = calculateIntentMatchScore(p, criteria, 2 + hpCount);
                        item.put("matchPercentage", matchPct); // Will be ~55% due to missing water resistance
                        item.put("similarityScore", round(matchPct / 100.0, 4));
                        item.put("finalScore", round(matchPct / 100.0, 4));
                        item.put("aiReason", "Alternative: Over-Ear Headphone (No Water Resistance)");
                        finalPicks.add(item);
                        hpCount++;
                        if (hpCount >= 2) break;
                    }
                }

            } else if (impossibleBudget) {
                // Truthful explanation for budget below catalog minimum
                reply.append("We currently do not have any headphones or earbuds under ")
                     .append(String.format("%,d", criteria.maxPriceLimit.longValue()))
                     .append(" VND in our catalog (our most affordable quality option starts at 1,790,000 VND for Anker Soundcore Space A40). ")
                     .append("Here are our most budget-friendly models closest to your target price:");

                List<Map<String, Object>> budgetSorted = new ArrayList<>(allProducts);
                budgetSorted.sort((a, b) -> {
                    double pa = ((Number) a.get("price")).doubleValue();
                    double pb = ((Number) b.get("price")).doubleValue();
                    return Double.compare(pa, pb);
                });

                int limit = Math.min(4, budgetSorted.size());
                for (int i = 0; i < limit; i++) {
                    Map<String, Object> p = budgetSorted.get(i);
                    Map<String, Object> item = new HashMap<>(p);
                    int matchPct = calculateIntentMatchScore(p, criteria, i);
                    item.put("matchPercentage", matchPct);
                    item.put("similarityScore", round(matchPct / 100.0, 4));
                    item.put("finalScore", round(matchPct / 100.0, 4));
                    item.put("aiReason", "Budget Pick: " + String.format("%,d", ((Number) p.get("price")).longValue()) + " VND");
                    finalPicks.add(item);
                }

            } else if (impossibleBattery) {
                // Truthful explanation for battery beyond maximum available
                reply.append("Our catalog's longest battery life model is Marshall Major IV offering up to 80 hours. We do not currently have models with ")
                     .append(criteria.minBatteryHours).append(" hours of battery life. ")
                     .append("Here are our longest-lasting battery champion models in stock:");

                List<Map<String, Object>> batSorted = new ArrayList<>(allProducts);
                batSorted.sort((a, b) -> {
                    int ba = a.get("batteryLife") instanceof Number ? ((Number) a.get("batteryLife")).intValue() : 0;
                    int bb = b.get("batteryLife") instanceof Number ? ((Number) b.get("batteryLife")).intValue() : 0;
                    return Integer.compare(bb, ba);
                });

                int limit = Math.min(4, batSorted.size());
                for (int i = 0; i < limit; i++) {
                    Map<String, Object> p = batSorted.get(i);
                    Map<String, Object> item = new HashMap<>(p);
                    int matchPct = calculateIntentMatchScore(p, criteria, i);
                    item.put("matchPercentage", matchPct);
                    item.put("similarityScore", round(matchPct / 100.0, 4));
                    item.put("finalScore", round(matchPct / 100.0, 4));
                    item.put("aiReason", "Longest Battery Pick: " + p.get("batteryLife") + " hours");
                    finalPicks.add(item);
                }

            } else {
                // General truthful fallback
                reply.append("I couldn't find an exact product satisfying all of those specific constraints in our current catalog. ")
                     .append("Here are the closest alternatives available with their respective trade-offs noted:");

                List<Map<String, Object>> candidateList = new ArrayList<>(allProducts);
                candidateList.sort((a, b) -> {
                    int sa = calculateIntentMatchScore(a, criteria, 0);
                    int sb = calculateIntentMatchScore(b, criteria, 0);
                    return Double.compare(sb, sa);
                });

                int limit = Math.min(4, candidateList.size());
                for (int i = 0; i < limit; i++) {
                    Map<String, Object> p = candidateList.get(i);
                    Map<String, Object> item = new HashMap<>(p);
                    int matchPct = calculateIntentMatchScore(p, criteria, i);
                    item.put("matchPercentage", matchPct);
                    item.put("similarityScore", round(matchPct / 100.0, 4));
                    item.put("finalScore", round(matchPct / 100.0, 4));
                    finalPicks.add(item);
                }
            }
        }

        responseMap.put("reply", reply.toString());
        responseMap.put("products", finalPicks);
        return responseMap;
    }

    /**
     * Determines whether a user message is gibberish, keyboard spam, small talk, or completely off-topic.
     */
    private boolean isOutOfScopeOrGibberish(String raw, String qLower) {
        if (raw == null || raw.trim().isEmpty()) {
            return true;
        }
        String trimmed = raw.trim();
        // Too short or no letters
        if (trimmed.length() < 2 || !trimmed.matches(".*[a-zA-Z\\u00C0-\\u1EF9].*")) {
            return true;
        }

        // 1. Exact or common greeting / small talk patterns
        if (qLower.matches("^(hi|hello|hey|hey there|greetings|good morning|good afternoon|good evening|how are you|who are you|what can you do|help|alo|chao|xin chao|chao ban|hi ban|hello shop)[\\?!.\\s]*$")) {
            return true;
        }

        // 2. Pure off-topic chit-chat / question words without audio intent
        if (qLower.matches("^(what is your name|how are you doing|are you a robot|tell me a joke|sing a song|write code|who made you|where are you from|weather today|thoi tiet|an com chua)[\\?!.\\s]*$")) {
            return true;
        }

        // 3. Gibberish / keyboard mash detection (e.g. "asdfgh", "qwerty", repeated characters "aaaaaa")
        if (qLower.matches(".*([a-z])\\1{3,}.*")) { // same character repeated 4+ times
            return true;
        }
        if (qLower.matches("^(asdf|qwer|zxcv|jkl;|1234|abcd).*")) {
            return true;
        }

        // 4. Must contain at least one shopping or audio-related keyword/signal
        boolean hasAudioOrShoppingSignal =
                qLower.contains("tai nghe") || qLower.contains("headphone") || qLower.contains("earbud")
                || qLower.contains("earphone") || qLower.contains("airpod") || qLower.contains("headset")
                || qLower.contains("chống ồn") || qLower.contains("anc") || qLower.contains("bass")
                || qLower.contains("treble") || qLower.contains("mic") || qLower.contains("bluetooth")
                || qLower.contains("wireless") || qLower.contains("pin") || qLower.contains("battery")
                || qLower.contains("sony") || qLower.contains("apple") || qLower.contains("bose")
                || qLower.contains("jbl") || qLower.contains("sennheiser") || qLower.contains("razer")
                || qLower.contains("hyperx") || qLower.contains("marshall") || qLower.contains("soundcore")
                || qLower.contains("audio-technica") || qLower.contains("mua") || qLower.contains("giá")
                || qLower.contains("tư vấn") || qLower.contains("tìm") || qLower.contains("buy")
                || qLower.contains("price") || qLower.contains("under") || qLower.contains("cheap")
                || qLower.contains("best") || qLower.contains("recommend") || qLower.contains("suggest")
                || qLower.contains("budget") || qLower.contains("call") || qLower.contains("game")
                || qLower.contains("gaming") || qLower.contains("gym") || qLower.contains("sport")
                || qLower.contains("sound") || qLower.contains("audio") || qLower.contains("wired")
                || qLower.contains("over-ear") || qLower.contains("in-ear") || qLower.contains("tws")
                || qLower.contains("dưới") || qLower.contains("triệu") || qLower.contains("vnd");

        return !hasAudioOrShoppingSignal;
    }

    private void extractBatteryConstraints(String qLower, IntentCriteria c) {
        // Pattern 1: Explicit battery range with unit: "between 30 and 60 hours", "from 30 to 60 hrs", "từ 30 đến 60 giờ"
        java.util.regex.Matcher mBetween = java.util.regex.Pattern.compile(
                "(?:battery(?:\\s+life)?\\s*(?:of|is|around)?\\s*)?(?:between|from|từ|khoảng từ)\\s*([0-9]+)\\s*(?:and|to|-|đến|den)\\s*([0-9]+)\\s*(hours|hrs|hr|h|giờ|gio)").matcher(qLower);
        if (mBetween.find()) {
            try {
                int b1 = Integer.parseInt(mBetween.group(1));
                int b2 = Integer.parseInt(mBetween.group(2));
                c.minBatteryHours = Math.min(b1, b2);
                c.maxBatteryHours = Math.max(b1, b2);
                c.wantBattery = true;
                return;
            } catch (Exception ignored) {
            }
        }

        // Pattern 1B: Battery keyword prefix before between: "battery between 30 and 60"
        java.util.regex.Matcher mBetweenPrefix = java.util.regex.Pattern.compile(
                "(?:battery|pin)(?:\\s+life)?\\s*(?:of|is|around|khoảng)?\\s*(?:between|from|từ|khoảng từ)\\s*([0-9]+)\\s*(?:and|to|-|đến|den)\\s*([0-9]+)").matcher(qLower);
        if (mBetweenPrefix.find()) {
            try {
                int b1 = Integer.parseInt(mBetweenPrefix.group(1));
                int b2 = Integer.parseInt(mBetweenPrefix.group(2));
                c.minBatteryHours = Math.min(b1, b2);
                c.maxBatteryHours = Math.max(b1, b2);
                c.wantBattery = true;
                return;
            } catch (Exception ignored) {
            }
        }

        // Pattern 2: "over 40 hours", "more than 40h", "at least 40 hours", "longer than 40h", "> 40 hours", "trên 40 giờ"
        java.util.regex.Matcher mOver = java.util.regex.Pattern.compile(
                "(?:over|above|more than|at least|greater than|longer than|min|>|>=|trên|tren|hơn|hon)\\s*([0-9]+)\\s*(?:hours|hrs|hr|h|giờ|gio)").matcher(qLower);
        if (mOver.find()) {
            try {
                c.minBatteryHours = Integer.parseInt(mOver.group(1));
                c.wantBattery = true;
            } catch (Exception ignored) {
            }
        }

        // Pattern 3: "40+ hours", "40h+", "40 hours+"
        java.util.regex.Matcher mPlus = java.util.regex.Pattern.compile(
                "([0-9]+)\\s*\\+\\s*(?:hours|hrs|hr|h|giờ|gio)?").matcher(qLower);
        if (mPlus.find()) {
            try {
                c.minBatteryHours = Integer.parseInt(mPlus.group(1));
                c.wantBattery = true;
            } catch (Exception ignored) {
            }
        }

        // Pattern 4: "under 20 hours", "less than 20h", "< 20 hours", "up to 20 hours", "dưới 20 giờ"
        java.util.regex.Matcher mUnder = java.util.regex.Pattern.compile(
                "(?:under|below|less than|shorter than|up to|max|<|<=|dưới|duoi)\\s*([0-9]+)\\s*(?:hours|hrs|hr|h|giờ|gio)").matcher(qLower);
        if (mUnder.find()) {
            try {
                c.maxBatteryHours = Integer.parseInt(mUnder.group(1));
                c.wantBattery = true;
            } catch (Exception ignored) {
            }
        }

        // Only explicit battery wording counts. A bare "hours" (e.g. "long working hours") describes
        // usage duration / comfort, NOT a battery requirement, so it must not trigger battery sorting.
        if (qLower.contains("battery") || qLower.contains("long life") || qLower.contains("endurance")
                || java.util.regex.Pattern.compile("(?<![a-z])pin(?![a-z])").matcher(qLower).find()) {
            c.wantBattery = true;
        }
    }

    private void extractPriceConstraints(String qLower, IntentCriteria c) {
        // Pattern: "between 2 and 5 million", "from 2 to 5 million", "từ 2 đến 5 triệu", "khoảng 2-5tr"
        java.util.regex.Matcher mBetween = java.util.regex.Pattern.compile(
                "(?:between|from|từ|khoảng|khoang)\\s*([0-9]+(?:[.,][0-9]+)*)\\s*(?:and|to|-|đến|den)\\s*([0-9]+(?:[.,][0-9]+)*)\\s*([a-zA-Z%]+)?").matcher(qLower);
        if (mBetween.find()) {
            try {
                String numStr1 = mBetween.group(1);
                String numStr2 = mBetween.group(2);
                String unit = mBetween.group(3) != null ? mBetween.group(3).trim().toLowerCase(java.util.Locale.ROOT) : "";
                if (!unit.startsWith("hour") && !unit.startsWith("hr") && !unit.equals("h") && !unit.startsWith("gio") && !unit.equals("mm")) {
                    double v1 = parsePriceValue(numStr1, unit);
                    double v2 = parsePriceValue(numStr2, unit);
                    if (v1 > 0 && v2 > 0) {
                        c.minPriceLimit = Math.min(v1, v2);
                        c.maxPriceLimit = Math.max(v1, v2);
                        return;
                    }
                }
            } catch (Exception ignored) {
            }
        }
        c.maxPriceLimit = extractPriceConstraint(qLower, true);
        c.minPriceLimit = extractPriceConstraint(qLower, false);
    }

    private double parsePriceValue(String numStr, String unit) {
        double val;
        if (unit.startsWith("m") || unit.startsWith("tri") || unit.equals("tr")) {
            val = Double.parseDouble(numStr.replace(",", ".")) * 1_000_000.0;
        } else if (unit.startsWith("k") || unit.startsWith("th")) {
            val = Double.parseDouble(numStr.replace(",", ".")) * 1_000.0;
        } else {
            String digitsOnly = numStr.replaceAll("[.,]", "");
            val = Double.parseDouble(digitsOnly);
            if (val < 100) {
                val *= 1_000_000.0;
            } else if (val < 10000) {
                val *= 1_000.0;
            }
        }
        return val;
    }

    private Double extractPriceConstraint(String qLower, boolean isMaxLimit) {
        // Detects patterns like "under 3m", "below 2,000,000", "less than 3 million", "under 1500k", "dưới 3 triệu"
        String regex = isMaxLimit
                ? "(?:under|below|less than|cheaper than|max|up to|budget of|budget|around|<|<=|dưới|duoi|tầm|khoảng)\\s*([0-9]+(?:[.,][0-9]+)*)\\s*([a-zA-Z%]+)?"
                : "(?:over|above|more than|expensive than|min|from|greater than|>|>=|trên|tren|từ|tu)\\s*([0-9]+(?:[.,][0-9]+)*)\\s*([a-zA-Z%]+)?";
        java.util.regex.Matcher m = java.util.regex.Pattern.compile(regex).matcher(qLower);
        while (m.find()) {
            try {
                String numStr = m.group(1);
                String unit = m.group(2) != null ? m.group(2).trim().toLowerCase(java.util.Locale.ROOT) : "";

                // Skip if followed by non-currency measurement units (battery, driver, weight, etc.)
                if (unit.startsWith("hour") || unit.startsWith("hr") || unit.equals("h")
                        || unit.startsWith("gio") || unit.startsWith("giờ") || unit.startsWith("day")
                        || unit.equals("mm") || unit.equals("g") || unit.equals("gram") || unit.equals("kg") || unit.equals("db")) {
                    continue;
                }

                double val;
                if (unit.startsWith("m") || unit.startsWith("tri") || unit.equals("tr")) {
                    val = Double.parseDouble(numStr.replace(",", ".")) * 1_000_000.0;
                } else if (unit.startsWith("k") || unit.startsWith("th")) {
                    val = Double.parseDouble(numStr.replace(",", ".")) * 1_000.0;
                } else if (unit.equals("vnd") || unit.equals("usd") || unit.equals("dong") || unit.equals("d")) {
                    String digitsOnly = numStr.replaceAll("[.,]", "");
                    val = Double.parseDouble(digitsOnly);
                    if (val < 100) val *= 1_000_000.0;
                } else if (unit.isEmpty()) {
                    String digitsOnly = numStr.replaceAll("[.,]", "");
                    val = Double.parseDouble(digitsOnly);
                    if (val >= 10000) {
                        // Full currency amount like 500000, 2000000
                    } else if (qLower.contains("price") || qLower.contains("cost") || qLower.contains("budget")
                            || qLower.contains("giá") || qLower.contains("gia") || qLower.contains("tiền") || qLower.contains("$") || qLower.contains("vnd")) {
                        if (val < 100) {
                            val *= 1_000_000.0;
                        } else {
                            val *= 1_000.0;
                        }
                    } else {
                        // Bare small number without price context or currency unit is NOT a price constraint!
                        continue;
                    }
                } else {
                    continue;
                }
                return val > 0 ? val : null;
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    /**
     * AI Visual Image Search (Backward compatible single-image overload):
     * Analyzes headphone photo and matches visually similar products.
     */
    public Map<String, Object> searchProductsByImage(
            String userNote, String mimeType, String base64Image, Integer customerId, String sessionId) {
        List<String> mimes = mimeType != null ? List.of(mimeType) : List.of("image/jpeg");
        List<String> imgs = base64Image != null ? List.of(base64Image) : List.of();
        return searchProductsByImages(userNote, mimes, imgs, customerId, sessionId, null);
    }

    /**
     * AI Visual Image Search with Multi-Image Support (Up to 4 images):
     * Uses Multi-tier Visual Feature Matching Engine (256-bit dHash, Color Histogram, Aspect Ratio)
     * combined with Gemini Multimodal Vision API to accurately rank catalog products.
     */
    public Map<String, Object> searchProductsByImages(
            String userNote, List<String> mimeTypes, List<String> base64Images,
            Integer customerId, String sessionId, String contextRealPath) {

        syncConfigurationFromDatabase();
        Map<String, Object> result = new HashMap<>();

        List<String> validImages = new ArrayList<>();
        List<String> validMimes = new ArrayList<>();
        if (base64Images != null) {
            for (int i = 0; i < base64Images.size(); i++) {
                String b64 = base64Images.get(i);
                if (b64 != null && !b64.trim().isEmpty()) {
                    validImages.add(b64.trim());
                    String m = (mimeTypes != null && i < mimeTypes.size() && mimeTypes.get(i) != null)
                            ? mimeTypes.get(i).trim() : "image/jpeg";
                    validMimes.add(m);
                    if (validImages.size() >= 4) break; // Maximum 4 images
                }
            }
        }

        if (validImages.isEmpty()) {
            result.put("success", false);
            result.put("reply", "Please select or upload 1 to 4 headphone images for AI analysis.");
            result.put("products", new ArrayList<Map<String, Object>>());
            return result;
        }

        List<Map<String, Object>> allProducts = aiPerformanceDAO.getAllProductsForRecommendation();
        if (allProducts == null || allProducts.isEmpty()) {
            result.put("success", false);
            result.put("reply", "The product catalog is currently updating. Please try again shortly.");
            result.put("products", new ArrayList<Map<String, Object>>());
            return result;
        }

        // Record visual search behavior
        aiPerformanceDAO.recordSearchBehavior(customerId, sessionId,
                "IMAGE_SEARCH (" + validImages.size() + " images): " + (userNote != null && !userNote.isBlank() ? userNote : "Visual Upload"));

        Map<Integer, Double> behaviorScores = aiPerformanceDAO.getProductBehaviorScores();

        // 1. Extract visual fingerprints from all uploaded query images
        List<com.swp391.util.VisualSearchEngine.VisualFingerprint> queryFingerprints = new ArrayList<>();
        for (String b64 : validImages) {
            java.awt.image.BufferedImage bImg = com.swp391.util.VisualSearchEngine.decodeBase64ToImage(b64);
            if (bImg != null) {
                com.swp391.util.VisualSearchEngine.VisualFingerprint qFp = com.swp391.util.VisualSearchEngine.extractFingerprint(bImg);
                if (qFp != null) {
                    queryFingerprints.add(qFp);
                }
            }
        }

        // 2. Measure actual visual feature similarity for each product in the catalog
        Map<Integer, Double> productVisualScores = new HashMap<>();
        for (Map<String, Object> p : allProducts) {
            int pid = (int) p.get("productId");
            String imgUrl = (String) p.get("imageUrl");
            double bestSim = 0.45; // baseline

            if (!queryFingerprints.isEmpty() && imgUrl != null && !imgUrl.isBlank()) {
                com.swp391.util.VisualSearchEngine.VisualFingerprint prodFp =
                        com.swp391.util.VisualSearchEngine.getProductFingerprint(imgUrl, contextRealPath);
                if (prodFp != null) {
                    for (com.swp391.util.VisualSearchEngine.VisualFingerprint qFp : queryFingerprints) {
                        double sim = com.swp391.util.VisualSearchEngine.compareFingerprints(qFp, prodFp);
                        if (sim > bestSim) {
                            bestSim = sim;
                        }
                    }
                }
            }
            productVisualScores.put(pid, bestSim);
        }

        // 3. Query Gemini Multimodal Vision API (if available)
        Map<String, Object> geminiRes = com.swp391.util.GeminiClient.askShoppingAssistantWithImages(
                userNote, validMimes, validImages, allProducts);

        String visualAnalysis = null;
        String adviceReply = null;
        List<Integer> geminiProductIds = new ArrayList<>();

        if (geminiRes != null) {
            visualAnalysis = (String) geminiRes.get("analysis");
            adviceReply = (String) geminiRes.get("reply");
            if (geminiRes.get("productIds") instanceof List<?>) {
                @SuppressWarnings("unchecked")
                List<Integer> pids = (List<Integer>) geminiRes.get("productIds");
                if (pids != null) {
                    geminiProductIds.addAll(pids);
                }
            }
        }

        if (visualAnalysis == null || visualAnalysis.isBlank()) {
            visualAnalysis = "AI Visual Engine analyzed the optical characteristics (Perceptual 256-bit Hash, RGB color spectrum, and form factor) of "
                    + validImages.size() + " image(s) against our store catalog.";
        }
        if (adviceReply == null || adviceReply.isBlank()) {
            adviceReply = "Here are the headphones matching the design, color, and specifications of your uploaded photo(s):";
        }

        // 4. Score and rank products with Visual Similarity as the dominant factor
        List<Map<String, Object>> candidateProducts = new ArrayList<>();
        String noteLower = userNote != null ? userNote.toLowerCase(java.util.Locale.ROOT) : "";

        for (Map<String, Object> p : allProducts) {
            int pid = (int) p.get("productId");
            double visualSim = productVisualScores.getOrDefault(pid, 0.45);
            double beh = behaviorScores.getOrDefault(pid, 0.65);

            // Optional keyword boost if user provided a text note
            String pName = String.valueOf(p.getOrDefault("productName", "")).toLowerCase();
            String bName = String.valueOf(p.getOrDefault("brandName", "")).toLowerCase();
            String cName = String.valueOf(p.getOrDefault("categoryName", "")).toLowerCase();
            boolean keywordMatch = !noteLower.isEmpty() && (pName.contains(noteLower) || bName.contains(noteLower) || cName.contains(noteLower));

            // Gemini recommendation boost
            double geminiBoost = 0.0;
            if (geminiProductIds.contains(pid)) {
                int gRank = geminiProductIds.indexOf(pid);
                geminiBoost = Math.max(0.02, 0.08 - (gRank * 0.015));
            }

            double sim = visualSim;
            if (keywordMatch) {
                sim = Math.min(0.99, sim + 0.05);
            }
            if (geminiBoost > 0) {
                sim = Math.min(0.99, sim + geminiBoost);
            }

            // High-confidence visual match (> 0.90) guarantees top-tier standing (95% - 99%)
            double finalScore;
            String visualTag;
            if (visualSim >= 0.90) {
                finalScore = Math.min(0.99, Math.max(0.95, (0.90 * sim) + (0.10 * beh)));
                visualTag = visualSim >= 0.95 ? "Exact Visual Match" : "High Visual Match";
            } else if (visualSim >= 0.70) {
                finalScore = Math.min(0.91, Math.max(0.75, (0.80 * sim) + (0.20 * beh)));
                visualTag = "Similar Design";
            } else {
                finalScore = Math.min(0.69, Math.max(0.30, sim * (0.80 + 0.10 * beh)));
                visualTag = "Suggested Alternative";
            }

            Map<String, Object> item = new HashMap<>(p);
            item.put("visualSim", round(visualSim, 4));
            item.put("similarityScore", round(sim, 4));
            item.put("behaviorScore", round(beh, 4));
            item.put("finalScore", round(finalScore, 4));
            int matchPct = (int) Math.round(finalScore * 100);
            item.put("matchPercentage", Math.max(30, Math.min(99, matchPct)));
            item.put("visualTag", visualTag);

            candidateProducts.add(item);
        }

        // Sort descending by finalScore
        candidateProducts.sort((a, b) -> {
            Double scoreA = (Double) a.get("finalScore");
            Double scoreB = (Double) b.get("finalScore");
            return Double.compare(scoreB != null ? scoreB : 0.0, scoreA != null ? scoreA : 0.0);
        });

        // 5. Stage 1 = image results (visual similarity >= 0.70 and match >= 60%).
        //    Stage 2 = refine with the user's note.
        final int MIN_MATCH = 60;
        final double IMAGE_FOUND_SIM = 0.70;
        String noteTrim = userNote != null ? userNote.trim() : "";
        IntentCriteria noteCriteria = noteTrim.isEmpty() ? null : extractIntentCriteria(noteTrim, noteLower, allProducts);
        boolean hasNote = noteCriteria != null && hasHardConstraints(noteCriteria);

        List<Map<String, Object>> imageMatches = new ArrayList<>();
        for (Map<String, Object> it : candidateProducts) {
            if ((Double) it.get("visualSim") >= IMAGE_FOUND_SIM && (Integer) it.get("matchPercentage") >= MIN_MATCH) {
                imageMatches.add(it);
            }
        }

        List<Map<String, Object>> finalList = new ArrayList<>();
        if (!hasNote) {
            finalList = imageMatches;
            if (finalList.isEmpty()) {
                adviceReply = "Sorry, no products found with over " + MIN_MATCH + "% visual similarity to the image(s) provided.";
            }
        } else {
            List<Map<String, Object>> imageAndNote = new ArrayList<>();
            for (Map<String, Object> it : imageMatches) {
                if (productMeetsIntent(it, noteCriteria)) imageAndNote.add(it);
            }

            if (!imageAndNote.isEmpty()) {
                finalList = imageAndNote;
                adviceReply = "Found " + imageAndNote.size() + " product(s) matching both your photo(s) and note \"" + noteTrim + "\":";
            } else if (!imageMatches.isEmpty()) {
                finalList = imageMatches;
                adviceReply = "We found products matching your image(s), but none of them satisfy your note \""
                        + noteTrim + "\". Here are the products found by image:";
            } else {
                // No product looks like the image: fall back to products satisfying the note, closest to the image first
                List<Map<String, Object>> noteOnly = new ArrayList<>();
                for (Map<String, Object> it : candidateProducts) {
                    if (productMeetsIntent(it, noteCriteria)) {
                        double vs = (Double) it.get("visualSim");
                        double fs = Math.min(0.89, 0.60 + vs * 0.25);
                        it.put("finalScore", round(fs, 4));
                        it.put("matchPercentage", (int) Math.round(fs * 100));
                        it.put("visualTag", "Matches Note Criteria");
                        noteOnly.add(it);
                    }
                }
                if (!noteOnly.isEmpty()) {
                    noteOnly.sort((a, b) -> Double.compare((Double) b.get("visualSim"), (Double) a.get("visualSim")));
                    finalList = noteOnly;
                    adviceReply = "No products match your uploaded image(s), but we found products satisfying your note \""
                            + noteTrim + "\". Here are the closest options to your image:";
                } else {
                    adviceReply = "Sorry, no products in our store match your request (no products match the image and none satisfy your note \""
                            + noteTrim + "\").";
                }
            }
        }

        // Take Top 6
        List<Map<String, Object>> matchingProducts = new ArrayList<>();
        int limit = Math.min(6, finalList.size());
        for (int i = 0; i < limit; i++) {
            Map<String, Object> item = finalList.get(i);
            int pid = (int) item.get("productId");
            double sim = (Double) item.get("similarityScore");
            double beh = (Double) item.get("behaviorScore");
            double fs = (Double) item.get("finalScore");

            long recId = aiPerformanceDAO.recordAIRecommendation(
                    customerId, sessionId, pid, "AI_IMAGE_SEARCH", sim, beh, fs,
                    "AI Visual Multi-Image Search (" + validImages.size() + " imgs): " + (userNote != null && !userNote.isBlank() ? userNote : "Photo Match"));
            item.put("recommendationId", recId);
            matchingProducts.add(item);
        }

        result.put("success", true);
        result.put("analysis", visualAnalysis);
        result.put("reply", adviceReply);
        result.put("products", matchingProducts);
        return result;
    }

    /** True if the note contains at least one concrete, checkable requirement. */
    private boolean hasHardConstraints(IntentCriteria c) {
        return c.wantHeadphone || c.wantEarbud || c.wantANC || c.wantWaterRes || c.wantWireless || c.wantWired
                || c.wantLightweight || c.wantComfortable || c.minBatteryHours != null || c.maxBatteryHours != null
                || c.maxPriceLimit != null || c.minPriceLimit != null || c.matchedBrand != null;
    }

    /** Strict check of a product against the constraints extracted from the note. */
    private boolean productMeetsIntent(Map<String, Object> p, IntentCriteria c) {
        String pCat = String.valueOf(p.getOrDefault("categoryName", "")).toLowerCase(java.util.Locale.ROOT);
        String pBrand = String.valueOf(p.getOrDefault("brandName", "")).toLowerCase(java.util.Locale.ROOT);
        String pWater = String.valueOf(p.getOrDefault("waterResistance", "None")).trim();
        boolean hasWater = !pWater.equalsIgnoreCase("None") && !pWater.isEmpty();
        boolean pAnc = Boolean.TRUE.equals(p.get("noiseCancelling"));
        double pPrice = p.get("price") instanceof Number ? ((Number) p.get("price")).doubleValue() : 0.0;
        int pBat = p.get("batteryLife") instanceof Number ? ((Number) p.get("batteryLife")).intValue() : 0;
        double pWeight = p.get("weight") instanceof Number ? ((Number) p.get("weight")).doubleValue() : 250.0;
        String pConn = String.valueOf(p.getOrDefault("connectionType", "BLUETOOTH")).toUpperCase(java.util.Locale.ROOT);

        boolean isEarbud = pCat.contains("earbud") || pCat.contains("in-ear");
        boolean isOver = pCat.contains("headphone") || pCat.contains("over-ear");
        if (c.wantHeadphone && !c.wantEarbud && isEarbud) return false;
        if (c.wantEarbud && !c.wantHeadphone && isOver) return false;
        if (c.wantWaterRes && !hasWater) return false;
        if (c.maxPriceLimit != null && pPrice > c.maxPriceLimit * 1.05) return false;
        if (c.minPriceLimit != null && pPrice < c.minPriceLimit * 0.95) return false;
        if (c.minBatteryHours != null && pBat < c.minBatteryHours) return false;
        if (c.maxBatteryHours != null && pBat > c.maxBatteryHours) return false;
        if (c.matchedBrand != null && !pBrand.equalsIgnoreCase(c.matchedBrand)) return false;
        if (c.wantANC && !pAnc) return false;
        if (c.wantLightweight && pWeight > 250.0) return false;
        if (c.wantComfortable && pWeight > 320.0) return false;
        if (c.wantWireless && pConn.contains("WIRED") && !pConn.contains("BLUETOOTH") && !pConn.contains("WIRELESS")) return false;
        if (c.wantWired && (!pConn.contains("WIRED") || pConn.contains("BLUETOOTH"))) return false;
        return true;
    }
}
