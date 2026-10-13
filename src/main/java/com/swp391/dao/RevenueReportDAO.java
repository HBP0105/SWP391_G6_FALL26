package com.swp391.dao;

import com.swp391.util.DBContext;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Pure Data Access Object (DAO) for Admin Revenue Reporting (Screen 3).
 * Uses ONLY standard Java Map/List collection structures without any custom models.
 */
public class RevenueReportDAO {

    private static final Logger LOGGER = Logger.getLogger(RevenueReportDAO.class.getName());
    private final DBContext dbContext;

    public RevenueReportDAO() {
        this.dbContext = new DBContext();
    }

    private void applyDateConditions(StringBuilder sql, List<Object> params, 
            String formattedStartDate, String formattedEndDate, String dateColumn) {
        if (formattedStartDate != null && !formattedStartDate.trim().isEmpty()) {
            sql.append(" AND ").append(dateColumn).append(" >= ?");
            params.add(formattedStartDate);
        }
        if (formattedEndDate != null && !formattedEndDate.trim().isEmpty()) {
            if (formattedEndDate.endsWith(" 00:00:00")) {
                sql.append(" AND ").append(dateColumn).append(" < ?");
            } else {
                sql.append(" AND ").append(dateColumn).append(" <= ?");
            }
            params.add(formattedEndDate);
        }
    }

    /**
     * Fetch overall revenue summary stats into a Map (Total Revenue, Total Orders, Delivered Orders, Cancelled Orders, AOV, Completion Rate).
     */
    public Map<String, Object> getRevenueSummary(String formattedStartDate, String formattedEndDate) {
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalRevenue", BigDecimal.ZERO);
        summary.put("totalOrders", 0);
        summary.put("deliveredOrders", 0);
        summary.put("cancelledOrders", 0);
        summary.put("avgOrderValue", BigDecimal.ZERO);
        summary.put("completionRate", 0.0);

        StringBuilder sql = new StringBuilder("""
                SELECT 
                    SUM(CASE WHEN UPPER(OrderStatus) = 'DELIVERED' THEN TotalAmount ELSE 0 END) AS TotalRevenue,
                    COUNT(OrderID) AS TotalOrders,
                    SUM(CASE WHEN UPPER(OrderStatus) = 'DELIVERED' THEN 1 ELSE 0 END) AS DeliveredOrders,
                    SUM(CASE WHEN UPPER(OrderStatus) = 'CANCELLED' THEN 1 ELSE 0 END) AS CancelledOrders
                FROM Orders
                WHERE 1=1
                """);

        List<Object> params = new ArrayList<>();
        applyDateConditions(sql, params, formattedStartDate, formattedEndDate, "OrderDate");

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal totalRev = rs.getBigDecimal("TotalRevenue") != null ? rs.getBigDecimal("TotalRevenue") : BigDecimal.ZERO;
                    int totalOrd = rs.getInt("TotalOrders");
                    int deliveredOrd = rs.getInt("DeliveredOrders");
                    int cancelledOrd = rs.getInt("CancelledOrders");

                    summary.put("totalRevenue", totalRev);
                    summary.put("totalOrders", totalOrd);
                    summary.put("deliveredOrders", deliveredOrd);
                    summary.put("cancelledOrders", cancelledOrd);

                    if (deliveredOrd > 0 && totalRev.compareTo(BigDecimal.ZERO) > 0) {
                        BigDecimal avg = totalRev.divide(new BigDecimal(deliveredOrd), 2, RoundingMode.HALF_UP);
                        summary.put("avgOrderValue", avg);
                    }

                    if (totalOrd > 0) {
                        double rate = (double) deliveredOrd / totalOrd * 100.0;
                        summary.put("completionRate", Math.round(rate * 10.0) / 10.0);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getRevenueSummary", e);
        }

        return summary;
    }

    /**
     * Fetch revenue trend grouped by Date or Month into a List of Maps for Chart.js.
     * @param groupBy "daily" or "monthly"
     */
    public List<Map<String, Object>> getRevenueTrend(String formattedStartDate, String formattedEndDate, String groupBy) {
        List<Map<String, Object>> trendList = new ArrayList<>();

        boolean isMonthly = "monthly".equalsIgnoreCase(groupBy);
        String dateFormatStr = isMonthly ? "yyyy-MM" : "yyyy-MM-dd";

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT FORMAT(OrderDate, '").append(dateFormatStr).append("') AS PeriodLabel, ")
           .append("SUM(TotalAmount) AS Revenue, COUNT(OrderID) AS OrderCount ")
           .append("FROM Orders ")
           .append("WHERE UPPER(OrderStatus) = 'DELIVERED' ");

        List<Object> params = new ArrayList<>();
        applyDateConditions(sql, params, formattedStartDate, formattedEndDate, "OrderDate");

        sql.append(" GROUP BY FORMAT(OrderDate, '").append(dateFormatStr).append("') ")
           .append(" ORDER BY PeriodLabel ASC");

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("periodLabel", rs.getString("PeriodLabel"));
                    map.put("revenue", rs.getBigDecimal("Revenue") != null ? rs.getBigDecimal("Revenue") : BigDecimal.ZERO);
                    map.put("orderCount", rs.getInt("OrderCount"));
                    trendList.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getRevenueTrend", e);
        }

