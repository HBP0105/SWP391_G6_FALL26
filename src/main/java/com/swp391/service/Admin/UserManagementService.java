package com.swp391.service.Admin;

import com.swp391.dao.Admin.AuditLogDAO;
import com.swp391.dao.Admin.UserManagementDAO;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Service for Unified User & Access Management.
 * Handles business validation, self-protection rules, and audit logging.
 */
public class UserManagementService {

    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final int MAX_PAGE_SIZE = 50;
    private static final Set<String> USER_TYPES = Set.of("ALL", "CUSTOMER", "STAFF");
    private static final Set<String> STATUSES = Set.of("ALL", "ACTIVE", "INACTIVE", "BANNED");

    private final UserManagementDAO dao;
    private final AuditLogDAO auditLogDAO;

    public UserManagementService() {
        this.dao = new UserManagementDAO();
        this.auditLogDAO = new AuditLogDAO();
    }

    public List<Map<String, Object>> getUsers(
            String keyword,
            String userType,
            String status,
            int page,
            int pageSize) {

        page = normalizePage(page);
        pageSize = normalizePageSize(pageSize);
        return dao.getUsers(
                normalizeKeyword(keyword),
                normalizeUserType(userType),
                normalizeStatus(status),
                (page - 1) * pageSize,
                pageSize
        );
    }

    public int countUsers(String keyword, String userType, String status) {
        return dao.countUsers(
                normalizeKeyword(keyword),
                normalizeUserType(userType),
                normalizeStatus(status)
        );
    }

    public Map<String, Integer> getUserStats() {
        return dao.getUserStats();
    }

    public List<Map<String, Object>> getStaffRoles() {
        return dao.getStaffRoles();
    }

    public void updateStatus(String userType, int userId, String status, Integer currentAdminId) {
        userType = normalizeRequiredUserType(userType);
        status = normalizeRequiredStatus(status);

        if (userId <= 0) {
            throw new IllegalArgumentException("Invalid account ID.");
        }
        if ("STAFF".equals(userType) && currentAdminId != null && userId == currentAdminId && !"ACTIVE".equals(status)) {
            throw new IllegalArgumentException("You cannot lock, deactivate, or ban your own admin account.");
        }

        if (!dao.updateStatus(userType, userId, status)) {
            throw new IllegalArgumentException("Account was not found or status was not updated.");
        }

        auditLogDAO.insertAuditLog(
                currentAdminId,
                "UPDATE_STATUS",
                "STAFF".equals(userType) ? "Staff" : "Customer",
                String.valueOf(userId),
                null,
                "{\"Status\":\"" + status + "\"}"
        );
    }

    public void updateStaffRole(int staffId, int roleId, Integer currentAdminId) {
        if (staffId <= 0 || roleId <= 0) {
            throw new IllegalArgumentException("Invalid staff or role ID.");
        }
        if (currentAdminId != null && staffId == currentAdminId) {
            throw new IllegalArgumentException("You cannot change your own admin role.");
        }
        if (!dao.roleExists(roleId)) {
            throw new IllegalArgumentException("Invalid staff role.");
        }
        if (!dao.updateStaffRole(staffId, roleId)) {
            throw new IllegalArgumentException("Staff account was not found or role was not updated.");
        }

        auditLogDAO.insertAuditLog(
                currentAdminId,
                "UPDATE_ROLE",
                "Staff",
                String.valueOf(staffId),
                null,
                "{\"RoleID\":" + roleId + "}"
        );
    }

    public void updateAccess(String userType, int userId, Integer roleId, String status, Integer currentAdminId) {
        userType = normalizeRequiredUserType(userType);
        if ("STAFF".equals(userType) && roleId != null && roleId > 0) {
            updateStaffRole(userId, roleId, currentAdminId);
        }
        if (status != null && !status.isBlank()) {
            updateStatus(userType, userId, status, currentAdminId);
        }
    }

    public int normalizePage(int page) {
        return Math.max(page, 1);
    }

    public int normalizePageSize(int pageSize) {
        if (pageSize <= 0) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(pageSize, MAX_PAGE_SIZE);
    }

    public int getTotalPages(int totalItems, int pageSize) {
        pageSize = normalizePageSize(pageSize);
        return totalItems <= 0 ? 1 : (int) Math.ceil((double) totalItems / pageSize);
    }

    private String normalizeKeyword(String keyword) {
        return keyword == null ? "" : keyword.trim();
    }

    private String normalizeUserType(String userType) {
        String value = userType == null || userType.isBlank() ? "ALL" : userType.trim().toUpperCase();
        return USER_TYPES.contains(value) ? value : "ALL";
    }

    private String normalizeStatus(String status) {
        String value = status == null || status.isBlank() ? "ALL" : status.trim().toUpperCase();
        return STATUSES.contains(value) ? value : "ALL";
    }

    private String normalizeRequiredUserType(String userType) {
        String value = userType == null ? "" : userType.trim().toUpperCase();
        if (!"CUSTOMER".equals(value) && !"STAFF".equals(value)) {
            throw new IllegalArgumentException("Invalid account type.");
        }
        return value;
    }

    private String normalizeRequiredStatus(String status) {
        String value = userTypeOrStatus(status);
        if (!"ACTIVE".equals(value) && !"INACTIVE".equals(value) && !"BANNED".equals(value)) {
            throw new IllegalArgumentException("Invalid account status.");
        }
        return value;
    }

    private String userTypeOrStatus(String value) {
        return value == null ? "" : value.trim().toUpperCase();
    }
}
