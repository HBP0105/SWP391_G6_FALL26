package com.swp391.dao;

import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Loads the live account access state used to invalidate stale browser sessions.
 */
public class AccountStatusDAO {

    private final DBContext dbContext = new DBContext();

    public AccountState findCustomerState(int customerId) {
        String sql = "SELECT Status FROM Customers WHERE CustomerID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next()
                        ? new AccountState(rs.getString("Status"), "CUSTOMER", null)
                        : null;
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to verify customer account status.", e);
        }
    }

    public AccountState findStaffState(int staffId) {
        String sql = """
                SELECT s.Status, s.RoleID, r.RoleName
                FROM Staff s
                INNER JOIN Roles r ON s.RoleID = r.RoleID
                WHERE s.StaffID = ?
                """;
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next()
                        ? new AccountState(
                                rs.getString("Status"),
                                rs.getString("RoleName"),
                                rs.getInt("RoleID"))
                        : null;
            }
        } catch (Exception e) {
            throw new RuntimeException("Unable to verify staff account status.", e);
        }
    }

    public record AccountState(String status, String roleName, Integer roleId) {
        public boolean isActive() {
            return "ACTIVE".equalsIgnoreCase(status);
        }
    }
}
