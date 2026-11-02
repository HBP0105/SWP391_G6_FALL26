package com.swp391.dao.Admin;

import com.swp391.model.UserBehavior;
import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Customer Behavior Data Pipeline (Screen 5).
 * Executes queries on UserBehaviors table to monitor real-time user interaction events,
 * distribution by behavior type, daily ingestion trends, and top search queries.
 */
public class BehaviorDAO {

    private static final Logger LOGGER = Logger.getLogger(BehaviorDAO.class.getName());
    private final DBContext dbContext;

    public BehaviorDAO() {
        this.dbContext = new DBContext();
    }

    public BehaviorDAO(DBContext dbContext) {
        this.dbContext = dbContext;
    }

    private void setDateParameters(PreparedStatement ps, int baseIndex, String startDate, String endDate) throws SQLException {
        if (startDate != null && !startDate.trim().isEmpty()) {
            ps.setString(baseIndex, startDate);
            ps.setString(baseIndex + 1, startDate);
        } else {
            ps.setNull(baseIndex, java.sql.Types.VARCHAR);
            ps.setNull(baseIndex + 1, java.sql.Types.VARCHAR);
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            ps.setString(baseIndex + 2, endDate);
            ps.setString(baseIndex + 3, endDate);
        } else {
            ps.setNull(baseIndex + 2, java.sql.Types.VARCHAR);
            ps.setNull(baseIndex + 3, java.sql.Types.VARCHAR);
        }
    }

    private String sanitizeType(String behaviorType) {
        if (behaviorType == null || behaviorType.trim().isEmpty() || "ALL".equalsIgnoreCase(behaviorType.trim())) {
            return null;
        }
        return behaviorType.trim();
    }

    /**
     * Aggregates total behavior events, unique sessions, unique customers, and counts by behavior type.
     */
    public Map<String, Object> getBehaviorSummary(String startDate, String endDate, String behaviorType) {
        Map<String, Object> summary = new HashMap<>();
        String bType = sanitizeType(behaviorType);

        String sql = """
                SELECT 
                  COUNT(*) AS totalEvents,
                  COUNT(DISTINCT ub.SessionID) AS totalSessions,
                  COUNT(DISTINCT ub.CustomerID) AS totalUsers,
                  SUM(CASE WHEN ub.BehaviorType = 'VIEW' THEN 1 ELSE 0 END) AS totalViews,
                  SUM(CASE WHEN ub.BehaviorType = 'SEARCH' THEN 1 ELSE 0 END) AS totalSearches,
                  SUM(CASE WHEN ub.BehaviorType = 'FAVORITE' THEN 1 ELSE 0 END) AS totalFavorites,
                  SUM(CASE WHEN ub.BehaviorType = 'CART' THEN 1 ELSE 0 END) AS totalCarts,
                  SUM(CASE WHEN ub.BehaviorType = 'PURCHASE' THEN 1 ELSE 0 END) AS totalPurchases,
                  COUNT(DISTINCT CASE WHEN ub.BehaviorType = 'CART' THEN ub.SessionID END) AS cartSessions,
                  COUNT(DISTINCT CASE WHEN ub.BehaviorType = 'PURCHASE' AND cart.SessionID IS NOT NULL THEN ub.SessionID END) AS convertedSessions
                FROM UserBehaviors ub
                LEFT JOIN (
                    SELECT DISTINCT SessionID 
                    FROM UserBehaviors 
                    WHERE BehaviorType = 'CART'
                ) cart ON ub.SessionID = cart.SessionID
                WHERE (? IS NULL OR ub.CreatedAt >= ?)
                  AND (? IS NULL OR ub.CreatedAt < ?)
                  AND (? IS NULL OR ub.BehaviorType = ?)
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            setDateParameters(ps, 1, startDate, endDate);
            ps.setString(5, bType);
            ps.setString(6, bType);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    long totalEvents = rs.getLong("totalEvents");
                    long totalSessions = rs.getLong("totalSessions");
                    long totalUsers = rs.getLong("totalUsers");
                    long totalViews = rs.getLong("totalViews");
                    long totalSearches = rs.getLong("totalSearches");
                    long totalFavorites = rs.getLong("totalFavorites");
                    long totalCarts = rs.getLong("totalCarts");
                    long totalPurchases = rs.getLong("totalPurchases");
                    long cartSessions = rs.getLong("cartSessions");
                    long convertedSessions = rs.getLong("convertedSessions");

                    summary.put("totalEvents", totalEvents);
                    summary.put("totalSessions", totalSessions);
                    summary.put("totalUsers", totalUsers);
                    summary.put("totalViews", totalViews);
                    summary.put("totalSearches", totalSearches);
                    summary.put("totalFavorites", totalFavorites);
                    summary.put("totalCarts", totalCarts);
                    summary.put("totalPurchases", totalPurchases);
                    summary.put("cartSessions", cartSessions);
                    summary.put("convertedSessions", convertedSessions);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getBehaviorSummary", e);
            throw new RuntimeException("Lỗi truy vấn tổng quan luồng dữ liệu hành vi!", e);
        }

        return summary;
    }

    /**
     * Gets breakdown of behavior events grouped by BehaviorType for Doughnut Chart.
     */
    public List<Map<String, Object>> getBehaviorTypeDistribution(String startDate, String endDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
                SELECT 
                  ub.BehaviorType, 
                  COUNT(*) AS eventCount 
                FROM UserBehaviors ub 
                WHERE (? IS NULL OR ub.CreatedAt >= ?)
                  AND (? IS NULL OR ub.CreatedAt < ?)
                GROUP BY ub.BehaviorType 
                ORDER BY eventCount DESC
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            setDateParameters(ps, 1, startDate, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("behaviorType", rs.getString("BehaviorType"));
                    map.put("eventCount", rs.getLong("eventCount"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getBehaviorTypeDistribution", e);
            throw new RuntimeException("Lỗi truy vấn cơ cấu phân bổ hành vi!", e);
        }

        return list;
    }

    /**
     * Gets daily event ingestion trend for Bar/Line Chart.
     */
    public List<Map<String, Object>> getDailyIngestionTrend(String startDate, String endDate) {
        List<Map<String, Object>> trendList = new ArrayList<>();

        String sql = """
                SELECT 
                  FORMAT(ub.CreatedAt, 'dd/MM/yyyy') AS periodLabel,
                  COUNT(*) AS eventCount
                FROM UserBehaviors ub
                WHERE (? IS NULL OR ub.CreatedAt >= ?)
                  AND (? IS NULL OR ub.CreatedAt < ?)
                GROUP BY FORMAT(ub.CreatedAt, 'dd/MM/yyyy')
                ORDER BY MIN(ub.CreatedAt) ASC
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            setDateParameters(ps, 1, startDate, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("periodLabel", rs.getString("periodLabel"));
                    map.put("eventCount", rs.getLong("eventCount"));
                    trendList.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getDailyIngestionTrend", e);
            throw new RuntimeException("Lỗi truy vấn xu hướng thu thập dữ liệu hành vi!", e);
        }

        return trendList;
    }

