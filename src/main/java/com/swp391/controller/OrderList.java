/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package com.swp391.controller;

import com.swp391.dao.OrderDAO;
import com.swp391.model.Order;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.util.List;

/**
 *
 * @author HP
 */
@WebServlet(name="OrderList", urlPatterns={"/staff/orders"})
public class OrderList extends HttpServlet {
   
    private OrderDAO orderDAO;
    @Override
    public void init() {
        orderDAO = new OrderDAO();
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet OrderList</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet OrderList at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        
        // Filter parameters
        String statusFilter = request.getParameter("status");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String keyword = request.getParameter("keyword");

        // Date Validation Logic
        String msgError = null;
        LocalDate today = LocalDate.now();

        if (startDate != null && !startDate.trim().isEmpty()) {
            try {
                LocalDate start = LocalDate.parse(startDate.trim());
                if (start.isAfter(today)) {
                    msgError = "\"From Date\" cannot be in the future!";
                    startDate = "";
                }
            } catch (Exception e) {
                msgError = "Invalid \"From Date\" format!";
                startDate = "";
            }
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            try {
                LocalDate end = LocalDate.parse(endDate.trim());
                if (end.isAfter(today)) {
                    msgError = "\"To Date\" cannot be in the future!";
                    endDate = "";
                }
            } catch (Exception e) {
                msgError = "Invalid \"To Date\" format!";
                endDate = "";
            }
        }

        if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
            try {
                LocalDate start = LocalDate.parse(startDate.trim());
                LocalDate end = LocalDate.parse(endDate.trim());
                if (start.isAfter(end)) {
                    msgError = "\"From Date\" cannot be later than \"To Date\"!";
                    startDate = "";
                    endDate = "";
                }
            } catch (Exception e) {
                msgError = "Invalid date range!";
                startDate = "";
                endDate = "";
            }
        }

        // Export Action: Export ALL matching orders from Database (Unpaginated)
        String action = request.getParameter("action");
        if ("export".equals(action)) {
            exportToCSV(request, response, startDate, endDate, statusFilter, keyword);
            return;
        }

        if (msgError != null) {
            request.setAttribute("msgError", msgError);
        }

        // Stat counts based on active date range filters
        int pendingCount = orderDAO.getTotalOrdersFilteredCount(startDate, endDate, "PENDING");
        int confirmedCount = orderDAO.getTotalOrdersFilteredCount(startDate, endDate, "CONFIRMED");
        int shippingCount = orderDAO.getTotalOrdersFilteredCount(startDate, endDate, "SHIPPING");
        int deliveredCount = orderDAO.getTotalOrdersFilteredCount(startDate, endDate, "DELIVERED");
        int cancelledCount = orderDAO.getTotalOrdersFilteredCount(startDate, endDate, "CANCELLED");

        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("confirmedCount", confirmedCount);
        request.setAttribute("shippingCount", shippingCount);
        request.setAttribute("deliveredCount", deliveredCount);
        request.setAttribute("cancelledCount", cancelledCount);

        // Pagination parameters
        int page = 1;
        int pageSize = 5; // Display 5 orders per page
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int totalOrders = orderDAO.getTotalOrdersFilteredCount(startDate, endDate, statusFilter, keyword);
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Order> orderList = orderDAO.getOrdersFiltered(startDate, endDate, statusFilter, keyword, page, pageSize);
        
        request.setAttribute("orders", orderList);
        request.setAttribute("selectedStatus", statusFilter != null ? statusFilter : "ALL");
        request.setAttribute("selectedStartDate", startDate != null ? startDate : "");
        request.setAttribute("selectedEndDate", endDate != null ? endDate : "");
        request.setAttribute("selectedKeyword", keyword != null ? keyword : "");
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);

        request.getRequestDispatcher("/views/staff/order-list.jsp").forward(request, response);
    } 

    private void exportToCSV(HttpServletRequest request, HttpServletResponse response, 
                             String startDate, String endDate, String status, String keyword) 
            throws IOException {
        
        List<Order> allMatchingOrders = orderDAO.getOrdersFiltered(startDate, endDate, status, keyword, 1, Integer.MAX_VALUE);

        String filename = "Order_Report_" + LocalDate.now() + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try (PrintWriter writer = response.getWriter()) {
            // Write UTF-8 BOM byte for Excel UTF-8 compatibility
            writer.write('\uFEFF');

            // Header line
            writer.println("\"Order ID\",\"Customer\",\"Phone Number\",\"Shipping Address\",\"Total Amount (VND)\",\"Order Date\",\"Status\"");

            for (Order o : allMatchingOrders) {
                StringBuilder line = new StringBuilder();
                line.append("\"#ORD-").append(o.getOrderID()).append("\",");
                line.append("\"").append(escapeCSV(o.getShippingName())).append("\",");
                // Preserve leading zero in Excel for Phone Number
                line.append("=\"").append(escapeCSV(o.getShippingPhone())).append("\",");
                line.append("\"").append(escapeCSV(o.getShippingAddress())).append("\",");
                line.append("\"").append(o.getFormattedTotalAmount()).append("\",");
                // Preserve exact Date string in Excel to prevent Excel auto-reformatting US date mismatches
                line.append("=\"").append(o.getFormattedOrderDate()).append("\",");
                line.append("\"").append(o.getOrderStatus()).append("\"");
                writer.println(line.toString());
            }
            writer.flush();
        }
    }

    private String escapeCSV(String value) {
        if (value == null) return "";
        return value.replace("\"", "\"\"");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if ("updateStatus".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String newStatus = request.getParameter("newStatus");
                
                // State Machine Backend Validation
                boolean success = orderDAO.updateOrderStatusWithValidation(orderId, newStatus);
                if (success) {
                    request.getSession().setAttribute("msgSuccess", "true");
                    request.getSession().setAttribute("msgSuccessOrderId", orderId);
                    request.getSession().setAttribute("msgSuccessStatus", newStatus);
                } else {
                    request.getSession().setAttribute("msgErrorStatus", "Invalid status transition for Order #ORD-" + orderId + "!");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/staff/orders");
    }

    @Override
    public String getServletInfo() {
        return "Order Management Servlet";
    }

}
