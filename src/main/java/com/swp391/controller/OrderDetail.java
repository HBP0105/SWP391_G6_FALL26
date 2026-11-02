package com.swp391.controller;

import com.swp391.service.OrderService;

import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Thin Controller for Order Details & Status Update (Screen 2).
 * Delegates all data bundling, validation, state machine transitions, and updates to OrderService.
 */
@WebServlet(name = "OrderDetail", urlPatterns = {"/staff/order-detail"})
public class OrderDetail extends HttpServlet {

    private OrderService orderService;

    @Override
    public void init() {
        orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        String idParam = request.getParameter("id");
        int orderId = 0;
        if (idParam != null && !idParam.trim().isEmpty()) {
                orderId = Integer.parseInt(idParam.trim());
        }

        if (orderId <= 0) {
            request.getSession().setAttribute("msgErrorStatus", "Invalid Order ID specified!");
            response.sendRedirect(request.getContextPath() + "/staff/orders");
            return;
        }

        // PRG Session Flash Message cleanup (transfers attributes to Request scope)
        if (session != null) {
            if (session.getAttribute("msgSuccess") != null) {
                request.setAttribute("msgSuccess", session.getAttribute("msgSuccess"));
                request.setAttribute("msgSuccessOrderId", session.getAttribute("msgSuccessOrderId"));
                request.setAttribute("msgSuccessStatus", session.getAttribute("msgSuccessStatus"));
                session.removeAttribute("msgSuccess");
                session.removeAttribute("msgSuccessOrderId");
                session.removeAttribute("msgSuccessStatus");
            }
            if (session.getAttribute("msgErrorStatus") != null) {
                request.setAttribute("msgErrorStatus", session.getAttribute("msgErrorStatus"));
                session.removeAttribute("msgErrorStatus");
            }
        }

        Map<String, Object> bundle = orderService.getOrderDetailBundle(orderId);
        if (bundle == null || bundle.get("order") == null) {
            request.getSession().setAttribute("msgErrorStatus", "Order #ORD-" + orderId + " was not found in database!");
            response.sendRedirect(request.getContextPath() + "/staff/orders");
            return;
        }

        bundle.forEach(request::setAttribute);

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
                String shippingProvider = request.getParameter("shippingProvider");
                String trackingNumber = request.getParameter("trackingNumber");
                String shipperName = request.getParameter("shipperName");
                String shipperPhone = request.getParameter("shipperPhone");

                
                String processUpdate = orderService.processStatusUpdate(
                        orderId, newStatus, cancelReason, shippingProvider, trackingNumber,
                        shipperName, shipperPhone);
                HttpSession session = request.getSession();
                if (processUpdate == null) {
                    session.setAttribute("msgSuccess", "true");
                    session.setAttribute("msgSuccessOrderId", orderId);
                    session.setAttribute("msgSuccessStatus", newStatus);
                    session.removeAttribute("msgErrorStatus");
                } else {
                    session.setAttribute("msgErrorStatus", processUpdate);
                    session.removeAttribute("msgSuccess");
                    session.removeAttribute("msgSuccessOrderId");
                    session.removeAttribute("msgSuccessStatus");
                }
            } catch (Exception e) {
                HttpSession session = request.getSession();
                session.setAttribute("msgErrorStatus", "Invalid order update parameters!");
                session.removeAttribute("msgSuccess");
                session.removeAttribute("msgSuccessOrderId");
                session.removeAttribute("msgSuccessStatus");
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