        return trendList;
    }

    /**
     * Fetch top selling products into a List of Maps.
     */
    public List<Map<String, Object>> getTopSellingProducts(String formattedStartDate, String formattedEndDate, int limit) {
        List<Map<String, Object>> topProducts = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
                SELECT TOP (?) p.ProductID, p.ProductName, COALESCE(c.CategoryName, 'General') AS CategoryName,
                       SUM(oi.Quantity) AS TotalQty, SUM(oi.Quantity * oi.UnitPrice) AS TotalRev
                FROM OrderItems oi
                JOIN Orders o ON oi.OrderID = o.OrderID
                JOIN Products p ON oi.ProductID = p.ProductID
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                WHERE UPPER(o.OrderStatus) = 'DELIVERED'
                """);

        List<Object> params = new ArrayList<>();
        params.add(limit > 0 ? limit : 5);

        applyDateConditions(sql, params, formattedStartDate, formattedEndDate, "o.OrderDate");

        sql.append("""
                GROUP BY p.ProductID, p.ProductName, c.CategoryName
                ORDER BY TotalRev DESC
                """);

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("productID", rs.getInt("ProductID"));
                    map.put("productName", rs.getString("ProductName"));
                    map.put("categoryName", rs.getString("CategoryName"));
                    map.put("totalQuantitySold", rs.getInt("TotalQty"));
                    map.put("totalRevenue", rs.getBigDecimal("TotalRev") != null ? rs.getBigDecimal("TotalRev") : BigDecimal.ZERO);
                    topProducts.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getTopSellingProducts", e);
        }

        return topProducts;
    }

    /**
     * Fetch revenue breakdown by product category into a List of Maps.
     */
    public List<Map<String, Object>> getRevenueByCategory(String formattedStartDate, String formattedEndDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
                SELECT c.CategoryID, COALESCE(c.CategoryName, 'Uncategorized') AS CategoryName,
                       COUNT(DISTINCT o.OrderID) AS OrderCount,
                       SUM(oi.Quantity * oi.UnitPrice) AS TotalRev
                FROM OrderItems oi
                JOIN Orders o ON oi.OrderID = o.OrderID
                JOIN Products p ON oi.ProductID = p.ProductID
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                WHERE UPPER(o.OrderStatus) = 'DELIVERED'
                """);

        List<Object> params = new ArrayList<>();
        applyDateConditions(sql, params, formattedStartDate, formattedEndDate, "o.OrderDate");

        sql.append("""
                GROUP BY c.CategoryID, c.CategoryName
                ORDER BY TotalRev DESC
                """);

        BigDecimal grandTotal = BigDecimal.ZERO;

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("categoryID", rs.getInt("CategoryID"));
                    map.put("categoryName", rs.getString("CategoryName"));
                    map.put("orderCount", rs.getInt("OrderCount"));
                    BigDecimal rev = rs.getBigDecimal("TotalRev") != null ? rs.getBigDecimal("TotalRev") : BigDecimal.ZERO;
                    map.put("totalRevenue", rev);
                    grandTotal = grandTotal.add(rev);
                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getRevenueByCategory", e);
        }

        // Calculate percentage for each category
        if (grandTotal.compareTo(BigDecimal.ZERO) > 0) {
            for (Map<String, Object> map : list) {
                BigDecimal rev = (BigDecimal) map.get("totalRevenue");
                double pct = rev.multiply(new BigDecimal(100))
                        .divide(grandTotal, 2, RoundingMode.HALF_UP).doubleValue();
                map.put("percentage", pct);
            }
        } else {
            for (Map<String, Object> map : list) {
                map.put("percentage", 0.0);
            }
        }

        return list;
    }

    /**
     * Fetch revenue breakdown by payment method (COD, VNPAY, BANK_TRANSFER).
     */
    public Map<String, BigDecimal> getRevenueByPaymentMethod(String formattedStartDate, String formattedEndDate) {
        Map<String, BigDecimal> map = new HashMap<>();

        StringBuilder sql = new StringBuilder("""
                SELECT ISNULL(p.PaymentMethod, 'COD') AS Method, SUM(o.TotalAmount) AS TotalRev
                FROM Orders o
                LEFT JOIN Payments p ON o.OrderID = p.OrderID
                WHERE UPPER(o.OrderStatus) = 'DELIVERED'
                """);

        List<Object> params = new ArrayList<>();
        applyDateConditions(sql, params, formattedStartDate, formattedEndDate, "o.OrderDate");

        sql.append(" GROUP BY ISNULL(p.PaymentMethod, 'COD')");

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String method = rs.getString("Method");
                    BigDecimal rev = rs.getBigDecimal("TotalRev") != null ? rs.getBigDecimal("TotalRev") : BigDecimal.ZERO;
                    map.put(method != null ? method : "COD", rev);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getRevenueByPaymentMethod", e);
        }

        return map;
    }
}
