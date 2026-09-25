<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Shopping Cart - Headphone Store</title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Main Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />
    
    <!-- Custom Cart Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cart.css" />
</head>
<body>
    <!-- HEADER -->
    <header>
        <!-- TOP HEADER -->
        <div id="top-header">
            <div class="container">
                <ul class="header-links pull-left">
                    <li><a href="#"><i class="fa fa-phone"></i> +021-95-51-84</a></li>
                    <li><a href="#"><i class="fa fa-envelope-o"></i> email@email.com</a></li>
                </ul>
                <ul class="header-links pull-right">
                    <li><a href="#"><i class="fa fa-user-o"></i> My Account</a></li>
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
                            <a href="${pageContext.request.contextPath}/views/home.jsp" class="logo">
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
                    <li><a href="${pageContext.request.contextPath}/views/home.jsp">Home</a></li>
                    <li><a href="#">Categories</a></li>
                    <li class="active"><a href="#">Cart</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <!-- /NAVIGATION -->

    <!-- CART SECTION -->
    <div class="section cart-section">
        <div class="container">
            <div class="row">
                <!-- Cart Items Table -->
                <div class="col-md-8">
                    <div class="section-title">
                        <h3 class="title">Your Shopping Cart</h3>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="cart-table">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Details</th>
                                    <th>Price</th>
                                    <th>Quantity</th>
                                    <th>Total</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:set var="totalPrice" value="0" />
                                <c:forEach items="${requestScope.listCart}" var="item">
                                    <tr>
                                        <td>
                                            <c:choose>
                                                <c:when test="${empty item.imageUrl}">
                                                    <!-- Nếu không có ảnh, nối đường dẫn gốc với ảnh mặc định (default.png) -->
                                                    <img src="${pageContext.request.contextPath}/assets/img/default.png" alt="${item.productName}" class="cart-item-img">
                                                </c:when>
                                                <c:otherwise>
                                                    <!-- Nếu có ảnh từ DB thì in ra bình thường -->
                                                    <img src="${item.imageUrl}" alt="${item.productName}" class="cart-item-img">
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="cart-item-title">${item.productName}</td>
                                        <td>$${item.price}</td>
                                        <td>
                                            <input type="number" class="qty-input" value="${item.quantity}" min="1">
                                        </td>
                                        <td>$${item.price * item.quantity}</td>
                                        <td>
                                            <button class="remove-btn"><i class="fa fa-trash"></i></button>
                                        </td>
                                    </tr>
                                    <c:set var="totalPrice" value="${totalPrice + (item.price * item.quantity)}" />
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
                <!-- /Cart Items Table -->

                <!-- Cart Summary -->
                <div class="col-md-4">
                    <div class="cart-summary">
                        <h3>Order Summary</h3>
                        <div class="summary-item summary-total" style="border-top: none; padding-top: 0;">
                            <span>Total:</span>
                            <span>$${totalPrice}</span>
                        </div>
                        <a href="checkout.jsp" class="primary-btn checkout-btn text-center">Proceed to Checkout</a>
                    </div>
                </div>
                <!-- /Cart Summary -->
            </div>
        </div>
    </div>
    <!-- /CART SECTION -->

    <!-- FOOTER -->
    <footer id="footer">
        <div class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12 text-center">
                        <p class="text-muted">Â© 2026 Headphone Store. All rights reserved.</p>
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
</body>
</html>
