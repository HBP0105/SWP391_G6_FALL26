package com.swp391.controller;

import com.swp391.dao.ProductDAO;
import com.swp391.model.Product;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

/**
 * Servlet xử lý gợi ý tìm kiếm sản phẩm (autocomplete).
 * Trả về JSON tối đa 5 sản phẩm khớp với từ khóa nhập vào.
 * URL: /search/suggest?q=keyword
 */
@WebServlet(name = "SearchSuggestServlet", urlPatterns = {"/searchSuggest"})
public class SearchSuggestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        // Cho phép CORS nếu cần (cùng origin thì không cần, nhưng để phòng ngừa)
        response.setHeader("Cache-Control", "no-cache");

        String keyword = request.getParameter("q");

        PrintWriter out = response.getWriter();

        // Kiểm tra keyword hợp lệ (ít nhất 3 ký tự)
        if (keyword == null || keyword.trim().length() < 3) {
            out.print("[]");
            out.flush();
            return;
        }

        keyword = keyword.trim();
        ProductDAO productDAO = new ProductDAO();
        List<Product> suggestions = productDAO.searchProductsByName(keyword, 5);

        // Tự build JSON để không cần thư viện ngoài
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < suggestions.size(); i++) {
            Product p = suggestions.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"productID\":").append(p.getProductID()).append(",");
            json.append("\"productName\":\"").append(escapeJson(p.getProductName())).append("\",");
            json.append("\"categoryName\":\"").append(escapeJson(p.getCategoryName() != null ? p.getCategoryName() : "")).append("\",");
            json.append("\"price\":").append(p.getPrice() != null ? p.getPrice().toPlainString() : "0").append(",");
            json.append("\"imageUrl\":\"").append(escapeJson(p.getImageUrl())).append("\"");
            json.append("}");
        }
        json.append("]");

        out.print(json.toString());
        out.flush();
    }

    /**
     * Escape các ký tự đặc biệt trong JSON string.
     */
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
