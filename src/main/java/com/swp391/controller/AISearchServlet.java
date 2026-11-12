package com.swp391.controller;

import com.swp391.model.Customer;
import com.swp391.service.Admin.AIPerformanceService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Dedicated Controller for AI Audio Product Search & Visual Image Search.
 * URL: /ai-search or /aiSearch
 */
@WebServlet(name = "AISearchServlet", urlPatterns = {"/ai-search", "/aiSearch"})
public class AISearchServlet extends HttpServlet {

    private AIPerformanceService aiPerformanceService;

    @Override
    public void init() {
        this.aiPerformanceService = new AIPerformanceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activeNav", "ai-search");

        String queryParam = request.getParameter("q");
        if (queryParam != null && !queryParam.trim().isEmpty()) {
            queryParam = queryParam.trim();
            HttpSession session = request.getSession(true);
            Integer customerId = extractCustomerId(session);
            String sessionId = session.getId();

            Map<String, Object> aiResult = aiPerformanceService.askAIShoppingAssistant(queryParam, customerId, sessionId);
            request.setAttribute("initialQuery", queryParam);
            request.setAttribute("initialAnalysis", "Semantic search analysis for: \"" + queryParam + "\"");
            request.setAttribute("initialReply", aiResult.get("reply"));
            request.setAttribute("initialProducts", aiResult.get("products"));
        }

        request.getRequestDispatcher("/views/aiSearch.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(true);
        String sessionId = session.getId();
        Integer customerId = extractCustomerId(session);

        String action = request.getParameter("action");
        String query = request.getParameter("query");
        String imageData = request.getParameter("imageData");
        String mimeType = request.getParameter("mimeType");
        String userNote = request.getParameter("userNote");

        List<String> imageList = new ArrayList<>();
        List<String> mimeTypeList = new ArrayList<>();

        String[] imagesArr = request.getParameterValues("images[]");
        if (imagesArr == null) imagesArr = request.getParameterValues("images");
        if (imagesArr != null) {
            for (String img : imagesArr) {
                if (img != null && !img.trim().isEmpty()) {
                    imageList.add(img.trim());
                }
            }
        } else if (imageData != null && !imageData.trim().isEmpty()) {
            imageList.add(imageData.trim());
        }

        String[] mimesArr = request.getParameterValues("mimeTypes[]");
        if (mimesArr == null) mimesArr = request.getParameterValues("mimeTypes");
        if (mimesArr != null) {
            for (String m : mimesArr) {
                if (m != null && !m.trim().isEmpty()) {
                    mimeTypeList.add(m.trim());
                }
            }
        } else if (mimeType != null && !mimeType.trim().isEmpty()) {
            mimeTypeList.add(mimeType.trim());
        }

        // Fallback reading request body if sent as raw JSON
        if (action == null && request.getContentType() != null && request.getContentType().contains("application/json")) {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            String body = sb.toString();
            action = extractJsonField(body, "action");
            query = extractJsonField(body, "query");
            userNote = extractJsonField(body, "userNote");

            List<String> jsonImages = extractJsonArray(body, "images");
            if (jsonImages != null && !jsonImages.isEmpty()) {
                imageList.addAll(jsonImages);
            } else {
                String jsonImg = extractJsonField(body, "imageData");
                if (jsonImg != null && !jsonImg.trim().isEmpty()) {
                    imageList.add(jsonImg.trim());
                }
            }

            List<String> jsonMimes = extractJsonArray(body, "mimeTypes");
            if (jsonMimes != null && !jsonMimes.isEmpty()) {
                mimeTypeList.addAll(jsonMimes);
            } else {
                String jsonMime = extractJsonField(body, "mimeType");
                if (jsonMime != null && !jsonMime.trim().isEmpty()) {
                    mimeTypeList.add(jsonMime.trim());
                }
            }
        }

        PrintWriter out = response.getWriter();

        if ("search_image".equalsIgnoreCase(action) || !imageList.isEmpty()) {
            // Visual Image Search (Supports up to 4 images)
            if (imageList.isEmpty()) {
                out.print("{\"success\":false,\"message\":\"Please provide at least one headphone image (Base64).\"}");
                out.flush();
                return;
            }
            String contextRealPath = request.getServletContext().getRealPath("/");
            Map<String, Object> res = aiPerformanceService.searchProductsByImages(
                    userNote, mimeTypeList, imageList, customerId, sessionId, contextRealPath);
            renderJsonResponse(out, "IMAGE", res);
            return;
        }

        // Default or "search_text"
        if (query == null || query.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Please enter a question or description for the headphones you want.\"}");
            out.flush();
            return;
        }

        Map<String, Object> res = aiPerformanceService.askAIShoppingAssistant(query.trim(), customerId, sessionId);
        renderJsonResponse(out, "TEXT", res);
    }

    private void renderJsonResponse(PrintWriter out, String mode, Map<String, Object> res) {
        String analysis = (String) res.getOrDefault("analysis", "Feature analysis completed.");
        String reply = (String) res.getOrDefault("reply", "Here are the matching products:");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> products = (List<Map<String, Object>>) res.get("products");
        if (products == null) {
            products = new ArrayList<>();
        }

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":true,");
        sb.append("\"mode\":\"").append(mode).append("\",");
        sb.append("\"analysis\":\"").append(escapeJson(analysis)).append("\",");
        sb.append("\"reply\":\"").append(escapeJson(reply)).append("\",");
        sb.append("\"products\":[");

        for (int i = 0; i < products.size(); i++) {
            if (i > 0) sb.append(",");
            Map<String, Object> p = products.get(i);
            sb.append("{");
            sb.append("\"productId\":").append(p.get("productId")).append(",");
            sb.append("\"productName\":\"").append(escapeJson(String.valueOf(p.getOrDefault("productName", "")))).append("\",");
            sb.append("\"price\":").append(p.getOrDefault("price", 0)).append(",");
            sb.append("\"imageUrl\":\"").append(escapeJson(String.valueOf(p.getOrDefault("imageUrl", "")))).append("\",");
            sb.append("\"brandName\":\"").append(escapeJson(String.valueOf(p.getOrDefault("brandName", "")))).append("\",");
            sb.append("\"categoryName\":\"").append(escapeJson(String.valueOf(p.getOrDefault("categoryName", "")))).append("\",");
            sb.append("\"matchPercentage\":").append(p.getOrDefault("matchPercentage", 85)).append(",");
            sb.append("\"visualTag\":\"").append(escapeJson(String.valueOf(p.getOrDefault("visualTag", "Recommended")))).append("\"");
            sb.append("}");
        }

        sb.append("]}");
        out.print(sb.toString());
        out.flush();
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

    private String extractJsonField(String json, String field) {
        if (json == null) return null;
        java.util.regex.Matcher m = java.util.regex.Pattern.compile("\"" + field + "\"\\s*:\\s*\"([^\"]*)\"").matcher(json);
        if (m.find()) {
            return m.group(1);
        }
        return null;
    }

    private List<String> extractJsonArray(String json, String arrayName) {
        if (json == null) return null;
        java.util.regex.Matcher m = java.util.regex.Pattern.compile("\"" + arrayName + "\"\\s*:\\s*\\[([^\\]]*)\\]").matcher(json);
        if (m.find()) {
            String content = m.group(1);
            List<String> list = new ArrayList<>();
            java.util.regex.Matcher itemM = java.util.regex.Pattern.compile("\"([^\"]*)\"").matcher(content);
            while (itemM.find()) {
                list.add(itemM.group(1));
            }
            return list;
        }
        return null;
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

