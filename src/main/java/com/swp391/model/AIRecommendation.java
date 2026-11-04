package com.swp391.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class AIRecommendation {

    private long recommendationId;
    private Integer customerId;
    private String sessionId;
    private int productId;

    private String recommendationType;

    private BigDecimal similarityScore;
    private BigDecimal behaviorScore;
    private BigDecimal finalScore;

    private String reason;

    private boolean isClicked;
    private boolean isPurchased;

    private LocalDateTime createdAt;

    public AIRecommendation() {
    }

    public AIRecommendation(long recommendationId, Integer customerId, String sessionId, int productId,
            String recommendationType, BigDecimal similarityScore, BigDecimal behaviorScore,
            BigDecimal finalScore, String reason, boolean isClicked, boolean isPurchased, LocalDateTime createdAt) {
        this.recommendationId = recommendationId;
        this.customerId = customerId;
        this.sessionId = sessionId;
        this.productId = productId;
        this.recommendationType = recommendationType;
        this.similarityScore = similarityScore;
        this.behaviorScore = behaviorScore;
        this.finalScore = finalScore;
        this.reason = reason;
        this.isClicked = isClicked;
        this.isPurchased = isPurchased;
        this.createdAt = createdAt;
    }

    // Standard getters/setters (CamelCase)
    public long getRecommendationId() {
        return recommendationId;
    }

    public void setRecommendationId(long recommendationId) {
        this.recommendationId = recommendationId;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    // Alias getters/setters (UPPERCASE for backward compatibility)
    public long getRecommendationID() {
        return recommendationId;
    }

    public void setRecommendationID(long recommendationID) {
        this.recommendationId = recommendationID;
    }

    public Integer getCustomerID() {
        return customerId;
    }

    public void setCustomerID(Integer customerID) {
        this.customerId = customerID;
    }

    public Integer getCutomerID() {
        return customerId;
    }

    public void setCutomerID(Integer customerID) {
        this.customerId = customerID;
    }

    public String getSessionID() {
        return sessionId;
    }

    public void setSessionID(String sessionID) {
        this.sessionId = sessionID;
    }

    public int getProductID() {
        return productId;
    }

    public void setProductID(int productID) {
        this.productId = productID;
    }

    public String getRecommendationType() {
        return recommendationType;
    }

    public void setRecommendationType(String recommendationType) {
        this.recommendationType = recommendationType;
    }

    public BigDecimal getSimilarityScore() {
        return similarityScore;
    }

    public void setSimilarityScore(BigDecimal similarityScore) {
        this.similarityScore = similarityScore;
    }

    public BigDecimal getBehaviorScore() {
        return behaviorScore;
    }

    public void setBehaviorScore(BigDecimal behaviorScore) {
        this.behaviorScore = behaviorScore;
    }

    public BigDecimal getFinalScore() {
        return finalScore;
    }

    public void setFinalScore(BigDecimal finalScore) {
        this.finalScore = finalScore;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public boolean isClicked() {
        return isClicked;
    }

    public void setClicked(boolean clicked) {
        this.isClicked = clicked;
    }

    public boolean isIsClicked() {
        return isClicked;
    }

    public void setIsClicked(boolean isClicked) {
        this.isClicked = isClicked;
    }

    public boolean isPurchased() {
        return isPurchased;
    }

    public void setPurchased(boolean purchased) {
        this.isPurchased = purchased;
    }

    public boolean isIsPurchased() {
        return isPurchased;
    }

    public void setIsPurchased(boolean isPurchased) {
        this.isPurchased = isPurchased;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
