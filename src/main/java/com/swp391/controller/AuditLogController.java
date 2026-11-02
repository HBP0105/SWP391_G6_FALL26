package com.swp391.controller;

import com.swp391.service.AuditLogService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

/**
 * Controller for System Audit Logs (Feature 5).
 * Maps to /admin/audit-logs and /staff/audit-logs.
 */
@WebServlet(name = "AuditLogController", urlPatterns = {"/admin/audit-logs", "/staff/audit-logs"})
public class AuditLogController extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 15;
    private AuditLogService auditLogService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.auditLogService = new AuditLogService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String action = request.getParameter("action");
        String keyword = request.getParameter("keyword");
        String pageParam = request.getParameter("page");

        Map<String, Object> viewData = auditLogService.getAuditLogBundle(
                startDate, endDate, action, keyword, pageParam, DEFAULT_PAGE_SIZE);

        viewData.forEach(request::setAttribute);

        request.getRequestDispatcher("/views/admin/audit-logs.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "System Audit Logs Controller";
    }
}
