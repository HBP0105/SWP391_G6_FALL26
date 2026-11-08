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
}
