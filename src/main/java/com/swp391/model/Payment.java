/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.swp391.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 *
 * @author HP
 */
public class Payment {
    public long paymentID;
    public int orderID;
    public String paymentMethod;
    public String transactionID;
    public BigDecimal amount;
    public String paymentStatus;
    public String responseCode;
    public LocalDateTime paymentDate;

    public Payment() {
    }

    public Payment(long paymentID, int orderID, String paymentMethod,
            String transactionID, BigDecimal amount,
            String paymentStatus, String responseCode,
            LocalDateTime paymentDate) {

        this.paymentID = paymentID;
        this.orderID = orderID;
        this.paymentMethod = paymentMethod;
        this.transactionID = transactionID;
        this.amount = amount;
        this.paymentStatus = paymentStatus;
        this.responseCode = responseCode;
        this.paymentDate = paymentDate;
    }

    public long getPaymentID() {
        return paymentID;
    }

    public void setPaymentID(long paymentID) {
        this.paymentID = paymentID;
    }

    public int getOrderID() {
        return orderID;
    }

    public void setOrderID(int orderID) {
        this.orderID = orderID;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getTransactionID() {
        return transactionID;
    }

    public void setTransactionID(String transactionID) {
        this.transactionID = transactionID;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getResponseCode() {
        return responseCode;
    }

    public void setResponseCode(String responseCode) {
        this.responseCode = responseCode;
    }

    public LocalDateTime getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(LocalDateTime paymentDate) {
        this.paymentDate = paymentDate;
    }
}
