package com.swp391.controller;

import com.swp391.dao.OrderDAO;
import com.swp391.model.Customer;
import com.swp391.model.OrderDTO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MyOrderServlet", urlPatterns = {"/my-orders"})
public class MyOrderServlet extends HttpServlet {

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

        // Yêu cầu đăng nhập trước khi xem đơn hàng của tôi
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy danh sách tất cả các đơn hàng của khách hàng này từ CSDL
        List<OrderDTO> orders = orderDAO.getOrdersByCustomerId(customer.getCustomerID());

        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/views/myOrder.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
