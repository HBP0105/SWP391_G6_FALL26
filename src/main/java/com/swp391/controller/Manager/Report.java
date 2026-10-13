package com.swp391.controller.manager;

import com.swp391.service.ReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/Manager/Report")
public class Report extends HttpServlet {

    private ReportService reportService;

    @Override
    public void init() {
        reportService = new ReportService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "reports");

        String period = request.getParameter("period");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String status = request.getParameter("status");
        String yearStr = request.getParameter("year");

        // Delegate period resolution to service
        Map<String, Object> filters = reportService.resolveFilters(
                period, startDate, endDate, status, yearStr
        );

        startDate = (String) filters.get("startDate");
        endDate = (String) filters.get("endDate");
        status = (String) filters.get("status");
        int currentYear = (int) filters.get("currentYear");

        Map<String, Object> overviewStats = reportService.getOverviewStats(startDate, endDate, status);
        List<Map<String, Object>> monthlyRevenue = reportService.getMonthlyRevenue(currentYear);
        Map<String, Object> statusDistribution = reportService.getOrderStatusDistribution(startDate, endDate);
        List<Map<String, Object>> topProducts = reportService.getTopSellingProducts(5, startDate, endDate);
        List<Map<String, Object>> categorySales = reportService.getCategorySales(startDate, endDate);
        List<Map<String, Object>> ordersReport = reportService.getOrdersReport(startDate, endDate, status);

        request.setAttribute("overviewStats", overviewStats);
        request.setAttribute("monthlyRevenue", monthlyRevenue);
        request.setAttribute("statusDistribution", statusDistribution);
        request.setAttribute("topProducts", topProducts);
        request.setAttribute("categorySales", categorySales);
        request.setAttribute("ordersReport", ordersReport);

        request.setAttribute("selectedPeriod", period != null ? period : "all");
        request.setAttribute("selectedStatus", status);
        request.setAttribute("startDate", startDate != null ? startDate : "");
        request.setAttribute("endDate", endDate != null ? endDate : "");
        request.setAttribute("currentYear", currentYear);

        request.getRequestDispatcher("/views/Manager/report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
