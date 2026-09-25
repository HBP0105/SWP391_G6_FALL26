package com.swp391.dao;

import com.swp391.model.Customer;
import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class CustomerDAO {

    private DBContext dbContext;

    public CustomerDAO() {
        dbContext = new DBContext();
    }

    /**
     * Dang nhap Customer
     */
    public Customer login(String email, String password) {
        String sql = "SELECT CustomerID, FullName, Email, PasswordHash, Phone, Status, CreatedAt, UpdatedAt "
                   + "FROM Customers "
                   + "WHERE Email = ? AND PasswordHash = ? AND Status = 'ACTIVE'";

        try (Connection conn = dbContext.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Customer customer = new Customer();
                    customer.setCustomerID(rs.getInt("CustomerID"));
                    customer.setFullName(rs.getString("FullName"));
                    customer.setEmail(rs.getString("Email"));
                    customer.setPasswordHash(rs.getString("PasswordHash"));
                    customer.setPhone(rs.getString("Phone"));
                    customer.setStatus(rs.getString("Status"));

                    Timestamp createdTs = rs.getTimestamp("CreatedAt");
                    if (createdTs != null) {
                        customer.setCreatedAt(createdTs.toLocalDateTime());
                    }

                    Timestamp updatedTs = rs.getTimestamp("UpdatedAt");
                    if (updatedTs != null) {
                        customer.setUpdatedAt(updatedTs.toLocalDateTime());
                    }

                    return customer;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Kiem tra Email da ton tai trong Customers chua
     */
    public boolean checkEmailExist(String email) {
        String sql = "SELECT 1 FROM Customers WHERE Email = ?";
        try (Connection conn = dbContext.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {

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

    /**
     * Dang ky Customer moi
     */
    public boolean register(String fullName, String email, String password, String phone) {
        String sql = "INSERT INTO Customers (FullName, Email, PasswordHash, Phone, Status, CreatedAt) "
                   + "VALUES (?, ?, ?, ?, 'ACTIVE', GETDATE())";

        try (Connection conn = dbContext.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setNString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, phone);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cap nhat mat khau moi theo Email
     */
    public boolean updatePassword(String email, String newPassword) {
        String sql = "UPDATE Customers SET PasswordHash = ?, UpdatedAt = GETDATE() WHERE Email = ?";
        try (Connection conn = dbContext.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setString(2, email);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lay thong tin Customer theo Email
     */
    public Customer getCustomerByEmail(String email) {
        String sql = "SELECT CustomerID, FullName, Email, PasswordHash, Phone, Status, CreatedAt, UpdatedAt "
                   + "FROM Customers WHERE Email = ?";
        try (Connection conn = dbContext.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Customer customer = new Customer();
                    customer.setCustomerID(rs.getInt("CustomerID"));
                    customer.setFullName(rs.getString("FullName"));
                    customer.setEmail(rs.getString("Email"));
                    customer.setPasswordHash(rs.getString("PasswordHash"));
                    customer.setPhone(rs.getString("Phone"));
                    customer.setStatus(rs.getString("Status"));

                    Timestamp createdTs = rs.getTimestamp("CreatedAt");
                    if (createdTs != null) {
                        customer.setCreatedAt(createdTs.toLocalDateTime());
                    }

                    Timestamp updatedTs = rs.getTimestamp("UpdatedAt");
                    if (updatedTs != null) {
                        customer.setUpdatedAt(updatedTs.toLocalDateTime());
                    }

                    return customer;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
