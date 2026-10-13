package com.swp391.service;

import com.swp391.dao.Manager.ReportDAO;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service layer for Reports.
 * Contains date-period resolution business logic and
 * delegates data retrieval to ReportDAO.
 */
public class ReportService {

    private final ReportDAO reportDAO;

    public ReportService() {
        this.reportDAO = new ReportDAO();
    }

    /**
     * Resolves period shortcuts (today, this_week, etc.) into concrete
     * start/end date strings. Returns a map with keys:
     * "startDate", "endDate", "status", "currentYear".
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
            switch (period.toLowerCase()) {
                case "today":
                    startDate = today.toString();
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

        filters.put("startDate", startDate);
        filters.put("endDate", endDate);
        filters.put("status", status);
        filters.put("currentYear", currentYear);

        return filters;
    }

    public Map<String, Object> getOverviewStats(
            String startDate, String endDate, String status) {
        return reportDAO.getOverviewStats(startDate, endDate, status);
    }

    public List<Map<String, Object>> getMonthlyRevenue(int year) {
        return reportDAO.getMonthlyRevenue(year);
    }

    public Map<String, Object> getOrderStatusDistribution(
            String startDate, String endDate) {
        return reportDAO.getOrderStatusDistribution(startDate, endDate);
    }

    public List<Map<String, Object>> getTopSellingProducts(
            int limit, String startDate, String endDate) {
        return reportDAO.getTopSellingProducts(limit, startDate, endDate);
    }

    public List<Map<String, Object>> getCategorySales(
            String startDate, String endDate) {
        return reportDAO.getCategorySales(startDate, endDate);
    }

    public List<Map<String, Object>> getOrdersReport(
            String startDate, String endDate, String status) {
        return reportDAO.getOrdersReport(startDate, endDate, status);
    }
}
