package com.swp391.dao.Manager;

import com.swp391.model.Voucher;
import com.swp391.util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VoucherDao {

    public List<Voucher> getAllVouchers() {
        return getVouchers(null, null, null, null, null, null, null);
    }

    public List<Voucher> getVouchers(
            String keyword,
            String discountType,
            String status,
            String validPeriod,
            String sort,
            Integer offset,
            Integer pageSize) {

        List<Voucher> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT
                v.VoucherID,
                v.VoucherCode,
                v.Description,
                v.DiscountType,
                v.DiscountValue,
                v.MinOrderAmount,
                v.MaxDiscount,
                v.StartDate,
                v.EndDate,
                v.UsageLimit,
                v.UsedCount,
                v.Status,
                v.CreatedBy,
                v.CreatedAt
            FROM Vouchers v
            WHERE 1 = 1
        """);

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, discountType, status, validPeriod);
        appendSort(sql, sort);

        if (offset != null && pageSize != null) {
            sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            params.add(offset);
            params.add(pageSize);
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapVoucher(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countVouchers(
            String keyword,
            String discountType,
            String status,
            String validPeriod) {

        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*)
            FROM Vouchers v
            WHERE 1 = 1
        """);

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, discountType, status, validPeriod);

        try (Connection conn = DBContext.getConnection();
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
            e.printStackTrace();
        }

        return 0;
    }

    private void appendFilters(
            StringBuilder sql,
            List<Object> params,
            String keyword,
            String discountType,
            String status,
            String validPeriod) {

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (v.VoucherCode LIKE ? OR v.Description LIKE ?)");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
        }

        if (discountType != null && !discountType.isBlank() && !"ALL".equalsIgnoreCase(discountType)) {
            sql.append(" AND v.DiscountType = ?");
            params.add(discountType.trim().toUpperCase());
        }

        if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND v.Status = ?");
            params.add(status.trim().toUpperCase());
        }

        if ("valid_now".equalsIgnoreCase(validPeriod)) {
            sql.append(" AND v.StartDate <= GETDATE() AND v.EndDate >= GETDATE()");
        } else if ("upcoming".equalsIgnoreCase(validPeriod)) {
            sql.append(" AND v.StartDate > GETDATE()");
        } else if ("expired".equalsIgnoreCase(validPeriod)) {
            sql.append(" AND v.EndDate < GETDATE()");
        }
    }

    private void appendSort(StringBuilder sql, String sort) {
        if ("minorder_asc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY v.MinOrderAmount ASC, v.VoucherID DESC");
        } else if ("minorder_desc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY v.MinOrderAmount DESC, v.VoucherID DESC");
        } else if ("discount_desc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY v.DiscountValue DESC, v.VoucherID DESC");
        } else if ("discount_asc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY v.DiscountValue ASC, v.VoucherID DESC");
        } else if ("expiring_soon".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY v.EndDate ASC, v.VoucherID DESC");
        } else {
            sql.append(" ORDER BY v.CreatedAt DESC, v.VoucherID DESC");
        }
    }

    public Voucher getVoucherById(int id) {
        String sql = """
            SELECT
                VoucherID,
                VoucherCode,
                Description,
                DiscountType,
                DiscountValue,
                MinOrderAmount,
                MaxDiscount,
                StartDate,
                EndDate,
                UsageLimit,
                UsedCount,
                Status,
                CreatedBy,
                CreatedAt
            FROM Vouchers
            WHERE VoucherID = ?
        """;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapVoucher(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public Voucher getVoucherByCode(String code) {
        if (code == null || code.isBlank()) {
            return null;
        }

        String sql = """
            SELECT
                VoucherID,
                VoucherCode,
                Description,
                DiscountType,
                DiscountValue,
                MinOrderAmount,
                MaxDiscount,
                StartDate,
                EndDate,
                UsageLimit,
                UsedCount,
                Status,
                CreatedBy,
                CreatedAt
            FROM Vouchers
            WHERE VoucherCode = ?
        """;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapVoucher(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean insertVoucher(Voucher v) {
        String sql = """
            INSERT INTO Vouchers (
                VoucherCode,
                Description,
                DiscountType,
                DiscountValue,
                MinOrderAmount,
                MaxDiscount,
                StartDate,
                EndDate,
                UsageLimit,
                UsedCount,
                Status,
                CreatedBy,
                CreatedAt
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
        """;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, v.getVoucherCode());
            ps.setString(2, v.getDescription());
            ps.setString(3, v.getDiscountType());
            ps.setBigDecimal(4, v.getDiscountValue());
            ps.setBigDecimal(5, v.getMinOrderAmount());

            if (v.getMaxDiscount() != null) {
                ps.setBigDecimal(6, v.getMaxDiscount());
            } else {
                ps.setNull(6, Types.DECIMAL);
            }

            ps.setTimestamp(7, Timestamp.valueOf(v.getStartDate()));
            ps.setTimestamp(8, Timestamp.valueOf(v.getEndDate()));

            if (v.getUsageLimit() != null && v.getUsageLimit() > 0) {
                ps.setInt(9, v.getUsageLimit());
            } else {
                ps.setNull(9, Types.INTEGER);
            }

            ps.setInt(10, v.getUsedCount());
            ps.setString(11, v.getStatus() != null ? v.getStatus() : "ACTIVE");

            if (v.getCreatedBy() != null && v.getCreatedBy() > 0) {
                ps.setInt(12, v.getCreatedBy());
            } else {
                ps.setNull(12, Types.INTEGER);
            }

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateStatus(int voucherId, String status) {
        String sql = "UPDATE Vouchers SET Status = ? WHERE VoucherID = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, voucherId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private Voucher mapVoucher(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setVoucherId(rs.getInt("VoucherID"));
        v.setVoucherCode(rs.getString("VoucherCode"));
        v.setDescription(rs.getString("Description"));
        v.setDiscountType(rs.getString("DiscountType"));
        v.setDiscountValue(rs.getBigDecimal("DiscountValue"));
        v.setMinOrderAmount(rs.getBigDecimal("MinOrderAmount"));
        v.setMaxDiscount(rs.getBigDecimal("MaxDiscount"));

        Timestamp startTs = rs.getTimestamp("StartDate");
        if (startTs != null) {
            v.setStartDate(startTs.toLocalDateTime());
        }

        Timestamp endTs = rs.getTimestamp("EndDate");
        if (endTs != null) {
            v.setEndDate(endTs.toLocalDateTime());
        }

        int usageLimit = rs.getInt("UsageLimit");
        if (rs.wasNull()) {
            v.setUsageLimit(null);
        } else {
            v.setUsageLimit(usageLimit);
        }

        v.setUsedCount(rs.getInt("UsedCount"));
        v.setStatus(rs.getString("Status"));

        int createdBy = rs.getInt("CreatedBy");
        if (rs.wasNull()) {
            v.setCreatedBy(null);
        } else {
            v.setCreatedBy(createdBy);
        }

        Timestamp createdTs = rs.getTimestamp("CreatedAt");
        if (createdTs != null) {
            v.setCreatedAt(createdTs.toLocalDateTime());
        }

        return v;
    }
}
