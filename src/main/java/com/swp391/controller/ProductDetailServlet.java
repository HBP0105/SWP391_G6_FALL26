package com.swp391.controller;

import com.swp391.dao.ProductDAO;
import com.swp391.dao.ReviewDAO;
import com.swp391.dao.ReviewDAO.ReviewSummary;
import com.swp391.model.Customer;
import com.swp391.model.Product;
import com.swp391.model.Review;
import com.swp391.service.Admin.AIPerformanceService;
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

        Product product = null;
        if (productId > 0) {
            ProductDAO productDAO = new ProductDAO();
            ReviewDAO reviewDAO = new ReviewDAO();

            product = productDAO.getProductById(productId);

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

            if (product != null) {
                List<Review> reviews = reviewDAO.getReviewsByProductId(productId);
                ReviewSummary reviewSummary = reviewDAO.getReviewSummary(productId);

                request.setAttribute("reviews", reviews);
                request.setAttribute("reviewSummary", reviewSummary);

                // Check if current logged-in customer has already reviewed this product
                if (customerId != null) {
                    Review userReview = reviewDAO.getReviewByUserAndProduct(customerId, productId);
                    request.setAttribute("userReview", userReview);
                }

                // Tính toán danh sách AI 512-Vector Hybrid Recommendations
                if (aiPerformanceService != null) {
                    try {
                        List<Map<String, Object>> aiRecs = aiPerformanceService.getRecommendedProductsForDetail(productId, customerId, sessionId);
                        request.setAttribute("aiRecommendations", aiRecs);
                    } catch (Exception e) {
                        // Fail-safe: lỗi AI không làm sập trang xem chi tiết sản phẩm
                    }
                }
            }
        }

        request.setAttribute("product", product);
        request.getRequestDispatcher("/views/productDetail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Customer customer = (session != null) ? (Customer) session.getAttribute("customer") : null;

        String idParam = request.getParameter("productId");
        int productId = 0;
        try {
            productId = Integer.parseInt(idParam);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // 1. Requirement: user must be logged in to create/update review
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect="
                    + java.net.URLEncoder.encode(request.getContextPath() + "/productDetail?id=" + productId + "#tab3", "UTF-8"));
            return;
        }

        // 2. Validate rating & comment
        String ratingParam = request.getParameter("rating");
        String comment = request.getParameter("comment");

        int rating = 0;
        try {
            rating = Integer.parseInt(ratingParam);
        } catch (Exception ignored) {
        }

        if (rating < 1 || rating > 5 || comment == null || comment.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/productDetail?id=" + productId + "&reviewError=invalid#tab3");
            return;
        }

        // 3. Save to database
        ReviewDAO reviewDAO = new ReviewDAO();
        boolean success = reviewDAO.addOrUpdateReview(customer.getCustomerID(), productId, rating, comment.trim());

        if (success) {
            response.sendRedirect(request.getContextPath() + "/productDetail?id=" + productId + "&reviewSuccess=true#tab3");
        } else {
            response.sendRedirect(request.getContextPath() + "/productDetail?id=" + productId + "&reviewError=server#tab3");
        }
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
