package com.swp391.controller.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Controller for /admin/account-access.
 * Unified with UserManagement - redirects GET and forwards POST to /admin/users.
 */
@WebServlet("/admin/account-access")
public class AccountAccess extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String queryString = request.getQueryString();
        String redirectUrl = request.getContextPath() + "/admin/users" + (queryString != null && !queryString.isBlank() ? "?" + queryString : "");
        response.sendRedirect(redirectUrl);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/users").forward(request, response);
    }
}
