package com.swp391.controller;

import com.swp391.dao.FavoriteDAO;
import com.swp391.model.Customer;
import com.swp391.model.WishlistItemDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            try {
                Customer customer = (Customer) session.getAttribute("customer");
                Boolean modified = (Boolean) session.getAttribute("wishlistModified");
                @SuppressWarnings("unchecked")
                List<WishlistItemDTO> wishlistItems = (List<WishlistItemDTO>) session.getAttribute("wishlistItems");

                if (customer != null && wishlistItems != null && (modified == null || Boolean.TRUE.equals(modified))) {
                    System.out.println("[LogoutServlet] Khách hàng " + customer.getFullName() 
                            + " đăng xuất -> Lưu wishlist từ session vào database (count=" + wishlistItems.size() + ").");
                    FavoriteDAO favoriteDAO = new FavoriteDAO();
                    favoriteDAO.saveFavoritesForCustomer(customer.getCustomerID(), wishlistItems);
                    session.setAttribute("wishlistModified", false);
                }
            } catch (Exception e) {
                System.err.println("[LogoutServlet ERROR] Lỗi khi lưu wishlist lúc đăng xuất: " + e.getMessage());
                e.printStackTrace(System.err);
            }

            session.removeAttribute("user");
            session.removeAttribute("customer");
            session.removeAttribute("role");
            session.removeAttribute("wishlistItems");
            session.removeAttribute("wishlistProductIds");
            session.removeAttribute("wishlistCount");
            session.removeAttribute("wishlistModified");
            session.invalidate();
        }

        response.sendRedirect(request.getContextPath() + "/login");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
