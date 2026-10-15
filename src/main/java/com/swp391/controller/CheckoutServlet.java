package com.swp391.controller;

import com.swp391.dao.OrderDAO;
import com.swp391.model.CartItemDTO;
import com.swp391.model.Customer;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

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

        Map<Integer, CartItemDTO> cart = (Map<Integer, CartItemDTO>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        request.setAttribute("listCart", new ArrayList<>(cart.values()));
        request.getRequestDispatcher("/views/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8"); 
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Map<Integer, CartItemDTO> cart = (Map<Integer, CartItemDTO>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        try {
            // Khách hàng tự nhập địa chỉ giao hàng
            String addressLine = request.getParameter("addressLine");
            String ward = request.getParameter("ward");
            String district = request.getParameter("district");
            String province = request.getParameter("province");
            String address = addressLine + ", " + ward + ", " + district + ", " + province;
            
            String paymentMethod = request.getParameter("paymentMethod");
            String notes = request.getParameter("orderNotes");

            // Lưu đơn hàng vào Database (COD)
            int orderId = orderDAO.placeOrder(customer.getCustomerID(), cart, address, paymentMethod, notes);

            if (orderId > 0) {
                // Xóa giỏ hàng trên Session sau khi đặt thành công
                session.removeAttribute("cart");
                
                // Chuyển hướng sang trang My Order kèm thông báo thành công và mã đơn vừa đặt
                response.sendRedirect(request.getContextPath() + "/my-orders?orderSuccess=true&orderId=" + orderId); 
            } else {
                response.getWriter().println("An error occurred while placing your order! Please try again.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("System error: " + e.getMessage());
        }
    }
}
