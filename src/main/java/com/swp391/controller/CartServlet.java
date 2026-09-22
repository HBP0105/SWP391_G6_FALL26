package com.swp391.controller;

import com.swp391.dao.CartDAO;
import com.swp391.model.CartItemDTO;
import com.swp391.model.Customer;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private CartDAO cartDAO;

    @Override
    public void init() throws ServletException {
        cartDAO = new CartDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        // B?O M?T: Ch?a ??ng nh?p -> ?á v? trang ??ng nh?p
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp");
            return;
        }
        // L?Y GI? HÀNG T? DATABASE
        int cartId = cartDAO.getCartIdByCustomerId(customer.getCustomerId());
        List<CartItemDTO> listCart = cartDAO.getCartItems(cartId);
        
        // G?i qua giao di?n
        request.setAttribute("listCart", listCart);
        request.getRequestDispatcher("/views/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        // B?O M?T: Ch?a ??ng nh?p không cho Add to Cart
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/views/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if ("add".equals(action)) {
            try {
                int productId = Integer.parseInt(request.getParameter("productId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                
                int cartId = cartDAO.getCartIdByCustomerId(customer.getCustomerId());
                cartDAO.addCartItem(cartId, productId, quantity); // L?u vào DB
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if ("update".equals(action)) {
            // int productId = Integer.parseInt(request.getParameter("productId"));
            // int quantity = Integer.parseInt(request.getParameter("quantity"));
            // cartDAO.updateCartItemQuantity(..., productId, quantity);
        } else if ("remove".equals(action)) {
            // int productId = Integer.parseInt(request.getParameter("productId"));
            // cartDAO.removeCartItem(..., productId);
        }
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
