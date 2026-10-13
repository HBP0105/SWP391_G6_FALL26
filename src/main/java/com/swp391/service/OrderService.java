package com.swp391.service;

import com.swp391.dao.Manager.OrderManagementDAO;

import java.util.List;
import java.util.Map;

/**
 * Service layer for Order management.
 * Provides order listing and detail retrieval.
 */
public class OrderService {

    private final OrderManagementDAO orderDao;

    public OrderService() {
        this.orderDao = new OrderManagementDAO();
    }

    public List<Map<String, Object>> getAllOrders() {
        return orderDao.getAllOrders();
    }

    public Map<String, Object> getOrderById(int orderId) {
        return orderDao.getOrderById(orderId);
    }

    public List<Map<String, Object>> getOrderItems(int orderId) {
        return orderDao.getOrderItems(orderId);
    }
}
