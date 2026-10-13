package com.swp391.controller;

import com.swp391.dao.BrandDAO;
import com.swp391.dao.CategoryDAO;
import com.swp391.dao.ProductDAO;
import com.swp391.model.Brand;
import com.swp391.model.Category;
import com.swp391.model.Product;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "ProductListServlet", urlPatterns = {"/productList"})
public class ProductListServlet extends HttpServlet {

    private static final int PAGE_SIZE = 9;
    private static final List<String> SORT_OPTIONS = Arrays.asList("newest", "price_asc", "price_desc", "rating_desc");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Keyword
        String keyword = request.getParameter("q");
        keyword = (keyword == null) ? "" : keyword.trim();

        // Filters
        List<Integer> selectedCategoryIds = parseIntList(request.getParameterValues("category"));
        List<Integer> selectedBrandIds = parseIntList(request.getParameterValues("brand"));
        Double minPrice = parseDouble(request.getParameter("minPrice"));
        Double maxPrice = parseDouble(request.getParameter("maxPrice"));
        if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
            Double tmp = minPrice;
            minPrice = maxPrice;
            maxPrice = tmp;
        }

        // Sort
        String sort = request.getParameter("sort");
        if (sort == null || !SORT_OPTIONS.contains(sort)) {
            sort = "newest";
        }

        // Page
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception ignored) {
        }

        ProductDAO productDAO = new ProductDAO();
        List<Category> categories = new CategoryDAO().getAllActiveCategories();
        List<Brand> brands = new BrandDAO().getAllActiveBrands();

        int totalResults = productDAO.countFilteredProducts(keyword, selectedCategoryIds, selectedBrandIds, minPrice, maxPrice);
        int totalPages = Math.max(1, (int) Math.ceil(totalResults / (double) PAGE_SIZE));
        page = Math.max(1, Math.min(page, totalPages));

        List<Product> products = productDAO.searchAndFilterProducts(
                keyword, selectedCategoryIds, selectedBrandIds, minPrice, maxPrice, sort, page, PAGE_SIZE);

        request.setAttribute("keyword", keyword);
        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        request.setAttribute("selectedCategoryIds", selectedCategoryIds);
        request.setAttribute("selectedBrandIds", selectedBrandIds);
        request.setAttribute("minPrice", minPrice == null ? "" : String.valueOf(minPrice.longValue()));
        request.setAttribute("maxPrice", maxPrice == null ? "" : String.valueOf(maxPrice.longValue()));
        request.setAttribute("sort", sort);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalResults", totalResults);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("fromIndex", totalResults == 0 ? 0 : (page - 1) * PAGE_SIZE + 1);
        request.setAttribute("toIndex", Math.min(page * PAGE_SIZE, totalResults));

        request.getRequestDispatcher("/views/search.jsp").forward(request, response);
    }

    private static List<Integer> parseIntList(String[] values) {
        List<Integer> result = new ArrayList<>();
        if (values != null) {
            for (String v : values) {
                try {
                    result.add(Integer.parseInt(v.trim()));
                } catch (NumberFormatException ignored) {
                }
            }
        }
        return result;
    }

    private static Double parseDouble(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            double d = Double.parseDouble(value.trim());
            return d < 0 ? null : d;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
