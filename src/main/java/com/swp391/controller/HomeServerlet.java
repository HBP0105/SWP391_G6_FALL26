package com.swp391.controller;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class HomeServerlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("msg", "Hello t? Servlet!");
        request.getRequestDispatcher("views/home.jsp").forward(request, response);
    }
}