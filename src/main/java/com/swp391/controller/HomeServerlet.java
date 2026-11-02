package com.swp391.controller;

import com.swp391.dao.AIRecommendationDAO;
import com.swp391.dao.CategoryDAO;
import com.swp391.dao.ProductDAO;
import com.swp391.model.AIRecommendationItem;
import com.swp391.model.Category;
import com.swp391.model.Customer;
import com.swp391.model.Product;
import com.swp391.util.GeminiService;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "HomeServerlet", urlPatterns = {"/home"})
public class HomeServerlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ProductDAO productDAO = new ProductDAO();
        CategoryDAO categoryDAO = new CategoryDAO();
        AIRecommendationDAO aiDAO = new AIRecommendationDAO();

        // Load active categories from database
        List<Category> categories = categoryDAO.getAllActiveCategories();

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

        // 3. (AI Recommendation Section: 8 products tailored to user)
        HttpSession session = request.getSession(false);
        Customer customer = (session != null) ? (Customer) session.getAttribute("customer") : null;
        List<Product> catalog = productDAO.getAllProducts();

        List<Product> purchased = (customer != null) ? aiDAO.getPurchasedProducts(customer.getCustomerID()) : Collections.emptyList();
        List<Product> wishlist = (customer != null) ? aiDAO.getWishlistProducts(customer.getCustomerID()) : Collections.emptyList();

        int custId = (customer != null) ? customer.getCustomerID() : 0;
        List<AIRecommendationItem> rawAiItems = GeminiService.recommendForUser(custId, purchased, wishlist, catalog, 8);
        List<AIRecommendationItem> aiRecommendations = aiDAO.populateProducts(rawAiItems);

        // Optional log to DB for analytics/grading
        if (customer != null && !aiRecommendations.isEmpty()) {
            aiDAO.saveRecommendationsToDb(customer.getCustomerID(), "PERSONALIZED", aiRecommendations);
        }

        request.setAttribute("categories", categories);
        request.setAttribute("newProducts", newProducts);
        request.setAttribute("topSellingProducts", topSellingProducts);
        request.setAttribute("aiRecommendations", aiRecommendations);

        // Keep for bottom widgets
        request.setAttribute("topHeadphones", topHeadphones);
        request.setAttribute("topEarbuds", topEarbuds);

        request.getRequestDispatcher("/views/home.jsp").forward(request, response);
    }
}
