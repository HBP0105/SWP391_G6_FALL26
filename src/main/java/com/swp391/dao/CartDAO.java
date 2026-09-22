package com.swp391.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CartDAO {

    public int getCartIdByCustomerId(int customerId) {
        // String sql = "SELECT CartID FROM Carts WHERE CustomerID = ?";
        return -1;
    }

    public void addCartItem(int cartId, int productId, int quantity) {
        // String sql = "INSERT INTO CartItems (CartID, ProductID, Quantity) VALUES (?, ?, ?)";
    }

    public void updateCartItemQuantity(int cartId, int productId, int newQuantity) {
        // String sql = "UPDATE CartItems SET Quantity = ? WHERE CartID = ? AND ProductID = ?";
    }

    public void removeCartItem(int cartId, int productId) {
        // String sql = "DELETE FROM CartItems WHERE CartID = ? AND ProductID = ?";
    }

    public void clearCart(int cartId) {
        // String sql = "DELETE FROM CartItems WHERE CartID = ?";
    }
}
