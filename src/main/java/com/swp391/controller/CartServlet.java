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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/authen/login.jsp");
            return;
        }
        Map<Integer, CartItemDTO> cart = (Map<Integer, CartItemDTO>) session.getAttribute("cart");
        if(cart == null){
            cart = new HashMap<>();
        }
        request.setAttribute("listCart", new ArrayList<>(cart.values()));
        request.getRequestDispatcher("/views/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/authen/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        Map<Integer, CartItemDTO> cart = (Map<Integer, CartItemDTO>) session.getAttribute("cart");
        if (cart == null) {
            cart = new HashMap<>();
        }
        try{
            int productId = Integer.parseInt(request.getParameter("productId"));
            if ("add".equals(action)) {
                    int quantity = Integer.parseInt(request.getParameter("quantity"));
                    if (cart.containsKey(productId)) {
                        // Đã có trong giỏ -> Cộng dồn số lượng
                        CartItemDTO item = cart.get(productId);
                        item.setQuantity(item.getQuantity() + quantity);
                    } else {
                        // Mới tinh -> Gọi CartDAO chọc DB lấy thông tin sản phẩm
                        CartItemDTO item = cartDAO.getProductInfo(productId);
                        if (item != null) {
                            item.setQuantity(quantity);
                            cart.put(productId, item); // Thả vào giỏ hàng
                        }
                    }
            } else if ("update".equals(action)) {
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                if (quantity > 0) {
                    if (cart.containsKey(productId)) {
                        cart.get(productId).setQuantity(quantity);
                    }
                } else {
                    cart.remove(productId);
                }
            } else if ("remove".equals(action)) {
                cart.remove(productId);
            }
            session.setAttribute("cart", cart);
        }catch(Exception e){
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
