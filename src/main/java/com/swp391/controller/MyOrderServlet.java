package com.swp391.controller;

import com.swp391.dao.OrderDAO;
import com.swp391.model.CartItemDTO;
import com.swp391.model.Customer;
import com.swp391.model.OrderDTO;
import java.io.IOException;
import java.util.ArrayList;
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

        // 1. Lọc theo Tab trạng thái (status) và Từ khóa tìm kiếm (keyword)
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }
        String keyword = request.getParameter("keyword");
        String kw = ("ALL".equalsIgnoreCase(status) && keyword != null) ? keyword.trim().toLowerCase() : "";

        List<OrderDTO> filteredOrders = new ArrayList<>();
        for (OrderDTO o : orders) {
            boolean matchStatus = "ALL".equalsIgnoreCase(status)
                    || (o.getOrderStatus() != null && o.getOrderStatus().equalsIgnoreCase(status));
            if (!matchStatus) {
                continue;
            }

            if (!kw.isEmpty()) {
                boolean matchKeyword = String.valueOf(o.getOrderId()).contains(kw)
                        || ("#ord-" + o.getOrderId()).contains(kw)
                        || (o.getShippingAddress() != null && o.getShippingAddress().toLowerCase().contains(kw));

                if (!matchKeyword && o.getItems() != null) {
                    for (CartItemDTO item : o.getItems()) {
                        if (item.getProductName() != null && item.getProductName().toLowerCase().contains(kw)) {
                            matchKeyword = true;
                            break;
                        }
                    }
                }
                if (!matchKeyword) {
                    continue;
                }
            }
            filteredOrders.add(o);
        }

        // 2. Phân trang: Mỗi trang chứa tối đa 5 đơn hàng
        int pageSize = 5;
        int totalFiltered = filteredOrders.size();
        int totalPages = (int) Math.ceil((double) totalFiltered / pageSize);
        if (totalPages < 1) {
            totalPages = 1;
        }

        int currentPage = 1;
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                currentPage = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
        if (currentPage < 1) {
            currentPage = 1;
        } else if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int startIndex = (currentPage - 1) * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalFiltered);
        List<OrderDTO> pagedOrders = (startIndex < totalFiltered)
                ? filteredOrders.subList(startIndex, endIndex)
                : new ArrayList<>();

        request.setAttribute("orders", orders);
        request.setAttribute("pagedOrders", pagedOrders);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalFiltered", totalFiltered);
        request.getRequestDispatcher("/views/myOrder.jsp").forward(request, response);
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
                boolean cancelled = orderDAO.cancelOrder(orderId, customer.getCustomerID());
                if (cancelled) {
                    // Hủy xong chuyển thẳng sang tab CANCELLED kèm thông báo
                    response.sendRedirect(request.getContextPath() + "/my-orders?status=CANCELLED&cancelSuccess=true&orderId=" + orderId);
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        doGet(request, response);
    }
}
