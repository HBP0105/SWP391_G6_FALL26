package com.swp391.filter;

import com.swp391.dao.CustomerDAO;
import com.swp391.model.Customer;
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

/**
 * Ensures any active customer session is immediately invalidated if an Admin bans or deactivates the account.
 */
@WebFilter("/*")
public class CustomerSessionStatusFilter implements Filter {

    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();
        String path = uri.substring(contextPath.length());

        if (isBypassedPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        Object customerObj = session != null ? session.getAttribute("customer") : null;
        if (customerObj instanceof Customer) {
            Customer customer = (Customer) customerObj;
            String liveStatus = customerDAO.getCustomerStatusById(customer.getCustomerID());
            if (liveStatus == null || !"ACTIVE".equalsIgnoreCase(liveStatus)) {
                String statusText = liveStatus != null ? liveStatus.toLowerCase() : "disabled";
                session.invalidate();
                HttpSession newSession = request.getSession(true);
                newSession.setAttribute("loginError",
                        "Your account has been " + statusText + ". Please contact administrator.");
                response.sendRedirect(contextPath + "/login");
                return;
            }
            customer.setStatus(liveStatus);
        }

        chain.doFilter(request, response);
    }

    private boolean isBypassedPath(String path) {
        return path.startsWith("/assets/")
                || path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/images/")
                || path.startsWith("/fonts/")
                || "/favicon.ico".equals(path)
                || "/login".equals(path)
                || "/logout".equals(path)
                || "/register".equals(path);
    }
}
