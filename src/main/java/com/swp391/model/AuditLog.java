package com.swp391.model;

import java.time.LocalDateTime;

public class AuditLog {

    private long auditLogId;
    private Integer staffId;
    private Integer customerId;
    private String action;
    private String entityName;
    private String entityId;
    private String oldData;
    private String newData;
    private LocalDateTime createdAt;

    public AuditLog() {
    }

    public AuditLog(long auditLogId, Integer staffId, String action, String entityName,
                    String entityId, String oldData, String newData, LocalDateTime createdAt) {
        this.auditLogId = auditLogId;
        this.staffId = staffId;
        this.customerId = staffId;
        this.action = action;
        this.entityName = entityName;
        this.entityId = entityId;
        this.oldData = oldData;
        this.newData = newData;
        this.createdAt = createdAt;
    }

    public long getAuditLogId() {
        return auditLogId;
    }

    public void setAuditLogId(long auditLogId) {
        this.auditLogId = auditLogId;
    }

    public Integer getStaffId() {
        return staffId != null ? staffId : customerId;
    }

    public void setStaffId(Integer staffId) {
        this.staffId = staffId;
        this.customerId = staffId;
    }

    // Aliases
    public long getAuditLogID() {
        return auditLogId;
    }

    public void setAuditLogID(long auditLogID) {
        this.auditLogId = auditLogID;
    }

    public Integer getStaffID() {
        return getStaffId();
    }

    public void setStaffID(Integer staffID) {
        setStaffId(staffID);
    }

    public Integer getcustomerID() {
        return getStaffId();
    }

    public void setcustomerID(Integer customerID) {
        setStaffId(customerID);
    }

    public Integer getCustomerId() {
        return customerId != null ? customerId : staffId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
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

    public String getEntityId() {
        return entityId;
    }

    public void setEntityId(String entityId) {
        this.entityId = entityId;
    }

    public String getEntityID() {
        return entityId;
    }

    public void setEntityID(String entityID) {
        this.entityId = entityID;
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
