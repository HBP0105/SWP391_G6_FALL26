package com.swp391.service.Admin;

import java.util.List;
import java.util.Map;

/**
 * AccountAccessService - Preserved for backward compatibility, delegates to UserManagementService.
 */
public class AccountAccessService {

    private final UserManagementService userManagementService;

    public AccountAccessService() {
        this.userManagementService = new UserManagementService();
    }

    public List<Map<String, Object>> getAccounts(String keyword, String userType, String status) {
        return userManagementService.getUsers(keyword, userType, status, 1, 1000);
    }

    public List<Map<String, Object>> getStaffRoles() {
        return userManagementService.getStaffRoles();
    }

    public void updateStatus(String userType, int userId, String status, Integer currentAdminId) {
        userManagementService.updateStatus(userType, userId, status, currentAdminId);
    }

    public void updateStaffRole(int staffId, int roleId, Integer currentAdminId) {
        userManagementService.updateStaffRole(staffId, roleId, currentAdminId);
    }
}
