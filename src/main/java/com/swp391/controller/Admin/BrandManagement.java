package com.swp391.controller.Admin;

import com.swp391.model.Brand;
import com.swp391.model.Staff;
import com.swp391.service.Admin.BrandService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/**
 * Controller for Admin Brand Management.
 * Explicit 4-tier MVC implementation matching Manager Product Management style.
 */
@WebServlet("/admin/brands")
public class BrandManagement extends HttpServlet {

    private BrandService brandService;

    @Override
    public void init() {
        this.brandService = new BrandService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "brands");

        // Flash message handling from session
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object success = session.getAttribute("brandSuccess");
            Object error = session.getAttribute("brandError");
            if (success != null) {
                request.setAttribute("successMessage", success);
                session.removeAttribute("brandSuccess");
            }
            if (error != null) {
                request.setAttribute("errorMessage", error);
                session.removeAttribute("brandError");
            }
            // Flash attributes for modal auto-reopen on error (Solution 2)
            Object modalError = session.getAttribute("brandModalError");
            if (modalError != null) {
                request.setAttribute("modalError", modalError);
                request.setAttribute("modalAction", session.getAttribute("brandModalAction"));
                request.setAttribute("modalId", session.getAttribute("brandModalId"));
                request.setAttribute("modalName", session.getAttribute("brandModalName"));
                request.setAttribute("modalDescription", session.getAttribute("brandModalDescription"));
                request.setAttribute("modalStatus", session.getAttribute("brandModalStatus"));

                session.removeAttribute("brandModalError");
                session.removeAttribute("brandModalAction");
                session.removeAttribute("brandModalId");
                session.removeAttribute("brandModalName");
                session.removeAttribute("brandModalDescription");
                session.removeAttribute("brandModalStatus");
            }
        }

        // Parse search & filter parameters
        String keyword = brandService.normalizeKeyword(request.getParameter("keyword"));
        String status = brandService.normalizeFilterStatus(request.getParameter("status"));
        int page = parseInt(request.getParameter("page"), 1);
        if (page < 1) page = 1;

        // Count items and calculate total pages
        int totalItems = brandService.countBrands(keyword, status);
        int totalPages = brandService.getTotalPages(totalItems);
        if (page > totalPages) {
            page = totalPages;
        }

        // Fetch data
        List<Brand> brands = brandService.getBrands(keyword, status, page);
        Map<String, Integer> stats = brandService.getBrandStats();

        // Bind attributes
        request.setAttribute("brands", brands);
        request.setAttribute("stats", stats);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        request.getRequestDispatcher("/views/admin/brands.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Integer adminId = getCurrentAdminId(session);
        String action = request.getParameter("action");

        // Retain query parameters for redirect
        String keyword = valueOrEmpty(request.getParameter("keyword"));
        String statusParam = valueOrEmpty(request.getParameter("statusParam"));
        String pageParam = valueOrEmpty(request.getParameter("page"));

        try {
            if ("create".equals(action)) {
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String status = request.getParameter("status");

                int newId = brandService.createBrand(name, description, status, adminId);
                session.setAttribute("brandSuccess", "Brand #" + newId + " created successfully.");
                keyword = "";
                statusParam = "ALL";
                pageParam = "1";
            } else if ("update".equals(action)) {
                int id = parsePositiveInt(request.getParameter("id"), "Invalid brand ID.");
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String status = request.getParameter("status");

                brandService.updateBrand(id, name, description, status, adminId);
                session.setAttribute("brandSuccess", "Brand updated successfully.");
            } else if ("toggleStatus".equals(action)) {
                int id = parsePositiveInt(request.getParameter("id"), "Invalid brand ID.");
                String status = request.getParameter("status");

                brandService.updateBrandStatus(id, status, adminId);
                session.setAttribute("brandSuccess", "Brand status updated successfully.");
            } else {
                throw new IllegalArgumentException("Invalid brand management action.");
            }
        } catch (IllegalArgumentException e) {
            handlePostError(session, action, request, e.getMessage());
        } catch (Exception e) {
            handlePostError(session, action, request, "Unable to process request: " + e.getMessage());
        }

        // Build redirect URL preserving filters
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/brands?");
        if (!keyword.isEmpty()) {
            redirectUrl.append("keyword=").append(URLEncoder.encode(keyword, StandardCharsets.UTF_8)).append("&");
        }
        if (!statusParam.isEmpty() && !"ALL".equalsIgnoreCase(statusParam)) {
            redirectUrl.append("status=").append(URLEncoder.encode(statusParam, StandardCharsets.UTF_8)).append("&");
        }
        if (!pageParam.isEmpty() && !"1".equals(pageParam)) {
            redirectUrl.append("page=").append(URLEncoder.encode(pageParam, StandardCharsets.UTF_8)).append("&");
        }

        String finalUrl = redirectUrl.toString();
        if (finalUrl.endsWith("&") || finalUrl.endsWith("?")) {
            finalUrl = finalUrl.substring(0, finalUrl.length() - 1);
        }
        response.sendRedirect(finalUrl);
    }

    private Integer getCurrentAdminId(HttpSession session) {
        if (session == null) return null;
        Object staffObj = session.getAttribute("staff");
        return (staffObj instanceof Staff staff) ? staff.getStaffId() : null;
    }

    private void handlePostError(HttpSession session, String action, HttpServletRequest request, String errorMsg) {
        if ("create".equals(action) || "update".equals(action)) {
            session.setAttribute("brandModalError", errorMsg);
            session.setAttribute("brandModalAction", action);
            session.setAttribute("brandModalId", request.getParameter("id"));
            session.setAttribute("brandModalName", request.getParameter("name"));
            session.setAttribute("brandModalDescription", request.getParameter("description"));
            session.setAttribute("brandModalStatus", request.getParameter("status"));
        } else {
            session.setAttribute("brandError", errorMsg);
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
            int parsed = Integer.parseInt(value != null ? value.trim() : "");
            if (parsed > 0) return parsed;
        } catch (NumberFormatException ignored) {
        }
        throw new IllegalArgumentException(message);
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
