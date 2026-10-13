package com.swp391.controller.manager;

import com.swp391.model.Product;
import com.swp391.service.ProductService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/Manager/products")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class ProductManagement extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 10;

    private ProductService productService;

    @Override
    public void init() {
        productService = new ProductService();
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "products");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            showProductForm(request, response, "add", null);
            return;
        }

        if ("edit".equals(action)) {
            Integer id = parsePositiveInteger(request.getParameter("id"));
            if (id == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            Product product = productService.getProductById(id);
            if (product == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            String from = request.getParameter("from");
            request.setAttribute("from", from);
            showProductForm(request, response, "edit", product);
            return;
        }

        if ("detail".equals(action)) {
            Integer id = parsePositiveInteger(request.getParameter("id"));
            if (id == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            Product product = productService.getProductById(id);
            if (product == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            String from = request.getParameter("from");
            request.setAttribute("from", from);
            request.setAttribute("product", product);
            request.getRequestDispatcher(
                    "/views/Manager/product_detail.jsp"
            ).forward(request, response);
            return;
        }

        if ("delete".equals(action)) {
            Integer id = parsePositiveInteger(request.getParameter("id"));
            if (id == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            boolean success = productService.deleteProduct(id);
            if (!success) {
                request.getSession().setAttribute(
                        "error",
                        "Cannot delete product."
                );
            }

            response.sendRedirect(
                    request.getContextPath() + "/Manager/products"
            );
            return;
        }

        showProductList(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            handleAdd(request, response);
            return;
        }

        if ("edit".equals(action)) {
            handleEdit(request, response);
            return;
        }

        
        if ("delete".equals(action)) {

            System.out.println(
                    "DELETE ACTION RECEIVED, id = "
                    + request.getParameter("id")
            );

            Integer id
                    = parsePositiveInteger(
                            request.getParameter("id")
                    );

            System.out.println(
                    "Parsed delete id = " + id
            );

            boolean success
                    = productService.deleteProduct(id);

            System.out.println(
                    "Delete result = " + success
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/Manager/products"
            );

            return;
        }
    }

    private void showProductList(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String stock = request.getParameter("stock");
        String status = request.getParameter("status");
        String sort = request.getParameter("sort");

        Integer categoryId = parsePositiveInteger(
                request.getParameter("category")
        );

        int page = parseInteger(
                request.getParameter("page"),
                1
        );
        int pageSize = parseInteger(
                request.getParameter("pageSize"),
                DEFAULT_PAGE_SIZE
        );

        page = productService.normalizePage(page);
        pageSize = productService.normalizePageSize(pageSize);

        int totalItems = productService.countProducts(
                keyword,
                categoryId,
                stock,
                status
        );
        int totalPages = productService.getTotalPages(
                totalItems,
                pageSize
        );

        if (page > totalPages) {
            page = totalPages;
        }

        List<Product> products = productService.getProducts(
                keyword,
                categoryId,
                stock,
                status,
                sort,
                page,
                pageSize
        );

        request.setAttribute("categories", productService.getAllCategories());
        request.setAttribute("products", products);

        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("selectedStock", stock);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedSort", sort);

        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher(
                "/views/Manager/productManagement.jsp"
        ).forward(request, response);
    }

    private void handleAdd(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            ProductFormData data = readProductForm(request);
            String imageURL = resolveImageUrl(request, null);

            boolean success = productService.insertProduct(
                    data.name,
                    data.description,
                    data.categoryId,
                    data.brandId,
                    data.price,
                    data.stock,
                    imageURL,
                    data.connectionType,
                    data.driverSize,
                    data.noiseCancelling,
                    data.batteryLife,
                    data.microphone,
                    data.waterResistance,
                    data.status
            );

            if (success) {
                response.sendRedirect(
                        request.getContextPath() + "/Manager/products"
                );
                return;
            }

            throw new IllegalStateException("Cannot add product.");

        } catch (Exception e) {
            request.setAttribute("error", safeMessage(e, "Cannot add product."));
            request.setAttribute("mode", "add");
            loadFormData(request);
            request.getRequestDispatcher(
                    "/views/Manager/productForm.jsp"
            ).forward(request, response);
        }
    }

    private void handleEdit(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer id = parsePositiveInteger(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Product existingProduct = productService.getProductById(id);
        if (existingProduct == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        try {
            ProductFormData data = readProductForm(request);
            String imageURL = resolveImageUrl(request, existingProduct.getImageURL());

            boolean success = productService.updateProduct(
                    id,
                    data.name,
                    data.description,
                    data.categoryId,
                    data.brandId,
                    data.price,
                    data.stock,
                    imageURL,
                    data.connectionType,
                    data.driverSize,
                    data.noiseCancelling,
                    data.batteryLife,
                    data.microphone,
                    data.waterResistance,
                    data.status
            );

            if (success) {
                String from = request.getParameter("from");
                if ("inventory".equalsIgnoreCase(from)) {
                    response.sendRedirect(
                            request.getContextPath() + "/Manager/Inventory"
                    );
                } else {
                    response.sendRedirect(
                            request.getContextPath() + "/Manager/products"
                    );
                }
                return;
            }

            throw new IllegalStateException("Cannot update product.");

        } catch (Exception e) {
            request.setAttribute("error", safeMessage(e, "Cannot update product."));
            request.setAttribute("mode", "edit");
            request.setAttribute("from", request.getParameter("from"));
            request.setAttribute("product", productService.getProductById(id));
            loadFormData(request);
            request.getRequestDispatcher(
                    "/views/Manager/productForm.jsp"
            ).forward(request, response);
        }
    }

    private void showProductForm(HttpServletRequest request,
            HttpServletResponse response,
            String mode,
            Product product)
            throws ServletException, IOException {

        request.setAttribute("mode", mode);
        if (product != null) {
            request.setAttribute("product", product);
        }

        loadFormData(request);
        request.getRequestDispatcher(
                "/views/Manager/productForm.jsp"
        ).forward(request, response);
    }

    private void loadFormData(HttpServletRequest request) {
        request.setAttribute("categories", productService.getAllCategories());
        request.setAttribute("brands", productService.getAllBrands());
    }

    private ProductFormData readProductForm(HttpServletRequest request) {
        ProductFormData data = new ProductFormData();

        data.name = request.getParameter("name");
        data.description = request.getParameter("description");
        data.categoryId = Integer.parseInt(request.getParameter("categoryId"));
        data.brandId = Integer.parseInt(request.getParameter("brandId"));
        data.price = new BigDecimal(request.getParameter("price"));
        data.stock = Integer.parseInt(request.getParameter("stock"));
        data.connectionType = request.getParameter("connectionType");
        data.driverSize = parseNullableDouble(request.getParameter("driverSize"));
        data.noiseCancelling = request.getParameter("noiseCancelling") != null;
        data.batteryLife = parseNullableInteger(request.getParameter("batteryLife"));
        data.microphone = request.getParameter("microphone") != null;
        data.waterResistance = request.getParameter("waterResistance");
        data.status = request.getParameter("status");

        return data;
    }

    private String resolveImageUrl(HttpServletRequest request,
            String existingImageURL)
            throws IOException, ServletException {

        Part imagePart = request.getPart("image");
        if (imagePart == null || imagePart.getSize() == 0) {
            return existingImageURL;
        }

        String contentType = imagePart.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Selected file must be an image.");
        }

        String uploadDirectory = getServletContext().getRealPath(
                "/uploads/products"
        );

        if (uploadDirectory == null) {
            throw new IOException("Product upload directory is unavailable.");
        }

        try (var input = imagePart.getInputStream()) {
            return productService.saveProductImage(
                    input,
                    imagePart.getSubmittedFileName(),
                    uploadDirectory,
                    request.getContextPath() + "/uploads/products"
            );
        }
    }

    private Integer parsePositiveInteger(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            int result = Integer.parseInt(value);
            return result > 0 ? result : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parseInteger(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private Integer parseNullableInteger(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return Integer.valueOf(value);
    }

    private Double parseNullableDouble(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return Double.valueOf(value);
    }

    private String safeMessage(Exception e, String fallback) {
        if (e.getMessage() == null || e.getMessage().isBlank()) {
            return fallback;
        }
        return e.getMessage();
    }

    private static class ProductFormData {
        private String name;
        private String description;
        private int categoryId;
        private int brandId;
        private BigDecimal price;
        private int stock;
        private String connectionType;
        private Double driverSize;
        private boolean noiseCancelling;
        private Integer batteryLife;
        private boolean microphone;
        private String waterResistance;
        private String status;
    }
}
