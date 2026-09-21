package com.swp391.controller;

import com.swp391.dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private CustomerDAO customerDAO;

    @Override
    public void init() {
        customerDAO = new CustomerDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/authen/forgot.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty() || "checkEmail".equalsIgnoreCase(action)) {
            handleCheckEmail(request, response);
        } else if ("resetPassword".equalsIgnoreCase(action)) {
            handleResetPassword(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/forgot-password");
        }
    }

    private void handleCheckEmail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        if (email != null) {
            email = email.trim();
        }

        request.setAttribute("email", email);

        if (email == null || email.isEmpty()) {
            request.setAttribute("error", "Email cannot be empty!");
            request.getRequestDispatcher("/authen/forgot.jsp").forward(request, response);
            return;
        }

        if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$")) {
            request.setAttribute("error", "Email format is not correct!");
            request.getRequestDispatcher("/authen/forgot.jsp").forward(request, response);
            return;
        }

        // Kiem tra email trong CustomerDAO
        if (!customerDAO.checkEmailExist(email)) {
            request.setAttribute("error", "Email does not exist in our system!");
            request.getRequestDispatcher("/authen/forgot.jsp").forward(request, response);
            return;
        }

        // Email hop le va ton tai -> chuyen sang dat lai mat khau
        request.setAttribute("step", "reset");
        request.setAttribute("email", email);
        request.getRequestDispatcher("/authen/forgot.jsp").forward(request, response);
    }

    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (email != null) {
            email = email.trim();
        }

        request.setAttribute("email", email);

        if (email == null || email.isEmpty() || !customerDAO.checkEmailExist(email)) {
            request.setAttribute("error", "Invalid email or session expired. Please enter email again!");
            request.getRequestDispatcher("/authen/forgot.jsp").forward(request, response);
            return;
        }

        String errorMsg = null;

        if (newPassword == null || newPassword.trim().isEmpty()) {
            errorMsg = "Password cannot be empty!";
        } else if (newPassword.length() < 6) {
            errorMsg = "Password must have at least 6 characters!";
        } else if (confirmPassword == null || !newPassword.equals(confirmPassword)) {
            errorMsg = "Confirm password does not match!";
        }

        if (errorMsg != null) {
            request.setAttribute("error", errorMsg);
            request.setAttribute("step", "reset");
            request.getRequestDispatcher("/authen/forgot.jsp").forward(request, response);
            return;
        }

        // Validate thanh cong -> cap nhat mat khau trong CustomerDAO
        boolean updated = customerDAO.updatePassword(email, newPassword);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/login?resetSuccess=true");
        } else {
            request.setAttribute("error", "Failed to update password. Please try again!");
            request.setAttribute("step", "reset");
            request.getRequestDispatcher("/authen/forgot.jsp").forward(request, response);
        }
    }
}
