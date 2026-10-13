package com.swp391.controller;

import com.swp391.dao.ProductDAO;
import com.swp391.model.Product;
import java.io.IOException;
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

        // 1. (New Products carousel)
        List<Product> newProducts = productDAO.getNewProducts(10);
        List<Product> newHeadphones = productDAO.getNewProductsByCategory(1, 10);
        List<Product> newEarbuds = productDAO.getNewProductsByCategory(2, 10);

        // 2. (Top Selling carousel & widgets)
        List<Product> topSellingProducts = productDAO.getTopSellingProducts(10);
        List<Product> topHeadphones = productDAO.getTopSellingProductsByCategory(1, 6);
        List<Product> topEarbuds = productDAO.getTopSellingProductsByCategory(2, 6);

        request.setAttribute("newProducts", newProducts);
        request.setAttribute("newHeadphones", newHeadphones);
        request.setAttribute("newEarbuds", newEarbuds);

        request.setAttribute("topSellingProducts", topSellingProducts);
        request.setAttribute("topHeadphones", topHeadphones);
        request.setAttribute("topEarbuds", topEarbuds);

        request.getRequestDispatcher("/views/home.jsp").forward(request, response);
    }
}
