package com.swp391.service.Manager;

import com.swp391.dao.Manager.ReportDAO;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service layer for Reports.
 * Handles date resolution and business logic for:
 * 1. Overview
 * 2. Revenue Analysis
 * 3. Product Performance
 * 4. Order Analysis
 */
public class ReportService {

    private final ReportDAO reportDAO;

    public ReportService() {
        this.reportDAO = new ReportDAO();
    }

    /**
     * Resolves period shortcuts into concrete start/end date strings.
     */
    public Map<String, Object> resolveFilters(
            String period,
            String startDate,
            String endDate,
            String status,
            String yearStr) {

        Map<String, Object> filters = new HashMap<>();

        LocalDate today = LocalDate.now();
        int currentYear = today.getYear();

        if (yearStr != null && !yearStr.trim().isEmpty()) {
            try {
                currentYear = Integer.parseInt(yearStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        if (period != null && !period.trim().isEmpty()) {
            switch (period.toLowerCase().trim()) {
                case "today":
                    startDate = today.toString();
                    endDate = today.toString();
                    break;
                case "last_7_days":
                    startDate = today.minusDays(7).toString();
                    endDate = today.toString();
                    break;
                case "this_week":
                    startDate = today.with(DayOfWeek.MONDAY).toString();
                    endDate = today.with(DayOfWeek.SUNDAY).toString();
                    break;
                case "this_month":
                    startDate = today.with(TemporalAdjusters.firstDayOfMonth()).toString();
                    endDate = today.with(TemporalAdjusters.lastDayOfMonth()).toString();
                    break;
                case "this_year":
                    startDate = LocalDate.of(currentYear, 1, 1).toString();
                    endDate = LocalDate.of(currentYear, 12, 31).toString();
                    break;
                case "last_30_days":
                    startDate = today.minusDays(30).toString();
                    endDate = today.toString();
                    break;
                case "last_90_days":
                    startDate = today.minusDays(90).toString();
                    endDate = today.toString();
                    break;
                case "all":
                    startDate = "";
                    endDate = "";
                    break;
                default:
                    break;
            }
        }

        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }

        filters.put("startDate", startDate != null ? startDate.trim() : "");
        filters.put("endDate", endDate != null ? endDate.trim() : "");
        filters.put("status", status.trim());
        filters.put("currentYear", currentYear);
        filters.put("period", period != null ? period.trim() : "all");

        return filters;
    }

    // ==========================================
    // 1. OVERVIEW METHODS
    // ==========================================

    public Map<String, Object> getOverviewStats(String startDate, String endDate, String status) {
        return reportDAO.getOverviewStats(startDate, endDate, status);
    }

    public List<Map<String, Object>> getMonthlyRevenue(int year) {
        return reportDAO.getMonthlyRevenue(year);
    }

    public Map<String, Object> getOrderStatusDistribution(String startDate, String endDate) {
        return reportDAO.getOrderStatusDistribution(startDate, endDate);
    }

    public List<Map<String, Object>> getTopSellingProducts(int limit, String startDate, String endDate) {
        return reportDAO.getTopSellingProducts(limit, startDate, endDate);
    }

    public List<Map<String, Object>> getCategorySales(String startDate, String endDate) {
        return reportDAO.getCategorySales(startDate, endDate);
    }

    public List<Map<String, Object>> getOrdersReport(String startDate, String endDate, String status) {
        return reportDAO.getOrdersReport(startDate, endDate, status);
    }

    // ==========================================
    // 2. REVENUE ANALYSIS METHODS
    // ==========================================

    public Map<String, Object> getRevenueAnalysisStats(String startDate, String endDate) {
        return reportDAO.getRevenueAnalysisStats(startDate, endDate);
    }

    public List<Map<String, Object>> getRevenueTrend(String startDate, String endDate, String groupBy, int year) {
        return reportDAO.getRevenueTrend(startDate, endDate, groupBy, year);
    }

    public List<Map<String, Object>> getRevenuePaymentMethodBreakdown(String startDate, String endDate) {
        return reportDAO.getRevenuePaymentMethodBreakdown(startDate, endDate);
    }

    // ==========================================
    // 3. PRODUCT PERFORMANCE METHODS
    // ==========================================

    public List<Map<String, Object>> getProductPerformanceList(
            String startDate,
            String endDate,
            Integer categoryId,
            Integer brandId,
            String keyword,
            String sort,
            int page,
            int pageSize) {

        int offset = Math.max(0, (page - 1) * pageSize);
        return reportDAO.getProductPerformanceList(
                startDate, endDate, categoryId, brandId, keyword, sort, offset, pageSize
        );
    }

    public int countProductPerformance(
            String startDate,
            String endDate,
            Integer categoryId,
            Integer brandId,
            String keyword) {

        return reportDAO.countProductPerformance(startDate, endDate, categoryId, brandId, keyword);
    }

    public Map<String, Object> getProductPerformanceSummary(
            String startDate,
            String endDate,
            Integer categoryId,
            Integer brandId,
            String keyword) {

        return reportDAO.getProductPerformanceSummary(startDate, endDate, categoryId, brandId, keyword);
    }

    public List<Map<String, Object>> getAllCategories() {
        return reportDAO.getAllCategories();
    }

    public List<Map<String, Object>> getAllBrands() {
        return reportDAO.getAllBrands();
    }

    // ==========================================
    // 4. ORDER ANALYSIS METHODS
    // ==========================================

    public Map<String, Object> getOrderAnalysisStats(
            String startDate,
            String endDate,
            String status,
            String paymentMethod) {

        return reportDAO.getOrderAnalysisStats(startDate, endDate, status, paymentMethod);
    }

    public List<Map<String, Object>> getOrderPaymentMethods(String startDate, String endDate) {
        return reportDAO.getOrderPaymentMethods(startDate, endDate);
    }

    public List<Map<String, Object>> getDetailedOrdersPaginated(
            String startDate,
            String endDate,
            String status,
            String paymentMethod,
            String keyword,
            int page,
            int pageSize) {

        int offset = Math.max(0, (page - 1) * pageSize);
        return reportDAO.getDetailedOrdersPaginated(
                startDate, endDate, status, paymentMethod, keyword, offset, pageSize
        );
    }

    public int countDetailedOrders(
            String startDate,
            String endDate,
            String status,
            String paymentMethod,
            String keyword) {

        return reportDAO.countDetailedOrders(startDate, endDate, status, paymentMethod, keyword);
    }
}