    /**
     * Gets top searched keywords and their frequencies.
     */
    public List<Map<String, Object>> getTopSearchedKeywords(String startDate, String endDate, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
                SELECT TOP (?) 
                  ub.SearchKeyword, 
                  COUNT(*) AS searchCount 
                FROM UserBehaviors ub 
                WHERE ub.SearchKeyword IS NOT NULL 
                  AND LTRIM(RTRIM(ub.SearchKeyword)) <> ''
                  AND (? IS NULL OR ub.CreatedAt >= ?)
                  AND (? IS NULL OR ub.CreatedAt < ?)
                GROUP BY ub.SearchKeyword 
                ORDER BY searchCount DESC
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit > 0 ? limit : 5);
            setDateParameters(ps, 2, startDate, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("searchKeyword", rs.getString("SearchKeyword"));
                    map.put("searchCount", rs.getLong("searchCount"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getTopSearchedKeywords", e);
            throw new RuntimeException("Lỗi truy vấn top từ khóa tìm kiếm!", e);
        }

        return list;
    }

    /**
     * Retrieves recent raw customer behavior stream logs.
     */
    public List<Map<String, Object>> getRecentBehaviorLogs(String startDate, String endDate, String behaviorType, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String bType = sanitizeType(behaviorType);

        String sql = """
                SELECT TOP (?) 
                  ub.BehaviorID, ub.CustomerID, ub.ProductID, ub.BehaviorType, 
                  ub.SearchKeyword, ub.SessionID, ub.CreatedAt,
                  p.ProductName,
                  c.FullName AS CustomerName
                FROM UserBehaviors ub
                LEFT JOIN Products p ON ub.ProductID = p.ProductID
                LEFT JOIN Customers c ON ub.CustomerID = c.CustomerID
                WHERE (? IS NULL OR ub.CreatedAt >= ?)
                  AND (? IS NULL OR ub.CreatedAt < ?)
                  AND (? IS NULL OR ub.BehaviorType = ?)
                ORDER BY ub.CreatedAt DESC, ub.BehaviorID DESC
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit > 0 ? limit : 20);
            setDateParameters(ps, 2, startDate, endDate);
            ps.setString(6, bType);
            ps.setString(7, bType);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserBehavior ub = new UserBehavior();
                    ub.setBehaviorID(rs.getLong("BehaviorID"));
                    int cid = rs.getInt("CustomerID");
                    ub.setCustomerID(rs.wasNull() ? null : cid);
                    int pid = rs.getInt("ProductID");
                    ub.setProductID(rs.wasNull() ? null : pid);
                    ub.setBehaviorType(rs.getString("BehaviorType"));
                    ub.setSearchKeyword(rs.getString("SearchKeyword"));
                    ub.setSessionId(rs.getString("SessionID"));
                    java.sql.Timestamp ts = rs.getTimestamp("CreatedAt");
                    String formattedTime = "—";
                    if (ts != null) {
                        java.time.LocalDateTime ldt = ts.toLocalDateTime();
                        ub.setCreatedAt(ldt);
                        formattedTime = ldt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
                    }

                    Map<String, Object> map = new HashMap<>();
                    map.put("behavior", ub);
                    map.put("productName", rs.getString("ProductName") != null ? rs.getString("ProductName") : "—");
                    map.put("customerName", rs.getString("CustomerName") != null ? rs.getString("CustomerName") : "Khách vãng lai (Guest)");
                    map.put("formattedTime", formattedTime);
                    map.put("ingestionStatus", "INGESTED");
                    map.put("isGuest", rs.getObject("CustomerID") == null);

                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getRecentBehaviorLogs", e);
            throw new RuntimeException("Lỗi truy vấn nhật ký luồng hành vi thời gian thực!", e);
        }

        return list;
    }
}
