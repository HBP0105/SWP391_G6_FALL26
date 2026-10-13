package com.swp391.dao;

import com.swp391.model.Category;
import com.swp391.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CategoryDAO {

    private static final Logger LOGGER = Logger.getLogger(CategoryDAO.class.getName());
    private final DBContext dbContext;

    public CategoryDAO() {
        dbContext = new DBContext();
    }

    /**
     * Get all active categories ordered by CategoryID.
     */
    public List<Category> getAllActiveCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.CategoryID, c.CategoryName, c.Description, c.Status, "
                + "(SELECT COUNT(*) FROM Products p WHERE p.CategoryID = c.CategoryID AND p.Status = 'ACTIVE') AS ProductCount "
                + "FROM Categories c "
                + "WHERE c.Status = 'ACTIVE' "
                + "ORDER BY c.CategoryID ASC";

        try (Connection conn = dbContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("CategoryID"));
                c.setCategoryName(rs.getString("CategoryName"));
                c.setDescription(rs.getString("Description"));
                c.setStatus(rs.getString("Status"));
                c.setProductCount(rs.getInt("ProductCount"));
                list.add(c);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getAllActiveCategories", e);
        }
        return list;
    }
}
