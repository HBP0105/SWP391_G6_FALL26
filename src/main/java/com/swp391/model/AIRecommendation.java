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

    public AIRecommendation(long recommendationId, Integer customerId, String sessionId, int productId, String recommendationType, BigDecimal similarityScore, BigDecimal behaviorScore, BigDecimal finalScore, String reason, boolean isClicked, boolean isPurchased, LocalDateTime createdAt) {
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

    public boolean isIsClicked() {
        return isClicked;
    }

    public void setIsClicked(boolean isClicked) {
        this.isClicked = isClicked;
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
