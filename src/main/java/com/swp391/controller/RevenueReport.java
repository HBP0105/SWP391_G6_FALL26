package com.swp391.controller;

import com.swp391.service.RevenueService;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Thin Controller for Admin Overview Revenue Reporting (Screen 3).
 * Handles HTTP requests, delegates validation & metric calculation to RevenueService,
 * and forwards data to /views/admin/revenue-report.jsp.
 */
@WebServlet(name = "RevenueReport", urlPatterns = {"/admin/revenue-report"})
public class RevenueReport extends HttpServlet {

    private RevenueService revenueService;

    @Override
    public void init() {
        revenueService = new RevenueService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String groupBy = request.getParameter("groupBy");
        String action = request.getParameter("action");

        // Export Action: Export CSV Report
        if ("export".equals(action)) {
            exportToCSV(response, startDate, endDate, groupBy);
            return;
        }

        // Delegate calculations to RevenueService
        Map<String, Object> viewData = revenueService.getRevenueReportBundle(startDate, endDate, groupBy);

        viewData.forEach(request::setAttribute);

        request.getRequestDispatcher("/views/admin/revenue-report.jsp").forward(request, response);
    }

    private void exportToCSV(HttpServletResponse response, String startDate, String endDate, String groupBy)
            throws IOException {
        String filename = "Revenue_Report_" + LocalDate.now() + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        String csvContent = revenueService.generateCSVRevenueReport(startDate, endDate, groupBy);
        try (PrintWriter writer = response.getWriter()) {
            writer.write(csvContent);
            writer.flush();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Admin Revenue Report Servlet";
    }
}
