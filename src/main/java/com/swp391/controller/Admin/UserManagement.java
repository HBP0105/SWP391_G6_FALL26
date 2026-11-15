package com.swp391.controller.Admin;

import com.swp391.model.Staff;
import com.swp391.service.Admin.UserManagementService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@WebServlet({"/admin/users", "/admin/user-management"})
public class UserManagement extends HttpServlet {

    private UserManagementService service;

    @Override
    public void init() {
        service = new UserManagementService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("exportCsv".equalsIgnoreCase(action)) {
            handleExportCsv(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        Integer currentAdminId = getCurrentAdminId(session);
        request.setAttribute("currentAdminId", currentAdminId);

        if (session != null) {
            Object success = session.getAttribute("successMessage");
            if (success == null) success = session.getAttribute("accountAccessSuccess");
            if (success == null) success = session.getAttribute("userManagementSuccess");

            Object error = session.getAttribute("errorMessage");
            if (error == null) error = session.getAttribute("accountAccessError");
            if (error == null) error = session.getAttribute("userManagementError");

            if (success != null) {
                request.setAttribute("successMessage", success);
                session.removeAttribute("successMessage");
                session.removeAttribute("accountAccessSuccess");
                session.removeAttribute("userManagementSuccess");
            }
            if (error != null) {
                request.setAttribute("errorMessage", error);
                session.removeAttribute("errorMessage");
                session.removeAttribute("accountAccessError");
                session.removeAttribute("userManagementError");
            }

            // Flash attributes for modal auto-reopen on error (Solution 2)
            Object modalError = session.getAttribute("userModalError");
            if (modalError != null) {
                request.setAttribute("modalError", modalError);
                request.setAttribute("modalAction", session.getAttribute("userModalAction"));
                request.setAttribute("modalFullName", session.getAttribute("userModalFullName"));
                request.setAttribute("modalEmail", session.getAttribute("userModalEmail"));
                request.setAttribute("modalPhone", session.getAttribute("userModalPhone"));
                request.setAttribute("modalRoleId", session.getAttribute("userModalRoleId"));
                request.setAttribute("modalStatus", session.getAttribute("userModalStatus"));
                request.setAttribute("modalStaffId", session.getAttribute("userModalStaffId"));
                request.setAttribute("modalTargetUserType", session.getAttribute("userModalTargetUserType"));
                request.setAttribute("modalUserId", session.getAttribute("userModalUserId"));
                request.setAttribute("modalReason", session.getAttribute("userModalReason"));

                session.removeAttribute("userModalError");
                session.removeAttribute("userModalAction");
                session.removeAttribute("userModalFullName");
                session.removeAttribute("userModalEmail");
                session.removeAttribute("userModalPhone");
                session.removeAttribute("userModalRoleId");
                session.removeAttribute("userModalStatus");
                session.removeAttribute("userModalStaffId");
                session.removeAttribute("userModalTargetUserType");
                session.removeAttribute("userModalUserId");
                session.removeAttribute("userModalReason");
            }
        }

        if ("detail".equalsIgnoreCase(action)) {
            try {
                String targetType = request.getParameter("detailUserType");
                if (targetType == null || targetType.isBlank()) {
                    targetType = request.getParameter("userType");
                }
                String targetIdParam = request.getParameter("detailUserId");
                if (targetIdParam == null || targetIdParam.isBlank()) {
                    targetIdParam = request.getParameter("userId");
                }
                int userId = parsePositiveInt(targetIdParam, "Invalid account ID.");
                Map<String, Object> detail = service.getUserDetail(targetType, userId);
                request.setAttribute("userDetail", detail);
            } catch (IllegalArgumentException e) {
                request.setAttribute("errorMessage", e.getMessage());
            } catch (Exception e) {
                request.setAttribute("errorMessage", "Unable to load user details.");
            }
        }

        String keyword = service.normalizeKeyword(request.getParameter("keyword"));
        String userType = service.normalizeUserType(request.getParameter("userType"));
        String role = service.normalizeRole(request.getParameter("role"));
        String status = service.normalizeStatus(request.getParameter("status"));
        String sort = service.normalizeSort(request.getParameter("sort"));
        int page = service.normalizePage(parseInt(request.getParameter("page"), 1));

        int totalItems = service.countUsers(keyword, userType, role, status);
        int totalPages = service.getTotalPages(totalItems);
        if (page > totalPages) {
            page = totalPages;
        }

        request.setAttribute("users", service.getUsers(keyword, userType, role, status, sort, page));
        request.setAttribute("stats", service.getUserStats());
        request.setAttribute("roles", service.getStaffRoles());
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedUserType", userType);
        request.setAttribute("selectedRole", role);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", UserManagementService.DEFAULT_PAGE_SIZE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        request.getRequestDispatcher("/views/admin/user-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Integer currentAdminId = getCurrentAdminId(session);
        String action = request.getParameter("action");

        // Preserve redirect query parameters
        String keyword = valueOrEmpty(request.getParameter("keyword"));
        String userTypeParam = valueOrEmpty(request.getParameter("userType"));
        String roleParam = valueOrEmpty(request.getParameter("roleParam"));
        String statusParam = valueOrEmpty(request.getParameter("statusParam"));
        String sortParam = valueOrEmpty(request.getParameter("sort"));
        String pageParam = valueOrEmpty(request.getParameter("page"));

        try {
            if ("updateStatus".equals(action)) {
                String targetType = request.getParameter("targetUserType");
                if (targetType == null || targetType.isBlank()) {
                    targetType = request.getParameter("userType");
                }
                boolean changed = service.updateStatus(
                        targetType,
                        parsePositiveInt(request.getParameter("userId"), "Invalid account ID."),
                        request.getParameter("status"),
                        request.getParameter("reason"),
                        currentAdminId
                );
                session.setAttribute("successMessage",
                        changed ? "Account status updated successfully." : "Account status was already up to date.");
            } else if ("updateRole".equals(action)) {
                boolean changed = service.updateStaffRole(
                        parsePositiveInt(request.getParameter("staffId"), "Invalid staff ID."),
                        parsePositiveInt(request.getParameter("roleId"), "Invalid role ID."),
                        request.getParameter("reason"),
                        currentAdminId
                );
                session.setAttribute("successMessage",
                        changed ? "Staff role updated successfully." : "Staff role was already up to date.");
            } else if ("updateAccess".equals(action)) {
                String targetType = request.getParameter("targetUserType");
                if (targetType == null || targetType.isBlank()) {
                    targetType = request.getParameter("userType");
                }
                int targetUserId = parsePositiveInt(request.getParameter("userId"), "Invalid account ID.");
                Integer roleId = parseOptionalPositiveInt(request.getParameter("roleId"));
                String newStatus = request.getParameter("status");
                String reason = request.getParameter("reason");

                String message = service.updateAccess(targetType, targetUserId, roleId, newStatus, reason, currentAdminId);
                session.setAttribute("successMessage", message);
            } else if ("createStaff".equals(action)) {
                int newStaffId = service.createStaff(
                        request.getParameter("fullName"),
                        request.getParameter("email"),
                        request.getParameter("phone"),
                        request.getParameter("password"),
                        parsePositiveInt(request.getParameter("roleId"), "Invalid staff role."),
                        request.getParameter("status"),
                        currentAdminId
                );
                session.setAttribute("successMessage", "Created new staff account #" + newStaffId + " successfully.");
                // Reset filter/page so the newly created staff account (newest) appears immediately at top
                keyword = "";
                userTypeParam = "ALL";
                roleParam = "ALL";
                statusParam = "ALL";
                sortParam = "newest";
                pageParam = "1";
            } else if ("updateStaffInfo".equals(action)) {
                service.updateStaffInfo(
                        parsePositiveInt(request.getParameter("staffId"), "Invalid staff ID."),
                        request.getParameter("fullName"),
                        request.getParameter("phone"),
                        currentAdminId
                );
                session.setAttribute("successMessage", "Staff profile information updated successfully.");
            } else if ("resetPassword".equals(action)) {
                service.resetStaffPassword(
                        parsePositiveInt(request.getParameter("staffId"), "Invalid staff ID."),
                        request.getParameter("newPassword"),
                        request.getParameter("confirmPassword"),
                        currentAdminId
                );
                session.setAttribute("successMessage", "Staff password has been reset successfully.");
            } else {
                throw new IllegalArgumentException("Invalid account management action.");
            }
        } catch (IllegalArgumentException e) {
            handlePostError(session, action, request, e.getMessage());
        } catch (Exception e) {
            handlePostError(session, action, request, "Unable to process request: " + e.getMessage());
        }

        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/users?");
        appendQueryParam(redirectUrl, "keyword", keyword);
        if (!userTypeParam.isEmpty() && !"ALL".equalsIgnoreCase(userTypeParam)) {
            appendQueryParam(redirectUrl, "userType", userTypeParam);
        }
        if (!roleParam.isEmpty() && !"ALL".equalsIgnoreCase(roleParam)) {
            appendQueryParam(redirectUrl, "role", roleParam);
        }
        if (!statusParam.isEmpty() && !"ALL".equalsIgnoreCase(statusParam)) {
            appendQueryParam(redirectUrl, "status", statusParam);
        }
        if (!sortParam.isEmpty() && !"newest".equalsIgnoreCase(sortParam)) {
            appendQueryParam(redirectUrl, "sort", sortParam);
        }
        if (!pageParam.isEmpty() && !"1".equals(pageParam)) {
            appendQueryParam(redirectUrl, "page", pageParam);
        }

        String finalUrl = redirectUrl.toString();
        if (finalUrl.endsWith("&") || finalUrl.endsWith("?")) {
            finalUrl = finalUrl.substring(0, finalUrl.length() - 1);
        }

        response.sendRedirect(finalUrl);
    }

    private void handleExportCsv(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String keyword = request.getParameter("keyword");
        String userType = request.getParameter("userType");
        String role = request.getParameter("role");
        String status = request.getParameter("status");
        String sort = request.getParameter("sort");

        String csvContent = service.exportUsersCsv(keyword, userType, role, status, sort);
        response.setContentType("text/csv; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"users-export.csv\"");

        try (OutputStream out = response.getOutputStream()) {
            out.write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF}); // UTF-8 BOM for Excel
            out.write(csvContent.getBytes(StandardCharsets.UTF_8));
            out.flush();
        }
    }

