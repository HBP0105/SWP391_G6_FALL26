
package com.swp391.model;

import java.time.LocalDateTime;

public class UserBehavior {
    public long behaviorID;
    public Integer customerID;
    public Integer productID;
    public String behaviorType;
    public String searchKeyword;
    public String sessionID;
    public LocalDateTime createdAt;

    public UserBehavior() {
    }

    public UserBehavior(long behaviorID, Integer customerID, Integer productID,
            String behaviorType, String searchKeyword,
            String sessionID, LocalDateTime createdAt) {

        this.behaviorID = behaviorID;
        this.customerID = customerID;
        this.productID = productID;
        this.behaviorType = behaviorType;
        this.searchKeyword = searchKeyword;
        this.sessionID = sessionID;
        this.createdAt = createdAt;
    }

    public long getBehaviorID() {
        return behaviorID;
    }

    public void setBehaviorID(long behaviorID) {
        this.behaviorID = behaviorID;
    }

    public Integer getcustomerID() {
        return customerID;
    }

    public void setcustomerID(Integer customerID) {
        this.customerID = customerID;
    }

    public Integer getProductID() {
        return productID;
    }

    public void setProductID(Integer productID) {
        this.productID = productID;
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

    public String getSessionID() {
        return sessionID;
    }

    public void setSessionID(String sessionID) {
        this.sessionID = sessionID;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
