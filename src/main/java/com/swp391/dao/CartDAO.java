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
    public CartItemDTO getProductInfo(int productId){
        CartItemDTO item = null;
        String sql = "SELECT p.ProductID, p.ProductName, p.Price, pi.ImageURL " +
                     "FROM Products p " +
                     "LEFT JOIN ProductImages pi ON p.ProductID = pi.ProductID AND pi.IsPrimary = 1 " +
                     "WHERE p.ProductID = ?";
        try {
            Connection connection = getConnection();
            PreparedStatement ptm = connection.prepareStatement(sql);
            ptm.setInt(1, productId);
            ResultSet rs = ptm.executeQuery();
            if(rs.next()){
                item = new CartItemDTO();
                item.setProductId(rs.getInt("productID"));
                item.setProductName(rs.getString("ProductName"));
                item.setPrice(rs.getDouble("Price"));
                item.setImageUrl(rs.getString("ImageURL"));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return item;
    }

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
                // San pham da ton tai -> Cap nhat cong them so luong
                int oldQty = rs.getInt("Quantity");
                String updateSql = "UPDATE CartItems SET Quantity = ? WHERE CartID = ? AND ProductID = ?";
                PreparedStatement ptmUpdate = connection.prepareStatement(updateSql);
                ptmUpdate.setInt(1, oldQty + quantity);
                ptmUpdate.setInt(2, cartId);
                ptmUpdate.setInt(3, productId);
                ptmUpdate.executeUpdate();
            } else {
                // San pham da ton tai -> Cap nhat cong them so luong
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
        // San pham da ton tai -> Cap nhat cong them so luong
    }

    public void removeCartItem(int cartId, int productId) {
        // San pham da ton tai -> Cap nhat cong them so luong
    }

    public void clearCart(int cartId) {
        // San pham da ton tai -> Cap nhat cong them so luong
    }
}
