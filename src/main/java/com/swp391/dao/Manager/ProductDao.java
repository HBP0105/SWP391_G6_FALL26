package com.swp391.dao.Manager;

import com.swp391.model.*;
import com.swp391.util.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDao {

    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();

        String sql = baseSelect()
                + " ORDER BY p.ProductID DESC";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Brand> getAllBrands() {
        List<Brand> list = new ArrayList<>();

        String sql = """
                SELECT BrandID, BrandName
                FROM Brands
                WHERE Status = 'ACTIVE'
                ORDER BY BrandName
                """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Brand brand = new Brand();
                brand.setBrandId(rs.getInt("BrandID"));
                brand.setBrandName(rs.getString("BrandName"));
                list.add(brand);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // Gi? method c? ?? không phá code khác.
    public List<Product> getProducts(
            Integer categoryId,
            String stock,
            String status,
            String sort) {

        return queryProducts(
                null,
                categoryId,
                stock,
                status,
                sort,
                null,
                null
        );
    }

    public List<Product> getProducts(
            String keyword,
            Integer categoryId,
            String stock,
            String status,
            String sort,
            int offset,
            int pageSize) {

        return queryProducts(
                keyword,
                categoryId,
                stock,
                status,
                sort,
                offset,
                pageSize
        );
    }

    private List<Product> queryProducts(
            String keyword,
            Integer categoryId,
            String stock,
            String status,
            String sort,
            Integer offset,
            Integer pageSize) {

        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(baseSelect());
        sql.append(" WHERE 1 = 1");

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, categoryId, stock, status);
        appendSort(sql, sort);

        if (offset != null && pageSize != null) {
            sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            params.add(offset);
            params.add(pageSize);
        }

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countProducts(
            String keyword,
            Integer categoryId,
            String stock,
            String status) {

        StringBuilder sql = new StringBuilder("""
                SELECT COUNT(*)
                FROM Products p
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                LEFT JOIN Brands b ON p.BrandID = b.BrandID
                WHERE 1 = 1
                """);

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, categoryId, stock, status);

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            bindParams(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();

        String sql = """
                SELECT CategoryID, CategoryName
                FROM Categories
                WHERE Status = 'ACTIVE'
                ORDER BY CategoryName
                """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getInt("CategoryID"));
                category.setCategoryName(rs.getString("CategoryName"));
                list.add(category);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean insertProduct(
            String name,
            String description,
            int categoryId,
            int brandId,
            BigDecimal price,
            int stock,
            String imageURL,
            String connectionType,
            Double driverSize,
            boolean noiseCancelling,
            Integer batteryLife,
            boolean microphone,
            String waterResistance,
            String status) {

        String sql = """
                INSERT INTO Products
                (
                    ProductName,
                    Description,
                    CategoryID,
                    BrandID,
                    Price,
                    StockQuantity,
                    ImageURL,
                    ConnectionType,
                    DriverSize,
                    NoiseCancelling,
                    BatteryLife,
                    Microphone,
                    WaterResistance,
                    Status
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            bindProductValues(
                    ps,
                    1,
                    name,
                    description,
                    categoryId,
                    brandId,
                    price,
                    stock,
                    imageURL,
                    connectionType,
                    driverSize,
                    noiseCancelling,
                    batteryLife,
                    microphone,
                    waterResistance,
                    status
            );

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateProduct(
            int id,
            String name,
            String description,
            int categoryId,
            int brandId,
            BigDecimal price,
            int stock,
            String imageURL,
            String connectionType,
            Double driverSize,
            boolean noiseCancelling,
            Integer batteryLife,
            boolean microphone,
            String waterResistance,
            String status) {

        String sql = """
                UPDATE Products
                SET ProductName = ?,
                    Description = ?,
                    CategoryID = ?,
                    BrandID = ?,
                    Price = ?,
                    StockQuantity = ?,
                    ImageURL = ?,
                    ConnectionType = ?,
                    DriverSize = ?,
                    NoiseCancelling = ?,
                    BatteryLife = ?,
                    Microphone = ?,
                    WaterResistance = ?,
                    Status = ?,
                    UpdatedAt = GETDATE()
                WHERE ProductID = ?
                """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            int nextIndex = bindProductValues(
                    ps,
                    1,
                    name,
                    description,
                    categoryId,
                    brandId,
                    price,
                    stock,
                    imageURL,
                    connectionType,
                    driverSize,
                    noiseCancelling,
                    batteryLife,
                    microphone,
                    waterResistance,
                    status
            );

            ps.setInt(nextIndex, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteProduct(int id) {
        String sql = "DELETE FROM Products WHERE ProductID = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public Product getProductById(int id) {
        String sql = baseSelect()
                + " WHERE p.ProductID = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProduct(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private String baseSelect() {
        return """
                SELECT
                    p.ProductID,
                    p.CategoryID,
                    p.BrandID,
                    p.ProductName,
                    p.Description,
                    p.Price,
                    p.StockQuantity,
                    p.ImageURL,
                    p.ConnectionType,
                    p.DriverSize,
                    p.NoiseCancelling,
                    p.BatteryLife,
                    p.Microphone,
                    p.WaterResistance,
                    p.Status,
                    p.CreatedAt,
                    p.UpdatedAt,
                    c.CategoryName,
                    b.BrandName
                FROM Products p
                LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
                LEFT JOIN Brands b ON p.BrandID = b.BrandID
                """;
    }

    private void appendFilters(
            StringBuilder sql,
            List<Object> params,
            String keyword,
            Integer categoryId,
            String stock,
            String status) {

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (p.ProductName LIKE ? OR c.CategoryName LIKE ? OR b.BrandName LIKE ?)");
            String value = "%" + keyword.trim() + "%";
            params.add(value);
            params.add(value);
            params.add(value);
        }

        if (categoryId != null) {
            sql.append(" AND p.CategoryID = ?");
            params.add(categoryId);
        }

        if ("in".equals(stock)) {
            sql.append(" AND p.StockQuantity > 10");
        } else if ("low".equals(stock)) {
            sql.append(" AND p.StockQuantity BETWEEN 1 AND 10");
        } else if ("out".equals(stock)) {
            sql.append(" AND p.StockQuantity = 0");
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND p.Status = ?");
            params.add(status);
        }
    }

    private void appendSort(StringBuilder sql, String sort) {
        if ("price_asc".equals(sort)) {
            sql.append(" ORDER BY p.Price ASC, p.ProductID DESC");
        } else if ("price_desc".equals(sort)) {
            sql.append(" ORDER BY p.Price DESC, p.ProductID DESC");
        } else {
            sql.append(" ORDER BY p.ProductID DESC");
        }
    }

    private void bindParams(PreparedStatement ps, List<Object> params)
            throws SQLException {

        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private int bindProductValues(
            PreparedStatement ps,
            int startIndex,
            String name,
            String description,
            int categoryId,
            int brandId,
            BigDecimal price,
            int stock,
            String imageURL,
            String connectionType,
            Double driverSize,
            boolean noiseCancelling,
            Integer batteryLife,
            boolean microphone,
            String waterResistance,
            String status) throws SQLException {

        int i = startIndex;

        ps.setString(i++, name);
        setNullableString(ps, i++, description);
        ps.setInt(i++, categoryId);
        ps.setInt(i++, brandId);
        ps.setBigDecimal(i++, price);
        ps.setInt(i++, stock);
        setNullableString(ps, i++, imageURL);
        setNullableString(ps, i++, connectionType);

        if (driverSize != null) {
            ps.setDouble(i++, driverSize);
        } else {
            ps.setNull(i++, Types.DECIMAL);
        }

        ps.setBoolean(i++, noiseCancelling);

        if (batteryLife != null) {
            ps.setInt(i++, batteryLife);
        } else {
            ps.setNull(i++, Types.INTEGER);
        }

        ps.setBoolean(i++, microphone);
        setNullableString(ps, i++, waterResistance);
        ps.setString(i++, status);

        return i;
    }

    private void setNullableString(PreparedStatement ps, int index, String value)
            throws SQLException {
        if (value != null && !value.isBlank()) {
            ps.setString(index, value);
        } else {
            ps.setNull(index, Types.VARCHAR);
        }
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        Product p = new Product();

        p.setProductId(rs.getInt("ProductID"));
        p.setCategoryId(rs.getInt("CategoryID"));
        p.setBrandId(rs.getInt("BrandID"));
        p.setProductName(rs.getString("ProductName"));
        p.setDescription(rs.getString("Description"));
        p.setPrice(rs.getBigDecimal("Price"));
        p.setStockQuantity(rs.getInt("StockQuantity"));
        p.setImageURL(rs.getString("ImageURL"));
        p.setConnectionType(rs.getString("ConnectionType"));

        double driverSize = rs.getDouble("DriverSize");
        p.setDriverSize(rs.wasNull() ? null : driverSize);

        p.setNoiseCancelling(rs.getBoolean("NoiseCancelling"));

        int batteryLife = rs.getInt("BatteryLife");
        p.setBatteryLife(rs.wasNull() ? null : batteryLife);

        p.setMicrophone(rs.getBoolean("Microphone"));
        p.setWaterResistance(rs.getString("WaterResistance"));
        p.setStatus(rs.getString("Status"));

        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        if (createdAt != null) {
            p.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("UpdatedAt");
        if (updatedAt != null) {
            p.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        p.setCategoryName(rs.getString("CategoryName"));
        p.setBrandName(rs.getString("BrandName"));

        return p;
    }
}
