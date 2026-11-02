package com.swp391.controller;

import com.swp391.dao.AddressDAO;
import com.swp391.dao.OrderDAO;
import com.swp391.model.Address;
import com.swp391.model.CartItemDTO;
import com.swp391.model.Customer;
import com.swp391.util.VNPayConfig;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private AddressDAO addressDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        addressDAO = new AddressDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Map<Integer, CartItemDTO> cart = (Map<Integer, CartItemDTO>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        List<Address> savedAddresses = addressDAO.getAddressesByCustomerId(customer.getCustomerID());
        request.setAttribute("savedAddresses", savedAddresses);
        request.setAttribute("listCart", new ArrayList<>(cart.values()));
        request.getRequestDispatcher("/views/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8"); 
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Map<Integer, CartItemDTO> cart = (Map<Integer, CartItemDTO>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        try {
            // Khách hàng tự nhập địa chỉ giao hàng
            String addressLine = request.getParameter("addressLine");
            String ward = request.getParameter("ward");
            String district = request.getParameter("district");
            String province = request.getParameter("province");
            String address = addressLine + ", " + ward + ", " + district + ", " + province;
            
            String paymentMethod = request.getParameter("paymentMethod");
            String notes = request.getParameter("orderNotes");
            
            // Tính tổng tiền để gửi sang VNPay
            double totalAmount = 0;
            for(CartItemDTO item : cart.values()){
                totalAmount += (item.getPrice() * item.getQuantity());
            }
            
            // Lưu đơn hàng vào Database (COD)
            int orderId = orderDAO.placeOrder(customer.getCustomerID(), cart, address, paymentMethod, notes);

            if (orderId > 0) {
                // NHÁNH 1: Nếu khách chọn thanh toán qua VNPAY
                if ("VNPAY".equalsIgnoreCase(paymentMethod)) {
                    long amount = (long) (totalAmount * 100); // VNPay quy định nhân 100
                    Map<String, String> vnp_Params = new HashMap<>();
                    vnp_Params.put("vnp_Version", "2.1.0");
                    vnp_Params.put("vnp_Command", "pay");
                    vnp_Params.put("vnp_TmnCode", VNPayConfig.vnp_TmnCode);
                    vnp_Params.put("vnp_Amount", String.valueOf(amount));
                    vnp_Params.put("vnp_CurrCode", "VND");
                    vnp_Params.put("vnp_TxnRef", String.valueOf(orderId));
                    vnp_Params.put("vnp_OrderInfo", "Payment for order #ORD-" + orderId);
                    vnp_Params.put("vnp_OrderType", "other");
                    vnp_Params.put("vnp_Locale", "vn");
                    vnp_Params.put("vnp_ReturnUrl", VNPayConfig.vnp_ReturnUrl);
                    vnp_Params.put("vnp_IpAddr", VNPayConfig.getIpAddress(request));
                    Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
                    SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
                    vnp_Params.put("vnp_CreateDate", formatter.format(cld.getTime()));
                    // Sắp xếp tham số A-Z và tạo chuỗi băm
                    List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
                    Collections.sort(fieldNames);
                    StringBuilder hashData = new StringBuilder();
                    StringBuilder query = new StringBuilder();
                    for (int i = 0; i < fieldNames.size(); i++) {
                        String fieldName = fieldNames.get(i);
                        String fieldValue = vnp_Params.get(fieldName);
                        if ((fieldValue != null) && (fieldValue.length() > 0)) {
                            hashData.append(fieldName).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                            query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString())).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                            if (i < fieldNames.size() - 1) {
                                query.append('&');
                                hashData.append('&');
                            }
                        }
                    }
                    String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.vnp_HashSecret, hashData.toString());
                    String paymentUrl = VNPayConfig.vnp_PayUrl + "?" + query.toString() + "&vnp_SecureHash=" + vnp_SecureHash;
                    // Chuyển hướng khách sang cổng VNPay
                    response.sendRedirect(paymentUrl);
                    return;
                }
                // NHÁNH 2: Nếu khách chọn COD
                // Xóa giỏ hàng trên Session sau khi đặt thành công
                session.removeAttribute("cart");
                
                // Chuyển hướng sang trang My Order (Tab PENDING) kèm thông báo thành công
                response.sendRedirect(request.getContextPath() + "/my-orders?orderSuccess=true&method=COD&status=PENDING&orderId=" + orderId); 
            } else {
                response.getWriter().println("An error occurred while placing your order! Please try again.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("System error: " + e.getMessage());
        }
    }
}
