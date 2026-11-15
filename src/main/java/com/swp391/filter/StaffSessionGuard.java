package com.swp391.filter;

import com.swp391.dao.StaffDAO;
import com.swp391.model.Staff;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Shared live-session guard for Staff filters (Admin / Manager).
 * Verifies against DB that the logged-in staff account is still ACTIVE and holds the required role.
 */
final class StaffSessionGuard {

    private static final StaffDAO STAFF_DAO = new StaffDAO();

    private StaffSessionGuard() {
    }

    static boolean authorize(
            HttpServletRequest request,
            HttpServletResponse response,
            String requiredRole,
            String forbiddenMessage) throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        Object staffObj = session.getAttribute("staff");
        if (!(staffObj instanceof Staff)) {
            Object roleObj = session.getAttribute("role");
            String role = roleObj != null ? roleObj.toString() : null;
            if (role != null && !requiredRole.equalsIgnoreCase(role)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, forbiddenMessage);
                return false;
            }
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        Staff sessionStaff = (Staff) staffObj;
        Staff liveStaff = STAFF_DAO.getStaffAuthStateById(sessionStaff.getStaffId());
        if (liveStaff == null || !"ACTIVE".equalsIgnoreCase(liveStaff.getStatus())) {
            String statusText = (liveStaff != null && liveStaff.getStatus() != null)
                    ? liveStaff.getStatus().toLowerCase()
                    : "disabled";
            session.invalidate();
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("loginError",
                    "Your staff account has been " + statusText + ". Please contact administrator.");
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        // Sync role/profile changes made while the staff member was logged in
        session.setAttribute("staff", liveStaff);
        session.setAttribute("user", liveStaff);
        session.setAttribute("role", liveStaff.getRoleName());

        if (!requiredRole.equalsIgnoreCase(liveStaff.getRoleName())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, forbiddenMessage);
            return false;
        }

        return true;
    }
}
