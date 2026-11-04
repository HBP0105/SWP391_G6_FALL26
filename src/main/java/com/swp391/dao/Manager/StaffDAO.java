package com.swp391.dao.Manager;

import com.swp391.model.Role;
import com.swp391.model.Staff;
import com.swp391.util.DBContext;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;

public class StaffDAO {

    /**
     * Get staff member by StaffID including Role details.
     */
    public Staff getStaffById(int staffId) {
        String sql = """
            SELECT 
                s.StaffID,
                s.RoleID,
                s.FullName,
                s.Email,
                s.PasswordHash,
                s.Phone,
                s.Status,
                s.CreatedAt,
                s.UpdatedAt,
                r.RoleName,
                r.Description AS RoleDescription
            FROM Staff s
            LEFT JOIN Roles r ON s.RoleID = r.RoleID
            WHERE s.StaffID = ?
        """;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapStaff(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get staff by email.
     */
    public Staff getStaffByEmail(String email) {
        if (email == null || email.trim().isEmpty()) return null;
        String sql = """
            SELECT 
                s.StaffID,
                s.RoleID,
                s.FullName,
                s.Email,
                s.PasswordHash,
                s.Phone,
                s.Status,
                s.CreatedAt,
                s.UpdatedAt,
                r.RoleName,
                r.Description AS RoleDescription
            FROM Staff s
            LEFT JOIN Roles r ON s.RoleID = r.RoleID
            WHERE LOWER(s.Email) = LOWER(?)
        """;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapStaff(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get an active manager from Staff table.
     * If no manager exists, auto-seeds a default Manager record so that
     * profile viewing and editing always work out of the box.
     */
    public Staff getOrCreateDefaultManager() {
        String sql = """
            SELECT TOP 1
                s.StaffID,
                s.RoleID,
                s.FullName,
                s.Email,
                s.PasswordHash,
                s.Phone,
                s.Status,
                s.CreatedAt,
                s.UpdatedAt,
                r.RoleName,
                r.Description AS RoleDescription
            FROM Staff s
            LEFT JOIN Roles r ON s.RoleID = r.RoleID
            WHERE r.RoleName = 'MANAGER' OR s.RoleID = 2
            ORDER BY s.StaffID ASC
        """;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return mapStaff(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // If no manager found, check if ANY staff exists
        String anyStaffSql = """
            SELECT TOP 1
                s.StaffID,
                s.RoleID,
                s.FullName,
                s.Email,
                s.PasswordHash,
                s.Phone,
                s.Status,
                s.CreatedAt,
                s.UpdatedAt,
                r.RoleName,
                r.Description AS RoleDescription
            FROM Staff s
            LEFT JOIN Roles r ON s.RoleID = r.RoleID
            ORDER BY s.StaffID ASC
        """;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(anyStaffSql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return mapStaff(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // If table is completely empty, insert default manager
        return seedDefaultManager();
    }

    private Staff seedDefaultManager() {
        int roleId = 2; // Default MANAGER role

        // Look up RoleID for MANAGER in Roles table
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT RoleID FROM Roles WHERE RoleName = 'MANAGER'");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                roleId = rs.getInt("RoleID");
            }
        } catch (Exception ignored) {
        }

        String insertSql = """
            INSERT INTO Staff (RoleID, FullName, Email, PasswordHash, Phone, Status, CreatedAt)
            VALUES (?, ?, ?, ?, ?, 'ACTIVE', GETDATE())
        """;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, roleId);
            ps.setString(2, "Store Manager");
            ps.setString(3, "manager@headphonestore.com");
            ps.setString(4, hashPassword("123456"));
            ps.setString(5, "0901234567");

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        int newId = keys.getInt(1);
                        return getStaffById(newId);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Check if email is already taken by another staff member.
     */
    public boolean isEmailTaken(String email, int excludeStaffId) {
        if (email == null || email.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM Staff WHERE LOWER(Email) = LOWER(?) AND StaffID <> ?";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            ps.setInt(2, excludeStaffId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update profile details (FullName, Email, Phone).
     */
    public boolean updateProfile(int staffId, String fullName, String email, String phone) {
        String sql = """
            UPDATE Staff
            SET FullName = ?,
                Email = ?,
                Phone = ?,
                UpdatedAt = GETDATE()
            WHERE StaffID = ?
        """;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName.trim());
            ps.setString(2, email.trim());
            ps.setString(3, phone != null ? phone.trim() : null);
            ps.setInt(4, staffId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Change staff password.
     */
    public boolean updatePassword(int staffId, String newPassword) {
        String hashedPassword = hashPassword(newPassword);
        String sql = """
            UPDATE Staff
            SET PasswordHash = ?,
                UpdatedAt = GETDATE()
            WHERE StaffID = ?
        """;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setInt(2, staffId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Verify whether a password matches the stored password.
     */
    public boolean verifyPassword(int staffId, String rawPassword) {
        if (rawPassword == null) return false;
        Staff staff = getStaffById(staffId);
        if (staff == null || staff.getPasswordHash() == null) return false;

        String stored = staff.getPasswordHash();
        String hashed = hashPassword(rawPassword);

        return stored.equals(rawPassword) || stored.equalsIgnoreCase(hashed);
    }

    public static String hashPassword(String password) {
        if (password == null) return "";
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedHash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : encodedHash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            return password;
        }
    }

    private Staff mapStaff(ResultSet rs) throws Exception {
        Staff staff = new Staff();
        staff.setStaffId(rs.getInt("StaffID"));
        staff.setRoleId(rs.getInt("RoleID"));
        staff.setFullName(rs.getString("FullName"));
        staff.setEmail(rs.getString("Email"));
        staff.setPasswordHash(rs.getString("PasswordHash"));
        staff.setPhone(rs.getString("Phone"));
        staff.setStatus(rs.getString("Status"));

        Timestamp created = rs.getTimestamp("CreatedAt");
        if (created != null) {
            staff.setCreatedAt(created.toLocalDateTime());
        }

        Timestamp updated = rs.getTimestamp("UpdatedAt");
        if (updated != null) {
            staff.setUpdatedAt(updated.toLocalDateTime());
        }

        Role role = new Role();
        role.setRoleId(rs.getInt("RoleID"));
        role.setRoleName(rs.getString("RoleName"));
        role.setDescription(rs.getString("RoleDescription"));
        staff.setRole(role);

        return staff;
    }
}
