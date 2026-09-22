package com.swp391.controller;

import com.swp391.dao.CustomerDAO;
import com.swp391.model.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/profile")
public class CustomerProfileServlet extends HttpServlet {

    private CustomerDAO customerDAO;

    @Override
    public void init() {
        customerDAO = new CustomerDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check cả 2 session key: "customer" (Customer) và "user" (Staff)
        Object sessionUser = null;
        if (session != null) {
            sessionUser = session.getAttribute("customer");
            if (sessionUser == null) {
                sessionUser = session.getAttribute("user");
            }
        }

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (sessionUser instanceof Customer) {
            Customer freshCustomer = customerDAO.getCustomerByEmail(((Customer) sessionUser).getEmail());
            if (freshCustomer != null) {
                session.setAttribute("customer", freshCustomer);
            }
        }

        request.getRequestDispatcher("/views/customerProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        doGet(request, response);
    }
}
