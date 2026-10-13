package com.swp391.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Shipment {

    private long shipmentId;
    private int orderId;
    private String shippingProvider;
    private String trackingNumber;
    private String shippingAddress;
    private String shippingStatus;
    private LocalDate estimatedDeliveryDate;
    private LocalDateTime shippedAt;
    private LocalDateTime deliveredAt;

    public Shipment() {
    }

    public Shipment(long shipmentId, int orderId, String shippingProvider,
            String trackingNumber, String shippingAddress, String shippingStatus,
            LocalDateTime shippedAt, LocalDateTime deliveredAt) {
        this.shipmentId = shipmentId;
        this.orderId = orderId;
        this.shippingProvider = shippingProvider;
        this.trackingNumber = trackingNumber;
        this.shippingAddress = shippingAddress;
        this.shippingStatus = shippingStatus;
        this.shippedAt = shippedAt;
        this.deliveredAt = deliveredAt;
    }

    public Shipment(long shipmentId, int orderId, String shippingProvider,
            String trackingNumber, String shippingAddress, String shippingStatus,
            LocalDate estimatedDeliveryDate, LocalDateTime shippedAt, LocalDateTime deliveredAt) {
        this(shipmentId, orderId, shippingProvider, trackingNumber, shippingAddress, shippingStatus, shippedAt, deliveredAt);
        this.estimatedDeliveryDate = estimatedDeliveryDate;
    }

    public long getShipmentId() {
        return shipmentId;
    }

    public void setShipmentId(long shipmentId) {
        this.shipmentId = shipmentId;
    }

    public long getShipmentID() {
        return shipmentId;
    }

    public void setShipmentID(long shipmentID) {
        this.shipmentId = shipmentID;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getOrderID() {
        return orderId;
    }

    public void setOrderID(int orderID) {
        this.orderId = orderID;
    }

    public String getShippingProvider() {
        return shippingProvider;
    }

    public void setShippingProvider(String shippingProvider) {
        this.shippingProvider = shippingProvider;
    }

    public String getTrackingNumber() {
        return trackingNumber;
    }

    public void setTrackingNumber(String trackingNumber) {
        this.trackingNumber = trackingNumber;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public String getShippingStatus() {
        return shippingStatus;
    }

    public void setShippingStatus(String shippingStatus) {
        this.shippingStatus = shippingStatus;
    }

    public LocalDate getEstimatedDeliveryDate() {
        return estimatedDeliveryDate;
    }

    public void setEstimatedDeliveryDate(LocalDate estimatedDeliveryDate) {
        this.estimatedDeliveryDate = estimatedDeliveryDate;
    }

    public LocalDateTime getShippedAt() {
        return shippedAt;
    }

    public void setShippedAt(LocalDateTime shippedAt) {
        this.shippedAt = shippedAt;
    }

    public LocalDateTime getDeliveredAt() {
        return deliveredAt;
    }

    public void setDeliveredAt(LocalDateTime deliveredAt) {
        this.deliveredAt = deliveredAt;
    }

    public String getFormattedEstimatedDate() {
        if (estimatedDeliveryDate == null) return "3-5 business days";
        return estimatedDeliveryDate.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    public String getFormattedDeliveredAt() {
        if (deliveredAt == null) return null;
        return deliveredAt.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss dd/MM/yyyy"));
    }
}
