package com.swp391.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class WishlistItemDTO {
    private int favoriteId;
    private int customerId;
    private int productId;
    private String productName;
    private String description;
    private BigDecimal price;
    private String categoryName;
    private String brandName;
    private String imageUrl;
    private int stockQuantity;
    private double rating;
    private int reviewCount;
    private String connectionType;
    private boolean noiseCancelling;
    private Integer batteryLife;
    private String status;
    private LocalDateTime addedAt;

    private static final DateTimeFormatter STEAM_DATE_FORMAT = DateTimeFormatter.ofPattern("MMM dd, yyyy", Locale.ENGLISH);

    public WishlistItemDTO() {
    }

    public int getFavoriteId() {
        return favoriteId;
    }

    public void setFavoriteId(int favoriteId) {
        this.favoriteId = favoriteId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }

    public String getConnectionType() {
        return connectionType;
    }

    public void setConnectionType(String connectionType) {
        this.connectionType = connectionType;
    }

    public boolean isNoiseCancelling() {
        return noiseCancelling;
    }

    public void setNoiseCancelling(boolean noiseCancelling) {
        this.noiseCancelling = noiseCancelling;
    }

    public Integer getBatteryLife() {
        return batteryLife;
    }

    public void setBatteryLife(Integer batteryLife) {
        this.batteryLife = batteryLife;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(LocalDateTime addedAt) {
        this.addedAt = addedAt;
    }

    public String getFormattedAddedDate() {
        if (addedAt != null) {
            return addedAt.format(STEAM_DATE_FORMAT);
        }
        return "Recently";
    }

    public static WishlistItemDTO fromProduct(Product p, int customerId) {
        if (p == null) return null;
        WishlistItemDTO dto = new WishlistItemDTO();
        dto.setProductId(p.getProductId());
        dto.setCustomerId(customerId);
        dto.setProductName(p.getProductName());
        dto.setDescription(p.getDescription());
        dto.setPrice(p.getPrice());
        dto.setStockQuantity(p.getStockQuantity());
        dto.setCategoryName(p.getCategoryName());
        dto.setBrandName(p.getBrandName());
        dto.setImageUrl(p.getImageUrl());
        dto.setRating(p.getRating());
        dto.setReviewCount(p.getReviewCount());
        dto.setConnectionType(p.getConnectionType());
        dto.setNoiseCancelling(p.isNoiseCancelling());
        dto.setBatteryLife(p.getBatteryLife());
        dto.setStatus(p.getStatus());
        dto.setAddedAt(LocalDateTime.now());
        return dto;
    }
}
