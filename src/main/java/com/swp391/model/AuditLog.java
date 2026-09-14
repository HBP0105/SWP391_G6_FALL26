/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.swp391.model;

import java.time.LocalDateTime;

/**
 *
 * @author HP
 */
public class AuditLog {
    public long auditLogID;
    public Integer userID;
    public String action;
    public String entityName;
    public String entityID;
    public String oldData;
    public String newData;
    public LocalDateTime createdAt;

    public AuditLog() {
    }

    public AuditLog(long auditLogID, Integer userID, String action,
            String entityName, String entityID,
            String oldData, String newData,
            LocalDateTime createdAt) {

        this.auditLogID = auditLogID;
        this.userID = userID;
        this.action = action;
        this.entityName = entityName;
        this.entityID = entityID;
        this.oldData = oldData;
        this.newData = newData;
        this.createdAt = createdAt;
    }

    public long getAuditLogID() {
        return auditLogID;
    }

    public void setAuditLogID(long auditLogID) {
        this.auditLogID = auditLogID;
    }

    public Integer getUserID() {
        return userID;
    }

    public void setUserID(Integer userID) {
        this.userID = userID;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getEntityName() {
        return entityName;
    }

    public void setEntityName(String entityName) {
        this.entityName = entityName;
    }

    public String getEntityID() {
        return entityID;
    }

    public void setEntityID(String entityID) {
        this.entityID = entityID;
    }

    public String getOldData() {
        return oldData;
    }

    public void setOldData(String oldData) {
        this.oldData = oldData;
    }

    public String getNewData() {
        return newData;
    }

    public void setNewData(String newData) {
        this.newData = newData;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

}
