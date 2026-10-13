package com.swp391.dao;

import com.swp391.model.Product;
import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ProductDAO {

    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());
    private final DBContext dbContext;

    public ProductDAO() {
        this.dbContext = new DBContext();
    }

    private Product mapResultSetToProduct(ResultSet rs) throws Exception {
        Product p = new Product();
        p.setProductId(rs.getInt("ProductID"));
        p.setCategoryId(rs.getInt("CategoryID"));
        p.setBrandId(rs.getInt("BrandID"));
        p.setProductName(rs.getString("ProductName"));
        p.setDescription(rs.getString("Description"));
        p.setPrice(rs.getBigDecimal("Price"));
        p.setStockQuantity(rs.getInt("StockQuantity"));
        p.setConnectionType(rs.getString("ConnectionType"));

        double driverSize = rs.getDouble("DriverSize");
        if (!rs.wasNull()) {
            p.setDriverSize(driverSize);
        }

        p.setNoiseCancelling(rs.getBoolean("NoiseCancelling"));

        int batteryLife = rs.getInt("BatteryLife");
        if (!rs.wasNull()) {
            p.setBatteryLife(batteryLife);
        }

        p.setMicrophone(rs.getBoolean("Microphone"));
        p.setWaterResistance(rs.getString("WaterResistance"));

        double weight = rs.getDouble("Weight");
        if (!rs.wasNull()) {
            p.setWeight(weight);
        }

        p.setStatus(rs.getString("Status"));

        try {
            p.setCategoryName(rs.getString("CategoryName"));
        } catch (Exception e) {
            // Field optional
        }

        try {
            p.setBrandName(rs.getString("BrandName"));
        } catch (Exception e) {
            // Field optional
        }

        try {
            String img = rs.getString("ImageURL");
            if (img != null && !img.trim().isEmpty()) {
                p.setImageUrl(img);
            }
        } catch (Exception e) {
            // Field optional
        }

        return p;
    }

    /**
     * Get new products filtered by category ID (limit items).
     * NOTE: SQL Server does not support TOP (?) with PreparedStatement parameter,
     * so we embed the limit directly in the SQL string (limit is always an integer from code, safe).
     */
    public List<Product> getNewProductsByCategory(int categoryId, int limit) {
        List<Product> list = new ArrayList<>();

        String sql;
        if (categoryId > 0) {
            sql = "SELECT TOP " + limit + " p.*, c.CategoryName, b.BrandName, img.ImageURL " +
                  "FROM Products p " +
                  "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID " +
                  "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                  "LEFT JOIN ProductImages img ON p.ProductID = img.ProductID AND img.IsPrimary = 1 " +
                  "WHERE p.Status = 'ACTIVE' AND p.CategoryID = ? " +
                  "ORDER BY p.CreatedAt DESC, p.ProductID DESC";
        } else {
            sql = "SELECT TOP " + limit + " p.*, c.CategoryName, b.BrandName, img.ImageURL " +
                  "FROM Products p " +
                  "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID " +
                  "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                  "LEFT JOIN ProductImages img ON p.ProductID = img.ProductID AND img.IsPrimary = 1 " +
                  "WHERE p.Status = 'ACTIVE' " +
                  "ORDER BY p.CreatedAt DESC, p.ProductID DESC";
        }

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (categoryId > 0) {
                ps.setInt(1, categoryId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getNewProductsByCategory (categoryId=" + categoryId + ")", e);
        }
        return list;
    }

    /**
     * Get new products (all categories)
     */
    public List<Product> getNewProducts(int limit) {
        return getNewProductsByCategory(0, limit);
    }

    /**
     * Get top selling products filtered by category ID (limit items).
     */
    public List<Product> getTopSellingProductsByCategory(int categoryId, int limit) {
        List<Product> list = new ArrayList<>();

        String sql;
        if (categoryId > 0) {
            sql = "SELECT TOP " + limit + " p.*, c.CategoryName, b.BrandName, img.ImageURL, " +
                  "ISNULL((SELECT SUM(oi.Quantity) FROM OrderItems oi WHERE oi.ProductID = p.ProductID), 0) AS TotalSold " +
                  "FROM Products p " +
                  "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID " +
                  "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                  "LEFT JOIN ProductImages img ON p.ProductID = img.ProductID AND img.IsPrimary = 1 " +
                  "WHERE p.Status = 'ACTIVE' AND p.CategoryID = ? " +
                  "ORDER BY TotalSold DESC, p.ProductID ASC";
        } else {
            sql = "SELECT TOP " + limit + " p.*, c.CategoryName, b.BrandName, img.ImageURL, " +
                  "ISNULL((SELECT SUM(oi.Quantity) FROM OrderItems oi WHERE oi.ProductID = p.ProductID), 0) AS TotalSold " +
                  "FROM Products p " +
                  "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID " +
                  "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                  "LEFT JOIN ProductImages img ON p.ProductID = img.ProductID AND img.IsPrimary = 1 " +
                  "WHERE p.Status = 'ACTIVE' " +
                  "ORDER BY TotalSold DESC, p.ProductID ASC";
        }

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (categoryId > 0) {
                ps.setInt(1, categoryId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getTopSellingProductsByCategory (categoryId=" + categoryId + ")", e);
        }
        return list;
    }

    /**
     * Get top selling products (all categories)
     */
    public List<Product> getTopSellingProducts(int limit) {
        return getTopSellingProductsByCategory(0, limit);
    }

    /**
     * Get combined new products (max limitPerCategory per category).
     */
    public List<Product> getNewProductsAll(int limitPerCategory) {
        List<Product> list = new ArrayList<>();
        // Category 1 = Headphone, Category 2 = Earbud
        list.addAll(getNewProductsByCategory(1, limitPerCategory)); // Headphones
        list.addAll(getNewProductsByCategory(2, limitPerCategory)); // Earbuds
        return list;
    }

    /**
     * Get combined top selling products (max limitPerCategory per category).
     */
    public List<Product> getTopSellingProductsAll(int limitPerCategory) {
        List<Product> list = new ArrayList<>();
        list.addAll(getTopSellingProductsByCategory(1, limitPerCategory)); // Headphones
        list.addAll(getTopSellingProductsByCategory(2, limitPerCategory)); // Earbuds
        return list;
    }

    /**
     * Get product by ID
     */
    public Product getProductById(int productId) {
        String sql = "SELECT p.*, c.CategoryName, b.BrandName, img.ImageURL " +
                     "FROM Products p " +
                     "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID " +
                     "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                     "LEFT JOIN ProductImages img ON p.ProductID = img.ProductID AND img.IsPrimary = 1 " +
                     "WHERE p.ProductID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProduct(rs);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getProductById (id=" + productId + ")", e);
        }
        return null;
    }

    /**
     * Get all active products
     */
    public List<Product> getAllProducts() {
        return getNewProductsByCategory(0, 100);
    }

    /**
     * Search products by name - returns top 5 suggestions for autocomplete.
     * Uses LIKE %keyword% search, case-insensitive.
     */
    public List<Product> searchProductsByName(String keyword, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP " + limit + " p.*, c.CategoryName, b.BrandName, img.ImageURL " +
                     "FROM Products p " +
                     "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID " +
                     "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                     "LEFT JOIN ProductImages img ON p.ProductID = img.ProductID AND img.IsPrimary = 1 " +
                     "WHERE p.Status = 'ACTIVE' AND p.ProductName LIKE ? " +
                     "ORDER BY p.ProductName ASC";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in searchProductsByName (keyword=" + keyword + ")", e);
        }
        return list;
    }

    /**
     * Search products by name - returns all matching results for the product list page.
     */
    public List<Product> searchProducts(String keyword) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.CategoryName, b.BrandName, img.ImageURL " +
                     "FROM Products p " +
                     "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID " +
                     "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                     "LEFT JOIN ProductImages img ON p.ProductID = img.ProductID AND img.IsPrimary = 1 " +
                     "WHERE p.Status = 'ACTIVE' AND p.ProductName LIKE ? " +
                     "ORDER BY p.ProductName ASC";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in searchProducts (keyword=" + keyword + ")", e);
        }
        return list;
    }
}
