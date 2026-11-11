package com.swp391.dao.Admin;

import java.util.List;
import java.util.Map;

/**
 * AccountAccessDAO - Preserved for backward compatibility, delegates to UserManagementDAO.
 */
public class AccountAccessDAO {

    private final UserManagementDAO userManagementDAO;

    public AccountAccessDAO() {
        this.userManagementDAO = new UserManagementDAO();
    }

    public List<Map<String, Object>> getAccounts(String keyword, String userType, String status) {
        return userManagementDAO.getUsers(keyword, userType, status, 0, 1000);
    }

    public List<Map<String, Object>> getStaffRoles() {
        return userManagementDAO.getStaffRoles();
    }

    public boolean roleExists(int roleId) {
        return userManagementDAO.roleExists(roleId);
    }

    public boolean updateStaffRole(int staffId, int roleId) {
        return userManagementDAO.updateStaffRole(staffId, roleId);
    }

    public boolean updateStatus(String userType, int userId, String status) {
        return userManagementDAO.updateStatus(userType, userId, status);
    }
}
