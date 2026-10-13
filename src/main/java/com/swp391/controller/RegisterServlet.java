package com.swp391.controller;

import com.swp391.dao.CustomerDAO;
import com.swp391.dao.StaffDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

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
        request.getRequestDispatcher("/authen/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone = request.getParameter("phone");

        if (fullName != null) {
            fullName = fullName.trim();
        }
        if (email != null) {
            email = email.trim();
        }
        if (phone != null) {
            phone = phone.trim();
        }

        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);

        String errorMsg = null;

        if (fullName == null || fullName.isEmpty()) {
            errorMsg = "Name cannot be empty!";
        } else if (fullName.length() < 2 || fullName.length() > 100) {
            errorMsg = "Name must be in range 2 - 100 characters!";
        } else if (email == null || email.isEmpty()) {
            errorMsg = "Email cannot be empty!";
        } else if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$")) {
            errorMsg = "Email format is not correct!";
        } else if (password == null || password.isEmpty()) {
            errorMsg = "Password cannot be empty!";
        } else if (password.length() < 6) {  //!password.matches("^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{6,}$")
            errorMsg = "Password must have at least 6 characters!";
        } else if (confirmPassword != null && !password.equals(confirmPassword)) {
            errorMsg = "Confirm password does not match!";
        } else if (phone == null || phone.isEmpty()) {
            errorMsg = "Phone number cannot be empty!";
        } else if (!phone.matches("^(0[3|5|7|8|9])[0-9]{8}$")) {
            errorMsg = "Phone number is not valid!";
        } else if (customerDAO.checkEmailExist(email) || staffDAO.checkEmailExist(email)) {
            errorMsg = "Email already exists!";
        }

        if (errorMsg != null) {
            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("/authen/register.jsp").forward(request, response);
        } else {
            boolean success = customerDAO.register(fullName, email, password, phone);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/login?registerSuccess=true");
            } else {
                request.setAttribute("error", "Registration was not successful. Please try again!");
                request.getRequestDispatcher("/authen/register.jsp").forward(request, response);
            }
        }
    }
}
