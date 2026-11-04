package com.swp391.controller.Manager;

import com.swp391.model.Staff;
import com.swp391.service.Manager.ProfileService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/Manager/Profile")
public class Profile extends HttpServlet {

    private ProfileService profileService;

    @Override
    public void init() {
        profileService = new ProfileService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "profile");

        HttpSession session = request.getSession();
        Staff staff = getCurrentStaff(session);

        if (staff == null) {
            session.setAttribute("errorMsg", "Unable to locate manager account.");
            request.setAttribute("staff", null);
            request.getRequestDispatcher("/views/Manager/profile.jsp").forward(request, response);
            return;
        }

        Staff freshStaff = profileService.getStaffById(staff.getStaffId());
        if (freshStaff != null) {
            staff = freshStaff;
            session.setAttribute("staff", staff);
        }

        request.setAttribute("staff", staff);
        loadFlashMessages(request, session);

        String action = request.getParameter("action");
        if ("edit".equalsIgnoreCase(action)) {
            request.getRequestDispatcher("/views/Manager/profileEdit.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/views/Manager/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Staff staff = getCurrentStaff(session);

        if (staff == null) {
            session.setAttribute("errorMsg", "Unable to locate manager account.");
            response.sendRedirect(request.getContextPath() + "/Manager/Profile");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "updateProfile";
        }

        if ("changePassword".equalsIgnoreCase(action.trim())) {
            String error = profileService.changePassword(
                    staff.getStaffId(),
                    request.getParameter("currentPassword"),
                    request.getParameter("newPassword"),
                    request.getParameter("confirmPassword")
            );

            if (error != null) {
                session.setAttribute("errorMsg", error);
            } else {
                session.setAttribute("successMsg", "Password updated successfully!");
            }

            response.sendRedirect(request.getContextPath() + "/Manager/Profile");
            return;
        }

        String error = profileService.updateProfile(
                staff.getStaffId(),
                request.getParameter("fullName"),
                request.getParameter("email"),
                request.getParameter("phone")
        );

        if (error != null) {
            session.setAttribute("errorMsg", error);
            response.sendRedirect(request.getContextPath() + "/Manager/Profile?action=edit");
            return;
        }

        Staff updatedStaff = profileService.getStaffById(staff.getStaffId());
        if (updatedStaff != null) {
            session.setAttribute("staff", updatedStaff);
        }
        session.setAttribute("successMsg", "Profile information updated successfully!");
        response.sendRedirect(request.getContextPath() + "/Manager/Profile");
    }

    private Staff getCurrentStaff(HttpSession session) {
        Staff staff = (Staff) session.getAttribute("staff");

        if (staff == null) {
            staff = (Staff) session.getAttribute("user");
        }

        if (staff == null) {
            staff = profileService.getOrCreateDefaultManager();
            if (staff != null) {
                session.setAttribute("staff", staff);
            }
        }

        return staff;
    }

    private void loadFlashMessages(HttpServletRequest request, HttpSession session) {
        String successMsg = (String) session.getAttribute("successMsg");
        if (successMsg != null) {
            request.setAttribute("successMsg", successMsg);
            session.removeAttribute("successMsg");
        }

        String errorMsg = (String) session.getAttribute("errorMsg");
        if (errorMsg != null) {
            request.setAttribute("errorMsg", errorMsg);
            session.removeAttribute("errorMsg");
        }
    }
}
