package com.swp391.service;

import com.swp391.dao.Manager.VoucherDao;
import com.swp391.model.Voucher;

import java.math.BigDecimal;
import java.util.List;

public class VoucherService {

    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final int MAX_PAGE_SIZE = 50;

    private final VoucherDao voucherDao;

    public VoucherService() {
        this.voucherDao = new VoucherDao();
    }

    public List<Voucher> getAllVouchers() {
        return voucherDao.getAllVouchers();
    }

    public List<Voucher> getVouchers(
            String keyword,
            String discountType,
            String status,
            String validPeriod,
            String sort,
            int page,
            int pageSize) {

        page = normalizePage(page);
        pageSize = normalizePageSize(pageSize);

        int offset = (page - 1) * pageSize;

        return voucherDao.getVouchers(
                normalize(keyword),
                normalize(discountType),
                normalize(status),
                normalize(validPeriod),
                normalize(sort),
                offset,
                pageSize
        );
    }

    public int countVouchers(
            String keyword,
            String discountType,
            String status,
            String validPeriod) {

        return voucherDao.countVouchers(
                normalize(keyword),
                normalize(discountType),
                normalize(status),
                normalize(validPeriod)
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

    public Voucher getVoucherById(int id) {
        if (id <= 0) {
            return null;
        }
        return voucherDao.getVoucherById(id);
    }

    public boolean insertVoucher(Voucher voucher) {
        validateVoucher(voucher);

        // Normalize
        voucher.setVoucherCode(voucher.getVoucherCode().trim().toUpperCase());
        if (voucher.getDescription() != null) {
            voucher.setDescription(voucher.getDescription().trim());
        }

        // Check unique code
        Voucher existing = voucherDao.getVoucherByCode(voucher.getVoucherCode());
        if (existing != null) {
            throw new IllegalArgumentException("Voucher code '" + voucher.getVoucherCode() + "' already exists.");
        }

        return voucherDao.insertVoucher(voucher);
    }

    public boolean changeStatus(int voucherId, String status) {
        if (voucherId <= 0) {
            return false;
        }
        if (!"ACTIVE".equalsIgnoreCase(status) && !"INACTIVE".equalsIgnoreCase(status) && !"EXPIRED".equalsIgnoreCase(status)) {
            throw new IllegalArgumentException("Invalid voucher status.");
        }
        return voucherDao.updateStatus(voucherId, status.toUpperCase());
    }

    private void validateVoucher(Voucher v) {
        if (v == null) {
            throw new IllegalArgumentException("Voucher data is required.");
        }
        if (v.getVoucherCode() == null || v.getVoucherCode().trim().isEmpty()) {
            throw new IllegalArgumentException("Voucher code cannot be empty.");
        }
        if (v.getDiscountType() == null || (!"PERCENT".equalsIgnoreCase(v.getDiscountType()) && !"FIXED".equalsIgnoreCase(v.getDiscountType()))) {
            throw new IllegalArgumentException("Discount type must be PERCENT or FIXED.");
        }
        if (v.getDiscountValue() == null || v.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Discount value must be greater than 0.");
        }
        if ("PERCENT".equalsIgnoreCase(v.getDiscountType()) && v.getDiscountValue().compareTo(new BigDecimal("100")) > 0) {
            throw new IllegalArgumentException("Percentage discount cannot exceed 100%.");
        }
        if (v.getMinOrderAmount() != null && v.getMinOrderAmount().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Minimum order amount cannot be negative.");
        }
        if (v.getMaxDiscount() != null && v.getMaxDiscount().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Maximum discount cannot be negative.");
        }
        if (v.getStartDate() == null) {
            throw new IllegalArgumentException("Start date is required.");
        }
        if (v.getEndDate() == null) {
            throw new IllegalArgumentException("End date is required.");
        }
        if (!v.getEndDate().isAfter(v.getStartDate())) {
            throw new IllegalArgumentException("End date must be after start date.");
        }
        if (v.getUsageLimit() != null && v.getUsageLimit() <= 0) {
            throw new IllegalArgumentException("Usage limit must be greater than 0.");
        }
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
