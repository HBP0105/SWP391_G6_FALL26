package com.swp391.dao;

import com.swp391.model.AIRecommendation;
import com.swp391.util.DBContext;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Data Access Object executing SQL queries for AI Performance & Configuration Reporting (Screen 4).
 * Uses existing database schema tables (AIRecommendations, UserBehaviors, AuditLogs, Products, Categories, Brands).
 * Returns standard Java Map/List objects and existing AIRecommendation models.
 */
public class AIPerformanceDAO {

    private static final Logger LOGGER = Logger.getLogger(AIPerformanceDAO.class.getName());
    private final DBContext dbContext;

    public AIPerformanceDAO() {
        this.dbContext = new DBContext();
    }

    public AIPerformanceDAO(DBContext dbContext) {
        this.dbContext = dbContext;
    }

    private void applyDateConditions(StringBuilder sql, List<Object> params, 
            String formattedStartDate, String formattedEndDate, String dateColumn) {
        if (formattedStartDate != null && !formattedStartDate.trim().isEmpty()) {
            sql.append(" AND ").append(dateColumn).append(" >= ?");
            params.add(formattedStartDate);
        }
        if (formattedEndDate != null && !formattedEndDate.trim().isEmpty()) {
            if (formattedEndDate.endsWith(" 00:00:00")) {
                sql.append(" AND ").append(dateColumn).append(" < ?");
            } else {
                sql.append(" AND ").append(dateColumn).append(" <= ?");
            }
            params.add(formattedEndDate);
        }
    }

    /**
     * Aggregates overall AI performance metrics (Total Recommendations, Clicks, Purchases, CTR, Conversion Rate, Avg Scores).
     */
    public Map<String, Object> getAIPerformanceSummary(String startDate, String endDate, String recommendationType) {
        Map<String, Object> summary = new HashMap<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ");
        sql.append("  COUNT(*) AS totalRecommendations, ");
        sql.append("  SUM(CASE WHEN IsClicked = 1 THEN 1 ELSE 0 END) AS totalClicked, ");
        sql.append("  SUM(CASE WHEN IsPurchased = 1 THEN 1 ELSE 0 END) AS totalPurchased, ");
        sql.append("  AVG(CAST(SimilarityScore AS FLOAT)) AS avgSimilarityScore, ");
        sql.append("  AVG(CAST(BehaviorScore AS FLOAT)) AS avgBehaviorScore, ");
        sql.append("  AVG(CAST(FinalScore AS FLOAT)) AS avgFinalScore ");
        sql.append("FROM AIRecommendations ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        applyDateConditions(sql, params, startDate, endDate, "CreatedAt");

        if (recommendationType != null && !recommendationType.trim().isEmpty() && !"ALL".equalsIgnoreCase(recommendationType)) {
            sql.append("AND RecommendationType = ? ");
            params.add(recommendationType.trim());
        }

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    long totalRecs = rs.getLong("totalRecommendations");
                    long totalClicked = rs.getLong("totalClicked");
                    long totalPurchased = rs.getLong("totalPurchased");

                    double avgSim = rs.getDouble("avgSimilarityScore");
                    double avgBeh = rs.getDouble("avgBehaviorScore");
                    double avgFinal = rs.getDouble("avgFinalScore");

                    double ctrRate = totalRecs > 0 ? (totalClicked * 100.0 / totalRecs) : 0.0;
                    double conversionRate = totalRecs > 0 ? (totalPurchased * 100.0 / totalRecs) : 0.0;
                    double clickToPurchaseRate = totalClicked > 0 ? (totalPurchased * 100.0 / totalClicked) : 0.0;

                    summary.put("totalRecommendations", totalRecs);
                    summary.put("totalClicked", totalClicked);
                    summary.put("totalPurchased", totalPurchased);

                    summary.put("ctrRate", round(ctrRate, 2));
                    summary.put("conversionRate", round(conversionRate, 2));
                    summary.put("clickToPurchaseRate", round(clickToPurchaseRate, 2));

                    summary.put("avgSimilarityScore", round(avgSim, 4));
                    summary.put("avgBehaviorScore", round(avgBeh, 4));
                    summary.put("avgFinalScore", round(avgFinal, 4));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getAIPerformanceSummary", e);
            summary.put("totalRecommendations", 0L);
            summary.put("totalClicked", 0L);
            summary.put("totalPurchased", 0L);
            summary.put("ctrRate", 0.0);
            summary.put("conversionRate", 0.0);
            summary.put("clickToPurchaseRate", 0.0);
            summary.put("avgSimilarityScore", 0.0);
            summary.put("avgBehaviorScore", 0.0);
            summary.put("avgFinalScore", 0.0);
        }

        return summary;
    }

