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
        order.setCustomerID(rs.getInt("CustomerID"));
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

    public List<Order> getAllOrders() {

        List<Order> orders = new ArrayList<>();

        String sql = """
                SELECT OrderID, CustomerID, TotalAmount,
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
                SELECT OrderID, CustomerID, TotalAmount,
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
     * @param newStatus new order status
     * @return true if update is successful
     */
    public boolean updateOrderStatus(int orderID, String newStatus) {

        String sql = """
                UPDATE Orders
                SET OrderStatus = ?,
                    UpdatedAt = GETDATE()
                WHERE OrderID = ?
                """;

        try (Connection connection = dbContext.getConnection(); PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, orderID);

            int rowsAffected = ps.executeUpdate();

            return rowsAffected > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Update order status with strict State Machine validation.
     * Allowed transitions:
     * - PENDING -> CONFIRMED or CANCELLED
     * - CONFIRMED -> SHIPPING or CANCELLED
     * - SHIPPING -> DELIVERED
     * - DELIVERED or CANCELLED -> Cannot be changed!
     */
    public boolean updateOrderStatusWithValidation(int orderID, String newStatus) {
        Order currentOrder = getOrderById(orderID);
        if (currentOrder == null) {
            return false;
        }

        String currentStatus = currentOrder.getOrderStatus();
        if (currentStatus == null || newStatus == null) {
            return false;
        }

        boolean isValidTransition = false;
        if ("PENDING".equalsIgnoreCase(currentStatus)) {
            if ("CONFIRMED".equalsIgnoreCase(newStatus) || "CANCELLED".equalsIgnoreCase(newStatus)) {
                isValidTransition = true;
            }
        } else if ("CONFIRMED".equalsIgnoreCase(currentStatus)) {
            if ("SHIPPING".equalsIgnoreCase(newStatus) || "CANCELLED".equalsIgnoreCase(newStatus)) {
                isValidTransition = true;
            }
        } else if ("SHIPPING".equalsIgnoreCase(currentStatus)) {
            if ("DELIVERED".equalsIgnoreCase(newStatus)) {
                isValidTransition = true;
            }
        }

        if (!isValidTransition) {
            return false;
        }

        return updateOrderStatus(orderID, newStatus.toUpperCase());
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
                SELECT OrderID, CustomerID, TotalAmount,
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

    /**
     * Get total count of orders filtered by status and date range.
     */
    public int getTotalOrdersFilteredCount(String startDate, String endDate, String status) {
        return getTotalOrdersFilteredCount(startDate, endDate, status, null);
    }

    /**
     * Get total count of orders filtered by status, date range, and search keyword.
     */
    public int getTotalOrdersFilteredCount(String startDate, String endDate, String status, String keyword) {
        StringBuilder sql = new StringBuilder("""
                SELECT COUNT(*)
                FROM Orders
                WHERE 1=1
                """);
        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND OrderStatus = ?");
            params.add(status);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND OrderDate >= ?");
            params.add(startDate + " 00:00:00");
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND OrderDate <= ?");
            params.add(endDate + " 23:59:59");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String cleanKw = keyword.trim().replaceAll("(?i)^#?ORD-?", "");
            sql.append(" AND (CAST(OrderID AS VARCHAR) LIKE ? OR ShippingName LIKE ? OR ShippingPhone LIKE ?)");
            String kPattern = "%" + cleanKw + "%";
            params.add(kPattern);
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get paginated orders filtered by status and date range.
     */
    public List<Order> getOrdersFiltered(String startDate, String endDate, String status, int page, int pageSize) {
        return getOrdersFiltered(startDate, endDate, status, null, page, pageSize);
    }

    /**
     * Get paginated orders filtered by status, date range, and search keyword.
     */
    public List<Order> getOrdersFiltered(String startDate, String endDate, String status, String keyword, int page, int pageSize) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
                SELECT OrderID, CustomerID, TotalAmount,
                       ShippingName, ShippingPhone, ShippingAddress,
                       OrderStatus, OrderDate, UpdatedAt
                FROM Orders
                WHERE 1=1
                """);

        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND OrderStatus = ?");
            params.add(status);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND OrderDate >= ?");
            params.add(startDate + " 00:00:00");
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND OrderDate <= ?");
            params.add(endDate + " 23:59:59");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String cleanKw = keyword.trim().replaceAll("(?i)^#?ORD-?", "");
            sql.append(" AND (CAST(OrderID AS VARCHAR) LIKE ? OR ShippingName LIKE ? OR ShippingPhone LIKE ?)");
            String kPattern = "%" + cleanKw + "%";
            params.add(kPattern);
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        sql.append(" ORDER BY OrderDate DESC");
        if (pageSize > 0 && pageSize < Integer.MAX_VALUE) {
            sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            params.add((page - 1) * pageSize);
            params.add(pageSize);
        }

        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

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
