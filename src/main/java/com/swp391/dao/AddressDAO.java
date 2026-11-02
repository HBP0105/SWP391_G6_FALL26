package com.swp391.dao;

import com.swp391.model.Address;
import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AddressDAO extends DBContext {

    // 1. Lấy danh sách toàn bộ địa chỉ trong kho của Customer (Địa chỉ mặc định xếp lên đầu)
    public List<Address> getAddressesByCustomerId(int customerId) {
        List<Address> list = new ArrayList<>();
        String sql = "SELECT AddressID, CustomerID, ReceiverName, ReceiverPhone, "
                   + "AddressLine, Ward, District, Province, IsDefault "
                   + "FROM Addresses WHERE CustomerID = ? "
                   + "ORDER BY IsDefault DESC, AddressID DESC";
        try {
            Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Address a = new Address();
                a.setAddressId(rs.getInt("AddressID"));
                a.setCustomerId(rs.getInt("CustomerID"));
                a.setReceiverName(rs.getString("ReceiverName"));
                a.setReceiverPhone(rs.getString("ReceiverPhone"));
                a.setAddressLine(rs.getString("AddressLine"));
                a.setWard(rs.getString("Ward"));
                a.setDistrict(rs.getString("District"));
                a.setProvince(rs.getString("Province"));
                a.setIsDefault(rs.getBoolean("IsDefault"));
                list.add(a);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Thêm địa chỉ mới vào Kho địa chỉ (Address Repository)
    public boolean addAddress(Address addr) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // Nếu khách chọn đặt làm mặc định, hạ các địa chỉ cũ xuống IsDefault = 0 trước
            if (addr.isIsDefault()) {
                String sqlReset = "UPDATE Addresses SET IsDefault = 0 WHERE CustomerID = ?";
                PreparedStatement psReset = conn.prepareStatement(sqlReset);
                psReset.setInt(1, addr.getCustomerId());
                psReset.executeUpdate();
            }

            String sql = "INSERT INTO Addresses (CustomerID, ReceiverName, ReceiverPhone, AddressLine, Ward, District, Province, IsDefault) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, addr.getCustomerId());
            ps.setString(2, addr.getReceiverName());
            ps.setString(3, addr.getReceiverPhone());
            ps.setString(4, addr.getAddressLine());
            ps.setString(5, addr.getWard());
            ps.setString(6, addr.getDistrict());
            ps.setString(7, addr.getProvince());
            ps.setBoolean(8, addr.isIsDefault());
            ps.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
            return false;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception ex) {}
        }
    }

    // 3. Cập nhật (Sửa) địa chỉ trong Kho
    public boolean updateAddress(Address addr) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            if (addr.isIsDefault()) {
                String sqlReset = "UPDATE Addresses SET IsDefault = 0 WHERE CustomerID = ?";
                PreparedStatement psReset = conn.prepareStatement(sqlReset);
                psReset.setInt(1, addr.getCustomerId());
                psReset.executeUpdate();
            }

            String sql = "UPDATE Addresses SET ReceiverName = ?, ReceiverPhone = ?, AddressLine = ?, "
                       + "Ward = ?, District = ?, Province = ?, IsDefault = ?, UpdatedAt = GETDATE() "
                       + "WHERE AddressID = ? AND CustomerID = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, addr.getReceiverName());
            ps.setString(2, addr.getReceiverPhone());
            ps.setString(3, addr.getAddressLine());
            ps.setString(4, addr.getWard());
            ps.setString(5, addr.getDistrict());
            ps.setString(6, addr.getProvince());
            ps.setBoolean(7, addr.isIsDefault());
            ps.setInt(8, addr.getAddressId());
            ps.setInt(9, addr.getCustomerId());
            ps.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
            return false;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception ex) {}
        }
    }

    // 4. Xóa địa chỉ khỏi Kho
    public boolean deleteAddress(int addressId, int customerId) {
        String sql = "DELETE FROM Addresses WHERE AddressID = ? AND CustomerID = ?";
        try {
            Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, addressId);
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 5. Đặt 1 địa chỉ làm Mặc định (Default)
    public boolean setDefaultAddress(int addressId, int customerId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String sqlReset = "UPDATE Addresses SET IsDefault = 0 WHERE CustomerID = ?";
            PreparedStatement psReset = conn.prepareStatement(sqlReset);
            psReset.setInt(1, customerId);
            psReset.executeUpdate();

            String sqlSet = "UPDATE Addresses SET IsDefault = 1, UpdatedAt = GETDATE() WHERE AddressID = ? AND CustomerID = ?";
            PreparedStatement psSet = conn.prepareStatement(sqlSet);
            psSet.setInt(1, addressId);
            psSet.setInt(2, customerId);
            psSet.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {}
            return false;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception ex) {}
        }
    }
}
