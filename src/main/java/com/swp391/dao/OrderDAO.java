package com.swp391.dao;

import com.swp391.model.Address;
import com.swp391.model.Customer;
import com.swp391.model.Order;
import com.swp391.model.OrderItem;
import com.swp391.model.Payment;
import com.swp391.model.Shipment;
import com.swp391.util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class OrderDAO {

    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());
    private final DBContext dbContext;

    public OrderDAO() {
        this.dbContext = new DBContext();
    }

    // =========================================================================
    // 1. RESULT SET MAPPING HELPER (Exception-safe column extraction)
    // =========================================================================
    private String getCol(ResultSet rs, String col) {
        try {
            return rs.getString(col);
        } catch (Exception e) {
            return null;
        }
    }

    private int getColInt(ResultSet rs, String col) {
        try {
            return rs.getInt(col);
        } catch (Exception e) {
            return 0;
        }
    }

    private BigDecimal getColBigDecimal(ResultSet rs, String col) {
        try {
            BigDecimal val = rs.getBigDecimal(col);
            return val != null ? val : BigDecimal.ZERO;
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    private Timestamp getColTimestamp(ResultSet rs, String col) {
        try {
            return rs.getTimestamp(col);
        } catch (Exception e) {
            return null;
        }
    }

    private java.sql.Date getColDate(ResultSet rs, String col) {
        try {
            return rs.getDate(col);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Maps ResultSet row to Order model safely. Reads joined sub-entities if
     * present.
     */
    private Order mapOrder(ResultSet rs, boolean isDetail) throws SQLException {
        Order order = new Order();
        order.setOrderID(getColInt(rs, "OrderID"));
        order.setCustomerID(getColInt(rs, "CustomerID"));
        order.setTotalAmount(getColBigDecimal(rs, "TotalAmount"));
        order.setOrderStatus(getCol(rs, "OrderStatus"));
        order.setShippingName(getCol(rs, "ShippingName"));
        order.setShippingPhone(getCol(rs, "ShippingPhone"));
        order.setShippingAddress(getCol(rs, "ShippingAddress"));

        Timestamp oDate = getColTimestamp(rs, "OrderDate");
        if (oDate != null) {
            order.setOrderDate(oDate.toLocalDateTime());
        }

        Timestamp uDate = getColTimestamp(rs, "UpdatedAt");
        if (uDate != null) {
            order.setUpdatedAt(uDate.toLocalDateTime());
        }

        order.setCancelReason(getCol(rs, "CancelReason"));

        // 1. Customer Mapping
        String custName = getCol(rs, "CustFullName");
        String custPhone = getCol(rs, "CustPhone");
        if (custName != null || custPhone != null || order.getCustomerID() > 0) {
            Customer c = new Customer();
            c.setCustomerID(order.getCustomerID());
            c.setFullName(custName);
            c.setPhone(custPhone);
            c.setEmail(getCol(rs, "CustEmail"));
            order.setCustomer(c);
        }

        // 2. Payment Mapping
        String pMethod = getCol(rs, "PaymentMethod");
        String pStatus = getCol(rs, "PaymentStatus");
        int paymentId = getColInt(rs, "PaymentID");
        if (pMethod != null || pStatus != null || paymentId > 0) {
            Payment p = new Payment();
            p.setPaymentID(paymentId);
            p.setOrderID(order.getOrderID());
            p.setPaymentMethod(pMethod);
            p.setPaymentStatus(pStatus);
            p.setTransactionID(getCol(rs, "TransactionID"));

            Timestamp pDate = getColTimestamp(rs, "PaymentDate");
            if (pDate != null) {
                p.setPaymentDate(pDate.toLocalDateTime());
            }
            order.setPayment(p);
        }

        // 3. Shipment Mapping
        String provider = getCol(rs, "ShippingProvider");
        String tracking = getCol(rs, "TrackingNumber");
        int shipmentId = getColInt(rs, "ShipmentID");
        if (provider != null || tracking != null || shipmentId > 0) {
            Shipment s = new Shipment();
            s.setShipmentID(shipmentId);
            s.setOrderID(order.getOrderID());
            s.setShippingProvider(provider);
            s.setTrackingNumber(tracking);
            s.setShippingStatus(getCol(rs, "ShippingStatus"));

            java.sql.Date estDate = getColDate(rs, "EstimatedDeliveryDate");
            if (estDate != null) {
                s.setEstimatedDeliveryDate(estDate.toLocalDate());
            }
            Timestamp sAt = getColTimestamp(rs, "ShippedAt");
            if (sAt != null) {
                s.setShippedAt(sAt.toLocalDateTime());
            }
            Timestamp dAt = getColTimestamp(rs, "DeliveredAt");
            if (dAt != null) {
                s.setDeliveredAt(dAt.toLocalDateTime());
            }

            order.setShipment(s);
        }

        // 4. Address Mapping (Detail Screen only)
        if (isDetail) {
            String recName = getCol(rs, "AddrReceiverName");
            String recPhone = getCol(rs, "AddrReceiverPhone");
            String addrLine = getCol(rs, "AddressLine");
            if (recName == null && order.getCustomer() != null) {
                recName = order.getCustomer().getFullName();
            }
            if (recPhone == null && order.getCustomer() != null) {
                recPhone = order.getCustomer().getPhone();
            }
            if (addrLine == null) {
                addrLine = order.getShippingAddress();
            }

            Address a = new Address();
            a.setCustomerID(order.getCustomerID());
            a.setReceiverName(recName);
            a.setReceiverPhone(recPhone);
            a.setAddressLine(addrLine);
            order.setAddress(a);
        }

        // 5. Order Summary (TotalQuantity & ProductSummary)
        order.setTotalQuantity(getColInt(rs, "TotalQuantity"));
        String pSummary = getCol(rs, "ProductSummary");
        order.setProductSummary(pSummary != null && !pSummary.trim().isEmpty() ? pSummary : "Tai nghe");

        return order;
    }

    // =========================================================================
    // 2. SCREEN 1: ORDER LIST (PAGINATION, FILTERS & METRIC CARDS)
    // =========================================================================
    private String getOrderListQuery() {
        return """
                SELECT o.OrderID, o.CustomerID, o.TotalAmount, o.OrderDate, o.OrderStatus, o.UpdatedAt, o.CancelReason,
                       o.ShippingName, o.ShippingPhone, o.ShippingAddress,
                       c.FullName AS CustFullName, c.Phone AS CustPhone, c.Email AS CustEmail,
                       p.PaymentID, p.PaymentMethod, p.PaymentStatus,
                       (SELECT COALESCE(SUM(oi.Quantity), 0) FROM OrderItems oi WHERE oi.OrderID = o.OrderID) AS TotalQuantity,
                       (SELECT COALESCE(STRING_AGG(prod.ProductName, ', '), 'Tai nghe') FROM OrderItems oi 
                JOIN Products prod ON oi.ProductID = prod.ProductID WHERE oi.OrderID = o.OrderID) AS ProductSummary
                FROM Orders o
                LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
                LEFT JOIN Payments p ON o.OrderID = p.OrderID
                """;
    }

    private void applyFilters(StringBuilder sql, List<Object> params,
            String startDate, String endDate, String status, String keyword) {
        // 1. Loc theo trang thai don hang (PENDING, SHIPPING, DELIVERED,...)
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND o.OrderStatus = ?");
            params.add(status.trim());
        }

        // 2. Loc tu ngay
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND o.OrderDate >= ?");
            params.add(startDate.trim());
        }

        // 3. Loc den ngay
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND o.OrderDate < ?");
            params.add(endDate.trim());
        }

        // 4. Tim kiem tu khoa theo Ma don, Ten khach hang hoac So dien thoai
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (CAST(o.OrderID AS VARCHAR) LIKE ? OR c.FullName LIKE ? OR c.Phone LIKE ?)");
            String pattern = "%" + keyword.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
    }

    public Map<String, Integer> getOrderStatusCountsMap(String startDate, String endDate) {
        Map<String, Integer> map = new HashMap<>();
        for (String st : java.util.List.of("PENDING", "CONFIRMED", "SHIPPING", "DELIVERED", "CANCELLED")) {
            map.put(st, 0);
        }

        StringBuilder sql = new StringBuilder("SELECT o.OrderStatus, COUNT(o.OrderID) AS Qty FROM Orders o WHERE 1=1");
        List<Object> params = new ArrayList<>();
        applyFilters(sql, params, startDate, endDate, null, null);
        sql.append(" GROUP BY o.OrderStatus");

        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String st = rs.getString("OrderStatus");
                    if (st != null) {
                        map.put(st, rs.getInt("Qty"));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error calculating status counts", e);
        }
        return map;
    }

    public int getTotalOrdersFilteredCount(String startDate, String endDate, String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(o.OrderID) FROM Orders o "
                + "LEFT JOIN Customers c ON o.CustomerID = c.CustomerID WHERE 1=1");
        List<Object> params = new ArrayList<>();
        applyFilters(sql, params, startDate, endDate, status, keyword);

        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error counting filtered orders", e);
        }
        return 0;
    }

    public List<Order> getOrdersFiltered(String startDate, String endDate, String status,
            String keyword, int page, int pageSize) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(getOrderListQuery()).append(" WHERE 1=1");
        List<Object> params = new ArrayList<>();
        applyFilters(sql, params, startDate, endDate, status, keyword);

        sql.append(" ORDER BY o.OrderDate DESC, o.OrderID DESC");
        if (pageSize > 0) {
            int currentPage = Math.max(page, 1);
            sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            params.add((currentPage - 1) * pageSize);
            params.add(pageSize);
        }

        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapOrder(rs, false);
                    orders.add(order);
                }
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching filtered orders", e);
        }
        return orders;
    }

    // =========================================================================
    // 3. SCREEN 2: ORDER DETAIL & ITEMS
    // =========================================================================
    private String getOrderDetailQuery() {
        return """
                SELECT o.OrderID, o.CustomerID, o.TotalAmount, o.ShippingName, o.ShippingPhone, o.ShippingAddress, 
                       o.OrderStatus, o.CancelReason, o.OrderDate, o.UpdatedAt,
                       c.FullName AS CustFullName, c.Phone AS CustPhone, c.Email AS CustEmail,
                       a.ReceiverName AS AddrReceiverName, a.ReceiverPhone AS AddrReceiverPhone, a.AddressLine,
                       s.ShippingProvider, s.TrackingNumber, s.EstimatedDeliveryDate, s.ShippedAt, s.DeliveredAt,
                       p.PaymentMethod, p.PaymentStatus,
                       oi.OrderItemID, oi.ProductID, oi.Quantity, oi.UnitPrice,
                       prod.ProductName
                FROM Orders o
                LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
                LEFT JOIN Addresses a ON o.CustomerID = a.CustomerID AND a.IsDefault = 1
                LEFT JOIN Shipments s ON o.OrderID = s.OrderID
                LEFT JOIN Payments p ON o.OrderID = p.OrderID
                LEFT JOIN OrderItems oi ON o.OrderID = oi.OrderID
                LEFT JOIN Products prod ON oi.ProductID = prod.ProductID
                WHERE o.OrderID = ?
                ORDER BY oi.OrderItemID ASC
                """;
    }

    public Map<String, Object> getOrderDetailWithJoin(int orderID) {
        if (orderID <= 0) {
            throw new IllegalArgumentException("Invalid orderID");
        }
        Map<String, Object> map = new HashMap<>();
        Order order = null;
        List<OrderItem> items = new ArrayList<>();

        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(getOrderDetailQuery())) {
            ps.setInt(1, orderID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (order == null) {
                        order = mapOrder(rs, true);
                    }
                    int orderItemId = rs.getInt("OrderItemID");
                    if (orderItemId > 0) {
                        OrderItem item = new OrderItem();
                        item.setOrderItemID(orderItemId);
                        item.setOrderID(order.getOrderID());
                        item.setProductID(rs.getInt("ProductID"));
                        item.setQuantity(rs.getInt("Quantity"));
                        item.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                        String pName = rs.getString("ProductName");
                        item.setProductName(pName != null ? pName : "Product #" + item.getProductID());
                        items.add(item);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching order detail #" + orderID, e);
        }

        if (order == null) {
            return null;
        }
        map.put("order", order);
        map.put("items", items);
        return map;
    }

    // =========================================================================
    // 4. ATOMIC DATABASE TRANSACTIONS (REFACTORED - TEACHER'S CRITERIA)
    // =========================================================================
    // -------------------------------------------------------------------------
    // TRANSACTION 1: UPDATE ORDER + SHIPMENT + COD PAYMENT
    // -------------------------------------------------------------------------
    public boolean updateOrderStatusWithShipmentAndPayment(int orderID, String expectedCurrentStatus, String newStatus,
            String cancelReason, String shippingProvider, String trackingNumber, String shipperName, String shipperPhone) {

        Connection conn = null;
        boolean committed = false;

        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false);

            String oldStatus = normalizeStatus(expectedCurrentStatus);
            String targetStatus = normalizeStatus(newStatus);

            updateOrderRecord(conn, orderID, oldStatus, targetStatus, shipperName, shipperPhone);

            if ("SHIPPING".equals(targetStatus)) {
                handleShippingTransition(conn, orderID, shippingProvider, trackingNumber);
            } else if ("DELIVERED".equals(targetStatus)) {
                handleDeliveryTransition(conn, orderID);
            }

            conn.commit();
            committed = true;
            return true;

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Transaction error updating order #" + orderID, e);
            return false;
        } finally {
            closeTransactionConnection(conn, committed);
        }
    }

    private String normalizeStatus(String status) throws SQLException {
        if (status == null || status.isBlank()) {
            throw new SQLException("Order status must not be empty.");
        }
        return status.trim().toUpperCase(java.util.Locale.ROOT);
    }

    private void updateOrderRecord(Connection conn, int orderId, String expectedStatus, String newStatus,
            String shipperName, String shipperPhone) throws SQLException {

        if (expectedStatus == null || expectedStatus.isBlank()) {
            throw new SQLException("Bắt buộc phải có trạng thái hiện tại (expectedStatus) để cập nhật đơn #" + orderId);
        }

        boolean hasShipper = shipperName != null && !shipperName.isBlank();

        String sql = hasShipper
                ? """
                  UPDATE Orders 
                  SET OrderStatus = ?, ShippingName = ?, ShippingPhone = ?, UpdatedAt = GETDATE() 
                  WHERE OrderID = ? AND OrderStatus = ?
                  """
                : """
                  UPDATE Orders 
                  SET OrderStatus = ?, UpdatedAt = GETDATE() 
                  WHERE OrderID = ? AND OrderStatus = ?
                  """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            ps.setString(i++, newStatus);

            if (hasShipper) {
                ps.setString(i++, shipperName.trim());
                ps.setString(i++, shipperPhone == null || shipperPhone.isBlank() ? null : shipperPhone.trim());
            }

            ps.setInt(i++, orderId);
            ps.setString(i++, expectedStatus);

            if (ps.executeUpdate() != 1) {
                throw new SQLException("Đơn hàng #" + orderId + " đã bị thay đổi trạng thái hoặc không tìm thấy!");
            }
        }
    }

    private void handleShippingTransition(Connection conn, int orderId, String provider, String tracking) throws SQLException {

        String shippingProviderValue = provider == null || provider.isBlank() ? "Giao Hàng Nhanh (GHN)" : provider.trim();

        if (tracking == null || tracking.isBlank()) {
            throw new SQLException("Tracking number must be generated by Service before shipping.");
        }

        String sql = """
                IF EXISTS (
                    SELECT 1 FROM Shipments WITH (UPDLOCK, HOLDLOCK) WHERE OrderID = ?
                )
                BEGIN
                    UPDATE Shipments
                    SET ShippingProvider = ?,
                        TrackingNumber = ?,
                        ShippingStatus = 'SHIPPING',
                        ShippedAt = ISNULL(ShippedAt, GETDATE())
                    WHERE OrderID = ?
                END
                ELSE
                BEGIN
                    INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingStatus, ShippedAt)
                    VALUES (?, ?, ?, 'SHIPPING', GETDATE())
                END
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, shippingProviderValue);
            ps.setString(3, tracking.trim());
            ps.setInt(4, orderId);
            ps.setInt(5, orderId);
            ps.setString(6, shippingProviderValue);
            ps.setString(7, tracking.trim());
            ps.executeUpdate();
        }
    }

    private void handleDeliveryTransition(Connection conn, int orderId) throws SQLException {

        String shipmentSql = """
                UPDATE Shipments
                SET ShippingStatus = 'DELIVERED',
                    DeliveredAt = ISNULL(DeliveredAt, GETDATE())
                WHERE OrderID = ? AND ShippingStatus = 'SHIPPING'
                """;

        try (PreparedStatement ps = conn.prepareStatement(shipmentSql)) {
            ps.setInt(1, orderId);
            if (ps.executeUpdate() != 1) {
                throw new SQLException("Shipment not found or not in SHIPPING state for order #" + orderId);
            }
        }

        String paymentSql = """
                UPDATE Payments
                SET PaymentStatus = 'SUCCESS',
                    PaymentDate = ISNULL(PaymentDate, GETDATE())
                WHERE OrderID = ?
                  AND PaymentMethod = 'COD'
                  AND (PaymentStatus IS NULL OR PaymentStatus <> 'SUCCESS')
                """;

        try (PreparedStatement ps = conn.prepareStatement(paymentSql)) {
            ps.setInt(1, orderId);
            ps.executeUpdate();
        }
    }

    // -------------------------------------------------------------------------
    // TRANSACTION 2: CANCEL ORDER + RESTORE STOCK + INVENTORY LOG
    // -------------------------------------------------------------------------
    public boolean cancelOrderWithStockRestoration(int orderID, String expectedCurrentStatus, String cancelReason,
            List<OrderItem> items) {

        if (items == null || items.isEmpty()) {
            LOGGER.log(Level.WARNING, "No items provided to restore stock for order #" + orderID);
            return false;
        }

        Connection conn = null;
        boolean committed = false;

        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false);

            updateOrderAsCancelled(conn, orderID, expectedCurrentStatus, cancelReason);

            restoreStockAndLogFromItems(conn, orderID, cancelReason, items);

            conn.commit();
            committed = true;
            return true;

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Transaction error cancelling order #" + orderID, e);
            return false;
        } finally {
            closeTransactionConnection(conn, committed);
        }
    }

    private void updateOrderAsCancelled(Connection conn, int orderId, String expectedCurrentStatus,
            String cancelReason) throws SQLException {

        String status = normalizeStatus(expectedCurrentStatus);

        String sql = """
                UPDATE Orders
                SET OrderStatus = 'CANCELLED',
                    CancelReason = ?,
                    UpdatedAt = GETDATE()
                WHERE OrderID = ?
                  AND OrderStatus = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cancelReason != null ? cancelReason.trim() : "");
            ps.setInt(2, orderId);
            ps.setString(3, status);

            if (ps.executeUpdate() != 1) {
                throw new SQLException("Không thể hủy đơn #" + orderId + ": Đã thay đổi trạng thái hoặc không tìm thấy.");
            }
        }

        String updateShipmentSql = """
                UPDATE Shipments
                SET ShippingStatus = 'FAILED'
                WHERE OrderID = ? AND (ShippingStatus IS NULL OR ShippingStatus <> 'DELIVERED')
                """;
        try (PreparedStatement psShip = conn.prepareStatement(updateShipmentSql)) {
            psShip.setInt(1, orderId);
            psShip.executeUpdate();
        }

        String updatePaymentSql = """
                UPDATE Payments
                SET PaymentStatus = 'CANCELLED'
                WHERE OrderID = ? AND (PaymentStatus IS NULL OR PaymentStatus <> 'SUCCESS')
                """;
        try (PreparedStatement psPay = conn.prepareStatement(updatePaymentSql)) {
            psPay.setInt(1, orderId);
            psPay.executeUpdate();
        }
    }

    private void restoreStockAndLogFromItems(Connection conn, int orderId, String cancelReason,
            List<OrderItem> items) throws SQLException {

        Map<Integer, Integer> aggregatedItems = new java.util.LinkedHashMap<>();
        for (OrderItem item : items) {
            aggregatedItems.merge(item.getProductID(), item.getQuantity(), Math::addExact);
        }

        String sql = """
                DECLARE @StockChange TABLE (
                    ProductID INT,
                    PreviousQuantity INT,
                    NewQuantity INT
                );

                UPDATE Products
                SET StockQuantity = StockQuantity + ?
                OUTPUT
                    inserted.ProductID,
                    deleted.StockQuantity,
                    inserted.StockQuantity
                INTO @StockChange (ProductID, PreviousQuantity, NewQuantity)
                WHERE ProductID = ?;

                IF @@ROWCOUNT <> 1
                    THROW 50001, 'Product not found while restoring stock.', 1;

                INSERT INTO InventoryTransactions (
                    ProductID,
                    TransactionType,
                    Quantity,
                    PreviousQuantity,
                    NewQuantity,
                    Reason,
                    CreatedAt
                )
                SELECT
                    ProductID,
                    'RETURN',
                    ?,
                    PreviousQuantity,
                    NewQuantity,
                    ?,
                    GETDATE()
                FROM @StockChange;
                """;

        String reason = "Cancelled Order #ORD-" + orderId
                + " (" + (cancelReason == null ? "" : cancelReason.trim()) + ")";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Map.Entry<Integer, Integer> entry : aggregatedItems.entrySet()) {
                int productId = entry.getKey();
                int totalQuantity = entry.getValue();

                ps.setInt(1, totalQuantity);
                ps.setInt(2, productId);
                ps.setInt(3, totalQuantity);
                ps.setString(4, reason);
                ps.execute();
            }
        }
    }

    // -------------------------------------------------------------------------
    // SHARED HELPER: ĐÓNG KẾT NỐI VÀ QUẢN LÝ POOL AN TOÀN TUYỆT ĐỐI
    // -------------------------------------------------------------------------
    private void closeTransactionConnection(Connection conn, boolean committed) {
        if (conn == null) {
            return;
        }
        try {
            if (!committed && !conn.isClosed()) {
                conn.rollback();
            }
            if (!conn.isClosed()) {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to restore connection state", e);
        } finally {
            try {
                conn.close(); // Chắc chắn 100% trả kết nối về pool
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Failed to close database connection", e);
            }
        }
    }

    public List<Map<String, Object>> getAIRecommendationsForOrder(int customerId, int orderId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sqlWithCustomer = """
                SELECT TOP 3 
                  r.RecommendationID, r.ProductID, p.ProductName, p.Price, pi.ImageURL, 
                  r.SimilarityScore, r.Reason, r.RecommendationType, 
                  c.CategoryName, b.BrandName 
                FROM AIRecommendations r 
                LEFT JOIN (
                    SELECT TOP 1 MinSimilarityThreshold 
                    FROM AIConfigurations 
                    ORDER BY ConfigID DESC
                ) cfg ON 1=1 
                JOIN Products p ON r.ProductID = p.ProductID 
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID 
                LEFT JOIN Brands b ON p.BrandID = b.BrandID 
                LEFT JOIN ProductImages pi ON p.ProductID = pi.ProductID AND pi.IsPrimary = 1 
                WHERE r.CustomerID = ? 
                  AND (cfg.MinSimilarityThreshold IS NULL OR r.SimilarityScore >= cfg.MinSimilarityThreshold) 
                ORDER BY ISNULL(r.FinalScore, r.SimilarityScore) DESC, r.SimilarityScore DESC, r.CreatedAt DESC
                """;

        String fallbackSql = """
                SELECT TOP 3 
                  r.RecommendationID, r.ProductID, p.ProductName, p.Price, pi.ImageURL, 
                  r.SimilarityScore, r.Reason, r.RecommendationType, 
                  c.CategoryName, b.BrandName 
                FROM AIRecommendations r 
                LEFT JOIN (
                    SELECT TOP 1 MinSimilarityThreshold 
                    FROM AIConfigurations 
                    ORDER BY ConfigID DESC
                ) cfg ON 1=1 
                JOIN Products p ON r.ProductID = p.ProductID 
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID 
                LEFT JOIN Brands b ON p.BrandID = b.BrandID 
                LEFT JOIN ProductImages pi ON p.ProductID = pi.ProductID AND pi.IsPrimary = 1 
                WHERE (cfg.MinSimilarityThreshold IS NULL OR r.SimilarityScore >= cfg.MinSimilarityThreshold) 
                ORDER BY ISNULL(r.FinalScore, r.SimilarityScore) DESC, r.SimilarityScore DESC, r.CreatedAt DESC
                """;

        try (Connection conn = dbContext.getConnection()) {
            boolean hasCustomerRecs = false;
            if (customerId > 0) {
                try (PreparedStatement ps = conn.prepareStatement(sqlWithCustomer)) {
                    ps.setInt(1, customerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            hasCustomerRecs = true;
                            list.add(mapAIRecRow(rs));
                        }
                    }
                }
            }

            if (!hasCustomerRecs) {
                try (PreparedStatement psFallback = conn.prepareStatement(fallbackSql); ResultSet rs = psFallback.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapAIRecRow(rs));
                    }
                }
            }

            // Fallback sang sản phẩm đang Active nếu bảng AIRecommendations chưa có dữ liệu
            if (list.isEmpty()) {
                String activeProductsSql = """
                        SELECT TOP 3 
                          0 AS RecommendationID, p.ProductID, p.ProductName, p.Price, pi.ImageURL, 
                          0.88 AS SimilarityScore, 
                          N'Similar headphone model recommended for customer retention call' AS Reason, 
                          'ALTERNATIVE' AS RecommendationType, 
                          c.CategoryName, b.BrandName 
                        FROM Products p 
                        LEFT JOIN Categories c ON p.CategoryID = c.CategoryID 
                        LEFT JOIN Brands b ON p.BrandID = b.BrandID 
                        LEFT JOIN ProductImages pi ON p.ProductID = pi.ProductID AND pi.IsPrimary = 1 
                        WHERE p.Status = 'ACTIVE' 
                        ORDER BY p.ProductID DESC
                        """;
                try (PreparedStatement psAct = conn.prepareStatement(activeProductsSql); ResultSet rsAct = psAct.executeQuery()) {
                    while (rsAct.next()) {
                        list.add(mapAIRecRow(rsAct));
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading AI Recommendations for customer #" + customerId, e);
        }
        return list;
    }

    private Map<String, Object> mapAIRecRow(ResultSet rs) throws SQLException {
        Map<String, Object> map = new HashMap<>();
        map.put("recommendationID", rs.getLong("RecommendationID"));
        map.put("productID", rs.getInt("ProductID"));
        map.put("productName", rs.getString("ProductName"));
        map.put("price", rs.getBigDecimal("Price"));
        map.put("imageUrl", rs.getString("ImageURL"));

        BigDecimal sim = rs.getBigDecimal("SimilarityScore");
        double rawVal = sim != null ? sim.doubleValue() : 0.0;
        double simPercent = rawVal <= 1.0 ? rawVal * 100.0 : rawVal;
        map.put("similarityScore", simPercent);
        map.put("similarityPercent", String.format(java.util.Locale.US, "%.1f", simPercent));

        map.put("reason", rs.getString("Reason"));
        map.put("recommendationType", rs.getString("RecommendationType"));
        map.put("categoryName", rs.getString("CategoryName"));
        map.put("brandName", rs.getString("BrandName"));
        return map;
    }
}
