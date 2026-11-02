package com.swp391.dao;

import com.swp391.model.AIRecommendationItem;
import com.swp391.model.Product;
import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO to fetch customer purchases, wishlist and persist AI recommendation logs.
 */
public class AIRecommendationDAO {

    private static final Logger LOGGER = Logger.getLogger(AIRecommendationDAO.class.getName());
    private final DBContext dbContext;

    public AIRecommendationDAO() {
        this.dbContext = new DBContext();
    }

    /**
     * Get all distinct products previously purchased by customer.
     */
    public List<Product> getPurchasedProducts(int customerId) {
        List<Product> list = new ArrayList<>();
        if (customerId <= 0) return list;

        String sql = "SELECT DISTINCT p.*, b.BrandName, c.CategoryName, img.ImageURL "
                   + "FROM OrderItems oi "
                   + "JOIN Orders o ON oi.OrderID = o.OrderID "
                   + "JOIN Products p ON oi.ProductID = p.ProductID "
                   + "LEFT JOIN Brands b ON p.BrandID = b.BrandID "
                   + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                   + "OUTER APPLY (SELECT TOP 1 pi.ImageURL FROM ProductImages pi WHERE pi.ProductID = p.ProductID AND pi.IsPrimary = 1) img "
                   + "WHERE o.CustomerID = ? AND o.OrderStatus = 'DELIVERED'";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching purchased products for customer " + customerId, e);
        }
        return list;
    }

    /**
     * Get all wishlist products for customer.
     */
    public List<Product> getWishlistProducts(int customerId) {
        List<Product> list = new ArrayList<>();
        if (customerId <= 0) return list;

        String sql = "SELECT p.*, b.BrandName, c.CategoryName, img.ImageURL "
                   + "FROM Favorites f "
                   + "JOIN Products p ON f.ProductID = p.ProductID "
                   + "LEFT JOIN Brands b ON p.BrandID = b.BrandID "
                   + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                   + "OUTER APPLY (SELECT TOP 1 pi.ImageURL FROM ProductImages pi WHERE pi.ProductID = p.ProductID AND pi.IsPrimary = 1) img "
                   + "WHERE f.CustomerID = ?";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching wishlist products for customer " + customerId, e);
        }
        return list;
    }

    /**
     * Populate full Product entity into each recommendation item.
     */
    public List<AIRecommendationItem> populateProducts(List<AIRecommendationItem> items) {
        if (items == null || items.isEmpty()) return items;

        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < items.size(); i++) {
            if (i > 0) inClause.append(",");
            inClause.append(items.get(i).getProductId());
        }

        String sql = "SELECT p.*, b.BrandName, c.CategoryName, img.ImageURL, "
                   + "ISNULL(rv.AvgRating, 0) AS AvgRating, ISNULL(rv.ReviewCount, 0) AS ReviewCount "
                   + "FROM Products p "
                   + "LEFT JOIN Brands b ON p.BrandID = b.BrandID "
                   + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                   + "OUTER APPLY (SELECT TOP 1 pi.ImageURL FROM ProductImages pi WHERE pi.ProductID = p.ProductID AND pi.IsPrimary = 1) img "
                   + "OUTER APPLY (SELECT AVG(CAST(r.Rating AS FLOAT)) AS AvgRating, COUNT(*) AS ReviewCount "
                   + "             FROM Reviews r WHERE r.ProductID = p.ProductID AND r.Status = 'VISIBLE') rv "
                   + "WHERE p.ProductID IN (" + inClause + ") AND p.Status = 'ACTIVE'";

        Map<Integer, Product> map = new HashMap<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product p = mapProduct(rs);
                p.setRating(rs.getDouble("AvgRating"));
                p.setReviewCount(rs.getInt("ReviewCount"));
                map.put(p.getProductId(), p);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error populating recommendation products", e);
        }

        List<AIRecommendationItem> populated = new ArrayList<>();
        for (AIRecommendationItem item : items) {
            Product p = map.get(item.getProductId());
            if (p != null) {
                item.setProduct(p);
                populated.add(item);
            }
        }
        return populated;
    }

    /**
     * Save AI recommendation batch to AIRecommendations table.
     */
    public void saveRecommendationsToDb(Integer customerId, String recommendationType, List<AIRecommendationItem> items) {
        if (items == null || items.isEmpty()) return;

        String sql = "INSERT INTO AIRecommendations (CustomerID, ProductID, RecommendationType, SimilarityScore, BehaviorScore, FinalScore, Reason, CreatedAt) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (AIRecommendationItem item : items) {
                if (customerId != null && customerId > 0) {
                    ps.setInt(1, customerId);
                } else {
                    ps.setNull(1, java.sql.Types.INTEGER);
                }
                ps.setInt(2, item.getProductId());
                ps.setString(3, recommendationType);
                ps.setDouble(4, 0.95);
                ps.setDouble(5, 0.90);
                ps.setDouble(6, item.getScore());
                ps.setString(7, item.getReason() != null ? item.getReason() : "AI matched sound profile");
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error logging recommendations to DB: " + e.getMessage());
        }
    }

    private Product mapProduct(ResultSet rs) throws Exception {
        Product p = new Product();
        p.setProductId(rs.getInt("ProductID"));
        p.setCategoryId(rs.getInt("CategoryID"));
        p.setBrandId(rs.getInt("BrandID"));
        p.setProductName(rs.getString("ProductName"));
        p.setDescription(rs.getString("Description"));
        p.setPrice(rs.getBigDecimal("Price"));
        p.setStockQuantity(rs.getInt("StockQuantity"));
        p.setConnectionType(rs.getString("ConnectionType"));
        p.setDriverSize(rs.getDouble("DriverSize"));
        p.setNoiseCancelling(rs.getBoolean("NoiseCancelling"));
        p.setBatteryLife(rs.getInt("BatteryLife"));
        p.setMicrophone(rs.getBoolean("Microphone"));
        p.setWaterResistance(rs.getString("WaterResistance"));
        p.setWeight(rs.getDouble("Weight"));
        p.setStatus(rs.getString("Status"));
        p.setBrandName(rs.getString("BrandName"));
        p.setCategoryName(rs.getString("CategoryName"));

        String img = rs.getString("ImageURL");
        if (img != null && !img.trim().isEmpty()) {
            p.setImageUrl(img);
        } else {
            p.setImageUrl("assets/img/product01.png");
        }
        return p;
    }
}
