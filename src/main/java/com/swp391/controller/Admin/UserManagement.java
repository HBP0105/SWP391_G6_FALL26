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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

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
        }

        String keyword = request.getParameter("keyword");
        String userType = request.getParameter("userType");
        String status = request.getParameter("status");
        int page = service.normalizePage(parseInt(request.getParameter("page"), 1));
        int pageSize = service.normalizePageSize(parseInt(request.getParameter("pageSize"), 10));

        int totalItems = service.countUsers(keyword, userType, status);
        int totalPages = service.getTotalPages(totalItems, pageSize);
        if (page > totalPages) {
            page = totalPages;
        }

        request.setAttribute("users", service.getUsers(keyword, userType, status, page, pageSize));
        request.setAttribute("stats", service.getUserStats());
        request.setAttribute("roles", service.getStaffRoles());
        request.setAttribute("keyword", keyword == null ? "" : keyword.trim());
        request.setAttribute("selectedUserType", userType == null || userType.isBlank() ? "ALL" : userType.toUpperCase());
        request.setAttribute("selectedStatus", status == null || status.isBlank() ? "ALL" : status.toUpperCase());
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
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
        String statusParam = valueOrEmpty(request.getParameter("statusParam"));
        String pageParam = valueOrEmpty(request.getParameter("page"));
        String pageSizeParam = valueOrEmpty(request.getParameter("pageSize"));

        try {
            if ("updateStatus".equals(action)) {
                String targetType = request.getParameter("targetUserType");
                if (targetType == null || targetType.isBlank()) {
                    targetType = request.getParameter("userType");
                }
                service.updateStatus(
                        targetType,
                        parsePositiveInt(request.getParameter("userId"), "Invalid account ID."),
                        request.getParameter("status"),
                        currentAdminId
                );
                session.setAttribute("successMessage", "Account status updated successfully.");
            } else if ("updateRole".equals(action)) {
                service.updateStaffRole(
                        parsePositiveInt(request.getParameter("staffId"), "Invalid staff ID."),
                        parsePositiveInt(request.getParameter("roleId"), "Invalid role ID."),
                        currentAdminId
                );
                session.setAttribute("successMessage", "Staff role updated successfully.");
            } else if ("updateAccess".equals(action)) {
                String targetType = request.getParameter("targetUserType");
                if (targetType == null || targetType.isBlank()) {
                    targetType = request.getParameter("userType");
                }
                int targetUserId = parsePositiveInt(request.getParameter("userId"), "Invalid account ID.");
                Integer roleId = parseOptionalPositiveInt(request.getParameter("roleId"));
                String newStatus = request.getParameter("status");

                service.updateAccess(targetType, targetUserId, roleId, newStatus, currentAdminId);
                session.setAttribute("successMessage", "Account access permissions and status updated successfully.");
            } else {
                throw new IllegalArgumentException("Invalid account access action.");
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Unable to update account access: " + e.getMessage());
        }

        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/users?");
        if (!keyword.isEmpty()) {
            redirectUrl.append("keyword=").append(URLEncoder.encode(keyword, StandardCharsets.UTF_8)).append("&");
        }
        if (!userTypeParam.isEmpty() && !"ALL".equalsIgnoreCase(userTypeParam)) {
            redirectUrl.append("userType=").append(URLEncoder.encode(userTypeParam, StandardCharsets.UTF_8)).append("&");
        }
        if (!statusParam.isEmpty() && !"ALL".equalsIgnoreCase(statusParam)) {
            redirectUrl.append("status=").append(URLEncoder.encode(statusParam, StandardCharsets.UTF_8)).append("&");
        }
        if (!pageParam.isEmpty()) {
            redirectUrl.append("page=").append(URLEncoder.encode(pageParam, StandardCharsets.UTF_8)).append("&");
        }
        if (!pageSizeParam.isEmpty()) {
            redirectUrl.append("pageSize=").append(URLEncoder.encode(pageSizeParam, StandardCharsets.UTF_8)).append("&");
        }

        String finalUrl = redirectUrl.toString();
        if (finalUrl.endsWith("&") || finalUrl.endsWith("?")) {
            finalUrl = finalUrl.substring(0, finalUrl.length() - 1);
        }
        response.sendRedirect(finalUrl);
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
