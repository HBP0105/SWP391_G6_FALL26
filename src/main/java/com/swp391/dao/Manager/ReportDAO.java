package com.swp391.dao.Manager;

import com.swp391.util.DBContext;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportDAO {


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
                ISNULL(SUM(CASE WHEN o.OrderStatus = 'DELIVERED' THEN o.TotalAmount ELSE 0 END), 0) AS TotalRevenue,
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

        try (Connection conn = new DBContext().getConnection();
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

                    if (completed > 0 && totalRevenue != null && totalRevenue.compareTo(BigDecimal.ZERO) > 0) {
                        stats.put("avgOrderValue", totalRevenue.divide(BigDecimal.valueOf(completed), 2, RoundingMode.HALF_UP));
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
            WHERE o.OrderStatus = 'DELIVERED'
        """);
        List<Object> unitParams = new ArrayList<>();
        appendDateFilter(unitsSql, unitParams, startDate, endDate);

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            unitsSql.append(" AND o.OrderStatus = ?");
            unitParams.add(status.trim());
        }

        try (Connection conn = new DBContext().getConnection();
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
     * Get monthly revenue breakdown for the specified year.
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
            WHERE YEAR(o.OrderDate) = ? AND o.OrderStatus = 'DELIVERED'
            GROUP BY MONTH(o.OrderDate)
            ORDER BY [Month]
        """;

        BigDecimal maxRevenue = BigDecimal.ONE;

        try (Connection conn = new DBContext().getConnection();
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

    /**
     * Get order status breakdown distribution.
     */
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

        try (Connection conn = new DBContext().getConnection();
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

    /**
     * Get top selling products.
     */
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
            WHERE o.OrderStatus = 'DELIVERED'
        """);

        List<Object> params = new ArrayList<>();
        params.add(limit);
        appendDateFilter(sql, params, startDate, endDate);

        sql.append("""
            GROUP BY p.ProductID, p.ProductName, c.CategoryName, b.BrandName, p.Price, p.StockQuantity
            ORDER BY UnitsSold DESC, TotalRevenue DESC
        """);

        try (Connection conn = new DBContext().getConnection();
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
            WHERE o.OrderStatus = 'DELIVERED'
        """);

        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);

        sql.append("""
            GROUP BY c.CategoryID, c.CategoryName
            ORDER BY CategoryRevenue DESC
        """);

        BigDecimal grandTotal = BigDecimal.ZERO;

        try (Connection conn = new DBContext().getConnection();
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

        try (Connection conn = new DBContext().getConnection();
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


    public Map<String, Object> getRevenueAnalysisStats(String startDate, String endDate) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalRevenue", BigDecimal.ZERO);
        stats.put("deliveredRevenue", BigDecimal.ZERO);
        stats.put("shippingRevenue", BigDecimal.ZERO);
        stats.put("pendingRevenue", BigDecimal.ZERO);
        stats.put("totalOrders", 0);
        stats.put("validOrders", 0);
        stats.put("shippingOrders", 0);
        stats.put("pendingOrders", 0);
        stats.put("completionRate", 0.0);
        stats.put("avgOrderValue", BigDecimal.ZERO);
        stats.put("unitsSold", 0);

        StringBuilder sql = new StringBuilder("""
            SELECT 
                COUNT(*) AS TotalOrders,
                SUM(CASE WHEN o.OrderStatus = 'DELIVERED' THEN 1 ELSE 0 END) AS ValidOrders,
                SUM(CASE WHEN o.OrderStatus = 'SHIPPING' THEN 1 ELSE 0 END) AS ShippingOrders,
                SUM(CASE WHEN o.OrderStatus = 'PENDING' THEN 1 ELSE 0 END) AS PendingOrders,
                ISNULL(SUM(CASE WHEN o.OrderStatus = 'DELIVERED' THEN o.TotalAmount ELSE 0 END), 0) AS TotalRevenue,
                ISNULL(SUM(CASE WHEN o.OrderStatus = 'DELIVERED' THEN o.TotalAmount ELSE 0 END), 0) AS DeliveredRevenue,
                ISNULL(SUM(CASE WHEN o.OrderStatus = 'SHIPPING' THEN o.TotalAmount ELSE 0 END), 0) AS ShippingRevenue,
                ISNULL(SUM(CASE WHEN o.OrderStatus = 'PENDING' THEN o.TotalAmount ELSE 0 END), 0) AS PendingRevenue
            FROM Orders o
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalOrders = rs.getInt("TotalOrders");
                    int validOrders = rs.getInt("ValidOrders");
                    int shippingOrders = rs.getInt("ShippingOrders");
                    int pendingOrders = rs.getInt("PendingOrders");
                    BigDecimal totalRev = rs.getBigDecimal("TotalRevenue");
                    BigDecimal delRev = rs.getBigDecimal("DeliveredRevenue");
                    BigDecimal shipRev = rs.getBigDecimal("ShippingRevenue");
                    BigDecimal penRev = rs.getBigDecimal("PendingRevenue");

                    stats.put("totalOrders", totalOrders);
                    stats.put("validOrders", validOrders);
                    stats.put("shippingOrders", shippingOrders);
                    stats.put("pendingOrders", pendingOrders);
                    stats.put("totalRevenue", totalRev != null ? totalRev : BigDecimal.ZERO);
                    stats.put("deliveredRevenue", delRev != null ? delRev : BigDecimal.ZERO);
                    stats.put("shippingRevenue", shipRev != null ? shipRev : BigDecimal.ZERO);
                    stats.put("pendingRevenue", penRev != null ? penRev : BigDecimal.ZERO);

                    if (validOrders > 0 && totalRev != null && totalRev.compareTo(BigDecimal.ZERO) > 0) {
                        stats.put("avgOrderValue", totalRev.divide(BigDecimal.valueOf(validOrders), 2, RoundingMode.HALF_UP));
                    }
                    if (totalOrders > 0) {
                        stats.put("completionRate", Math.round((validOrders * 1000.0) / totalOrders) / 10.0);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Total units sold
        StringBuilder unitsSql = new StringBuilder("""
            SELECT ISNULL(SUM(oi.Quantity), 0) AS UnitsSold
            FROM OrderItems oi
            JOIN Orders o ON oi.OrderID = o.OrderID
            WHERE o.OrderStatus = 'DELIVERED'
        """);
        List<Object> unitParams = new ArrayList<>();
        appendDateFilter(unitsSql, unitParams, startDate, endDate);

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(unitsSql.toString())) {
            for (int i = 0; i < unitParams.size(); i++) {
                ps.setObject(i + 1, unitParams.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("unitsSold", rs.getInt("UnitsSold"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return stats;
    }

    /**
     * Get revenue trend grouped by Month (annual) or by Day (range-based).
     */
    public List<Map<String, Object>> getRevenueTrend(String startDate, String endDate, String groupBy, int year) {
        List<Map<String, Object>> trendList = new ArrayList<>();

        if ("day".equalsIgnoreCase(groupBy) && startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
            // Daily breakdown within date range
            StringBuilder sql = new StringBuilder("""
                SELECT 
                    t.OrderDay,
                    COUNT(t.OrderID) AS OrdersCount,
                    ISNULL(SUM(t.TotalUnits), 0) AS UnitsSold,
                    ISNULL(SUM(t.TotalAmount), 0) AS Revenue
                FROM (
                    SELECT 
                        o.OrderID,
                        CONVERT(VARCHAR(10), o.OrderDate, 120) AS OrderDay,
                        o.TotalAmount,
                        (SELECT ISNULL(SUM(oi.Quantity), 0) FROM OrderItems oi WHERE oi.OrderID = o.OrderID) AS TotalUnits
                    FROM Orders o
                    WHERE o.OrderStatus = 'DELIVERED'
            """);

            List<Object> params = new ArrayList<>();
            appendDateFilter(sql, params, startDate, endDate);
            sql.append("""
                ) t
                GROUP BY t.OrderDay
                ORDER BY t.OrderDay ASC
            """);

            BigDecimal maxRevenue = BigDecimal.ONE;

            try (Connection conn = new DBContext().getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql.toString())) {

                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();
                        String day = rs.getString("OrderDay");
                        int ordersCount = rs.getInt("OrdersCount");
                        int unitsSold = rs.getInt("UnitsSold");
                        BigDecimal rev = rs.getBigDecimal("Revenue");

                        item.put("periodLabel", day);
                        item.put("ordersCount", ordersCount);
                        item.put("unitsSold", unitsSold);
                        item.put("revenue", rev != null ? rev : BigDecimal.ZERO);

                        BigDecimal aov = BigDecimal.ZERO;
                        if (ordersCount > 0 && rev != null && rev.compareTo(BigDecimal.ZERO) > 0) {
                            aov = rev.divide(BigDecimal.valueOf(ordersCount), 2, RoundingMode.HALF_UP);
                        }
                        item.put("avgOrderValue", aov);

                        if (rev != null && rev.compareTo(maxRevenue) > 0) {
                            maxRevenue = rev;
                        }
                        trendList.add(item);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            for (Map<String, Object> item : trendList) {
                BigDecimal rev = (BigDecimal) item.get("revenue");
                if (rev != null && maxRevenue.compareTo(BigDecimal.ZERO) > 0) {
                    double pct = (rev.doubleValue() / maxRevenue.doubleValue()) * 95.0 + 5.0;
                    item.put("barHeight", (int) Math.round(pct));
                } else {
                    item.put("barHeight", 5);
                }
            }

        } else {
            // Default: Monthly breakdown for selected year
            String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
            for (int m = 1; m <= 12; m++) {
                Map<String, Object> item = new HashMap<>();
                item.put("month", m);
                item.put("periodLabel", monthNames[m - 1]);
                item.put("ordersCount", 0);
                item.put("unitsSold", 0);
                item.put("revenue", BigDecimal.ZERO);
                item.put("avgOrderValue", BigDecimal.ZERO);
                item.put("barHeight", 5);
                trendList.add(item);
            }

            String sql = """
                SELECT 
                    MONTH(t.OrderDate) AS [Month],
                    COUNT(t.OrderID) AS OrdersCount,
                    ISNULL(SUM(t.TotalUnits), 0) AS UnitsSold,
                    ISNULL(SUM(t.TotalAmount), 0) AS Revenue
                FROM (
                    SELECT 
                        o.OrderID,
                        o.OrderDate,
                        o.TotalAmount,
                        (SELECT ISNULL(SUM(oi.Quantity), 0) FROM OrderItems oi WHERE oi.OrderID = o.OrderID) AS TotalUnits
                    FROM Orders o
                    WHERE o.OrderStatus = 'DELIVERED' AND YEAR(o.OrderDate) = ?
                ) t
                GROUP BY MONTH(t.OrderDate)
                ORDER BY [Month] ASC
            """;

            BigDecimal maxRevenue = BigDecimal.ONE;

            try (Connection conn = new DBContext().getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, year);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int m = rs.getInt("Month");
                        int ordersCount = rs.getInt("OrdersCount");
                        int unitsSold = rs.getInt("UnitsSold");
                        BigDecimal rev = rs.getBigDecimal("Revenue");

                        if (m >= 1 && m <= 12) {
                            Map<String, Object> map = trendList.get(m - 1);
                            map.put("ordersCount", ordersCount);
                            map.put("unitsSold", unitsSold);
                            map.put("revenue", rev != null ? rev : BigDecimal.ZERO);

                            BigDecimal aov = BigDecimal.ZERO;
                            if (ordersCount > 0 && rev != null && rev.compareTo(BigDecimal.ZERO) > 0) {
                                aov = rev.divide(BigDecimal.valueOf(ordersCount), 2, RoundingMode.HALF_UP);
                            }
                            map.put("avgOrderValue", aov);

                            if (rev != null && rev.compareTo(maxRevenue) > 0) {
                                maxRevenue = rev;
                            }
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            for (Map<String, Object> item : trendList) {
                BigDecimal rev = (BigDecimal) item.get("revenue");
                if (rev != null && maxRevenue.compareTo(BigDecimal.ZERO) > 0) {
                    double pct = (rev.doubleValue() / maxRevenue.doubleValue()) * 95.0 + 5.0;
                    item.put("barHeight", (int) Math.round(pct));
                }
            }
        }

        return trendList;
    }

    /**
     * Get revenue breakdown by payment method.
     */
    public List<Map<String, Object>> getRevenuePaymentMethodBreakdown(String startDate, String endDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT 
                ISNULL(p.PaymentMethod, 'COD') AS PaymentMethod,
                COUNT(o.OrderID) AS OrdersCount,
                ISNULL(SUM(CASE WHEN o.OrderStatus = 'DELIVERED' THEN o.TotalAmount ELSE 0 END), 0) AS Revenue
            FROM Orders o
            LEFT JOIN Payments p ON o.OrderID = p.OrderID
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);
        sql.append("""
            GROUP BY ISNULL(p.PaymentMethod, 'COD')
            ORDER BY Revenue DESC
        """);

        BigDecimal totalRevenue = BigDecimal.ZERO;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    String method = rs.getString("PaymentMethod");
                    int count = rs.getInt("OrdersCount");
                    BigDecimal rev = rs.getBigDecimal("Revenue");

                    map.put("paymentMethod", method);
                    map.put("ordersCount", count);
                    map.put("revenue", rev != null ? rev : BigDecimal.ZERO);
                    if (rev != null) {
                        totalRevenue = totalRevenue.add(rev);
                    }
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        for (Map<String, Object> map : list) {
            BigDecimal rev = (BigDecimal) map.get("revenue");
            int sharePct = 0;
            if (rev != null && totalRevenue.compareTo(BigDecimal.ZERO) > 0) {
                sharePct = (int) Math.round((rev.doubleValue() / totalRevenue.doubleValue()) * 100.0);
            }
            map.put("sharePct", sharePct);
        }

        return list;
    }


    public List<Map<String, Object>> getProductPerformanceList(
            String startDate,
            String endDate,
            Integer categoryId,
            Integer brandId,
            String keyword,
            String sort,
            int offset,
            int limit) {

        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT 
                p.ProductID,
                p.ProductName,
                ISNULL(b.BrandName, 'N/A') AS BrandName,
                ISNULL(c.CategoryName, 'N/A') AS CategoryName,
                p.Price,
                p.StockQuantity,
                ISNULL(sales.UnitsSold, 0) AS UnitsSold,
                ISNULL(sales.OrderCount, 0) AS OrderCount,
                ISNULL(sales.Revenue, 0) AS Revenue
            FROM Products p
            LEFT JOIN Brands b ON p.BrandID = b.BrandID
            LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
            LEFT JOIN (
                SELECT 
                    oi.ProductID,
                    SUM(oi.Quantity) AS UnitsSold,
                    COUNT(DISTINCT oi.OrderID) AS OrderCount,
                    SUM(oi.Quantity * oi.UnitPrice) AS Revenue
                FROM OrderItems oi
                JOIN Orders o ON oi.OrderID = o.OrderID
                WHERE o.OrderStatus = 'DELIVERED'
        """);

        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);

        sql.append("""
                GROUP BY oi.ProductID
            ) sales ON p.ProductID = sales.ProductID
            WHERE 1=1
        """);

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.CategoryID = ?");
            params.add(categoryId);
        }

        if (brandId != null && brandId > 0) {
            sql.append(" AND p.BrandID = ?");
            params.add(brandId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.ProductName LIKE ? OR CAST(p.ProductID AS VARCHAR(20)) = ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(keyword.trim());
        }

        // Sorting
        String orderByClause = resolveProductSort(sort);
        sql.append(" ").append(orderByClause);

        // Pagination
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(limit);

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                int rank = offset + 1;
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("rank", rank++);
                    map.put("productID", rs.getInt("ProductID"));
                    map.put("productName", rs.getString("ProductName"));
                    map.put("brandName", rs.getString("BrandName"));
                    map.put("categoryName", rs.getString("CategoryName"));
                    map.put("price", rs.getBigDecimal("Price"));
                    map.put("stockQuantity", rs.getInt("StockQuantity"));
                    map.put("unitsSold", rs.getInt("UnitsSold"));
                    map.put("orderCount", rs.getInt("OrderCount"));
                    map.put("revenue", rs.getBigDecimal("Revenue"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * Count total products matching performance filters for pagination.
     */
    public int countProductPerformance(
            String startDate,
            String endDate,
            Integer categoryId,
            Integer brandId,
            String keyword) {

        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*) AS TotalCount
            FROM Products p
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.CategoryID = ?");
            params.add(categoryId);
        }

        if (brandId != null && brandId > 0) {
            sql.append(" AND p.BrandID = ?");
            params.add(brandId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.ProductName LIKE ? OR CAST(p.ProductID AS VARCHAR(20)) = ?)");
            params.add("%" + keyword.trim() + "%");
            params.add(keyword.trim());
        }

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("TotalCount");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Get aggregate KPI summary for Product Performance screen.
     */
    public Map<String, Object> getProductPerformanceSummary(
            String startDate,
            String endDate,
            Integer categoryId,
            Integer brandId,
            String keyword) {

        Map<String, Object> summary = new HashMap<>();
        summary.put("totalProducts", 0);
        summary.put("totalUnitsSold", 0);
        summary.put("totalRevenue", BigDecimal.ZERO);
        summary.put("avgRevenuePerProduct", BigDecimal.ZERO);

        StringBuilder sql = new StringBuilder("""
            SELECT 
                COUNT(p.ProductID) AS TotalProducts,
                ISNULL(SUM(sales.UnitsSold), 0) AS TotalUnitsSold,
                ISNULL(SUM(sales.Revenue), 0) AS TotalRevenue
            FROM Products p
            LEFT JOIN (
                SELECT 
                    oi.ProductID,
                    SUM(oi.Quantity) AS UnitsSold,
                    SUM(oi.Quantity * oi.UnitPrice) AS Revenue
                FROM OrderItems oi
                JOIN Orders o ON oi.OrderID = o.OrderID
                WHERE o.OrderStatus = 'DELIVERED'
        """);

        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);

        sql.append("""
                GROUP BY oi.ProductID
            ) sales ON p.ProductID = sales.ProductID
            WHERE 1=1
        """);

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.CategoryID = ?");
            params.add(categoryId);
        }

        if (brandId != null && brandId > 0) {
            sql.append(" AND p.BrandID = ?");
            params.add(brandId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.ProductName LIKE ? OR CAST(p.ProductID AS VARCHAR(20)) = ?)");
            params.add("%" + keyword.trim() + "%");
            params.add(keyword.trim());
        }

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalProducts = rs.getInt("TotalProducts");
                    int totalUnits = rs.getInt("TotalUnitsSold");
                    BigDecimal totalRev = rs.getBigDecimal("TotalRevenue");

                    summary.put("totalProducts", totalProducts);
                    summary.put("totalUnitsSold", totalUnits);
                    summary.put("totalRevenue", totalRev != null ? totalRev : BigDecimal.ZERO);

                    if (totalProducts > 0 && totalRev != null && totalRev.compareTo(BigDecimal.ZERO) > 0) {
                        summary.put("avgRevenuePerProduct", totalRev.divide(BigDecimal.valueOf(totalProducts), 2, RoundingMode.HALF_UP));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return summary;
    }

    private String resolveProductSort(String sort) {
        if (sort == null || sort.trim().isEmpty()) {
            return "ORDER BY Revenue DESC, UnitsSold DESC, p.ProductID DESC";
        }
        return switch (sort.toLowerCase().trim()) {
            case "revenue_asc" -> "ORDER BY Revenue ASC, UnitsSold ASC";
            case "revenue_desc" -> "ORDER BY Revenue DESC, UnitsSold DESC";
            case "units_asc" -> "ORDER BY UnitsSold ASC, Revenue ASC";
            case "units_desc" -> "ORDER BY UnitsSold DESC, Revenue DESC";
            case "orders_asc" -> "ORDER BY OrderCount ASC, Revenue ASC";
            case "orders_desc" -> "ORDER BY OrderCount DESC, Revenue DESC";
            case "name_asc" -> "ORDER BY p.ProductName ASC";
            case "name_desc" -> "ORDER BY p.ProductName DESC";
            case "id_asc" -> "ORDER BY p.ProductID ASC";
            case "id_desc" -> "ORDER BY p.ProductID DESC";
            default -> "ORDER BY Revenue DESC, UnitsSold DESC, p.ProductID DESC";
        };
    }

    /**
     * Get list of active categories for filter dropdown.
     */
    public List<Map<String, Object>> getAllCategories() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT CategoryID, CategoryName FROM Categories WHERE Status = 'ACTIVE' ORDER BY CategoryName";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("categoryID", rs.getInt("CategoryID"));
                map.put("categoryName", rs.getString("CategoryName"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get list of active brands for filter dropdown.
     */
    public List<Map<String, Object>> getAllBrands() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT BrandID, BrandName FROM Brands WHERE Status = 'ACTIVE' ORDER BY BrandName";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("brandID", rs.getInt("BrandID"));
                map.put("brandName", rs.getString("BrandName"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    public Map<String, Object> getOrderAnalysisStats(
            String startDate,
            String endDate,
            String status,
            String paymentMethod) {

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalOrders", 0);
        stats.put("completedOrders", 0);
        stats.put("pendingOrders", 0);
        stats.put("shippingOrders", 0);
        stats.put("cancelledOrders", 0);
        stats.put("cancellationRate", 0.0);
        stats.put("totalUnitsSold", 0);
        stats.put("avgItemsPerOrder", 0.0);
        stats.put("totalRevenue", BigDecimal.ZERO);
        stats.put("avgOrderValue", BigDecimal.ZERO);

        StringBuilder sql = new StringBuilder("""
            SELECT 
                COUNT(*) AS TotalOrders,
                ISNULL(SUM(CASE WHEN o.OrderStatus = 'DELIVERED' THEN o.TotalAmount ELSE 0 END), 0) AS TotalRevenue,
                SUM(CASE WHEN o.OrderStatus = 'DELIVERED' THEN 1 ELSE 0 END) AS CompletedOrders,
                SUM(CASE WHEN o.OrderStatus = 'PENDING' THEN 1 ELSE 0 END) AS PendingOrders,
                SUM(CASE WHEN o.OrderStatus = 'SHIPPING' THEN 1 ELSE 0 END) AS ShippingOrders,
                SUM(CASE WHEN o.OrderStatus = 'CANCELLED' THEN 1 ELSE 0 END) AS CancelledOrders
            FROM Orders o
            LEFT JOIN Payments p ON o.OrderID = p.OrderID
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND o.OrderStatus = ?");
            params.add(status.trim());
        }

        if (paymentMethod != null && !paymentMethod.trim().isEmpty() && !"ALL".equalsIgnoreCase(paymentMethod)) {
            if ("COD".equalsIgnoreCase(paymentMethod.trim())) {
                sql.append(" AND (p.PaymentMethod = 'COD' OR p.PaymentMethod IS NULL)");
            } else {
                sql.append(" AND p.PaymentMethod = ?");
                params.add(paymentMethod.trim());
            }
        }

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalOrders = rs.getInt("TotalOrders");
                    BigDecimal totalRev = rs.getBigDecimal("TotalRevenue");
                    int completed = rs.getInt("CompletedOrders");
                    int pending = rs.getInt("PendingOrders");
                    int shipping = rs.getInt("ShippingOrders");
                    int cancelled = rs.getInt("CancelledOrders");

                    stats.put("totalOrders", totalOrders);
                    stats.put("totalRevenue", totalRev != null ? totalRev : BigDecimal.ZERO);
                    stats.put("completedOrders", completed);
                    stats.put("pendingOrders", pending);
                    stats.put("shippingOrders", shipping);
                    stats.put("cancelledOrders", cancelled);

                    if (completed > 0 && totalRev != null && totalRev.compareTo(BigDecimal.ZERO) > 0) {
                        stats.put("avgOrderValue", totalRev.divide(BigDecimal.valueOf(completed), 2, RoundingMode.HALF_UP));
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

        // Units Sold for calculating Average items per order
        StringBuilder unitsSql = new StringBuilder("""
            SELECT ISNULL(SUM(oi.Quantity), 0) AS TotalUnits
            FROM OrderItems oi
            JOIN Orders o ON oi.OrderID = o.OrderID
            LEFT JOIN Payments p ON o.OrderID = p.OrderID
            WHERE 1=1
        """);

        List<Object> unitParams = new ArrayList<>();
        appendDateFilter(unitsSql, unitParams, startDate, endDate);

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            unitsSql.append(" AND o.OrderStatus = ?");
            unitParams.add(status.trim());
        }

        if (paymentMethod != null && !paymentMethod.trim().isEmpty() && !"ALL".equalsIgnoreCase(paymentMethod)) {
            if ("COD".equalsIgnoreCase(paymentMethod.trim())) {
                unitsSql.append(" AND (p.PaymentMethod = 'COD' OR p.PaymentMethod IS NULL)");
            } else {
                unitsSql.append(" AND p.PaymentMethod = ?");
                unitParams.add(paymentMethod.trim());
            }
        }

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(unitsSql.toString())) {

            for (int i = 0; i < unitParams.size(); i++) {
                ps.setObject(i + 1, unitParams.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalUnits = rs.getInt("TotalUnits");
                    stats.put("totalUnitsSold", totalUnits);

                    int totalOrders = (int) stats.get("totalOrders");
                    if (totalOrders > 0) {
                        double avgItems = (totalUnits * 1.0) / totalOrders;
                        stats.put("avgItemsPerOrder", Math.round(avgItems * 10.0) / 10.0);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return stats;
    }

    /**
     * Get payment method statistics for Order Analysis screen.
     */
    public List<Map<String, Object>> getOrderPaymentMethods(String startDate, String endDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT 
                ISNULL(p.PaymentMethod, 'COD') AS PaymentMethod,
                COUNT(o.OrderID) AS OrderCount,
                ISNULL(SUM(o.TotalAmount), 0) AS TotalAmount,
                SUM(CASE WHEN p.PaymentStatus = 'SUCCESS' THEN 1 ELSE 0 END) AS SuccessCount,
                SUM(CASE WHEN p.PaymentStatus = 'PENDING' OR p.PaymentStatus IS NULL THEN 1 ELSE 0 END) AS PendingCount
            FROM Orders o
            LEFT JOIN Payments p ON o.OrderID = p.OrderID
            WHERE 1=1
        """);

        List<Object> params = new ArrayList<>();
        appendDateFilter(sql, params, startDate, endDate);
        sql.append("""
            GROUP BY ISNULL(p.PaymentMethod, 'COD')
            ORDER BY OrderCount DESC
        """);

        int totalOrders = 0;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    String method = rs.getString("PaymentMethod");
                    int count = rs.getInt("OrderCount");
                    BigDecimal totalAmount = rs.getBigDecimal("TotalAmount");
                    int success = rs.getInt("SuccessCount");
                    int pending = rs.getInt("PendingCount");

                    map.put("paymentMethod", method);
                    map.put("orderCount", count);
                    map.put("totalAmount", totalAmount != null ? totalAmount : BigDecimal.ZERO);
                    map.put("successCount", success);
                    map.put("pendingCount", pending);

                    totalOrders += count;
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        for (Map<String, Object> map : list) {
            int count = (int) map.get("orderCount");
            int sharePct = 0;
            if (totalOrders > 0) {
                sharePct = (int) Math.round((count * 100.0) / totalOrders);
            }
            map.put("sharePct", sharePct);
        }

        return list;
    }

    /**
     * Get paginated detailed order list for Order Analysis screen with filters.
     */
    public List<Map<String, Object>> getDetailedOrdersPaginated(
            String startDate,
            String endDate,
            String status,
            String paymentMethod,
            String keyword,
            int offset,
            int limit) {

        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT 
                o.OrderID,
                o.OrderDate,
                o.TotalAmount,
                o.OrderStatus,
                o.ShippingName,
                o.ShippingPhone,
                o.ShippingAddress,
                c.CustomerID,
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

        if (paymentMethod != null && !paymentMethod.trim().isEmpty() && !"ALL".equalsIgnoreCase(paymentMethod)) {
            if ("COD".equalsIgnoreCase(paymentMethod.trim())) {
                sql.append(" AND (p.PaymentMethod = 'COD' OR p.PaymentMethod IS NULL)");
            } else {
                sql.append(" AND p.PaymentMethod = ?");
                params.add(paymentMethod.trim());
            }
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (CAST(o.OrderID AS VARCHAR(20)) = ? OR c.FullName LIKE ? OR c.Email LIKE ? OR o.ShippingPhone LIKE ?)");
            params.add(keyword.trim());
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        sql.append(" ORDER BY o.OrderDate DESC");
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(limit);

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("orderID", rs.getInt("OrderID"));
                    map.put("customerID", rs.getInt("CustomerID"));
                    map.put("customerName", rs.getString("CustomerName"));
                    map.put("customerEmail", rs.getString("CustomerEmail"));
                    map.put("shippingName", rs.getString("ShippingName"));
                    map.put("shippingPhone", rs.getString("ShippingPhone"));
                    map.put("shippingAddress", rs.getString("ShippingAddress"));
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

    /**
     * Count total orders matching filter criteria for pagination.
     */
    public int countDetailedOrders(
            String startDate,
            String endDate,
            String status,
            String paymentMethod,
            String keyword) {

        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*) AS TotalCount
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

        if (paymentMethod != null && !paymentMethod.trim().isEmpty() && !"ALL".equalsIgnoreCase(paymentMethod)) {
            if ("COD".equalsIgnoreCase(paymentMethod.trim())) {
                sql.append(" AND (p.PaymentMethod = 'COD' OR p.PaymentMethod IS NULL)");
            } else {
                sql.append(" AND p.PaymentMethod = ?");
                params.add(paymentMethod.trim());
            }
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (CAST(o.OrderID AS VARCHAR(20)) = ? OR c.FullName LIKE ? OR c.Email LIKE ? OR o.ShippingPhone LIKE ?)");
            params.add(keyword.trim());
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("TotalCount");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Helper to append date filters safely to queries on Orders table alias 'o'.
     */
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
