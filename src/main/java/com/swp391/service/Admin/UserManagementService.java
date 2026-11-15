package com.swp391.service.Admin;

import com.swp391.dao.Admin.AuditLogDAO;
import com.swp391.dao.Admin.UserManagementDAO;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Service for Unified User & Access Management.
 * Handles business validation, self-protection, last-admin protection,
 * staff creation, detail retrieval, CSV export, and full old/new audit logging.
 */
public class UserManagementService {

    /**
     * Validation error carrying the specific form field name for inline modal feedback.
     */
    public static class FieldValidationException extends IllegalArgumentException {
        private final String field;

        public FieldValidationException(String field, String message) {
            super(message);
            this.field = field;
        }

        public String getField() {
            return field;
        }
    }

    public static final int DEFAULT_PAGE_SIZE = 10;
    private static final Set<String> USER_TYPES = Set.of("ALL", "CUSTOMER", "STAFF");
    private static final Set<String> ROLES = Set.of("ALL", "ADMIN", "MANAGER", "CUSTOMER");
    private static final Set<String> STATUSES = Set.of("ALL", "ACTIVE", "INACTIVE", "BANNED");
    private static final Set<String> SORTS = Set.of("newest", "oldest", "name_asc", "name_desc");
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^[0-9+\\-\\s().]{7,20}$");

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
        return getUsers(keyword, userType, "ALL", status, "newest", page);
    }

    public List<Map<String, Object>> getUsers(
            String keyword,
            String userType,
            String role,
            String status,
            String sort,
            int page) {

        int normalizedPage = normalizePage(page);
        return dao.getUsers(
                normalizeKeyword(keyword),
                normalizeUserType(userType),
                normalizeRole(role),
                normalizeStatus(status),
                normalizeSort(sort),
                (normalizedPage - 1) * DEFAULT_PAGE_SIZE,
                DEFAULT_PAGE_SIZE
        );
    }

    public int countUsers(String keyword, String userType, String status) {
        return countUsers(keyword, userType, "ALL", status);
    }

    public int countUsers(String keyword, String userType, String role, String status) {
        return dao.countUsers(
                normalizeKeyword(keyword),
                normalizeUserType(userType),
                normalizeRole(role),
                normalizeStatus(status)
        );
    }

    public Map<String, Integer> getUserStats() {
        return dao.getUserStats();
    }

    public List<Map<String, Object>> getStaffRoles() {
        return dao.getStaffRoles();
    }

    public Map<String, Object> getUserDetail(String userType, int userId) {
        userType = normalizeRequiredUserType(userType);
        if (userId <= 0) {
            throw new IllegalArgumentException("Invalid account ID.");
        }
        Map<String, Object> detail = dao.getUserDetail(userType, userId);
        if (detail == null) {
            throw new IllegalArgumentException("Account was not found.");
        }
        return detail;
    }

    public void updateStatus(String userType, int userId, String status, Integer currentAdminId) {
        updateStatusInternal(userType, userId, status, null, currentAdminId, false);
    }

    public boolean updateStatus(String userType, int userId, String status, String reason, Integer currentAdminId) {
        return updateStatusInternal(userType, userId, status, reason, currentAdminId, true);
    }

    public void updateStaffRole(int staffId, int roleId, Integer currentAdminId) {
        updateStaffRoleInternal(staffId, roleId, null, currentAdminId);
    }

    public boolean updateStaffRole(int staffId, int roleId, String reason, Integer currentAdminId) {
        return updateStaffRoleInternal(staffId, roleId, reason, currentAdminId);
    }

    public String updateAccess(
            String userType,
            int userId,
            Integer roleId,
            String status,
            String reason,
            Integer currentAdminId) {

        userType = normalizeRequiredUserType(userType);
        boolean roleChanged = false;
        boolean statusChanged = false;

        if ("STAFF".equals(userType) && roleId != null && roleId > 0) {
            roleChanged = updateStaffRoleInternal(userId, roleId, reason, currentAdminId);
        }
        if (status != null && !status.isBlank()) {
            statusChanged = updateStatusInternal(userType, userId, status, reason, currentAdminId, true);
        }

        if (roleChanged && statusChanged) {
            return "Updated staff role and account status successfully.";
        }
        if (roleChanged) {
            return "Staff role updated successfully.";
        }
        if (statusChanged) {
            return "Account status updated successfully.";
        }
        throw new IllegalArgumentException("No changes detected: role and status are already set to these values.");
    }

    public void updateAccess(String userType, int userId, Integer roleId, String status, Integer currentAdminId) {
        updateAccess(userType, userId, roleId, status, null, currentAdminId);
    }

    public int createStaff(
            String fullName,
            String email,
            String phone,
            String password,
            int roleId,
            String status,
            Integer currentAdminId) {

        String cleanName = trimToEmpty(fullName);
        String cleanEmail = trimToEmpty(email);
        String cleanPhone = trimToEmpty(phone);
        String cleanPassword = password == null ? "" : password.trim();
        String normalizedStatus = normalizeNewStaffStatus(status);

        if (cleanName.isEmpty() || cleanName.length() > 100) {
            throw new FieldValidationException("fullName", "Full name is required and must be at most 100 characters.");
        }
        if (cleanEmail.isEmpty() || cleanEmail.length() > 150 || !EMAIL_PATTERN.matcher(cleanEmail).matches()) {
            throw new FieldValidationException("email", "Please enter a valid email address.");
        }
        if (!cleanPhone.isEmpty() && !PHONE_PATTERN.matcher(cleanPhone).matches()) {
            throw new FieldValidationException("phone", "Phone number format is invalid (7-20 digits/characters).");
        }
        if (cleanPassword.length() < 6) {
            throw new FieldValidationException("password", "Initial password must be at least 6 characters.");
        }
        String roleName = dao.getRoleNameById(roleId);
        if (roleName == null) {
            throw new FieldValidationException("roleId", "Invalid staff role selected.");
        }
        if (dao.emailExistsInAnyAccount(cleanEmail)) {
            throw new FieldValidationException("email", "Email address is already registered in the system.");
        }
        if (!cleanPhone.isEmpty() && dao.phoneExistsInAnyAccount(cleanPhone, null)) {
            throw new FieldValidationException("phone", "Phone number is already registered to another account.");
        }

        int newStaffId = dao.createStaff(cleanName, cleanEmail, cleanPhone, cleanPassword, roleId, normalizedStatus);
        if (newStaffId <= 0) {
            throw new RuntimeException("Failed to create staff account.");
        }

        String newData = "{\"FullName\":\"" + escapeJson(cleanName) + "\","
                + "\"Email\":\"" + escapeJson(cleanEmail) + "\","
                + "\"RoleID\":" + roleId + ","
                + "\"RoleName\":\"" + escapeJson(roleName) + "\","
                + "\"Status\":\"" + escapeJson(normalizedStatus) + "\"}";

        auditLogDAO.insertAuditLog(
                currentAdminId,
                "CREATE_STAFF",
                "Staff",
                String.valueOf(newStaffId),
                null,
                newData
        );

        return newStaffId;
    }

    public void updateStaffInfo(int staffId, String fullName, String phone, Integer currentAdminId) {
        if (staffId <= 0) {
            throw new IllegalArgumentException("Invalid staff ID.");
        }
        String cleanName = trimToEmpty(fullName);
        String cleanPhone = trimToEmpty(phone);

        if (cleanName.isEmpty() || cleanName.length() > 100) {
            throw new FieldValidationException("fullName", "Full name is required and must be at most 100 characters.");
        }
        if (!cleanPhone.isEmpty() && !PHONE_PATTERN.matcher(cleanPhone).matches()) {
            throw new FieldValidationException("phone", "Phone number format is invalid (7-20 digits/characters).");
        }

        Map<String, Object> snapshot = dao.getAccountSnapshot("STAFF", staffId);
        if (snapshot == null) {
            throw new IllegalArgumentException("Staff account was not found.");
        }
        if ("ADMIN".equalsIgnoreCase(valueAsString(snapshot.get("roleName")))) {
            throw new IllegalArgumentException("Administrator accounts cannot be modified by another administrator.");
        }

        String oldName = trimToEmpty(valueAsString(snapshot.get("fullName")));
        String oldPhone = trimToEmpty(valueAsString(snapshot.get("phone")));

        if (cleanName.equals(oldName) && cleanPhone.equals(oldPhone)) {
            throw new IllegalArgumentException("No changes detected: full name and phone remain unchanged.");
        }
        if (!cleanPhone.isEmpty() && !cleanPhone.equals(oldPhone) && dao.phoneExistsInAnyAccount(cleanPhone, staffId)) {
            throw new FieldValidationException("phone", "Phone number is already registered to another account.");
        }

        if (!dao.updateStaffInfo(staffId, cleanName, cleanPhone)) {
            throw new IllegalArgumentException("Staff account was not found or profile was not updated.");
        }

        String oldData = "{\"FullName\":\"" + escapeJson(oldName) + "\",\"Phone\":\"" + escapeJson(oldPhone) + "\"}";
        String newData = "{\"FullName\":\"" + escapeJson(cleanName) + "\",\"Phone\":\"" + escapeJson(cleanPhone) + "\"}";

        auditLogDAO.insertAuditLog(
                currentAdminId,
                "UPDATE_STAFF_INFO",
                "Staff",
                String.valueOf(staffId),
                oldData,
                newData
        );
    }

    public void resetStaffPassword(
            int staffId,
            String newPassword,
            String confirmPassword,
            Integer currentAdminId) {

        if (staffId <= 0) {
            throw new IllegalArgumentException("Invalid staff ID.");
        }
        if (currentAdminId != null && staffId == currentAdminId) {
            throw new IllegalArgumentException("You cannot reset your own password from User Management.");
        }

        String cleanPassword = newPassword == null ? "" : newPassword.trim();
        String cleanConfirm = confirmPassword == null ? "" : confirmPassword.trim();
        if (cleanPassword.length() < 6) {
            throw new FieldValidationException("newPassword", "New password must be at least 6 characters.");
        }
        if (!cleanPassword.equals(cleanConfirm)) {
            throw new FieldValidationException("confirmPassword", "Confirm password does not match.");
        }

        Map<String, Object> snapshot = dao.getAccountSnapshot("STAFF", staffId);
        if (snapshot == null) {
            throw new IllegalArgumentException("Staff account was not found.");
        }
        if ("ADMIN".equalsIgnoreCase(valueAsString(snapshot.get("roleName")))) {
            throw new IllegalArgumentException("You cannot reset another administrator's password.");
        }

        if (!dao.resetStaffPassword(staffId, cleanPassword)) {
            throw new IllegalArgumentException("Staff account was not found or password was not reset.");
        }

        String email = valueAsString(snapshot.get("email"));
        String newData = "{\"Email\":\"" + escapeJson(email) + "\",\"Note\":\"Admin reset staff password\"}";

        auditLogDAO.insertAuditLog(
                currentAdminId,
                "RESET_PASSWORD",
                "Staff",
                String.valueOf(staffId),
                null,
                newData
        );
    }

    public void changeOwnPassword(
            int staffId,
            String currentPassword,
            String newPassword,
            String confirmPassword) {

        if (staffId <= 0) {
            throw new IllegalArgumentException("Invalid administrator session.");
        }
        String cleanCurrent = currentPassword == null ? "" : currentPassword.trim();
        String cleanNew = newPassword == null ? "" : newPassword.trim();
        String cleanConfirm = confirmPassword == null ? "" : confirmPassword.trim();

        if (cleanCurrent.isEmpty()) {
            throw new IllegalArgumentException("Please enter your current password.");
        }
        if (cleanNew.length() < 6) {
            throw new IllegalArgumentException("New password must be at least 6 characters.");
        }
        if (!cleanNew.equals(cleanConfirm)) {
            throw new IllegalArgumentException("Confirm password does not match.");
        }
        if (cleanNew.equals(cleanCurrent)) {
            throw new IllegalArgumentException("New password must be different from your current password.");
        }
        if (!dao.verifyStaffPassword(staffId, cleanCurrent)) {
            throw new IllegalArgumentException("Current password is incorrect.");
        }
        if (!dao.resetStaffPassword(staffId, cleanNew)) {
            throw new IllegalArgumentException("Unable to update password. Please try again.");
        }

        auditLogDAO.insertAuditLog(
                staffId,
                "CHANGE_OWN_PASSWORD",
                "Staff",
                String.valueOf(staffId),
                null,
                "{\"Note\":\"Administrator changed own password\"}"
        );
    }

    public void updateOwnProfile(int staffId, String fullName, String phone) {
        if (staffId <= 0) {
            throw new IllegalArgumentException("Invalid administrator session.");
        }
        String cleanName = trimToEmpty(fullName);
        String cleanPhone = trimToEmpty(phone);

        if (cleanName.isEmpty() || cleanName.length() > 100) {
            throw new IllegalArgumentException("Full name is required and must be at most 100 characters.");
        }
        if (!cleanPhone.isEmpty() && !PHONE_PATTERN.matcher(cleanPhone).matches()) {
            throw new IllegalArgumentException("Phone number format is invalid (7-20 digits/characters).");
        }

        Map<String, Object> snapshot = dao.getAccountSnapshot("STAFF", staffId);
        if (snapshot == null) {
            throw new IllegalArgumentException("Administrator account was not found.");
        }

        String oldName = trimToEmpty(valueAsString(snapshot.get("fullName")));
        String oldPhone = trimToEmpty(valueAsString(snapshot.get("phone")));

        if (cleanName.equals(oldName) && cleanPhone.equals(oldPhone)) {
            throw new IllegalArgumentException("No changes detected: full name and phone remain unchanged.");
        }
        if (!cleanPhone.isEmpty() && !cleanPhone.equals(oldPhone) && dao.phoneExistsInAnyAccount(cleanPhone, staffId)) {
            throw new IllegalArgumentException("Phone number is already registered to another account.");
        }

        if (!dao.updateStaffInfo(staffId, cleanName, cleanPhone)) {
            throw new IllegalArgumentException("Unable to update profile information.");
        }

        String oldData = "{\"FullName\":\"" + escapeJson(oldName) + "\",\"Phone\":\"" + escapeJson(oldPhone) + "\"}";
        String newData = "{\"FullName\":\"" + escapeJson(cleanName) + "\",\"Phone\":\"" + escapeJson(cleanPhone) + "\"}";
        auditLogDAO.insertAuditLog(staffId, "UPDATE_OWN_PROFILE", "Staff", String.valueOf(staffId), oldData, newData);
    }

    public String exportUsersCsv(
            String keyword,
            String userType,
            String role,
            String status,
            String sort) {

        List<Map<String, Object>> users = dao.getAllUsersForExport(
                normalizeKeyword(keyword),
                normalizeUserType(userType),
                normalizeRole(role),
                normalizeStatus(status),
                normalizeSort(sort)
        );

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        StringBuilder csv = new StringBuilder();
        csv.append("UserID,UserType,FullName,Email,Phone,Role,Status,CreatedAt,UpdatedAt\n");

        for (Map<String, Object> u : users) {
            csv.append(csvCell(u.get("userId"))).append(',')
               .append(csvCell(u.get("userType"))).append(',')
               .append(csvCell(u.get("fullName"))).append(',')
               .append(csvCell(u.get("email"))).append(',')
               .append(csvCell(u.get("phone"))).append(',')
               .append(csvCell(u.get("roleName"))).append(',')
               .append(csvCell(u.get("status"))).append(',')
               .append(csvCell(formatTimestamp(u.get("createdAt"), dateFormat))).append(',')
               .append(csvCell(formatTimestamp(u.get("updatedAt"), dateFormat))).append('\n');
        }
        return csv.toString();
    }

    private boolean updateStatusInternal(
            String userType,
            int userId,
            String status,
            String reason,
            Integer currentAdminId,
            boolean requireBanReason) {

        userType = normalizeRequiredUserType(userType);
        status = normalizeRequiredStatus(status);
        String cleanReason = trimToEmpty(reason);

        if (userId <= 0) {
            throw new IllegalArgumentException("Invalid account ID.");
        }
        if ("STAFF".equals(userType) && currentAdminId != null && userId == currentAdminId && !"ACTIVE".equals(status)) {
            throw new FieldValidationException("status", "You cannot lock, deactivate, or ban your own admin account.");
        }

        Map<String, Object> snapshot = dao.getAccountSnapshot(userType, userId);
        if (snapshot == null) {
            throw new IllegalArgumentException("Account was not found.");
        }

        String oldStatus = valueAsString(snapshot.get("status"));
        String oldRoleName = valueAsString(snapshot.get("roleName"));

        if ("STAFF".equals(userType) && "ADMIN".equalsIgnoreCase(oldRoleName)) {
            throw new FieldValidationException("status", "You cannot lock, deactivate, or ban another administrator account.");
        }

        if (status.equalsIgnoreCase(oldStatus)) {
            return false;
        }

        if (requireBanReason && "BANNED".equals(status) && cleanReason.isEmpty()) {
            throw new FieldValidationException("reason", "Please provide a reason when banning an account.");
        }

        if ("STAFF".equals(userType)
                && "ADMIN".equalsIgnoreCase(oldRoleName)
                && "ACTIVE".equalsIgnoreCase(oldStatus)
                && !"ACTIVE".equals(status)
                && dao.countActiveAdmins() <= 1) {
            throw new FieldValidationException("status", "Cannot lock or ban the last active ADMIN account.");
        }

        if (!dao.updateStatus(userType, userId, status)) {
            throw new IllegalArgumentException("Account was not found or status was not updated.");
        }

        String oldData = "{\"Status\":\"" + escapeJson(oldStatus) + "\"}";
        StringBuilder newData = new StringBuilder("{\"Status\":\"").append(escapeJson(status)).append("\"");
        if (!cleanReason.isEmpty()) {
            newData.append(",\"Reason\":\"").append(escapeJson(cleanReason)).append("\"");
        }
        newData.append("}");

        auditLogDAO.insertAuditLog(
                currentAdminId,
                "UPDATE_STATUS",
                "STAFF".equals(userType) ? "Staff" : "Customer",
                String.valueOf(userId),
                oldData,
                newData.toString()
        );
        return true;
    }

    private boolean updateStaffRoleInternal(int staffId, int roleId, String reason, Integer currentAdminId) {
        if (staffId <= 0 || roleId <= 0) {
            throw new IllegalArgumentException("Invalid staff or role ID.");
        }
        if (currentAdminId != null && staffId == currentAdminId) {
            throw new FieldValidationException("roleId", "You cannot change your own admin role.");
        }

        String newRoleName = dao.getRoleNameById(roleId);
        if (newRoleName == null) {
            throw new FieldValidationException("roleId", "Invalid staff role.");
        }

        Map<String, Object> snapshot = dao.getAccountSnapshot("STAFF", staffId);
        if (snapshot == null) {
            throw new IllegalArgumentException("Staff account was not found.");
        }

        Integer oldRoleId = snapshot.get("roleId") instanceof Number n ? n.intValue() : null;
        String oldRoleName = valueAsString(snapshot.get("roleName"));
        String currentStatus = valueAsString(snapshot.get("status"));

        if ("ADMIN".equalsIgnoreCase(oldRoleName)) {
            throw new FieldValidationException("roleId", "You cannot change the role of another administrator account.");
        }

        if (oldRoleId != null && oldRoleId == roleId) {
            return false;
        }

        if ("ADMIN".equalsIgnoreCase(oldRoleName)
                && "ACTIVE".equalsIgnoreCase(currentStatus)
                && !"ADMIN".equalsIgnoreCase(newRoleName)
                && dao.countActiveAdmins() <= 1) {
            throw new FieldValidationException("roleId", "Cannot demote the last active ADMIN account.");
        }

        if (!dao.updateStaffRole(staffId, roleId)) {
            throw new IllegalArgumentException("Staff account was not found or role was not updated.");
        }

        String cleanReason = trimToEmpty(reason);
        String oldData = "{\"RoleID\":" + (oldRoleId != null ? oldRoleId : "null")
                + ",\"RoleName\":\"" + escapeJson(oldRoleName) + "\"}";
        StringBuilder newData = new StringBuilder("{\"RoleID\":").append(roleId)
                .append(",\"RoleName\":\"").append(escapeJson(newRoleName)).append("\"");
        if (!cleanReason.isEmpty()) {
            newData.append(",\"Reason\":\"").append(escapeJson(cleanReason)).append("\"");
        }
        newData.append("}");

        auditLogDAO.insertAuditLog(
                currentAdminId,
                "UPDATE_ROLE",
                "Staff",
                String.valueOf(staffId),
                oldData,
                newData.toString()
        );
        return true;
    }

    public int normalizePage(int page) {
        return Math.max(page, 1);
    }

    public int getTotalPages(int totalItems) {
        return totalItems <= 0 ? 1 : (int) Math.ceil((double) totalItems / DEFAULT_PAGE_SIZE);
    }

    public int getTotalPages(int totalItems, int pageSize) {
        int size = pageSize > 0 ? pageSize : DEFAULT_PAGE_SIZE;
        return totalItems <= 0 ? 1 : (int) Math.ceil((double) totalItems / size);
    }

    public String normalizeKeyword(String keyword) {
        return keyword == null ? "" : keyword.trim();
    }

    public String normalizeUserType(String userType) {
        String value = userType == null || userType.isBlank() ? "ALL" : userType.trim().toUpperCase();
        return USER_TYPES.contains(value) ? value : "ALL";
    }

    public String normalizeRole(String role) {
        String value = role == null || role.isBlank() ? "ALL" : role.trim().toUpperCase();
        return ROLES.contains(value) ? value : "ALL";
    }

    public String normalizeStatus(String status) {
        String value = status == null || status.isBlank() ? "ALL" : status.trim().toUpperCase();
        return STATUSES.contains(value) ? value : "ALL";
    }

    public String normalizeSort(String sort) {
        String value = sort == null || sort.isBlank() ? "newest" : sort.trim().toLowerCase();
        return SORTS.contains(value) ? value : "newest";
    }

    private String normalizeRequiredUserType(String userType) {
        String value = userType == null ? "" : userType.trim().toUpperCase();
        if (!"CUSTOMER".equals(value) && !"STAFF".equals(value)) {
            throw new IllegalArgumentException("Invalid account type.");
        }
        return value;
    }

    private String normalizeRequiredStatus(String status) {
        String value = trimToEmpty(status).toUpperCase();
        if (!"ACTIVE".equals(value) && !"INACTIVE".equals(value) && !"BANNED".equals(value)) {
            throw new IllegalArgumentException("Invalid account status.");
        }
        return value;
    }

    private String normalizeNewStaffStatus(String status) {
        String value = trimToEmpty(status).toUpperCase();
        if (value.isEmpty()) {
            return "ACTIVE";
        }
        if (!"ACTIVE".equals(value) && !"INACTIVE".equals(value)) {
            throw new FieldValidationException("status", "Initial status for a new staff account must be ACTIVE or INACTIVE.");
        }
        return value;
    }

    private String formatTimestamp(Object ts, SimpleDateFormat dateFormat) {
        if (ts instanceof Date d) {
            return dateFormat.format(d);
        }
        return ts == null ? "" : ts.toString();
    }

    private String csvCell(Object value) {
        String text = value == null ? "" : value.toString();
        if (!text.isEmpty()) {
            char first = text.charAt(0);
            if (first == '=' || first == '+' || first == '-' || first == '@' || first == '\t' || first == '\r') {
                text = "'" + text;
            }
        }
        return "\"" + text.replace("\"", "\"\"") + "\"";
    }

    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", " ")
                .replace("\n", " ");
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String valueAsString(Object value) {
        return value == null ? "" : value.toString();
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
