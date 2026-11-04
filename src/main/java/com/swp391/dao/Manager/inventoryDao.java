package com.swp391.dao.Manager;

import com.swp391.model.Category;
import com.swp391.model.Product;
import java.sql.Types;
import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.time.LocalDate;
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

        try (Connection conn = new DBContext().getConnection();
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

        try (Connection conn = new DBContext().getConnection();
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

        try (Connection conn = new DBContext().getConnection();
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
        return getRecentTransactions(null, null, null, null, 0, 10);
    }

    public List<Map<String, Object>> getRecentTransactions(int offset, int pageSize) {
        return getRecentTransactions(null, null, null, null, offset, pageSize);
    }

    public List<Map<String, Object>> getRecentTransactions(
            String keyword,
            String transactionType,
            LocalDate fromDate,
            LocalDate toDate,
            int offset,
            int pageSize) {

        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
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
            WHERE 1 = 1
        """);

        List<Object> params = new ArrayList<>();
        appendTransactionFilters(sql, params, keyword, transactionType, fromDate, toDate);
        sql.append(" ORDER BY it.CreatedAt DESC, it.TransactionID DESC");
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();

                    item.put("transactionId", rs.getLong("TransactionID"));
                    item.put("productId", rs.getInt("ProductID"));
                    item.put("productName", rs.getString("ProductName"));
                    item.put("transactionType", rs.getString("TransactionType"));

                    int qty = rs.getInt("Quantity");
                    int prev = rs.getInt("PreviousQuantity");
                    int next = rs.getInt("NewQuantity");
                    if (next < prev && qty > 0) {
                        qty = -qty;
                    }

                    item.put("quantity", qty);
                    item.put("previousQuantity", prev);
                    item.put("newQuantity", next);
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
        return countRecentTransactions(null, null, null, null);
    }

    public int countRecentTransactions(
            String keyword,
            String transactionType,
            LocalDate fromDate,
            LocalDate toDate) {

        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*)
            FROM InventoryTransactions it
            LEFT JOIN Products p
                ON it.ProductID = p.ProductID
            WHERE 1 = 1
        """);

        List<Object> params = new ArrayList<>();
        appendTransactionFilters(sql, params, keyword, transactionType, fromDate, toDate);

        try (Connection conn = new DBContext().getConnection();
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

    private void appendTransactionFilters(
            StringBuilder sql,
            List<Object> params,
            String keyword,
            String transactionType,
            LocalDate fromDate,
            LocalDate toDate) {

        if (keyword != null && !keyword.isBlank()) {
            sql.append("""
                AND (
                    LOWER(REPLACE(ISNULL(p.ProductName, ''), ' ', '')) LIKE ?
                    OR LOWER(REPLACE(ISNULL(it.Reason, ''), ' ', '')) LIKE ?
                    OR CAST(it.ProductID AS VARCHAR(20)) LIKE ?
                    OR CAST(it.TransactionID AS VARCHAR(20)) LIKE ?
                )
            """);
            String pattern = "%" + keyword.toLowerCase() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }

        if (transactionType != null && !transactionType.isBlank()) {
            sql.append(" AND it.TransactionType = ?");
            params.add(transactionType);
        }

        if (fromDate != null) {
            sql.append(" AND CAST(it.CreatedAt AS DATE) >= ?");
            params.add(Date.valueOf(fromDate));
        }

        if (toDate != null) {
            sql.append(" AND CAST(it.CreatedAt AS DATE) <= ?");
            params.add(Date.valueOf(toDate));
        }
    }

    public int getTotalProducts() {
        String sql = """
            SELECT COUNT(*)
            FROM Products
        """;

        try (Connection conn = new DBContext().getConnection();
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

        try (Connection conn = new DBContext().getConnection();
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

        try (Connection conn = new DBContext().getConnection();
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

        try (Connection conn = new DBContext().getConnection();
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
    public Product getProductById(int id) {
        String sql = """
            SELECT p.ProductID, p.ProductName, p.StockQuantity
            FROM Products p
            WHERE p.ProductID = ?
        """;
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("ProductID"));
                    p.setProductName(rs.getString("ProductName"));
                    p.setStockQuantity(rs.getInt("StockQuantity"));
                    return p;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean adjustStock(
            int productId,
            String transactionType,
            int quantity,
            int previousQuantity,
            int newQuantity,
            String reason,
            Integer createdBy) {

        String updateSql = "UPDATE Products SET StockQuantity = ?, UpdatedAt = GETDATE() WHERE ProductID = ?";
        String insertTxSql = """
            INSERT INTO InventoryTransactions
            (ProductID, TransactionType, Quantity, PreviousQuantity, NewQuantity, Reason, CreatedBy, CreatedAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())
        """;

        try (Connection conn = new DBContext().getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                 PreparedStatement psInsert = conn.prepareStatement(insertTxSql)) {

                psUpdate.setInt(1, newQuantity);
                psUpdate.setInt(2, productId);
                int updated = psUpdate.executeUpdate();

                psInsert.setInt(1, productId);
                psInsert.setString(2, transactionType);
                psInsert.setInt(3, quantity);
                psInsert.setInt(4, previousQuantity);
                psInsert.setInt(5, newQuantity);
                if (reason != null && !reason.isBlank()) {
                    psInsert.setString(6, reason.trim());
                } else {
                    psInsert.setNull(6, Types.NVARCHAR);
                }
                if (createdBy != null && createdBy > 0) {
                    try (PreparedStatement psCheck = conn.prepareStatement("SELECT 1 FROM Staff WHERE StaffID = ?")) {
                        psCheck.setInt(1, createdBy);
                        try (ResultSet rsCheck = psCheck.executeQuery()) {
                            if (rsCheck.next()) {
                                psInsert.setInt(7, createdBy);
                            } else {
                                psInsert.setNull(7, Types.INTEGER);
                            }
                        }
                    }
                } else {
                    psInsert.setNull(7, Types.INTEGER);
                }
                int inserted = psInsert.executeUpdate();

                if (updated > 0 && inserted > 0) {
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                    return false;
                }
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}