package com.swp391.controller.manager;

import com.swp391.service.OrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/Manager/OrderManagement")
public class OrderManagement extends HttpServlet {

    private OrderService orderService;

    @Override
    public void init() {
        orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "orders");

        String action = request.getParameter("action");

       
        if ("detail".equals(action)) {

            String id = request.getParameter("id");

            try {
                int orderId = Integer.parseInt(id);

                Map<String, Object> order
                        = orderService.getOrderById(orderId);

                List<Map<String, Object>> orderItems
                        = orderService.getOrderItems(orderId);

                request.setAttribute("order", order);
                request.setAttribute("orderItems", orderItems);

                request.getRequestDispatcher(
                        "/views/Manager/orderDetail.jsp"
                ).forward(request, response);

                return;

            } catch (NumberFormatException e) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST
                );
                return;
            }
        }

        List<Map<String, Object>> orders
                = orderService.getAllOrders();

        request.setAttribute("orders", orders);

        request.getRequestDispatcher(
                "/views/Manager/orderManagement.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}
