/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.swp391.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;


public class Product {
    private int productID;
    private int categoryID;
    private int brandID;
    private String productName;
    private String description;
    private BigDecimal price;
    private int stockQuantity;
    private String connectionType;
    private Double driverSize;
    private boolean noiseCancelling;
    private Integer batteryLife;
    private boolean microphone;
    private String waterResistance;
    private Double weight;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Extra fields from JOIN queries
    private String categoryName;
    private String brandName;
    private String imageUrl;

    public Product() {}

    public Product(int productID, int categoryID, int brandID, String productName,
                   String description, BigDecimal price, int stockQuantity,
                   String connectionType, Double driverSize, boolean noiseCancelling,
                   Integer batteryLife, boolean microphone, String waterResistance,
                   Double weight, String status,
                   LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.productID = productID;
        this.categoryID = categoryID;
        this.brandID = brandID;
        this.productName = productName;
        this.description = description;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.connectionType = connectionType;
        this.driverSize = driverSize;
        this.noiseCancelling = noiseCancelling;
        this.batteryLife = batteryLife;
        this.microphone = microphone;
        this.waterResistance = waterResistance;
        this.weight = weight;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public int getCategoryID() {
        return categoryID;
    }

    public void setCategoryID(int categoryID) {
        this.categoryID = categoryID;
    }

    public int getBrandID() {
        return brandID;
    }

    public void setBrandID(int brandID) {
        this.brandID = brandID;
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

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public String getConnectionType() {
        return connectionType;
    }

    public void setConnectionType(String connectionType) {
        this.connectionType = connectionType;
    }

    public Double getDriverSize() {
        return driverSize;
    }

    public void setDriverSize(Double driverSize) {
        this.driverSize = driverSize;
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

    public boolean isMicrophone() {
        return microphone;
    }

    public void setMicrophone(boolean microphone) {
        this.microphone = microphone;
    }

    public String getWaterResistance() {
        return waterResistance;
    }

    public void setWaterResistance(String waterResistance) {
        this.waterResistance = waterResistance;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
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
        if (imageUrl != null && !imageUrl.trim().isEmpty()) {
            return imageUrl;
        }
        int imgIndex = (productID % 9) + 1;
        return String.format("assets/img/product%02d.png", imgIndex);
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

}

