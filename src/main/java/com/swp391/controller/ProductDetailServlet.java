package com.swp391.controller;

import com.swp391.dao.ProductDAO;
import com.swp391.model.Product;
import java.io.IOException;
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
                product = productDAO.getProductById(productId);
            } catch (NumberFormatException e) {
                // ID không hợp lệ, product vẫn là null
            }
        }

        request.setAttribute("product", product);
        request.getRequestDispatcher("/views/productDetail.jsp").forward(request, response);
    }
}
