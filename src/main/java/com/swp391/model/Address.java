package com.swp391.model;

import java.time.LocalDateTime;

public class Address {

    private int addressId;
    private int customerId;
    private String receiverName;
    private String receiverPhone;
    private String addressLine;
    private String ward;
    private String district;
    private String province;
    private boolean isDefault;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Address() {
    }

    public Address(int addressId, int customerId, String receiverName, String receiverPhone,
                   String addressLine, String ward, String district, String province, boolean isDefault) {
        this.addressId = addressId;
        this.customerId = customerId;
        this.receiverName = receiverName;
        this.receiverPhone = receiverPhone;
        this.addressLine = addressLine;
        this.ward = ward;
        this.district = district;
        this.province = province;
        this.isDefault = isDefault;
    }

    public Address(int addressId, int customerId, String receiverName, String receiverPhone,
                   String addressLine, String ward, String district, String province, boolean isDefault,
                   LocalDateTime createdAt, LocalDateTime updatedAt) {
        this(addressId, customerId, receiverName, receiverPhone, addressLine, ward, district, province, isDefault);
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getAddressId() {
        return addressId;
    }

    public void setAddressId(int addressId) {
        this.addressId = addressId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    // Aliases
    public int getAddressID() {
        return addressId;
    }

    public void setAddressID(int addressID) {
        this.addressId = addressID;
    }

    public int getCustomerID() {
        return customerId;
    }

    public void setCustomerID(int customerID) {
        this.customerId = customerID;
    }

    public int getUserID() {
        return customerId;
    }

    public void setUserID(int userID) {
        this.customerId = userID;
    }

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public String getReceiverPhone() {
        return receiverPhone;
    }

    public void setReceiverPhone(String receiverPhone) {
        this.receiverPhone = receiverPhone;
    }

    public String getAddressLine() {
        return addressLine;
    }

    public void setAddressLine(String addressLine) {
        this.addressLine = addressLine;
    }

    public String getWard() {
        return ward;
    }

    public void setWard(String ward) {
        this.ward = ward;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public boolean isDefault() {
        return isDefault;
    }

    public void setDefault(boolean isDefault) {
        this.isDefault = isDefault;
    }

    public boolean isIsDefault() {
        return isDefault;
    }

    public void setIsDefault(boolean isDefault) {
        this.isDefault = isDefault;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getFullAddress() {
        StringBuilder address = new StringBuilder();

        if (addressLine != null && !addressLine.trim().isEmpty()) {
            address.append(addressLine);
        }

        if (ward != null && !ward.trim().isEmpty()) {
            appendPart(address, ward);
        }

        if (district != null && !district.trim().isEmpty()) {
            appendPart(address, district);
        }

        if (province != null && !province.trim().isEmpty()) {
            appendPart(address, province);
        }

        return address.toString();
    }

    private void appendPart(StringBuilder address, String part) {
        if (address.length() > 0) {
            address.append(", ");
        }
        address.append(part);
    }
}