    private void appendQueryParam(StringBuilder sb, String key, String value) {
        if (value != null && !value.isEmpty()) {
            sb.append(key).append("=").append(URLEncoder.encode(value, StandardCharsets.UTF_8)).append("&");
        }
    }

    private Integer getCurrentAdminId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object staffObject = session.getAttribute("staff");
        if (staffObject instanceof Staff staff) {
            return staff.getStaffId();
        }
        return null;
    }

    private void handlePostError(HttpSession session, String action, HttpServletRequest request, String errorMsg) {
        if ("createStaff".equals(action) || "updateStaffInfo".equals(action)
                || "resetPassword".equals(action) || "updateAccess".equals(action)) {
            session.setAttribute("userModalError", errorMsg);
            session.setAttribute("userModalAction", action);
            session.setAttribute("userModalFullName", request.getParameter("fullName"));
            session.setAttribute("userModalEmail", request.getParameter("email"));
            session.setAttribute("userModalPhone", request.getParameter("phone"));
            session.setAttribute("userModalRoleId", request.getParameter("roleId"));
            session.setAttribute("userModalStatus", request.getParameter("status"));
            session.setAttribute("userModalStaffId", request.getParameter("staffId"));
            session.setAttribute("userModalTargetUserType", request.getParameter("targetUserType"));
            session.setAttribute("userModalUserId", request.getParameter("userId"));
            session.setAttribute("userModalReason", request.getParameter("reason"));
        } else {
            session.setAttribute("errorMessage", errorMsg);
        }
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return value == null || value.isBlank() ? defaultValue : Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private int parsePositiveInt(String value, String message) {
        try {
            int parsed = Integer.parseInt(value);
            if (parsed > 0) {
                return parsed;
            }
        } catch (Exception ignored) {
        }
        throw new IllegalArgumentException(message);
    }

    private Integer parseOptionalPositiveInt(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