    /**
     * Gets breakdown of recommendations, clicks, purchases, CTR, and conversion rate grouped by RecommendationType.
     */
    public List<Map<String, Object>> getPerformanceByType(String startDate, String endDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ");
        sql.append("  RecommendationType, ");
        sql.append("  COUNT(*) AS totalCount, ");
        sql.append("  SUM(CASE WHEN IsClicked = 1 THEN 1 ELSE 0 END) AS clickedCount, ");
        sql.append("  SUM(CASE WHEN IsPurchased = 1 THEN 1 ELSE 0 END) AS purchasedCount, ");
        sql.append("  AVG(CAST(FinalScore AS FLOAT)) AS avgScore ");
        sql.append("FROM AIRecommendations ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        applyDateConditions(sql, params, startDate, endDate, "CreatedAt");

        sql.append("GROUP BY RecommendationType ");
        sql.append("ORDER BY totalCount DESC");

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    String type = rs.getString("RecommendationType");
                    long total = rs.getLong("totalCount");
                    long clicked = rs.getLong("clickedCount");
                    long purchased = rs.getLong("purchasedCount");
                    double avgScore = rs.getDouble("avgScore");

                    double ctr = total > 0 ? (clicked * 100.0 / total) : 0.0;
                    double conv = total > 0 ? (purchased * 100.0 / total) : 0.0;

                    map.put("recommendationType", type);
                    map.put("totalCount", total);
                    map.put("clickedCount", clicked);
                    map.put("purchasedCount", purchased);
                    map.put("ctrRate", round(ctr, 2));
                    map.put("conversionRate", round(conv, 2));
                    map.put("avgScore", round(avgScore, 4));

                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getPerformanceByType", e);
        }

        return list;
    }

    /**
     * Retrieves top recommended products with recommendation count, CTR, conversion rate and product details.
     */
    public List<Map<String, Object>> getTopRecommendedProducts(String startDate, String endDate, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT TOP (?) ");
        sql.append("  p.ProductID, ");
        sql.append("  p.ProductName, ");
        sql.append("  c.CategoryName, ");
        sql.append("  b.BrandName, ");
        sql.append("  p.Price, ");
        sql.append("  COUNT(r.RecommendationID) AS recommendCount, ");
        sql.append("  SUM(CASE WHEN r.IsClicked = 1 THEN 1 ELSE 0 END) AS clickedCount, ");
        sql.append("  SUM(CASE WHEN r.IsPurchased = 1 THEN 1 ELSE 0 END) AS purchasedCount, ");
        sql.append("  AVG(CAST(r.FinalScore AS FLOAT)) AS avgFinalScore ");
        sql.append("FROM AIRecommendations r ");
        sql.append("JOIN Products p ON r.ProductID = p.ProductID ");
        sql.append("JOIN Categories c ON p.CategoryID = c.CategoryID ");
        sql.append("JOIN Brands b ON p.BrandID = b.BrandID ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        params.add(limit);
        applyDateConditions(sql, params, startDate, endDate, "r.CreatedAt");

        sql.append("GROUP BY p.ProductID, p.ProductName, c.CategoryName, b.BrandName, p.Price ");
        sql.append("ORDER BY recommendCount DESC, clickedCount DESC");

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    long total = rs.getLong("recommendCount");
                    long clicked = rs.getLong("clickedCount");
                    long purchased = rs.getLong("purchasedCount");
                    double ctr = total > 0 ? (clicked * 100.0 / total) : 0.0;
                    double conv = total > 0 ? (purchased * 100.0 / total) : 0.0;

                    map.put("productID", rs.getInt("ProductID"));
                    map.put("productName", rs.getString("ProductName"));
                    map.put("categoryName", rs.getString("CategoryName"));
                    map.put("brandName", rs.getString("BrandName"));
                    map.put("price", rs.getBigDecimal("Price"));
                    map.put("recommendCount", total);
                    map.put("clickedCount", clicked);
                    map.put("purchasedCount", purchased);
                    map.put("ctrRate", round(ctr, 2));
                    map.put("conversionRate", round(conv, 2));
                    map.put("avgFinalScore", round(rs.getDouble("avgFinalScore"), 4));

                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getTopRecommendedProducts", e);
        }

        return list;
    }

