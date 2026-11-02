package com.swp391.dao;

import com.swp391.util.DBContext;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Pure Data Access Object (DAO) for Admin Revenue Reporting (Screen 3).
 * Uses ONLY standard Java Map/List collection structures without any custom models.
 * Clean SQL Text Blocks without string concatenations, aligned with Screen 1 & 2.
 */
public class RevenueReportDAO {

    private static final Logger LOGGER = Logger.getLogger(RevenueReportDAO.class.getName());
    private final DBContext dbContext;

    public RevenueReportDAO() {
        this.dbContext = new DBContext();
    }

    /**
     * Binds nullable start and end dates to a PreparedStatement in the (? IS NULL OR col >= ?) pattern.
     */
    private void setDateParameters(PreparedStatement ps, int startIndex, String startDate, String endDate) throws SQLException {
        ps.setString(startIndex, startDate);
        ps.setString(startIndex + 1, startDate);
        ps.setString(startIndex + 2, endDate);
        ps.setString(startIndex + 3, endDate);
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

        String sql = """
                SELECT 
                    SUM(CASE WHEN OrderStatus = 'DELIVERED' THEN TotalAmount ELSE 0 END) AS TotalRevenue,
                    COUNT(OrderID) AS TotalOrders,
                    SUM(CASE WHEN OrderStatus = 'DELIVERED' THEN 1 ELSE 0 END) AS DeliveredOrders,
                    SUM(CASE WHEN OrderStatus = 'CANCELLED' THEN 1 ELSE 0 END) AS CancelledOrders
                FROM Orders
                WHERE (? IS NULL OR OrderDate >= ?)
                  AND (? IS NULL OR OrderDate < ?)
                """;

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            setDateParameters(ps, 1, formattedStartDate, formattedEndDate);

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
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getRevenueSummary", e);
            throw new RuntimeException("Lỗi truy vấn dữ liệu tổng quan doanh thu từ cơ sở dữ liệu!", e);
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

        String sql = isMonthly
                ? """
                  SELECT FORMAT(OrderDate, 'MM/yyyy') AS PeriodLabel,
                         SUM(TotalAmount) AS Revenue,
                         COUNT(OrderID) AS OrderCount
                  FROM Orders
                  WHERE OrderStatus = 'DELIVERED'
                    AND (? IS NULL OR OrderDate >= ?)
                    AND (? IS NULL OR OrderDate < ?)
                  GROUP BY FORMAT(OrderDate, 'MM/yyyy')
                  ORDER BY MIN(OrderDate) ASC
                  """
                : """
                  SELECT FORMAT(OrderDate, 'dd/MM/yyyy') AS PeriodLabel,
                         SUM(TotalAmount) AS Revenue,
                         COUNT(OrderID) AS OrderCount
                  FROM Orders
                  WHERE OrderStatus = 'DELIVERED'
                    AND (? IS NULL OR OrderDate >= ?)
                    AND (? IS NULL OR OrderDate < ?)
                  GROUP BY FORMAT(OrderDate, 'dd/MM/yyyy')
                  ORDER BY MIN(OrderDate) ASC
                  """;

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            setDateParameters(ps, 1, formattedStartDate, formattedEndDate);

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
            throw new RuntimeException("Lỗi truy vấn xu hướng doanh thu từ cơ sở dữ liệu!", e);
        }

