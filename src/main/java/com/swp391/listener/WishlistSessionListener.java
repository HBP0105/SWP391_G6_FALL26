package com.swp391.listener;

import com.swp391.dao.FavoriteDAO;
import com.swp391.model.Customer;
import com.swp391.model.WishlistItemDTO;
import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import java.util.List;

/**
 * Listener theo dõi vòng đời HttpSession.
 * Khi session của người dùng hết hạn (session destroyed / timeout),
 * tự động lưu danh sách wishlist từ session vào database.
 */
@WebListener
public class WishlistSessionListener implements HttpSessionListener {

    private final FavoriteDAO favoriteDAO = new FavoriteDAO();

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // Có thể khởi tạo nếu cần
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        HttpSession session = se.getSession();
        if (session == null) return;

        try {
            Customer customer = (Customer) session.getAttribute("customer");
            Boolean modified = (Boolean) session.getAttribute("wishlistModified");
            @SuppressWarnings("unchecked")
            List<WishlistItemDTO> wishlistItems = (List<WishlistItemDTO>) session.getAttribute("wishlistItems");

            if (customer != null && wishlistItems != null && (modified == null || Boolean.TRUE.equals(modified))) {
                System.out.println("[WishlistSessionListener] Session hết hạn/kết thúc: Lưu wishlist vào database cho Customer " 
                        + customer.getFullName() + " (ID: " + customer.getCustomerID() + ")");
                favoriteDAO.saveFavoritesForCustomer(customer.getCustomerID(), wishlistItems);
                session.setAttribute("wishlistModified", false);
            }
        } catch (Exception e) {
            System.err.println("[WishlistSessionListener ERROR] Không thể lưu wishlist khi session destroyed: " + e.getMessage());
            e.printStackTrace(System.err);
        }
    }
}
