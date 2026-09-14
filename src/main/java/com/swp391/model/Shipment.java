/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.swp391.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 *
 * @author HP
 */
public class Shipment {
    public long shipmentID;
    public int orderID;
    public String shippingProvider;
    public String trackingNumber;
    public String shippingAddress;
    public String shippingStatus;
    public LocalDate estimatedDeliveryDate;
    public LocalDateTime shippedAt;
    public LocalDateTime deliveredAt;

    public Shipment() {
    }

    public Shipment(long shipmentID, int orderID,
            String shippingProvider, String trackingNumber,
            String shippingAddress, String shippingStatus,
            LocalDate estimatedDeliveryDate,
            LocalDateTime shippedAt,
            LocalDateTime deliveredAt) {

        this.shipmentID = shipmentID;
        this.orderID = orderID;
        this.shippingProvider = shippingProvider;
        this.trackingNumber = trackingNumber;
        this.shippingAddress = shippingAddress;
        this.shippingStatus = shippingStatus;
        this.estimatedDeliveryDate = estimatedDeliveryDate;
        this.shippedAt = shippedAt;
        this.deliveredAt = deliveredAt;
    }

    public long getShipmentID() {
        return shipmentID;
    }

    public void setShipmentID(long shipmentID) {
        this.shipmentID = shipmentID;
    }

    public int getOrderID() {
        return orderID;
    }

    public void setOrderID(int orderID) {
        this.orderID = orderID;
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
}
