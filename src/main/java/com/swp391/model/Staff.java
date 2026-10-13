package com.swp391.model;

import java.time.LocalDateTime;

public class Staff {

    private int staffID;
    private Role role;
    private int roleID;
    private String fullName;
    private String email;
    private String passwordHash;
    private String phone;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Staff() {
    }

    public Staff(int staffID, Role role, String fullName, String email,
            String passwordHash, String phone, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.staffID = staffID;
        this.role = role;
        if (role != null) {
            this.roleID = role.getRoleId();
        }
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
        this.phone = phone;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getStaffID() {
        return staffID;
    }

    public void setStaffID(int staffID) {
        this.staffID = staffID;
    }

    public int getStaffId() {
        return staffID;
    }

    public void setStaffId(int staffId) {
        this.staffID = staffId;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
        if (role != null) {
            this.roleID = role.getRoleId();
        }
    }

    public int getRoleID() {
        if (role != null) {
            return role.getRoleId();
        }
        return roleID;
    }

    public void setRoleID(int roleID) {
        this.roleID = roleID;
    }

    public int getRoleId() {
        return getRoleID();
    }

    public void setRoleId(int roleId) {
        setRoleID(roleId);
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getRoleName(){
        return (role!=null) ? role.getRoleName() : null;
    }
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
