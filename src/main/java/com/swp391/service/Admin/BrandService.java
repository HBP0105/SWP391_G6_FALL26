package com.swp391.service.Admin;

import com.swp391.dao.Admin.AuditLogDAO;
import com.swp391.dao.Admin.BrandDAO;
import com.swp391.model.Brand;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Service for Admin Brand Management.
 * Handles validation, business rules, uniqueness check, and AuditLog recording.
 */
public class BrandService {

    public static final int DEFAULT_PAGE_SIZE = 10;
    private static final Set<String> FILTER_STATUSES = Set.of("ALL", "ACTIVE", "INACTIVE");

    private final BrandDAO brandDAO;
    private final AuditLogDAO auditLogDAO;

    public BrandService() {
        this.brandDAO = new BrandDAO();
        this.auditLogDAO = new AuditLogDAO();
    }

    public List<Brand> getBrands(String keyword, String status, int page) {
        int normalizedPage = Math.max(page, 1);
        int offset = (normalizedPage - 1) * DEFAULT_PAGE_SIZE;
        return brandDAO.getBrands(
                normalizeKeyword(keyword),
                normalizeFilterStatus(status),
                offset,
                DEFAULT_PAGE_SIZE
        );
    }

    public int countBrands(String keyword, String status) {
        return brandDAO.countBrands(normalizeKeyword(keyword), normalizeFilterStatus(status));
    }

    public int getTotalPages(int totalItems) {
        return totalItems <= 0 ? 1 : (int) Math.ceil((double) totalItems / DEFAULT_PAGE_SIZE);
    }

    public Map<String, Integer> getBrandStats() {
        return brandDAO.getBrandStats();
    }

    public Brand getBrandById(int id) {
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid brand ID.");
        }
        Brand brand = brandDAO.getBrandById(id);
        if (brand == null) {
            throw new IllegalArgumentException("Brand was not found.");
        }
        return brand;
    }

    public int createBrand(String name, String description, String status, Integer adminId) {
        String cleanName = trimToEmpty(name);
        String cleanDesc = trimToEmpty(description);
        String cleanStatus = normalizeRequiredStatus(status);

        if (cleanName.isEmpty() || cleanName.length() > 100) {
            throw new IllegalArgumentException("Brand name is required and must be at most 100 characters.");
        }
        if (cleanDesc.length() > 500) {
            throw new IllegalArgumentException("Description must be at most 500 characters.");
        }
        if (brandDAO.isBrandNameExists(cleanName, null)) {
            throw new IllegalArgumentException("Brand name '" + cleanName + "' already exists.");
        }

        Brand brand = new Brand();
        brand.setBrandName(cleanName);
        brand.setDescription(cleanDesc.isEmpty() ? null : cleanDesc);
        brand.setStatus(cleanStatus);

        int newId = brandDAO.insertBrand(brand);
        if (newId <= 0) {
            throw new RuntimeException("Failed to create brand in database.");
        }

        // Audit Log
        String newData = "{\"Name\":\"" + escapeJson(cleanName) + "\",\"Status\":\"" + cleanStatus + "\"}";
        auditLogDAO.insertAuditLog(adminId, "CREATE_BRAND", "Brands", String.valueOf(newId), null, newData);

        return newId;
    }

    public void updateBrand(int id, String name, String description, String status, Integer adminId) {
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid brand ID.");
        }
        String cleanName = trimToEmpty(name);
        String cleanDesc = trimToEmpty(description);
        String cleanStatus = normalizeRequiredStatus(status);

        if (cleanName.isEmpty() || cleanName.length() > 100) {
            throw new IllegalArgumentException("Brand name is required and must be at most 100 characters.");
        }
        if (cleanDesc.length() > 500) {
            throw new IllegalArgumentException("Description must be at most 500 characters.");
        }

        Brand oldBrand = brandDAO.getBrandById(id);
        if (oldBrand == null) {
            throw new IllegalArgumentException("Brand was not found.");
        }

        if (brandDAO.isBrandNameExists(cleanName, id)) {
            throw new IllegalArgumentException("Brand name '" + cleanName + "' already exists.");
        }

        Brand brand = new Brand();
        brand.setBrandId(id);
        brand.setBrandName(cleanName);
        brand.setDescription(cleanDesc.isEmpty() ? null : cleanDesc);
        brand.setStatus(cleanStatus);

        if (!brandDAO.updateBrand(brand)) {
            throw new IllegalArgumentException("Unable to update brand.");
        }

        // Audit Log
        String oldData = "{\"Name\":\"" + escapeJson(oldBrand.getBrandName()) + "\",\"Status\":\"" + escapeJson(oldBrand.getStatus()) + "\"}";
        String newData = "{\"Name\":\"" + escapeJson(cleanName) + "\",\"Status\":\"" + cleanStatus + "\"}";
        auditLogDAO.insertAuditLog(adminId, "UPDATE_BRAND", "Brands", String.valueOf(id), oldData, newData);
    }

    public void updateBrandStatus(int id, String status, Integer adminId) {
        if (id <= 0) {
            throw new IllegalArgumentException("Invalid brand ID.");
        }
        String cleanStatus = normalizeRequiredStatus(status);

        Brand oldBrand = brandDAO.getBrandById(id);
        if (oldBrand == null) {
            throw new IllegalArgumentException("Brand was not found.");
        }

        if (cleanStatus.equalsIgnoreCase(oldBrand.getStatus())) {
            return;
        }

        if (!brandDAO.updateBrandStatus(id, cleanStatus)) {
            throw new IllegalArgumentException("Unable to update brand status.");
        }

        // Audit Log
        String oldData = "{\"Status\":\"" + escapeJson(oldBrand.getStatus()) + "\"}";
        String newData = "{\"Status\":\"" + cleanStatus + "\"}";
        auditLogDAO.insertAuditLog(adminId, "UPDATE_BRAND_STATUS", "Brands", String.valueOf(id), oldData, newData);
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
