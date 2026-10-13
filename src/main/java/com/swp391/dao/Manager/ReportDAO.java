package com.swp391.dao.Manager;

import com.swp391.util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportDAO {

    /**
     * Get summary KPI statistics for a given period and order status.
     */
    public Map<String, Object> getOverviewStats(String startDate, String endDate, String status) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalRevenue", BigDecimal.ZERO);
        stats.put("totalOrders", 0);
        stats.put("completedOrders", 0);
        stats.put("pendingOrders", 0);
        stats.put("shippingOrders", 0);
        stats.put("cancelledOrders", 0);
        stats.put("totalUnitsSold", 0);
        stats.put("avgOrderValue", BigDecimal.ZERO);
        stats.put("cancellationRate", 0.0);

        StringBuilder sql = new StringBuilder("""
            SELECT 
                COUNT(*) AS TotalOrders,
                ISNULL(SUM(CASE WHEN o.OrderStatus NOT IN ('CANCELLED') THEN o.TotalAmount ELSE 0 END), 0) AS TotalRevenue,
                SUM(CASE WHEN o.OrderStatus = 'DELIVERED' THEN 1 ELSE 0 END) AS CompletedOrders,
                SUM(CASE WHEN o.OrderStatus = 'PENDING' THEN 1 ELSE 0 END) AS PendingOrders,
                SUM(CASE WHEN o.OrderStatus = 'SHIPPING' THEN 1 ELSE 0 END) AS ShippingOrders,
                SUM(CASE WHEN o.OrderStatus = 'CANCELLED' THEN 1 ELSE 0 END) AS CancelledOrders
            FROM Orders o
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND o.OrderStatus = ?");
            params.add(status.trim());
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalOrders = rs.getInt("TotalOrders");
                    BigDecimal totalRevenue = rs.getBigDecimal("TotalRevenue");
                    int completed = rs.getInt("CompletedOrders");
                    int pending = rs.getInt("PendingOrders");
                    int shipping = rs.getInt("ShippingOrders");
                    int cancelled = rs.getInt("CancelledOrders");

                    stats.put("totalOrders", totalOrders);
                    stats.put("totalRevenue", totalRevenue != null ? totalRevenue : BigDecimal.ZERO);
                    stats.put("completedOrders", completed);
                    stats.put("pendingOrders", pending);
                    stats.put("shippingOrders", shipping);
                    stats.put("cancelledOrders", cancelled);

                    int validOrderCount = totalOrders - cancelled;
                    if (validOrderCount > 0 && totalRevenue != null && totalRevenue.compareTo(BigDecimal.ZERO) > 0) {
                        stats.put("avgOrderValue", totalRevenue.divide(BigDecimal.valueOf(validOrderCount), 2, java.math.RoundingMode.HALF_UP));
                    }

                    if (totalOrders > 0) {
                        double cancelRate = (cancelled * 100.0) / totalOrders;
                        stats.put("cancellationRate", Math.round(cancelRate * 10.0) / 10.0);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Units sold
        StringBuilder unitsSql = new StringBuilder("""
            SELECT ISNULL(SUM(oi.Quantity), 0) AS UnitsSold
            FROM OrderItems oi
            JOIN Orders o ON oi.OrderID = o.OrderID
            WHERE o.OrderStatus NOT IN ('CANCELLED')
        """);
        List<Object> unitParams = new ArrayList<>();
        appendDateFilter(unitsSql, unitParams, startDate, endDate);

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            unitsSql.append(" AND o.OrderStatus = ?");
            unitParams.add(status.trim());
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(unitsSql.toString())) {
            for (int i = 0; i < unitParams.size(); i++) {
                ps.setObject(i + 1, unitParams.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalUnitsSold", rs.getInt("UnitsSold"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return stats;
    }

    /**
     * Get monthly revenue breakdown for the specified year (or current year).
     */
    public List<Map<String, Object>> getMonthlyRevenue(int year) {
        List<Map<String, Object>> list = new ArrayList<>();
        String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

        // Default 12 months with 0
        for (int m = 1; m <= 12; m++) {
            Map<String, Object> map = new HashMap<>();
            map.put("month", m);
            map.put("monthName", monthNames[m - 1]);
            map.put("revenue", BigDecimal.ZERO);
            map.put("ordersCount", 0);
            map.put("barHeight", 5); // default min 5%
            list.add(map);
        }

        String sql = """
            SELECT 
                MONTH(o.OrderDate) AS [Month],
                COUNT(o.OrderID) AS OrdersCount,
                ISNULL(SUM(o.TotalAmount), 0) AS Revenue
            FROM Orders o
            WHERE YEAR(o.OrderDate) = ? AND o.OrderStatus NOT IN ('CANCELLED')
            GROUP BY MONTH(o.OrderDate)
            ORDER BY [Month]
        """;

        BigDecimal maxRevenue = BigDecimal.ONE;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int m = rs.getInt("Month");
                    int count = rs.getInt("OrdersCount");
                    BigDecimal rev = rs.getBigDecimal("Revenue");

                    if (m >= 1 && m <= 12) {
                        Map<String, Object> map = list.get(m - 1);
                        map.put("revenue", rev);
                        map.put("ordersCount", count);

                        if (rev != null && rev.compareTo(maxRevenue) > 0) {
                            maxRevenue = rev;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Calculate relative bar heights (percentage 5% to 100%)
        for (Map<String, Object> item : list) {
            BigDecimal rev = (BigDecimal) item.get("revenue");
            if (rev != null && maxRevenue.compareTo(BigDecimal.ZERO) > 0) {
                double pct = (rev.doubleValue() / maxRevenue.doubleValue()) * 95.0 + 5.0;
                item.put("barHeight", (int) Math.round(pct));
            }
        }

        return list;
    }

  
    public Map<String, Object> getOrderStatusDistribution(String startDate, String endDate) {
        Map<String, Object> result = new HashMap<>();
        int delivered = 0, shipping = 0, pending = 0, cancelled = 0, other = 0, total = 0;

        StringBuilder sql = new StringBuilder("""
            SELECT o.OrderStatus, COUNT(*) AS StatusCount
            FROM Orders o
            WHERE 1=1
        """);
        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);
        sql.append(" GROUP BY o.OrderStatus");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String status = rs.getString("OrderStatus");
                    int count = rs.getInt("StatusCount");
                    total += count;
                    if ("DELIVERED".equalsIgnoreCase(status)) {
                        delivered += count;
                    } else if ("SHIPPING".equalsIgnoreCase(status)) {
                        shipping += count;
                    } else if ("PENDING".equalsIgnoreCase(status)) {
                        pending += count;
                    } else if ("CANCELLED".equalsIgnoreCase(status)) {
                        cancelled += count;
                    } else {
                        other += count;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        result.put("total", total);
        result.put("delivered", delivered);
        result.put("shipping", shipping);
        result.put("pending", pending);
        result.put("cancelled", cancelled);
        result.put("other", other);

        int deliveredPct = total > 0 ? (int) Math.round((delivered * 100.0) / total) : 0;
        int shippingPct = total > 0 ? (int) Math.round((shipping * 100.0) / total) : 0;
        int pendingPct = total > 0 ? (int) Math.round((pending * 100.0) / total) : 0;
        int cancelledPct = total > 0 ? (int) Math.round((cancelled * 100.0) / total) : 0;

        result.put("deliveredPct", deliveredPct);
        result.put("shippingPct", shippingPct);
        result.put("pendingPct", pendingPct);
        result.put("cancelledPct", cancelledPct);

        return result;
    }

    
    public List<Map<String, Object>> getTopSellingProducts(int limit, String startDate, String endDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT TOP (?)
                p.ProductID,
                p.ProductName,
                c.CategoryName,
                b.BrandName,
                p.Price,
                p.StockQuantity,
                ISNULL(SUM(oi.Quantity), 0) AS UnitsSold,
                ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalRevenue
            FROM Products p
            JOIN OrderItems oi ON p.ProductID = oi.ProductID
            JOIN Orders o ON oi.OrderID = o.OrderID
            LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
            LEFT JOIN Brands b ON p.BrandID = b.BrandID
            WHERE o.OrderStatus NOT IN ('CANCELLED')
        """);

        List<Object> params = new ArrayList<>();
        params.add(limit);
        appendDateFilter(sql, params, startDate, endDate);

        sql.append("""
            GROUP BY p.ProductID, p.ProductName, c.CategoryName, b.BrandName, p.Price, p.StockQuantity
            ORDER BY UnitsSold DESC, TotalRevenue DESC
        """);

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                int rank = 1;
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("rank", rank++);
                    map.put("productID", rs.getInt("ProductID"));
                    map.put("productName", rs.getString("ProductName"));
                    map.put("categoryName", rs.getString("CategoryName"));
                    map.put("brandName", rs.getString("BrandName"));
                    map.put("price", rs.getBigDecimal("Price"));
                    map.put("stockQuantity", rs.getInt("StockQuantity"));
                    map.put("unitsSold", rs.getInt("UnitsSold"));
                    map.put("totalRevenue", rs.getBigDecimal("TotalRevenue"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * Get category revenue and volume breakdown.
     */
    public List<Map<String, Object>> getCategorySales(String startDate, String endDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT 
                c.CategoryID,
                c.CategoryName,
                ISNULL(SUM(oi.Quantity), 0) AS UnitsSold,
                ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS CategoryRevenue
            FROM Categories c
            JOIN Products p ON c.CategoryID = p.CategoryID
            JOIN OrderItems oi ON p.ProductID = oi.ProductID
            JOIN Orders o ON oi.OrderID = o.OrderID
            WHERE o.OrderStatus NOT IN ('CANCELLED')
        """);

        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);

        sql.append("""
            GROUP BY c.CategoryID, c.CategoryName
            ORDER BY CategoryRevenue DESC
        """);

        BigDecimal grandTotal = BigDecimal.ZERO;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("categoryID", rs.getInt("CategoryID"));
                    map.put("categoryName", rs.getString("CategoryName"));
                    map.put("unitsSold", rs.getInt("UnitsSold"));
                    BigDecimal rev = rs.getBigDecimal("CategoryRevenue");
                    map.put("revenue", rev);
                    if (rev != null) {
                        grandTotal = grandTotal.add(rev);
                    }
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        for (Map<String, Object> map : list) {
            BigDecimal rev = (BigDecimal) map.get("revenue");
            int pct = 0;
            if (rev != null && grandTotal.compareTo(BigDecimal.ZERO) > 0) {
                pct = (int) Math.round((rev.doubleValue() / grandTotal.doubleValue()) * 100.0);
            }
            map.put("sharePct", pct);
        }

        return list;
    }

    /**
     * Get detailed orders list for tabular reporting and export.
     */
    public List<Map<String, Object>> getOrdersReport(String startDate, String endDate, String status) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT 
                o.OrderID,
                o.OrderDate,
                o.TotalAmount,
                o.OrderStatus,
                c.FullName AS CustomerName,
                c.Email AS CustomerEmail,
                ISNULL(p.PaymentMethod, 'COD') AS PaymentMethod,
                ISNULL(p.PaymentStatus, 'PENDING') AS PaymentStatus,
                (SELECT ISNULL(SUM(oi.Quantity), 0) FROM OrderItems oi WHERE oi.OrderID = o.OrderID) AS TotalItems
            FROM Orders o
            LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
            LEFT JOIN Payments p ON o.OrderID = p.OrderID
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND o.OrderStatus = ?");
            params.add(status.trim());
        }

        sql.append(" ORDER BY o.OrderDate DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("orderID", rs.getInt("OrderID"));
                    map.put("customerName", rs.getString("CustomerName"));
                    map.put("customerEmail", rs.getString("CustomerEmail"));
                    map.put("totalAmount", rs.getBigDecimal("TotalAmount"));
                    map.put("orderStatus", rs.getString("OrderStatus"));
                    map.put("paymentMethod", rs.getString("PaymentMethod"));
                    map.put("paymentStatus", rs.getString("PaymentStatus"));
                    map.put("totalItems", rs.getInt("TotalItems"));

                    java.sql.Timestamp ts = rs.getTimestamp("OrderDate");
                    if (ts != null) {
                        map.put("orderDate", ts.toLocalDateTime().format(dtf));
                    } else {
                        map.put("orderDate", "");
                    }

                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private void appendDateFilter(StringBuilder sql, List<Object> params, String startDate, String endDate) {
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND o.OrderDate >= CAST(? AS DATETIME2)");
            params.add(startDate.trim() + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND o.OrderDate <= CAST(? AS DATETIME2)");
            params.add(endDate.trim() + " 23:59:59");
        }
    }
}
