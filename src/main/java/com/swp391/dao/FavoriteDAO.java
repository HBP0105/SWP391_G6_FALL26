package com.swp391.dao;

import com.swp391.model.WishlistItemDTO;
import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

public class FavoriteDAO {

    private static final Logger LOGGER = Logger.getLogger(FavoriteDAO.class.getName());
    private final DBContext dbContext;

    public FavoriteDAO() {
        this.dbContext = new DBContext();
        ensureTableExists();
    }

    private void ensureTableExists() {
        String sql = "IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Favorites' AND xtype='U') " +
                     "BEGIN " +
                     "    CREATE TABLE Favorites ( " +
                     "        FavoriteID INT IDENTITY(1,1) PRIMARY KEY, " +
                     "        CustomerID INT NOT NULL, " +
                     "        ProductID INT NOT NULL, " +
                     "        CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(), " +
                     "        CONSTRAINT FK_Favorites_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE, " +
                     "        CONSTRAINT FK_Favorites_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID), " +
                     "        CONSTRAINT UQ_Favorites_Customer_Product UNIQUE (CustomerID, ProductID) " +
                     "    ); " +
                     "END";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.execute();
            System.out.println("[FavoriteDAO] Checked/Ensured table 'Favorites' exists in database.");
        } catch (Exception e) {
            System.err.println("[FavoriteDAO WARNING] ensureTableExists failed: " + e.getMessage());
            e.printStackTrace(System.err);
        }
    }

    public boolean addFavorite(int customerId, int productId) {
        System.out.println("[FavoriteDAO] addFavorite() bắt đầu: customerId=" + customerId + ", productId=" + productId);
        String checkSql = "SELECT 1 FROM Favorites WHERE CustomerID = ? AND ProductID = ?";
        String insertSql = "INSERT INTO Favorites (CustomerID, ProductID, CreatedAt) VALUES (?, ?, GETDATE())";

        try (Connection conn = dbContext.getConnection()) {
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, customerId);
                checkPs.setInt(2, productId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("[FavoriteDAO] Sản phẩm " + productId + " ĐÃ CÓ trong wishlist của Customer " + customerId);
                        return true; // Already in favorites
                    }
                }
            }

            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setInt(1, customerId);
                insertPs.setInt(2, productId);
                int affectedRows = insertPs.executeUpdate();
                System.out.println("[FavoriteDAO] ĐÃ THÊM THÀNH CÔNG sản phẩm " + productId + " cho Customer " + customerId + " (affectedRows=" + affectedRows + ")");
                return affectedRows > 0;
            }
        } catch (Exception e) {
            System.err.println("[FavoriteDAO ERROR] Thêm thất bại customerId=" + customerId + ", productId=" + productId + " -> " + e.getMessage());
            e.printStackTrace(System.err);
            LOGGER.log(Level.SEVERE, "Error adding favorite: customerId=" + customerId + ", productId=" + productId, e);
        }
        return false;
    }

    public boolean removeFavorite(int customerId, int productId) {
        System.out.println("[FavoriteDAO] removeFavorite() bắt đầu: customerId=" + customerId + ", productId=" + productId);
        String sql = "DELETE FROM Favorites WHERE CustomerID = ? AND ProductID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            int rows = ps.executeUpdate();
            System.out.println("[FavoriteDAO] Đã xóa sản phẩm " + productId + " của Customer " + customerId + " (rows=" + rows + ")");
            return rows > 0;
        } catch (Exception e) {
            System.err.println("[FavoriteDAO ERROR] Xóa thất bại customerId=" + customerId + ", productId=" + productId + " -> " + e.getMessage());
            e.printStackTrace(System.err);
            LOGGER.log(Level.SEVERE, "Error removing favorite: customerId=" + customerId + ", productId=" + productId, e);
        }
        return false;
    }

    public boolean isFavorite(int customerId, int productId) {
        String sql = "SELECT 1 FROM Favorites WHERE CustomerID = ? AND ProductID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            System.err.println("[FavoriteDAO ERROR] isFavorite error: " + e.getMessage());
            e.printStackTrace(System.err);
            LOGGER.log(Level.SEVERE, "Error checking favorite: customerId=" + customerId + ", productId=" + productId, e);
        }
        return false;
    }

    public int getFavoriteCount(int customerId) {
        String sql = "SELECT COUNT(*) FROM Favorites WHERE CustomerID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("[FavoriteDAO] getFavoriteCount cho Customer " + customerId + ": " + count);
                    return count;
                }
            }
        } catch (Exception e) {
            System.err.println("[FavoriteDAO ERROR] getFavoriteCount error: " + e.getMessage());
            e.printStackTrace(System.err);
            LOGGER.log(Level.SEVERE, "Error getting favorite count for customerId=" + customerId, e);
        }
        return 0;
    }

    public List<WishlistItemDTO> getFavoritesByCustomerId(int customerId) {
        System.out.println("[FavoriteDAO] getFavoritesByCustomerId() gọi cho customerId=" + customerId);
        List<WishlistItemDTO> list = new ArrayList<>();
        String sql = "SELECT f.FavoriteID, f.CustomerID, f.ProductID, f.CreatedAt AS FavoriteCreatedAt, " +
                "       p.ProductName, p.Description, p.Price, p.StockQuantity, p.ConnectionType, " +
                "       p.NoiseCancelling, p.BatteryLife, p.Status, " +
                "       c.CategoryName, b.BrandName, img.ImageURL, " +
                "       COALESCE(r.AvgRating, 0) AS AvgRating, " +
                "       COALESCE(r.ReviewCount, 0) AS ReviewCount " +
                "FROM Favorites f " +
                "JOIN Products p ON f.ProductID = p.ProductID " +
                "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID " +
                "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                "LEFT JOIN ProductImages img ON p.ProductID = img.ProductID AND img.IsPrimary = 1 " +
                "LEFT JOIN ( " +
                "    SELECT ProductID, ROUND(AVG(CAST(Rating AS FLOAT)), 1) AS AvgRating, COUNT(*) AS ReviewCount " +
                "    FROM Reviews " +
                "    WHERE Status = 'VISIBLE' " +
                "    GROUP BY ProductID " +
                ") r ON p.ProductID = r.ProductID " +
                "WHERE f.CustomerID = ? " +
                "ORDER BY f.CreatedAt DESC";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WishlistItemDTO item = mapResultSetToWishlistItem(rs);
                    item.setFavoriteId(rs.getInt("FavoriteID"));
                    item.setCustomerId(rs.getInt("CustomerID"));
                    Timestamp ts = rs.getTimestamp("FavoriteCreatedAt");
                    if (ts != null) {
                        item.setAddedAt(ts.toLocalDateTime());
                    }
                    list.add(item);
                }
            }
            System.out.println("[FavoriteDAO] Đã load " + list.size() + " items cho Customer " + customerId);
        } catch (Exception e) {
            System.err.println("[FavoriteDAO ERROR] getFavoritesByCustomerId thất bại: " + e.getMessage());
            e.printStackTrace(System.err);
            LOGGER.log(Level.SEVERE, "Error getting favorites for customerId=" + customerId, e);
        }
        return list;
    }

    public List<WishlistItemDTO> getWishlistItemsByProductIds(List<Integer> productIds) {
        if (productIds == null || productIds.isEmpty()) {
            return Collections.emptyList();
        }

        List<WishlistItemDTO> list = new ArrayList<>();
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < productIds.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }

        String sql = "SELECT 0 AS FavoriteID, 0 AS CustomerID, p.ProductID, NULL AS FavoriteCreatedAt, " +
                "       p.ProductName, p.Description, p.Price, p.StockQuantity, p.ConnectionType, " +
                "       p.NoiseCancelling, p.BatteryLife, p.Status, " +
                "       c.CategoryName, b.BrandName, img.ImageURL, " +
                "       COALESCE(r.AvgRating, 0) AS AvgRating, " +
                "       COALESCE(r.ReviewCount, 0) AS ReviewCount " +
                "FROM Products p " +
                "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID " +
                "LEFT JOIN Brands b ON p.BrandID = b.BrandID " +
                "LEFT JOIN ProductImages img ON p.ProductID = img.ProductID AND img.IsPrimary = 1 " +
                "LEFT JOIN ( " +
                "    SELECT ProductID, ROUND(AVG(CAST(Rating AS FLOAT)), 1) AS AvgRating, COUNT(*) AS ReviewCount " +
                "    FROM Reviews " +
                "    WHERE Status = 'VISIBLE' " +
                "    GROUP BY ProductID " +
                ") r ON p.ProductID = r.ProductID " +
                "WHERE p.ProductID IN (" + placeholders + ") " +
                "ORDER BY p.ProductID DESC";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < productIds.size(); i++) {
                ps.setInt(i + 1, productIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WishlistItemDTO item = mapResultSetToWishlistItem(rs);
                    item.setAddedAt(LocalDateTime.now());
                    list.add(item);
                }
            }
        } catch (Exception e) {
            System.err.println("[FavoriteDAO ERROR] getWishlistItemsByProductIds thất bại: " + e.getMessage());
            e.printStackTrace(System.err);
            LOGGER.log(Level.SEVERE, "Error getting wishlist items by product IDs", e);
        }
        return list;
    }

    public void syncGuestWishlist(int customerId, List<Integer> productIds) {
        if (productIds == null || productIds.isEmpty()) return;
        for (Integer pid : productIds) {
            if (pid != null) {
                addFavorite(customerId, pid);
            }
        }
    }

    private WishlistItemDTO mapResultSetToWishlistItem(ResultSet rs) throws Exception {
        WishlistItemDTO item = new WishlistItemDTO();
        item.setProductId(rs.getInt("ProductID"));
        item.setProductName(rs.getString("ProductName"));
        item.setDescription(rs.getString("Description"));
        item.setPrice(rs.getBigDecimal("Price"));
        item.setStockQuantity(rs.getInt("StockQuantity"));
        item.setConnectionType(rs.getString("ConnectionType"));
        item.setNoiseCancelling(rs.getBoolean("NoiseCancelling"));

        int battery = rs.getInt("BatteryLife");
        if (!rs.wasNull()) {
            item.setBatteryLife(battery);
        }

        item.setStatus(rs.getString("Status"));
        item.setCategoryName(rs.getString("CategoryName"));
        item.setBrandName(rs.getString("BrandName"));

        String img = rs.getString("ImageURL");
        if (img != null && !img.trim().isEmpty()) {
            item.setImageUrl(img);
        }

        item.setRating(rs.getDouble("AvgRating"));
        item.setReviewCount(rs.getInt("ReviewCount"));
        return item;
    }

    /**
     * Đồng bộ / lưu toàn bộ danh sách wishlist từ session vào database.
     * Được gọi khi người dùng thoát ra (Logout) hoặc khi session hết hạn (Session timeout).
     */
    public boolean saveFavoritesForCustomer(int customerId, List<WishlistItemDTO> items) {
        System.out.println("[FavoriteDAO] saveFavoritesForCustomer() BẮT ĐẦU: Customer " + customerId + " với " + (items != null ? items.size() : 0) + " items.");
        String deleteSql = "DELETE FROM Favorites WHERE CustomerID = ?";
        String insertSql = "INSERT INTO Favorites (CustomerID, ProductID, CreatedAt) VALUES (?, ?, ?)";

        try (Connection conn = dbContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement delPs = conn.prepareStatement(deleteSql)) {
                    delPs.setInt(1, customerId);
                    int deletedRows = delPs.executeUpdate();
                    System.out.println("[FavoriteDAO] Đã dọn dẹp " + deletedRows + " bản ghi cũ của Customer " + customerId);
                }

                if (items != null && !items.isEmpty()) {
                    try (PreparedStatement insPs = conn.prepareStatement(insertSql)) {
                        Set<Integer> insertedProductIds = new HashSet<>();
                        for (WishlistItemDTO item : items) {
                            if (item != null && item.getProductId() > 0 && insertedProductIds.add(item.getProductId())) {
                                insPs.setInt(1, customerId);
                                insPs.setInt(2, item.getProductId());
                                LocalDateTime addedAt = item.getAddedAt() != null ? item.getAddedAt() : LocalDateTime.now();
                                insPs.setTimestamp(3, Timestamp.valueOf(addedAt));
                                insPs.addBatch();
                            }
                        }
                        int[] results = insPs.executeBatch();
                        System.out.println("[FavoriteDAO] Batch insert hoàn tất: " + results.length + " bản ghi mới cho Customer " + customerId);
                    }
                }

                conn.commit();
                System.out.println("[FavoriteDAO] ĐÃ LƯU THÀNH CÔNG wishlist vào database cho Customer " + customerId);
                return true;
            } catch (Exception ex) {
                conn.rollback();
                System.err.println("[FavoriteDAO ERROR] Lỗi khi lưu wishlist, rollback: " + ex.getMessage());
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            System.err.println("[FavoriteDAO ERROR] saveFavoritesForCustomer thất bại: " + e.getMessage());
            e.printStackTrace(System.err);
            LOGGER.log(Level.SEVERE, "Error saving favorites for customerId=" + customerId, e);
        }
        return false;
    }
}
