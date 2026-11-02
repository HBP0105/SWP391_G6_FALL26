package com.swp391.model;

/**
 * Model representing an AI recommendation item with a tailored reason.
 */
public class AIRecommendationItem {

    private int productId;
    private String reason;
    private double score;
    private Product product;

    public AIRecommendationItem() {
    }

    public AIRecommendationItem(int productId, String reason) {
        this.productId = productId;
        this.reason = reason;
        this.score = 0.95;
    }

    public AIRecommendationItem(int productId, String reason, Product product) {
        this.productId = productId;
        this.reason = reason;
        this.product = product;
        this.score = 0.95;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public double getScore() {
        return score;
    }

    public void setScore(double score) {
        this.score = score;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }
}

