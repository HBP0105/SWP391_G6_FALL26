package com.swp391.dao;

import com.swp391.model.CartItemDTO;
import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;

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
}
