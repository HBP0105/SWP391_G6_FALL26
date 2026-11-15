package com.swp391.dao.Admin;

import com.swp391.util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for Unified User & Access Management.
 * Supports paginated queries, role/status filtering, sorting, user details,
 * staff creation, last-admin protection, role updates, status changes, and CSV export.
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
        return getUsers(keyword, userType, "ALL", status, "newest", offset, pageSize);
    }

    public List<Map<String, Object>> getUsers(
            String keyword,
            String userType,
            String role,
            String status,
            String sort,
            int offset,
            int pageSize) {

        List<Map<String, Object>> users = new ArrayList<>();
        String sql = """
                SELECT * FROM (
                    SELECT 'CUSTOMER' AS UserType,
                           c.CustomerID AS UserID,
                           c.FullName,
                           c.Email,
                           c.Phone,
                           'CUSTOMER' AS RoleName,
                           CAST(NULL AS INT) AS RoleID,
                           c.Status,
                           c.CreatedAt,
                           c.UpdatedAt
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
                           s.CreatedAt,
                           s.UpdatedAt
                    FROM Staff s
                    INNER JOIN Roles r ON s.RoleID = r.RoleID
                ) u
                WHERE (? IS NULL OR u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR CAST(u.UserID AS VARCHAR(20)) LIKE ?)
                  AND (? = 'ALL' OR u.UserType = ?)
                  AND (? = 'ALL' OR UPPER(u.RoleName) = ?)
                  AND (? = 'ALL' OR u.Status = ?)
                ORDER BY
                    CASE WHEN ? = 'oldest' THEN u.CreatedAt END ASC,
                    CASE WHEN ? = 'name_asc' THEN u.FullName END ASC,
                    CASE WHEN ? = 'name_desc' THEN u.FullName END DESC,
                    u.CreatedAt DESC, u.UserID DESC
                OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
                """;

        String kw = (keyword != null && !keyword.isBlank()) ? "%" + keyword.trim() + "%" : null;
        String ut = (userType != null && !userType.isBlank()) ? userType.trim().toUpperCase() : "ALL";
        String ro = (role != null && !role.isBlank()) ? role.trim().toUpperCase() : "ALL";
        String st = (status != null && !status.isBlank()) ? status.trim().toUpperCase() : "ALL";
        String so = (sort != null && !sort.isBlank()) ? sort.trim().toLowerCase() : "newest";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, kw);
            ps.setString(5, kw);
            ps.setString(6, ut);
            ps.setString(7, ut);
            ps.setString(8, ro);
            ps.setString(9, ro);
            ps.setString(10, st);
            ps.setString(11, st);
            ps.setString(12, so);
            ps.setString(13, so);
            ps.setString(14, so);
            ps.setInt(15, offset);
            ps.setInt(16, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUserRow(rs));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to load users.", e);
        }
        return users;
    }

    public List<Map<String, Object>> getAllUsersForExport(
            String keyword,
            String userType,
            String role,
            String status,
            String sort) {

        List<Map<String, Object>> users = new ArrayList<>();
        String sql = """
                SELECT * FROM (
                    SELECT 'CUSTOMER' AS UserType,
                           c.CustomerID AS UserID,
                           c.FullName,
                           c.Email,
                           c.Phone,
                           'CUSTOMER' AS RoleName,
                           CAST(NULL AS INT) AS RoleID,
                           c.Status,
                           c.CreatedAt,
                           c.UpdatedAt
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
                           s.CreatedAt,
                           s.UpdatedAt
                    FROM Staff s
                    INNER JOIN Roles r ON s.RoleID = r.RoleID
                ) u
                WHERE (? IS NULL OR u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR CAST(u.UserID AS VARCHAR(20)) LIKE ?)
                  AND (? = 'ALL' OR u.UserType = ?)
                  AND (? = 'ALL' OR UPPER(u.RoleName) = ?)
                  AND (? = 'ALL' OR u.Status = ?)
                ORDER BY
                    CASE WHEN ? = 'oldest' THEN u.CreatedAt END ASC,
                    CASE WHEN ? = 'name_asc' THEN u.FullName END ASC,
                    CASE WHEN ? = 'name_desc' THEN u.FullName END DESC,
                    u.CreatedAt DESC, u.UserID DESC
                """;

        String kw = (keyword != null && !keyword.isBlank()) ? "%" + keyword.trim() + "%" : null;
        String ut = (userType != null && !userType.isBlank()) ? userType.trim().toUpperCase() : "ALL";
        String ro = (role != null && !role.isBlank()) ? role.trim().toUpperCase() : "ALL";
        String st = (status != null && !status.isBlank()) ? status.trim().toUpperCase() : "ALL";
        String so = (sort != null && !sort.isBlank()) ? sort.trim().toLowerCase() : "newest";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, kw);
            ps.setString(5, kw);
            ps.setString(6, ut);
            ps.setString(7, ut);
            ps.setString(8, ro);
            ps.setString(9, ro);
            ps.setString(10, st);
            ps.setString(11, st);
            ps.setString(12, so);
            ps.setString(13, so);
            ps.setString(14, so);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUserRow(rs));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to export users.", e);
        }
        return users;
    }

    public int countUsers(String keyword, String userType, String status) {
        return countUsers(keyword, userType, "ALL", status);
    }

    public int countUsers(String keyword, String userType, String role, String status) {
        String sql = """
                SELECT COUNT(*) FROM (
                    SELECT 'CUSTOMER' AS UserType, c.CustomerID AS UserID, c.FullName, c.Email, c.Phone, 'CUSTOMER' AS RoleName, CAST(NULL AS INT) AS RoleID, c.Status, c.CreatedAt, c.UpdatedAt FROM Customers c
                    UNION ALL
                    SELECT 'STAFF' AS UserType, s.StaffID AS UserID, s.FullName, s.Email, s.Phone, r.RoleName, s.RoleID, s.Status, s.CreatedAt, s.UpdatedAt FROM Staff s INNER JOIN Roles r ON s.RoleID = r.RoleID
                ) u
                WHERE (? IS NULL OR u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR CAST(u.UserID AS VARCHAR(20)) LIKE ?)
                  AND (? = 'ALL' OR u.UserType = ?)
                  AND (? = 'ALL' OR UPPER(u.RoleName) = ?)
                  AND (? = 'ALL' OR u.Status = ?)
                """;

        String kw = (keyword != null && !keyword.isBlank()) ? "%" + keyword.trim() + "%" : null;
        String ut = (userType != null && !userType.isBlank()) ? userType.trim().toUpperCase() : "ALL";
        String ro = (role != null && !role.isBlank()) ? role.trim().toUpperCase() : "ALL";
        String st = (status != null && !status.isBlank()) ? status.trim().toUpperCase() : "ALL";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, kw);
            ps.setString(5, kw);
            ps.setString(6, ut);
            ps.setString(7, ut);
            ps.setString(8, ro);
            ps.setString(9, ro);
            ps.setString(10, st);
            ps.setString(11, st);

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
        return getRoleNameById(roleId) != null;
    }

    public String getRoleNameById(int roleId) {
        String sql = "SELECT RoleName FROM Roles WHERE RoleID = ? AND RoleName IN ('ADMIN', 'MANAGER')";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("RoleName") : null;
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to validate role.", e);
        }
    }

    public Map<String, Object> getAccountSnapshot(String userType, int userId) {
        String sql;
        if ("STAFF".equalsIgnoreCase(userType)) {
            sql = """
                    SELECT 'STAFF' AS UserType,
                           s.StaffID AS UserID,
                           s.FullName,
                           s.Email,
                           s.Phone,
                           r.RoleName,
                           s.RoleID,
                           s.Status,
                           s.CreatedAt,
                           s.UpdatedAt
                    FROM Staff s
                    INNER JOIN Roles r ON s.RoleID = r.RoleID
                    WHERE s.StaffID = ?
                    """;
        } else if ("CUSTOMER".equalsIgnoreCase(userType)) {
            sql = """
                    SELECT 'CUSTOMER' AS UserType,
                           c.CustomerID AS UserID,
                           c.FullName,
                           c.Email,
                           c.Phone,
                           'CUSTOMER' AS RoleName,
                           CAST(NULL AS INT) AS RoleID,
                           c.Status,
                           c.CreatedAt,
                           c.UpdatedAt
                    FROM Customers c
                    WHERE c.CustomerID = ?
                    """;
        } else {
            return null;
        }

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUserRow(rs);
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to load account details.", e);
        }
        return null;
    }

    public Map<String, Object> getUserDetail(String userType, int userId) {
        Map<String, Object> detail = getAccountSnapshot(userType, userId);
        if (detail == null) {
            return null;
        }

        if ("CUSTOMER".equalsIgnoreCase(userType)) {
            String orderSql = """
                    SELECT COUNT(*) AS totalOrders,
                           COALESCE(SUM(CASE WHEN OrderStatus = 'DELIVERED' THEN 1 ELSE 0 END), 0) AS deliveredOrders,
                           COALESCE(SUM(CASE WHEN OrderStatus = 'CANCELLED' THEN 1 ELSE 0 END), 0) AS cancelledOrders,
                           COALESCE(SUM(CASE WHEN OrderStatus = 'DELIVERED' THEN TotalAmount ELSE 0 END), 0) AS totalSpent,
                           MAX(OrderDate) AS lastOrderDate
                    FROM Orders
                    WHERE CustomerID = ?
                    """;
            try (Connection conn = dbContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        detail.put("totalOrders", rs.getInt("totalOrders"));
                        detail.put("deliveredOrders", rs.getInt("deliveredOrders"));
                        detail.put("cancelledOrders", rs.getInt("cancelledOrders"));
                        BigDecimal spent = rs.getBigDecimal("totalSpent");
                        detail.put("totalSpent", spent != null ? spent : BigDecimal.ZERO);
                        detail.put("lastOrderDate", rs.getTimestamp("lastOrderDate"));
                    }
                }
            } catch (Exception e) {
                throw new RuntimeException("Unable to load customer order summary.", e);
            }
        } else {
            String auditSql = """
                    SELECT COUNT(*) AS totalAuditActions,
                           MAX(CreatedAt) AS lastAuditAt
                    FROM AuditLogs
                    WHERE StaffID = ?
                    """;
            try (Connection conn = dbContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(auditSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        detail.put("totalAuditActions", rs.getInt("totalAuditActions"));
                        detail.put("lastAuditAt", rs.getTimestamp("lastAuditAt"));
                    }
                }
            } catch (Exception e) {
                throw new RuntimeException("Unable to load staff audit summary.", e);
            }
        }

        // Latest administrative change applied to this account
        String entityName = "STAFF".equalsIgnoreCase(userType) ? "Staff" : "Customer";
        String lastChangeSql = """
                SELECT TOP 1
                       a.Action,
                       a.OldData,
                       a.NewData,
                       a.CreatedAt,
                       COALESCE(s.FullName, 'System') AS ChangedByName,
                       s.Email AS ChangedByEmail
                FROM AuditLogs a
                LEFT JOIN Staff s ON a.StaffID = s.StaffID
                WHERE a.EntityName = ?
                  AND a.EntityID = ?
                  AND a.Action IN ('UPDATE_STATUS', 'UPDATE_ROLE', 'RESET_PASSWORD', 'CREATE_STAFF', 'UPDATE_STAFF_INFO', 'CHANGE_OWN_PASSWORD')
                ORDER BY a.CreatedAt DESC, a.AuditLogID DESC
                """;
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(lastChangeSql)) {
            ps.setString(1, entityName);
            ps.setString(2, String.valueOf(userId));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    detail.put("lastChangeAction", rs.getString("Action"));
                    detail.put("lastChangeOldData", rs.getString("OldData"));
                    detail.put("lastChangeNewData", rs.getString("NewData"));
                    detail.put("lastChangeAt", rs.getTimestamp("CreatedAt"));
                    detail.put("lastChangedByName", rs.getString("ChangedByName"));
                    detail.put("lastChangedByEmail", rs.getString("ChangedByEmail"));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to load latest account access history.", e);
        }

        return detail;
    }

    public int countActiveAdmins() {
        String sql = """
                SELECT COUNT(*)
                FROM Staff s
                INNER JOIN Roles r ON s.RoleID = r.RoleID
                WHERE r.RoleName = 'ADMIN' AND s.Status = 'ACTIVE'
                """;
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            throw new RuntimeException("Unable to count active administrators.", e);
        }
    }

    public boolean emailExistsInAnyAccount(String email) {
        String sql = """
                SELECT CASE WHEN EXISTS (
                    SELECT 1 FROM Staff WHERE LOWER(Email) = LOWER(?)
                    UNION ALL
                    SELECT 1 FROM Customers WHERE LOWER(Email) = LOWER(?)
                ) THEN 1 ELSE 0 END
                """;
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) == 1;
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to verify email uniqueness.", e);
        }
    }

    public boolean phoneExistsInAnyAccount(String phone, Integer excludeStaffId) {
        String normalizedPhone = normalizePhoneForCompare(phone);
        if (normalizedPhone.isEmpty()) {
            return false;
        }
        String normalizedCol = "REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(Phone)), ' ', ''), '-', ''), '.', ''), '(', ''), ')', '')";
        String staffExcludeClause = excludeStaffId != null ? " AND StaffID <> ?" : "";
        String sql = "SELECT CASE WHEN EXISTS ("
                + " SELECT 1 FROM Staff WHERE Phone IS NOT NULL AND " + normalizedCol + " = ?" + staffExcludeClause
                + " UNION ALL"
                + " SELECT 1 FROM Customers WHERE Phone IS NOT NULL AND " + normalizedCol + " = ?"
                + ") THEN 1 ELSE 0 END";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            ps.setString(idx++, normalizedPhone);
            if (excludeStaffId != null) {
                ps.setInt(idx++, excludeStaffId);
            }
            ps.setString(idx, normalizedPhone);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) == 1;
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to verify phone uniqueness.", e);
        }
    }

    private String normalizePhoneForCompare(String phone) {
        if (phone == null) {
            return "";
        }
        return phone.trim().replaceAll("[\\s\\-.()]", "");
    }

    public int createStaff(String fullName, String email, String phone, String password, int roleId, String status) {
        String sql = """
                INSERT INTO Staff (RoleID, FullName, Email, PasswordHash, Phone, Status, CreatedAt)
                VALUES (?, ?, ?, ?, ?, ?, GETDATE())
                """;
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, roleId);
            ps.setNString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, password);
            ps.setString(5, phone != null && !phone.isBlank() ? phone : null);
            ps.setString(6, status);
            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
            return -1;
        } catch (Exception e) {
            throw new RuntimeException("Unable to create staff account.", e);
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

    public boolean updateStaffInfo(int staffId, String fullName, String phone) {
        String sql = "UPDATE Staff SET FullName = ?, Phone = ?, UpdatedAt = GETDATE() WHERE StaffID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, fullName);
            ps.setString(2, phone != null && !phone.isBlank() ? phone : null);
            ps.setInt(3, staffId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Unable to update staff profile information.", e);
        }
    }

    public boolean resetStaffPassword(int staffId, String newPassword) {
        String sql = "UPDATE Staff SET PasswordHash = ?, UpdatedAt = GETDATE() WHERE StaffID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setInt(2, staffId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Unable to reset staff password.", e);
        }
    }

    public boolean verifyStaffPassword(int staffId, String currentPassword) {
        String sql = "SELECT 1 FROM Staff WHERE StaffID = ? AND PasswordHash = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setString(2, currentPassword);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to verify current password.", e);
        }
    }

    public boolean phoneExistsInAnyAccount(String phone, int excludeStaffId) {
        return phoneExistsInAnyAccount(phone, Integer.valueOf(excludeStaffId));
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

    private Map<String, Object> mapUserRow(ResultSet rs) throws Exception {
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
        row.put("updatedAt", rs.getTimestamp("UpdatedAt"));
        return row;
    }
}
