package com.swp391.dao;

import com.swp391.model.CartItemDTO;
import com.swp391.model.OrderDTO;
import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class OrderDAO extends DBContext {

    public int placeOrder(int customerId, Map<Integer, CartItemDTO> cart, 
                          String address, String payment, String notes) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Bật Transaction

            // 1. Tính tổng tiền
            double totalAmount = 0;
            for (CartItemDTO item : cart.values()) {
                totalAmount += (item.getPrice() * item.getQuantity());
            }

            // 2. Chèn vào bảng Orders
            String sqlOrder = "INSERT INTO Orders (CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, OrderDate) "
                            + "VALUES (?, ?, ?, ?, ?, 'PENDING', GETDATE())";
            PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, customerId);
            psOrder.setDouble(2, totalAmount);
            psOrder.setString(3, "Unassigned"); // Default shipper awaiting assignment
            psOrder.setString(4, "N/A");             // SĐT Shipper
            psOrder.setString(5, address);          // Địa chỉ khách nhận hàng
            psOrder.executeUpdate();

            // Lấy ra mã OrderID vừa sinh
            ResultSet rs = psOrder.getGeneratedKeys();
            int orderId = 0;
            if (rs.next()) {
                orderId = rs.getInt(1);
            }

            // 3. Chèn vào bảng OrderItems bằng Batch
            String sqlItem = "INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES (?, ?, ?, ?)";
            PreparedStatement psItem = conn.prepareStatement(sqlItem);
            for (CartItemDTO item : cart.values()) {
                psItem.setInt(1, orderId);
                psItem.setInt(2, item.getProductId());
                psItem.setInt(3, item.getQuantity());
                psItem.setDouble(4, item.getPrice());
                psItem.addBatch();
            }
            psItem.executeBatch();

            // 4. Chèn vào bảng Payments
            String sqlPayment = "INSERT INTO Payments (OrderID, PaymentMethod, Amount, PaymentStatus, PaymentDate) "
                              + "VALUES (?, ?, ?, 'PENDING', GETDATE())";
            PreparedStatement psPayment = conn.prepareStatement(sqlPayment);
            psPayment.setInt(1, orderId);
            psPayment.setString(2, (payment != null && !payment.trim().isEmpty()) ? payment : "COD");
            psPayment.setDouble(3, totalAmount);
            psPayment.executeUpdate();

            // Lưu vĩnh viễn (Commit)
            conn.commit();
            return orderId;

        } catch (Exception e) {
            e.printStackTrace();
            try { 
                if (conn != null) conn.rollback(); 
            } catch (Exception ex) {}
            return 0;
        } finally {
            try { 
                if (conn != null) conn.setAutoCommit(true); 
            } catch (Exception ex) {}
        }
    }

    /**
     * Lấy toàn bộ đơn hàng của một Customer kèm danh sách sản phẩm bên trong
     */
    public List<OrderDTO> getOrdersByCustomerId(int customerId) {
        List<OrderDTO> list = new ArrayList<>();
        String sqlOrders = "SELECT OrderID, CustomerID, TotalAmount, ShippingName, ShippingPhone, ShippingAddress, OrderStatus, "
                         + "CONVERT(VARCHAR(19), OrderDate, 120) AS FormattedDate "
                         + "FROM Orders "
                         + "WHERE CustomerID = ? "
                         + "ORDER BY OrderDate DESC, OrderID DESC";

        String sqlItems = "SELECT oi.ProductID, oi.Quantity, oi.UnitPrice, p.ProductName, pi.ImageURL "
                        + "FROM OrderItems oi "
                        + "JOIN Products p ON oi.ProductID = p.ProductID "
                        + "LEFT JOIN ProductImages pi ON p.ProductID = pi.ProductID AND pi.IsPrimary = 1 "
                        + "WHERE oi.OrderID = ?";

        try {
            Connection conn = getConnection();
            PreparedStatement psOrders = conn.prepareStatement(sqlOrders);
            psOrders.setInt(1, customerId);
            ResultSet rsOrders = psOrders.executeQuery();

            while (rsOrders.next()) {
                OrderDTO order = new OrderDTO();
                int orderId = rsOrders.getInt("OrderID");
                order.setOrderId(orderId);
                order.setCustomerId(rsOrders.getInt("CustomerID"));
                order.setTotalAmount(rsOrders.getDouble("TotalAmount"));
                order.setShippingName(rsOrders.getString("ShippingName"));
                order.setShippingPhone(rsOrders.getString("ShippingPhone"));
                order.setShippingAddress(rsOrders.getString("ShippingAddress"));
                order.setOrderStatus(rsOrders.getString("OrderStatus"));
                order.setOrderDate(rsOrders.getString("FormattedDate"));

                // Lấy danh sách sản phẩm của từng đơn hàng
                PreparedStatement psItems = conn.prepareStatement(sqlItems);
                psItems.setInt(1, orderId);
                ResultSet rsItems = psItems.executeQuery();
                List<CartItemDTO> items = new ArrayList<>();
                while (rsItems.next()) {
                    CartItemDTO item = new CartItemDTO();
                    item.setProductId(rsItems.getInt("ProductID"));
                    item.setProductName(rsItems.getString("ProductName"));
                    item.setQuantity(rsItems.getInt("Quantity"));
                    item.setPrice(rsItems.getDouble("UnitPrice"));
                    item.setImageUrl(rsItems.getString("ImageURL"));
                    items.add(item);
                }
                order.setItems(items);
                list.add(order);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
