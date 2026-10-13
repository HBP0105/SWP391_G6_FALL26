package com.swp391.controller;

import com.swp391.service.OrderService;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.util.Map;

/**
 * Thin Controller for Order Management & Listing (Screen 1 Dashboard).
 * Strictly handles HTTP Request/Response flow and delegates all business logic,
 * validation, state transitions, and CSV generation to OrderService.
 */
@WebServlet(name = "OrderList", urlPatterns = {"/staff/orders"})
public class OrderList extends HttpServlet {
   
    private static final int DEFAULT_PAGE_SIZE = 10; // Hằng số cấu hình kích thước trang mặc định (10 đơn hàng/trang)
    private OrderService orderService;
    
    @Override
    public void init() {
        orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String statusFilter = request.getParameter("status");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String keyword = request.getParameter("keyword");
        String action = request.getParameter("action");
        String pageParam = request.getParameter("page");

        // Xuất báo cáo CSV: Ủy quyền toàn bộ xử lý cho OrderService
        if ("export".equals(action)) {
            exportToCSV(request, response, startDate, endDate, statusFilter, keyword);
            return;
        }

        // Đọc thông báo từ Session đưa vào Request scope (PRG Pattern)
        HttpSession session = request.getSession(false);
        if (session != null) {
            if (session.getAttribute("msgSuccess") != null) {
                request.setAttribute("msgSuccess", session.getAttribute("msgSuccess"));
                request.setAttribute("msgSuccessOrderId", session.getAttribute("msgSuccessOrderId"));
                request.setAttribute("msgSuccessStatus", session.getAttribute("msgSuccessStatus"));
                session.removeAttribute("msgSuccess");
                session.removeAttribute("msgSuccessOrderId");
                session.removeAttribute("msgSuccessStatus");
            }
            if (session.getAttribute("msgErrorStatus") != null) {
                request.setAttribute("msgErrorStatus", session.getAttribute("msgErrorStatus"));
                session.removeAttribute("msgErrorStatus");
            }
        }

        // Ủy quyền lấy dữ liệu, phân trang và đếm chỉ số cho OrderService
        Map<String, Object> viewData = orderService.getOrderListBundle(startDate, endDate, statusFilter, keyword, pageParam, DEFAULT_PAGE_SIZE);
        
        viewData.forEach(request::setAttribute);

        request.getRequestDispatcher("/views/staff/order-list.jsp").forward(request, response);
    } 

    private void exportToCSV(HttpServletRequest request, HttpServletResponse response, 
            String startDate, String endDate, String status, String keyword) throws IOException {
        
        String csvContent = orderService.generateCSVReport(startDate, endDate, status, keyword);
        if (csvContent != null && csvContent.startsWith("\uFEFF\"Export Error:")) {
            // Lỗi xác thực khoảng ngày do OrderService trả về
            String errorMsg = csvContent.replace("\uFEFF\"Export Error:", "").replace("\"\n", "").replace("\"\"", "\"").trim();
            request.getSession().setAttribute("msgErrorStatus", errorMsg);
            response.sendRedirect(request.getContextPath() + "/staff/orders");
            return;
        }

        String filename = "Order_Report_" + LocalDate.now() + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try (PrintWriter writer = response.getWriter()) {
            writer.write(csvContent != null ? csvContent : "");
            writer.flush();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty() || !"updateStatus".equals(action)) {
            request.getSession().setAttribute("msgErrorStatus", "Invalid or unsupported action requested!");
            response.sendRedirect(request.getContextPath() + "/staff/orders");
            return;
        }

        String orderIdParam = request.getParameter("orderId");
        int orderId = 0;
        try {
            if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
                orderId = Integer.parseInt(orderIdParam.trim());
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("msgErrorStatus", "Invalid parameter: Order ID must be a numeric integer!");
            response.sendRedirect(request.getContextPath() + "/staff/orders");
            return;
        }

        String newStatus = request.getParameter("newStatus");
        String cancelReason = request.getParameter("cancelReason");
        String shippingProvider = request.getParameter("shippingProvider");
        String trackingNumber = request.getParameter("trackingNumber");
        String shipperName = request.getParameter("shipperName");
        String shipperPhone = request.getParameter("shipperPhone");

        // Ủy quyền toàn bộ kiểm tra nghiệp vụ và cập nhật trạng thái cho OrderService
        String errorMessage = orderService.processStatusUpdate(orderId, newStatus, cancelReason, shippingProvider, trackingNumber, shipperName, shipperPhone);
        if (errorMessage == null) {
            request.getSession().setAttribute("msgSuccess", "true");
            request.getSession().setAttribute("msgSuccessOrderId", orderId);
            request.getSession().setAttribute("msgSuccessStatus", newStatus);
        } else {
            request.getSession().setAttribute("msgErrorStatus", errorMessage);
        }

        response.sendRedirect(request.getContextPath() + "/staff/orders");
    }

    @Override
    public String getServletInfo() {
        return "Order Management Thin Servlet Controller";
    }
}
