package com.swp391.controller;

import com.swp391.model.Staff;
import com.swp391.service.AIPerformanceService;

import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller for Admin AI Performance & Configuration Reporting (Screen 4).
 * Handles HTTP GET requests for viewing metrics and exporting CSV reports,
 * and HTTP POST requests with Post-Redirect-Get (PRG) pattern for updating AI configuration.
 * Forwards data to /views/admin/ai-performance-report.jsp.
 */
@WebServlet(name = "AIPerformanceReport", urlPatterns = {"/admin/ai-performance"})
public class AIPerformanceReport extends HttpServlet {

    private AIPerformanceService aiPerformanceService;

    @Override
    public void init() {
        aiPerformanceService = new AIPerformanceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // PRG Session Flash Message cleanup (transfers attributes to Request scope)
        HttpSession session = request.getSession(false);
        if (session != null) {
            if (session.getAttribute("msgSuccess") != null) {
                request.setAttribute("msgSuccess", session.getAttribute("msgSuccess"));
                session.removeAttribute("msgSuccess");
            }
            if (session.getAttribute("msgError") != null) {
                request.setAttribute("msgError", session.getAttribute("msgError"));
                session.removeAttribute("msgError");
            }
        }

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String type = request.getParameter("type");

        Map<String, Object> viewData = aiPerformanceService.getAIPerformanceBundle(startDate, endDate, type);

        viewData.forEach(request::setAttribute);

        request.getRequestDispatcher("/views/admin/ai-performance-report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("updateConfig".equals(action)) {
            try {
                double simWeight = Double.parseDouble(request.getParameter("similarityWeight"));
                double behWeight = Double.parseDouble(request.getParameter("behaviorWeight"));
                double minThreshold = Double.parseDouble(request.getParameter("minSimilarityThreshold"));
                int topK = Integer.parseInt(request.getParameter("topKLimit"));
                String fallbackStrategy = request.getParameter("fallbackStrategy");

                Integer staffId = extractStaffId(request);

                String err = aiPerformanceService.updateAIConfiguration(simWeight, behWeight, minThreshold, topK, fallbackStrategy, staffId);

                if (err != null) {
                    request.getSession().setAttribute("msgError", err);
                } else {
                    request.getSession().setAttribute("msgSuccess", "AI Recommendation configuration updated successfully and recorded in Audit Log!");
                }

            } catch (Exception e) {
                request.getSession().setAttribute("msgError", "Invalid AI configuration parameters: " + e.getMessage());
            }
        }

        // Post-Redirect-Get (PRG) pattern prevents duplicate form submission on refresh
        response.sendRedirect(request.getContextPath() + "/admin/ai-performance");
    }

    /**
     * Helper to safely extract Admin/Staff ID from session without Java reflection.
     */
    private Integer extractStaffId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;

        Object userObj = session.getAttribute("staff");
        if (userObj == null) {
            userObj = session.getAttribute("user");
        }

        if (userObj instanceof Staff) {
            return ((Staff) userObj).getStaffID();
        }
        return null;
    }

    @Override
    public String getServletInfo() {
        return "Admin AI Performance & Configuration Servlet";
    }
}
