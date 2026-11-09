package com.swp391.service.Manager;

import com.swp391.dao.Manager.ReportDAO;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class ReportService {

    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final int MAX_PAGE_SIZE = 100;
    private static final Set<String> ORDER_STATUSES = Set.of(
            "ALL", "PENDING", "CONFIRMED", "SHIPPING", "DELIVERED", "CANCELLED"
    );
    private static final Set<String> PAYMENT_METHODS = Set.of(
            "ALL", "COD", "VNPAY", "BANK_TRANSFER"
    );
    private static final Set<String> GROUP_BY_VALUES = Set.of("day", "month");
    private static final Set<String> PRODUCT_SORTS = Set.of(
            "revenue_desc", "revenue_asc",
            "units_desc", "units_asc",
            "orders_desc", "orders_asc",
            "name_asc", "name_desc",
            "id_desc", "id_asc"
    );
    private static final Set<String> ORDER_SORTS = Set.of(
            "date_desc", "date_asc", "amount_desc", "amount_asc", "id_desc", "id_asc"
    );
    private static final Set<String> REVENUE_SORTS = Set.of(
            "period_asc", "period_desc", "revenue_desc", "revenue_asc", "orders_desc", "orders_asc"
    );

    private final ReportDAO reportDAO;

    public ReportService() {
        this.reportDAO = new ReportDAO();
    }

    public Map<String, Object> resolveFilters(
            String period,
            String startDate,
            String endDate,
            String status,
            String yearStr) {

        Map<String, Object> filters = new HashMap<>();
        LocalDate today = LocalDate.now();
        int currentYear = normalizeYear(yearStr, today.getYear());
        String rawPeriod = normalizeText(period);
        String normalizedPeriod;
        if (rawPeriod.isEmpty()) {
            normalizedPeriod = normalizeText(startDate).isEmpty() && normalizeText(endDate).isEmpty()
                    ? "all"
                    : "custom";
        } else {
            normalizedPeriod = normalizePeriod(rawPeriod);
        }

        switch (normalizedPeriod) {
            case "today" -> {
                startDate = today.toString();
                endDate = today.toString();
            }
            case "last_7_days" -> {
                startDate = today.minusDays(6).toString();
                endDate = today.toString();
            }
            case "this_week" -> {
                startDate = today.with(DayOfWeek.MONDAY).toString();
                endDate = today.toString();
            }
            case "this_month" -> {
                startDate = today.with(TemporalAdjusters.firstDayOfMonth()).toString();
                endDate = today.toString();
            }
            case "this_year" -> {
                startDate = LocalDate.of(today.getYear(), 1, 1).toString();
                endDate = today.toString();
                currentYear = today.getYear();
            }
            case "last_30_days" -> {
                startDate = today.minusDays(29).toString();
                endDate = today.toString();
            }
            case "last_90_days" -> {
                startDate = today.minusDays(89).toString();
                endDate = today.toString();
            }
            case "all" -> {
                startDate = "";
                endDate = "";
            }
            case "custom" -> {
                // Keep the user-provided date range unchanged.
            }
            default -> {
            }
        }

        startDate = normalizeText(startDate);
        endDate = normalizeText(endDate);
        validateReportDateRange(startDate, endDate);

        filters.put("startDate", startDate);
        filters.put("endDate", endDate);
        filters.put("status", normalizeOrderStatus(status));
        filters.put("currentYear", currentYear);
        filters.put("period", normalizedPeriod);
        return filters;
    }

    public void validateReportDateRange(String startDate, String endDate) {
        LocalDate start = parseDate(startDate, "Start date");
        LocalDate end = parseDate(endDate, "End date");
        LocalDate today = LocalDate.now();

        if (start != null && start.isAfter(today)) {
            throw new IllegalArgumentException("Start date cannot be in the future.");
        }
        if (end != null && end.isAfter(today)) {
            throw new IllegalArgumentException("End date cannot be in the future.");
        }
        if (start != null && end != null && start.isAfter(end)) {
            throw new IllegalArgumentException("Start date cannot be after End date.");
        }
    }

    public String normalizeOrderStatus(String status) {
        String value = normalizeUpper(status, "ALL");
        if (!ORDER_STATUSES.contains(value)) {
            throw new IllegalArgumentException("Invalid order status filter.");
        }
        return value;
    }

    public String normalizePaymentMethod(String paymentMethod) {
        String value = normalizeUpper(paymentMethod, "ALL");
        if (!PAYMENT_METHODS.contains(value)) {
            throw new IllegalArgumentException("Invalid payment method filter.");
        }
        return value;
    }

    public String normalizeGroupBy(String groupBy) {
        String value = normalizeText(groupBy).toLowerCase();
        if (value.isEmpty()) {
            return "month";
        }
        if (!GROUP_BY_VALUES.contains(value)) {
            throw new IllegalArgumentException("Invalid revenue grouping option.");
        }
        return value;
    }

    public String normalizeProductSort(String sort) {
        String value = normalizeText(sort).toLowerCase();
        if (value.isEmpty()) {
            return "revenue_desc";
        }
        if (!PRODUCT_SORTS.contains(value)) {
            return "revenue_desc";
        }
        return value;
    }

    public String normalizeOrderSort(String sort) {
        String value = normalizeText(sort).toLowerCase();
        return ORDER_SORTS.contains(value) ? value : "date_desc";
    }

    public String normalizeRevenueSort(String sort) {
        String value = normalizeText(sort).toLowerCase();
        return REVENUE_SORTS.contains(value) ? value : "period_asc";
    }

    public String normalizeSearchKeyword(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return "";
        }
        return keyword.replaceAll("\\s+", "").trim().toLowerCase();
    }

    public Integer normalizePositiveId(Integer value) {
        return value != null && value > 0 ? value : null;
    }

    public int normalizePage(int page) {
        return Math.max(page, 1);
    }

    public int normalizePageSize(int pageSize) {
        if (pageSize <= 0) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(pageSize, MAX_PAGE_SIZE);
    }

    public int getTotalPages(int totalItems, int pageSize) {
        int normalizedPageSize = normalizePageSize(pageSize);
        return totalItems <= 0 ? 1 : (int) Math.ceil((double) totalItems / normalizedPageSize);
    }

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

    public Map<String, Object> getRevenueAnalysisStats(String startDate, String endDate) {
        return reportDAO.getRevenueAnalysisStats(startDate, endDate);
    }

    public List<Map<String, Object>> getRevenueTrend(String startDate, String endDate, String groupBy, int year) {
        return reportDAO.getRevenueTrend(startDate, endDate, groupBy, year);
    }

    public List<Map<String, Object>> getRevenuePaymentMethodBreakdown(String startDate, String endDate) {
        return reportDAO.getRevenuePaymentMethodBreakdown(startDate, endDate);
    }

    public List<Map<String, Object>> getProductPerformanceList(
            String startDate,
            String endDate,
            Integer categoryId,
            Integer brandId,
            String keyword,
            String sort,
            int page,
            int pageSize) {

        page = normalizePage(page);
        pageSize = normalizePageSize(pageSize);
        int offset = (page - 1) * pageSize;
        return reportDAO.getProductPerformanceList(
                startDate, endDate, normalizePositiveId(categoryId), normalizePositiveId(brandId),
                normalizeSearchKeyword(keyword), normalizeProductSort(sort), offset, pageSize
        );
    }

    public int countProductPerformance(
            String startDate,
            String endDate,
            Integer categoryId,
            Integer brandId,
            String keyword) {

        return reportDAO.countProductPerformance(
                startDate, endDate, normalizePositiveId(categoryId), normalizePositiveId(brandId), normalizeSearchKeyword(keyword)
        );
    }

    public Map<String, Object> getProductPerformanceSummary(
            String startDate,
            String endDate,
            Integer categoryId,
            Integer brandId,
            String keyword) {

        return reportDAO.getProductPerformanceSummary(
                startDate, endDate, normalizePositiveId(categoryId), normalizePositiveId(brandId), normalizeText(keyword)
        );
    }

    public List<Map<String, Object>> getAllCategories() {
        return reportDAO.getAllCategories();
    }

    public List<Map<String, Object>> getAllBrands() {
        return reportDAO.getAllBrands();
    }

    public Map<String, Object> getOrderAnalysisStats(
            String startDate,
            String endDate,
            String status,
            String paymentMethod) {

        return reportDAO.getOrderAnalysisStats(
                startDate, endDate, normalizeOrderStatus(status), normalizePaymentMethod(paymentMethod)
        );
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
            String sort,
            int page,
            int pageSize) {

        page = normalizePage(page);
        pageSize = normalizePageSize(pageSize);
        int offset = (page - 1) * pageSize;
        return reportDAO.getDetailedOrdersPaginated(
                startDate, endDate, normalizeOrderStatus(status), normalizePaymentMethod(paymentMethod),
                normalizeSearchKeyword(keyword), normalizeOrderSort(sort), offset, pageSize
        );
    }

    public int countDetailedOrders(
            String startDate,
            String endDate,
            String status,
            String paymentMethod,
            String keyword) {

        return reportDAO.countDetailedOrders(
                startDate, endDate, normalizeOrderStatus(status), normalizePaymentMethod(paymentMethod), normalizeSearchKeyword(keyword)
        );
    }

    public List<Map<String, Object>> filterRevenueTrend(
            List<Map<String, Object>> source, String keyword, String sort) {
        String normalizedKeyword = normalizeSearchKeyword(keyword);
        String normalizedSort = normalizeRevenueSort(sort);
        List<Map<String, Object>> result = new ArrayList<>();
        if (source != null) {
            for (Map<String, Object> row : source) {
                String label = String.valueOf(row.getOrDefault("periodLabel", ""))
                        .replaceAll("\\s+", "").toLowerCase();
                if (normalizedKeyword.isEmpty() || label.contains(normalizedKeyword)) {
                    result.add(row);
                }
            }
        }

        if ("period_desc".equals(normalizedSort)) {
            Collections.reverse(result);
        } else if (!"period_asc".equals(normalizedSort)) {
            Comparator<Map<String, Object>> comparator = switch (normalizedSort) {
                case "revenue_desc" -> Comparator.comparing(this::revenueValue).reversed();
                case "revenue_asc" -> Comparator.comparing(this::revenueValue);
                case "orders_desc" -> Comparator.comparingInt(this::orderCountValue).reversed();
                case "orders_asc" -> Comparator.comparingInt(this::orderCountValue);
                default -> Comparator.comparingInt(row -> 0);
            };
            result.sort(comparator);
        }
        return result;
    }

    private BigDecimal revenueValue(Map<String, Object> row) {
        Object value = row.get("revenue");
        if (value instanceof BigDecimal) {
            return (BigDecimal) value;
        }
        if (value instanceof Number) {
            return BigDecimal.valueOf(((Number) value).doubleValue());
        }
        return BigDecimal.ZERO;
    }

    private int orderCountValue(Map<String, Object> row) {
        Object value = row.get("ordersCount");
        return value instanceof Number ? ((Number) value).intValue() : 0;
    }

    private String normalizePeriod(String period) {
        String value = normalizeText(period).toLowerCase();
        if (value.isEmpty()) {
            return "all";
        }
        return switch (value) {
            case "all", "custom", "today", "last_7_days", "this_week", "this_month", "this_year", "last_30_days", "last_90_days" -> value;
            default -> "all";
        };
    }

    private int normalizeYear(String yearStr, int fallback) {
        String value = normalizeText(yearStr);
        if (value.isEmpty()) {
            return fallback;
        }
        try {
            int year = Integer.parseInt(value);
            int currentYear = LocalDate.now().getYear();
            return year >= 2000 && year <= currentYear ? year : fallback;
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private LocalDate parseDate(String value, String fieldName) {
        String normalized = normalizeText(value);
        if (normalized.isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(normalized);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException(fieldName + " is invalid.");
        }
    }

    private String normalizeText(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeUpper(String value, String fallback) {
        String normalized = normalizeText(value);
        return normalized.isEmpty() ? fallback : normalized.toUpperCase();
    }
}
