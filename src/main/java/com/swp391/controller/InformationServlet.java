package com.swp391.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Set;

@WebServlet(name = "InformationServlet", urlPatterns = {"/information"})
public class InformationServlet extends HttpServlet {

    private static final Set<String> TOPICS = Set.of(
            "about", "contact", "privacy", "returns", "terms", "help"
    );

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String topic = request.getParameter("topic");
        if (topic == null || !TOPICS.contains(topic)) {
            topic = "about";
        }
        request.setAttribute("topic", topic);
        request.getRequestDispatcher("/views/information.jsp").forward(request, response);
    }
}
