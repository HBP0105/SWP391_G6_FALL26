package com.swp391.dao;

import com.swp391.model.AIRecommendation;
import com.swp391.util.DBContext;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Data Access Object executing SQL queries for AI Performance & Configuration Reporting (Screen 4).
 * Uses clean SQL Text Blocks without string concatenations, aligned with Screens 1, 2, and 3.
 */
public class AIPerformanceDAO {

    private static final Logger LOGGER = Logger.getLogger(AIPerformanceDAO.class.getName());
    private final DBContext dbContext;

    public AIPerformanceDAO() {
        this.dbContext = new DBContext();
    }

    public AIPerformanceDAO(DBContext dbContext) {
        this.dbContext = dbContext;
    }

    private void setDateParameters(PreparedStatement ps, int startIndex, String startDate, String endDate) throws SQLException {
        ps.setString(startIndex, startDate);
        ps.setString(startIndex + 1, startDate);
        ps.setString(startIndex + 2, endDate);
        ps.setString(startIndex + 3, endDate);
    }

    private String sanitizeType(String recommendationType) {
        if (recommendationType == null || recommendationType.trim().isEmpty() || "ALL".equalsIgnoreCase(recommendationType.trim())) {
            return null;
        }
        return recommendationType.trim();
    }

    /**
     * Aggregates overall AI performance metrics (Total Recommendations, Clicks, Purchases, CTR, Conversion Rate, Avg Scores).
     */
    public Map<String, Object> getAIPerformanceSummary(String startDate, String endDate, String recommendationType) {
        Map<String, Object> summary = new HashMap<>();
        String recType = sanitizeType(recommendationType);

        String sql = """
                SELECT 
                  COUNT(*) AS totalRecommendations, 
                  SUM(CASE WHEN IsClicked = 1 THEN 1 ELSE 0 END) AS totalClicked, 
                  SUM(CASE WHEN IsPurchased = 1 THEN 1 ELSE 0 END) AS totalPurchased, 
                  AVG(SimilarityScore) AS avgSimilarityScore, 
                  AVG(BehaviorScore) AS avgBehaviorScore, 
                  AVG(FinalScore) AS avgFinalScore 
                FROM AIRecommendations 
                WHERE (? IS NULL OR CreatedAt >= ?)
                  AND (? IS NULL OR CreatedAt < ?)
                  AND (? IS NULL OR RecommendationType = ?)
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            setDateParameters(ps, 1, startDate, endDate);
            ps.setString(5, recType);
            ps.setString(6, recType);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    long totalRecs = rs.getLong("totalRecommendations");
                    long totalClicked = rs.getLong("totalClicked");
                    long totalPurchased = rs.getLong("totalPurchased");

                    double avgSim = rs.getDouble("avgSimilarityScore");
                    double avgBeh = rs.getDouble("avgBehaviorScore");
                    double avgFinal = rs.getDouble("avgFinalScore");

                    summary.put("totalRecommendations", totalRecs);
                    summary.put("totalClicked", totalClicked);
                    summary.put("totalPurchased", totalPurchased);
                    summary.put("avgSimilarityScore", avgSim);
                    summary.put("avgBehaviorScore", avgBeh);
                    summary.put("avgFinalScore", avgFinal);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getAIPerformanceSummary", e);
            throw new RuntimeException("Lỗi truy vấn dữ liệu tổng quan hiệu năng AI từ cơ sở dữ liệu!", e);
        }

        return summary;
    }

    /**
     * Gets breakdown of recommendations, clicks, purchases, CTR, and conversion rate grouped by RecommendationType.
     */
    public List<Map<String, Object>> getPerformanceByType(String startDate, String endDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
                SELECT 
                  RecommendationType, 
                  COUNT(*) AS totalCount, 
                  SUM(CASE WHEN IsClicked = 1 THEN 1 ELSE 0 END) AS clickedCount, 
                  SUM(CASE WHEN IsPurchased = 1 THEN 1 ELSE 0 END) AS purchasedCount, 
                  AVG(FinalScore) AS avgScore 
                FROM AIRecommendations 
                WHERE (? IS NULL OR CreatedAt >= ?)
                  AND (? IS NULL OR CreatedAt < ?)
                GROUP BY RecommendationType 
                ORDER BY totalCount DESC
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            setDateParameters(ps, 1, startDate, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    String type = rs.getString("RecommendationType");
                    long total = rs.getLong("totalCount");
                    long clicked = rs.getLong("clickedCount");
                    long purchased = rs.getLong("purchasedCount");
                    double avgScore = rs.getDouble("avgScore");

                    map.put("recommendationType", type);
                    map.put("totalCount", total);
                    map.put("clickedCount", clicked);
                    map.put("purchasedCount", purchased);
                    map.put("avgScore", avgScore);

                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getPerformanceByType", e);
            throw new RuntimeException("Lỗi truy vấn hiệu năng AI theo phân loại từ cơ sở dữ liệu!", e);
        }

        return list;
    }

    /**
     * Retrieves top recommended products with recommendation count, CTR, conversion rate and product details.
     */
    public List<Map<String, Object>> getTopRecommendedProducts(String startDate, String endDate, String recommendationType, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String recType = sanitizeType(recommendationType);

        String sql = """
                SELECT TOP (?) 
                  p.ProductID, p.ProductName, c.CategoryName, b.BrandName, p.Price, 
                  COUNT(r.RecommendationID) AS recommendCount, 
                  SUM(CASE WHEN r.IsClicked = 1 THEN 1 ELSE 0 END) AS clickedCount, 
                  SUM(CASE WHEN r.IsPurchased = 1 THEN 1 ELSE 0 END) AS purchasedCount, 
                  AVG(r.FinalScore) AS avgFinalScore 
                FROM AIRecommendations r 
                JOIN Products p ON r.ProductID = p.ProductID 
                JOIN Categories c ON p.CategoryID = c.CategoryID 
                JOIN Brands b ON p.BrandID = b.BrandID 
                WHERE (? IS NULL OR r.CreatedAt >= ?)
                  AND (? IS NULL OR r.CreatedAt < ?)
                  AND (? IS NULL OR r.RecommendationType = ?)
                GROUP BY p.ProductID, p.ProductName, c.CategoryName, b.BrandName, p.Price 
                ORDER BY recommendCount DESC, clickedCount DESC
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit > 0 ? limit : 5);
            setDateParameters(ps, 2, startDate, endDate);
            ps.setString(6, recType);
            ps.setString(7, recType);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    long total = rs.getLong("recommendCount");
                    long clicked = rs.getLong("clickedCount");
                    long purchased = rs.getLong("purchasedCount");
                    map.put("productID", rs.getInt("ProductID"));
                    map.put("productName", rs.getString("ProductName"));
                    map.put("categoryName", rs.getString("CategoryName"));
                    map.put("brandName", rs.getString("BrandName"));
                    map.put("price", rs.getBigDecimal("Price"));
                    map.put("recommendCount", total);
                    map.put("clickedCount", clicked);
                    map.put("purchasedCount", purchased);
                    map.put("avgFinalScore", rs.getDouble("avgFinalScore"));

                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getTopRecommendedProducts", e);
            throw new RuntimeException("Lỗi truy vấn top sản phẩm AI gợi ý từ cơ sở dữ liệu!", e);
        }

        return list;
    }

    /**
     * Retrieves recent AI Recommendations using existing model AIRecommendation & details.
     */
    public List<Map<String, Object>> getRecentRecommendationLogs(String startDate, String endDate, String recommendationType, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String recType = sanitizeType(recommendationType);

        String sql = """
                SELECT TOP (?) 
                  r.RecommendationID, r.CustomerID, r.SessionID, r.ProductID, 
                  r.RecommendationType, r.SimilarityScore, r.BehaviorScore, 
                  r.FinalScore, r.Reason, r.IsClicked, r.IsPurchased, r.CreatedAt, 
                  p.ProductName, c.FullName AS CustomerName 
                FROM AIRecommendations r 
                JOIN Products p ON r.ProductID = p.ProductID 
                LEFT JOIN Customers c ON r.CustomerID = c.CustomerID 
                WHERE (? IS NULL OR r.CreatedAt >= ?)
                  AND (? IS NULL OR r.CreatedAt < ?)
                  AND (? IS NULL OR r.RecommendationType = ?)
                ORDER BY r.CreatedAt DESC
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit > 0 ? limit : 10);
            setDateParameters(ps, 2, startDate, endDate);
            ps.setString(6, recType);
            ps.setString(7, recType);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AIRecommendation rec = new AIRecommendation();
                    rec.setRecommendationID(rs.getLong("RecommendationID"));
                    int cid = rs.getInt("CustomerID");
                    rec.setCustomerID(rs.wasNull() ? null : cid);
                    rec.setSessionID(rs.getString("SessionID"));
                    rec.setProductID(rs.getInt("ProductID"));
                    rec.setRecommendationType(rs.getString("RecommendationType"));
                    rec.setSimilarityScore(rs.getBigDecimal("SimilarityScore"));
                    rec.setBehaviorScore(rs.getBigDecimal("BehaviorScore"));
                    rec.setFinalScore(rs.getBigDecimal("FinalScore"));
                    rec.setReason(rs.getString("Reason"));
                    rec.setClicked(rs.getBoolean("IsClicked"));
                    rec.setPurchased(rs.getBoolean("IsPurchased"));
                    if (rs.getTimestamp("CreatedAt") != null) {
                        rec.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
                    }

                    Map<String, Object> map = new HashMap<>();
                    map.put("recommendation", rec);
                    map.put("productName", rs.getString("ProductName"));
                    map.put("customerName", rs.getString("CustomerName") != null ? rs.getString("CustomerName") : "Guest User");

                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getRecentRecommendationLogs", e);
            throw new RuntimeException("Lỗi truy vấn nhật ký gợi ý AI gần đây từ cơ sở dữ liệu!", e);
        }

        return list;
    }

    /**
     * Retrieves active AI Configuration from AIConfigurations table.
     * Falls back safely if table is not yet created or empty.
     */
    public Map<String, Object> getActiveAIConfiguration() {
        Map<String, Object> config = new HashMap<>();
        String sql = """
                SELECT TOP 1 
                  ConfigID, SimilarityWeight, BehaviorWeight, MinSimilarityThreshold, 
                  TopKLimit, FallbackStrategy, AlgorithmStatus, UpdatedAt, UpdatedBy 
                FROM AIConfigurations 
                ORDER BY ConfigID DESC
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                config.put("configID", rs.getInt("ConfigID"));
                BigDecimal sim = rs.getBigDecimal("SimilarityWeight");
                config.put("similarityWeight", sim != null ? sim.doubleValue() : 0.50);

                BigDecimal beh = rs.getBigDecimal("BehaviorWeight");
                config.put("behaviorWeight", beh != null ? beh.doubleValue() : 0.50);

                BigDecimal minThresh = rs.getBigDecimal("MinSimilarityThreshold");
                config.put("minSimilarityThreshold", minThresh != null ? minThresh.doubleValue() : 0.60);

                config.put("topKLimit", rs.getInt("TopKLimit") > 0 ? rs.getInt("TopKLimit") : 10);
                config.put("fallbackStrategy", rs.getString("FallbackStrategy") != null ? rs.getString("FallbackStrategy") : "COLD_START");
                config.put("algorithmStatus", rs.getString("AlgorithmStatus") != null ? rs.getString("AlgorithmStatus") : "ACTIVE");
                if (rs.getTimestamp("UpdatedAt") != null) {
                    config.put("updatedAt", rs.getTimestamp("UpdatedAt").toLocalDateTime());
                }
                config.put("updatedBy", rs.getObject("UpdatedBy"));
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Bảng AIConfigurations chưa sẵn sàng hoặc rỗng, dùng cấu hình mặc định: " + e.getMessage());
        }
        return config;
    }

    /**
     * Atomically updates AIConfigurations, recalculates AIRecommendations FinalScores, and inserts AuditLog in ONE TRANSACTION.
     */
    public boolean saveAIConfigurationWithTransaction(double simWeight, double behWeight, double minThreshold, 
        int topK, String fallback, Integer staffId, String oldData, String newData) {

        // 1. Validation kiểm tra chặt chẽ tham số tại tầng DAO (Defense in Depth)
        if (Double.isNaN(simWeight) || simWeight < 0.0 || simWeight > 1.0) {
            throw new IllegalArgumentException("Similarity Weight phải là số trong khoảng [0.0 - 1.0]. Nhận được: " + simWeight);
        }
        if (Double.isNaN(behWeight) || behWeight < 0.0 || behWeight > 1.0) {
            throw new IllegalArgumentException("Behavior Weight phải là số trong khoảng [0.0 - 1.0]. Nhận được: " + behWeight);
        }
        double weightSum = Math.round((simWeight + behWeight) * 1000.0) / 1000.0;
        if (Math.abs(weightSum - 1.0) > 0.001) {
            throw new IllegalArgumentException("Tổng Similarity Weight và Behavior Weight phải bằng 1.0. Nhận được: " + weightSum);
        }
        if (Double.isNaN(minThreshold) || minThreshold < 0.0 || minThreshold > 1.0) {
            throw new IllegalArgumentException("Minimum Similarity Threshold phải là số trong khoảng [0.0 - 1.0]. Nhận được: " + minThreshold);
        }
        if (topK < 1 || topK > 50) {
            throw new IllegalArgumentException("Giới hạn gợi ý (Top K) phải là số nguyên trong khoảng [1 - 50]. Nhận được: " + topK);
        }
        String cleanFallback = fallback != null ? fallback.trim().toUpperCase(java.util.Locale.ROOT) : "";
        if (!"COLD_START".equals(cleanFallback) && !"BEST_SELLER".equals(cleanFallback)) {
            throw new IllegalArgumentException("Chiến lược dự phòng (Fallback Strategy) không hợp lệ: " + fallback + ". Chỉ chấp nhận COLD_START hoặc BEST_SELLER.");
        }

        Connection conn = null;
        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Cập nhật hoặc thêm cấu hình bền vững vào bảng AIConfigurations
            String updateConfigSql = """
                    IF EXISTS (SELECT 1 FROM AIConfigurations)
                    BEGIN
                        UPDATE AIConfigurations
                        SET SimilarityWeight = ?, 
                            BehaviorWeight = ?, 
                            MinSimilarityThreshold = ?, 
                            TopKLimit = ?, 
                            FallbackStrategy = ?, 
                            UpdatedAt = GETDATE(), 
                            UpdatedBy = ?
                        WHERE ConfigID = (SELECT TOP 1 ConfigID FROM AIConfigurations ORDER BY ConfigID DESC);
                    END
                    ELSE
                    BEGIN
                        INSERT INTO AIConfigurations (SimilarityWeight, BehaviorWeight, MinSimilarityThreshold, TopKLimit, FallbackStrategy, AlgorithmStatus, UpdatedAt, UpdatedBy)
                        VALUES (?, ?, ?, ?, ?, 'ACTIVE', GETDATE(), ?);
                    END
                    """;

            try (PreparedStatement psConfig = conn.prepareStatement(updateConfigSql)) {
                // Tham số cho nhánh UPDATE
                psConfig.setBigDecimal(1, BigDecimal.valueOf(simWeight));
                psConfig.setBigDecimal(2, BigDecimal.valueOf(behWeight));
                psConfig.setBigDecimal(3, BigDecimal.valueOf(minThreshold));
                psConfig.setInt(4, topK);
                psConfig.setString(5, fallback != null ? fallback : "COLD_START");
                if (staffId != null) {
                    psConfig.setInt(6, staffId);
                } else {
                    psConfig.setNull(6, java.sql.Types.INTEGER);
                }

                // Tham số cho nhánh INSERT
                psConfig.setBigDecimal(7, BigDecimal.valueOf(simWeight));
                psConfig.setBigDecimal(8, BigDecimal.valueOf(behWeight));
                psConfig.setBigDecimal(9, BigDecimal.valueOf(minThreshold));
                psConfig.setInt(10, topK);
                psConfig.setString(11, fallback != null ? fallback : "COLD_START");
                if (staffId != null) {
                    psConfig.setInt(12, staffId);
                } else {
                    psConfig.setNull(12, java.sql.Types.INTEGER);
                }

                psConfig.executeUpdate();
            }

            // 2. Tác động trực tiếp lên thuật toán AI: Tính toán lại FinalScore trong bảng AIRecommendations theo trọng số mới
            String updateScoresSql = """
                    UPDATE AIRecommendations
                    SET FinalScore = ROUND((? * SimilarityScore) + (? * ISNULL(BehaviorScore, SimilarityScore)), 4)
                    """;
            try (PreparedStatement psScores = conn.prepareStatement(updateScoresSql)) {
                psScores.setBigDecimal(1, BigDecimal.valueOf(simWeight));
                psScores.setBigDecimal(2, BigDecimal.valueOf(behWeight));
                psScores.executeUpdate();
            }

            // 3. Ghi vết kiểm toán vào bảng AuditLogs
            String insertAuditSql = """
                    INSERT INTO AuditLogs (StaffID, Action, EntityName, EntityID, OldData, NewData, CreatedAt) 
                    VALUES (?, 'UPDATE_AI_CONFIG', 'AI_CONFIG', 'GLOBAL', ?, ?, GETDATE())
                    """;
            try (PreparedStatement psAudit = conn.prepareStatement(insertAuditSql)) {
                if (staffId != null) {
                    psAudit.setInt(1, staffId);
                } else {
                    psAudit.setNull(1, java.sql.Types.INTEGER);
                }
                psAudit.setString(2, oldData);
                psAudit.setString(3, newData);
                psAudit.executeUpdate();
            }

            // Commit transaction thành công toàn bộ
            conn.commit();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi transaction khi lưu cấu hình AI và nhật ký kiểm toán", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.SEVERE, "Rollback transaction thất bại", rollbackEx);
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException closeEx) {
                    LOGGER.log(Level.WARNING, "Đóng kết nối SQL thất bại", closeEx);
                }
            }
        }
    }

    /**
     * Retrieves all active products with specifications, primary image, and 512-dimension vector embedding.
     */
    public List<Map<String, Object>> getAllProductsForRecommendation() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = """
                SELECT p.ProductID, p.ProductName, p.Price, p.CategoryID, p.BrandID,
                       p.ConnectionType, p.NoiseCancelling, p.BatteryLife, p.Description,
                       p.EmbeddingVector,
                       c.CategoryName, b.BrandName,
                       img.ImageURL
                FROM Products p
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                LEFT JOIN Brands b ON p.BrandID = b.BrandID
                LEFT JOIN ProductImages img ON p.ProductID = img.ProductID AND img.IsPrimary = 1
                WHERE p.Status = 'ACTIVE'
                ORDER BY p.ProductID ASC
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("productId", rs.getInt("ProductID"));
                map.put("productName", rs.getString("ProductName"));
                map.put("price", rs.getBigDecimal("Price"));
                map.put("categoryId", rs.getInt("CategoryID"));
                map.put("brandId", rs.getInt("BrandID"));
                map.put("categoryName", rs.getString("CategoryName") != null ? rs.getString("CategoryName") : "Tai nghe");
                map.put("brandName", rs.getString("BrandName") != null ? rs.getString("BrandName") : "Chính hãng");
                map.put("connectionType", rs.getString("ConnectionType") != null ? rs.getString("ConnectionType") : "Wireless");
                map.put("noiseCancelling", rs.getBoolean("NoiseCancelling"));
                map.put("batteryLife", rs.getInt("BatteryLife"));
                map.put("description", rs.getString("Description") != null ? rs.getString("Description") : "");
                map.put("embeddingVector", rs.getString("EmbeddingVector"));
                String img = rs.getString("ImageURL");
                map.put("imageUrl", (img != null && !img.trim().isEmpty()) ? img : "assets/img/product01.png");
                list.add(map);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getAllProductsForRecommendation", e);
        }
        return list;
    }

    /**
     * Aggregates behavior points per product from UserBehaviors (VIEW=1, SEARCH=2, FAVORITE=3, CART=4, PURCHASE=5).
     */
    public Map<Integer, Double> getProductBehaviorScores() {
        Map<Integer, Double> scoreMap = new HashMap<>();
        String sql = """
                SELECT ProductID,
                       SUM(CASE 
                             WHEN BehaviorType = 'PURCHASE' THEN 5 
                             WHEN BehaviorType = 'CART' THEN 4 
                             WHEN BehaviorType = 'FAVORITE' THEN 3 
                             WHEN BehaviorType = 'SEARCH' THEN 2 
                             ELSE 1 
                           END) AS TotalPoints
                FROM UserBehaviors
                WHERE ProductID IS NOT NULL
                GROUP BY ProductID
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            double maxPoints = 1.0;
            Map<Integer, Double> rawMap = new HashMap<>();
            while (rs.next()) {
                int pid = rs.getInt("ProductID");
                double pts = rs.getDouble("TotalPoints");
                rawMap.put(pid, pts);
                if (pts > maxPoints) {
                    maxPoints = pts;
                }
            }

            // Chuẩn hóa về thang [0.0 - 1.0]
            for (Map.Entry<Integer, Double> entry : rawMap.entrySet()) {
                double normalized = Math.min(1.0, entry.getValue() / maxPoints);
                scoreMap.put(entry.getKey(), Math.round(normalized * 1000.0) / 1000.0);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error reading behavior points, using default scores", e);
        }
        return scoreMap;
    }

    /**
     * Records an AI Recommendation event into AIRecommendations table and returns generated RecommendationID.
     */
    public long recordAIRecommendation(Integer customerId, String sessionId, int productId, 
                                        String recType, double simScore, double behScore, double finalScore, String reason) {
        String sql = """
                INSERT INTO AIRecommendations 
                (CustomerID, SessionID, ProductID, RecommendationType, SimilarityScore, BehaviorScore, FinalScore, Reason, IsClicked, IsPurchased, CreatedAt)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, 0, GETDATE())
                """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {

            if (customerId != null) {
                ps.setInt(1, customerId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setString(2, sessionId);
            ps.setInt(3, productId);
            ps.setString(4, recType != null ? recType : "SIMILAR");
            ps.setBigDecimal(5, BigDecimal.valueOf(simScore));
            ps.setBigDecimal(6, BigDecimal.valueOf(behScore));
            ps.setBigDecimal(7, BigDecimal.valueOf(finalScore));
            ps.setString(8, reason != null ? reason : "AI 512-Vector Semantic Similarity");

            ps.executeUpdate();
            try (ResultSet gk = ps.getGeneratedKeys()) {
                if (gk.next()) {
                    return gk.getLong(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error recording AI recommendation log", e);
        }
        return 0L;
    }

    /**
     * Updates EmbeddingVector column for a product.
     */
    public void updateProductEmbeddingVector(int productId, String vectorJson) {
        String sql = "UPDATE Products SET EmbeddingVector = ? WHERE ProductID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, vectorJson);
            ps.setInt(2, productId);
            ps.executeUpdate();
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error updating EmbeddingVector for ProductID " + productId, e);
        }
    }

    /**
     * Tracks a click on an AI-recommended product and inserts a VIEW event into UserBehaviors.
     */
    public void trackRecommendationClick(long recId, int productId, Integer customerId, String sessionId) {
        if (recId > 0) {
            String updateRecSql = "UPDATE AIRecommendations SET IsClicked = 1 WHERE RecommendationID = ?";
            try (Connection conn = dbContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(updateRecSql)) {
                ps.setLong(1, recId);
                ps.executeUpdate();
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Error updating IsClicked for RecommendationID " + recId, e);
            }
        }

        // Đồng thời ghi nhận vào bảng UserBehaviors
        String insertBehaviorSql = """
                INSERT INTO UserBehaviors (CustomerID, ProductID, BehaviorType, SessionID, CreatedAt)
                VALUES (?, ?, 'VIEW', ?, GETDATE())
                """;
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertBehaviorSql)) {
            if (customerId != null) {
                ps.setInt(1, customerId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setInt(2, productId);
            ps.setString(3, sessionId);
            ps.executeUpdate();
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error inserting VIEW into UserBehaviors", e);
        }
    }
}
