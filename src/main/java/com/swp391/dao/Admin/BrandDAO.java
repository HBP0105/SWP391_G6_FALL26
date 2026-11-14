package com.swp391.dao.Admin;

import com.swp391.model.Brand;
import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for Admin Brand Management.
 * Uses clean standard SQL Text Blocks with LEFT JOIN and GROUP BY (no string concatenation).
 */
public class BrandDAO {

    private final DBContext dbContext;

    public BrandDAO() {
        this.dbContext = new DBContext();
    }

    /**
     * Get paginated list of brands with product count using standard SQL.
     */
    public List<Brand> getBrands(String keyword, String status, int offset, int pageSize) {
        List<Brand> list = new ArrayList<>();

        String sql = """
                SELECT b.BrandID, b.BrandName, b.Description, b.Status,
                       b.CreatedAt, b.UpdatedAt,
                       COUNT(p.ProductID) AS ProductCount
                FROM Brands b
                LEFT JOIN Products p ON b.BrandID = p.BrandID
                WHERE (? IS NULL OR b.BrandName LIKE ? OR b.Description LIKE ?)
                  AND (? = 'ALL' OR b.Status = ?)
                GROUP BY b.BrandID, b.BrandName, b.Description, b.Status, b.CreatedAt, b.UpdatedAt
                ORDER BY b.BrandID DESC
                OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
                """;

        String kw = (keyword == null || keyword.isBlank()) ? null : "%" + keyword.trim() + "%";
        String st = (status == null || status.isBlank()) ? "ALL" : status.trim().toUpperCase();

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, st);
            ps.setString(5, st);
            ps.setInt(6, offset);
            ps.setInt(7, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Brand brand = new Brand();
                    brand.setBrandId(rs.getInt("BrandID"));
                    brand.setBrandName(rs.getString("BrandName"));
                    brand.setDescription(rs.getString("Description"));
                    brand.setStatus(rs.getString("Status"));

                    Timestamp createdTs = rs.getTimestamp("CreatedAt");
                    if (createdTs != null) {
                        brand.setCreatedAt(createdTs.toLocalDateTime());
                    }
                    Timestamp updatedTs = rs.getTimestamp("UpdatedAt");
                    if (updatedTs != null) {
                        brand.setUpdatedAt(updatedTs.toLocalDateTime());
                    }
                    brand.setProductCount(rs.getInt("ProductCount"));
                    list.add(brand);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Count total brands matching search and status criteria using standard SQL.
     */
    public int countBrands(String keyword, String status) {
        String sql = """
                SELECT COUNT(*)
                FROM Brands b
                WHERE (? IS NULL OR b.BrandName LIKE ? OR b.Description LIKE ?)
                  AND (? = 'ALL' OR b.Status = ?)
                """;

        String kw = (keyword == null || keyword.isBlank()) ? null : "%" + keyword.trim() + "%";
        String st = (status == null || status.isBlank()) ? "ALL" : status.trim().toUpperCase();

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ps.setString(4, st);
            ps.setString(5, st);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Get summary KPI statistics for brands.
     */
    public Map<String, Integer> getBrandStats() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = """
                SELECT
                    COUNT(*) AS totalCount,
                    COALESCE(SUM(CASE WHEN Status = 'ACTIVE' THEN 1 ELSE 0 END), 0) AS activeCount,
                    COALESCE(SUM(CASE WHEN Status = 'INACTIVE' THEN 1 ELSE 0 END), 0) AS inactiveCount
                FROM Brands
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                stats.put("totalCount", rs.getInt("totalCount"));
                stats.put("activeCount", rs.getInt("activeCount"));
                stats.put("inactiveCount", rs.getInt("inactiveCount"));
            }
        } catch (Exception e) {
            stats.put("totalCount", 0);
            stats.put("activeCount", 0);
            stats.put("inactiveCount", 0);
        }
        return stats;
    }

    /**
     * Find brand by ID.
     */
    public Brand getBrandById(int brandId) {
        String sql = """
                SELECT b.BrandID, b.BrandName, b.Description, b.Status,
                       b.CreatedAt, b.UpdatedAt,
                       (SELECT COUNT(*) FROM Products p WHERE p.BrandID = b.BrandID) AS ProductCount
                FROM Brands b
                WHERE b.BrandID = ?
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, brandId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Brand brand = new Brand();
                    brand.setBrandId(rs.getInt("BrandID"));
                    brand.setBrandName(rs.getString("BrandName"));
                    brand.setDescription(rs.getString("Description"));
                    brand.setStatus(rs.getString("Status"));
                    Timestamp createdTs = rs.getTimestamp("CreatedAt");
                    if (createdTs != null) {
                        brand.setCreatedAt(createdTs.toLocalDateTime());
                    }
                    Timestamp updatedTs = rs.getTimestamp("UpdatedAt");
                    if (updatedTs != null) {
                        brand.setUpdatedAt(updatedTs.toLocalDateTime());
                    }
                    brand.setProductCount(rs.getInt("ProductCount"));
                    return brand;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Check if a brand name already exists (case-insensitive) using standard SQL.
     */
    public boolean isBrandNameExists(String name, Integer excludeId) {
        String sql = """
                SELECT 1
                FROM Brands
                WHERE LOWER(BrandName) = LOWER(?)
                  AND (? IS NULL OR BrandID <> ?)
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
                ps.setInt(3, excludeId);
            } else {
                ps.setNull(2, Types.INTEGER);
                ps.setNull(3, Types.INTEGER);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Insert a new brand and return generated ID.
     */
    public int insertBrand(Brand brand) {
        String sql = """
                INSERT INTO Brands (BrandName, Description, Status, CreatedAt)
                VALUES (?, ?, ?, GETDATE())
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setNString(1, brand.getBrandName());
            ps.setNString(2, brand.getDescription());
            ps.setString(3, brand.getStatus());

            if (ps.executeUpdate() > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Update an existing brand.
     */
    public boolean updateBrand(Brand brand) {
        String sql = """
                UPDATE Brands
                SET BrandName = ?, Description = ?, Status = ?, UpdatedAt = GETDATE()
                WHERE BrandID = ?
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setNString(1, brand.getBrandName());
            ps.setNString(2, brand.getDescription());
            ps.setString(3, brand.getStatus());
            ps.setInt(4, brand.getBrandId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update only brand status.
     */
    public boolean updateBrandStatus(int brandId, String status) {
        String sql = """
                UPDATE Brands
                SET Status = ?, UpdatedAt = GETDATE()
                WHERE BrandID = ?
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, brandId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
