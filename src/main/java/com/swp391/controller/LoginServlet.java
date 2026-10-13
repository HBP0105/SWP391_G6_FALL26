package com.swp391.controller;

import com.swp391.dao.CustomerDAO;
import com.swp391.dao.StaffDAO;
import com.swp391.model.Customer;
import com.swp391.model.Staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private CustomerDAO customerDAO;
    private StaffDAO staffDAO;

    @Override
    public void init() {
        customerDAO = new CustomerDAO();
        staffDAO = new StaffDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/authen/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("username");
        String password = request.getParameter("password");

        // dang nhap Customer
        Customer customer = customerDAO.login(email, password);
        if (customer != null) {
            HttpSession session = request.getSession();
            session.setAttribute("customer", customer);
            session.setAttribute("role", "CUSTOMER");

            // Khởi tạo wishlist từ database vào session
            com.swp391.dao.FavoriteDAO favoriteDAO = new com.swp391.dao.FavoriteDAO();
            java.util.List<com.swp391.model.WishlistItemDTO> dbItems = favoriteDAO.getFavoritesByCustomerId(customer.getCustomerID());
            java.util.Set<Integer> pIds = new java.util.LinkedHashSet<>();
            if (dbItems != null) {
                for (com.swp391.model.WishlistItemDTO itm : dbItems) {
                    pIds.add(itm.getProductId());
                }
            } else {
                dbItems = new java.util.ArrayList<>();
            }
            session.setAttribute("wishlistItems", dbItems);
            session.setAttribute("wishlistProductIds", pIds);
            session.setAttribute("wishlistCount", dbItems.size());
            session.setAttribute("wishlistModified", false);

            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // dang nhap Staff
        Staff staff = staffDAO.login(email, password);
        if (staff != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", staff);
            session.setAttribute("role", staff.getRoleName());

            if ("ADMIN".equalsIgnoreCase(staff.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/views/admin.jsp");
            } else if ("MANAGER".equalsIgnoreCase(staff.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/views/manager.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/home");
            }
            return;
        }

        // Dang nhap that bai
        request.setAttribute("error", "Email or password incorrect");
        request.getRequestDispatcher("/authen/login.jsp").forward(request, response);
    }
}
