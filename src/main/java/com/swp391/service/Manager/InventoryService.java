package com.swp391.service.Manager;

import com.swp391.dao.Manager.inventoryDao;
import com.swp391.model.Category;
import com.swp391.model.Product;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;


public class InventoryService {

    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final int MAX_PAGE_SIZE = 50;

    private final inventoryDao dao;

    public InventoryService() {
        this.dao = new inventoryDao();
    }

    public List<Map<String, Object>> getInventoryProducts() {
        return dao.getInventoryProducts();
    }

    public List<Map<String, Object>> getInventoryProducts(
            String keyword,
            Integer categoryId,
            String stock,
            String sort,
            int page,
            int pageSize) {

        page = normalizePage(page);
        pageSize = normalizePageSize(pageSize);

        int offset = (page - 1) * pageSize;

        return dao.getInventoryProducts(
                normalizeKeyword(keyword),
                categoryId,
                normalize(stock),
                normalize(sort),
                offset,
                pageSize
        );
    }

    public int countInventoryProducts(
            String keyword,
            Integer categoryId,
            String stock) {

        return dao.countInventoryProducts(
                normalizeKeyword(keyword),
                categoryId,
                normalize(stock)
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

    public List<Category> getAllCategories() {
        return dao.getAllCategories();
    }

    public int getTotalProducts() {
        return dao.getTotalProducts();
    }

    public int getInStockProducts() {
        return dao.getInStockProducts();
    }

    public int getLowStockProducts() {
        return dao.getLowStockProducts();
    }

    public int getOutOfStockProducts() {
        return dao.getOutOfStockProducts();
    }

    public List<Map<String, Object>> getRecentTransactions() {
        return dao.getRecentTransactions(null, null, null, null, 0, 10);
    }

    public List<Map<String, Object>> getRecentTransactions(int page, int pageSize) {
        return getRecentTransactions(null, null, null, null, page, pageSize);
    }

    public List<Map<String, Object>> getRecentTransactions(
            String keyword,
            String transactionType,
            String fromDate,
            String toDate,
            int page,
            int pageSize) {

        page = normalizePage(page);
        pageSize = normalizePageSize(pageSize);
        int offset = (page - 1) * pageSize;

        validateTransactionDateRange(fromDate, toDate);
        LocalDate from = parseDate(fromDate, "From date");
        LocalDate to = parseDate(toDate, "To date");

        return dao.getRecentTransactions(
                normalizeKeyword(keyword),
                normalizeTransactionType(transactionType),
                from,
                to,
                offset,
                pageSize
        );
    }

    public int countRecentTransactions() {
        return dao.countRecentTransactions(null, null, null, null);
    }

    public int countRecentTransactions(
            String keyword,
            String transactionType,
            String fromDate,
            String toDate) {

        validateTransactionDateRange(fromDate, toDate);
        LocalDate from = parseDate(fromDate, "From date");
        LocalDate to = parseDate(toDate, "To date");

        return dao.countRecentTransactions(
                normalizeKeyword(keyword),
                normalizeTransactionType(transactionType),
                from,
                to
        );
    }

    public int getTotalTransactionPages(int totalItems, int pageSize) {
        pageSize = normalizePageSize(pageSize);
        return totalItems == 0 ? 1 : (int) Math.ceil((double) totalItems / pageSize);
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private String normalizeTransactionType(String value) {
        String type = normalize(value);
        if (type == null || "ALL".equalsIgnoreCase(type)) {
            return null;
        }
        type = type.toUpperCase();
        if (!"IMPORT".equals(type)
                && !"SALE".equals(type)
                && !"RETURN".equals(type)
                && !"ADJUSTMENT".equals(type)) {
            throw new IllegalArgumentException("Invalid transaction type filter.");
        }
        return type;
    }

    public void validateTransactionDateRange(String fromDate, String toDate) {
        LocalDate from = parseDate(fromDate, "From date");
        LocalDate to = parseDate(toDate, "To date");
        LocalDate today = LocalDate.now();

        if (from != null && from.isAfter(today)) {
            throw new IllegalArgumentException("From date cannot be in the future.");
        }
        if (to != null && to.isAfter(today)) {
            throw new IllegalArgumentException("To date cannot be in the future.");
        }
        if (from != null && to != null && from.isAfter(to)) {
            throw new IllegalArgumentException("From date cannot be after To date.");
        }
    }

    private LocalDate parseDate(String value, String fieldName) {
        String normalized = normalize(value);
        if (normalized == null) {
            return null;
        }
        try {
            return LocalDate.parse(normalized);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException(fieldName + " is invalid.");
        }
    }

    public Product getProductById(int productId) {
        if (productId <= 0) {
            return null;
        }
        return dao.getProductById(productId);
    }

    public boolean adjustStock(
            int productId,
            String transactionType,
            int quantity,
            String reason,
            Integer staffId) {

        if (productId <= 0) {
            throw new IllegalArgumentException("Invalid product ID.");
        }

        Product product = getProductById(productId);
        if (product == null) {
            throw new IllegalArgumentException("Product does not exist.");
        }

        if (transactionType == null || transactionType.isBlank()) {
            throw new IllegalArgumentException("Transaction type is required.");
        }
        transactionType = transactionType.trim().toUpperCase();

        if (!"IMPORT".equals(transactionType)
                && !"RETURN".equals(transactionType)
                && !"ADJUSTMENT".equals(transactionType)) {
            throw new IllegalArgumentException("Invalid transaction type. Must be IMPORT, RETURN, or ADJUSTMENT.");
        }

        if (quantity == 0) {
            throw new IllegalArgumentException("Quantity cannot be 0.");
        }

        int previousQuantity = product.getStockQuantity();
        int newQuantity;
        int transactionQuantity;

        if ("IMPORT".equals(transactionType) || "RETURN".equals(transactionType)) {
            if (quantity <= 0) {
                throw new IllegalArgumentException("Quantity must be greater than 0 for " + transactionType + ".");
            }
            newQuantity = previousQuantity + quantity;
            transactionQuantity = quantity;
        } else {
            newQuantity = previousQuantity + quantity;
            if (newQuantity < 0) {
                throw new IllegalArgumentException("New stock cannot be negative. Current stock is "
                        + previousQuantity + ", but adjustment was " + quantity + ".");
            }
            transactionQuantity = Math.abs(quantity);
        }

        if (newQuantity < 0) {
            throw new IllegalArgumentException("New stock cannot be negative.");
        }

        return dao.adjustStock(
                productId,
                transactionType,
                transactionQuantity,
                previousQuantity,
                newQuantity,
                reason != null ? reason.trim() : null,
                staffId
        );
    }

    private String normalizeKeyword(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return null;
        }
        String result = keyword.replaceAll("\\s+", "").trim();
        return result.isEmpty() ? null : result;
    }

}
