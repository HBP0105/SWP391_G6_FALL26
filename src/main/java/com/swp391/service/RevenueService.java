package com.swp391.service;

import com.swp391.dao.RevenueReportDAO;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Business Service handling all operations for Admin Revenue Reporting (Screen 3).
 * Performs date sanitization, metric aggregation, trend formatting, and CSV report generation.
 * Uses ONLY standard Java Map/List data structures without any custom models.
 */
public class RevenueService {

    private final RevenueReportDAO revenueReportDAO;

    public RevenueService() {
        this.revenueReportDAO = new RevenueReportDAO();
    }

    public RevenueService(RevenueReportDAO revenueReportDAO) {
        this.revenueReportDAO = revenueReportDAO;
    }

    private String formatStartDate(String startDate) {
        if (startDate == null || startDate.trim().isEmpty()) {
            return null;
        }
        return startDate.trim() + " 00:00:00";
    }

    private String formatEndDate(String endDate) {
        if (endDate == null || endDate.trim().isEmpty()) {
            return null;
        }
        try {
            LocalDate endLocalDate = LocalDate.parse(endDate.trim());
            LocalDate nextDay = endLocalDate.plusDays(1);
            return nextDay.toString() + " 00:00:00";
        } catch (Exception e) {
            return endDate.trim() + " 23:59:59";
        }
    }

