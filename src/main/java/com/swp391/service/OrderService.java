package com.swp391.service;

import com.swp391.dao.OrderDAO;
import com.swp391.model.Address;
import com.swp391.model.Customer;
import com.swp391.model.Order;
import com.swp391.model.OrderItem;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderService {

    private final OrderDAO orderDAO;
    private final AIPerformanceService aiPerformanceService;
    private final com.swp391.dao.AuditLogDAO auditLogDAO;
    private static final int MAX_EXPORT_LIMIT = 5000;

    public OrderService() {
        this.orderDAO = new OrderDAO();
        this.aiPerformanceService = new AIPerformanceService();
        this.auditLogDAO = new com.swp391.dao.AuditLogDAO();
    }

    public OrderService(OrderDAO orderDAO) {
        this.orderDAO = orderDAO;
        this.aiPerformanceService = new AIPerformanceService();
        this.auditLogDAO = new com.swp391.dao.AuditLogDAO();
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
     * Business Operation: Get Map of status -> count using single SQL query
     * (Item 11 Fix).
     */
    public Map<String, Integer> getOrderStatusCountsMap(String startDate, String endDate) {
        String formattedStart = formatStartDate(startDate);
        String formattedEnd = formatEndDate(endDate);
        return orderDAO.getOrderStatusCountsMap(formattedStart, formattedEnd);
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
     * Get paginated orders filtered by status, date range, and search keyword
     * using SQL JOIN.
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
     * Business Operation: Aggregate all data, filters, counts, and pagination
     * math for Screen 1 Order List View.
     */
    public Map<String, Object> getOrderListBundle(String startDate, String endDate, String statusFilter,
            String keyword, String pageParam, int pageSize) {
        Map<String, Object> bundle = new HashMap<>();

        // 1. Pagination size validation (default 10 orders per page)
        int validPageSize = pageSize > 0 && pageSize <= 100 ? pageSize : 10;

        // 2. Date range validation
        String dateError = validateDateRange(startDate, endDate);
        if (dateError != null) {
            bundle.put("msgError", dateError);
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
        if (page < 1) {
            page = 1;
        }

        int totalOrders = getTotalOrdersFilteredCount(startDate, endDate, statusFilter, keyword);
        int totalPages = (int) Math.ceil((double) totalOrders / validPageSize);
        if (totalPages < 1) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
        }

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
     * Input Sanitization Helper: Only strips ORD prefix when keyword matches
     * order ID pattern. Prevents stripping 'ORD' from ordinary search terms
     * like 'ORDER' or 'ORDINARY'. (Item 7 Fix)
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

    private String formatStartDate(String startDate) {
        if (startDate == null || startDate.trim().isEmpty()) {
            return null;
        }
        return startDate.trim() + " 00:00:00";
    }

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
     * State Machine Validation Rule: Checks if transition from currentStatus to
     * newStatus is allowed.
     */
    public boolean isValidStatusTransition(String currentStatus, String newStatus) {
        if (currentStatus == null || newStatus == null) {
            return false;
        }
        if ("PENDING".equalsIgnoreCase(currentStatus)) {
            return "CONFIRMED".equalsIgnoreCase(newStatus) || "CANCELLED".equalsIgnoreCase(newStatus);
        } else if ("CONFIRMED".equalsIgnoreCase(currentStatus)) {
            return "SHIPPING".equalsIgnoreCase(newStatus) || "CANCELLED".equalsIgnoreCase(newStatus);
        } else if ("SHIPPING".equalsIgnoreCase(currentStatus)) {
            return "DELIVERED".equalsIgnoreCase(newStatus) || "CANCELLED".equalsIgnoreCase(newStatus);
        }
        return false;
    }

    /**
     * Executes order status update: state machine validation, inventory restoration on CANCELLED,
     * or updating shipment and payment on SHIPPING/DELIVERED.
     */
    public boolean updateOrderStatus(int orderId,String expectedCurrentStatus,String newStatus,String cancelReason,
            String shippingProvider,String trackingNumber,String shipperName,String shipperPhone,List<OrderItem> items) {

        if (expectedCurrentStatus == null || newStatus == null) {
            return false;
        }

        // 1. Business Rule: Validate status transition using State Machine
        if (!isValidStatusTransition(expectedCurrentStatus, newStatus)) {
            return false;
        }

        // 2. Business Rule: Require cancelReason and execute Atomic Transaction when status is CANCELLED
        if ("CANCELLED".equalsIgnoreCase(newStatus)) {
            return cancelOrder(orderId, expectedCurrentStatus, cancelReason, items);
        }

        // 3. Execute Atomic Single-Connection Transaction for Orders, Shipments, and Payments
        String provider = (shippingProvider == null || shippingProvider.isBlank())
                ? "Giao Hàng Nhanh (GHN)" : shippingProvider.trim();

        String tracking = trackingNumber == null ? "" : trackingNumber.trim();

        if ("SHIPPING".equalsIgnoreCase(newStatus) && tracking.isEmpty()) {
            String prefix = "GHN";
            if (provider.contains("GHTK")) {
                prefix = "GHTK";
            } else if (provider.contains("VTP") || provider.contains("Viettel")) {
                prefix = "VTP";
            } else if (provider.contains("SPX") || provider.contains("Shopee")) {
                prefix = "SPX";
            } else if (provider.contains("VNPost")) {
                prefix = "VNP";
            }
            tracking = prefix + java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        }

        String cleanShipperName = (shipperName == null || shipperName.isBlank()) ? null : shipperName.trim();
        String cleanShipperPhone = (shipperPhone == null || shipperPhone.isBlank()) ? null : shipperPhone.trim();

        boolean success = orderDAO.updateOrderStatusWithShipmentAndPayment(
                orderId,
                expectedCurrentStatus,
                newStatus.toUpperCase(java.util.Locale.ROOT),
                null,
                provider,
                tracking,
                cleanShipperName,
                cleanShipperPhone
        );

        if (success) {
            String details = "Status: " + expectedCurrentStatus + " -> " + newStatus;
            if ("SHIPPING".equalsIgnoreCase(newStatus)) {
                details += " (Carrier: " + provider + ", Tracking: " + tracking + ")";
            }
            auditLogDAO.insertAuditLog(null, "UPDATE_STATUS", "Orders", "#ORD-" + orderId,
                    "Status: " + expectedCurrentStatus, details);
        }

        return success;
    }

    /**
     * Business Validation: Validates order items before restoring stock on order cancellation.
     */
    public String validateOrderItems(int orderId, List<OrderItem> items) {
        if (items == null || items.isEmpty()) {
            return "Danh sách sản phẩm hoàn kho không được để trống: Order #" + orderId;
        }
        for (OrderItem item : items) {
            if (item == null) {
                return "Dữ liệu sản phẩm không được null khi hoàn kho đơn #" + orderId;
            }
            if (item.getOrderID() != orderId) {
                return "Sản phẩm #" + item.getProductID() + " không thuộc đơn hàng #" + orderId;
            }
            if (item.getProductID() <= 0 || item.getQuantity() <= 0) {
                return "ProductID hoặc Quantity không hợp lệ khi hoàn kho đơn #" + orderId;
            }
        }
        return null;
    }

    /**
     * Cancel Order with Stock Restoration and Inventory Log (Teacher's Criteria).
     * Validates cancel reason and order items at Service layer before invoking DAO transaction.
     */
    public boolean cancelOrder(int orderId, String expectedCurrentStatus, String cancelReason, List<OrderItem> items) {
        if (cancelReason == null || cancelReason.isBlank()) {
            return false;
        }

        String itemValidationError = validateOrderItems(orderId, items);
        if (itemValidationError != null) {
            return false;
        }

        boolean success = orderDAO.cancelOrderWithStockRestoration(orderId, expectedCurrentStatus,
                cancelReason.trim(), items
        );
        if (success) {
            auditLogDAO.insertAuditLog(null, "CANCEL_ORDER", "Orders", "#ORD-" + orderId,
                    "Status: " + expectedCurrentStatus, "Status: CANCELLED (Reason: " + cancelReason.trim() + ")");
        }
        return success;
    }

    /**
     * Business Operation: Generate CSV Report Content with Formula Injection
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
                    ? o.getShippingAddress() : (addr != null && addr.getAddressLine() != null ? addr.getAddressLine() : "");

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
     * CSV Formula Injection & Quote Escaping Helper (Item 9 Fix). Sanitizes
     */
    private String escapeCSV(String value) {
        if (value == null) {
            return "";
        }
        String clean = value.replace("\"", "\"\"");
        if (clean.startsWith("=") || clean.startsWith("+") || clean.startsWith("-")
                || clean.startsWith("@") || clean.startsWith("\t") || clean.startsWith("\r")) {
            clean = "'" + clean;
        }
        return clean;
    }

    /**
     * Business Operation: Process Order Status Update with centralized error
     * messages and business rule validations.
     */
    public String processStatusUpdate(int orderId, String newStatus, String cancelReason,String shippingProvider, 
            String trackingNumber, String shipperName, String shipperPhone, List<OrderItem> items) {
        if (orderId <= 0) {
            return "Invalid Order ID specified!";
        }
        
        Map<String, Object> detail = orderDAO.getOrderDetailWithJoin(orderId);
        if (detail == null || detail.get("order") == null) {
            return "Order #ORD-" + orderId + " was not found order!";
        }
        Order order = (Order) detail.get("order");

        
        List<OrderItem> detailItems = (List<OrderItem>) detail.get("items");
        List<OrderItem> finalItems = (items != null && !items.isEmpty()) ? items : detailItems;

        if ("CANCELLED".equalsIgnoreCase(newStatus)) {
            if (cancelReason == null || cancelReason.trim().isEmpty()) {
                return "Cancellation reason is required when cancelling an order!";
            }
            String itemValidationError = validateOrderItems(orderId, finalItems);
            if (itemValidationError != null) {
                return itemValidationError;
            }
        }
        if ("SHIPPING".equalsIgnoreCase(newStatus) && shipperPhone != null && !shipperPhone.trim().isEmpty()) {
            String cleanPhone = shipperPhone.trim();
            if (!cleanPhone.matches("^0[35789]\\d{8}$")) {
                return "Số điện thoại người giao hàng (Shipper) không hợp lệ! Vui lòng nhập 10 chữ số (bắt đầu bằng 03, 05, 07, 08, 09).";
            }
        }
        if (!isValidStatusTransition(order.getOrderStatus(), newStatus)) {
            return "Invalid status transition for Order #ORD-" + orderId + "!";
        }
        boolean success = updateOrderStatus(orderId, order.getOrderStatus(), newStatus, cancelReason,
                shippingProvider, trackingNumber, shipperName, shipperPhone, finalItems);
        if (!success) {
            return "Failed to update order status for Order #ORD-" + orderId + "!";
        }
        return null;
    }

    public String processStatusUpdate(int orderId, String newStatus, String cancelReason,
            String shippingProvider, String trackingNumber, String shipperName, String shipperPhone) {
        return processStatusUpdate(orderId, newStatus, cancelReason, shippingProvider, trackingNumber, shipperName, shipperPhone, null);
    }


    public Map<String, Object> getOrderDetailBundle(int orderId) {
        Map<String, Object> detailData = orderDAO.getOrderDetailWithJoin(orderId);
        if (detailData == null || detailData.get("order") == null) {
            return null;
        }

        Order order = (Order) detailData.get("order");
        @SuppressWarnings("unchecked")
        List<OrderItem> items = (List<OrderItem>) detailData.get("items");
        if (items == null) {
            items = new ArrayList<>();
        }

        Map<String, Object> bundle = new HashMap<>();
        bundle.put("order", order);
        bundle.put("customer", order.getCustomer());
        bundle.put("address", order.getAddress());
        bundle.put("shipment", order.getShipment());
        bundle.put("payment", order.getPayment());
        bundle.put("items", items);

        // Fetch AI 512-Vector recommendations for customer retention ONLY if order is CANCELLED
        List<Map<String, Object>> aiRecommendations = new ArrayList<>();
        if (order != null && "CANCELLED".equalsIgnoreCase(order.getOrderStatus())) {
            int cancelledProductId = (items != null && !items.isEmpty()) ? items.get(0).getProductId() : 0;
            aiRecommendations = getAlternativeRecommendationsForOrder(cancelledProductId, order.getCustomerID(), orderId);
        }
        bundle.put("aiRecommendations", aiRecommendations);

        return bundle;
    }

    private List<Map<String, Object>> getAlternativeRecommendationsForOrder(int cancelledProductId, int customerId, int orderId) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (cancelledProductId > 0 && aiPerformanceService != null) {
            try {
                List<Map<String, Object>> recs = aiPerformanceService.getRecommendedProductsForDetail(cancelledProductId, customerId, "cancel-order-" + orderId);
                if (recs != null && !recs.isEmpty()) {
                    for (Map<String, Object> r : recs) {
                        Map<String, Object> map = new HashMap<>(r);
                        map.put("productID", r.get("productId"));
                        int match = r.containsKey("matchPercentage") ? (int) r.get("matchPercentage") : 85;
                        map.put("similarityPercent", String.valueOf(match));
                        map.put("recommendationType", "ALTERNATIVE");
                        map.put("reason", "Alternative product: " + match + "% match in sound profile, specs & price point for customer retention");
                        list.add(map);
                    }
                    return list;
                }
            } catch (Exception ignored) {
            }
        }
        return orderDAO.getAIRecommendationsForOrder(customerId, orderId);
    }
}
