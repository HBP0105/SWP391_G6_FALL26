package com.swp391.service;

import com.swp391.dao.AIPerformanceDAO;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Business Service for AI Performance & Configuration Reporting (Screen 4).
 * Handles date validation, AI score metric aggregation, parameter tuning validation,
 * audit logging, and CSV report export.
 * Uses existing Java models and Map/List structures without creating new models.
 */
public class AIPerformanceService {

    private final AIPerformanceDAO aiPerformanceDAO;

    // Default AI Model Configuration Parameters (Stored in-memory, manageable by Admin)
    private static double similarityWeight = 0.50;
    private static double behaviorWeight = 0.50;
    private static double minSimilarityThreshold = 0.60;
    private static int topKLimit = 10;
    private static String fallbackStrategy = "COLD_START";
    private static String algorithmStatus = "ACTIVE";

    public AIPerformanceService() {
        this.aiPerformanceDAO = new AIPerformanceDAO();
    }

    public AIPerformanceService(AIPerformanceDAO aiPerformanceDAO) {
        this.aiPerformanceDAO = aiPerformanceDAO;
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

        // 1. Summary Metrics Map
        Map<String, Object> summary = aiPerformanceDAO.getAIPerformanceSummary(formattedStart, formattedEnd, recommendationType);

        // 2. Breakdown by Recommendation Type
        List<Map<String, Object>> byType = aiPerformanceDAO.getPerformanceByType(formattedStart, formattedEnd);

        // 3. Top Recommended Products
        List<Map<String, Object>> topProducts = aiPerformanceDAO.getTopRecommendedProducts(formattedStart, formattedEnd, 10);

        // 4. Recent Recommendation Logs
        List<Map<String, Object>> recentLogs = aiPerformanceDAO.getRecentRecommendationLogs(formattedStart, formattedEnd, recommendationType, 20);

        // 5. Active AI Model Parameters Map
        Map<String, Object> aiConfig = getAIConfigurationMap();

        // 6. Recent Audit Logs for AI Config Updates
        List<Map<String, Object>> auditLogs = aiPerformanceDAO.getAIAuditLogs(10);

        bundle.put("summary", summary);
        bundle.put("byType", byType);
        bundle.put("topProducts", topProducts);
        bundle.put("recentLogs", recentLogs);
        bundle.put("aiConfig", aiConfig);
        bundle.put("auditLogs", auditLogs);
        bundle.put("selectedStartDate", startDate != null ? startDate : "");
        bundle.put("selectedEndDate", endDate != null ? endDate : "");
        bundle.put("selectedType", recommendationType != null ? recommendationType : "ALL");

        return bundle;
    }

