package com.swp391.dao;

import com.swp391.model.CartItemDTO;
import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CartDAO extends DBContext{

    public int getCartIdByCustomerId(int customerId) {
        int cartId = -1;
        String sql = "SELECT CartID FROM Carts WHERE CustomerID = ?";
        try{
            Connection connection = getConnection();
            PreparedStatement ptm = connection.prepareStatement(sql);
            ptm.setInt(1, customerId);
            ResultSet rs = ptm.executeQuery();
            if(rs.next()){
                cartId = rs.getInt("CartID");
            }
            else{
                String insertSql = "INSERT INTO Carts (CustomerID) VALUES (?)";
                PreparedStatement ptmInsert = connection.prepareStatement(insertSql, PreparedStatement.RETURN_GENERATED_KEYS);
                ptmInsert.setInt(1, customerId);
                ptmInsert.executeUpdate();
                
                ResultSet rsKeys = ptmInsert.getGeneratedKeys();
                if (rsKeys.next()) {
                    cartId = rsKeys.getInt(1);
                }
            }
        }catch(Exception ex){
            ex.printStackTrace();
        }
        return cartId;
    }
    
    public List<CartItemDTO> getCartItems(int cartId) {
        List<CartItemDTO> list = new ArrayList<>();
        String sql = "SELECT ci.ProductID, p.ProductName, p.Price, ci.Quantity, pi.ImageURL \n" +
                     "FROM CartItems ci \n" +
                     "JOIN Products p ON ci.ProductID = p.ProductID \n" +
                     "LEFT JOIN ProductImages pi ON p.ProductID = pi.ProductID AND pi.IsPrimary = 1 \n" +
                     "WHERE ci.CartID = ?";
        try {
            Connection connection = getConnection();
            PreparedStatement ptm = connection.prepareStatement(sql);
            ptm.setInt(1, cartId);
            ResultSet rs = ptm.executeQuery();
            
            while (rs.next()) {
                CartItemDTO item = new CartItemDTO();
                item.setProductId(rs.getInt("ProductID"));
                item.setProductName(rs.getString("ProductName"));
                item.setPrice(rs.getDouble("Price"));
                item.setQuantity(rs.getInt("Quantity"));
                item.setImageUrl(rs.getString("ImageURL"));
                
                list.add(item);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public void addCartItem(int cartId, int productId, int quantity) {
        String checkSql = "SELECT Quantity FROM CartItems WHERE CartID = ? AND ProductID = ?";
        try {
            Connection connection = getConnection();
            PreparedStatement ptmCheck = connection.prepareStatement(checkSql);
            ptmCheck.setInt(1, cartId);
            ptmCheck.setInt(2, productId);
            ResultSet rs = ptmCheck.executeQuery();
            
            if (rs.next()) {
                // S?n ph?m ?ã t?n t?i -> C?p nh?t c?ng thêm s? l??ng
                int oldQty = rs.getInt("Quantity");
                String updateSql = "UPDATE CartItems SET Quantity = ? WHERE CartID = ? AND ProductID = ?";
                PreparedStatement ptmUpdate = connection.prepareStatement(updateSql);
                ptmUpdate.setInt(1, oldQty + quantity);
                ptmUpdate.setInt(2, cartId);
                ptmUpdate.setInt(3, productId);
                ptmUpdate.executeUpdate();
            } else {
                // S?n ph?m m?i tinh -> Insert dòng m?i
                String insertSql = "INSERT INTO CartItems (CartID, ProductID, Quantity) VALUES (?, ?, ?)";
                PreparedStatement ptmInsert = connection.prepareStatement(insertSql);
                ptmInsert.setInt(1, cartId);
                ptmInsert.setInt(2, productId);
                ptmInsert.setInt(3, quantity);
                ptmInsert.executeUpdate();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }

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