    public String validateDateRange(String startDate, String endDate) {
        LocalDate today = LocalDate.now();
        if (startDate != null && !startDate.trim().isEmpty()) {
            try {
                LocalDate start = LocalDate.parse(startDate.trim());
                if (start.isAfter(today)) {
                    return "\"From Date\" cannot be in the future!";
                }
            } catch (Exception e) {
                return "Invalid \"From Date\" format!";
            }
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            try {
                LocalDate end = LocalDate.parse(endDate.trim());
                if (end.isAfter(today)) {
                    return "\"To Date\" cannot be in the future!";
                }
            } catch (Exception e) {
                return "Invalid \"To Date\" format!";
            }
        }
        if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
            try {
                LocalDate start = LocalDate.parse(startDate.trim());
                LocalDate end = LocalDate.parse(endDate.trim());
                if (start.isAfter(end)) {
                    return "\"From Date\" cannot be later than \"To Date\"!";
                }
            } catch (Exception e) {
                return "Invalid date range!";
            }
        }
        return null;
    }

    /**
     * Bundle all revenue metrics, trend charts, top products, and category stats for Screen 3 View.
     */
    public Map<String, Object> getRevenueReportBundle(String startDate, String endDate, String groupBy) {
        Map<String, Object> bundle = new HashMap<>();

        String msgError = validateDateRange(startDate, endDate);
        String startForQuery = startDate;
        String endForQuery = endDate;
        if (msgError != null) {
            bundle.put("msgError", msgError);
            startForQuery = "";
            endForQuery = "";
        }

        String formattedStart = formatStartDate(startForQuery);
        String formattedEnd = formatEndDate(endForQuery);

        String activeGroupBy = ("monthly".equalsIgnoreCase(groupBy)) ? "monthly" : "daily";

        // 1. Overall Summary Map
        Map<String, Object> summary = revenueReportDAO.getRevenueSummary(formattedStart, formattedEnd);

        // 2. Revenue Trend Chart Data List
        List<Map<String, Object>> trend = revenueReportDAO.getRevenueTrend(formattedStart, formattedEnd, activeGroupBy);

        // 3. Top Selling Products List
        List<Map<String, Object>> topProducts = revenueReportDAO.getTopSellingProducts(formattedStart, formattedEnd, 5);

        // 4. Revenue By Category List
        List<Map<String, Object>> categories = revenueReportDAO.getRevenueByCategory(formattedStart, formattedEnd);

        // 5. Revenue By Payment Method Map
        Map<String, BigDecimal> paymentMethods = revenueReportDAO.getRevenueByPaymentMethod(formattedStart, formattedEnd);

        bundle.put("summary", summary);
        bundle.put("trend", trend);
        bundle.put("topProducts", topProducts);
        bundle.put("categories", categories);
        bundle.put("paymentMethods", paymentMethods);
        bundle.put("selectedStartDate", startDate != null ? startDate : "");
        bundle.put("selectedEndDate", endDate != null ? endDate : "");
        bundle.put("selectedGroupBy", activeGroupBy);

        return bundle;
    }

    /**
     * Generate CSV Report for Revenue Export.
     */
    public String generateCSVRevenueReport(String startDate, String endDate, String groupBy) {
        Map<String, Object> bundle = getRevenueReportBundle(startDate, endDate, groupBy);

        @SuppressWarnings("unchecked")
        Map<String, Object> summary = (Map<String, Object>) bundle.get("summary");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> topProducts = (List<Map<String, Object>>) bundle.get("topProducts");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> categories = (List<Map<String, Object>>) bundle.get("categories");

        DecimalFormat formatter = new DecimalFormat("#,###");
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setGroupingSeparator('.');
        formatter.setDecimalFormatSymbols(symbols);

        BigDecimal totalRevenue = (BigDecimal) summary.getOrDefault("totalRevenue", BigDecimal.ZERO);
        BigDecimal avgOrderValue = (BigDecimal) summary.getOrDefault("avgOrderValue", BigDecimal.ZERO);

        StringBuilder sb = new StringBuilder();
        sb.append('\uFEFF'); // UTF-8 BOM for Excel compatibility

        sb.append("\"ADMIN REVENUE REPORT - HEADPHONE STORE\"\n");
        sb.append("\"Report Date:\",\"").append(LocalDate.now()).append("\"\n\n");

        sb.append("\"--- OVERALL METRICS ---\"\n");
        sb.append("\"Total Revenue (VND)\",\"").append(formatter.format(totalRevenue)).append("\"\n");
        sb.append("\"Total Orders\",\"").append(summary.get("totalOrders")).append("\"\n");
        sb.append("\"Delivered Orders\",\"").append(summary.get("deliveredOrders")).append("\"\n");
        sb.append("\"Cancelled Orders\",\"").append(summary.get("cancelledOrders")).append("\"\n");
        sb.append("\"Average Order Value (VND)\",\"").append(formatter.format(avgOrderValue)).append("\"\n");
        sb.append("\"Completion Rate\",\"").append(summary.get("completionRate")).append("%\"\n\n");

        sb.append("\"--- REVENUE BY CATEGORY ---\"\n");
        sb.append("\"Category ID\",\"Category Name\",\"Order Count\",\"Total Revenue (VND)\",\"Percentage\"\n");
        for (Map<String, Object> cat : categories) {
            BigDecimal catRev = (BigDecimal) cat.getOrDefault("totalRevenue", BigDecimal.ZERO);
            sb.append("\"").append(cat.get("categoryID")).append("\",");
            sb.append("\"").append(escapeCSV((String) cat.get("categoryName"))).append("\",");
            sb.append("\"").append(cat.get("orderCount")).append("\",");
            sb.append("\"").append(formatter.format(catRev)).append("\",");
            sb.append("\"").append(cat.get("percentage")).append("%\"\n");
        }
        sb.append("\n");

        sb.append("\"--- TOP SELLING PRODUCTS ---\"\n");
        sb.append("\"Product ID\",\"Product Name\",\"Category\",\"Quantity Sold\",\"Total Revenue (VND)\"\n");
        for (Map<String, Object> p : topProducts) {
            BigDecimal prodRev = (BigDecimal) p.getOrDefault("totalRevenue", BigDecimal.ZERO);
            sb.append("\"").append(p.get("productID")).append("\",");
            sb.append("\"").append(escapeCSV((String) p.get("productName"))).append("\",");
            sb.append("\"").append(escapeCSV((String) p.get("categoryName"))).append("\",");
            sb.append("\"").append(p.get("totalQuantitySold")).append("\",");
            sb.append("\"").append(formatter.format(prodRev)).append("\"\n");
        }

        return sb.toString();
    }

    private String escapeCSV(String value) {
        if (value == null) return "";
        String clean = value.replace("\"", "\"\"");
        if (clean.startsWith("=") || clean.startsWith("+") || clean.startsWith("-") 
                || clean.startsWith("@") || clean.startsWith("\t") || clean.startsWith("\r")) {
            clean = "'" + clean;
        }
        return clean;
    }
}
