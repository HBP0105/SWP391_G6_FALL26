/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package com.swp391.controller;

import com.swp391.dao.OrderDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author admin
 */
@WebServlet(name="VNPayReturnServlet", urlPatterns={"/vnpay-return"})
public class VNPayReturnServlet extends HttpServlet {
    
    private OrderDAO orderDAO;
    
    @Override
    public void init() throws ServletException{
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        HttpSession session = request.getSession();
        // Đọc các tham số kết quả do VNPay trả về trên URL
        String orderIdStr = request.getParameter("vnp_TxnRef");
        String responseCode = request.getParameter("vnp_ResponseCode");
        String transactionNo = request.getParameter("vnp_TransactionNo");
        
        if(orderIdStr != null){
            int orderId = Integer.parseInt(orderIdStr);
            // Mã "00" nghĩa là giao dịch THÀNH CÔNG -> Đơn hàng được CONFIRMED ngay lập tức
            if("00".equals(responseCode)){
                orderDAO.updateVNPayStatus(orderId, transactionNo, responseCode, true);
                session.removeAttribute("cart");
                response.sendRedirect(request.getContextPath() + "/my-orders?orderSuccess=true&method=VNPAY&status=CONFIRMED&orderId=" + orderId);
            }else{
                // Khách hủy giao dịch hoặc thẻ lỗi -> Đơn hàng chuyển sang CANCELLED
                orderDAO.updateVNPayStatus(orderId, transactionNo, responseCode, false);
                response.sendRedirect(request.getContextPath() + "/my-orders?paymentFailed=true&status=CANCELLED&orderId=" + orderId);
            }
        }else{
            response.sendRedirect(request.getContextPath() + "/home");
        }
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        
    }

}
