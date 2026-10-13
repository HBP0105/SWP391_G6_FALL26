package com.swp391.controller;

import com.swp391.dao.BrandDAO;
import com.swp391.dao.CategoryDAO;
import com.swp391.dao.ProductDAO;
import com.swp391.model.Brand;
import com.swp391.model.Category;
import com.swp391.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "CompareServlet", urlPatterns = {"/compare"})
public class CompareServlet extends HttpServlet {

    private ProductDAO productDAO;
    private CategoryDAO categoryDAO;
    private BrandDAO brandDAO;

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
        categoryDAO = new CategoryDAO();
        brandDAO = new BrandDAO();
        System.out.println("[CompareServlet] Initialized successfully.");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        // AJAX API: Tìm kiếm sản phẩm trả về JSON
        if ("search_ajax".equalsIgnoreCase(action)) {
            handleSearchAjax(request, response);
            return;
        }

        // AJAX API: Lấy chi tiết 1 sản phẩm trả về JSON
        if ("get_product_ajax".equalsIgnoreCase(action)) {
            handleGetProductAjax(request, response);
            return;
        }

        // 1. Lấy ID của Product A và Product B từ request
        String idAParam = request.getParameter("idA");
        String idBParam = request.getParameter("idB");
        String swapParam = request.getParameter("swap");

        int idA = parseInteger(idAParam, 0);
        int idB = parseInteger(idBParam, 0);

        if ("true".equalsIgnoreCase(swapParam) || "1".equals(swapParam)) {
            int temp = idA;
            idA = idB;
            idB = temp;
        }

        Product productA = null;
        Product productB = null;

        if (idA > 0) {
            productA = productDAO.getProductById(idA);
        }
        if (idB > 0) {
            productB = productDAO.getProductById(idB);
        }

        // Nếu cả A và B đều chưa được truyền tham số, chọn mặc định 2 sản phẩm bán chạy nhất
        if (productA == null && productB == null && idAParam == null && idBParam == null) {
            List<Product> topSelling = productDAO.getTopSellingProducts(2);
            if (topSelling != null && topSelling.size() >= 2) {
                productA = topSelling.get(0);
                productB = topSelling.get(1);
            } else if (topSelling != null && !topSelling.isEmpty()) {
                productA = topSelling.get(0);
            }
        }

        // 2. Load danh mục và thương hiệu cho bộ lọc tìm kiếm
        List<Category> categories = categoryDAO.getAllActiveCategories();
        List<Brand> brands = brandDAO.getAllActiveBrands();

        // 3. Xử lý bộ lọc tìm kiếm cho danh sách sản phẩm bên dưới
        String keyword = request.getParameter("keyword");
        if (keyword != null) keyword = keyword.trim();

        int selectedCatId = parseInteger(request.getParameter("category"), 0);
        int selectedBrandId = parseInteger(request.getParameter("brand"), 0);

        List<Integer> catList = selectedCatId > 0 ? Collections.singletonList(selectedCatId) : Collections.emptyList();
        List<Integer> brandList = selectedBrandId > 0 ? Collections.singletonList(selectedBrandId) : Collections.emptyList();

        int page = parseInteger(request.getParameter("page"), 1);
        int pageSize = 4;

        List<Product> searchResults = productDAO.searchAndFilterProducts(keyword, catList, brandList, null, null, "newest", page, pageSize);
        int totalCount = productDAO.countFilteredProducts(keyword, catList, brandList, null, null);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        int fromIndex = totalCount > 0 ? (page - 1) * pageSize + 1 : 0;
        int toIndex = Math.min(page * pageSize, totalCount);

        request.setAttribute("productA", productA);
        request.setAttribute("productB", productB);
        request.setAttribute("productAJson", productToJson(productA));
        request.setAttribute("productBJson", productToJson(productB));
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        request.setAttribute("searchResults", searchResults);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("fromIndex", fromIndex);
        request.setAttribute("toIndex", toIndex);
        request.setAttribute("selectedCatId", selectedCatId);
        request.setAttribute("selectedBrandId", selectedBrandId);
        request.setAttribute("searchKeyword", keyword != null ? keyword : "");

