package com.swp391.service;

import com.swp391.dao.Manager.ManagerDashBoard;
import com.swp391.model.OrderSummary;

import java.util.ArrayList;
import java.util.List;

/**
 * Service layer for Manager Dashboard.
 * Aggregates dashboard statistics and recent orders.
 */
public class DashboardService {

    private final ManagerDashBoard dashBoardDao;

    public DashboardService() {
        this.dashBoardDao = new ManagerDashBoard();
    }

    public int getTotalProducts() {
        return dashBoardDao.getTotalProducts();
    }

    public int getNewProductsThisMonth() {
        return dashBoardDao.getNewProductsThisMonth();
    }

    public int getTotalOrders() {
        return dashBoardDao.getTotalOrders();
    }

    public double getOrderGrowthPercent() {
        return dashBoardDao.getOrderGrowthPercent();
    }

    public int getLowStockProducts() {
        return dashBoardDao.getLowStockProducts();
    }

    /**
     * Returns recent orders, guaranteed non-null.
     */
    public List<OrderSummary> getRecentOrders() {
        List<OrderSummary> list = dashBoardDao.getRecentOrders();
        if (list == null) {
            list = new ArrayList<>();
        }
        return list;
    }
}
