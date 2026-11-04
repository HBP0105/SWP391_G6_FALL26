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
        String sqlOrders = "SELECT o.OrderID, o.CustomerID, o.TotalAmount, o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.OrderStatus, "
                         + "CONVERT(VARCHAR(19), o.OrderDate, 120) AS FormattedDate, "
                         + "pay.PaymentMethod, pay.PaymentStatus "
                         + "FROM Orders o "
                         + "LEFT JOIN Payments pay ON o.OrderID = pay.OrderID "
                         + "WHERE o.CustomerID = ? "
                         + "ORDER BY o.OrderDate DESC, o.OrderID DESC";

        String sqlItems = "SELECT oi.ProductID, oi.Quantity, oi.UnitPrice, "
                        + "p.ProductName, p.Description, p.ConnectionType, p.DriverSize, "
                        + "p.NoiseCancelling, p.BatteryLife, p.Microphone, p.WaterResistance, p.Weight, "
                        + "c.CategoryName, b.BrandName, pi.ImageURL "
                        + "FROM OrderItems oi "
                        + "JOIN Products p ON oi.ProductID = p.ProductID "
                        + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                        + "LEFT JOIN Brands b ON p.BrandID = b.BrandID "
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
                order.setPaymentMethod(rsOrders.getString("PaymentMethod"));
                order.setPaymentStatus(rsOrders.getString("PaymentStatus"));

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
                    item.setDescription(rsItems.getString("Description"));
                    item.setCategoryName(rsItems.getString("CategoryName"));
                    item.setBrandName(rsItems.getString("BrandName"));
                    item.setConnectionType(rsItems.getString("ConnectionType"));
                    item.setDriverSize(rsItems.getDouble("DriverSize"));
                    item.setNoiseCancelling(rsItems.getBoolean("NoiseCancelling"));
                    item.setBatteryLife(rsItems.getInt("BatteryLife"));
                    item.setMicrophone(rsItems.getBoolean("Microphone"));
                    item.setWaterResistance(rsItems.getString("WaterResistance"));
                    item.setWeight(rsItems.getDouble("Weight"));
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
    
    /**
     * Cập nhật trạng thái đơn hàng và thanh toán sau khi VNPay phản hồi
     */
    public void updateVNPayStatus(int orderId, String transactionNo, String responseCode, boolean isSuccess){
        String sqlOrder = "UPDATE Orders SET OrderStatus = ?, UpdatedAt = GETDATE() WHERE OrderID = ?";
        String sqlPayment = "UPDATE Payments SET PaymentStatus = ?, TransactionID = ?, ResponseCode = ?, PaymentDate = GETDATE() WHERE OrderID = ?";
        Connection conn = null;
        try{
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // 1. Cập nhật bảng Orders (CONFIRMED nếu thành công, CANCELLED nếu hủy/lỗi)
            PreparedStatement psOrder = conn.prepareStatement(sqlOrder);
            psOrder.setString(1, isSuccess ? "CONFIRMED" : "CANCELLED");
            psOrder.setInt(2, orderId);
            psOrder.executeUpdate();
            
            // 2. Cập nhật bảng Payments (SUCCESS nếu thành công, FAILED nếu hủy/lỗi)
            PreparedStatement psPayment = conn.prepareStatement(sqlPayment);
            psPayment.setString(1, isSuccess ? "SUCCESS" : "FAILED");
            psPayment.setString(2, transactionNo);
            psPayment.setString(3, responseCode);
            psPayment.setInt(4, orderId);
            psPayment.executeUpdate();
            
            conn.commit();
        }catch(Exception e){
            e.printStackTrace();
            try{
                if(conn != null) conn.rollback();
            }catch(Exception ex){}
        }finally{
            try{
                if(conn != null) conn.setAutoCommit(true);
            }catch(Exception ex){}
        }
    }

    /**
     * Khách hàng tự hủy đơn hàng (Chỉ cho phép hủy khi đơn đang ở trạng thái PENDING hoặc CONFIRMED)
     */
    public boolean cancelOrder(int orderId, int customerId) {
        String sqlOrder = "UPDATE Orders SET OrderStatus = 'CANCELLED', UpdatedAt = GETDATE() "
                        + "WHERE OrderID = ? AND CustomerID = ? AND OrderStatus IN ('PENDING', 'CONFIRMED')";
        try {
            Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement(sqlOrder);
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy thông tin chi tiết của 1 đơn hàng cụ thể (Kèm thông tin Thanh toán, Vận đơn và Thông số sản phẩm)
     */
    public OrderDTO getOrderDetailById(int orderId, int customerId) {
        String sqlOrder = "SELECT o.OrderID, o.CustomerID, o.TotalAmount, o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.OrderStatus, "
                        + "CONVERT(VARCHAR(19), o.OrderDate, 120) AS FormattedDate, "
                        + "pay.PaymentMethod, pay.PaymentStatus, pay.TransactionID, "
                        + "CONVERT(VARCHAR(19), pay.PaymentDate, 120) AS FormattedPayDate, "
                        + "sh.ShippingProvider, sh.TrackingNumber, CONVERT(VARCHAR(10), sh.EstimatedDeliveryDate, 120) AS EstDelivery "
                        + "FROM Orders o "
                        + "LEFT JOIN Payments pay ON o.OrderID = pay.OrderID "
                        + "LEFT JOIN Shipments sh ON o.OrderID = sh.OrderID "
                        + "WHERE o.OrderID = ? AND o.CustomerID = ?";

        String sqlItems = "SELECT oi.ProductID, oi.Quantity, oi.UnitPrice, "
                        + "p.ProductName, p.Description, p.ConnectionType, p.DriverSize, "
                        + "p.NoiseCancelling, p.BatteryLife, p.Microphone, p.WaterResistance, p.Weight, "
                        + "c.CategoryName, b.BrandName, pi.ImageURL "
                        + "FROM OrderItems oi "
                        + "JOIN Products p ON oi.ProductID = p.ProductID "
                        + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                        + "LEFT JOIN Brands b ON p.BrandID = b.BrandID "
                        + "LEFT JOIN ProductImages pi ON p.ProductID = pi.ProductID AND pi.IsPrimary = 1 "
                        + "WHERE oi.OrderID = ?";

        try {
            Connection conn = getConnection();
            PreparedStatement psOrder = conn.prepareStatement(sqlOrder);
            psOrder.setInt(1, orderId);
            psOrder.setInt(2, customerId);
            ResultSet rsOrder = psOrder.executeQuery();

            if (rsOrder.next()) {
                OrderDTO order = new OrderDTO();
                order.setOrderId(rsOrder.getInt("OrderID"));
                order.setCustomerId(rsOrder.getInt("CustomerID"));
                order.setTotalAmount(rsOrder.getDouble("TotalAmount"));
                order.setShippingName(rsOrder.getString("ShippingName"));
                order.setShippingPhone(rsOrder.getString("ShippingPhone"));
                order.setShippingAddress(rsOrder.getString("ShippingAddress"));
                order.setOrderStatus(rsOrder.getString("OrderStatus"));
                order.setOrderDate(rsOrder.getString("FormattedDate"));
                order.setPaymentMethod(rsOrder.getString("PaymentMethod"));
                order.setPaymentStatus(rsOrder.getString("PaymentStatus"));
                order.setTransactionId(rsOrder.getString("TransactionID"));
                order.setPaymentDate(rsOrder.getString("FormattedPayDate"));
                order.setShippingProvider(rsOrder.getString("ShippingProvider"));
                order.setTrackingNumber(rsOrder.getString("TrackingNumber"));
                order.setEstimatedDeliveryDate(rsOrder.getString("EstDelivery"));

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
                    item.setDescription(rsItems.getString("Description"));
                    item.setCategoryName(rsItems.getString("CategoryName"));
                    item.setBrandName(rsItems.getString("BrandName"));
                    item.setConnectionType(rsItems.getString("ConnectionType"));
                    item.setDriverSize(rsItems.getDouble("DriverSize"));
                    item.setNoiseCancelling(rsItems.getBoolean("NoiseCancelling"));
                    item.setBatteryLife(rsItems.getInt("BatteryLife"));
                    item.setMicrophone(rsItems.getBoolean("Microphone"));
                    item.setWaterResistance(rsItems.getString("WaterResistance"));
                    item.setWeight(rsItems.getDouble("Weight"));
                    items.add(item);
                }
                order.setItems(items);
                return order;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
