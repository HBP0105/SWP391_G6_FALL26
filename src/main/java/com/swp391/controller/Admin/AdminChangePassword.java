package com.swp391.controller.Admin;

import com.swp391.model.Staff;
import com.swp391.service.Admin.UserManagementService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Allows the signed-in Administrator to change their own password inside the Admin Portal.
 * Protected by AdminAuthFilter (/admin/*).
 */
@WebServlet("/admin/change-password")
public class AdminChangePassword extends HttpServlet {

    private UserManagementService service;

    @Override
    public void init() {
        this.service = new UserManagementService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            Object success = session.getAttribute("adminPwSuccess");
            Object error = session.getAttribute("adminPwError");
            if (success != null) {
                request.setAttribute("successMessage", success);
                session.removeAttribute("adminPwSuccess");
            }
            if (error != null) {
                request.setAttribute("errorMessage", error);
                session.removeAttribute("adminPwError");
            }
        }

        request.getRequestDispatcher("/views/admin/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        Object staffObj = session != null ? session.getAttribute("staff") : null;
        if (!(staffObj instanceof Staff)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        Staff currentAdmin = (Staff) staffObj;

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            service.changeOwnPassword(currentAdmin.getStaffId(), currentPassword, newPassword, confirmPassword);
            currentAdmin.setPasswordHash(newPassword.trim());
            session.setAttribute("staff", currentAdmin);
            session.setAttribute("user", currentAdmin);
            session.setAttribute("adminPwSuccess", "Your administrator password has been updated successfully.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("adminPwError", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("adminPwError", "Unable to change password: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/change-password");
    }
}
