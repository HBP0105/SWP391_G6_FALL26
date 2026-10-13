package com.swp391.model;

import java.time.LocalDateTime;

public class UserBehavior {

    private long behaviorId;
    private Integer customerId;
    private Integer productId;
    private String behaviorType;
    private String searchKeyword;
    private String sessionId;
    private LocalDateTime createdAt;

    public UserBehavior() {
    }

    public UserBehavior(long behaviorId, Integer customerId, Integer productId,
            String behaviorType, String searchKeyword, String sessionId, LocalDateTime createdAt) {
        this.behaviorId = behaviorId;
        this.customerId = customerId;
        this.productId = productId;
        this.behaviorType = behaviorType;
        this.searchKeyword = searchKeyword;
        this.sessionId = sessionId;
        this.createdAt = createdAt;
    }

    public long getBehaviorId() {
        return behaviorId;
    }

    public void setBehaviorId(long behaviorId) {
        this.behaviorId = behaviorId;
    }

    public long getBehaviorID() {
        return behaviorId;
    }

    public void setBehaviorID(long behaviorID) {
        this.behaviorId = behaviorID;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public Integer getcustomerID() {
        return customerId;
    }

    public void setcustomerID(Integer customerID) {
        this.customerId = customerID;
    }

    public Integer getCustomerID() {
        return customerId;
    }

    public void setCustomerID(Integer customerID) {
        this.customerId = customerID;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
    }

    public Integer getProductID() {
        return productId;
    }

    public void setProductID(Integer productID) {
        this.productId = productID;
    }

    public String getBehaviorType() {
        return behaviorType;
    }

    public void setBehaviorType(String behaviorType) {
        this.behaviorType = behaviorType;
    }

    public String getSearchKeyword() {
        return searchKeyword;
    }

    public void setSearchKeyword(String searchKeyword) {
        this.searchKeyword = searchKeyword;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public String getSessionID() {
        return sessionId;
    }

    public void setSessionID(String sessionID) {
        this.sessionId = sessionID;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
