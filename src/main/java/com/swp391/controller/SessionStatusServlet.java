package com.swp391.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** Browser heartbeat endpoint. Live DB validation is performed by the filter. */
@WebServlet("/session-status")
public class SessionStatusServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        boolean authenticated = session != null
                && (session.getAttribute("customer") != null || session.getAttribute("staff") != null);
        response.getWriter().write(authenticated
                ? "{\"authenticated\":true,\"active\":true}"
                : "{\"authenticated\":false,\"active\":false}");
    }
}
