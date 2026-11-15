package com.swp391.dao;

import com.swp391.model.Role;
import com.swp391.model.Staff;
import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class StaffDAO {

    private DBContext dbContext;

    public StaffDAO() {
        dbContext = new DBContext();
    }

    /**
     * Dang nhap Staff
     */
    public Staff login(String email, String password) {
        String sql = """
                SELECT s.StaffID, s.RoleID, s.FullName, s.Email, s.PasswordHash, s.Phone, s.Status,
                       s.CreatedAt, s.UpdatedAt, r.RoleName, r.Description
                FROM Staff s
                INNER JOIN Roles r ON s.RoleID = r.RoleID
                WHERE s.Email = ? AND s.PasswordHash = ? AND s.Status = 'ACTIVE'
                """;

        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

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
     * Find staff by email and password regardless of status (for explicit lock/ban messaging).
     */
    public Staff findByEmailAndPassword(String email, String password) {
        String sql = """
                SELECT s.StaffID, s.RoleID, s.FullName, s.Email, s.PasswordHash, s.Phone, s.Status,
                       s.CreatedAt, s.UpdatedAt, r.RoleName, r.Description
                FROM Staff s
                INNER JOIN Roles r ON s.RoleID = r.RoleID
                WHERE s.Email = ? AND s.PasswordHash = ?
                """;

        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
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
     * Fetch live staff status and role from DB for session synchronization and revocation checks.
     */
    public Staff getStaffAuthStateById(int staffId) {
        String sql = """
                SELECT s.StaffID, s.RoleID, s.FullName, s.Email, s.PasswordHash, s.Phone, s.Status,
                       s.CreatedAt, s.UpdatedAt, r.RoleName, r.Description
                FROM Staff s
                INNER JOIN Roles r ON s.RoleID = r.RoleID
                WHERE s.StaffID = ?
                """;

        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    private Staff mapStaff(ResultSet rs) throws Exception {
        Role role = new Role();
        role.setRoleId(rs.getInt("RoleID"));
        role.setRoleName(rs.getString("RoleName"));
        role.setDescription(rs.getString("Description"));

        Staff staff = new Staff();
        staff.setStaffID(rs.getInt("StaffID"));
        staff.setRole(role);
        staff.setFullName(rs.getString("FullName"));
        staff.setEmail(rs.getString("Email"));
        staff.setPasswordHash(rs.getString("PasswordHash"));
        staff.setPhone(rs.getString("Phone"));
        staff.setStatus(rs.getString("Status"));

        Timestamp createdTs = rs.getTimestamp("CreatedAt");
        if (createdTs != null) {
            staff.setCreatedAt(createdTs.toLocalDateTime());
        }

        Timestamp updatedTs = rs.getTimestamp("UpdatedAt");
        if (updatedTs != null) {
            staff.setUpdatedAt(updatedTs.toLocalDateTime());
        }
        return staff;
    }

    /**
     * Kiem tra Email da ton tai trong Staff chua
     */
    public boolean checkEmailExist(String email) {
        String sql = "SELECT 1 FROM Staff WHERE Email = ?";
        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
