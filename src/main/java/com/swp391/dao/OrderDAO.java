package com.swp391.dao;

import com.swp391.model.Order;
import com.swp391.model.OrderItem;
import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    private DBContext dbContext;

    public OrderDAO() {
        dbContext = new DBContext();
    }

    private Order mapOrder(ResultSet rs) throws SQLException {
        Order order = new Order();

        order.setOrderID(rs.getInt("OrderID"));
        order.setUserID(rs.getInt("UserID"));
        order.setTotalAmount(rs.getBigDecimal("TotalAmount"));
        order.setShippingName(rs.getString("ShippingName"));
        order.setShippingPhone(rs.getString("ShippingPhone"));
        order.setShippingAddress(rs.getString("ShippingAddress"));
        order.setOrderStatus(rs.getString("OrderStatus"));

        if (rs.getTimestamp("OrderDate") != null) {
            order.setOrderDate(
                    rs.getTimestamp("OrderDate").toLocalDateTime()
            );
        }

        if (rs.getTimestamp("UpdatedAt") != null) {
            order.setUpdatedAt(
                    rs.getTimestamp("UpdatedAt").toLocalDateTime()
            );
        }

        return order;
    }

    /**
     * Get all orders.
     *
     * Used for Staff to view the order list.
     *
     * @return list of all orders
     */
    public List<Order> getAllOrders() {

        List<Order> orders = new ArrayList<>();

        String sql = """
                SELECT OrderID, UserID, TotalAmount,
                       ShippingName, ShippingPhone, ShippingAddress,
                       OrderStatus, OrderDate, UpdatedAt
                FROM Orders
                ORDER BY OrderDate DESC
                """;

        try (Connection connection = dbContext.getConnection(); PreparedStatement ps = connection.prepareStatement(sql); ResultSet resultSet = ps.executeQuery()) {

            while (resultSet.next()) {

                orders.add(mapOrder(resultSet));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return orders;
    }

    /**
     * Get one order by OrderID.
     *
     * @param orderID order ID
     * @return order if found, otherwise null
     */
    public Order getOrderById(int orderID) {

        String sql = """
                SELECT OrderID, UserID, TotalAmount,
                       ShippingName, ShippingPhone, ShippingAddress,
                       OrderStatus, OrderDate, UpdatedAt
                FROM Orders
                WHERE OrderID = ?
                """;

        try (Connection connection = dbContext.getConnection(); PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, orderID);

            try (ResultSet resultSet = ps.executeQuery()) {

                if (resultSet.next()) {

                    return mapOrder(resultSet);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get all order items of an order.
     *
     * @param orderID order ID
     * @return list of order items
     */
    public List<OrderItem> getOrderItems(int orderID) {

        List<OrderItem> items = new ArrayList<>();

        String sql = """
                SELECT OrderItemID, OrderID, ProductID,
                       Quantity, UnitPrice
                FROM OrderItems
                WHERE OrderID = ?
                ORDER BY OrderItemID
                """;

        try (Connection connection = dbContext.getConnection(); PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, orderID);

            try (ResultSet resultSet = ps.executeQuery()) {

                while (resultSet.next()) {

                    OrderItem item = new OrderItem();

                    item.setOrderItemID(resultSet.getInt("OrderItemID"));
                    item.setOrderID(resultSet.getInt("OrderID"));
                    item.setProductID(resultSet.getInt("ProductID"));
                    item.setQuantity(resultSet.getInt("Quantity"));
                    item.setUnitPrice(resultSet.getBigDecimal("UnitPrice"));

                    items.add(item);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return items;
    }

    /**
     * Update order status.
     *
     * @param orderID order ID
     * @param status new order status
     * @return true if update is successful
     */
    public boolean updateOrderStatus(int orderID, String status) {

        String sql = """
                UPDATE Orders
                SET OrderStatus = ?,
                    UpdatedAt = GETDATE()
                WHERE OrderID = ?
                """;

        try (Connection connection = dbContext.getConnection(); PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, orderID);

            int rowsAffected = ps.executeUpdate();

            return rowsAffected > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Get orders by status.
     *
     * @param status order status
     * @return list of orders
     */
    public List<Order> getOrdersByStatus(String status) {

        List<Order> orders = new ArrayList<>();

        String sql = """
                SELECT OrderID, UserID, TotalAmount,
                       ShippingName, ShippingPhone, ShippingAddress,
                       OrderStatus, OrderDate, UpdatedAt
                FROM Orders
                WHERE OrderStatus = ?
                ORDER BY OrderDate DESC
                """;

        try (Connection connection = dbContext.getConnection(); PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, status);

            try (ResultSet resultSet = ps.executeQuery()) {

                while (resultSet.next()) {

                    orders.add(mapOrder(resultSet));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }
}
