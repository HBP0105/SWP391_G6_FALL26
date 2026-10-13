package com.swp391.dao;

import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 * DAO handling database operations for Shipments table (Auxiliary updates for Order Management).
 */
public class ShipmentDAO {

    private DBContext dbContext;

    public ShipmentDAO() {
        dbContext = new DBContext();
    }

    /**
     * Update or insert shipment carrier, tracking code, status and timestamps.
     * 
     * @param orderID order ID
     * @param provider shipping provider / carrier
     * @param trackingNumber tracking code
     * @param shippingStatus shipment status
     * @return true if updated or inserted
     */
    public boolean updateShipmentInfo(int orderID, String provider, String trackingNumber, String shippingStatus) {
        String updateSql = """
                UPDATE Shipments
                SET ShippingProvider = ?,
                    TrackingNumber = ?,
                    ShippingStatus = ?,
                    ShippedAt = CASE WHEN ? = 'SHIPPING' AND ShippedAt IS NULL THEN GETDATE() ELSE ShippedAt END,
                    DeliveredAt = CASE WHEN ? = 'DELIVERED' THEN GETDATE() ELSE DeliveredAt END
                WHERE OrderID = ?
                """;
        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(updateSql)) {
            ps.setString(1, provider);
            ps.setString(2, trackingNumber);
            ps.setString(3, shippingStatus);
            ps.setString(4, shippingStatus);
            ps.setString(5, shippingStatus);
            ps.setInt(6, orderID);
            if (ps.executeUpdate() > 0) {
                return true;
            }

            // Neu chua co ban ghi thi INSERT moi
            String insertSql = "INSERT INTO Shipments (OrderID, ShippingProvider, TrackingNumber, ShippingStatus, ShippedAt) "
                    + "VALUES (?, ?, ?, ?, GETDATE())";
            try (PreparedStatement psIns = connection.prepareStatement(insertSql)) {
                psIns.setInt(1, orderID);
                psIns.setString(2, provider != null ? provider : "Giao Hàng Nhanh (GHN)");
                psIns.setString(3, trackingNumber != null ? trackingNumber : "TRK" + System.currentTimeMillis());
                psIns.setString(4, shippingStatus != null ? shippingStatus : "SHIPPING");
                return psIns.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}

