package com.swp391.service.Admin;

import com.swp391.dao.Admin.BehaviorDAO;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Business Service handling operations for Customer Behavior Data Pipeline Dashboard (Screen 5).
 * Aggregates user behavior events, computes ingestion rates, and coordinates CSV exports.
 */
public class BehaviorService {

    private static final Logger LOGGER = Logger.getLogger(BehaviorService.class.getName());
    private final BehaviorDAO behaviorDAO;

    public BehaviorService() {
        this.behaviorDAO = new BehaviorDAO();
    }

    public BehaviorService(BehaviorDAO behaviorDAO) {
        this.behaviorDAO = behaviorDAO;
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
     * Bundles all data needed for Screen 5 (Behavior Pipeline View).
     */
    public Map<String, Object> getBehaviorPipelineBundle(String startDate, String endDate, String behaviorType) {
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
            // 1. Behavior Summary KPIs
            Map<String, Object> summary = behaviorDAO.getBehaviorSummary(formattedStart, formattedEnd, behaviorType);
            calculateBehaviorSummaryMetrics(summary);

            // 2. Distribution by Behavior Type (Doughnut Chart)
            List<Map<String, Object>> typeDistribution = behaviorDAO.getBehaviorTypeDistribution(formattedStart, formattedEnd);

            // 3. Daily Ingestion Trend (Bar Chart)
            List<Map<String, Object>> dailyTrend = behaviorDAO.getDailyIngestionTrend(formattedStart, formattedEnd);

            // 4. Top Searched Keywords
            List<Map<String, Object>> topKeywords = behaviorDAO.getTopSearchedKeywords(formattedStart, formattedEnd, 5);

            // 5. Recent Behavior Stream Logs
            List<Map<String, Object>> streamLogs = behaviorDAO.getRecentBehaviorLogs(formattedStart, formattedEnd, behaviorType, 25);

            bundle.put("summary", summary);
            bundle.put("typeDistribution", typeDistribution);
            bundle.put("dailyTrend", dailyTrend);
            bundle.put("topKeywords", topKeywords);
            bundle.put("streamLogs", streamLogs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error querying behavior stream data from database", e);
            bundle.put("msgError", "Failed to connect or load customer behavior data from database. Please verify SQL Server connection!");
            bundle.put("summary", new HashMap<String, Object>());
            bundle.put("typeDistribution", new ArrayList<Map<String, Object>>());
            bundle.put("dailyTrend", new ArrayList<Map<String, Object>>());
            bundle.put("topKeywords", new ArrayList<Map<String, Object>>());
            bundle.put("streamLogs", new ArrayList<Map<String, Object>>());
        }

        bundle.put("selectedStartDate", startDate != null ? startDate : "");
        bundle.put("selectedEndDate", endDate != null ? endDate : "");
        bundle.put("selectedType", behaviorType != null ? behaviorType : "ALL");

        return bundle;
    }

    /**
     * Business Calculation: Compute Cart-to-Purchase Funnel conversion rate and View-to-Cart rate.
     */
    private void calculateBehaviorSummaryMetrics(Map<String, Object> summary) {
        if (summary == null || summary.isEmpty()) return;
        long totalCarts = (long) summary.getOrDefault("totalCarts", 0L);
        long totalPurchases = (long) summary.getOrDefault("totalPurchases", 0L);
        long totalViews = (long) summary.getOrDefault("totalViews", 0L);
        long cartSessions = (long) summary.getOrDefault("cartSessions", 0L);
        long convertedSessions = (long) summary.getOrDefault("convertedSessions", 0L);

        double cartToPurchaseRate;
        if (cartSessions > 0 && convertedSessions > 0) {
            cartToPurchaseRate = (convertedSessions * 100.0 / cartSessions);
        } else if (totalCarts > 0 && totalPurchases > 0) {
            cartToPurchaseRate = Math.min(100.0, totalPurchases * 100.0 / totalCarts);
        } else {
            cartToPurchaseRate = 0.0;
        }

        double viewToCartRate = totalViews > 0 ? (totalCarts * 100.0 / totalViews) : 0.0;

        summary.put("cartToPurchaseRate", Math.round(cartToPurchaseRate * 10.0) / 10.0);
        summary.put("viewToCartRate", Math.round(viewToCartRate * 10.0) / 10.0);
    }
}
