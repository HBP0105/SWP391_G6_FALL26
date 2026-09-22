package com.swp391.controller;

import com.swp391.dao.CustomerDAO;
import com.swp391.model.Customer;
import com.swp391.model.Staff;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private CustomerDAO customerDAO;

    @Override
    public void init() {
        customerDAO = new CustomerDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Object sessionUser = (session != null) ? session.getAttribute("customer") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.getRequestDispatcher("/authen/changePassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Object sessionUser = (session != null) ? session.getAttribute("customer") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("checkEmail".equalsIgnoreCase(action)) {
            handleCheckEmail(request, response, sessionUser);
        } else if ("changePassword".equalsIgnoreCase(action)) {
            handleChangePassword(request, response, sessionUser, session);
        } else {
            doGet(request, response);
        }
    }

    private void handleCheckEmail(HttpServletRequest request, HttpServletResponse response, Object sessionUser)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        if (email != null) {
            email = email.trim();
        }

        String loggedInEmail = getLoggedInEmail(sessionUser);

        request.setAttribute("emailInput", email);

        if (email == null || email.isEmpty()) {
            request.setAttribute("error", "Email cannot be empty!");
            request.getRequestDispatcher("/authen/changePassword.jsp").forward(request, response);
            return;
        }

        if (!email.equalsIgnoreCase(loggedInEmail)) {
            request.setAttribute("error", "Email does not match your current logged-in account!");
            request.getRequestDispatcher("/authen/changePassword.jsp").forward(request, response);
            return;
        }

        if (sessionUser instanceof Customer && !customerDAO.checkEmailExist(email)) {
            request.setAttribute("error", "Email does not exist in our system!");
            request.getRequestDispatcher("/authen/changePassword.jsp").forward(request, response);
            return;
        }

        // Email hợp lệ → chuyển sang bước nhập mật khẩu mới
        request.setAttribute("step", "reset");
        request.setAttribute("checkedEmail", email);
        request.getRequestDispatcher("/authen/changePassword.jsp").forward(request, response);
    }

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response,
                                      Object sessionUser, HttpSession session)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (email != null) {
            email = email.trim();
        }

        String loggedInEmail = getLoggedInEmail(sessionUser);

        request.setAttribute("checkedEmail", email);
        request.setAttribute("step", "reset");

        if (email == null || email.isEmpty() || !email.equalsIgnoreCase(loggedInEmail)) {
            request.setAttribute("error", "Invalid email verification. Please verify your email again!");
            request.removeAttribute("step");
            request.getRequestDispatcher("/authen/changePassword.jsp").forward(request, response);
            return;
        }

        Customer customerInDb = customerDAO.getCustomerByEmail(email);
        if (customerInDb == null) {
            request.setAttribute("error", "Account not found in the database!");
            request.removeAttribute("step");
            request.getRequestDispatcher("/authen/changePassword.jsp").forward(request, response);
            return;
        }

        String errorMsg = null;
        if (newPassword == null || newPassword.trim().isEmpty()) {
            errorMsg = "New password cannot be empty!";
        } else if (newPassword.length() < 6) {
            errorMsg = "Password must have at least 6 characters!";
        } else if (confirmPassword == null || !newPassword.equals(confirmPassword)) {
            errorMsg = "Confirm password does not match!";
        } else if (newPassword.equals(customerInDb.getPasswordHash())) {
            errorMsg = "New password cannot be the same as your old password!";
        }

        if (errorMsg != null) {
            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("/authen/changePassword.jsp").forward(request, response);
            return;
        }

        boolean updated = customerDAO.updatePassword(email, newPassword);
        if (updated) {
            customerInDb.setPasswordHash(newPassword);
            session.setAttribute("customer", customerInDb);
            session.setAttribute("flashSuccess", "Password changed successfully!");
            response.sendRedirect(request.getContextPath() + "/profile");
        } else {
            request.setAttribute("error", "Failed to update password. Please try again!");
            request.getRequestDispatcher("/authen/changePassword.jsp").forward(request, response);
        }
    }

    private String getLoggedInEmail(Object sessionUser) {
        if (sessionUser instanceof Customer) {
            return ((Customer) sessionUser).getEmail();
        } else if (sessionUser instanceof Staff) {
            return ((Staff) sessionUser).getEmail();
        }
        return "";
    }
}
