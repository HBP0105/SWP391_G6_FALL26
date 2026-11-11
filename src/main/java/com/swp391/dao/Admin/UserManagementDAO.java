package com.swp391.dao.Admin;

import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for Unified User & Access Management.
 * Supports paginated queries, role updates, status changes, and metrics summary.
 */
public class UserManagementDAO {

    private final DBContext dbContext;

    public UserManagementDAO() {
        this.dbContext = new DBContext();
    }

    public List<Map<String, Object>> getUsers(
            String keyword,
            String userType,
            String status,
            int offset,
            int pageSize) {

        List<Map<String, Object>> users = new ArrayList<>();
        StringBuilder sql = new StringBuilder(baseUserQuery());
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, userType, status);
        sql.append(" ORDER BY u.CreatedAt DESC, u.UserType ASC, u.UserID DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("userType", rs.getString("UserType"));
                    row.put("userId", rs.getInt("UserID"));
                    row.put("fullName", rs.getString("FullName"));
                    row.put("email", rs.getString("Email"));
                    row.put("phone", rs.getString("Phone"));
                    row.put("roleName", rs.getString("RoleName"));
                    int roleId = rs.getInt("RoleID");
                    row.put("roleId", rs.wasNull() ? null : roleId);
                    row.put("status", rs.getString("Status"));
                    row.put("createdAt", rs.getTimestamp("CreatedAt"));
                    users.add(row);
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to load users.", e);
        }
        return users;
    }

    public int countUsers(String keyword, String userType, String status) {
        StringBuilder sql = new StringBuilder("""
                SELECT COUNT(*) FROM (
                    SELECT 'CUSTOMER' AS UserType, c.CustomerID AS UserID, c.FullName, c.Email, c.Phone, 'CUSTOMER' AS RoleName, CAST(NULL AS INT) AS RoleID, c.Status, c.CreatedAt FROM Customers c
                    UNION ALL
                    SELECT 'STAFF' AS UserType, s.StaffID AS UserID, s.FullName, s.Email, s.Phone, r.RoleName, s.RoleID, s.Status, s.CreatedAt FROM Staff s INNER JOIN Roles r ON s.RoleID = r.RoleID
                ) u WHERE 1=1
                """);
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, userType, status);

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to count users.", e);
        }
    }

    public Map<String, Integer> getUserStats() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = """
                SELECT
                    (SELECT COUNT(*) FROM Customers) + (SELECT COUNT(*) FROM Staff) AS totalAccounts,
                    (SELECT COUNT(*) FROM Customers) AS totalCustomers,
                    (SELECT COUNT(*) FROM Staff) AS totalStaff,
                    (SELECT COUNT(*) FROM Customers WHERE Status = 'ACTIVE') + (SELECT COUNT(*) FROM Staff WHERE Status = 'ACTIVE') AS totalActive,
                    (SELECT COUNT(*) FROM Customers WHERE Status = 'BANNED') + (SELECT COUNT(*) FROM Staff WHERE Status = 'BANNED') AS totalBanned
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                stats.put("totalAccounts", rs.getInt("totalAccounts"));
                stats.put("totalCustomers", rs.getInt("totalCustomers"));
                stats.put("totalStaff", rs.getInt("totalStaff"));
                stats.put("totalActive", rs.getInt("totalActive"));
                stats.put("totalBanned", rs.getInt("totalBanned"));
            }
        } catch (Exception e) {
            // Fallback default metrics if query fails
            stats.put("totalAccounts", 0);
            stats.put("totalCustomers", 0);
            stats.put("totalStaff", 0);
            stats.put("totalActive", 0);
            stats.put("totalBanned", 0);
        }
        return stats;
    }

    public List<Map<String, Object>> getStaffRoles() {
        List<Map<String, Object>> roles = new ArrayList<>();
        String sql = "SELECT RoleID, RoleName FROM Roles WHERE RoleName IN ('ADMIN', 'MANAGER') ORDER BY RoleName";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> role = new HashMap<>();
                role.put("roleId", rs.getInt("RoleID"));
                role.put("roleName", rs.getString("RoleName"));
                roles.add(role);
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to load staff roles.", e);
        }
        return roles;
    }

    public boolean roleExists(int roleId) {
        String sql = "SELECT COUNT(*) FROM Roles WHERE RoleID = ? AND RoleName IN ('ADMIN', 'MANAGER')";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to validate role.", e);
        }
    }

    public boolean updateStaffRole(int staffId, int roleId) {
        String sql = "UPDATE Staff SET RoleID = ?, UpdatedAt = GETDATE() WHERE StaffID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, staffId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Unable to update staff role.", e);
        }
    }

    public boolean updateStatus(String userType, int userId, String status) {
        String table;
        String idColumn;
        if ("STAFF".equalsIgnoreCase(userType)) {
            table = "Staff";
            idColumn = "StaffID";
        } else if ("CUSTOMER".equalsIgnoreCase(userType)) {
            table = "Customers";
            idColumn = "CustomerID";
        } else {
            return false;
        }

        String sql = "UPDATE " + table + " SET Status = ?, UpdatedAt = GETDATE() WHERE " + idColumn + " = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Unable to update account status.", e);
        }
    }

    private String baseUserQuery() {
        return """
                SELECT * FROM (
                    SELECT 'CUSTOMER' AS UserType,
                           c.CustomerID AS UserID,
                           c.FullName,
                           c.Email,
                           c.Phone,
                           'CUSTOMER' AS RoleName,
                           CAST(NULL AS INT) AS RoleID,
                           c.Status,
                           c.CreatedAt
                    FROM Customers c
                    UNION ALL
                    SELECT 'STAFF' AS UserType,
                           s.StaffID AS UserID,
                           s.FullName,
                           s.Email,
                           s.Phone,
                           r.RoleName,
                           s.RoleID,
                           s.Status,
                           s.CreatedAt
                    FROM Staff s
                    INNER JOIN Roles r ON s.RoleID = r.RoleID
                ) u
                WHERE 1=1
                """;
    }

    private void appendFilters(
            StringBuilder sql,
            List<Object> params,
            String keyword,
            String userType,
            String status) {

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR CAST(u.UserID AS VARCHAR(20)) LIKE ?)");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        if (userType != null && !userType.isBlank() && !"ALL".equalsIgnoreCase(userType)) {
            sql.append(" AND u.UserType = ?");
            params.add(userType.toUpperCase());
        }
        if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND u.Status = ?");
            params.add(status.toUpperCase());
        }
    }

    private void bind(PreparedStatement ps, List<Object> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }
}
