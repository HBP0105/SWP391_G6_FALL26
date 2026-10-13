/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.swp391.dao.Manager;

import java.sql.*;
import java.util.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import com.swp391.model.OrderSummary;
import com.swp391.util.DBContext;

public class ManagerDashBoard {

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    public int getTotalProducts() {
        String sql = "SELECT COUNT(*) FROM Products WHERE Status = 'ACTIVE'";
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    public int getNewProductsThisMonth() {
        String sql = """
            SELECT COUNT(*) 
            FROM Products
            WHERE MONTH(CreatedAt) = MONTH(GETDATE())
              AND YEAR(CreatedAt) = YEAR(GETDATE())
        """;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    public int getTotalOrders() {
        String sql = "SELECT COUNT(*) FROM Orders";
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    public double getOrderGrowthPercent() {
        String sql = """
            SELECT 
                (SELECT COUNT(*) FROM Orders 
                 WHERE MONTH(OrderDate) = MONTH(GETDATE()) 
                   AND YEAR(OrderDate) = YEAR(GETDATE())) * 1.0
                /
                NULLIF(
                    (SELECT COUNT(*) FROM Orders 
                     WHERE MONTH(OrderDate) = MONTH(DATEADD(MONTH, -1, GETDATE()))
                       AND YEAR(OrderDate) = YEAR(DATEADD(MONTH, -1, GETDATE())))
                ,0) * 100
        """;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    public int getLowStockProducts() {
        String sql = "SELECT COUNT(*) FROM Products WHERE StockQuantity > 0 AND StockQuantity <= 10";
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return 0;
    }

    public List<OrderSummary> getRecentOrders() {
        List<OrderSummary> list = new ArrayList<>();

        String sql = """
            SELECT TOP 5 
                o.OrderID,
                c.FullName,
                o.TotalAmount,
                o.OrderStatus,
                o.OrderDate
            FROM Orders o
            JOIN Customers c ON o.CustomerID = c.CustomerID
            ORDER BY o.OrderDate DESC
        """;

        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

            while (rs.next()) {
                OrderSummary o = new OrderSummary();

                o.setOrderID(rs.getInt("OrderID"));
                o.setCustomerName(rs.getString("FullName"));
                o.setTotalAmount(rs.getBigDecimal("TotalAmount"));
                o.setOrderStatus(rs.getString("OrderStatus"));

                Timestamp ts = rs.getTimestamp("OrderDate");
                if (ts != null) {
                    LocalDateTime ldt = ts.toLocalDateTime();
                    o.setOrderDate(ldt); // v?n gi? LocalDateTime
                    o.setFormattedDate(ldt.format(formatter)); // ? THÊM DÒNG NÀY
                }

                list.add(o);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return list;
    }
}
