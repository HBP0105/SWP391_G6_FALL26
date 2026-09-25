/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.swp391.model;

import java.time.LocalDateTime;

/**
 *
 * @author ADMIN
 */
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

    public UserBehavior(long behaviorId, Integer customerId, Integer productId, String behaviorType, String searchKeyword, String sessionId, LocalDateTime createdAt) {
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

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

}
