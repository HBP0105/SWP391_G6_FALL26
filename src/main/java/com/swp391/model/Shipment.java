/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.swp391.model;

import java.time.LocalDateTime;

/**
 *
 * @author ADMIN
 */
public class Shipment {

    private long shipmentId;
    private int orderId;

    private String shippingProvider;
    private String trackingNumber;
    private String shippingAddress;

    private String shippingStatus;

    private LocalDateTime shippedAt;
    private LocalDateTime deliveredAt;

    public Shipment() {
    }

    public Shipment(long shipmentId, int orderId, String shippingProvider, String trackingNumber, String shippingAddress, String shippingStatus, LocalDateTime shippedAt, LocalDateTime deliveredAt) {
        this.shipmentId = shipmentId;
        this.orderId = orderId;
        this.shippingProvider = shippingProvider;
        this.trackingNumber = trackingNumber;
        this.shippingAddress = shippingAddress;
        this.shippingStatus = shippingStatus;
        this.shippedAt = shippedAt;
        this.deliveredAt = deliveredAt;
    }

    public long getShipmentId() {
        return shipmentId;
    }

    public void setShipmentId(long shipmentId) {
        this.shipmentId = shipmentId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
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

}