        request.getRequestDispatcher("/views/compare.jsp").forward(request, response);
    }

    private void handleSearchAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        String keyword = request.getParameter("keyword");
        int selectedCatId = parseInteger(request.getParameter("category"), 0);
        int selectedBrandId = parseInteger(request.getParameter("brand"), 0);
        int page = parseInteger(request.getParameter("page"), 1);
        int pageSize = 4;

        List<Integer> catList = selectedCatId > 0 ? Collections.singletonList(selectedCatId) : Collections.emptyList();
        List<Integer> brandList = selectedBrandId > 0 ? Collections.singletonList(selectedBrandId) : Collections.emptyList();

        int totalCount = productDAO.countFilteredProducts(keyword, catList, brandList, null, null);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        int fromIndex = totalCount > 0 ? (page - 1) * pageSize + 1 : 0;
        int toIndex = Math.min(page * pageSize, totalCount);

        List<Product> list = productDAO.searchAndFilterProducts(keyword, catList, brandList, null, null, "newest", page, pageSize);

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"totalCount\":").append(totalCount).append(",");
        json.append("\"totalPages\":").append(totalPages).append(",");
        json.append("\"currentPage\":").append(page).append(",");
        json.append("\"pageSize\":").append(pageSize).append(",");
        json.append("\"fromIndex\":").append(fromIndex).append(",");
        json.append("\"toIndex\":").append(toIndex).append(",");
        json.append("\"products\":[");

        for (int i = 0; i < list.size(); i++) {
            Product p = list.get(i);
            if (i > 0) json.append(",");
            json.append(productToJson(p));
        }

        json.append("]}");

        try (PrintWriter out = response.getWriter()) {
            out.print(json.toString());
            out.flush();
        }
    }

    private void handleGetProductAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        int productId = parseInteger(request.getParameter("productId"), 0);
        if (productId <= 0) {
            productId = parseInteger(request.getParameter("id"), 0);
        }
        Product p = null;
        if (productId > 0) {
            p = productDAO.getProductById(productId);
        }

        try (PrintWriter out = response.getWriter()) {
            if (p != null) {
                out.print("{\"success\":true,\"product\":" + productToJson(p) + "}");
            } else {
                out.print("{\"success\":false,\"message\":\"Không tìm thấy sản phẩm.\"}");
            }
            out.flush();
        }
    }

    private String productToJson(Product p) {
        if (p == null) return "null";
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"productId\":").append(p.getProductId()).append(",");
        sb.append("\"productName\":\"").append(escapeJson(p.getProductName())).append("\",");
        sb.append("\"description\":\"").append(escapeJson(p.getDescription())).append("\",");
        sb.append("\"price\":").append(p.getPrice() != null ? p.getPrice() : 0).append(",");
        sb.append("\"stockQuantity\":").append(p.getStockQuantity()).append(",");
        sb.append("\"categoryName\":\"").append(escapeJson(p.getCategoryName())).append("\",");
        sb.append("\"brandName\":\"").append(escapeJson(p.getBrandName())).append("\",");
        sb.append("\"imageUrl\":\"").append(escapeJson(p.getImageUrl())).append("\",");
        sb.append("\"connectionType\":\"").append(escapeJson(p.getConnectionType())).append("\",");
        sb.append("\"noiseCancelling\":").append(p.isNoiseCancelling()).append(",");
        sb.append("\"batteryLife\":").append(p.getBatteryLife() != null ? p.getBatteryLife() : 0).append(",");
        sb.append("\"microphone\":").append(p.isMicrophone()).append(",");
        sb.append("\"waterResistance\":\"").append(escapeJson(p.getWaterResistance())).append("\",");
        sb.append("\"driverSize\":").append(p.getDriverSize() != null ? p.getDriverSize() : 0).append(",");
        sb.append("\"weight\":").append(p.getWeight() != null ? p.getWeight() : 0).append(",");
        sb.append("\"status\":\"").append(escapeJson(p.getStatus())).append("\",");
        sb.append("\"rating\":").append(p.getRating()).append(",");
        sb.append("\"reviewCount\":").append(p.getReviewCount());
        sb.append("}");
        return sb.toString();
    }

    private int parseInteger(String str, int defaultValue) {
        if (str == null || str.trim().isEmpty()) return defaultValue;
        try {
            return Integer.parseInt(str.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
