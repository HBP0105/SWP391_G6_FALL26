package com.swp391.service;

import com.swp391.dao.Manager.inventoryDao;
import com.swp391.model.Category;

import java.util.List;
import java.util.Map;

/**
 * Service layer for Inventory management.
 * Provides stock statistics, search, filter, pagination, and inventory product listings.
 */
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
                normalize(keyword),
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
                normalize(keyword),
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
        return dao.getRecentTransactions();
    }

    public List<Map<String, Object>> getRecentTransactions(int page, int pageSize) {
        page = normalizePage(page);
        pageSize = normalizePageSize(pageSize);

        int offset = (page - 1) * pageSize;
        return dao.getRecentTransactions(offset, pageSize);
    }

    public int countRecentTransactions() {
        return dao.countRecentTransactions();
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
}
