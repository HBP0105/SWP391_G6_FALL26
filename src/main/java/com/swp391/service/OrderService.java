package com.swp391.service;

import com.swp391.dao.OrderDAO;
import com.swp391.model.Address;
import com.swp391.model.Customer;
import com.swp391.model.Order;
import com.swp391.model.OrderItem;
import com.swp391.model.Payment;
import com.swp391.model.Shipment;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Business Service handling all operations for Order Management.
 * 
 * ARCHITECTURAL DESIGN (SEPARATION OF CONCERNS):
 * - Screen 1 (Order List): Delegates to OrderDAO lightweight subquery JOINs.
 * - Screen 2 (Order Detail): Delegates to OrderDAO full JOIN queries.
 * 
 * Contains 100% of Business Validation Rules, Input Sanitization, State Machine Logic,
 * and Atomic Transaction management.
 */
public class OrderService {

    private final OrderDAO orderDAO;
    private static final int MAX_EXPORT_LIMIT = 5000;

    public OrderService() {
        this.orderDAO = new OrderDAO();
    }

    public OrderService(OrderDAO orderDAO) {
        this.orderDAO = orderDAO;
    }

    /**
     * Input Sanitization Helper: Only strips ORD prefix when keyword matches order ID pattern.
     * Prevents stripping 'ORD' from ordinary search terms like 'ORDER' or 'ORDINARY'. (Item 7 Fix)
     */
    private String cleanKeyword(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return null;
        }
        String trimmed = keyword.trim();
        if (trimmed.matches("(?i)^#?ORD-\\d+$")) {
            return trimmed.replaceAll("(?i)^#?ORD-", "");
        }
        if (trimmed.matches("^#\\d+$")) {
            return trimmed.substring(1);
        }
        return trimmed;
    }

    /**
     * Date Formatting Helper: Formats start date string for database timestamp comparison.
     */
    private String formatStartDate(String startDate) {
        if (startDate == null || startDate.trim().isEmpty()) {
            return null;
        }
        return startDate.trim() + " 00:00:00";
    }

    /**
     * Date Formatting Helper: Converts end date to NEXT DAY 00:00:00 for half-open interval < comparison.
     * Prevents missing fractional seconds at 23:59:59.xxx. (Item 6 Fix)
     */
    private String formatEndDate(String endDate) {
        if (endDate == null || endDate.trim().isEmpty()) {
            return null;
        }
        try {
            LocalDate endLocalDate = LocalDate.parse(endDate.trim());
            LocalDate nextDay = endLocalDate.plusDays(1);
            return nextDay.toString() + " 00:00:00";
        } catch (Exception e) {
            return endDate.trim() + " 23:59:59";
        }
    }

    /**
     * Get a single order by ID (with SQL JOIN).
     */
    public Order getOrderById(int orderId) {
        return orderDAO.getOrderById(orderId);
    }

    /**
     * Get purchased product items for an order.
     */
    public List<OrderItem> getOrderItems(int orderId) {
        return orderDAO.getOrderItems(orderId);
    }

    /**
     * Get paginated orders filtered by status, date range, and search keyword using SQL JOIN.
     */
    public List<Order> getOrdersFiltered(String startDate, String endDate, String status, String keyword,
            int page, int pageSize) {
        String formattedStart = formatStartDate(startDate);
        String formattedEnd = formatEndDate(endDate);
        String cleanedKw = cleanKeyword(keyword);

        return orderDAO.getOrdersFiltered(formattedStart, formattedEnd, 
                status, cleanedKw, page, pageSize);
    }

    /**
     * Get total count of orders filtered by status, date range, and keyword.
     */
    public int getTotalOrdersFilteredCount(String startDate, String endDate, String status, String keyword) {
        String formattedStart = formatStartDate(startDate);
        String formattedEnd = formatEndDate(endDate);
        String cleanedKw = cleanKeyword(keyword);

        return orderDAO.getTotalOrdersFilteredCount(formattedStart, formattedEnd, 
                status, cleanedKw);
    }

    /**
     * State Machine Validation Rule: Checks if transition from currentStatus to newStatus is allowed.
     */
    public boolean isValidStatusTransition(String currentStatus, String newStatus) {
        if (currentStatus == null || newStatus == null) return false;
        if ("PENDING".equalsIgnoreCase(currentStatus)) {
            return "CONFIRMED".equalsIgnoreCase(newStatus) || "CANCELLED".equalsIgnoreCase(newStatus);
        } else if ("CONFIRMED".equalsIgnoreCase(currentStatus)) {
            return "SHIPPING".equalsIgnoreCase(newStatus) || "CANCELLED".equalsIgnoreCase(newStatus);
        } else if ("SHIPPING".equalsIgnoreCase(currentStatus)) {
            return "DELIVERED".equalsIgnoreCase(newStatus);
        }
        return false;
    }

    /**
     * Business Operation: Update Order Status with State Machine Validation and Atomic Transaction (Items 1, 2 & 4 Fix).
     * Executes Orders, Shipments, and Payments updates in a SINGLE atomic database transaction.
     */
    public boolean updateOrderStatus(int orderId, String newStatus, String cancelReason, 
            String shippingProvider, String trackingNumber, String shipperName, String shipperPhone) {
        Order currentOrder = orderDAO.getOrderById(orderId);
        if (currentOrder == null || newStatus == null) {
            return false;
        }

        // 1. Business Rule: Validate status transition using State Machine
        if (!isValidStatusTransition(currentOrder.getOrderStatus(), newStatus)) {
            return false;
        }

        // 2. Business Rule: Require cancelReason and execute Atomic Transaction when status is CANCELLED
        if ("CANCELLED".equalsIgnoreCase(newStatus)) {
            if (cancelReason == null || cancelReason.trim().isEmpty()) {
                return false;
            }
            String sanitizedCancelReason = cancelReason.trim();
            return orderDAO.cancelOrderWithStockRestoration(orderId, sanitizedCancelReason);
        }

        // 3. Execute Atomic Single-Connection Transaction for Orders, Shipments, and Payments
        if (shippingProvider == null || shippingProvider.trim().isEmpty()) {
            shippingProvider = "Giao Hàng Nhanh (GHN)";
        }
        if (trackingNumber == null || trackingNumber.trim().isEmpty()) {
            String prefix = "GHN";
            if (shippingProvider.contains("GHTK")) prefix = "GHTK";
            else if (shippingProvider.contains("VTP") || shippingProvider.contains("Viettel")) prefix = "VTP";
            else if (shippingProvider.contains("SPX") || shippingProvider.contains("Shopee")) prefix = "SPX";
            else if (shippingProvider.contains("VNPost")) prefix = "VNP";
            trackingNumber = prefix + (System.currentTimeMillis() % 1000000000L);
        }

        String cleanShipperName = (shipperName != null && !shipperName.trim().isEmpty()) ? shipperName.trim() : null;
        String cleanShipperPhone = (shipperPhone != null && !shipperPhone.trim().isEmpty()) ? shipperPhone.trim() : null;

        return orderDAO.updateOrderStatusWithShipmentAndPayment(orderId, newStatus.toUpperCase(), 
                null, shippingProvider, trackingNumber, cleanShipperName, cleanShipperPhone);
    }

    /**
     * Business Operation: Validate Start Date and End Date range. (Item 5 Fix)
     */
    public String validateDateRange(String startDate, String endDate) {
        LocalDate today = LocalDate.now();
        if (startDate != null && !startDate.trim().isEmpty()) {
            try {
                LocalDate start = LocalDate.parse(startDate.trim());
                if (start.isAfter(today)) {
                    return "\"From Date\" cannot be in the future!";
                }
            } catch (Exception e) {
                return "Invalid \"From Date\" format (expected YYYY-MM-DD)!";
            }
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            try {
                LocalDate end = LocalDate.parse(endDate.trim());
                if (end.isAfter(today)) {
                    return "\"To Date\" cannot be in the future!";
                }
            } catch (Exception e) {
                return "Invalid \"To Date\" format (expected YYYY-MM-DD)!";
            }
        }
        if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
            try {
                LocalDate start = LocalDate.parse(startDate.trim());
                LocalDate end = LocalDate.parse(endDate.trim());
                if (start.isAfter(end)) {
                    return "\"From Date\" cannot be later than \"To Date\"!";
                }
            } catch (Exception e) {
                return "Invalid date range!";
            }
        }
        return null;
    }

    /**
     * Business Operation: Get Map of status -> count using single SQL query (Item 11 Fix).
     */
    public Map<String, Integer> getOrderStatusCountsMap(String startDate, String endDate) {
        String formattedStart = formatStartDate(startDate);
        String formattedEnd = formatEndDate(endDate);
        return orderDAO.getOrderStatusCountsMap(formattedStart, formattedEnd);
    }

    /**
     * Business Operation: Generate CSV Report Content with Formula Injection Protection (Items 9 & 10 Fix).
     */
    public String generateCSVReport(String startDate, String endDate, String status, String keyword) {
        String dateError = validateDateRange(startDate, endDate);
        if (dateError != null) {
            return "\uFEFF\"Export Error: " + dateError.replace("\"", "\"\"") + "\"\n";
        }

        List<Order> matchingOrders = getOrdersFiltered(startDate, endDate, status, keyword, 1, MAX_EXPORT_LIMIT);

        StringBuilder sb = new StringBuilder();
        sb.append('\uFEFF');
        sb.append("\"Order ID\",\"Customer Account\",\"Receiver Name\",\"Receiver Phone\",\"Delivery Address\","
                + "\"Product Name\",\"Total Quantity\",\"Shipper Name\",\"Shipper Phone\",\"Total Amount (VND)\",\"Order Date\",\"Status\"\n");

        for (Order o : matchingOrders) {
            Customer cust = o.getCustomer();
            Address addr = o.getAddress();
            String pSummary = o.getProductSummary() != null ? o.getProductSummary() : "Headphone Product";

            String custName = cust != null && cust.getFullName() != null ? cust.getFullName() : "";
            String recName = addr != null && addr.getReceiverName() != null && !addr.getReceiverName().trim().isEmpty() 
                    ? addr.getReceiverName() : custName;
            String recPhone = addr != null && addr.getReceiverPhone() != null && !addr.getReceiverPhone().trim().isEmpty() 
                    ? addr.getReceiverPhone() : (cust != null && cust.getPhone() != null ? cust.getPhone() : "");
            String delivAddr = o.getShippingAddress() != null && !o.getShippingAddress().trim().isEmpty() 
                    ? o.getShippingAddress() : (addr != null && addr.getFullAddress() != null ? addr.getFullAddress() : "");
            
            String shipperName = o.getShippingName() != null ? o.getShippingName() : "";
            String shipperPhone = o.getShippingPhone() != null ? o.getShippingPhone() : "";
            int qty = o.getTotalQuantity() > 0 ? o.getTotalQuantity() : 1;

            sb.append("\"#ORD-").append(o.getOrderID()).append("\",");
            sb.append("\"").append(escapeCSV(custName)).append("\",");
            sb.append("\"").append(escapeCSV(recName)).append("\",");
            sb.append("\"").append(escapeCSV(recPhone)).append("\",");
            sb.append("\"").append(escapeCSV(delivAddr)).append("\",");
            sb.append("\"").append(escapeCSV(pSummary)).append("\",");
            sb.append("\"").append(qty).append("\",");
            sb.append("\"").append(escapeCSV(shipperName)).append("\",");
            sb.append("\"").append(escapeCSV(shipperPhone)).append("\",");

            String totalStr = "0";
            if (o.getTotalAmount() != null) {
                java.text.DecimalFormat formatter = new java.text.DecimalFormat("#,###");
                java.text.DecimalFormatSymbols symbols = new java.text.DecimalFormatSymbols();
                symbols.setGroupingSeparator('.');
                formatter.setDecimalFormatSymbols(symbols);
                totalStr = formatter.format(o.getTotalAmount());
            }
            sb.append("\"").append(totalStr).append("\",");

            String dateStr = "";
            if (o.getOrderDate() != null) {
                dateStr = o.getOrderDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
            }
            sb.append("\"").append(escapeCSV(dateStr)).append("\",");
            sb.append("\"").append(escapeCSV(o.getOrderStatus())).append("\"\n");
        }
        return sb.toString();
    }

    /**
     * CSV Formula Injection & Quote Escaping Helper (Item 9 Fix).
     * Sanitizes values starting with =, +, -, @, \t, or \r to prevent formula injection.
     */
    private String escapeCSV(String value) {
        if (value == null) return "";
        String clean = value.replace("\"", "\"\"");
        if (clean.startsWith("=") || clean.startsWith("+") || clean.startsWith("-") 
                || clean.startsWith("@") || clean.startsWith("\t") || clean.startsWith("\r")) {
            clean = "'" + clean;
        }
        return clean;
    }

    /**
     * Business Operation: Aggregate all data, filters, counts, and pagination math for Screen 1 Order List View.
     */
    public Map<String, Object> getOrderListBundle(String startDate, String endDate, String statusFilter, 
            String keyword, String pageParam, int pageSize) {
        Map<String, Object> bundle = new HashMap<>();

        // 1. Pagination size validation (default 10 orders per page)
        int validPageSize = pageSize > 0 && pageSize <= 100 ? pageSize : 10;

        // 2. Date range validation
        String msgError = validateDateRange(startDate, endDate);
        if (msgError != null) {
            bundle.put("msgError", msgError);
            bundle.put("orders", new ArrayList<>());
            bundle.put("pendingCount", 0);
            bundle.put("confirmedCount", 0);
            bundle.put("shippingCount", 0);
            bundle.put("deliveredCount", 0);
            bundle.put("cancelledCount", 0);
            bundle.put("selectedStatus", statusFilter != null ? statusFilter : "ALL");
            bundle.put("selectedStartDate", startDate != null ? startDate : "");
            bundle.put("selectedEndDate", endDate != null ? endDate : "");
            bundle.put("selectedKeyword", keyword != null ? keyword : "");
            bundle.put("currentPage", 1);
            bundle.put("pageSize", validPageSize);
            bundle.put("totalPages", 1);
            bundle.put("totalOrders", 0);
            return bundle;
        }

        // 3. Single-query metric summary cards
        Map<String, Integer> counts = getOrderStatusCountsMap(startDate, endDate);
        bundle.put("pendingCount", counts.getOrDefault("PENDING", 0));
        bundle.put("confirmedCount", counts.getOrDefault("CONFIRMED", 0));
        bundle.put("shippingCount", counts.getOrDefault("SHIPPING", 0));
        bundle.put("deliveredCount", counts.getOrDefault("DELIVERED", 0));
        bundle.put("cancelledCount", counts.getOrDefault("CANCELLED", 0));

        // 4. Pagination math & boundary checks
        int page = 1;
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        if (page < 1) page = 1;

        int totalOrders = getTotalOrdersFilteredCount(startDate, endDate, statusFilter, keyword);
        int totalPages = (int) Math.ceil((double) totalOrders / validPageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Order> orderList = getOrdersFiltered(startDate, endDate, statusFilter,
                keyword, page, validPageSize);

        bundle.put("orders", orderList);
        bundle.put("selectedStatus", statusFilter != null ? statusFilter : "ALL");
        bundle.put("selectedStartDate", startDate != null ? startDate : "");
        bundle.put("selectedEndDate", endDate != null ? endDate : "");
        bundle.put("selectedKeyword", keyword != null ? keyword : "");
        bundle.put("currentPage", page);
        bundle.put("pageSize", validPageSize);
        bundle.put("totalPages", totalPages);
        bundle.put("totalOrders", totalOrders);

        return bundle;
    }

    /**
     * Business Operation: Process Order Status Update with centralized error messages and business rule validations.
     */
    public String processStatusUpdate(int orderId, String newStatus, String cancelReason, 
            String shippingProvider, String trackingNumber, String shipperName, String shipperPhone) {
        if (orderId <= 0) {
            return "Invalid Order ID specified!";
        }
        Order order = getOrderById(orderId);
        if (order == null) {
            return "Order #ORD-" + orderId + " was not found in database!";
        }
        if ("CANCELLED".equalsIgnoreCase(newStatus) && (cancelReason == null || cancelReason.trim().isEmpty())) {
            return "Cancellation reason is required when cancelling an order!";
        }
        if (!isValidStatusTransition(order.getOrderStatus(), newStatus)) {
            return "Invalid status transition for Order #ORD-" + orderId + "!";
        }
        boolean success = updateOrderStatus(orderId, newStatus, cancelReason, shippingProvider, trackingNumber, shipperName, shipperPhone);
        if (!success) {
            return "Failed to update order status for Order #ORD-" + orderId + "!";
        }
        return null;
    }

    public String processStatusUpdate(int orderId, String newStatus, String cancelReason, 
            String shippingProvider, String trackingNumber) {
        return processStatusUpdate(orderId, newStatus, cancelReason, shippingProvider, trackingNumber, null, null);
    }

    /**
     * Business Operation: Aggregate all details for Screen 2 Order Detail view in a single bundle
     * (Item 3 Fix: Preserves recorded TotalAmount including shipping fees/discounts if present).
     */
    public Map<String, Object> getOrderDetailBundle(int orderId) {
        Order order = orderDAO.getOrderDetailWithJoin(orderId);
        if (order == null) return null;

        List<OrderItem> items = getOrderItems(orderId);

        // Item 3 Fix: Only calculate total from items if order.getTotalAmount() is missing or zero
        if (order.getTotalAmount() == null || order.getTotalAmount().compareTo(java.math.BigDecimal.ZERO) <= 0) {
            if (items != null && !items.isEmpty()) {
                java.math.BigDecimal calculatedTotal = java.math.BigDecimal.ZERO;
                for (OrderItem item : items) {
                    if (item.getSubtotal() != null) {
                        calculatedTotal = calculatedTotal.add(item.getSubtotal());
                    }
                }
                if (calculatedTotal.compareTo(java.math.BigDecimal.ZERO) > 0) {
                    order.setTotalAmount(calculatedTotal);
                }
            }
        }

        Map<String, Object> bundle = new HashMap<>();
        bundle.put("order", order);
        bundle.put("customer", order.getCustomer());
        bundle.put("address", order.getAddress());
        bundle.put("shipment", order.getShipment());
        bundle.put("payment", order.getPayment());
        bundle.put("items", items);

        // Fetch AI 512-Vector recommendations for customer care and cross-selling
        List<Map<String, Object>> aiRecommendations = orderDAO.getAIRecommendationsForOrder(order.getCustomerID(), orderId);
        bundle.put("aiRecommendations", aiRecommendations);

        return bundle;
    }
}
