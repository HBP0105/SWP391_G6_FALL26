/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package com.swp391.controller;

import com.swp391.dao.ProductDAO;
import com.swp391.dao.ReviewDAO;
import com.swp391.model.Customer;
import com.swp391.model.Product;
import com.swp391.model.Review;
import com.swp391.model.ReviewImage;
import com.swp391.util.CloudinaryService;
import java.io.IOException;
import java.util.Collection;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

/**
 *
 * @author Admin
 */
@WebServlet(name = "ProductReviewsController", urlPatterns = {"/ProductReviews", "/productReviews"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1 MB
        maxFileSize = 1024 * 1024 * 10,       // 10 MB
        maxRequestSize = 1024 * 1024 * 50     // 50 MB
)
public class ProductReviewsController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProductReviewsController.class.getName());

    public static class ParsedReviewComment {
        public String comfort = "";
        public String mic = "";
        public String sound = "";
        public String generalComment = "";
    }

    public static ParsedReviewComment parseComment(String rawComment) {
        ParsedReviewComment result = new ParsedReviewComment();
        if (rawComment == null || rawComment.trim().isEmpty()) {
            return result;
        }

        String[] lines = rawComment.split("\\r?\\n");
        StringBuilder general = new StringBuilder();

        for (String line : lines) {
            String trimmed = line.trim();
            if (trimmed.startsWith("Wearing Comfort:")) {
                result.comfort = trimmed.substring("Wearing Comfort:".length()).trim();
            } else if (trimmed.startsWith("Microphone Quality:")) {
                result.mic = trimmed.substring("Microphone Quality:".length()).trim();
            } else if (trimmed.startsWith("Sound Quality:")) {
                result.sound = trimmed.substring("Sound Quality:".length()).trim();
            } else {
                if (general.length() > 0) {
                    general.append("\n");
                }
                general.append(line);
            }
        }
        result.generalComment = general.toString().trim();
        return result;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            idParam = request.getParameter("productId");
        }

        Product product = null;
        ProductDAO productDAO = new ProductDAO();

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int productId = Integer.parseInt(idParam.trim());
                product = productDAO.getProductById(productId);
            } catch (NumberFormatException ignored) {
            }
        }

        if (product == null) {
            product = productDAO.getProductById(1);
            if (product == null) {
                List<Product> allProds = productDAO.getAllProducts();
                if (allProds != null && !allProds.isEmpty()) {
                    product = allProds.get(0);
                }
            }
        }

        if (product != null) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                Customer customer = (Customer) session.getAttribute("customer");
                if (customer != null) {
                    ReviewDAO reviewDAO = new ReviewDAO();
                    Review userReview = reviewDAO.getReviewByUserAndProduct(customer.getCustomerID(), product.getProductId());
                    request.setAttribute("userReview", userReview);

                    if (userReview != null && userReview.getComment() != null) {
                        ParsedReviewComment parsed = parseComment(userReview.getComment());
                        request.setAttribute("promptComfort", parsed.comfort);
                        request.setAttribute("promptMic", parsed.mic);
                        request.setAttribute("promptSound", parsed.sound);
                        request.setAttribute("promptGeneralComment", parsed.generalComment);
                    }
                }
            }
            request.setAttribute("product", product);
        }

        request.getRequestDispatcher("/views/productReviews.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String idParam = request.getParameter("productId");
        int productId = 0;
        try {
            if (idParam != null && !idParam.trim().isEmpty()) {
                productId = Integer.parseInt(idParam.trim());
            }
        } catch (NumberFormatException ignored) {
        }

        int rating = 5;
        try {
            String ratingParam = request.getParameter("rating");
            if (ratingParam != null) {
                rating = Integer.parseInt(ratingParam.trim());
            }
        } catch (NumberFormatException ignored) {
        }

        String promptComfort = request.getParameter("promptComfort");
        String promptMic = request.getParameter("promptMic");
        if (promptMic == null || promptMic.trim().isEmpty()) {
            promptMic = request.getParameter("promptMaterial");
        }
        String promptSound = request.getParameter("promptSound");
        if (promptSound == null || promptSound.trim().isEmpty()) {
            promptSound = request.getParameter("promptColor");
        }
        String comment = request.getParameter("comment");

        StringBuilder fullComment = new StringBuilder();
        if (promptComfort != null && !promptComfort.trim().isEmpty()) {
            fullComment.append("Wearing Comfort: ").append(promptComfort.trim()).append("\n");
        }
        if (promptMic != null && !promptMic.trim().isEmpty()) {
            fullComment.append("Microphone Quality: ").append(promptMic.trim()).append("\n");
        }
        if (promptSound != null && !promptSound.trim().isEmpty()) {
            fullComment.append("Sound Quality: ").append(promptSound.trim()).append("\n");
        }
        if (comment != null && !comment.trim().isEmpty()) {
            fullComment.append(comment.trim());
        }

        HttpSession session = request.getSession(false);
        Customer customer = (session != null) ? (Customer) session.getAttribute("customer") : null;

        if (customer != null && productId > 0 && fullComment.length() > 0) {
            ReviewDAO reviewDAO = new ReviewDAO();
            int reviewId = reviewDAO.saveOrUpdateReviewAndGetId(customer.getCustomerID(), productId, rating, fullComment.toString().trim());

            if (reviewId > 0) {
                // 1. Handle deleted images (user removed existing images during edit)
                String[] deletedImageIds = request.getParameterValues("deletedImageIds");
                if (deletedImageIds != null) {
                    for (String delIdStr : deletedImageIds) {
                        try {
                            int delId = Integer.parseInt(delIdStr.trim());
                            ReviewImage imgToDelete = reviewDAO.getReviewImageById(delId);
                            if (imgToDelete != null && imgToDelete.getReviewId() == reviewId) {
                                boolean dbDeleted = reviewDAO.deleteReviewImage(delId, reviewId);
                                if (dbDeleted && imgToDelete.getPublicId() != null) {
                                    CloudinaryService.destroy(imgToDelete.getPublicId());
                                }
                            }
                        } catch (Exception ex) {
                            LOGGER.log(Level.WARNING, "Error deleting review image: " + delIdStr, ex);
                        }
                    }
                }

                // 2. Handle newly uploaded images
                try {
                    Collection<Part> parts = request.getParts();
                    if (parts != null) {
                        boolean isPrimary = (reviewDAO.getImagesByReviewId(reviewId).isEmpty());
                        for (Part part : parts) {
                            if ("reviewPhotos".equals(part.getName()) && part.getSize() > 0) {
                                String fileName = part.getSubmittedFileName();
                                if (fileName != null && !fileName.trim().isEmpty()) {
                                    byte[] fileBytes = part.getInputStream().readAllBytes();
                                    if (fileBytes.length > 0) {
                                        CloudinaryService.UploadResult result = CloudinaryService.upload(fileBytes, fileName);
                                        if (result != null && result.getSecureUrl() != null) {
                                            reviewDAO.addReviewImage(reviewId, result.getSecureUrl(), result.getPublicId(), isPrimary);
                                            isPrimary = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception ex) {
                    LOGGER.log(Level.SEVERE, "Failed to upload or save review images", ex);
                }
            }

            response.sendRedirect(request.getContextPath() + "/productDetail?id=" + productId + "&reviewSuccess=true#tab3");
            return;
        }

        request.setAttribute("successMessage", "Thank you! Your product review has been submitted.");
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Product Reviews Controller";
    }
}
