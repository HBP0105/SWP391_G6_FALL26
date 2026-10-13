package com.swp391.dao.Manager;

import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderManagementDAO {

    public List<Map<String, Object>> getAllOrders() {

        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
            SELECT
                o.OrderID,
                o.CustomerID,
                c.FullName AS CustomerName,
                o.OrderDate,
                o.TotalAmount,
                p.PaymentStatus,
                o.OrderStatus
            FROM Orders o
            LEFT JOIN Customers c
                ON o.CustomerID = c.CustomerID
            LEFT JOIN Payments p
                ON o.OrderID = p.OrderID
            ORDER BY o.OrderDate DESC
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Map<String, Object> order = new HashMap<>();

                order.put(
                        "orderID",
                        rs.getInt("OrderID")
                );

                order.put(
                        "customerID",
                        rs.getInt("CustomerID")
                );

                order.put(
                        "customerName",
                        rs.getString("CustomerName")
                );

                order.put(
                        "orderDate",
                        rs.getTimestamp("OrderDate")
                );

                order.put(
                        "totalAmount",
                        rs.getBigDecimal("TotalAmount")
                );

                order.put(
                        "paymentStatus",
                        rs.getString("PaymentStatus")
                );

                order.put(
                        "orderStatus",
                        rs.getString("OrderStatus")
                );

                list.add(order);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Map<String, Object> getOrderById(int orderId) {

        Map<String, Object> order = new HashMap<>();

        String sql = """
        SELECT
            o.OrderID,
            o.CustomerID,
            o.TotalAmount,
            o.ShippingName,
            o.ShippingPhone,
            o.ShippingAddress,
            o.OrderStatus,
            o.OrderDate,
            o.UpdatedAt,

            p.PaymentID,
            p.PaymentMethod,
            p.TransactionID,
            p.Amount AS PaymentAmount,
            p.PaymentStatus,
            p.ResponseCode,
            p.PaymentDate

        FROM Orders o
        LEFT JOIN Payments p
            ON o.OrderID = p.OrderID

        WHERE o.OrderID = ?
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    order.put("orderId", rs.getInt("OrderID"));
                    order.put("customerId", rs.getInt("CustomerID"));
                    order.put("totalAmount", rs.getBigDecimal("TotalAmount"));

                    order.put("shippingName",
                            rs.getString("ShippingName"));

                    order.put("shippingPhone",
                            rs.getString("ShippingPhone"));

                    order.put("shippingAddress",
                            rs.getString("ShippingAddress"));

                    order.put("orderStatus",
                            rs.getString("OrderStatus"));

                    order.put("orderDate",
                            rs.getTimestamp("OrderDate"));

                    order.put("updatedAt",
                            rs.getTimestamp("UpdatedAt"));

                    order.put("paymentId",
                            rs.getLong("PaymentID"));

                    order.put("paymentMethod",
                            rs.getString("PaymentMethod"));

                    order.put("transactionId",
                            rs.getString("TransactionID"));

                    order.put("paymentAmount",
                            rs.getBigDecimal("PaymentAmount"));

                    order.put("paymentStatus",
                            rs.getString("PaymentStatus"));

                    order.put("responseCode",
                            rs.getString("ResponseCode"));

                    order.put("paymentDate",
                            rs.getTimestamp("PaymentDate"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return order;
    }

    public List<Map<String, Object>> getOrderItems(int orderId) {

        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
        SELECT
            oi.OrderItemID,
            oi.OrderID,
            oi.ProductID,
            p.ProductName,
            oi.Quantity,
            oi.UnitPrice,
            oi.Subtotal
        FROM OrderItems oi
        LEFT JOIN Products p
            ON oi.ProductID = p.ProductID
        WHERE oi.OrderID = ?
        ORDER BY oi.OrderItemID
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Map<String, Object> item = new HashMap<>();

                    item.put("orderItemId",
                            rs.getInt("OrderItemID"));

                    item.put("orderId",
                            rs.getInt("OrderID"));

                    item.put("productId",
                            rs.getInt("ProductID"));

                    item.put("productName",
                            rs.getString("ProductName"));

                    item.put("quantity",
                            rs.getInt("Quantity"));

                    item.put("unitPrice",
                            rs.getBigDecimal("UnitPrice"));

                    item.put("subtotal",
                            rs.getBigDecimal("Subtotal"));

                    list.add(item);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