        return trendList;
    }

    /**
     * Fetch top 5 selling products into a List of Maps.
     */
    public List<Map<String, Object>> getTopSellingProducts(String formattedStartDate, String formattedEndDate) {
        List<Map<String, Object>> topProducts = new ArrayList<>();

        String sql = """
                SELECT TOP (5) p.ProductID, p.ProductName, c.CategoryName,
                       SUM(oi.Quantity) AS TotalQty,
                       SUM(oi.Quantity * oi.UnitPrice) AS TotalRev
                FROM OrderItems oi
                JOIN Orders o ON oi.OrderID = o.OrderID
                JOIN Products p ON oi.ProductID = p.ProductID
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                WHERE o.OrderStatus = 'DELIVERED'
                  AND (? IS NULL OR o.OrderDate >= ?)
                  AND (? IS NULL OR o.OrderDate < ?)
                GROUP BY p.ProductID, p.ProductName, c.CategoryName
                ORDER BY TotalQty DESC, TotalRev DESC
                """;

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            setDateParameters(ps, 1, formattedStartDate, formattedEndDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("productID", rs.getInt("ProductID"));
                    map.put("productName", rs.getString("ProductName"));
                    String catName = rs.getString("CategoryName");
                    map.put("categoryName", catName != null ? catName : "General");
                    map.put("totalQuantitySold", rs.getInt("TotalQty"));
                    map.put("totalRevenue", rs.getBigDecimal("TotalRev") != null ? rs.getBigDecimal("TotalRev") : BigDecimal.ZERO);
                    topProducts.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getTopSellingProducts", e);
            throw new RuntimeException("Lỗi truy vấn danh sách sản phẩm bán chạy từ cơ sở dữ liệu!", e);
        }

        return topProducts;
    }

    /**
     * Fetch revenue breakdown by product category into a List of Maps.
     */
    public List<Map<String, Object>> getRevenueByCategory(String formattedStartDate, String formattedEndDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
                SELECT c.CategoryID, c.CategoryName,
                       COUNT(DISTINCT o.OrderID) AS OrderCount,
                       SUM(oi.Quantity * oi.UnitPrice) AS TotalRev
                FROM OrderItems oi
                JOIN Orders o ON oi.OrderID = o.OrderID
                JOIN Products p ON oi.ProductID = p.ProductID
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                WHERE o.OrderStatus = 'DELIVERED'
                  AND (? IS NULL OR o.OrderDate >= ?)
                  AND (? IS NULL OR o.OrderDate < ?)
                GROUP BY c.CategoryID, c.CategoryName
                ORDER BY TotalRev DESC
                """;

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            setDateParameters(ps, 1, formattedStartDate, formattedEndDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("categoryID", rs.getInt("CategoryID"));
                    String catName = rs.getString("CategoryName");
                    map.put("categoryName", catName != null ? catName : "Uncategorized");
                    map.put("orderCount", rs.getInt("OrderCount"));
                    BigDecimal rev = rs.getBigDecimal("TotalRev") != null ? rs.getBigDecimal("TotalRev") : BigDecimal.ZERO;
                    map.put("totalRevenue", rev);
                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getRevenueByCategory", e);
            throw new RuntimeException("Lỗi truy vấn doanh thu theo danh mục từ cơ sở dữ liệu!", e);
        }

        return list;
    }

    /**
     * Fetch revenue breakdown by payment method (COD, VNPAY, BANK_TRANSFER).
     */
    public Map<String, BigDecimal> getRevenueByPaymentMethod(String formattedStartDate, String formattedEndDate) {
        Map<String, BigDecimal> map = new HashMap<>();

        String sql = """
                SELECT COALESCE(p.PaymentMethod, 'COD') AS PaymentMethod,
                       SUM(o.TotalAmount) AS TotalRev
                FROM Orders o
                LEFT JOIN Payments p ON o.OrderID = p.OrderID
                WHERE o.OrderStatus = 'DELIVERED'
                  AND (? IS NULL OR o.OrderDate >= ?)
                  AND (? IS NULL OR o.OrderDate < ?)
                GROUP BY COALESCE(p.PaymentMethod, 'COD')
                """;

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            setDateParameters(ps, 1, formattedStartDate, formattedEndDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String method = rs.getString("PaymentMethod");
                    BigDecimal rev = rs.getBigDecimal("TotalRev") != null ? rs.getBigDecimal("TotalRev") : BigDecimal.ZERO;
                    map.put(method != null ? method : "COD", rev);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error executing getRevenueByPaymentMethod", e);
            throw new RuntimeException("Lỗi truy vấn doanh thu theo phương thức thanh toán từ cơ sở dữ liệu!", e);
        }

        return map;
    }
}
