package com.swp391.controller;

import com.swp391.model.Customer;
import com.swp391.service.Admin.AIPerformanceService;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AIChatbotServlet", urlPatterns = {"/aiChatbot"})
public class AIChatbotServlet extends HttpServlet {

    private static final String SESSION_HISTORY_KEY = "aiChatHistory";
    private static final String SESSION_OPEN_KEY = "aiChatOpen";
    private static final Map<Integer, List<Map<String, Object>>> CUSTOMER_CHAT_STORE = new ConcurrentHashMap<>();
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    private AIPerformanceService aiPerformanceService;

    @Override
    public void init() {
        this.aiPerformanceService = new AIPerformanceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(true);
        Integer customerId = extractCustomerId(session);
        List<Map<String, Object>> history = getOrInitHistory(session, customerId);
        boolean isOpen = Boolean.TRUE.equals(session.getAttribute(SESSION_OPEN_KEY));

        try (PrintWriter out = response.getWriter()) {
            out.print("{\"success\":true,\"isOpen\":" + isOpen + ",\"history\":" + historyToJson(history) + "}");
            out.flush();
        }
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

        if ("clear".equalsIgnoreCase(action)) {
            List<Map<String, Object>> fresh = createDefaultWelcomeHistory();
            session.setAttribute(SESSION_HISTORY_KEY, fresh);
            if (customerId != null) {
                CUSTOMER_CHAT_STORE.put(customerId, fresh);
            }
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"success\":true,\"history\":" + historyToJson(fresh) + "}");
                out.flush();
            }
            return;
        }

        if ("toggle".equalsIgnoreCase(action)) {
            boolean open = "true".equalsIgnoreCase(request.getParameter("isOpen"));
            session.setAttribute(SESSION_OPEN_KEY, open);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"success\":true,\"isOpen\":" + open + "}");
                out.flush();
            }
            return;
        }

        String userMessage = request.getParameter("message");
        if (userMessage == null || userMessage.trim().isEmpty()) {
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"success\":false,\"message\":\"Please enter a question.\"}");
                out.flush();
            }
            return;
        }

        userMessage = userMessage.trim();
        if (userMessage.length() > 300) {
            userMessage = userMessage.substring(0, 300);
        }

        List<Map<String, Object>> history = getOrInitHistory(session, customerId);
        String nowStr = LocalTime.now().format(TIME_FMT);

        // 1. Save user message
        Map<String, Object> userEntry = new HashMap<>();
        userEntry.put("sender", "user");
        userEntry.put("text", userMessage);
        userEntry.put("timestamp", nowStr);
        userEntry.put("products", new ArrayList<Map<String, Object>>());
        history.add(userEntry);

        // 2. Ask AI Shopping Assistant
        Map<String, Object> aiResult = aiPerformanceService.askAIShoppingAssistant(userMessage, customerId, sessionId);
        String aiReply = (String) aiResult.getOrDefault("reply", "Here are the best matching products I found for you:");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> products = (List<Map<String, Object>>) aiResult.get("products");
        if (products == null) {
            products = new ArrayList<>();
        }

        // 3. Save AI response + recommended products into session history
        Map<String, Object> aiEntry = new HashMap<>();
        aiEntry.put("sender", "ai");
        aiEntry.put("text", aiReply);
        aiEntry.put("timestamp", LocalTime.now().format(TIME_FMT));
        aiEntry.put("products", products);
        history.add(aiEntry);

        // Keep max 30 messages to avoid bloating session memory
        while (history.size() > 30) {
            history.remove(0);
        }

        session.setAttribute(SESSION_HISTORY_KEY, history);
        session.setAttribute(SESSION_OPEN_KEY, true);
        if (customerId != null) {
            CUSTOMER_CHAT_STORE.put(customerId, new ArrayList<>(history));
        }

        try (PrintWriter out = response.getWriter()) {
            StringBuilder sb = new StringBuilder();
            sb.append("{\"success\":true,");
            sb.append("\"reply\":\"").append(escapeJson(aiReply)).append("\",");
            sb.append("\"timestamp\":\"").append(escapeJson((String) aiEntry.get("timestamp"))).append("\",");
            sb.append("\"products\":").append(productsToJson(products));
            sb.append("}");
            out.print(sb.toString());
            out.flush();
        }
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> getOrInitHistory(HttpSession session, Integer customerId) {
        List<Map<String, Object>> history = (List<Map<String, Object>>) session.getAttribute(SESSION_HISTORY_KEY);
        if (history == null) {
            if (customerId != null && CUSTOMER_CHAT_STORE.containsKey(customerId)) {
                history = new ArrayList<>(CUSTOMER_CHAT_STORE.get(customerId));
            } else {
                history = createDefaultWelcomeHistory();
            }
            session.setAttribute(SESSION_HISTORY_KEY, history);
        } else if (customerId != null && !CUSTOMER_CHAT_STORE.containsKey(customerId)) {
            CUSTOMER_CHAT_STORE.put(customerId, new ArrayList<>(history));
        }
        return history;
    }

    private List<Map<String, Object>> createDefaultWelcomeHistory() {
        List<Map<String, Object>> list = new ArrayList<>();
        Map<String, Object> welcome = new HashMap<>();
        welcome.put("sender", "ai");
        welcome.put("text", "Hi there! I'm your AI Shopping Assistant. Ask me anything to find the right headphones or earbuds (e.g., \"wireless earbuds with ANC under 3,000,000 VND\", \"Sony headphones for office\", or \"long battery life\").");
        welcome.put("timestamp", LocalTime.now().format(TIME_FMT));
        welcome.put("products", new ArrayList<Map<String, Object>>());
        list.add(welcome);
        return list;
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
    private String historyToJson(List<Map<String, Object>> history) {
        StringBuilder sb = new StringBuilder("[");
        if (history != null) {
            for (int i = 0; i < history.size(); i++) {
                if (i > 0) sb.append(",");
                Map<String, Object> msg = history.get(i);
                String sender = (String) msg.getOrDefault("sender", "ai");
                String text = (String) msg.getOrDefault("text", "");
                String ts = (String) msg.getOrDefault("timestamp", "");
                List<Map<String, Object>> prods = (List<Map<String, Object>>) msg.get("products");
                sb.append("{");
                sb.append("\"sender\":\"").append(escapeJson(sender)).append("\",");
                sb.append("\"text\":\"").append(escapeJson(text)).append("\",");
                sb.append("\"timestamp\":\"").append(escapeJson(ts)).append("\",");
                sb.append("\"products\":").append(productsToJson(prods));
                sb.append("}");
            }
        }
        sb.append("]");
        return sb.toString();
    }

    private String productsToJson(List<Map<String, Object>> products) {
        StringBuilder sb = new StringBuilder("[");
        if (products != null) {
            for (int i = 0; i < products.size(); i++) {
                if (i > 0) sb.append(",");
                Map<String, Object> p = products.get(i);
                int pid = p.get("productId") instanceof Number ? ((Number) p.get("productId")).intValue() : 0;
                long recId = p.get("recommendationId") instanceof Number ? ((Number) p.get("recommendationId")).longValue() : 0L;
                String name = (String) p.getOrDefault("productName", "");
                String img = (String) p.getOrDefault("imageUrl", "assets/img/product01.png");
                String cat = (String) p.getOrDefault("categoryName", "");
                String brand = (String) p.getOrDefault("brandName", "");
                Number price = p.get("price") instanceof Number ? (Number) p.get("price") : 0;
                int matchPct = p.get("matchPercentage") instanceof Number ? ((Number) p.get("matchPercentage")).intValue() : 85;

                sb.append("{");
                sb.append("\"productId\":").append(pid).append(",");
                sb.append("\"recommendationId\":").append(recId).append(",");
                sb.append("\"productName\":\"").append(escapeJson(name)).append("\",");
                sb.append("\"imageUrl\":\"").append(escapeJson(img)).append("\",");
                sb.append("\"categoryName\":\"").append(escapeJson(cat)).append("\",");
                sb.append("\"brandName\":\"").append(escapeJson(brand)).append("\",");
                sb.append("\"price\":").append(price).append(",");
                sb.append("\"matchPercentage\":").append(matchPct);
                sb.append("}");
            }
        }
        sb.append("]");
        return sb.toString();
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

