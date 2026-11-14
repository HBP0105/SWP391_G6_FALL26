package com.swp391.filter;

import com.swp391.dao.AccountStatusDAO;
import com.swp391.dao.AccountStatusDAO.AccountState;
import com.swp391.model.Customer;
import com.swp391.model.Role;
import com.swp391.model.Staff;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Revalidates authenticated sessions against the database on every dynamic
 * request. This prevents an account disabled in one browser from continuing to
 * use an already-authenticated session in another browser.
 */
@WebFilter(filterName = "SessionAccountStatusFilter", urlPatterns = "/*")
public class SessionAccountStatusFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(SessionAccountStatusFilter.class.getName());
    private final AccountStatusDAO accountStatusDAO = new AccountStatusDAO();

    @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;
        String servletPath = request.getServletPath();

        if (isStaticResource(servletPath)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        if (session == null) {
            chain.doFilter(request, response);
            return;
        }

        Customer customer = session.getAttribute("customer") instanceof Customer value ? value : null;
        Staff staff = session.getAttribute("staff") instanceof Staff value ? value : null;
        if (customer == null && staff == null) {
            chain.doFilter(request, response);
            return;
        }

        try {
            AccountState state;
            if (customer != null) {
                state = accountStatusDAO.findCustomerState(customer.getCustomerID());
                if (state != null) {
                    customer.setStatus(state.status());
                }
            } else {
                state = accountStatusDAO.findStaffState(staff.getStaffId());
                if (state != null) {
                    refreshStaffSession(session, staff, state);
                }
            }

            if (state == null || !state.isActive()) {
                String reason = state != null && "BANNED".equalsIgnoreCase(state.status())
                        ? "account-banned"
                        : "account-inactive";
                invalidateAndReject(request, response, session, reason);
                return;
            }
        } catch (RuntimeException e) {
            // Fail open for a temporary database outage; authentication must not
            // become unavailable merely because the status check cannot connect.
            LOGGER.log(Level.WARNING, "Unable to refresh live account status", e);
        }

        chain.doFilter(request, response);
    }

    private void refreshStaffSession(HttpSession session, Staff staff, AccountState state) {
        staff.setStatus(state.status());
        if (state.roleId() != null) {
            Role role = staff.getRole();
            if (role == null) {
                role = new Role();
            }
            role.setRoleId(state.roleId());
            role.setRoleName(state.roleName());
            staff.setRole(role);
        }
        session.setAttribute("role", state.roleName());
        session.setAttribute("staff", staff);
        session.setAttribute("user", staff);
    }

    private void invalidateAndReject(HttpServletRequest request,
                                     HttpServletResponse response,
                                     HttpSession session,
                                     String reason) throws IOException {
        try {
            session.invalidate();
        } catch (IllegalStateException ignored) {
            // Another concurrent request already invalidated this session.
        }

        String loginUrl = request.getContextPath() + "/login?reason=" + reason;
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        if ("/session-status".equals(request.getServletPath()) || isAjaxRequest(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"authenticated\":true,\"active\":false,\"loginUrl\":\""
                    + loginUrl + "\"}");
            return;
        }
        response.sendRedirect(loginUrl);
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        return "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || (request.getHeader("Accept") != null
                    && request.getHeader("Accept").contains("application/json"));
    }

    private boolean isStaticResource(String path) {
        return path.startsWith("/assets/")
                || path.startsWith("/uploads/")
                || path.equals("/favicon.ico");
    }
}
