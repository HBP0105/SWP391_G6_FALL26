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
        String text = String.format("Product: %s. Brand: %s. Category: %s. Connection: %s. ANC: %s. Battery: %s hrs. Price: %s. %s",
                p.getOrDefault("productName", ""),
                p.getOrDefault("brandName", ""),
                p.getOrDefault("categoryName", ""),
                p.getOrDefault("connectionType", ""),
                Boolean.TRUE.equals(p.get("noiseCancelling")) ? "Active Noise Cancelling ANC" : "Standard",
                p.getOrDefault("batteryLife", "30"),
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

        // 0. Try Google Gemini AI first (RAG over active product catalog)
        if (!query.isEmpty()) {
            Map<String, Object> geminiRes = com.swp391.util.GeminiClient.askShoppingAssistantWithGemini(query, allProducts);
            if (geminiRes != null && geminiRes.get("reply") != null) {
                @SuppressWarnings("unchecked")
                List<Integer> geminiIds = (List<Integer>) geminiRes.get("productIds");
                List<Map<String, Object>> geminiPicks = new ArrayList<>();
                if (geminiIds != null && !geminiIds.isEmpty()) {
                    for (Integer gid : geminiIds) {
                        for (Map<String, Object> p : allProducts) {
                            if (gid.equals(p.get("productId"))) {
                                Map<String, Object> item = new HashMap<>(p);
                                double sim = 0.92;
                                double beh = behaviorScores.getOrDefault(gid, 0.75);
                                double fs = Math.min(0.99, (similarityWeight * sim) + (behaviorWeight * beh));
                                item.put("similarityScore", round(sim, 4));
                                item.put("behaviorScore", round(beh, 4));
                                item.put("finalScore", round(fs, 4));
                                item.put("matchPercentage", Math.max(80, Math.min(99, (int) Math.round(fs * 100))));
                                long recId = aiPerformanceDAO.recordAIRecommendation(
                                        customerId, sessionId, gid, "AI_CHAT", sim, beh, fs,
                                        "Gemini AI Assistant: " + (query.length() > 80 ? query.substring(0, 80) : query));
                                item.put("recommendationId", recId);
                                geminiPicks.add(item);
                                break;
                            }
                        }
                    }
                }
                // Return Gemini response (even if product list is empty because user query is out of scope)
                responseMap.put("reply", geminiRes.get("reply"));
                responseMap.put("products", geminiPicks);
                return responseMap;
            }
        }

        // 1. Guard against empty / gibberish / small talk / off-topic queries in local fallback
        if (isOutOfScopeOrGibberish(query, qLower)) {
            responseMap.put("reply", "I am an AI shopping assistant dedicated to audio products. I cannot answer social, off-topic, or non-shopping inquiries. Please ask me about buying headphones, earbuds, or audio gear (e.g., budget, noise cancelling, battery life, brand).");
            responseMap.put("products", new ArrayList<Map<String, Object>>());
            return responseMap;
        }

        // 2. Extract semantic intents from query
        boolean wantHeadphone = qLower.contains("headphone") || qLower.contains("over-ear") || qLower.contains("over ear")
                || qLower.contains("on-ear") || qLower.contains("headset") || qLower.contains("studio") || qLower.contains("chụp tai");
        boolean wantEarbud = qLower.contains("earbud") || qLower.contains("in-ear") || qLower.contains("in ear")
                || qLower.contains("tws") || qLower.contains("earphone") || qLower.contains("airpod") || qLower.contains("nhét tai");

        boolean wantANC = qLower.contains("anc") || qLower.contains("noise") || qLower.contains("quiet")
                || qLower.contains("study") || qLower.contains("flight") || qLower.contains("airplane")
                || qLower.contains("office") || qLower.contains("isolation") || qLower.contains("chống ồn");
        boolean wantBattery = qLower.contains("battery") || qLower.contains("long life") || qLower.contains("hours")
                || qLower.contains("all day") || qLower.contains("travel") || qLower.contains("pin");
        boolean wantSport = qLower.contains("sport") || qLower.contains("gym") || qLower.contains("run")
                || qLower.contains("workout") || qLower.contains("exercise") || qLower.contains("water")
                || qLower.contains("sweat") || qLower.contains("ipx") || qLower.contains("thể thao");
        boolean wantGamingOrCalls = qLower.contains("game") || qLower.contains("gaming") || qLower.contains("mic")
                || qLower.contains("call") || qLower.contains("meeting") || qLower.contains("zoom") || qLower.contains("voice");
        boolean wantWireless = qLower.contains("wireless") || qLower.contains("bluetooth") || qLower.contains("cordless") || qLower.contains("không dây");
        boolean wantWired = qLower.contains("wired") || qLower.contains("cable") || qLower.contains("3.5mm") || qLower.contains("có dây");
        boolean wantBudget = qLower.contains("cheap") || qLower.contains("budget") || qLower.contains("affordable")
                || qLower.contains("low price") || qLower.contains("inexpensive") || qLower.contains("giá rẻ");
        boolean wantPremium = qLower.contains("premium") || qLower.contains("luxury") || qLower.contains("high-end")
                || qLower.contains("high end") || qLower.contains("flagship") || qLower.contains("best") || qLower.contains("pro") || qLower.contains("cao cấp");

        // Extract price limit if mentioned (e.g. "under 3000000", "below 2m", "under 2.5 million", "< 1500k")
        Double maxPriceLimit = extractPriceConstraint(qLower, true);
        Double minPriceLimit = extractPriceConstraint(qLower, false);

        // Extract brand if mentioned
        String matchedBrand = null;
        for (Map<String, Object> p : allProducts) {
            String bName = (String) p.get("brandName");
            if (bName != null && !bName.isEmpty() && qLower.contains(bName.toLowerCase(java.util.Locale.ROOT))) {
                matchedBrand = bName;
                break;
            }
        }

        // Tokenize query for keyword matching
        String[] rawTokens = qLower.replaceAll("[^a-z0-9\\u00C0-\\u1EF9\\s]", " ").split("\\s+");
        List<String> keywords = new ArrayList<>();
        List<String> stopWords = java.util.Arrays.asList(
                "i", "want", "need", "looking", "for", "a", "an", "the", "me", "find", "show", "recommend",
                "suggest", "some", "good", "with", "and", "or", "to", "in", "on", "of", "under", "below",
                "over", "above", "around", "about", "can", "you", "please", "what", "is", "are", "which", "buy"
        );
        for (String tk : rawTokens) {
            if (tk.length() >= 2 && !stopWords.contains(tk) && !tk.matches("^\\d+$")) {
                keywords.add(tk);
            }
        }

        // Construct synthetic query product map to generate 512-D Query Vector
        Map<String, Object> syntheticQueryMap = new HashMap<>();
        syntheticQueryMap.put("productName", query);
        syntheticQueryMap.put("brandName", matchedBrand != null ? matchedBrand : "");
        syntheticQueryMap.put("categoryName", wantHeadphone ? "Headphones" : (wantEarbud ? "Earbuds" : "Audio"));
        syntheticQueryMap.put("connectionType", wantWired ? "Wired" : "Wireless Bluetooth");
        syntheticQueryMap.put("noiseCancelling", wantANC);
        syntheticQueryMap.put("batteryLife", wantBattery ? 40 : 24);
        syntheticQueryMap.put("price", maxPriceLimit != null ? maxPriceLimit.longValue() : 2000000);
        syntheticQueryMap.put("description", query);
        double[] queryVec = generateProduct512Vector(syntheticQueryMap);

        // Score all candidate products
        List<Map<String, Object>> scoredProducts = new ArrayList<>();
        for (Map<String, Object> p : allProducts) {
            int pid = (int) p.get("productId");
            String pName = ((String) p.getOrDefault("productName", "")).toLowerCase(java.util.Locale.ROOT);
            String pCat = ((String) p.getOrDefault("categoryName", "")).toLowerCase(java.util.Locale.ROOT);
            String pBrand = ((String) p.getOrDefault("brandName", "")).toLowerCase(java.util.Locale.ROOT);
            String pConn = ((String) p.getOrDefault("connectionType", "")).toLowerCase(java.util.Locale.ROOT);
            String pDesc = ((String) p.getOrDefault("description", "")).toLowerCase(java.util.Locale.ROOT);
            boolean pAnc = Boolean.TRUE.equals(p.get("noiseCancelling"));
            int pBattery = p.get("batteryLife") instanceof Number ? ((Number) p.get("batteryLife")).intValue() : 0;
            double pPrice = p.get("price") instanceof Number ? ((Number) p.get("price")).doubleValue() : 0.0;

            // Price constraint filtering
            if (maxPriceLimit != null && pPrice > maxPriceLimit * 1.05) {
                continue;
            }
            if (minPriceLimit != null && pPrice < minPriceLimit * 0.95) {
                continue;
            }

            // Category constraint filtering if strongly specified
            if (wantHeadphone && !wantEarbud && (pCat.contains("earbud") || pCat.contains("in-ear"))) {
                continue;
            }
            if (wantEarbud && !wantHeadphone && (pCat.contains("headphone") || pCat.contains("over-ear"))) {
                continue;
            }

            // Brand constraint filtering if specified
            if (matchedBrand != null && !pBrand.equalsIgnoreCase(matchedBrand)) {
                continue;
            }

            double[] pVec = parseOrGenerateVector(p);
            double vectorSim = calculateCosineSimilarity(queryVec, pVec);

            // Calculate semantic feature & keyword match score
            double intentScore = 0.55;
            if (matchedBrand != null && pBrand.equalsIgnoreCase(matchedBrand)) intentScore += 0.25;
            if (wantHeadphone && pCat.contains("headphone")) intentScore += 0.18;
            if (wantEarbud && pCat.contains("earbud")) intentScore += 0.18;
            if (wantANC) {
                intentScore += pAnc ? 0.22 : -0.15;
            }
            if (wantBattery) {
                intentScore += (pBattery >= 30) ? 0.18 : (pBattery >= 20 ? 0.08 : -0.05);
            }
            if (wantSport && (pCat.contains("earbud") || pDesc.contains("water") || pDesc.contains("sport") || pDesc.contains("ipx"))) {
                intentScore += 0.18;
            }
            if (wantGamingOrCalls && (pDesc.contains("mic") || pDesc.contains("call") || pDesc.contains("game") || pName.contains("gaming"))) {
                intentScore += 0.15;
            }
            if (wantWireless && (pConn.contains("wireless") || pConn.contains("bluetooth"))) intentScore += 0.12;
            if (wantWired && pConn.contains("wired")) intentScore += 0.18;
            if (wantBudget && pPrice <= 2000000) intentScore += 0.16;
            if (wantPremium && pPrice >= 3000000) intentScore += 0.16;

            int matchedKwCount = 0;
            for (String kw : keywords) {
                if (pName.contains(kw)) {
                    intentScore += 0.22;
                    matchedKwCount++;
                } else if (pBrand.contains(kw) || pCat.contains(kw)) {
                    intentScore += 0.14;
                    matchedKwCount++;
                } else if (pDesc.contains(kw)) {
                    intentScore += 0.08;
                    matchedKwCount++;
                }
            }

            double combinedSim = Math.min(0.99, Math.max(0.50, (vectorSim * 0.35) + (Math.min(1.0, intentScore) * 0.65)));
            double behScore = behaviorScores.getOrDefault(pid, 0.55);
            double finalScore = (similarityWeight * combinedSim) + (behaviorWeight * behScore);
            finalScore = Math.max(0.50, Math.min(0.99, finalScore));

            Map<String, Object> item = new HashMap<>(p);
            item.put("similarityScore", round(combinedSim, 4));
            item.put("behaviorScore", round(behScore, 4));
            item.put("finalScore", round(finalScore, 4));
            item.put("matchPercentage", Math.max(65, Math.min(99, (int) Math.round(finalScore * 100))));
            item.put("matchedKwCount", matchedKwCount);
            scoredProducts.add(item);
        }

        // Fallback if strict constraints filtered everything out
        boolean usedRelaxedFallback = false;
        if (scoredProducts.isEmpty()) {
            usedRelaxedFallback = true;
            for (Map<String, Object> p : allProducts) {
                int pid = (int) p.get("productId");
                double[] pVec = parseOrGenerateVector(p);
                double sim = Math.max(0.60, calculateCosineSimilarity(queryVec, pVec));
                double beh = behaviorScores.getOrDefault(pid, 0.55);
                double fs = (similarityWeight * sim) + (behaviorWeight * beh);
                Map<String, Object> item = new HashMap<>(p);
                item.put("similarityScore", round(sim, 4));
                item.put("behaviorScore", round(beh, 4));
                item.put("finalScore", round(fs, 4));
                item.put("matchPercentage", Math.max(65, Math.min(95, (int) Math.round(fs * 100))));
                scoredProducts.add(item);
            }
        }

        // Sort by budget/premium preference if requested, otherwise by finalScore descending
        scoredProducts.sort((a, b) -> {
            int cmp = Double.compare((double) b.get("finalScore"), (double) a.get("finalScore"));
            if (cmp != 0) return cmp;
            double pa = ((Number) a.get("price")).doubleValue();
            double pb = ((Number) b.get("price")).doubleValue();
            return wantBudget ? Double.compare(pa, pb) : Double.compare(pb, pa);
        });

        int limit = Math.min(4, scoredProducts.size());
        List<Map<String, Object>> topPicks = new ArrayList<>();
        for (int i = 0; i < limit; i++) {
            Map<String, Object> item = scoredProducts.get(i);
            int pid = (int) item.get("productId");
            double sim = (double) item.get("similarityScore");
            double beh = (double) item.get("behaviorScore");
            double fs = (double) item.get("finalScore");
            long recId = aiPerformanceDAO.recordAIRecommendation(
                    customerId, sessionId, pid, "AI_CHAT", sim, beh, fs,
                    "AI Chatbot Query: " + (query.length() > 80 ? query.substring(0, 80) : query));
            item.put("recommendationId", recId);
            topPicks.add(item);
        }

        // Build natural English AI response
        StringBuilder reply = new StringBuilder();
        if (usedRelaxedFallback) {
            reply.append("I couldn't find an exact match for all of those specific constraints, but based on our 512-D semantic analysis, here are the closest headphones and earbuds you might love:");
        } else {
            List<String> criteriaParts = new ArrayList<>();
            if (matchedBrand != null) criteriaParts.add(matchedBrand);
            if (wantHeadphone && !wantEarbud) criteriaParts.add("over-ear/on-ear headphones");
            else if (wantEarbud && !wantHeadphone) criteriaParts.add("compact earbuds");
            else criteriaParts.add("audio products");

            if (wantANC) criteriaParts.add("with Active Noise Cancelling (ANC)");
            if (wantBattery) criteriaParts.add("with long battery life");
            if (wantSport) criteriaParts.add("great for workouts & sports");
            if (wantGamingOrCalls) criteriaParts.add("ideal for calls & gaming");
            if (maxPriceLimit != null) {
                criteriaParts.add("under " + String.format("%,d", maxPriceLimit.longValue()) + " VND");
            } else if (wantBudget) {
                criteriaParts.add("at a budget-friendly price");
            } else if (wantPremium) {
                criteriaParts.add("in our premium lineup");
            }

            reply.append("Based on your request, I analyzed our catalog and found the best ")
                 .append(String.join(" ", criteriaParts))
                 .append(" for you:");
        }

        responseMap.put("reply", reply.toString());
        responseMap.put("products", topPicks);
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

    private Double extractPriceConstraint(String qLower, boolean isMaxLimit) {
        // Detects patterns like "under 3m", "below 2,000,000", "less than 1.5tr", "over 3000000"
        String regex = isMaxLimit
                ? "(?:under|below|less than|max|up to|budget|around|duoi|<|<=)\\s*([0-9]+(?:[.,][0-9]+)*)\\s*(m|million|tr|trieu|k|thousand|vnd|d)?"
                : "(?:over|above|more than|min|from|tren|>|>=)\\s*([0-9]+(?:[.,][0-9]+)*)\\s*(m|million|tr|trieu|k|thousand|vnd|d)?";
        java.util.regex.Matcher m = java.util.regex.Pattern.compile(regex).matcher(qLower);
        if (m.find()) {
            try {
                String numStr = m.group(1);
                String unit = m.group(2) != null ? m.group(2).trim() : "";
                double val;
                if (unit.startsWith("m") || unit.startsWith("tr")) {
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
                return val > 0 ? val : null;
            } catch (Exception ignored) {
            }
        }
        return null;
    }
}
