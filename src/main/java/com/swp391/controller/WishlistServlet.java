package com.swp391.controller;

import com.swp391.dao.FavoriteDAO;
import com.swp391.dao.ProductDAO;
import com.swp391.model.Customer;
import com.swp391.model.Product;
import com.swp391.model.WishlistItemDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@WebServlet(name = "WishlistServlet", urlPatterns = {"/wishlist"})
public class WishlistServlet extends HttpServlet {

    private FavoriteDAO favoriteDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        favoriteDAO = new FavoriteDAO();
        productDAO = new ProductDAO();
        System.out.println("[WishlistServlet] Initialized successfully with session-first persistence.");
    }

    @SuppressWarnings("unchecked")
    private synchronized List<WishlistItemDTO> getOrCreateSessionWishlistItems(HttpSession session, Customer customer) {
        List<WishlistItemDTO> wishlistItems = (List<WishlistItemDTO>) session.getAttribute("wishlistItems");
        if (wishlistItems == null) {
            if (customer != null) {
                wishlistItems = favoriteDAO.getFavoritesByCustomerId(customer.getCustomerID());
            }
            if (wishlistItems == null) {
                wishlistItems = new ArrayList<>();
            }
            session.setAttribute("wishlistItems", wishlistItems);

            Set<Integer> pIds = new LinkedHashSet<>();
            for (WishlistItemDTO itm : wishlistItems) {
                if (itm != null) {
                    pIds.add(itm.getProductId());
                }
            }
            session.setAttribute("wishlistProductIds", pIds);
            session.setAttribute("wishlistCount", wishlistItems.size());
            session.setAttribute("wishlistModified", false);
            System.out.println("[WishlistServlet] Đã khởi tạo wishlist trong session cho Customer " 
                    + (customer != null ? customer.getCustomerID() : "Guest") + " với " + wishlistItems.size() + " items.");
        }
        return wishlistItems;
    }

    @SuppressWarnings("unchecked")
    private synchronized Set<Integer> getOrCreateSessionWishlistProductIds(HttpSession session, Customer customer) {
        Set<Integer> wishlistProductIds = (Set<Integer>) session.getAttribute("wishlistProductIds");
        if (wishlistProductIds == null) {
            getOrCreateSessionWishlistItems(session, customer);
            wishlistProductIds = (Set<Integer>) session.getAttribute("wishlistProductIds");
        }
        return wishlistProductIds;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");

        System.out.println("\n------------------------------------------------------------");
        System.out.println("[WishlistServlet GET] Nhận request vào /wishlist");
        System.out.println("[WishlistServlet GET] Customer: " + (customer != null ? (customer.getFullName() + " (ID: " + customer.getCustomerID() + ")") : "NULL (Chưa đăng nhập)"));

        // Yêu cầu đăng nhập: nếu chưa đăng nhập thì chuyển sang trang login
        if (customer == null) {
            System.out.println("[WishlistServlet GET] -> Chưa đăng nhập, chuyển hướng sang " + request.getContextPath() + "/authen/login.jsp");
            System.out.println("------------------------------------------------------------\n");
            response.sendRedirect(request.getContextPath() + "/authen/login.jsp");
            return;
        }

        List<WishlistItemDTO> wishlistItems = getOrCreateSessionWishlistItems(session, customer);
        int count = wishlistItems != null ? wishlistItems.size() : 0;
        session.setAttribute("wishlistCount", count);
        request.setAttribute("wishlistItems", wishlistItems);
        request.setAttribute("wishlistCount", count);
        System.out.println("[WishlistServlet GET] -> Lấy thành công " + count + " sản phẩm từ session.");
        System.out.println("------------------------------------------------------------\n");

        request.getRequestDispatcher("/views/wishlist.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "add";
        }

        String rawProductId = request.getParameter("productId");
        int productId = 0;
        try {
            if (rawProductId != null) {
                productId = Integer.parseInt(rawProductId.trim());
            }
        } catch (Exception e) {
            System.err.println("[WishlistServlet POST ERROR] Không parse được productId: '" + rawProductId + "'");
        }

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || "json".equalsIgnoreCase(request.getParameter("format"));

        System.out.println("\n============================================================");
        System.out.println("[WishlistServlet POST] NHẬN YÊU CẦU POST VÀO /wishlist:");
        System.out.println(" - Action: " + action);
        System.out.println(" - ProductID: " + productId + " (raw: '" + rawProductId + "')");
        System.out.println(" - Is AJAX: " + isAjax);
        System.out.println(" - Customer: " + (customer != null ? (customer.getFullName() + " (ID: " + customer.getCustomerID() + ")") : "NULL (Chưa đăng nhập)"));

        // YÊU CẦU: Chỉ cho người đăng nhập rồi mới cho phép add vào wishlist.
        if (customer == null) {
            System.out.println("[WishlistServlet POST] -> Người dùng CHƯA ĐĂNG NHẬP! Báo lỗi yêu cầu đăng nhập.");
            System.out.println("============================================================\n");
            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"success\":false,\"requireLogin\":true,\"message\":\"Vui lòng đăng nhập để thêm sản phẩm vào danh sách yêu thích!\",\"loginUrl\":\"" + request.getContextPath() + "/authen/login.jsp\"}");
                    out.flush();
                }
                return;
            } else {
                response.sendRedirect(request.getContextPath() + "/authen/login.jsp");
                return;
            }
        }

        List<WishlistItemDTO> wishlistItems = getOrCreateSessionWishlistItems(session, customer);
        Set<Integer> wishlistProductIds = getOrCreateSessionWishlistProductIds(session, customer);

        boolean success = false;
        String message = "";
        boolean inWishlist = false;
        boolean alreadyInWishlist = false;

        if (productId > 0) {
            int customerId = customer.getCustomerID();

            final int pid = productId;
            if ("remove".equalsIgnoreCase(action)) {
                // CHỈ XÓA TRONG SESSION (chưa cập nhật database)
                boolean removed = wishlistProductIds.remove(pid);
                wishlistItems.removeIf(item -> item != null && item.getProductId() == pid);
                session.setAttribute("wishlistModified", true);
                success = removed;
                message = removed ? "Đã xóa sản phẩm khỏi danh sách yêu thích." : "Sản phẩm không có trong danh sách yêu thích.";
                inWishlist = false;
                System.out.println("[WishlistServlet POST] Đã xóa productId " + pid + " khỏi session wishlist (còn " + wishlistItems.size() + " items).");
            } else { // default "add"
                // Kiểm tra xem sản phẩm đã có trong wishlist chưa
                if (wishlistProductIds.contains(pid)) {
                    // ĐÃ CÓ TRONG WISHLIST: KHÔNG THỂ THÊM VÀO LẦN NỮA
                    success = false;
                    alreadyInWishlist = true;
                    message = "Sản phẩm này đã có trong danh sách yêu thích!";
                    inWishlist = true;
                    System.out.println("[WishlistServlet POST] ProductId " + pid + " ĐÃ CÓ trong session wishlist. Từ chối thêm trùng.");
                } else {
                    // CHƯA CÓ: CHỈ THÊM VÀO SESSION (chưa cập nhật database)
                    Product prod = productDAO.getProductById(pid);
                    if (prod != null) {
                        WishlistItemDTO newItem = WishlistItemDTO.fromProduct(prod, customerId);
                        wishlistItems.add(0, newItem);
                        wishlistProductIds.add(pid);
                        session.setAttribute("wishlistModified", true);
                        success = true;
                        message = "Đã thêm sản phẩm vào danh sách yêu thích!";
                        inWishlist = true;
                        System.out.println("[WishlistServlet POST] Đã thêm productId " + pid + " vào session wishlist (tổng " + wishlistItems.size() + " items).");
                    } else {
                        success = false;
                        message = "Không tìm thấy thông tin sản phẩm (ID: " + pid + ").";
                        inWishlist = false;
                    }
                }
            }
        } else {
            message = "Mã sản phẩm không hợp lệ: '" + rawProductId + "'";
            System.err.println("[WishlistServlet POST ERROR] " + message);
        }

        int currentCount = wishlistItems.size();
        session.setAttribute("wishlistCount", currentCount);
        System.out.println("[WishlistServlet POST] KẾT QUẢ: success=" + success + ", count=" + currentCount + ", msg=" + message);
        System.out.println("============================================================\n");

        if (isAjax) {
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"success\":" + success 
                        + ",\"alreadyInWishlist\":" + alreadyInWishlist 
                        + ",\"message\":\"" + escapeJson(message) + "\""
                        + ",\"count\":" + currentCount 
                        + ",\"inWishlist\":" + inWishlist 
                        + ",\"productId\":" + productId + "}");
                out.flush();
            }
        } else {
            String redirectUrl = request.getParameter("redirect");
            if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
                response.sendRedirect(redirectUrl);
            } else {
                response.sendRedirect(request.getContextPath() + "/wishlist");
            }
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
