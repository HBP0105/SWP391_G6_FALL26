package com.swp391.controller.Manager;

import com.swp391.service.Manager.ReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/Manager/Report")
public class Report extends HttpServlet {

    private ReportService reportService;

    @Override
    public void init() {
        reportService = new ReportService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "reports");
        request.setAttribute("today", LocalDate.now().toString());

        String tab = normalize(request.getParameter("tab"));
        if (tab.isEmpty()) {
            tab = "overview";
        }

        switch (tab) {
            case "revenue" -> handleRevenueTab(request, response);
            case "products" -> handleProductsTab(request, response);
            case "orders" -> handleOrdersTab(request, response);
            default -> handleOverviewTab(request, response);
        }
    }

    private void handleOverviewTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String period = request.getParameter("period");
        String rawStartDate = request.getParameter("startDate");
        String rawEndDate = request.getParameter("endDate");
        String rawStatus = request.getParameter("status");
        String yearStr = request.getParameter("year");
        String tableKeyword = request.getParameter("tableKeyword");
        String tableStatusRaw = request.getParameter("tableStatus");
        String tablePaymentRaw = request.getParameter("tablePaymentMethod");
        String tableSortRaw = request.getParameter("tableSort");
        int tablePage = reportService.normalizePage(parseInt(request.getParameter("tablePage"), 1));
        int tablePageSize = reportService.normalizePageSize(parseInt(request.getParameter("tablePageSize"), 10));

        Map<String, Object> overviewStats = new HashMap<>();
        List<Map<String, Object>> monthlyRevenue = Collections.emptyList();
        Map<String, Object> statusDistribution = new HashMap<>();
        List<Map<String, Object>> topProducts = Collections.emptyList();
        List<Map<String, Object>> categorySales = Collections.emptyList();
        List<Map<String, Object>> ordersReport = Collections.emptyList();
        int tableTotalItems = 0;
        int tableTotalPages = 1;
        String tableStatus = "ALL";
        String tablePaymentMethod = "ALL";
        String tableSort = "date_desc";

        String startDate = valueOrEmpty(rawStartDate);
        String endDate = valueOrEmpty(rawEndDate);
        String status = valueOrDefault(rawStatus, "ALL").toUpperCase();
        String selectedPeriod = valueOrDefault(period, "all");
        int currentYear = LocalDate.now().getYear();

        try {
            Map<String, Object> filters = reportService.resolveFilters(
                    period, rawStartDate, rawEndDate, rawStatus, yearStr
            );

            startDate = (String) filters.get("startDate");
            endDate = (String) filters.get("endDate");
            status = (String) filters.get("status");
            selectedPeriod = (String) filters.get("period");
            currentYear = (int) filters.get("currentYear");

            overviewStats = reportService.getOverviewStats(startDate, endDate, status);
            monthlyRevenue = reportService.getMonthlyRevenue(currentYear);
            statusDistribution = reportService.getOrderStatusDistribution(startDate, endDate);
            topProducts = reportService.getTopSellingProducts(5, startDate, endDate);
            categorySales = reportService.getCategorySales(startDate, endDate);
            tableStatus = reportService.normalizeOrderStatus(tableStatusRaw);
            tablePaymentMethod = reportService.normalizePaymentMethod(tablePaymentRaw);
            tableSort = reportService.normalizeOrderSort(tableSortRaw);
            tableTotalItems = reportService.countDetailedOrders(
                    startDate, endDate, tableStatus, tablePaymentMethod, tableKeyword
            );
            tableTotalPages = reportService.getTotalPages(tableTotalItems, tablePageSize);
            tablePage = Math.min(tablePage, tableTotalPages);
            ordersReport = reportService.getDetailedOrdersPaginated(
                    startDate, endDate, tableStatus, tablePaymentMethod, tableKeyword,
                    tableSort, tablePage, tablePageSize
            );
        } catch (IllegalArgumentException e) {
            request.setAttribute("reportFilterError", e.getMessage());
        }

        request.setAttribute("currentTab", "overview");
        request.setAttribute("overviewStats", overviewStats);
        request.setAttribute("monthlyRevenue", monthlyRevenue);
        request.setAttribute("statusDistribution", statusDistribution);
        request.setAttribute("topProducts", topProducts);
        request.setAttribute("categorySales", categorySales);
        request.setAttribute("ordersReport", ordersReport);
        request.setAttribute("selectedPeriod", selectedPeriod);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("currentYear", currentYear);
        request.setAttribute("tableKeyword", valueOrEmpty(tableKeyword));
        request.setAttribute("tableStatus", tableStatus);
        request.setAttribute("tablePaymentMethod", tablePaymentMethod);
        request.setAttribute("tableSort", tableSort);
        request.setAttribute("tablePage", tablePage);
        request.setAttribute("tablePageSize", tablePageSize);
        request.setAttribute("tableTotalItems", tableTotalItems);
        request.setAttribute("tableTotalPages", tableTotalPages);

        request.getRequestDispatcher("/views/Manager/report.jsp").forward(request, response);
    }

    private void handleRevenueTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String period = request.getParameter("period");
        String rawStartDate = request.getParameter("startDate");
        String rawEndDate = request.getParameter("endDate");
        String rawGroupBy = request.getParameter("groupBy");
        String yearStr = request.getParameter("year");
        String tableKeyword = request.getParameter("tableKeyword");
        String tableSort = reportService.normalizeRevenueSort(request.getParameter("tableSort"));

        Map<String, Object> revenueStats = new HashMap<>();
        List<Map<String, Object>> revenueTrend = Collections.emptyList();
        List<Map<String, Object>> revenueTable = Collections.emptyList();
        List<Map<String, Object>> paymentBreakdown = Collections.emptyList();

        String startDate = valueOrEmpty(rawStartDate);
        String endDate = valueOrEmpty(rawEndDate);
        String groupBy = valueOrDefault(rawGroupBy, "month").toLowerCase();
        String selectedPeriod = valueOrDefault(period, "all");
        int currentYear = LocalDate.now().getYear();

        try {
            groupBy = reportService.normalizeGroupBy(rawGroupBy);
            Map<String, Object> filters = reportService.resolveFilters(
                    period, rawStartDate, rawEndDate, null, yearStr
            );

            startDate = (String) filters.get("startDate");
            endDate = (String) filters.get("endDate");
            selectedPeriod = (String) filters.get("period");
            currentYear = (int) filters.get("currentYear");

            revenueStats = reportService.getRevenueAnalysisStats(startDate, endDate);
            revenueTrend = reportService.getRevenueTrend(startDate, endDate, groupBy, currentYear);
            revenueTable = reportService.filterRevenueTrend(revenueTrend, tableKeyword, tableSort);
            paymentBreakdown = reportService.getRevenuePaymentMethodBreakdown(startDate, endDate);
        } catch (IllegalArgumentException e) {
            request.setAttribute("reportFilterError", e.getMessage());
        }

        request.setAttribute("currentTab", "revenue");
        request.setAttribute("revenueStats", revenueStats);
        request.setAttribute("revenueTrend", revenueTrend);
        request.setAttribute("revenueTable", revenueTable);
        request.setAttribute("paymentBreakdown", paymentBreakdown);
        request.setAttribute("selectedPeriod", selectedPeriod);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("groupBy", groupBy);
        request.setAttribute("currentYear", currentYear);
        request.setAttribute("tableKeyword", valueOrEmpty(tableKeyword));
        request.setAttribute("tableSort", tableSort);

        request.getRequestDispatcher("/views/Manager/reportRevenue.jsp").forward(request, response);
    }

    private void handleProductsTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String period = request.getParameter("period");
        String rawStartDate = request.getParameter("startDate");
        String rawEndDate = request.getParameter("endDate");
        String keyword = request.getParameter("tableKeyword");
        String rawSort = request.getParameter("tableSort");

        int page = reportService.normalizePage(parseInt(request.getParameter("tablePage"), 1));
        int pageSize = reportService.normalizePageSize(parseInt(request.getParameter("tablePageSize"), 10));
        Integer categoryId = parsePositiveInteger(request.getParameter("tableCategoryId"));
        Integer brandId = parsePositiveInteger(request.getParameter("tableBrandId"));

        String startDate = valueOrEmpty(rawStartDate);
        String endDate = valueOrEmpty(rawEndDate);
        String sort = reportService.normalizeProductSort(rawSort);
        String selectedPeriod = valueOrDefault(period, "all");

        List<Map<String, Object>> productList = Collections.emptyList();
        Map<String, Object> summary = new HashMap<>();
        int totalItems = 0;
        int totalPages = 1;

        try {
            Map<String, Object> filters = reportService.resolveFilters(
                    period, rawStartDate, rawEndDate, null, null
            );
            startDate = (String) filters.get("startDate");
            endDate = (String) filters.get("endDate");
            selectedPeriod = (String) filters.get("period");

            totalItems = reportService.countProductPerformance(
                    startDate, endDate, categoryId, brandId, keyword
            );
            totalPages = reportService.getTotalPages(totalItems, pageSize);
            if (page > totalPages) {
                page = totalPages;
            }

            productList = reportService.getProductPerformanceList(
                    startDate, endDate, categoryId, brandId, keyword, sort, page, pageSize
            );
            summary = reportService.getProductPerformanceSummary(
                    startDate, endDate, null, null, ""
            );
        } catch (IllegalArgumentException e) {
            request.setAttribute("reportFilterError", e.getMessage());
            page = 1;
        }

        request.setAttribute("currentTab", "products");
        request.setAttribute("productList", productList);
        request.setAttribute("summary", summary);
        request.setAttribute("categories", reportService.getAllCategories());
        request.setAttribute("brands", reportService.getAllBrands());
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("selectedPeriod", selectedPeriod);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("tableCategoryId", categoryId);
        request.setAttribute("tableBrandId", brandId);
        request.setAttribute("tableKeyword", valueOrEmpty(keyword));
        request.setAttribute("tableSort", sort);

        request.getRequestDispatcher("/views/Manager/reportProducts.jsp").forward(request, response);
    }

    private void handleOrdersTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String period = request.getParameter("period");
        String rawStartDate = request.getParameter("startDate");
        String rawEndDate = request.getParameter("endDate");
        String rawStatus = request.getParameter("tableStatus");
        String rawPaymentMethod = request.getParameter("tablePaymentMethod");
        String keyword = request.getParameter("tableKeyword");
        String rawSort = request.getParameter("tableSort");

        int page = reportService.normalizePage(parseInt(request.getParameter("tablePage"), 1));
        int pageSize = reportService.normalizePageSize(parseInt(request.getParameter("tablePageSize"), 10));

        String startDate = valueOrEmpty(rawStartDate);
        String endDate = valueOrEmpty(rawEndDate);
        String status = valueOrDefault(rawStatus, "ALL").toUpperCase();
        String paymentMethod = valueOrDefault(rawPaymentMethod, "ALL").toUpperCase();
        String selectedPeriod = valueOrDefault(period, "all");
        String sort = reportService.normalizeOrderSort(rawSort);

        Map<String, Object> orderStats = new HashMap<>();
        List<Map<String, Object>> paymentStats = Collections.emptyList();
        List<Map<String, Object>> ordersList = Collections.emptyList();
        int totalOrders = 0;
        int totalPages = 1;

        try {
            status = reportService.normalizeOrderStatus(rawStatus);
            paymentMethod = reportService.normalizePaymentMethod(rawPaymentMethod);

            Map<String, Object> filters = reportService.resolveFilters(
                    period, rawStartDate, rawEndDate, status, null
            );
            startDate = (String) filters.get("startDate");
            endDate = (String) filters.get("endDate");
            selectedPeriod = (String) filters.get("period");
            status = (String) filters.get("status");

            totalOrders = reportService.countDetailedOrders(
                    startDate, endDate, status, paymentMethod, keyword
            );
            totalPages = reportService.getTotalPages(totalOrders, pageSize);
            if (page > totalPages) {
                page = totalPages;
            }

            orderStats = reportService.getOrderAnalysisStats(
                    startDate, endDate, "ALL", "ALL"
            );
            paymentStats = reportService.getOrderPaymentMethods(startDate, endDate);
            ordersList = reportService.getDetailedOrdersPaginated(
                    startDate, endDate, status, paymentMethod, keyword, sort, page, pageSize
            );
        } catch (IllegalArgumentException e) {
            request.setAttribute("reportFilterError", e.getMessage());
            page = 1;
        }

        request.setAttribute("currentTab", "orders");
        request.setAttribute("orderStats", orderStats);
        request.setAttribute("paymentStats", paymentStats);
        request.setAttribute("ordersList", ordersList);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("selectedPeriod", selectedPeriod);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("tableStatus", status);
        request.setAttribute("tablePaymentMethod", paymentMethod);
        request.setAttribute("tableKeyword", valueOrEmpty(keyword));
        request.setAttribute("tableSort", sort);

        request.getRequestDispatcher("/views/Manager/reportOrders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private int parseInt(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private Integer parsePositiveInteger(String value) {
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

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String valueOrDefault(String value, String defaultValue) {
        String normalized = valueOrEmpty(value);
        return normalized.isEmpty() ? defaultValue : normalized;
    }
}
