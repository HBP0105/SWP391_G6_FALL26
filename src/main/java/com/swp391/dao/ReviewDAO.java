package com.swp391.dao;

import com.swp391.model.Review;
import com.swp391.model.ReviewImage;
import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ReviewDAO {

    private static final Logger LOGGER = Logger.getLogger(ReviewDAO.class.getName());
    private final DBContext dbContext;

    public ReviewDAO() {
        this.dbContext = new DBContext();
    }

    public static class ReviewSummary {
        private int totalReviews;
        private double avgRating;
        private int star5;
        private int star4;
        private int star3;
        private int star2;
        private int star1;

        public int getTotalReviews() {
            return totalReviews;
        }

        public void setTotalReviews(int totalReviews) {
            this.totalReviews = totalReviews;
        }

        public double getAvgRating() {
            return avgRating;
        }

        public void setAvgRating(double avgRating) {
            this.avgRating = avgRating;
        }

        public int getStar5() {
            return star5;
        }

        public void setStar5(int star5) {
            this.star5 = star5;
        }

        public int getStar4() {
            return star4;
        }

        public void setStar4(int star4) {
            this.star4 = star4;
        }

        public int getStar3() {
            return star3;
        }

        public void setStar3(int star3) {
            this.star3 = star3;
        }

        public int getStar2() {
            return star2;
        }

        public void setStar2(int star2) {
            this.star2 = star2;
        }

        public int getStar1() {
            return star1;
        }

        public void setStar1(int star1) {
            this.star1 = star1;
        }

        public int getPercent5() {
            return totalReviews > 0 ? (int) Math.round((star5 * 100.0) / totalReviews) : 0;
        }

        public int getPercent4() {
            return totalReviews > 0 ? (int) Math.round((star4 * 100.0) / totalReviews) : 0;
        }

        public int getPercent3() {
            return totalReviews > 0 ? (int) Math.round((star3 * 100.0) / totalReviews) : 0;
        }

        public int getPercent2() {
            return totalReviews > 0 ? (int) Math.round((star2 * 100.0) / totalReviews) : 0;
        }

        public int getPercent1() {
            return totalReviews > 0 ? (int) Math.round((star1 * 100.0) / totalReviews) : 0;
        }
    }

    /**
     * Get all visible reviews for a product, sorted newest first, including images.
     */
    public List<Review> getReviewsByProductId(int productId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.*, c.FullName AS CustomerName "
                   + "FROM Reviews r "
                   + "JOIN Customers c ON r.CustomerID = c.CustomerID "
                   + "WHERE r.ProductID = ? AND r.Status = 'VISIBLE' "
                   + "ORDER BY r.CreatedAt DESC";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("ReviewID"));
                    r.setCustomerId(rs.getInt("CustomerID"));
                    r.setProductId(rs.getInt("ProductID"));
                    r.setRating(rs.getInt("Rating"));
                    r.setComment(rs.getString("Comment"));
                    r.setStatus(rs.getString("Status"));
                    r.setCustomerName(rs.getString("CustomerName"));

                    Timestamp createdTs = rs.getTimestamp("CreatedAt");
                    if (createdTs != null) {
                        r.setCreatedAt(createdTs.toLocalDateTime());
                    }
                    Timestamp updatedTs = rs.getTimestamp("UpdatedAt");
                    if (updatedTs != null) {
                        r.setUpdatedAt(updatedTs.toLocalDateTime());
                    }
                    list.add(r);
                }
            }

            // Fetch attached images for each review
            for (Review r : list) {
                r.setImages(getImagesByReviewId(r.getReviewId()));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getReviewsByProductId (productId=" + productId + ")", e);
        }
        return list;
    }

    /**
     * Get images for a specific review.
     */
    public List<ReviewImage> getImagesByReviewId(int reviewId) {
        List<ReviewImage> images = new ArrayList<>();
        String sql = "SELECT * FROM ReviewImages WHERE ReviewID = ? ORDER BY ImageID ASC";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReviewImage img = new ReviewImage();
                    img.setImageId(rs.getInt("ImageID"));
                    img.setReviewId(rs.getInt("ReviewID"));
                    img.setImageUrl(rs.getString("ImageURL"));
                    img.setPublicId(rs.getString("PublicID"));
                    img.setIsPrimary(rs.getBoolean("IsPrimary"));

                    Timestamp createdTs = rs.getTimestamp("CreatedAt");
                    if (createdTs != null) {
                        img.setCreatedAt(createdTs.toLocalDateTime());
                    }
                    images.add(img);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getImagesByReviewId (reviewId=" + reviewId + ")", e);
        }
        return images;
    }

    /**
     * Add a single review image.
     */
    public boolean addReviewImage(int reviewId, String imageUrl, String publicId, boolean isPrimary) {
        String sql = "INSERT INTO ReviewImages (ReviewID, ImageURL, PublicID, IsPrimary, CreatedAt) VALUES (?, ?, ?, ?, GETDATE())";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.setString(2, imageUrl);
            ps.setString(3, publicId);
            ps.setBoolean(4, isPrimary);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in addReviewImage", e);
            return false;
        }
    }

    /**
     * Get a review image by its ImageID.
     */
    public ReviewImage getReviewImageById(int imageId) {
        String sql = "SELECT * FROM ReviewImages WHERE ImageID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, imageId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ReviewImage img = new ReviewImage();
                    img.setImageId(rs.getInt("ImageID"));
                    img.setReviewId(rs.getInt("ReviewID"));
                    img.setImageUrl(rs.getString("ImageURL"));
                    img.setPublicId(rs.getString("PublicID"));
                    img.setIsPrimary(rs.getBoolean("IsPrimary"));
                    Timestamp ts = rs.getTimestamp("CreatedAt");
                    if (ts != null) {
                        img.setCreatedAt(ts.toLocalDateTime());
                    }
                    return img;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getReviewImageById (imageId=" + imageId + ")", e);
        }
        return null;
    }

    /**
     * Delete a review image by its ImageID and ReviewID.
     */
    public boolean deleteReviewImage(int imageId, int reviewId) {
        String sql = "DELETE FROM ReviewImages WHERE ImageID = ? AND ReviewID = ?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, imageId);
            ps.setInt(2, reviewId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in deleteReviewImage (imageId=" + imageId + ", reviewId=" + reviewId + ")", e);
            return false;
        }
    }

    /**
     * Get review summary stats (avg rating, count per star level)
     */
    public ReviewSummary getReviewSummary(int productId) {
        ReviewSummary summary = new ReviewSummary();
        String sql = "SELECT "
                   + "COUNT(*) AS TotalReviews, "
                   + "ISNULL(AVG(CAST(Rating AS FLOAT)), 0) AS AvgRating, "
                   + "ISNULL(SUM(CASE WHEN Rating = 5 THEN 1 ELSE 0 END), 0) AS Star5, "
                   + "ISNULL(SUM(CASE WHEN Rating = 4 THEN 1 ELSE 0 END), 0) AS Star4, "
                   + "ISNULL(SUM(CASE WHEN Rating = 3 THEN 1 ELSE 0 END), 0) AS Star3, "
                   + "ISNULL(SUM(CASE WHEN Rating = 2 THEN 1 ELSE 0 END), 0) AS Star2, "
                   + "ISNULL(SUM(CASE WHEN Rating = 1 THEN 1 ELSE 0 END), 0) AS Star1 "
                   + "FROM Reviews "
                   + "WHERE ProductID = ? AND Status = 'VISIBLE'";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.setTotalReviews(rs.getInt("TotalReviews"));
                    summary.setAvgRating(Math.round(rs.getDouble("AvgRating") * 10.0) / 10.0);
                    summary.setStar5(rs.getInt("Star5"));
                    summary.setStar4(rs.getInt("Star4"));
                    summary.setStar3(rs.getInt("Star3"));
                    summary.setStar2(rs.getInt("Star2"));
                    summary.setStar1(rs.getInt("Star1"));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getReviewSummary (productId=" + productId + ")", e);
        }
        return summary;
    }

    /**
     * Get existing review submitted by a specific customer for a product.
     */
    public Review getReviewByUserAndProduct(int customerId, int productId) {
        String sql = "SELECT r.*, c.FullName AS CustomerName "
                   + "FROM Reviews r "
                   + "JOIN Customers c ON r.CustomerID = c.CustomerID "
                   + "WHERE r.CustomerID = ? AND r.ProductID = ?";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("ReviewID"));
                    r.setCustomerId(rs.getInt("CustomerID"));
                    r.setProductId(rs.getInt("ProductID"));
                    r.setRating(rs.getInt("Rating"));
                    r.setComment(rs.getString("Comment"));
                    r.setStatus(rs.getString("Status"));
                    r.setCustomerName(rs.getString("CustomerName"));

                    Timestamp createdTs = rs.getTimestamp("CreatedAt");
                    if (createdTs != null) {
                        r.setCreatedAt(createdTs.toLocalDateTime());
                    }
                    Timestamp updatedTs = rs.getTimestamp("UpdatedAt");
                    if (updatedTs != null) {
                        r.setUpdatedAt(updatedTs.toLocalDateTime());
                    }

                    r.setImages(getImagesByReviewId(r.getReviewId()));
                    return r;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getReviewByUserAndProduct", e);
        }
        return null;
    }

    /**
     * Add or update review in database and return the ReviewID.
     */
    public int saveOrUpdateReviewAndGetId(int customerId, int productId, int rating, String comment) {
        String checkSql = "SELECT ReviewID FROM Reviews WHERE CustomerID = ? AND ProductID = ?";
        String updateSql = "UPDATE Reviews SET Rating = ?, Comment = ?, Status = 'VISIBLE', UpdatedAt = GETDATE() WHERE ReviewID = ?";
        String insertSql = "INSERT INTO Reviews (CustomerID, ProductID, Rating, Comment, Status, CreatedAt) OUTPUT INSERTED.ReviewID VALUES (?, ?, ?, ?, 'VISIBLE', GETDATE())";

        try (Connection conn = dbContext.getConnection()) {
            int existingId = -1;
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, customerId);
                checkPs.setInt(2, productId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        existingId = rs.getInt("ReviewID");
                    }
                }
            }

            if (existingId > 0) {
                try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                    updatePs.setInt(1, rating);
                    updatePs.setString(2, comment);
                    updatePs.setInt(3, existingId);
                    updatePs.executeUpdate();
                    return existingId;
                }
            } else {
                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    insertPs.setInt(1, customerId);
                    insertPs.setInt(2, productId);
                    insertPs.setInt(3, rating);
                    insertPs.setString(4, comment);
                    try (ResultSet rs = insertPs.executeQuery()) {
                        if (rs.next()) {
                            return rs.getInt(1);
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in saveOrUpdateReviewAndGetId", e);
        }
        return -1;
    }

    /**
     * Add or update review in database (boolean wrapper).
     */
    public boolean addOrUpdateReview(int customerId, int productId, int rating, String comment) {
        return saveOrUpdateReviewAndGetId(customerId, productId, rating, comment) > 0;
    }
}
