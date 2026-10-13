package com.swp391.dao;

import com.swp391.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 * DAO handling database operations for Payments table (Auxiliary updates for Order Management).
 */
public class PaymentDAO {

    private DBContext dbContext;

    public PaymentDAO() {
        dbContext = new DBContext();
    }

    /**
     * Update payment status to SUCCESS/Paid when order is delivered (Only for COD payment method).
     * 
     * @param orderID order ID
     * @return true if updated successfully
     */
    public boolean updateCODPaymentToPaid(int orderID) {
        String sql = "UPDATE Payments SET PaymentStatus = 'SUCCESS', PaymentDate = GETDATE() "
                + "WHERE OrderID = ? AND (PaymentMethod = 'COD' OR PaymentMethod IS NULL)";
        try (Connection connection = dbContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePaymentToPaid(int orderID) {
        return updateCODPaymentToPaid(orderID);
    }
}

