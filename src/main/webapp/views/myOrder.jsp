<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Orders - Headphone Store</title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Main Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />

    <style>
        .order-card {
            background: #fff;
            border: 1px solid #E4E7ED;
            border-radius: 6px;
            margin-bottom: 25px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05);
            transition: all 0.2s ease;
        }
        .order-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .order-card-header {
            background: #fbfbfb;
            padding: 15px 20px;
            border-bottom: 1px solid #E4E7ED;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 6px 6px 0 0;
        }
        .order-card-body {
            padding: 20px;
        }
        .order-card-footer {
            background: #fbfbfb;
            padding: 15px 20px;
            border-top: 1px solid #E4E7ED;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 0 0 6px 6px;
        }
        .order-status-badge {
            font-size: 13px;
            padding: 6px 14px;
            border-radius: 20px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-pending {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }
        .badge-confirmed {
            background-color: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        .badge-shipping {
            background-color: #cce5ff;
            color: #004085;
            border: 1px solid #b8daff;
        }
        .badge-delivered {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .badge-cancelled {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .product-img-thumb {
            width: 65px;
            height: 65px;
            object-fit: cover;
            border-radius: 4px;
            border: 1px solid #E4E7ED;
            background: #f8f9fa;
        }
        .info-pill {
            background-color: #f8f9fa;
            border-left: 3px solid #D10024;
            padding: 10px 15px;
            margin-bottom: 15px;
            border-radius: 0 4px 4px 0;
        }
    </style>
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
                    <li><a href="#"><i class="fa fa-dollar"></i> USD</a></li>
                    <%@ page import="com.swp391.model.Customer" %>
                    <%@ page import="com.swp391.model.Staff" %>
                    <%
                        Object currentUser = session.getAttribute("customer");
                        if (currentUser == null) {
                            currentUser = session.getAttribute("user");
                        }
                        if (currentUser == null) {
                    %>
                    <li>
                        <a href="${pageContext.request.contextPath}/login">
                            <i class="fa fa-user-o"></i> My Account
                        </a>
                    </li>
                    <%
                        } else {
                            String displayName = "";
                            if (currentUser instanceof Customer) {
                                displayName = ((Customer) currentUser).getFullName();
                            } else if (currentUser instanceof Staff) {
                                displayName = ((Staff) currentUser).getFullName();
                            }
                    %>
                    <li>
                        <a href="${pageContext.request.contextPath}/profile">
                            <i class="fa fa-user"></i> <%= displayName %>
                        </a>
                    </li>
                    <%
                        }
                    %>
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
                    <li class="active"><a href="${pageContext.request.contextPath}/my-orders">My Order</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart">Cart</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <!-- /NAVIGATION -->

    <!-- BREADCRUMB -->
    <div id="breadcrumb" class="section" style="padding: 20px 0; background: #fbfbfb; border-bottom: 1px solid #E4E7ED;">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <ul class="breadcrumb-tree" style="margin: 0; padding: 0; list-style: none;">
                        <li style="display: inline-block;"><a href="${pageContext.request.contextPath}/home">Home</a></li>
                        <li style="display: inline-block;" class="active"> / My Orders</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <!-- /BREADCRUMB -->

    <!-- ORDERS SECTION -->
    <div class="section" style="padding-top: 30px; padding-bottom: 60px;">
        <div class="container">
            
            <!-- ORDER PLACED FLASH ALERT -->
            <c:if test="${param.orderSuccess eq 'true'}">
                <div class="alert alert-success" style="background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; border-radius: 6px; padding: 20px; margin-bottom: 30px;">
                    <div style="display: flex; align-items: center;">
                        <i class="fa fa-check-circle" style="font-size: 38px; margin-right: 18px; color: #28a745;"></i>
                        <div>
                            <h4 style="margin: 0 0 6px 0; color: #155724; font-weight: bold;">🎉 Order Placed Successfully!</h4>
                            <p style="margin: 0; font-size: 15px;">
                                Thank you! Your order <strong>#ORD-${param.orderId}</strong> has been received with Cash on Delivery (COD). We are processing your package and will deliver it soon.
                            </p>
                        </div>
                    </div>
                </div>
            </c:if>

            <div class="row">
                <div class="col-md-12">
                    <div class="section-title" style="margin-bottom: 25px;">
                        <h3 class="title">My Orders</h3>
                    </div>

                    <!-- EMPTY ORDERS STATE -->
                    <c:if test="${empty requestScope.orders}">
                        <div class="text-center" style="padding: 60px 20px; background: #fff; border: 1px solid #E4E7ED; border-radius: 6px;">
                            <i class="fa fa-shopping-bag" style="font-size: 60px; color: #ccc; margin-bottom: 15px;"></i>
                            <h4 style="color: #666; margin-bottom: 15px;">You have no orders yet!</h4>
                            <p style="color: #999; margin-bottom: 25px;">Explore our collection of premium headphones and earbuds.</p>
                            <a href="${pageContext.request.contextPath}/home" class="primary-btn" style="border-radius: 4px; padding: 10px 25px;">
                                Continue Shopping
                            </a>
                        </div>
                    </c:if>

                    <!-- ORDERS LIST -->
                    <c:forEach items="${requestScope.orders}" var="order">
                        <div class="order-card">
                            <!-- Card Header: Order ID + Date + Status -->
                            <div class="order-card-header">
                                <div>
                                    <strong style="font-size: 16px; color: #2B2D42;">Order: #ORD-${order.orderId}</strong>
                                    <span class="text-muted" style="margin-left: 15px; font-size: 13px;">
                                        <i class="fa fa-calendar"></i> ${order.orderDate}
                                    </span>
                                </div>
                                <div>
                                    <c:choose>
                                        <c:when test="${order.orderStatus eq 'PENDING'}">
                                            <span class="order-status-badge badge-pending">
                                                <i class="fa fa-hourglass-half"></i> Pending
                                            </span>
                                        </c:when>
                                        <c:when test="${order.orderStatus eq 'CONFIRMED'}">
                                            <span class="order-status-badge badge-confirmed">
                                                <i class="fa fa-check"></i> Confirmed
                                            </span>
                                        </c:when>
                                        <c:when test="${order.orderStatus eq 'SHIPPING'}">
                                            <span class="order-status-badge badge-shipping">
                                                <i class="fa fa-truck"></i> Shipping
                                            </span>
                                        </c:when>
                                        <c:when test="${order.orderStatus eq 'DELIVERED'}">
                                            <span class="order-status-badge badge-delivered">
                                                <i class="fa fa-check-circle"></i> Delivered
                                            </span>
                                        </c:when>
                                        <c:when test="${order.orderStatus eq 'CANCELLED'}">
                                            <span class="order-status-badge badge-cancelled">
                                                <i class="fa fa-times-circle"></i> Cancelled
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="order-status-badge badge-pending">${order.orderStatus}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Card Body: Address + Shipper + Items -->
                            <div class="order-card-body">
                                <div class="row info-pill">
                                    <div class="col-md-7">
                                        <p style="margin: 0; font-size: 14px;">
                                            <i class="fa fa-map-marker" style="color: #D10024;"></i> 
                                            <strong>Shipping Address:</strong> ${order.shippingAddress}
                                        </p>
                                    </div>
                                    <div class="col-md-5 text-right">
                                        <p style="margin: 0; font-size: 14px;">
                                            <i class="fa fa-motorcycle" style="color: #D10024;"></i> 
                                            <strong>Delivery Person (Shipper):</strong> 
                                            <c:choose>
                                                <c:when test="${order.shippingName ne 'Unassigned' && order.shippingName ne 'Chưa phân công' && not empty order.shippingName}">
                                                    <span style="color: #28a745; font-weight: bold;">${order.shippingName}</span> 
                                                    (Phone: <a href="tel:${order.shippingPhone}">${order.shippingPhone}</a>)
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">Awaiting shipper assignment</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                </div>

                                <!-- Items Table -->
                                <div class="table-responsive" style="margin-top: 15px;">
                                    <table class="table" style="margin-bottom: 0;">
                                        <thead>
                                            <tr style="border-top: none; color: #8D99AE; font-size: 13px;">
                                                <th style="border-top: none;" width="80">Image</th>
                                                <th style="border-top: none;">Product</th>
                                                <th style="border-top: none;" class="text-center" width="120">Quantity</th>
                                                <th style="border-top: none;" class="text-right" width="160">Price</th>
                                                <th style="border-top: none;" class="text-right" width="180">Total</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${order.items}" var="item">
                                                <tr style="vertical-align: middle;">
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty item.imageUrl}">
                                                                <img src="${item.imageUrl}" class="product-img-thumb" alt="${item.productName}">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <img src="${pageContext.request.contextPath}/assets/img/product01.png" class="product-img-thumb" alt="${item.productName}">
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="vertical-align: middle;">
                                                        <strong style="color: #2B2D42;">${item.productName}</strong>
                                                    </td>
                                                    <td style="vertical-align: middle;" class="text-center">
                                                        x${item.quantity}
                                                    </td>
                                                    <td style="vertical-align: middle;" class="text-right">
                                                        $<fmt:formatNumber value="${item.price}" pattern="#,##0" />
                                                    </td>
                                                    <td style="vertical-align: middle;" class="text-right">
                                                        <strong style="color: #D10024;">$<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0" /></strong>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Card Footer: Payment Method + Total -->
                            <div class="order-card-footer">
                                <span class="text-muted" style="font-size: 13px;">
                                    <i class="fa fa-money"></i> Payment Method: <strong>Cash on Delivery (COD)</strong>
                                </span>
                                <div>
                                    <span style="font-size: 15px; margin-right: 10px;">Order Total:</span>
                                    <strong style="font-size: 20px; color: #D10024;">$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /></strong>
                                </div>
                            </div>
                        </div>
                    </c:forEach>

                </div>
            </div>
        </div>
    </div>
    <!-- /ORDERS SECTION -->

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
</body>
</html>
