package com.swp391.controller;

import com.swp391.service.BehaviorService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

/**
 * Controller handling Admin Customer Behavior Data Pipeline Dashboard (Screen 5).
 * URL: /admin/behavior-pipeline
 */
@WebServlet(name = "BehaviorPipeline", urlPatterns = {"/admin/behavior-pipeline"})
public class BehaviorPipeline extends HttpServlet {

    private BehaviorService behaviorService;

    @Override
    public void init() {
        this.behaviorService = new BehaviorService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String type = request.getParameter("type");

        Map<String, Object> viewData = behaviorService.getBehaviorPipelineBundle(startDate, endDate, type);

        viewData.forEach(request::setAttribute);

        request.getRequestDispatcher("/views/admin/behavior-pipeline.jsp").forward(request, response);
    }
}
