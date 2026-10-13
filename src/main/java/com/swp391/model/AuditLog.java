
package com.swp391.model;

import java.time.LocalDateTime;

public class AuditLog {
    public long auditLogID;
    public Integer staffID;
    public Integer customerID;
    public String action;
    public String entityName;
    public String entityID;
    public String oldData;
    public String newData;
    public LocalDateTime createdAt;

    public AuditLog() {
    }

    public AuditLog(long auditLogID, Integer staffID, String action,
            String entityName, String entityID,
            String oldData, String newData,
            LocalDateTime createdAt) {

        this.auditLogID = auditLogID;
        this.staffID = staffID;
        this.customerID = staffID;
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

    public Integer getStaffID() {
        return staffID != null ? staffID : customerID;
    }

    public void setStaffID(Integer staffID) {
        this.staffID = staffID;
        this.customerID = staffID;
    }

    public Integer getcustomerID() {
        return getStaffID();
    }

    public void setcustomerID(Integer customerID) {
        setStaffID(customerID);
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
