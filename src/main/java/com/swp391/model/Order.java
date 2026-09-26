package com.swp391.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Order {

    private int orderID;
    private int customerID;
    private BigDecimal totalAmount;
    private String shippingName;
    private String shippingPhone;
    private String shippingAddress;
    private String orderStatus;
    private String cancelReason;
    private LocalDateTime orderDate;
    private LocalDateTime updatedAt;

    public Order() {
    }

    public Order(int orderID, int customerID, BigDecimal totalAmount,
            String shippingName, String shippingPhone, String shippingAddress,
            String orderStatus, LocalDateTime orderDate, LocalDateTime updatedAt) {
        this.orderID = orderID;
        this.customerID = customerID;
        this.totalAmount = totalAmount;
        this.shippingName = shippingName;
        this.shippingPhone = shippingPhone;
        this.shippingAddress = shippingAddress;
        this.orderStatus = orderStatus;
        this.orderDate = orderDate;
        this.updatedAt = updatedAt;
    }

    public int getOrderID() {
        return orderID;
    }

    public void setOrderID(int orderID) {
        this.orderID = orderID;
    }

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getShippingName() {
        return shippingName;
    }

    public void setShippingName(String shippingName) {
        this.shippingName = shippingName;
    }

    public String getShippingPhone() {
        return shippingPhone;
    }

    public void setShippingPhone(String shippingPhone) {
        this.shippingPhone = shippingPhone;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getCancelReason() {
        return cancelReason;
    }

    public void setCancelReason(String cancelReason) {
        this.cancelReason = cancelReason;
    }

    public LocalDateTime getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(LocalDateTime orderDate) {
        this.orderDate = orderDate;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getFormattedTotalAmount() {
        if (totalAmount == null) return "0";
        java.text.DecimalFormat formatter = new java.text.DecimalFormat("#,###");
        java.text.DecimalFormatSymbols symbols = new java.text.DecimalFormatSymbols();
        symbols.setGroupingSeparator('.');
        formatter.setDecimalFormatSymbols(symbols);
        return formatter.format(totalAmount);
    }

    public String getFormattedOrderDate() {
        if (orderDate == null) return "";
        return orderDate.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
    }

    public String getFormattedOrderDateOnly() {
        if (orderDate == null) return "";
        return orderDate.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    public String getFormattedOrderTimeOnly() {
        if (orderDate == null) return "";
        return orderDate.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss"));
    }

    public String getFormattedUpdatedAt() {
        if (updatedAt == null) {
            return orderDate != null ? getFormattedOrderDate() : "N/A";
        }
        return updatedAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
    }
}
