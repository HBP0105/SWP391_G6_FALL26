<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    // Kiểm tra phân quyền: Chỉ cho phép Customer xem trang checkout
    Object customer = session.getAttribute("customer");
    
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return; 
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Checkout - Headphone Store</title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Main Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />
    
    <!-- Custom Checkout Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/checkout.css" />
</head>
<body>
    <!-- HEADER -->
    <header>
        <!-- TOP HEADER -->
        <div id="top-header">
            <div class="container">
                <%@ page import="com.swp391.model.Customer" %>
                <%@ page import="com.swp391.model.Staff" %>
                <%
                    Object currentUser = session.getAttribute("customer");
                    if (currentUser == null) {
                        currentUser = session.getAttribute("user");
                    }
                    String displayPhone = "";
                    String displayEmail = "";
                    String displayName = "";
                    if (currentUser instanceof Customer) {
                        Customer c = (Customer) currentUser;
                        displayPhone = c.getPhone() != null ? c.getPhone() : "";
                        displayEmail = c.getEmail() != null ? c.getEmail() : "";
                        displayName = c.getFullName() != null ? c.getFullName() : "";
                    } else if (currentUser instanceof Staff) {
                        Staff s = (Staff) currentUser;
                        displayPhone = s.getPhone() != null ? s.getPhone() : "";
                        displayEmail = s.getEmail() != null ? s.getEmail() : "";
                        displayName = s.getFullName() != null ? s.getFullName() : "";
                    }
                %>
                <ul class="header-links pull-left">
                    <% if (!displayPhone.isEmpty()) { %>
                    <li><a href="tel:<%= displayPhone %>"><i class="fa fa-phone"></i> <%= displayPhone %></a></li>
                    <% } %>
                    <% if (!displayEmail.isEmpty()) { %>
                    <li><a href="mailto:<%= displayEmail %>"><i class="fa fa-envelope-o"></i> <%= displayEmail %></a></li>
                    <% } %>
                </ul>
                <ul class="header-links pull-right">
                    <% if (currentUser == null) { %>
                    <li>
                        <a href="${pageContext.request.contextPath}/login">
                            <i class="fa fa-user-o"></i> My Account
                        </a>
                    </li>
                    <% } else { %>
                    <li>
                        <a href="${pageContext.request.contextPath}/profile">
                            <i class="fa fa-user"></i> <%= displayName %>
                        </a>
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>
        <!-- /TOP HEADER -->

        <!-- MAIN HEADER -->
        <div id="header">
            <div class="container">
                <div class="row">
                    <!-- LOGO -->
                    <div class="col-md-3">
                        <div class="header-logo">
                            <a href="${pageContext.request.contextPath}/home" class="logo">
                                <img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="Logo">
                            </a>
                        </div>
                    </div>
                    <!-- /LOGO -->
                </div>
            </div>
        </div>
        <!-- /MAIN HEADER -->
    </header>
    <!-- /HEADER -->

    <!-- NAVIGATION -->
    <nav id="navigation">
        <div class="container">
            <div id="responsive-nav">
                <ul class="main-nav nav navbar-nav">
                    <li><a href="${pageContext.request.contextPath}/home">Home</a></li>
                    <li><a href="${pageContext.request.contextPath}/my-orders">My Order</a></li>
                    <li><a href="${pageContext.request.contextPath}/addresses">Address Repository</a></li>
                    <li class="active"><span>Checkout</span></li>
                </ul>
            </div>
        </div>
    </nav>
    <!-- /NAVIGATION -->

    <!-- CHECKOUT SECTION -->
    <div class="section checkout-section">
        <div class="container">
            <form action="${pageContext.request.contextPath}/checkout" method="POST">
                <div class="row">
                    <!-- Billing Details -->
                    <div class="col-md-7">
                        <div class="checkout-details">
                            <h3>Shipping Information</h3>
                            
                            <div class="form-group">
                                <label>Customer Name</label>
                                <input type="text" class="form-control" value="${sessionScope.customer.fullName}" readonly>
                            </div>
                            
                            <div class="form-group">
                                <label>Customer Phone</label>
                                <input type="tel" class="form-control" value="${sessionScope.customer.phone}" readonly>
                            </div>
                            
                            <div class="form-group">
                                <label>Email Address</label>
                                <input type="email" class="form-control" value="${sessionScope.customer.email}" readonly>
                            </div>

                            <!-- CHỌN ĐỊA CHỈ TỪ ADDRESS REPOSITORY HOẶC TỰ NHẬP MỚI -->
                            <div class="form-group saved-address-box">
                                <div class="saved-address-header">
                                    <label>Select from Address Repository:</label>
                                    <a href="${pageContext.request.contextPath}/addresses" class="btn btn-default btn-xs">
                                        Manage Address Repository
                                    </a>
                                </div>
                                <c:choose>
                                    <c:when test="${not empty requestScope.savedAddresses}">
                                        <select id="savedAddressSelect" class="form-control saved-address-select" onchange="applySavedAddress(this)">
                                            <option value="">-- Enter a new address manually below --</option>
                                            <c:forEach items="${requestScope.savedAddresses}" var="addr">
                                                <option value="${addr.addressId}"
                                                        data-province="${addr.province}"
                                                        data-district="${addr.district}"
                                                        data-ward="${addr.ward}"
                                                        data-line="${addr.addressLine}"
                                                        ${addr.isDefault ? 'selected' : ''}>
                                                    ${addr.receiverName} (${addr.receiverPhone}) - ${addr.addressLine}, ${addr.ward}, ${addr.district}, ${addr.province} ${addr.isDefault ? '[Default]' : ''}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="text-muted saved-address-empty">
                                            No saved addresses yet. <a href="${pageContext.request.contextPath}/addresses" class="brand-link">Add to Address Repository</a> or enter your address below.
                                        </p>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="province">Province/City <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="province" name="province" placeholder="Province" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="district">District <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="district" name="district" placeholder="District" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="ward">Ward <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="ward" name="ward" placeholder="Ward" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="addressLine">Address Line <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="addressLine" name="addressLine" placeholder="Street name, house number, etc." required>
                            </div>

                            <div class="form-group">
                                <label for="orderNotes">Order Notes (Optional)</label>
                                <textarea class="form-control" id="orderNotes" name="orderNotes" rows="3" placeholder="Any special requests?"></textarea>
                            </div>
                        </div>
                    </div>
                    <!-- /Billing Details -->

                    <!-- Order Summary -->
                    <div class="col-md-5">
                        <div class="order-summary">
                            <h3>Your Order</h3>
                            
                            <div class="order-products">
                                <div class="order-col order-col-header">
                                    <strong>Product</strong>
                                    <strong>Total</strong>
                                </div>
                                <c:set var="totalPrice" value="0" />
                                <c:forEach items="${requestScope.listCart}" var="item">
                                    <div class="order-col">
                                        <div>${item.quantity}x ${item.productName}</div>
                                        <div>$<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0" /></div>
                                    </div>
                                    <c:set var="totalPrice" value="${totalPrice + (item.price * item.quantity)}" />
                                </c:forEach>
                            </div>
                            
                            <div class="order-col">
                                <div><strong>Subtotal</strong></div>
                                <div><strong>$<fmt:formatNumber value="${totalPrice}" pattern="#,##0" /></strong></div>
                            </div>
                            <div class="order-col">
                                <div><strong>Shipping</strong></div>
                                <div><strong>Free</strong></div>
                            </div>

                            <!-- Discount Voucher in Order Summary -->
                            <div class="form-group voucher-group">
                                <div class="voucher-input-wrap">
                                    <input type="text" class="form-control voucher-input" id="voucherCode" name="voucherCode" placeholder="Discount voucher">
                                    <button class="primary-btn voucher-btn" type="button">Apply</button>
                                </div>
                            </div>
                            
                            <div class="order-col order-total">
                                <div><strong>TOTAL</strong></div>
                                <div><strong class="order-total-price">$<fmt:formatNumber value="${totalPrice}" pattern="#,##0" /></strong></div>
                            </div>

                            <!-- Payment Method -->
                            <div class="payment-method">
                                <h4>Payment Method</h4>
                                <div class="form-group">
                                    <select class="form-control payment-method-select" name="paymentMethod" id="paymentMethod">
                                        <option value="COD">Cash on Delivery (COD)</option>
                                        <option value="VNPAY">VNPay</option>
                                    </select>
                                </div>
                            </div>
                            <!-- /Payment Method -->

                            <button type="submit" class="primary-btn place-order-btn">Place Order</button>
                        </div>
                    </div>
                    <!-- /Order Summary -->
                </div>
            </form>
        </div>
    </div>
    <!-- /CHECKOUT SECTION -->

    <!-- FOOTER -->
    <footer id="footer">
        <div class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12 text-center">
                        <p class="text-muted">© 2026 Headphone Store. All rights reserved.</p>
                    </div>
                </div>
            </div>
        </div>
    </footer>
    <!-- /FOOTER -->

    <!-- jQuery Plugins -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script>
        function applySavedAddress(selectElem) {
            var opt = selectElem.options[selectElem.selectedIndex];
            if (!opt || !opt.value) {
                document.getElementById('province').value = '';
                document.getElementById('district').value = '';
                document.getElementById('ward').value = '';
                document.getElementById('addressLine').value = '';
                return;
            }
            document.getElementById('province').value = opt.getAttribute('data-province') || '';
            document.getElementById('district').value = opt.getAttribute('data-district') || '';
            document.getElementById('ward').value = opt.getAttribute('data-ward') || '';
            document.getElementById('addressLine').value = opt.getAttribute('data-line') || '';
        }

        window.addEventListener('DOMContentLoaded', function () {
            var selectElem = document.getElementById('savedAddressSelect');
            if (selectElem && selectElem.value) {
                applySavedAddress(selectElem);
            }
        });
    </script>
</body>
</html>
