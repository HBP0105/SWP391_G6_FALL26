package com.swp391.dao.Admin;

import com.swp391.model.Category;
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
 * Data Access Object for Admin Category Management.
 * Uses clean standard SQL Text Blocks with LEFT JOIN and GROUP BY (no string concatenation).
 */
public class CategoryDAO {

    private final DBContext dbContext;

    public CategoryDAO() {
        this.dbContext = new DBContext();
    }

    /**
     * Get paginated list of categories with product count using standard SQL.
     */
    public List<Category> getCategories(String keyword, String status, int offset, int pageSize) {
        List<Category> list = new ArrayList<>();

        String sql = """
                SELECT c.CategoryID, c.CategoryName, c.Description, c.Status,
                       c.CreatedAt, c.UpdatedAt,
                       COUNT(p.ProductID) AS ProductCount
                FROM Categories c
                LEFT JOIN Products p ON c.CategoryID = p.CategoryID
                WHERE (? IS NULL OR c.CategoryName LIKE ? OR c.Description LIKE ?)
                  AND (? = 'ALL' OR c.Status = ?)
                GROUP BY c.CategoryID, c.CategoryName, c.Description, c.Status, c.CreatedAt, c.UpdatedAt
                ORDER BY c.CategoryID DESC
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
                    Category cat = new Category();
                    cat.setCategoryId(rs.getInt("CategoryID"));
                    cat.setCategoryName(rs.getString("CategoryName"));
                    cat.setDescription(rs.getString("Description"));
                    cat.setStatus(rs.getString("Status"));

                    Timestamp createdTs = rs.getTimestamp("CreatedAt");
                    if (createdTs != null) {
                        cat.setCreatedAt(createdTs.toLocalDateTime());
                    }
                    Timestamp updatedTs = rs.getTimestamp("UpdatedAt");
                    if (updatedTs != null) {
                        cat.setUpdatedAt(updatedTs.toLocalDateTime());
                    }
                    cat.setProductCount(rs.getInt("ProductCount"));
                    list.add(cat);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Count total categories matching criteria using standard SQL.
     */
    public int countCategories(String keyword, String status) {
        String sql = """
                SELECT COUNT(*)
                FROM Categories c
                WHERE (? IS NULL OR c.CategoryName LIKE ? OR c.Description LIKE ?)
                  AND (? = 'ALL' OR c.Status = ?)
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
     * Get summary KPI statistics for categories.
     */
    public Map<String, Integer> getCategoryStats() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = """
                SELECT
                    COUNT(*) AS totalCount,
                    COALESCE(SUM(CASE WHEN Status = 'ACTIVE' THEN 1 ELSE 0 END), 0) AS activeCount,
                    COALESCE(SUM(CASE WHEN Status = 'INACTIVE' THEN 1 ELSE 0 END), 0) AS inactiveCount
                FROM Categories
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
     * Find category by ID.
     */
    public Category getCategoryById(int categoryId) {
        String sql = """
                SELECT c.CategoryID, c.CategoryName, c.Description, c.Status,
                       c.CreatedAt, c.UpdatedAt,
                       (SELECT COUNT(*) FROM Products p WHERE p.CategoryID = c.CategoryID) AS ProductCount
                FROM Categories c
                WHERE c.CategoryID = ?
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Category cat = new Category();
                    cat.setCategoryId(rs.getInt("CategoryID"));
                    cat.setCategoryName(rs.getString("CategoryName"));
                    cat.setDescription(rs.getString("Description"));
                    cat.setStatus(rs.getString("Status"));
                    Timestamp createdTs = rs.getTimestamp("CreatedAt");
                    if (createdTs != null) {
                        cat.setCreatedAt(createdTs.toLocalDateTime());
                    }
                    Timestamp updatedTs = rs.getTimestamp("UpdatedAt");
                    if (updatedTs != null) {
                        cat.setUpdatedAt(updatedTs.toLocalDateTime());
                    }
                    cat.setProductCount(rs.getInt("ProductCount"));
                    return cat;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Check if a category name already exists (case-insensitive) using clean standard SQL.
     */
    public boolean isCategoryNameExists(String name, Integer excludeId) {
        String sql = """
                SELECT 1
                FROM Categories
                WHERE LOWER(CategoryName) = LOWER(?)
                  AND (? IS NULL OR CategoryID <> ?)
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
     * Insert a new category and return generated ID.
     */
    public int insertCategory(Category category) {
        String sql = """
                INSERT INTO Categories (CategoryName, Description, Status, CreatedAt)
                VALUES (?, ?, ?, GETDATE())
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setNString(1, category.getCategoryName());
            ps.setNString(2, category.getDescription());
            ps.setString(3, category.getStatus());

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
     * Update an existing category.
     */
    public boolean updateCategory(Category category) {
        String sql = """
                UPDATE Categories
                SET CategoryName = ?, Description = ?, Status = ?, UpdatedAt = GETDATE()
                WHERE CategoryID = ?
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setNString(1, category.getCategoryName());
            ps.setNString(2, category.getDescription());
            ps.setString(3, category.getStatus());
            ps.setInt(4, category.getCategoryId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update only category status.
     */
    public boolean updateCategoryStatus(int categoryId, String status) {
        String sql = """
                UPDATE Categories
                SET Status = ?, UpdatedAt = GETDATE()
                WHERE CategoryID = ?
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, categoryId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
