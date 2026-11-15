package com.swp391.controller;

import com.swp391.dao.OrderDAO;
import com.swp391.model.Customer;
import com.swp391.model.OrderDTO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "OrderDetailServlet", urlPatterns = {"/order-detail"})
public class OrderDetailServlet extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/my-orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(idParam.trim());
            OrderDTO order = orderDAO.getOrderDetailById(orderId, customer.getCustomerID());
            if (order == null) {
                response.sendRedirect(request.getContextPath() + "/my-orders");
                return;
            }
            request.setAttribute("order", order);
            request.getRequestDispatcher("/views/orderDetail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/my-orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("cancel".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String cancelReason = request.getParameter("cancelReason");
                if (cancelReason == null || cancelReason.trim().isEmpty()) {
                    cancelReason = "Customer requested order cancellation";
                }
                orderDAO.cancelOrder(orderId, customer.getCustomerID(), cancelReason);
                response.sendRedirect(request.getContextPath() + "/order-detail?id=" + orderId + "&cancelSuccess=true");
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        else if ("received".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                boolean delivered = orderDAO.confirmDelivered(orderId, customer.getCustomerID());
                if (delivered) {
                    response.sendRedirect(request.getContextPath() + "/order-detail?id=" + orderId + "&deliveredSuccess=true");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/my-orders");
    }
}
