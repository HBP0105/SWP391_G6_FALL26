package com.swp391.service.Manager;

import com.swp391.dao.Manager.StaffDAO;
import com.swp391.model.Staff;

public class ProfileService {

    private final StaffDAO staffDAO;

    public ProfileService() {
        this.staffDAO = new StaffDAO();
    }

    public Staff getStaffById(int staffId) {
        return staffDAO.getStaffById(staffId);
    }

    public Staff getOrCreateDefaultManager() {
        return staffDAO.getOrCreateDefaultManager();
    }

    /**
     * Updates staff profile. Returns null on success or error message string.
     */
    public String updateProfile(int staffId, String fullName, String email, String phone) {
        if (fullName == null || fullName.trim().isEmpty()) {
            return "Full Name is required.";
        }
        if (email == null || email.trim().isEmpty()) {
            return "Email is required.";
        }
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            return "Please enter a valid email address.";
        }
        if (phone != null && !phone.trim().isEmpty()) {
            if (!phone.trim().matches("^[0-9+()\\s-]{7,20}$")) {
                return "Please enter a valid phone number.";
            }
        }

        if (staffDAO.isEmailTaken(email.trim(), staffId)) {
            return "Email address is already in use by another account.";
        }

        boolean success = staffDAO.updateProfile(staffId, fullName.trim(), email.trim(), phone != null ? phone.trim() : "");
        if (!success) {
            return "Failed to update profile. Please try again.";
        }
        return null;
    }

    /**
     * Updates staff password. Returns null on success or error message string.
     */
    public String changePassword(int staffId, String currentPassword, String newPassword, String confirmPassword) {
        if (currentPassword == null || currentPassword.isEmpty()) {
            return "Current password is required.";
        }
        if (newPassword == null || newPassword.isEmpty()) {
            return "New password is required.";
        }
        if (newPassword.length() < 6) {
            return "New password must be at least 6 characters long.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "New password and confirmation password do not match.";
        }

        if (!staffDAO.verifyPassword(staffId, currentPassword)) {
            return "Current password is incorrect.";
        }

        boolean success = staffDAO.updatePassword(staffId, newPassword);
        if (!success) {
            return "Failed to change password. Please try again.";
        }
        return null;
    }
}
