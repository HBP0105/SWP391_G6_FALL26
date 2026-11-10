package com.swp391.controller;

import com.swp391.dao.CategoryDAO;
import com.swp391.dao.ProductDAO;
import com.swp391.model.Category;
import com.swp391.model.Customer;
import com.swp391.model.Product;
import com.swp391.service.Admin.AIPerformanceService;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "HomeServerlet", urlPatterns = {"/home"})
public class HomeServerlet extends HttpServlet {

    private AIPerformanceService aiPerformanceService;

    @Override
    public void init() {
        this.aiPerformanceService = new AIPerformanceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ProductDAO productDAO = new ProductDAO();
        CategoryDAO categoryDAO = new CategoryDAO();

        // Load active categories from database
        List<Category> categories = categoryDAO.getAllActiveCategories();

        // 0. AI Personalized Recommendations (ONLY when user is logged in)
        HttpSession session = request.getSession(false);
        Integer customerId = extractCustomerId(session);

        List<Map<String, Object>> aiRecommendations = new ArrayList<>();
        Map<Integer, List<Map<String, Object>>> aiRecommendationsByCategory = new HashMap<>();
        if (customerId != null && aiPerformanceService != null) {
            try {
                String sessionId = session.getId();
                Collection<Integer> wishlistIds = extractWishlistIds(session);
                aiRecommendations = aiPerformanceService.getRecommendedProductsForHome(customerId, sessionId, wishlistIds);
                for (Category cat : categories) {
                    List<Map<String, Object>> catList = new ArrayList<>();
                    for (Map<String, Object> item : aiRecommendations) {
                        Object cidObj = item.get("categoryId");
                        if (cidObj instanceof Number && ((Number) cidObj).intValue() == cat.getCategoryId()) {
                            catList.add(item);
                        }
                    }
                    aiRecommendationsByCategory.put(cat.getCategoryId(), catList);
                }
            } catch (Exception ignored) {
                // Fail-safe so Home page always renders even if AI query fails
            }
        }

        // 1. (New Products)
        List<Product> newProducts = productDAO.getNewProducts(10);
        for (Category cat : categories) {
            cat.setNewProducts(productDAO.getNewProductsByCategory(cat.getCategoryId(), 10));
            cat.setTopSellingProducts(productDAO.getTopSellingProductsByCategory(cat.getCategoryId(), 10));
        }

        // 2. (Top Selling carousel & widgets)
        List<Product> topSellingProducts = productDAO.getTopSellingProducts(10);
        List<Product> topHeadphones = productDAO.getTopSellingProductsByCategory(1, 6);
        List<Product> topEarbuds = productDAO.getTopSellingProductsByCategory(2, 6);

        request.setAttribute("categories", categories);
        request.setAttribute("aiRecommendations", aiRecommendations);
        request.setAttribute("aiRecommendationsByCategory", aiRecommendationsByCategory);
        request.setAttribute("newProducts", newProducts);
        request.setAttribute("topSellingProducts", topSellingProducts);

        // Keep for bottom widgets
        request.setAttribute("topHeadphones", topHeadphones);
        request.setAttribute("topEarbuds", topEarbuds);

        request.getRequestDispatcher("/views/home.jsp").forward(request, response);
    }

    private Integer extractCustomerId(HttpSession session) {
        if (session == null) return null;
        Object userObj = session.getAttribute("customer");
        if (userObj == null) {
            userObj = session.getAttribute("user");
        }
        if (userObj instanceof Customer) {
            return ((Customer) userObj).getCustomerID();
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private Collection<Integer> extractWishlistIds(HttpSession session) {
        if (session == null) return null;
        Object obj = session.getAttribute("wishlistProductIds");
        if (obj instanceof Collection) {
            return (Collection<Integer>) obj;
        }
        return null;
    }
}
