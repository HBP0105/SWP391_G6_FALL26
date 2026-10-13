package com.swp391.controller.manager;

import com.swp391.model.Voucher;
import com.swp391.service.VoucherService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet(urlPatterns = {"/Manager/Voucher", "/Manager/vouchers", "/manager/vouchers"})
public class Vourcher extends HttpServlet {

    private VoucherService voucherService;

    @Override
    public void init() {
        voucherService = new VoucherService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "voucher");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            request.getRequestDispatcher("/views/Manager/addVoucher.jsp")
                    .forward(request, response);
            return;
        }

        if ("detail".equals(action)) {
            String idStr = request.getParameter("id");
            try {
                int id = Integer.parseInt(idStr);
                Voucher voucher = voucherService.getVoucherById(id);
                if (voucher == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Voucher not found");
                    return;
                }
                request.setAttribute("voucher", voucher);
                request.getRequestDispatcher("/views/Manager/voucherDetail.jsp")
                        .forward(request, response);
                return;
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid voucher ID");
                return;
            }
        }

        String keyword = request.getParameter("keyword");
        String discountType = request.getParameter("discountType");
        String status = request.getParameter("status");
        String validPeriod = request.getParameter("validPeriod");
        String sort = request.getParameter("sort");

        int page = 1;
        int pageSize = 10;

        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException ignored) {
                page = 1;
            }
        }

        String pageSizeParam = request.getParameter("pageSize");
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            try {
                pageSize = Integer.parseInt(pageSizeParam.trim());
            } catch (NumberFormatException ignored) {
                pageSize = 10;
            }
        }

        page = voucherService.normalizePage(page);
        pageSize = voucherService.normalizePageSize(pageSize);

        int totalItems = voucherService.countVouchers(keyword, discountType, status, validPeriod);
        int totalPages = voucherService.getTotalPages(totalItems, pageSize);

        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }

        List<Voucher> vouchers = voucherService.getVouchers(
                keyword,
                discountType,
                status,
                validPeriod,
                sort,
                page,
                pageSize
        );

        request.setAttribute("vouchers", vouchers);
        request.setAttribute("keyword", keyword != null ? keyword.trim() : "");
        request.setAttribute("selectedDiscountType", discountType != null ? discountType.trim() : "");
        request.setAttribute("selectedStatus", status != null ? status.trim() : "");
        request.setAttribute("selectedValidPeriod", validPeriod != null ? validPeriod.trim() : "");
        request.setAttribute("selectedSort", sort != null ? sort.trim() : "");

        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("/views/Manager/voucher.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("changeStatus".equals(action)) {
            handleChangeStatus(request, response);
            return;
        }

        if ("add".equals(action)) {
            handleAddVoucher(request, response);
            return;
        }

        doGet(request, response);
    }

    private void handleAddVoucher(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String code = request.getParameter("voucherCode");
        String description = request.getParameter("description");
        String discountType = request.getParameter("discountType");
        String discountValueStr = request.getParameter("discountValue");
        String minOrderStr = request.getParameter("minOrderAmount");
        String maxDiscountStr = request.getParameter("maxDiscount");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String usageLimitStr = request.getParameter("usageLimit");
        String status = request.getParameter("status");

        try {
            Voucher v = new Voucher();
            v.setVoucherCode(code);
            v.setDescription(description);
            v.setDiscountType(discountType);

            if (discountValueStr != null && !discountValueStr.isBlank()) {
                v.setDiscountValue(new BigDecimal(discountValueStr.trim()));
            }

            BigDecimal minOrder = BigDecimal.ZERO;
            if (minOrderStr != null && !minOrderStr.isBlank()) {
                minOrder = new BigDecimal(minOrderStr.trim());
            }
            v.setMinOrderAmount(minOrder);

            if (maxDiscountStr != null && !maxDiscountStr.isBlank()) {
                v.setMaxDiscount(new BigDecimal(maxDiscountStr.trim()));
            } else {
                v.setMaxDiscount(null);
            }

            if (startDateStr != null && !startDateStr.isBlank()) {
                v.setStartDate(LocalDateTime.parse(startDateStr.trim()));
            }

            if (endDateStr != null && !endDateStr.isBlank()) {
                v.setEndDate(LocalDateTime.parse(endDateStr.trim()));
            }

            if (usageLimitStr != null && !usageLimitStr.isBlank()) {
                v.setUsageLimit(Integer.parseInt(usageLimitStr.trim()));
            } else {
                v.setUsageLimit(null);
            }

            v.setUsedCount(0);
            v.setStatus(status != null && !status.isBlank() ? status.trim() : "ACTIVE");

            boolean success = voucherService.insertVoucher(v);
            if (success) {
                request.getSession().setAttribute("successMessage", "Voucher '" + v.getVoucherCode() + "' has been added successfully!");
                response.sendRedirect(request.getContextPath() + "/Manager/Voucher");
                return;
            } else {
                request.setAttribute("errorMessage", "Failed to insert voucher into database.");
            }
        } catch (IllegalArgumentException | DateTimeParseException e) {
            request.setAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Unexpected error: " + e.getMessage());
        }

        // Keep values on error
        request.setAttribute("activePage", "voucher");
        request.setAttribute("voucherCode", code);
        request.setAttribute("description", description);
        request.setAttribute("discountType", discountType);
        request.setAttribute("discountValue", discountValueStr);
        request.setAttribute("minOrderAmount", minOrderStr);
        request.setAttribute("maxDiscount", maxDiscountStr);
        request.setAttribute("startDate", startDateStr);
        request.setAttribute("endDate", endDateStr);
        request.setAttribute("usageLimit", usageLimitStr);
        request.setAttribute("status", status);

        request.getRequestDispatcher("/views/Manager/addVoucher.jsp").forward(request, response);
    }

    private void handleChangeStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idStr = request.getParameter("voucherId");
        String status = request.getParameter("status");

        try {
            int id = Integer.parseInt(idStr);
            boolean success = voucherService.changeStatus(id, status);
            if (success) {
                request.getSession().setAttribute("successMessage", "Voucher status updated to " + status + "!");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to update voucher status.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/Manager/Voucher");
    }
}
