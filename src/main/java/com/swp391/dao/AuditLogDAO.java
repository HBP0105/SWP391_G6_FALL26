package com.swp391.dao;

import com.swp391.model.AuditLog;
import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object (DAO) for System Audit Logs (Feature 5).
 * Provides filtered listing, pagination, metrics summary, and action logging.
 */
public class AuditLogDAO {

    private static final Logger LOGGER = Logger.getLogger(AuditLogDAO.class.getName());
    private final DBContext dbContext;

    public AuditLogDAO() {
        this.dbContext = new DBContext();
    }

    /**
     * Inserts an audit log record into the database.
     */
    public boolean insertAuditLog(Integer staffId, String action, String entityName,
                                 String entityId, String oldData, String newData) {
        String sql = """
                INSERT INTO AuditLogs (StaffID, Action, EntityName, EntityID, OldData, NewData, CreatedAt)
                VALUES (?, ?, ?, ?, ?, ?, GETDATE())
                """;
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (staffId != null && staffId > 0) {
                ps.setInt(1, staffId);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, action != null ? action.trim() : "UNKNOWN");
            ps.setString(3, entityName != null ? entityName.trim() : null);
            ps.setString(4, entityId != null ? entityId.trim() : null);
            ps.setString(5, oldData);
            ps.setString(6, newData);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error inserting AuditLog: " + action + " on " + entityName, e);
            return false;
        }
    }

    /**
     * Retrieves filtered and paginated list of audit logs.
     */
    public List<AuditLog> getAuditLogsFiltered(String startDate, String endDate, String action,
                                             String keyword, int page, int pageSize) {
        List<AuditLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
                SELECT a.AuditLogID, a.StaffID, a.Action, a.EntityName, a.EntityID,
                       a.OldData, a.NewData, a.CreatedAt,
                       s.FullName AS StaffName, s.Email AS StaffEmail, r.RoleName
                FROM AuditLogs a
                LEFT JOIN Staff s ON a.StaffID = s.StaffID
                LEFT JOIN Roles r ON s.RoleID = r.RoleID
                WHERE 1=1
                """);

        List<Object> params = new ArrayList<>();
        buildFilterConditions(sql, params, startDate, endDate, action, keyword);

        sql.append(" ORDER BY a.CreatedAt DESC, a.AuditLogID DESC");
        if (pageSize > 0) {
            int currentPage = Math.max(page, 1);
            sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            params.add((currentPage - 1) * pageSize);
            params.add(pageSize);
        }

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setAuditLogId(rs.getLong("AuditLogID"));
                    int staffId = rs.getInt("StaffID");
                    if (!rs.wasNull()) {
                        log.setStaffId(staffId);
                    }
                    log.setAction(rs.getString("Action"));
                    log.setEntityName(rs.getString("EntityName"));
                    log.setEntityId(rs.getString("EntityID"));
                    log.setOldData(rs.getString("OldData"));
                    log.setNewData(rs.getString("NewData"));

                    Timestamp ts = rs.getTimestamp("CreatedAt");
                    if (ts != null) {
                        log.setCreatedAt(ts.toLocalDateTime());
                    }

                    log.setStaffName(rs.getString("StaffName"));
                    log.setStaffEmail(rs.getString("StaffEmail"));
                    log.setRoleName(rs.getString("RoleName"));

                    list.add(log);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching filtered AuditLogs", e);
        }
        return list;
    }

    /**
     * Counts the total number of filtered audit log records for pagination.
     */
    public int getTotalAuditLogsCount(String startDate, String endDate, String action, String keyword) {
        StringBuilder sql = new StringBuilder("""
                SELECT COUNT(a.AuditLogID)
                FROM AuditLogs a
                LEFT JOIN Staff s ON a.StaffID = s.StaffID
                LEFT JOIN Roles r ON s.RoleID = r.RoleID
                WHERE 1=1
                """);

        List<Object> params = new ArrayList<>();
        buildFilterConditions(sql, params, startDate, endDate, action, keyword);

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error counting filtered AuditLogs", e);
        }
        return 0;
    }

    /**
     * Gets a list of distinct actions present in AuditLogs for dropdown filtering.
     */
    public List<String> getDistinctActions() {
        List<String> actions = new ArrayList<>();
        String sql = "SELECT DISTINCT Action FROM AuditLogs WHERE Action IS NOT NULL ORDER BY Action ASC";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                actions.add(rs.getString("Action"));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching distinct AuditLog actions", e);
        }
        return actions;
    }

    /**
     * Computes summary metrics for Dashboard Cards (Total Logs, Today, Orders, Settings).
     */
    public Map<String, Integer> getAuditLogMetrics() {
        Map<String, Integer> metrics = new HashMap<>();
        metrics.put("totalLogs", 0);
        metrics.put("todayLogs", 0);
        metrics.put("orderLogs", 0);
        metrics.put("configLogs", 0);

        String sql = """
                SELECT 
                    COUNT(*) AS TotalLogs,
                    SUM(CASE WHEN CAST(CreatedAt AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS TodayLogs,
                    SUM(CASE WHEN EntityName = 'Orders' OR EntityName = 'Order' THEN 1 ELSE 0 END) AS OrderLogs,
                    SUM(CASE WHEN EntityName LIKE '%Config%' OR Action LIKE '%CONFIG%' THEN 1 ELSE 0 END) AS ConfigLogs
                FROM AuditLogs
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                metrics.put("totalLogs", rs.getInt("TotalLogs"));
                metrics.put("todayLogs", rs.getInt("TodayLogs"));
                metrics.put("orderLogs", rs.getInt("OrderLogs"));
                metrics.put("configLogs", rs.getInt("ConfigLogs"));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching AuditLog metrics", e);
        }
        return metrics;
    }

    private void buildFilterConditions(StringBuilder sql, List<Object> params,
                                       String startDate, String endDate, String action, String keyword) {
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND a.CreatedAt >= ?");
            params.add(startDate.trim());
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND a.CreatedAt < ?");
            params.add(endDate.trim());
        }

        if (action != null && !action.trim().isEmpty() && !"ALL".equalsIgnoreCase(action.trim())) {
            sql.append(" AND a.Action = ?");
            params.add(action.trim());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (s.FullName LIKE ? OR s.Email LIKE ? OR a.EntityID LIKE ? OR a.Action LIKE ? OR a.EntityName LIKE ?)");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
    }
}
