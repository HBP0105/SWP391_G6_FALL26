package com.swp391.dao.Manager;

import com.swp391.model.Category;
import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class inventoryDao {

    public List<Map<String, Object>> getInventoryProducts() {
        return getInventoryProducts(null, null, null, null, null, null);
    }

    public List<Map<String, Object>> getInventoryProducts(
            String keyword,
            Integer categoryId,
            String stock,
            String sort,
            Integer offset,
            Integer pageSize) {

        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT
                p.ProductID,
                p.ProductName,
                p.StockQuantity,
                p.ImageURL,
                p.UpdatedAt,
                c.CategoryName
            FROM Products p
            LEFT JOIN Categories c
                ON p.CategoryID = c.CategoryID
            WHERE 1 = 1
        """);

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, categoryId, stock);
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
                    Map<String, Object> item = new HashMap<>();

                    item.put("productId", rs.getInt("ProductID"));
                    item.put("productName", rs.getString("ProductName"));
                    item.put("stockQuantity", rs.getInt("StockQuantity"));
                    item.put("imageURL", rs.getString("ImageURL"));
                    item.put("categoryName", rs.getString("CategoryName"));
                    item.put("updatedAt", rs.getTimestamp("UpdatedAt"));

                    list.add(item);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countInventoryProducts(
            String keyword,
            Integer categoryId,
            String stock) {

        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*)
            FROM Products p
            LEFT JOIN Categories c
                ON p.CategoryID = c.CategoryID
            WHERE 1 = 1
        """);

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, categoryId, stock);

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

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();

        String sql = """
            SELECT CategoryID, CategoryName
            FROM Categories
            WHERE Status = 'ACTIVE'
            ORDER BY CategoryName
        """;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getInt("CategoryID"));
                category.setCategoryName(rs.getString("CategoryName"));
                list.add(category);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private void appendFilters(
            StringBuilder sql,
            List<Object> params,
            String keyword,
            Integer categoryId,
            String stock) {

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (p.ProductName LIKE ? OR c.CategoryName LIKE ?)");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
        }

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.CategoryID = ?");
            params.add(categoryId);
        }

        if ("in".equalsIgnoreCase(stock)) {
            sql.append(" AND p.StockQuantity > 10");
        } else if ("low".equalsIgnoreCase(stock)) {
            sql.append(" AND p.StockQuantity BETWEEN 1 AND 10");
        } else if ("out".equalsIgnoreCase(stock)) {
            sql.append(" AND p.StockQuantity = 0");
        }
    }

    private void appendSort(StringBuilder sql, String sort) {
        if ("stock_asc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY p.StockQuantity ASC, p.ProductID ASC");
        } else if ("stock_desc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY p.StockQuantity DESC, p.ProductID ASC");
        } else if ("name_asc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY p.ProductName ASC");
        } else if ("name_desc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY p.ProductName DESC");
        } else if ("updated_desc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY p.UpdatedAt DESC, p.ProductID DESC");
        } else {
            sql.append(" ORDER BY p.ProductID ASC");
        }
    }

    public List<Map<String, Object>> getRecentTransactions() {
        return getRecentTransactions(0, 10);
    }

    public List<Map<String, Object>> getRecentTransactions(int offset, int pageSize) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
            SELECT
                it.TransactionID,
                it.ProductID,
                p.ProductName,
                it.TransactionType,
                it.Quantity,
                it.PreviousQuantity,
                it.NewQuantity,
                it.Reason,
                it.CreatedAt
            FROM InventoryTransactions it
            LEFT JOIN Products p
                ON it.ProductID = p.ProductID
            ORDER BY it.CreatedAt DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, offset);
            ps.setInt(2, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();

                    item.put("transactionId", rs.getInt("TransactionID"));
                    item.put("productId", rs.getInt("ProductID"));
                    item.put("productName", rs.getString("ProductName"));
                    item.put("transactionType", rs.getString("TransactionType"));
                    item.put("quantity", rs.getInt("Quantity"));
                    item.put("previousQuantity", rs.getInt("PreviousQuantity"));
                    item.put("newQuantity", rs.getInt("NewQuantity"));
                    item.put("reason", rs.getString("Reason"));
                    item.put("createdAt", rs.getTimestamp("CreatedAt"));

                    list.add(item);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countRecentTransactions() {
        String sql = "SELECT COUNT(*) FROM InventoryTransactions";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int getTotalProducts() {
        String sql = """
            SELECT COUNT(*)
            FROM Products
        """;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int getInStockProducts() {
        String sql = """
            SELECT COUNT(*)
            FROM Products
            WHERE StockQuantity > 10
        """;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int getLowStockProducts() {
        String sql = """
            SELECT COUNT(*)
            FROM Products
            WHERE StockQuantity > 0
              AND StockQuantity <= 10
        """;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int getOutOfStockProducts() {
        String sql = """
            SELECT COUNT(*)
            FROM Products
            WHERE StockQuantity = 0
        """;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }
}