    /**
     * Returns current in-memory AI configuration parameters.
     */
    public Map<String, Object> getAIConfigurationMap() {
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
     * Updates AI Configuration parameters with validation and records change in AuditLogs table.
     */
    public String updateAIConfiguration(double newSimWeight, double newBehWeight, double newMinThreshold, int newTopK, String newFallback, Integer adminStaffId) {
        // Validation
        double weightSum = newSimWeight + newBehWeight;
        if (Math.abs(weightSum - 1.0) > 0.001 && Math.abs(weightSum - 100.0) > 0.1) {
            return "The sum of Similarity Weight and Behavior Weight must equal 1.0 (or 100%)!";
        }

        // Normalize if entered as percentages (e.g. 50 and 50 -> 0.5 and 0.5)
        if (newSimWeight > 1.0 || newBehWeight > 1.0) {
            newSimWeight = newSimWeight / 100.0;
            newBehWeight = newBehWeight / 100.0;
        }

        if (newMinThreshold < 0.0 || newMinThreshold > 1.0) {
            return "Minimum Similarity Threshold must be between 0.0 and 1.0!";
        }

        if (newTopK < 1 || newTopK > 50) {
            return "Recommendation Limit (Top K) must be between 1 and 50!";
        }

        String oldData = String.format("SimWeight=%.2f, BehWeight=%.2f, MinThreshold=%.2f, TopK=%d, Fallback=%s",
                similarityWeight, behaviorWeight, minSimilarityThreshold, topKLimit, fallbackStrategy);

        String newData = String.format("SimWeight=%.2f, BehWeight=%.2f, MinThreshold=%.2f, TopK=%d, Fallback=%s",
                newSimWeight, newBehWeight, newMinThreshold, newTopK, newFallback);

        // Update static configuration variables
        similarityWeight = newSimWeight;
        behaviorWeight = newBehWeight;
        minSimilarityThreshold = newMinThreshold;
        topKLimit = newTopK;
        if (newFallback != null && !newFallback.trim().isEmpty()) {
            fallbackStrategy = newFallback.trim();
        }

        // Insert into database AuditLogs table
        aiPerformanceDAO.insertAuditLog(adminStaffId, "UPDATE_AI_CONFIG", "AI_CONFIG", "GLOBAL", oldData, newData);

        return null; // Success (no error)
    }

    /**
     * Generates CSV export content for AI Performance Report.
     */
    public String generateCSVAIPerformanceReport(String startDate, String endDate, String recommendationType) {
        Map<String, Object> bundle = getAIPerformanceBundle(startDate, endDate, recommendationType);

        @SuppressWarnings("unchecked")
        Map<String, Object> summary = (Map<String, Object>) bundle.get("summary");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> byType = (List<Map<String, Object>>) bundle.get("byType");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> topProducts = (List<Map<String, Object>>) bundle.get("topProducts");

        DecimalFormat numFormatter = new DecimalFormat("#,##0.00");
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setDecimalSeparator('.');
        numFormatter.setDecimalFormatSymbols(symbols);

        StringBuilder sb = new StringBuilder();
        sb.append('\uFEFF'); // UTF-8 BOM for Excel compatibility

        sb.append("\"ADMIN AI PERFORMANCE & CONFIGURATION REPORT\"\n");
        sb.append("\"Report Date:\",\"").append(LocalDate.now()).append("\"\n\n");

        sb.append("\"--- OVERALL METRICS ---\"\n");
        sb.append("\"Total Recommendations Generated\",\"").append(summary.get("totalRecommendations")).append("\"\n");
        sb.append("\"Total Recommendations Clicked\",\"").append(summary.get("totalClicked")).append("\"\n");
        sb.append("\"Total Recommendations Purchased\",\"").append(summary.get("totalPurchased")).append("\"\n");
        sb.append("\"Click-Through Rate (CTR)\",\"").append(summary.get("ctrRate")).append("%\"\n");
        sb.append("\"Conversion Rate\",\"").append(summary.get("conversionRate")).append("%\"\n");
        sb.append("\"Average Similarity Score\",\"").append(summary.get("avgSimilarityScore")).append("\"\n");
        sb.append("\"Average Behavior Score\",\"").append(summary.get("avgBehaviorScore")).append("\"\n");
        sb.append("\"Average Final Score\",\"").append(summary.get("avgFinalScore")).append("\"\n\n");

        sb.append("\"--- PERFORMANCE BY RECOMMENDATION TYPE ---\"\n");
        sb.append("\"Type\",\"Total Recommendations\",\"Clicked\",\"Purchased\",\"CTR (%)\",\"Conversion Rate (%)\",\"Avg Final Score\"\n");
        for (Map<String, Object> row : byType) {
            sb.append("\"").append(row.get("recommendationType")).append("\",");
            sb.append("\"").append(row.get("totalCount")).append("\",");
            sb.append("\"").append(row.get("clickedCount")).append("\",");
            sb.append("\"").append(row.get("purchasedCount")).append("\",");
            sb.append("\"").append(row.get("ctrRate")).append("%\",");
            sb.append("\"").append(row.get("conversionRate")).append("%\",");
            sb.append("\"").append(row.get("avgScore")).append("\"\n");
        }
        sb.append("\n");

        sb.append("\"--- TOP RECOMMENDED PRODUCTS ---\"\n");
        sb.append("\"Product ID\",\"Product Name\",\"Category\",\"Brand\",\"Recommend Count\",\"Clicked\",\"Purchased\",\"CTR (%)\",\"Conversion (%)\"\n");
        for (Map<String, Object> p : topProducts) {
            sb.append("\"").append(p.get("productID")).append("\",");
            sb.append("\"").append(escapeCSV((String) p.get("productName"))).append("\",");
            sb.append("\"").append(escapeCSV((String) p.get("categoryName"))).append("\",");
            sb.append("\"").append(escapeCSV((String) p.get("brandName"))).append("\",");
            sb.append("\"").append(p.get("recommendCount")).append("\",");
            sb.append("\"").append(p.get("clickedCount")).append("\",");
            sb.append("\"").append(p.get("purchasedCount")).append("\",");
            sb.append("\"").append(p.get("ctrRate")).append("%\",");
            sb.append("\"").append(p.get("conversionRate")).append("%\"\n");
        }

        return sb.toString();
    }

    private String escapeCSV(String value) {
        if (value == null) return "";
        String clean = value.replace("\"", "\"\"");
        if (clean.startsWith("=") || clean.startsWith("+") || clean.startsWith("-") 
                || clean.startsWith("@") || clean.startsWith("\t") || clean.startsWith("\r")) {
            clean = "'" + clean;
        }
        return clean;
    }
}
