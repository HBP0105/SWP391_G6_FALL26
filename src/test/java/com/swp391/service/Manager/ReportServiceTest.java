package com.swp391.service.Manager;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class ReportServiceTest {

    private final ReportService reportService = new ReportService();

    @Test
    void keepsDatesSubmittedWithoutAPresetPeriod() {
        Map<String, Object> filters = reportService.resolveFilters(
                null, "2025-01-10", "2025-01-20", null, null
        );

        assertEquals("custom", filters.get("period"));
        assertEquals("2025-01-10", filters.get("startDate"));
        assertEquals("2025-01-20", filters.get("endDate"));
    }

    @Test
    void acceptsOneSidedDateRangeLikeInventoryTransactions() {
        Map<String, Object> filters = reportService.resolveFilters(
                null, "2025-01-10", null, null, null
        );

        assertEquals("custom", filters.get("period"));
        assertEquals("2025-01-10", filters.get("startDate"));
        assertEquals("", filters.get("endDate"));
    }

    @Test
    void rejectsFutureDates() {
        String futureDate = LocalDate.now().plusDays(1).toString();

        assertThrows(IllegalArgumentException.class,
                () -> reportService.resolveFilters(null, futureDate, null, null, null));
    }

    @Test
    void rejectsStartDateAfterEndDate() {
        assertThrows(IllegalArgumentException.class,
                () -> reportService.resolveFilters(
                        null, "2025-02-01", "2025-01-31", null, null
                ));
    }

    @Test
    void explicitAllPeriodStillClearsDates() {
        Map<String, Object> filters = reportService.resolveFilters(
                "all", "2025-01-10", "2025-01-20", null, null
        );

        assertEquals("all", filters.get("period"));
        assertEquals("", filters.get("startDate"));
        assertEquals("", filters.get("endDate"));
    }
}
