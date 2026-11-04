package com.swp391.controller.Manager;

import com.swp391.service.Manager.ReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
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

        String tab = request.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) {
            tab = "overview";
        } else {
            tab = tab.trim().toLowerCase();
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
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String status = request.getParameter("status");
        String yearStr = request.getParameter("year");

        Map<String, Object> filters = reportService.resolveFilters(
                period, startDate, endDate, status, yearStr
        );

        startDate = (String) filters.get("startDate");
        endDate = (String) filters.get("endDate");
        status = (String) filters.get("status");
        int currentYear = (int) filters.get("currentYear");

        Map<String, Object> overviewStats = reportService.getOverviewStats(startDate, endDate, status);
        List<Map<String, Object>> monthlyRevenue = reportService.getMonthlyRevenue(currentYear);
        Map<String, Object> statusDistribution = reportService.getOrderStatusDistribution(startDate, endDate);
        List<Map<String, Object>> topProducts = reportService.getTopSellingProducts(5, startDate, endDate);
        List<Map<String, Object>> categorySales = reportService.getCategorySales(startDate, endDate);
        List<Map<String, Object>> ordersReport = reportService.getOrdersReport(startDate, endDate, status);

        request.setAttribute("currentTab", "overview");
        request.setAttribute("overviewStats", overviewStats);
        request.setAttribute("monthlyRevenue", monthlyRevenue);
        request.setAttribute("statusDistribution", statusDistribution);
        request.setAttribute("topProducts", topProducts);
        request.setAttribute("categorySales", categorySales);
        request.setAttribute("ordersReport", ordersReport);

        request.setAttribute("selectedPeriod", period != null && !period.trim().isEmpty() ? period.trim() : "all");
        request.setAttribute("selectedStatus", status);
        request.setAttribute("startDate", startDate != null ? startDate : "");
        request.setAttribute("endDate", endDate != null ? endDate : "");
        request.setAttribute("currentYear", currentYear);

        request.getRequestDispatcher("/views/Manager/report.jsp").forward(request, response);
    }


    private void handleRevenueTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String period = request.getParameter("period");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String groupBy = request.getParameter("groupBy");
        String yearStr = request.getParameter("year");

        if (groupBy == null || groupBy.trim().isEmpty()) {
            groupBy = "month";
        } else {
            groupBy = groupBy.trim().toLowerCase();
        }

        Map<String, Object> filters = reportService.resolveFilters(
                period, startDate, endDate, null, yearStr
        );

        startDate = (String) filters.get("startDate");
        endDate = (String) filters.get("endDate");
        int currentYear = (int) filters.get("currentYear");

        Map<String, Object> revenueStats = reportService.getRevenueAnalysisStats(startDate, endDate);
        List<Map<String, Object>> revenueTrend = reportService.getRevenueTrend(startDate, endDate, groupBy, currentYear);
        List<Map<String, Object>> paymentBreakdown = reportService.getRevenuePaymentMethodBreakdown(startDate, endDate);

        request.setAttribute("currentTab", "revenue");
        request.setAttribute("revenueStats", revenueStats);
        request.setAttribute("revenueTrend", revenueTrend);
        request.setAttribute("paymentBreakdown", paymentBreakdown);

        request.setAttribute("selectedPeriod", period != null && !period.trim().isEmpty() ? period.trim() : "all");
        request.setAttribute("startDate", startDate != null ? startDate : "");
        request.setAttribute("endDate", endDate != null ? endDate : "");
        request.setAttribute("groupBy", groupBy);
        request.setAttribute("currentYear", currentYear);

        request.getRequestDispatcher("/views/Manager/reportRevenue.jsp").forward(request, response);
    }


    private void handleProductsTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String period = request.getParameter("period");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String categoryIdStr = request.getParameter("categoryId");
        String brandIdStr = request.getParameter("brandId");
        String keyword = request.getParameter("keyword");
        String sort = request.getParameter("sort");
        String pageStr = request.getParameter("page");
        String pageSizeStr = request.getParameter("pageSize");

        if (sort == null || sort.trim().isEmpty()) {
            sort = "revenue_desc";
        } else {
            sort = sort.trim().toLowerCase();
        }

        int page = parseInt(pageStr, 1);
        int pageSize = parseInt(pageSizeStr, 10);
        if (pageSize < 5) pageSize = 10;
        if (pageSize > 100) pageSize = 100;

        Integer categoryId = parseInteger(categoryIdStr);
        Integer brandId = parseInteger(brandIdStr);

        Map<String, Object> filters = reportService.resolveFilters(
                period, startDate, endDate, null, null
        );

        startDate = (String) filters.get("startDate");
        endDate = (String) filters.get("endDate");

        List<Map<String, Object>> productList = reportService.getProductPerformanceList(
                startDate, endDate, categoryId, brandId, keyword, sort, page, pageSize
        );
        int totalItems = reportService.countProductPerformance(
                startDate, endDate, categoryId, brandId, keyword
        );
        Map<String, Object> summary = reportService.getProductPerformanceSummary(
                startDate, endDate, categoryId, brandId, keyword
        );

        List<Map<String, Object>> categories = reportService.getAllCategories();
        List<Map<String, Object>> brands = reportService.getAllBrands();

        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        request.setAttribute("currentTab", "products");
        request.setAttribute("productList", productList);
        request.setAttribute("summary", summary);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);

        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        request.setAttribute("selectedPeriod", period != null && !period.trim().isEmpty() ? period.trim() : "all");
        request.setAttribute("startDate", startDate != null ? startDate : "");
        request.setAttribute("endDate", endDate != null ? endDate : "");
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("selectedBrand", brandId);
        request.setAttribute("keyword", keyword != null ? keyword.trim() : "");
        request.setAttribute("selectedSort", sort);

        request.getRequestDispatcher("/views/Manager/reportProducts.jsp").forward(request, response);
    }

    private void handleOrdersTab(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String period = request.getParameter("period");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String status = request.getParameter("status");
        String paymentMethod = request.getParameter("paymentMethod");
        String keyword = request.getParameter("keyword");
        String pageStr = request.getParameter("page");
        String pageSizeStr = request.getParameter("pageSize");

        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        } else {
            status = status.trim().toUpperCase();
        }

        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "ALL";
        } else {
            paymentMethod = paymentMethod.trim().toUpperCase();
        }

        int page = parseInt(pageStr, 1);
        int pageSize = parseInt(pageSizeStr, 10);
        if (pageSize < 5) pageSize = 10;
        if (pageSize > 100) pageSize = 100;

        Map<String, Object> filters = reportService.resolveFilters(
                period, startDate, endDate, status, null
        );

        startDate = (String) filters.get("startDate");
        endDate = (String) filters.get("endDate");

        Map<String, Object> orderStats = reportService.getOrderAnalysisStats(
                startDate, endDate, status, paymentMethod
        );
        List<Map<String, Object>> paymentStats = reportService.getOrderPaymentMethods(startDate, endDate);
        List<Map<String, Object>> ordersList = reportService.getDetailedOrdersPaginated(
                startDate, endDate, status, paymentMethod, keyword, page, pageSize
        );
        int totalOrders = reportService.countDetailedOrders(
                startDate, endDate, status, paymentMethod, keyword
        );

        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        request.setAttribute("currentTab", "orders");
        request.setAttribute("orderStats", orderStats);
        request.setAttribute("paymentStats", paymentStats);
        request.setAttribute("ordersList", ordersList);

        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);

        request.setAttribute("selectedPeriod", period != null && !period.trim().isEmpty() ? period.trim() : "all");
        request.setAttribute("startDate", startDate != null ? startDate : "");
        request.setAttribute("endDate", endDate != null ? endDate : "");
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedPaymentMethod", paymentMethod);
        request.setAttribute("keyword", keyword != null ? keyword.trim() : "");

        request.getRequestDispatcher("/views/Manager/reportOrders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private int parseInt(String str, int defaultValue) {
        if (str == null || str.trim().isEmpty()) return defaultValue;
        try {
            int val = Integer.parseInt(str.trim());
            return val > 0 ? val : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private Integer parseInteger(String str) {
        if (str == null || str.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(str.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
