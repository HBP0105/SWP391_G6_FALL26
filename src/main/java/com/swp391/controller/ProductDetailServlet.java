package com.swp391.controller;

import com.swp391.dao.ProductDAO;
import com.swp391.dao.ReviewDAO;
import com.swp391.dao.ReviewDAO.ReviewSummary;
import com.swp391.model.Customer;
import com.swp391.model.Product;
import com.swp391.model.Review;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "ProductDetailServlet", urlPatterns = {"/productDetail"})
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        Product product = null;

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int productId = Integer.parseInt(idParam.trim());
                ProductDAO productDAO = new ProductDAO();
                ReviewDAO reviewDAO = new ReviewDAO();

                product = productDAO.getProductById(productId);

                if (product != null) {
                    List<Review> reviews = reviewDAO.getReviewsByProductId(productId);
                    ReviewSummary reviewSummary = reviewDAO.getReviewSummary(productId);

                    request.setAttribute("reviews", reviews);
                    request.setAttribute("reviewSummary", reviewSummary);

                    // Check if current logged-in customer has already reviewed this product
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        Customer customer = (Customer) session.getAttribute("customer");
                        if (customer != null) {
                            Review userReview = reviewDAO.getReviewByUserAndProduct(customer.getCustomerID(), productId);
                            request.setAttribute("userReview", userReview);
                        }
                    }
                }
            } catch (NumberFormatException e) {
                // Invalid ID
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
        Customer customer = (Customer) session.getAttribute("customer");

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
            response.sendRedirect(request.getContextPath() + "/productDetail?id=" + productId + "&reviewError=failed#tab3");
        }
    }
}
