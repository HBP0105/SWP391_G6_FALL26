package com.swp391.controller;

import com.swp391.dao.ProductDAO;
import com.swp391.model.Product;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;



@WebServlet(name = "ProductListServlet", urlPatterns = {"/productList"})
public class ProductListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("q");

        if (keyword != null) {
            keyword = keyword.trim();
        } else {
            keyword = "";
        }

        ProductDAO productDAO = new ProductDAO();
        List<Product> products = productDAO.searchProducts(keyword);

        request.setAttribute("keyword", keyword);
        request.setAttribute("products", products);
        request.setAttribute("totalResults", products.size());

        request.getRequestDispatcher("/views/search.jsp").forward(request, response);
    }
}
