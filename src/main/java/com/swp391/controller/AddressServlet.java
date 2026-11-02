package com.swp391.controller;

import com.swp391.dao.AddressDAO;
import com.swp391.model.Address;
import com.swp391.model.Customer;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AddressServlet", urlPatterns = {"/addresses"})
public class AddressServlet extends HttpServlet {

    private AddressDAO addressDAO;

    @Override
    public void init() throws ServletException {
        addressDAO = new AddressDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Address> addresses = addressDAO.getAddressesByCustomerId(customer.getCustomerID());
        request.setAttribute("addresses", addresses);
        request.getRequestDispatcher("/views/addressRepository.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("customer");
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        int customerId = customer.getCustomerID();

        if ("add".equals(action)) {
            Address addr = new Address();
            addr.setCustomerId(customerId);
            addr.setReceiverName(request.getParameter("receiverName"));
            addr.setReceiverPhone(request.getParameter("receiverPhone"));
            addr.setProvince(request.getParameter("province"));
            addr.setDistrict(request.getParameter("district"));
            addr.setWard(request.getParameter("ward"));
            addr.setAddressLine(request.getParameter("addressLine"));
            addr.setIsDefault(request.getParameter("isDefault") != null);
            addressDAO.addAddress(addr);

        } else if ("update".equals(action)) {
            Address addr = new Address();
            addr.setAddressId(Integer.parseInt(request.getParameter("addressId")));
            addr.setCustomerId(customerId);
            addr.setReceiverName(request.getParameter("receiverName"));
            addr.setReceiverPhone(request.getParameter("receiverPhone"));
            addr.setProvince(request.getParameter("province"));
            addr.setDistrict(request.getParameter("district"));
            addr.setWard(request.getParameter("ward"));
            addr.setAddressLine(request.getParameter("addressLine"));
            addr.setIsDefault(request.getParameter("isDefault") != null);
            addressDAO.updateAddress(addr);

        } else if ("delete".equals(action)) {
            int addressId = Integer.parseInt(request.getParameter("addressId"));
            addressDAO.deleteAddress(addressId, customerId);

        } else if ("setDefault".equals(action)) {
            int addressId = Integer.parseInt(request.getParameter("addressId"));
            addressDAO.setDefaultAddress(addressId, customerId);
        }

        response.sendRedirect(request.getContextPath() + "/addresses");
    }
}
