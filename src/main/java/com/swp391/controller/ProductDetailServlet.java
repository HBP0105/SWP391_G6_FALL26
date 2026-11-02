package com.swp391.controller;

import com.swp391.dao.ProductDAO;
import com.swp391.model.Customer;
import com.swp391.model.Product;
import com.swp391.service.AIPerformanceService;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "ProductDetailServlet", urlPatterns = {"/productDetail"})
public class ProductDetailServlet extends HttpServlet {

    private AIPerformanceService aiPerformanceService;

    @Override
    public void init() {
        this.aiPerformanceService = new AIPerformanceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        String recIdParam = request.getParameter("recId");
        int productId = 0;

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                productId = Integer.parseInt(idParam.trim());
            } catch (NumberFormatException e) {
                productId = 0;
            }
        }

        // Nếu người dùng không truyền ID hoặc ID không hợp lệ, tự động chuyển hướng đến sản phẩm nổi bật ID = 1002
        if (productId <= 0) {
            response.sendRedirect(request.getContextPath() + "/productDetail?id=1002");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        Product product = productDAO.getProductById(productId);

        // Lấy Session ID và Customer ID nếu đã đăng nhập
        HttpSession session = request.getSession(true);
        String sessionId = session.getId();
        Integer customerId = extractCustomerId(session);

        // Tracking lượt Click từ AI Recommendation nếu có recId trên URL
        if (recIdParam != null && !recIdParam.trim().isEmpty()) {
            try {
                long recId = Long.parseLong(recIdParam.trim());
                if (aiPerformanceService != null) {
                    aiPerformanceService.trackRecommendationClick(recId, productId, customerId, sessionId);
                }
            } catch (Exception ignored) {
            }
        }

        // Tính toán danh sách AI 512-Vector Hybrid Recommendations
        if (product != null && aiPerformanceService != null) {
            try {
                List<Map<String, Object>> aiRecs = aiPerformanceService.getRecommendedProductsForDetail(productId, customerId, sessionId);
                request.setAttribute("aiRecommendations", aiRecs);
            } catch (Exception e) {
                // Fail-safe: lỗi AI không làm sập trang xem chi tiết sản phẩm
            }
        }

        request.setAttribute("product", product);
        request.getRequestDispatcher("/views/productDetail.jsp").forward(request, response);
    }

    private Integer extractCustomerId(HttpSession session) {
        if (session == null) return null;
        Object userObj = session.getAttribute("user");
        if (userObj == null) {
            userObj = session.getAttribute("customer");
        }
        if (userObj instanceof Customer) {
            return ((Customer) userObj).getCustomerID();
        }
        return null;
    }
}
