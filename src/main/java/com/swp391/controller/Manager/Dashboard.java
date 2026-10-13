package com.swp391.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import com.swp391.service.DashboardService;
import com.swp391.model.OrderSummary;
import java.util.List;

@WebServlet("/Manager/Dashboard")
public class Dashboard extends HttpServlet {

    private DashboardService dashboardService;

    @Override
    public void init() {
        dashboardService = new DashboardService();
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "dashboard");

        request.setAttribute("totalProducts", dashboardService.getTotalProducts());
        request.setAttribute("newProductsThisMonth", dashboardService.getNewProductsThisMonth());
        request.setAttribute("totalOrders", dashboardService.getTotalOrders());
        request.setAttribute("orderGrowthPercent", dashboardService.getOrderGrowthPercent());

        int lowStock = dashboardService.getLowStockProducts();
        request.setAttribute("lowStockProducts", lowStock);

        List<OrderSummary> list = dashboardService.getRecentOrders();

        request.setAttribute("recentOrders", list);

        request.getRequestDispatcher(
                "/views/Manager/managerDashBoard.jsp"
        ).forward(request, response);
    }


@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}
