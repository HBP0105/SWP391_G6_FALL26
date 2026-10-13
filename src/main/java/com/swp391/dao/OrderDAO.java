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
            a.setAddressID(getColInt(rs, "AddressID"));
            a.setCustomerID(order.getCustomerID());
            a.setReceiverName(recName);
            a.setReceiverPhone(recPhone);
            a.setAddressLine(addrLine);
            a.setWard(getCol(rs, "Ward"));
            a.setDistrict(getCol(rs, "District"));
            a.setProvince(getCol(rs, "Province"));
            order.setAddress(a);
        }

        // 5. Product Summary & Quantity
        order.setProductSummary(getCol(rs, "ProductSummary"));
        order.setTotalQuantity(getColInt(rs, "TotalQuantity"));
        if (order.getProductSummary() == null || order.getProductSummary().trim().isEmpty()) {
            order.setProductSummary("Don't Product Information!");
        }

        return order;
    }

    // =========================================================================
    // 2. SCREEN 1: ORDER LIST (PAGINATION, FILTERS & METRIC CARDS)
    // =========================================================================
    private String getOrderListQuery() {
        return """
                SELECT o.OrderID, o.CustomerID,
                       COALESCE(o.TotalAmount, oi.CalcTotalAmount) AS TotalAmount, 
                       o.OrderDate, o.OrderStatus, o.UpdatedAt, o.CancelReason,
                       o.ShippingName, o.ShippingPhone, o.ShippingAddress,
                       c.FullName AS CustFullName, c.Phone AS CustPhone, c.Email AS CustEmail,
                       p.PaymentID, p.PaymentMethod, p.PaymentStatus,
                       s.ShipmentID, s.ShippingProvider, s.TrackingNumber, s.ShippingStatus,
                       COALESCE(oi.ProductSummary, 'Headphone Product') AS ProductSummary,
                       COALESCE(oi.CalcTotalQuantity, 0) AS TotalQuantity
                FROM Orders o
                LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
                LEFT JOIN (
                    SELECT p1.OrderID, p1.PaymentID, p1.PaymentMethod, p1.PaymentStatus
                    FROM Payments p1
                    INNER JOIN (SELECT OrderID, MAX(PaymentID) AS MaxID FROM Payments GROUP BY OrderID) p2 
                    ON p1.PaymentID = p2.MaxID
                ) p ON o.OrderID = p.OrderID
                LEFT JOIN (
                    SELECT s1.OrderID, s1.ShipmentID, s1.ShippingProvider, s1.TrackingNumber, s1.ShippingStatus
                    FROM Shipments s1
                    INNER JOIN (SELECT OrderID, MAX(ShipmentID) AS MaxID FROM Shipments GROUP BY OrderID) s2 
                    ON s1.ShipmentID = s2.MaxID
                ) s ON o.OrderID = s.OrderID
                LEFT JOIN (
                    SELECT oi.OrderID,
                           SUM(oi.Quantity * oi.UnitPrice) AS CalcTotalAmount,
                           SUM(oi.Quantity) AS CalcTotalQuantity,
                           STRING_AGG(COALESCE(pr.ProductName, CONCAT('Product #', oi.ProductID)), ', ') AS ProductSummary
                    FROM OrderItems oi
                    LEFT JOIN Products pr ON oi.ProductID = pr.ProductID
                    GROUP BY oi.OrderID
                ) oi ON o.OrderID = oi.OrderID
                """;
    }

    private void applyFilters(StringBuilder sql, List<Object> params,
            String startDate, String endDate, String status, String keyword) {
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND UPPER(o.OrderStatus) = UPPER(?)");
            params.add(status.trim());
        }
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND o.OrderDate >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            if (endDate.endsWith(" 00:00:00")) {
                sql.append(" AND o.OrderDate < ?");
            } else {
                sql.append(" AND o.OrderDate <= ?");
            }
            params.add(endDate);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (CAST(o.OrderID AS VARCHAR) LIKE ? OR c.FullName LIKE ? OR c.Phone LIKE ?)");
            String kPattern = "%" + keyword.trim() + "%";
            params.add(kPattern);
            params.add(kPattern);
            params.add(kPattern);
        }
    }

    public Map<String, Integer> getOrderStatusCountsMap(String startDate, String endDate) {
        Map<String, Integer> map = new HashMap<>();
        map.put("PENDING", 0);
        map.put("CONFIRMED", 0);
        map.put("SHIPPING", 0);
        map.put("DELIVERED", 0);
        map.put("CANCELLED", 0);

        StringBuilder sql = new StringBuilder("SELECT UPPER(o.OrderStatus) AS Status, COUNT(DISTINCT o.OrderID) "
                + "AS Qty FROM Orders o WHERE 1=1");
        List<Object> params = new ArrayList<>();
        applyFilters(sql, params, startDate, endDate, null, null);
        sql.append(" GROUP BY UPPER(o.OrderStatus)");

        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String st = rs.getString("Status");
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
        StringBuilder sql = new StringBuilder("SELECT COUNT(DISTINCT o.OrderID) FROM Orders o "
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
        if (pageSize > 0 && pageSize < Integer.MAX_VALUE) {
            sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            if (page < 1) {
                page = 1;
            }

            if (pageSize <= 0) {
                throw new IllegalArgumentException(
                        "pageSize must be greater than 0"
                );
            }
            params.add((page - 1) * pageSize);
            params.add(pageSize);
        }

        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrder(rs, false));
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
                       a.AddressID, a.ReceiverName AS AddrReceiverName, a.ReceiverPhone AS AddrReceiverPhone, 
                       a.AddressLine, a.Ward, a.District, a.Province,
                       s.ShipmentID, s.ShippingProvider, s.TrackingNumber, s.ShippingStatus, s.EstimatedDeliveryDate, 
                       s.ShippedAt, s.DeliveredAt,
                       p.PaymentID, p.PaymentMethod, p.PaymentStatus, p.TransactionID, p.PaymentDate,
                       (
                           SELECT STRING_AGG(COALESCE(pr.ProductName, CONCAT('Product #', oi.ProductID)) 
                           + CASE WHEN oi.Quantity > 1 THEN CONCAT(' (x', oi.Quantity, ')') ELSE '' END, ', ')
                           FROM OrderItems oi
                           LEFT JOIN Products pr ON oi.ProductID = pr.ProductID
                           WHERE oi.OrderID = o.OrderID
                       ) AS ProductSummary
                FROM Orders o
                LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
                LEFT JOIN (
                    SELECT a1.* FROM Addresses a1
                    INNER JOIN (SELECT CustomerID, MAX(AddressID) AS MaxID FROM Addresses WHERE IsDefault = 1 OR IsDefault IS NULL GROUP BY CustomerID) a2 
                    ON a1.AddressID = a2.MaxID
                ) a ON o.CustomerID = a.CustomerID
                LEFT JOIN (
                    SELECT s1.* FROM Shipments s1
                    INNER JOIN (SELECT OrderID, MAX(ShipmentID) AS MaxID FROM Shipments GROUP BY OrderID) s2 
                    ON s1.ShipmentID = s2.MaxID
                ) s ON o.OrderID = s.OrderID
                LEFT JOIN (
                    SELECT p1.* FROM Payments p1
                    INNER JOIN (SELECT OrderID, MAX(PaymentID) AS MaxID FROM Payments GROUP BY OrderID) p2 
                    ON p1.PaymentID = p2.MaxID
                ) p ON o.OrderID = p.OrderID
                WHERE o.OrderID = ?
                """;
    }

    public Order getOrderById(int orderID) {
        if (orderID <= 0) {
            throw new IllegalArgumentException("Invalid orderID");
        }
        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(getOrderDetailQuery())) {
            ps.setInt(1, orderID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapOrder(rs, true);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching order detail #" + orderID, e);
        }
        return null;
    }

    public Order getOrderDetailWithJoin(int orderID) {
        return getOrderById(orderID);
    }

    public List<OrderItem> getOrderItems(int orderID) {

        List<OrderItem> items = new ArrayList<>();
        String sql = """
                SELECT oi.OrderItemID, oi.OrderID, oi.ProductID, oi.Quantity, oi.UnitPrice,
                       COALESCE(p.ProductName, CONCAT('Product #', oi.ProductID)) AS ProductName
                FROM OrderItems oi
                LEFT JOIN Products p ON oi.ProductID = p.ProductID
                WHERE oi.OrderID = ?
                ORDER BY oi.OrderItemID
                """;

        if (orderID <= 0) {
            throw new IllegalArgumentException("Invalid orderID");
        }
        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemID(rs.getInt("OrderItemID"));
                    item.setOrderID(rs.getInt("OrderID"));
                    item.setProductID(rs.getInt("ProductID"));
                    item.setQuantity(rs.getInt("Quantity"));
                    item.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                    item.setProductName(rs.getString("ProductName"));
                    items.add(item);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching order items #" + orderID, e);
        }
        return items;
    }

    // =========================================================================
    // 4. ATOMIC DATABASE TRANSACTIONS (STATUS UPDATES & STOCK RESTORATION)
    // =========================================================================
    public boolean updateOrderStatus(int orderID, String newStatus, String cancelReason) {
        String sql = "UPDATE Orders SET OrderStatus = ?, CancelReason = ?, UpdatedAt = GETDATE() WHERE OrderID = ?";
        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, cancelReason);
            ps.setInt(3, orderID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating status #" + orderID, e);
            return false;
        }
    }

    public boolean updateOrderStatusWithShipmentAndPayment(int orderID, String newStatus, String cancelReason,
            String shippingProvider, String trackingNumber, String shipperName, String shipperPhone) {
        String updateOrderSql = """
                UPDATE Orders SET OrderStatus = ?, CancelReason = ?,
                       ShippingName = COALESCE(?, ShippingName), ShippingPhone = COALESCE(?, ShippingPhone),
                       UpdatedAt = GETDATE() WHERE OrderID = ?
                """;
        String updateShipmentSql = """
                UPDATE Shipments SET ShippingProvider = COALESCE(?, ShippingProvider),
                       TrackingNumber = COALESCE(?, TrackingNumber), ShippingStatus = COALESCE(?, ShippingStatus),
                       ShippedAt = CASE WHEN ? = 'SHIPPING' AND ShippedAt IS NULL THEN GETDATE() ELSE ShippedAt END,
                       DeliveredAt = CASE WHEN ? = 'DELIVERED' THEN GETDATE() ELSE DeliveredAt END
                WHERE OrderID = ?
                """;
        String insertShipmentSql = "INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, "
                + "ShippingStatus, ShippedAt) VALUES (?, ?, ?, ?, GETDATE())";
        String updatePaymentSql = "UPDATE Payments SET PaymentStatus = 'SUCCESS', PaymentDate = GETDATE() "
                + "WHERE OrderID = ? AND (PaymentMethod = 'COD' OR PaymentMethod IS NULL)";

        Connection conn = null;
        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false); // Atomic Transaction

            // 1. Update Orders
            try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                ps.setString(1, newStatus);
                ps.setString(2, cancelReason);
                ps.setString(3, (shipperName != null && !shipperName.trim().isEmpty()) ? shipperName.trim() : null);
                ps.setString(4, (shipperPhone != null && !shipperPhone.trim().isEmpty()) ? shipperPhone.trim() : null);
                ps.setInt(5, orderID);
                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Handle SHIPPING
            if ("SHIPPING".equalsIgnoreCase(newStatus)) {
                try (PreparedStatement ps = conn.prepareStatement(updateShipmentSql)) {
                    ps.setString(1, shippingProvider);
                    ps.setString(2, trackingNumber);
                    ps.setString(3, "SHIPPING");
                    ps.setString(4, "SHIPPING");
                    ps.setString(5, "SHIPPING");
                    ps.setInt(6, orderID);
                    if (ps.executeUpdate() <= 0) {
                        try (PreparedStatement psIns = conn.prepareStatement(insertShipmentSql)) {
                            psIns.setInt(1, orderID);
                            psIns.setString(2, shippingProvider != null ? shippingProvider : "Giao Hàng Nhanh (GHN)");
                            psIns.setString(3, trackingNumber != null ? trackingNumber : "TRK" + System.currentTimeMillis());
                            psIns.setString(4, "SHIPPING");
                            psIns.executeUpdate();
                        }
                    }
                }
            }

            // 3. Handle DELIVERED (Update Shipment status + Auto COD Payment settlement)
            if ("DELIVERED".equalsIgnoreCase(newStatus)) {
                try (PreparedStatement ps = conn.prepareStatement(updateShipmentSql)) {
                    ps.setNull(1, java.sql.Types.VARCHAR);
                    ps.setNull(2, java.sql.Types.VARCHAR);
                    ps.setString(3, "DELIVERED");
                    ps.setString(4, "DELIVERED");
                    ps.setString(5, "DELIVERED");
                    ps.setInt(6, orderID);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(updatePaymentSql)) {
                    ps.setInt(1, orderID);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Transaction error updating status #" + orderID, e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(
                            Level.SEVERE,
                            "Lỗi rollback đơn hàng #" + orderID,
                            rollbackEx
                    );
                }
            }

            return false;
        }
        }

    

    public boolean updateOrderStatusWithShipmentAndPayment(int orderID, String newStatus, String cancelReason,
            String shippingProvider, String trackingNumber) {
        return updateOrderStatusWithShipmentAndPayment(orderID, newStatus, cancelReason, shippingProvider,
                trackingNumber, null, null);
    }

    public boolean restoreStockForCancelledOrder(int orderID) {
        Order o = getOrderById(orderID);
        String reason = (o != null && o.getCancelReason() != null) ? o.getCancelReason() : "Cancelled Order #" + orderID;
        return cancelOrderWithStockRestoration(orderID, reason);
    }

    /**
     * Atomically cancels order, restores product stock quantity, and writes
     * inventory audit logs.
     */
    public boolean cancelOrderWithStockRestoration(int orderID, String cancelReason) {
        String checkSql = "SELECT OrderStatus FROM Orders WHERE OrderID = ?";
        String updateOrderSql = "UPDATE Orders SET OrderStatus = 'CANCELLED', CancelReason = ?, "
                + "UpdatedAt = GETDATE() WHERE OrderID = ? AND UPPER(OrderStatus) != 'CANCELLED'";
        String fetchItemsSql = "SELECT oi.ProductID, oi.Quantity, p.StockQuantity "
                + "FROM OrderItems oi LEFT JOIN Products p ON oi.ProductID = p.ProductID WHERE oi.OrderID = ?";
        String updateStockSql = "UPDATE Products SET StockQuantity = StockQuantity + ? WHERE ProductID = ?";
        String logInventorySql = "INSERT INTO InventoryTransactions (ProductID, TransactionType, "
                + "Quantity, PreviousQuantity, NewQuantity, Reason, CreatedAt) VALUES (?, 'RETURN', ?, ?, ?, ?, GETDATE())";

        Connection conn = null;
        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false); // Atomic Transaction

            // 1. Guard against duplicate cancellation
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, orderID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || "CANCELLED".equalsIgnoreCase(rs.getString("OrderStatus"))) {
                        conn.rollback();
                        return false;
                    }
                }
            }

            // 2. Update Orders status
            try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                ps.setString(1, cancelReason);
                ps.setInt(2, orderID);
                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 3. Fetch items to restore
            List<int[]> items = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(fetchItemsSql)) {
                ps.setInt(1, orderID);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        items.add(new int[]{rs.getInt("ProductID"), rs.getInt("Quantity"), rs.getInt("StockQuantity")});
                    }
                }
            }
            if (items.isEmpty()) {
                conn.rollback();
                return false;
            }

            // 4. Restore stock and write inventory transaction log
            try (PreparedStatement psStock = conn.prepareStatement(updateStockSql); PreparedStatement psLog = conn.prepareStatement(logInventorySql)) {
                for (int[] item : items) {
                    int pId = item[0], qty = item[1], prevStock = item[2];
                    psStock.setInt(1, qty);
                    psStock.setInt(2, pId);
                    if (psStock.executeUpdate() <= 0) {
                        conn.rollback();
                        return false;
                    }

                    psLog.setInt(1, pId);
                    psLog.setInt(2, qty);
                    psLog.setInt(3, prevStock);
                    psLog.setInt(4, prevStock + qty);
                    psLog.setString(5, "Cancelled Order #ORD-" + orderID + " (" + cancelReason + ")");
                    psLog.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Transaction error cancelling order #" + orderID, e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.SEVERE, "Rollback failed for order #" + orderID, rollbackEx);
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException closeEx) {
                    LOGGER.log(Level.WARNING, "Failed to close connection for order #" + orderID, closeEx);
                }
            }
        }
    }

    /**
     * Retrieves AI 512-Vector recommendations for an order's customer. Matches
     * the customer's personalized/similar recommendations from
     * AIRecommendations. Falls back to top confidence recommendations if
     * customer has no specific history.
     */
    public List<Map<String, Object>> getAIRecommendationsForOrder(int customerId, int orderId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sqlWithCustomer = "SELECT TOP 3 "
                + "  r.RecommendationID, r.ProductID, p.ProductName, p.Price, pi.ImageURL, "
                + "  r.SimilarityScore, r.Reason, r.RecommendationType, "
                + "  c.CategoryName, b.BrandName "
                + "FROM AIRecommendations r "
                + "JOIN Products p ON r.ProductID = p.ProductID "
                + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                + "LEFT JOIN Brands b ON p.BrandID = b.BrandID "
                + "LEFT JOIN ProductImages pi ON p.ProductID = pi.ProductID AND pi.IsPrimary = 1 "
                + "WHERE r.CustomerID = ? "
                + "ORDER BY r.CreatedAt DESC, r.SimilarityScore DESC";

        String fallbackSql = "SELECT TOP 3 "
                + "  r.RecommendationID, r.ProductID, p.ProductName, p.Price, pi.ImageURL, "
                + "  r.SimilarityScore, r.Reason, r.RecommendationType, "
                + "  c.CategoryName, b.BrandName "
                + "FROM AIRecommendations r "
                + "JOIN Products p ON r.ProductID = p.ProductID "
                + "LEFT JOIN Categories c ON p.CategoryID = c.CategoryID "
                + "LEFT JOIN Brands b ON p.BrandID = b.BrandID "
                + "LEFT JOIN ProductImages pi ON p.ProductID = pi.ProductID AND pi.IsPrimary = 1 "
                + "ORDER BY r.SimilarityScore DESC, r.CreatedAt DESC";

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
