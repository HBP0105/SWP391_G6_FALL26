package com.swp391.controller.manager;

import com.swp391.model.Category;
import com.swp391.service.InventoryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
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

        int txPage = parseInteger(request.getParameter("txPage"), 1);
        int txPageSize = 5;

        int totalTx = inventoryService.countRecentTransactions();
        int totalTxPages = inventoryService.getTotalTransactionPages(totalTx, txPageSize);

        txPage = inventoryService.normalizePage(txPage);
        if (txPage > totalTxPages) {
            txPage = totalTxPages;
        }

        List<Category> categories = inventoryService.getAllCategories();
        List<Map<String, Object>> recentTransactions = inventoryService.getRecentTransactions(txPage, txPageSize);

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

        request.setAttribute("totalProducts", inventoryService.getTotalProducts());
        request.setAttribute("inStockProducts", inventoryService.getInStockProducts());
        request.setAttribute("lowStockProducts", inventoryService.getLowStockProducts());
        request.setAttribute("outOfStockProducts", inventoryService.getOutOfStockProducts());

        request.getRequestDispatcher("/views/Manager/inventory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
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
