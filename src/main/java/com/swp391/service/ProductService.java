package com.swp391.service;

import com.swp391.dao.Manager.ProductDao;
import com.swp391.model.Brand;
import com.swp391.model.Category;
import com.swp391.model.Product;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

public class ProductService {

    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final int MAX_PAGE_SIZE = 50;

    private final ProductDao productDao;

    public ProductService() {
        this.productDao = new ProductDao();
    }

    public List<Product> getAllProducts() {
        return productDao.getAllProducts();
    }

    public List<Product> getProducts(
            Integer categoryId,
            String stock,
            String status,
            String sort) {

        return productDao.getProducts(
                categoryId,
                normalize(stock),
                normalize(status),
                normalize(sort)
        );
    }

    public List<Product> getProducts(
            String keyword,
            Integer categoryId,
            String stock,
            String status,
            String sort,
            int page,
            int pageSize) {

        page = normalizePage(page);
        pageSize = normalizePageSize(pageSize);

        int offset = (page - 1) * pageSize;

        return productDao.getProducts(
                normalize(keyword),
                categoryId,
                normalize(stock),
                normalize(status),
                normalize(sort),
                offset,
                pageSize
        );
    }

    public int countProducts(
            String keyword,
            Integer categoryId,
            String stock,
            String status) {

        return productDao.countProducts(
                normalize(keyword),
                categoryId,
                normalize(stock),
                normalize(status)
        );
    }

    public int getTotalPages(int totalItems, int pageSize) {
        pageSize = normalizePageSize(pageSize);
        return totalItems == 0 ? 1 : (int) Math.ceil((double) totalItems / pageSize);
    }

    public int normalizePage(int page) {
        return Math.max(page, 1);
    }

    public int normalizePageSize(int pageSize) {
        if (pageSize <= 0) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(pageSize, MAX_PAGE_SIZE);
    }

    public Product getProductById(int id) {
        if (id <= 0) {
            return null;
        }
        return productDao.getProductById(id);
    }

    public List<Category> getAllCategories() {
        return productDao.getAllCategories();
    }

    public List<Brand> getAllBrands() {
        return productDao.getAllBrands();
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

        validateProduct(name, categoryId, brandId, price, stock, driverSize, batteryLife);

        return productDao.insertProduct(
                name.trim(),
                normalize(description),
                categoryId,
                brandId,
                price,
                stock,
                normalize(imageURL),
                normalize(connectionType),
                driverSize,
                noiseCancelling,
                batteryLife,
                microphone,
                normalize(waterResistance),
                normalizeStatus(status)
        );
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

        if (id <= 0 || productDao.getProductById(id) == null) {
            throw new IllegalArgumentException("Product does not exist.");
        }

        validateProduct(name, categoryId, brandId, price, stock, driverSize, batteryLife);

        return productDao.updateProduct(
                id,
                name.trim(),
                normalize(description),
                categoryId,
                brandId,
                price,
                stock,
                normalize(imageURL),
                normalize(connectionType),
                driverSize,
                noiseCancelling,
                batteryLife,
                microphone,
                normalize(waterResistance),
                normalizeStatus(status)
        );
    }

    public boolean deleteProduct(int id) {
        if (id <= 0 || productDao.getProductById(id) == null) {
            return false;
        }
        return productDao.deleteProduct(id);
    }

 
    public String saveProductImage(
            InputStream inputStream,
            String originalFileName,
            String uploadDirectory,
            String publicBasePath) throws IOException {

        if (inputStream == null || originalFileName == null || originalFileName.isBlank()) {
            return null;
        }

        String safeName = Paths.get(originalFileName).getFileName().toString();
        String extension = "";
        int dot = safeName.lastIndexOf('.');
        if (dot >= 0 && dot < safeName.length() - 1) {
            extension = safeName.substring(dot).toLowerCase();
        }

        String generatedName = UUID.randomUUID() + extension;
        Path directory = Paths.get(uploadDirectory);
        Files.createDirectories(directory);

        Path target = directory.resolve(generatedName);
        Files.copy(inputStream, target, StandardCopyOption.REPLACE_EXISTING);

        return publicBasePath + "/" + generatedName;
    }

    private void validateProduct(
            String name,
            int categoryId,
            int brandId,
            BigDecimal price,
            int stock,
            Double driverSize,
            Integer batteryLife) {

        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Product name is required.");
        }
        if (categoryId <= 0) {
            throw new IllegalArgumentException("Invalid category.");
        }
        if (brandId <= 0) {
            throw new IllegalArgumentException("Invalid brand.");
        }
        if (price == null || price.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Price cannot be negative.");
        }
        if (stock < 0) {
            throw new IllegalArgumentException("Stock cannot be negative.");
        }
        if (driverSize != null && driverSize < 0) {
            throw new IllegalArgumentException("Driver size cannot be negative.");
        }
        if (batteryLife != null && batteryLife < 0) {
            throw new IllegalArgumentException("Battery life cannot be negative.");
        }
    }

    private String normalizeStatus(String status) {
        String value = normalize(status);
        if (value == null) {
            return "ACTIVE";
        }
        if (!"ACTIVE".equals(value) && !"INACTIVE".equals(value)) {
            throw new IllegalArgumentException("Invalid product status.");
        }
        return value;
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