    /**
     * Retrieves recent AI Recommendations using existing model AIRecommendation & details.
     */
    public List<Map<String, Object>> getRecentRecommendationLogs(String startDate, String endDate, String recommendationType, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT TOP (?) ");
        sql.append("  r.RecommendationID, r.CustomerID, r.SessionID, r.ProductID, ");
        sql.append("  r.RecommendationType, r.SimilarityScore, r.BehaviorScore, ");
        sql.append("  r.FinalScore, r.Reason, r.IsClicked, r.IsPurchased, r.CreatedAt, ");
        sql.append("  p.ProductName, c.FullName AS CustomerName ");
        sql.append("FROM AIRecommendations r ");
        sql.append("JOIN Products p ON r.ProductID = p.ProductID ");
        sql.append("LEFT JOIN Customers c ON r.CustomerID = c.CustomerID ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        params.add(limit);

        applyDateConditions(sql, params, startDate, endDate, "r.CreatedAt");

        if (recommendationType != null && !recommendationType.trim().isEmpty() && !"ALL".equalsIgnoreCase(recommendationType)) {
            sql.append("AND r.RecommendationType = ? ");
            params.add(recommendationType.trim());
        }

        sql.append("ORDER BY r.CreatedAt DESC");

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AIRecommendation rec = new AIRecommendation();
                    rec.setRecommendationID(rs.getLong("RecommendationID"));
                    int cid = rs.getInt("CustomerID");
                    rec.setCustomerID(rs.wasNull() ? null : cid);
                    rec.setSessionID(rs.getString("SessionID"));
                    rec.setProductID(rs.getInt("ProductID"));
                    rec.setRecommendationType(rs.getString("RecommendationType"));
                    rec.setSimilarityScore(rs.getBigDecimal("SimilarityScore"));
                    rec.setBehaviorScore(rs.getBigDecimal("BehaviorScore"));
                    rec.setFinalScore(rs.getBigDecimal("FinalScore"));
                    rec.setReason(rs.getString("Reason"));
                    rec.setClicked(rs.getBoolean("IsClicked"));
                    rec.setPurchased(rs.getBoolean("IsPurchased"));
                    if (rs.getTimestamp("CreatedAt") != null) {
                        rec.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
                    }

                    Map<String, Object> map = new HashMap<>();
                    map.put("recommendation", rec);
                    map.put("productName", rs.getString("ProductName"));
                    map.put("customerName", rs.getString("CustomerName") != null ? rs.getString("CustomerName") : "Guest User");

                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getRecentRecommendationLogs", e);
        }

        return list;
    }

    /**
     * Inserts an audit log entry for AI configuration changes.
     */
    public boolean insertAuditLog(Integer staffID, String action, String entityName, String entityID, String oldData, String newData) {
        String sql = "INSERT INTO AuditLogs (StaffID, Action, EntityName, EntityID, OldData, NewData, CreatedAt) VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (staffID != null) {
                ps.setInt(1, staffID);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }

            ps.setString(2, action);
            ps.setString(3, entityName);
            ps.setString(4, entityID);
            ps.setString(5, oldData);
            ps.setString(6, newData);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing insertAuditLog", e);
            return false;
        }
    }

    /**
     * Retrieves recent AI audit log entries.
     */
    public List<Map<String, Object>> getAIAuditLogs(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (?) a.*, s.FullName FROM AuditLogs a LEFT JOIN Staff s ON a.StaffID = s.StaffID WHERE a.EntityName = 'AI_CONFIG' OR a.Action LIKE '%AI%' ORDER BY a.CreatedAt DESC";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("auditLogID", rs.getLong("AuditLogID"));
                    map.put("action", rs.getString("Action"));
                    map.put("entityName", rs.getString("EntityName"));
                    map.put("entityID", rs.getString("EntityID"));
                    map.put("oldData", rs.getString("OldData"));
                    map.put("newData", rs.getString("NewData"));
                    if (rs.getTimestamp("CreatedAt") != null) {
                        map.put("createdAt", rs.getTimestamp("CreatedAt").toLocalDateTime());
                    }
                    map.put("userName", rs.getString("FullName") != null ? rs.getString("FullName") : "System Admin");
                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getAIAuditLogs", e);
        }

        return list;
    }

    private double round(double value, int places) {
        if (places < 0) throw new IllegalArgumentException();
        BigDecimal bd = BigDecimal.valueOf(value);
        bd = bd.setScale(places, RoundingMode.HALF_UP);
        return bd.doubleValue();
    }
}
