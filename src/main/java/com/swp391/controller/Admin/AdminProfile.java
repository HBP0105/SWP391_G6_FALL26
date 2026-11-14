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
import java.util.Map;

/**
 * Controller for Administrator Own Profile (/admin/profile).
 */
@WebServlet("/admin/profile")
public class AdminProfile extends HttpServlet {

    private UserManagementService service;

    @Override
    public void init() {
        this.service = new UserManagementService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Object staffObj = session != null ? session.getAttribute("staff") : null;
        if (!(staffObj instanceof Staff currentAdmin)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Object success = session.getAttribute("adminProfileSuccess");
        Object error = session.getAttribute("adminProfileError");
        if (success != null) {
            request.setAttribute("successMessage", success);
            session.removeAttribute("adminProfileSuccess");
        }
        if (error != null) {
            request.setAttribute("errorMessage", error);
            session.removeAttribute("adminProfileError");
        }

        Map<String, Object> profile = service.getUserDetail("STAFF", currentAdmin.getStaffId());
        request.setAttribute("profile", profile);

        request.getRequestDispatcher("/views/admin/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        Object staffObj = session != null ? session.getAttribute("staff") : null;
        if (!(staffObj instanceof Staff currentAdmin)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");

        try {
            service.updateOwnProfile(currentAdmin.getStaffId(), fullName, phone);
            currentAdmin.setFullName(fullName.trim());
            currentAdmin.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : null);
            session.setAttribute("staff", currentAdmin);
            session.setAttribute("user", currentAdmin);
            session.setAttribute("adminProfileSuccess", "Your administrator profile has been updated successfully.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("adminProfileError", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("adminProfileError", "Unable to update profile: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/profile");
    }
}
