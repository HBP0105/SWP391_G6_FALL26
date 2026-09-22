package com.swp391.controller;

import com.swp391.dao.CartDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

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
        String action = request.getParameter("action");
        if (action == null) {
            action = "view";
        }        
        HttpSession session = request.getSession();
        Object customer = session.getAttribute("customer");
        request.getRequestDispatcher("/views/cart.jsp").forward(request, response);
        
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("add".equals(action)) {
            // int productId = Integer.parseInt(request.getParameter("productId"));
            // int quantity = Integer.parseInt(request.getParameter("quantity"));
            // cartDAO.addCartItem(..., productId, quantity);
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
