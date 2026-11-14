package com.swp391.service.Admin;

import com.swp391.dao.Admin.AuditLogDAO;
import com.swp391.dao.Admin.CategoryDAO;
import com.swp391.model.Category;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Service for Admin Category Management.
 * Handles validation, business logic, uniqueness checks, and AuditLog recording.
 */
public class CategoryService {

    public static final int DEFAULT_PAGE_SIZE = 10;
    private static final Set<String> FILTER_STATUSES = Set.of("ALL", "ACTIVE", "INACTIVE");

    private final CategoryDAO categoryDAO;
    private final AuditLogDAO auditLogDAO;

    public CategoryService() {
        this.categoryDAO = new CategoryDAO();
        this.auditLogDAO = new AuditLogDAO();
    }

    public List<Category> getCategories(String keyword, String status, int page) {
        int normalizedPage = Math.max(page, 1);
        int offset = (normalizedPage - 1) * DEFAULT_PAGE_SIZE;
        return categoryDAO.getCategories(
                normalizeKeyword(keyword),
                normalizeFilterStatus(status),
                offset,
                DEFAULT_PAGE_SIZE
        );
    }

    public int countCategories(String keyword, String status) {
        return categoryDAO.countCategories(normalizeKeyword(keyword), normalizeFilterStatus(status));
    }

    public int getTotalPages(int totalItems) {
        return totalItems <= 0 ? 1 : (int) Math.ceil((double) totalItems / DEFAULT_PAGE_SIZE);
    }

    public Map<String, Integer> getCategoryStats() {
        return categoryDAO.getCategoryStats();
    }

    public Category getCategoryById(int id) {
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid category ID.");
        }
        Category category = categoryDAO.getCategoryById(id);
        if (category == null) {
            throw new IllegalArgumentException("Category was not found.");
        }
        return category;
    }

    public int createCategory(String name, String description, String status, Integer adminId) {
        String cleanName = trimToEmpty(name);
        String cleanDesc = trimToEmpty(description);
        String cleanStatus = normalizeRequiredStatus(status);

        if (cleanName.isEmpty() || cleanName.length() > 100) {
            throw new IllegalArgumentException("Category name is required and must be at most 100 characters.");
        }
        if (cleanDesc.length() > 500) {
            throw new IllegalArgumentException("Description must be at most 500 characters.");
        }
        if (categoryDAO.isCategoryNameExists(cleanName, null)) {
            throw new IllegalArgumentException("Category name '" + cleanName + "' already exists.");
        }

        Category cat = new Category();
        cat.setCategoryName(cleanName);
        cat.setDescription(cleanDesc.isEmpty() ? null : cleanDesc);
        cat.setStatus(cleanStatus);

        int newId = categoryDAO.insertCategory(cat);
        if (newId <= 0) {
            throw new RuntimeException("Failed to create category in database.");
        }

        // Audit Log
        String newData = "{\"Name\":\"" + escapeJson(cleanName) + "\",\"Status\":\"" + cleanStatus + "\"}";
        auditLogDAO.insertAuditLog(adminId, "CREATE_CATEGORY", "Categories", String.valueOf(newId), null, newData);

        return newId;
    }

    public void updateCategory(int id, String name, String description, String status, Integer adminId) {
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid category ID.");
        }
        String cleanName = trimToEmpty(name);
        String cleanDesc = trimToEmpty(description);
        String cleanStatus = normalizeRequiredStatus(status);

        if (cleanName.isEmpty() || cleanName.length() > 100) {
            throw new IllegalArgumentException("Category name is required and must be at most 100 characters.");
        }
        if (cleanDesc.length() > 500) {
            throw new IllegalArgumentException("Description must be at most 500 characters.");
        }

        Category oldCat = categoryDAO.getCategoryById(id);
        if (oldCat == null) {
            throw new IllegalArgumentException("Category was not found.");
        }

        if (categoryDAO.isCategoryNameExists(cleanName, id)) {
            throw new IllegalArgumentException("Category name '" + cleanName + "' already exists.");
        }

        Category cat = new Category();
        cat.setCategoryId(id);
        cat.setCategoryName(cleanName);
        cat.setDescription(cleanDesc.isEmpty() ? null : cleanDesc);
        cat.setStatus(cleanStatus);

        if (!categoryDAO.updateCategory(cat)) {
            throw new IllegalArgumentException("Unable to update category.");
        }

        // Audit Log
        String oldData = "{\"Name\":\"" + escapeJson(oldCat.getCategoryName()) + "\",\"Status\":\"" + escapeJson(oldCat.getStatus()) + "\"}";
        String newData = "{\"Name\":\"" + escapeJson(cleanName) + "\",\"Status\":\"" + cleanStatus + "\"}";
        auditLogDAO.insertAuditLog(adminId, "UPDATE_CATEGORY", "Categories", String.valueOf(id), oldData, newData);
    }

    public void updateCategoryStatus(int id, String status, Integer adminId) {
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid category ID.");
        }
        String cleanStatus = normalizeRequiredStatus(status);

        Category oldCat = categoryDAO.getCategoryById(id);
        if (oldCat == null) {
            throw new IllegalArgumentException("Category was not found.");
        }

        if (cleanStatus.equalsIgnoreCase(oldCat.getStatus())) {
            return;
        }

        if (!categoryDAO.updateCategoryStatus(id, cleanStatus)) {
            throw new IllegalArgumentException("Unable to update category status.");
        }

        // Audit Log
        String oldData = "{\"Status\":\"" + escapeJson(oldCat.getStatus()) + "\"}";
        String newData = "{\"Status\":\"" + cleanStatus + "\"}";
        auditLogDAO.insertAuditLog(adminId, "UPDATE_CATEGORY_STATUS", "Categories", String.valueOf(id), oldData, newData);
    }

    public String normalizeKeyword(String keyword) {
        return keyword == null ? "" : keyword.trim();
    }

    public String normalizeFilterStatus(String status) {
        String val = status == null || status.isBlank() ? "ALL" : status.trim().toUpperCase();
        return FILTER_STATUSES.contains(val) ? val : "ALL";
    }

    private String normalizeRequiredStatus(String status) {
        String val = trimToEmpty(status).toUpperCase();
        if (!"ACTIVE".equals(val) && !"INACTIVE".equals(val)) {
            throw new IllegalArgumentException("Status must be ACTIVE or INACTIVE.");
        }
        return val;
    }

    private String trimToEmpty(String s) {
        return s == null ? "" : s.trim();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", " ").replace("\n", " ");
    }
}
