package com.swp391.controller;

import com.swp391.model.Customer;
import com.swp391.model.Staff;
import com.swp391.service.AIPerformanceService;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
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
        String action = request.getParameter("action");

        // Action: Export CSV Report
        if ("export".equals(action)) {
            exportToCSV(response, startDate, endDate, type);
            return;
        }

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
                    request.getSession().setAttribute("msgSuccess", "Cấu hình AI Recommendation đã được cập nhật thành công và ghi nhận vào Audit Log!");
                }

            } catch (Exception e) {
                request.getSession().setAttribute("msgError", "Tham số cấu hình AI không hợp lệ: " + e.getMessage());
            }
        }

        // Post-Redirect-Get (PRG) pattern prevents duplicate form submission on refresh
        response.sendRedirect(request.getContextPath() + "/admin/ai-performance");
    }

    /**
     * Helper to safely extract staff/admin ID from session without Java reflection.
     */
    private Integer extractStaffId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;

        Object userObj = session.getAttribute("user");
        if (userObj == null) {
            userObj = session.getAttribute("staff");
        }

        if (userObj instanceof Staff staff) {
            return staff.getStaffID();
        } else if (userObj instanceof Customer customer) {
            return customer.getCustomerID();
        }
        return null;
    }

    private void exportToCSV(HttpServletResponse response, String startDate, String endDate, String type)
            throws IOException {
        String filename = "AI_Performance_Report_" + LocalDate.now() + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        String csvContent = aiPerformanceService.generateCSVAIPerformanceReport(startDate, endDate, type);
        try (PrintWriter writer = response.getWriter()) {
            writer.write(csvContent);
            writer.flush();
        }
    }

    @Override
    public String getServletInfo() {
        return "Admin AI Performance & Configuration Servlet";
    }
}
