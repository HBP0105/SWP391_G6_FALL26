package com.swp391.dao;

import com.swp391.model.Brand;
import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class BrandDAO {

    private static final Logger LOGGER = Logger.getLogger(BrandDAO.class.getName());
    private final DBContext dbContext;

    public BrandDAO() {
        dbContext = new DBContext();
    }

    /**
     * Get all active brands (with number of active products), ordered by name.
     */
    public List<Brand> getAllActiveBrands() {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT b.BrandID, b.BrandName, b.Description, b.Status, "
                + "(SELECT COUNT(*) FROM Products p WHERE p.BrandID = b.BrandID AND p.Status = 'ACTIVE') AS ProductCount "
                + "FROM Brands b "
                + "WHERE b.Status = 'ACTIVE' "
                + "ORDER BY b.BrandName ASC";

        try (Connection conn = dbContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Brand b = new Brand();
                b.setBrandId(rs.getInt("BrandID"));
                b.setBrandName(rs.getString("BrandName"));
                b.setDescription(rs.getString("Description"));
                b.setStatus(rs.getString("Status"));
                b.setProductCount(rs.getInt("ProductCount"));
                list.add(b);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getAllActiveBrands", e);
        }
        return list;
    }
}
