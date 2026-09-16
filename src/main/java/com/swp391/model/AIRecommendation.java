
package com.swp391.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class AIRecommendation {
    public long recommendationID;
    public Integer customerID;
    public String sessionID;
    public int productID;
    public String recommendationType;
    public BigDecimal similarityScore;
    public BigDecimal behaviorScore;
    public BigDecimal finalScore;
    public String reason;
    public boolean isClicked;
    public boolean isPurchased;
    public LocalDateTime createdAt;

    public AIRecommendation() {
    }

    public AIRecommendation(long recommendationID, Integer customerID, String sessionID,
            int productID, String recommendationType,
            BigDecimal similarityScore, BigDecimal behaviorScore,
            BigDecimal finalScore, String reason,
            boolean isClicked, boolean isPurchased,
            LocalDateTime createdAt) {

        this.recommendationID = recommendationID;
        this.customerID = customerID;
        this.sessionID = sessionID;
        this.productID = productID;
        this.recommendationType = recommendationType;
        this.similarityScore = similarityScore;
        this.behaviorScore = behaviorScore;
        this.finalScore = finalScore;
        this.reason = reason;
        this.isClicked = isClicked;
        this.isPurchased = isPurchased;
        this.createdAt = createdAt;
    }

    public long getRecommendationID() {
        return recommendationID;
    }

    public void setRecommendationID(long recommendationID) {
        this.recommendationID = recommendationID;
    }

    public Integer getCutomerID() {
        return customerID;
    }

    public void setCutomerID(Integer customerID) {
        this.customerID = customerID;
    }

    public String getSessionID() {
        return sessionID;
    }

    public void setSessionID(String sessionID) {
        this.sessionID = sessionID;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
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
        isClicked = clicked;
    }

    public boolean isPurchased() {
        return isPurchased;
    }

    public void setPurchased(boolean purchased) {
        isPurchased = purchased;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

}
