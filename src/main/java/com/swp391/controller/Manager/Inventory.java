package com.swp391.controller.Manager;

import com.swp391.model.Category;
import com.swp391.model.Product;
import com.swp391.model.Staff;
import com.swp391.service.Manager.InventoryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@WebServlet("/Manager/Inventory")
public class Inventory extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 10;

    private InventoryService inventoryService;

    @Override
    public void init() {
        inventoryService = new InventoryService();
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "inventory");

        String action = request.getParameter("action");
        if ("adjust".equals(action)) {
            Integer productId = parsePositiveInteger(request.getParameter("id"));
            if (productId == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID");
                return;
            }

            Product product = inventoryService.getProductById(productId);
            if (product == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
                return;
            }

            request.setAttribute("product", product);
            request.getRequestDispatcher("/views/Manager/inventoryAdjust.jsp").forward(request, response);
            return;
        }

        String keyword = request.getParameter("keyword");
        String stock = request.getParameter("stock");
        String sort = request.getParameter("sort");

        Integer categoryId = parsePositiveInteger(request.getParameter("category"));

        int page = parseInteger(request.getParameter("page"), 1);
        int pageSize = parseInteger(request.getParameter("pageSize"), DEFAULT_PAGE_SIZE);

        page = inventoryService.normalizePage(page);
        pageSize = inventoryService.normalizePageSize(pageSize);

        int totalItems = inventoryService.countInventoryProducts(
                keyword,
                categoryId,
                stock
        );

        int totalPages = inventoryService.getTotalPages(
                totalItems,
                pageSize
        );

        if (page > totalPages) {
            page = totalPages;
        }

        List<Map<String, Object>> inventoryProducts = inventoryService.getInventoryProducts(
                keyword,
                categoryId,
                stock,
                sort,
                page,
                pageSize
        );

        String txKeyword = request.getParameter("txKeyword");
        String txType = request.getParameter("txType");
        String txFromDate = request.getParameter("txFromDate");
        String txToDate = request.getParameter("txToDate");

        int txPage = parseInteger(request.getParameter("txPage"), 1);
        int txPageSize = parseInteger(request.getParameter("txPageSize"), 5);
        txPage = inventoryService.normalizePage(txPage);
        txPageSize = inventoryService.normalizePageSize(txPageSize);

        int totalTx = 0;
        int totalTxPages = 1;
        List<Map<String, Object>> recentTransactions = Collections.emptyList();

        try {
            inventoryService.validateTransactionDateRange(txFromDate, txToDate);

            totalTx = inventoryService.countRecentTransactions(
                    txKeyword, txType, txFromDate, txToDate
            );
            totalTxPages = inventoryService.getTotalTransactionPages(totalTx, txPageSize);

            if (txPage > totalTxPages) {
                txPage = totalTxPages;
            }

            recentTransactions = inventoryService.getRecentTransactions(
                    txKeyword, txType, txFromDate, txToDate, txPage, txPageSize
            );
        } catch (IllegalArgumentException e) {
            request.setAttribute("txFilterError", e.getMessage());
            txPage = 1;
        }

        List<Category> categories = inventoryService.getAllCategories();

        request.setAttribute("inventoryProducts", inventoryProducts);
        request.setAttribute("categories", categories);
        request.setAttribute("recentTransactions", recentTransactions);

        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("selectedStock", stock);
        request.setAttribute("selectedSort", sort);

        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("currentTxPage", txPage);
        request.setAttribute("txPageSize", txPageSize);
        request.setAttribute("totalTx", totalTx);
        request.setAttribute("totalTxPages", totalTxPages);
        request.setAttribute("txKeyword", txKeyword);
        request.setAttribute("selectedTxType", txType);
        request.setAttribute("txFromDate", txFromDate);
        request.setAttribute("txToDate", txToDate);
        request.setAttribute("today", LocalDate.now().toString());

        request.setAttribute("totalProducts", inventoryService.getTotalProducts());
        request.setAttribute("inStockProducts", inventoryService.getInStockProducts());
        request.setAttribute("lowStockProducts", inventoryService.getLowStockProducts());
        request.setAttribute("outOfStockProducts", inventoryService.getOutOfStockProducts());

        request.getRequestDispatcher("/views/Manager/inventory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("adjust".equals(action)) {
            handleAdjustStock(request, response);
            return;
        }

        doGet(request, response);
    }

    private void handleAdjustStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer productId = parsePositiveInteger(request.getParameter("productId"));
        if (productId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID");
            return;
        }

        String transactionType = request.getParameter("transactionType");
        String quantityStr = request.getParameter("quantity");
        String reason = request.getParameter("reason");

        try {
            if (quantityStr == null || quantityStr.isBlank()) {
                throw new IllegalArgumentException("Quantity is required.");
            }
            int quantity = Integer.parseInt(quantityStr.trim());

            Integer staffId = null;
            Object staffObj = request.getSession().getAttribute("staff");
            if (staffObj instanceof Staff staff) {
                staffId = staff.getStaffId();
            }

            boolean success = inventoryService.adjustStock(
                    productId,
                    transactionType,
                    quantity,
                    reason,
                    staffId
            );

            if (success) {
                request.getSession().setAttribute(
                        "successMessage",
                        "Stock adjusted successfully for product #" + productId
                );
                response.sendRedirect(request.getContextPath() + "/Manager/Inventory");
                return;
            } else {
                request.setAttribute("errorMessage", "Failed to adjust stock. Please try again.");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Quantity must be a valid integer number.");
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
        }

        Product product = inventoryService.getProductById(productId);
        request.setAttribute("activePage", "inventory");
        request.setAttribute("product", product);
        request.setAttribute("selectedType", transactionType);
        request.setAttribute("enteredQuantity", quantityStr);
        request.setAttribute("enteredReason", reason);
        request.getRequestDispatcher("/views/Manager/inventoryAdjust.jsp").forward(request, response);
    }

    private Integer parsePositiveInteger(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parseInteger(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
