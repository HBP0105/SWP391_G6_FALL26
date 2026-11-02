package com.swp391.service;

import com.swp391.dao.AuditLogDAO;
import com.swp391.model.AuditLog;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service Layer for System Audit Logs (Feature 5).
 * Encapsulates business validation, pagination calculations, and activity logging.
 */
public class AuditLogService {

    private final AuditLogDAO auditLogDAO;

    public AuditLogService() {
        this.auditLogDAO = new AuditLogDAO();
    }

    public AuditLogService(AuditLogDAO auditLogDAO) {
        this.auditLogDAO = auditLogDAO;
    }

    /**
     * Prepares and packages all data required for the Audit Log Dashboard view.
     */
    public Map<String, Object> getAuditLogBundle(String startDate, String endDate,
                                                 String action, String keyword,
                                                 String pageParam, int pageSize) {
        Map<String, Object> bundle = new HashMap<>();

        String cleanStart = (startDate != null && !startDate.trim().isEmpty()) ? startDate.trim() : null;
        String cleanEnd = (endDate != null && !endDate.trim().isEmpty()) ? endDate.trim() : null;

        // Date range & future date validation
        String msgError = null;
        LocalDate today = LocalDate.now();

        if (cleanStart != null) {
            try {
                LocalDate start = LocalDate.parse(cleanStart);
                if (start.isAfter(today)) {
                    msgError = "Validation Error: 'From Date' cannot be in the future!";
                    cleanStart = null;
                }
            } catch (Exception e) {
                cleanStart = null;
            }
        }

        if (cleanEnd != null) {
            try {
                LocalDate end = LocalDate.parse(cleanEnd);
                if (end.isAfter(today)) {
                    msgError = "Validation Error: 'To Date' cannot be in the future!";
                    cleanEnd = null;
                }
            } catch (Exception e) {
                cleanEnd = null;
            }
        }

        if (cleanStart != null && cleanEnd != null) {
            try {
                LocalDate start = LocalDate.parse(cleanStart);
                LocalDate end = LocalDate.parse(cleanEnd);
                if (start.isAfter(end)) {
                    msgError = "Validation Error: 'From Date' cannot be later than 'To Date'!";
                    cleanStart = null;
                    cleanEnd = null;
                }
            } catch (Exception ignored) {
            }
        }

        if (msgError != null) {
            bundle.put("msgError", msgError);
        }

        String formattedStart = (cleanStart != null) ? cleanStart + " 00:00:00" : null;
        String formattedEnd = null;
        if (cleanEnd != null) {
            try {
                LocalDate endD = LocalDate.parse(cleanEnd);
                formattedEnd = endD.plusDays(1).toString() + " 00:00:00";
            } catch (Exception e) {
                formattedEnd = cleanEnd + " 23:59:59";
            }
        }

        String cleanAction = (action != null && !action.trim().isEmpty() && !"ALL".equalsIgnoreCase(action.trim()))
                ? action.trim() : null;
        String cleanKeyword = (keyword != null && !keyword.trim().isEmpty()) ? keyword.trim() : null;

        // Pagination calculations
        int page = 1;
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {
                page = 1;
            }
        }
        int validPageSize = pageSize > 0 ? pageSize : 15;

        int totalCount = auditLogDAO.getTotalAuditLogsCount(formattedStart, formattedEnd, cleanAction, cleanKeyword);
        int totalPages = (int) Math.ceil((double) totalCount / validPageSize);
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }

        List<AuditLog> logs = auditLogDAO.getAuditLogsFiltered(
                formattedStart, formattedEnd, cleanAction, cleanKeyword, page, validPageSize);

        Map<String, Integer> metrics = auditLogDAO.getAuditLogMetrics();
        List<String> distinctActions = auditLogDAO.getDistinctActions();

        bundle.put("logs", logs);
        bundle.put("totalLogs", metrics.getOrDefault("totalLogs", 0));
        bundle.put("todayLogs", metrics.getOrDefault("todayLogs", 0));
        bundle.put("orderLogs", metrics.getOrDefault("orderLogs", 0));
        bundle.put("configLogs", metrics.getOrDefault("configLogs", 0));
        bundle.put("distinctActions", distinctActions);

        bundle.put("selectedStartDate", cleanStart != null ? cleanStart : "");
        bundle.put("selectedEndDate", cleanEnd != null ? cleanEnd : "");
        bundle.put("selectedAction", cleanAction != null ? cleanAction : "ALL");
        bundle.put("selectedKeyword", cleanKeyword != null ? cleanKeyword : "");

        bundle.put("currentPage", page);
        bundle.put("pageSize", validPageSize);
        bundle.put("totalPages", totalPages);
        bundle.put("totalCount", totalCount);

        return bundle;
    }

    /**
     * Records a new activity log entry in the system.
     */
    public boolean logActivity(Integer staffId, String action, String entityName,
                               String entityId, String oldData, String newData) {
        return auditLogDAO.insertAuditLog(staffId, action, entityName, entityId, oldData, newData);
    }
}
