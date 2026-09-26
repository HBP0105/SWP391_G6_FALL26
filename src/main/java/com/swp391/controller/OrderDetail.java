package com.swp391.controller;

import com.swp391.dao.OrderDAO;
import com.swp391.model.Order;
import com.swp391.model.OrderItem;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Controller for Order Details & Status Update (Screen 2)
 */
@WebServlet(name = "OrderDetail", urlPatterns = {"/staff/order-detail"})
public class OrderDetail extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            request.getSession().setAttribute("msgErrorStatus", "Invalid Order ID specified!");
            response.sendRedirect(request.getContextPath() + "/staff/orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("msgErrorStatus", "Order ID must be a numeric value!");
            response.sendRedirect(request.getContextPath() + "/staff/orders");
            return;
        }

        Order order = orderDAO.getOrderById(orderId);
        if (order == null) {
            request.getSession().setAttribute("msgErrorStatus", "Order #ORD-" + orderId + " was not found in database!");
            response.sendRedirect(request.getContextPath() + "/staff/orders");
            return;
        }

        List<OrderItem> items = orderDAO.getOrderItems(orderId);

        request.setAttribute("order", order);
        request.setAttribute("items", items);

        request.getRequestDispatcher("/views/staff/order-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        int orderId = 0;

        if ("updateStatus".equals(action)) {
            try {
                orderId = Integer.parseInt(request.getParameter("orderId"));
                String newStatus = request.getParameter("newStatus");
                String cancelReason = request.getParameter("cancelReason");

                // Validation for CANCELLED reason if status is CANCELLED
                if ("CANCELLED".equalsIgnoreCase(newStatus) && (cancelReason == null || cancelReason.trim().isEmpty())) {
                    request.getSession().setAttribute("msgErrorStatus", "Cancellation reason is required when cancelling an order!");
                } else {
                    // State Machine Backend Validation
                    boolean success = orderDAO.updateOrderStatusWithValidation(orderId, newStatus, cancelReason);
                    if (success) {
                        request.getSession().setAttribute("msgSuccess", "true");
                        request.getSession().setAttribute("msgSuccessOrderId", orderId);
                        request.getSession().setAttribute("msgSuccessStatus", newStatus);
                    } else {
                        request.getSession().setAttribute("msgErrorStatus", "Invalid status transition for Order #ORD-" + orderId + "!");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (orderId > 0) {
            response.sendRedirect(request.getContextPath() + "/staff/order-detail?id=" + orderId);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/orders");
        }
    }

    @Override
    public String getServletInfo() {
        return "Order Detail Servlet";
    }
}
