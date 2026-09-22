/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.swp391.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 *
 * @author ADMIN
 */
public class Product {

    private int productId;
    private int categoryId;
    private int brandId;

    private String productName;
    private String description;
    private BigDecimal price;
    private int stockQuantity;
    private String imageURL;
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

    // join object
    private Category category;
    private Brand brand;
    private String categoryName;
    private String brandName;

    public Product() {
    }

    public Product(int productId, int categoryId, int brandId, String productName, String description, BigDecimal price, int stockQuantity, String imageURL, String connectionType, Double driverSize, boolean noiseCancelling, Integer batteryLife, boolean microphone, String waterResistance, Double weight, String status, LocalDateTime createdAt, LocalDateTime updatedAt, Category category, Brand brand, String categoryName, String brandName) {
        this.productId = productId;
        this.categoryId = categoryId;
        this.brandId = brandId;
        this.productName = productName;
        this.description = description;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.imageURL = imageURL;
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
        this.category = category;
        this.brand = brand;
        this.categoryName = categoryName;
        this.brandName = brandName;
    }

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
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

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
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

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public Brand getBrand() {
        return brand;
    }

    public void setBrand(Brand brand) {
        this.brand = brand;
    }

}
