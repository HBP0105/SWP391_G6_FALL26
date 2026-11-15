<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

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

    <!-- Custom My Orders Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/myOrder.css" />
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
                    <li class="active"><a href="${pageContext.request.contextPath}/my-orders">My Order</a></li>
                    <li><a href="${pageContext.request.contextPath}/addresses">Address Repository</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart">Cart</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <!-- /NAVIGATION -->

    <!-- Đếm số lượng đơn ở từng trạng thái để hiển thị trên Tab -->
    <c:set var="currentTab" value="${empty param.status ? 'ALL' : param.status}" />
    <c:set var="countAll" value="0" />
    <c:set var="countPending" value="0" />
    <c:set var="countConfirmed" value="0" />
    <c:set var="countShipping" value="0" />
    <c:set var="countDelivered" value="0" />
    <c:set var="countCancelled" value="0" />

    <c:forEach items="${requestScope.orders}" var="o">
        <c:set var="countAll" value="${countAll + 1}" />
        <c:if test="${o.orderStatus eq 'PENDING'}"><c:set var="countPending" value="${countPending + 1}" /></c:if>
        <c:if test="${o.orderStatus eq 'CONFIRMED'}"><c:set var="countConfirmed" value="${countConfirmed + 1}" /></c:if>
        <c:if test="${o.orderStatus eq 'SHIPPING'}"><c:set var="countShipping" value="${countShipping + 1}" /></c:if>
        <c:if test="${o.orderStatus eq 'DELIVERED'}"><c:set var="countDelivered" value="${countDelivered + 1}" /></c:if>
        <c:if test="${o.orderStatus eq 'CANCELLED'}"><c:set var="countCancelled" value="${countCancelled + 1}" /></c:if>
    </c:forEach>

    <!-- ORDERS SECTION -->
    <div class="section orders-section">
        <div class="container">
            
            <!-- ORDER PLACED / VNPAY CONFIRMED FLASH ALERT -->
            <c:if test="${param.orderSuccess eq 'true'}">
                <div class="alert alert-success">
                    <c:choose>
                        <c:when test="${param.method eq 'VNPAY'}">
                            <strong>Payment Successful!</strong> Your payment for order <strong>#ORD-${param.orderId}</strong> has been verified and the order is now <strong>Confirmed</strong>.
                        </c:when>
                        <c:otherwise>
                            <strong>Order Placed Successfully!</strong> Your order <strong>#ORD-${param.orderId}</strong> (COD) is currently <strong>Pending</strong> confirmation.
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <!-- PAYMENT FAILED / CANCELLED ALERT -->
            <c:if test="${param.paymentFailed eq 'true'}">
                <div class="alert alert-danger">
                    <strong>Payment Failed!</strong> The VNPay payment for order <strong>#ORD-${param.orderId}</strong> was not completed. The order has been moved to <strong>Cancelled</strong>.
                </div>
            </c:if>

            <!-- ORDER CANCELLED SUCCESSFULLY ALERT -->
            <c:if test="${param.cancelSuccess eq 'true'}">
                <div class="alert alert-warning">
                    <strong>Order Cancelled!</strong> Your order <strong>#ORD-${param.orderId}</strong> has been cancelled.
                </div>
            </c:if>

            <div class="row">
                <div class="col-md-12">
                    <!-- THANH TAB NGANG LỌC ĐƠN HÀNG THEO TRẠNG THÁI -->
                    <div class="order-tabs">
                        <a href="${pageContext.request.contextPath}/my-orders?status=ALL" 
                           class="order-tab-item ${currentTab eq 'ALL' ? 'active' : ''}">
                            All Orders <span class="tab-count">${countAll}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/my-orders?status=PENDING" 
                           class="order-tab-item ${currentTab eq 'PENDING' ? 'active' : ''}">
                           Pending <span class="tab-count">${countPending}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/my-orders?status=CONFIRMED" 
                           class="order-tab-item ${currentTab eq 'CONFIRMED' ? 'active' : ''}">
                           Confirmed <span class="tab-count">${countConfirmed}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/my-orders?status=SHIPPING" 
                           class="order-tab-item ${currentTab eq 'SHIPPING' ? 'active' : ''}">
                           Shipping <span class="tab-count">${countShipping}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/my-orders?status=DELIVERED" 
                           class="order-tab-item ${currentTab eq 'DELIVERED' ? 'active' : ''}">
                           Delivered <span class="tab-count">${countDelivered}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/my-orders?status=CANCELLED" 
                           class="order-tab-item ${currentTab eq 'CANCELLED' ? 'active' : ''}">
                           Cancelled <span class="tab-count">${countCancelled}</span>
                        </a>
                    </div>

                    <!-- THANH TÌM KIẾM ĐƠN HÀNG (CHỈ HIỂN THỊ Ở MỤC ALL ORDERS) -->
                    <c:if test="${currentTab eq 'ALL'}">
                        <form action="${pageContext.request.contextPath}/my-orders" method="GET" class="order-search-form">
                            <input type="hidden" name="status" value="ALL">
                            <div class="input-group">
                                <input type="text" class="form-control" name="keyword" value="${fn:escapeXml(param.keyword)}"
                                       placeholder="Search by Order ID (e.g. #ORD-5), Product Name, or Shipping Address...">
                                <span class="input-group-btn">
                                    <button class="btn btn-danger btn-search-order" type="submit">
                                        <i class="fa fa-search"></i> Search
                                    </button>
                                    <c:if test="${not empty param.keyword}">
                                        <a href="${pageContext.request.contextPath}/my-orders?status=ALL" class="btn btn-default">
                                            Clear
                                        </a>
                                    </c:if>
                                </span>
                            </div>
                        </form>
                    </c:if>

                    <!-- LỌC THEO TAB + SEARCH & PHÂN TRANG (MỖI TRANG 5 ĐƠN HÀNG) -->
                    <c:set var="kwLower" value="${(currentTab eq 'ALL' and not empty param.keyword) ? fn:toLowerCase(fn:trim(param.keyword)) : ''}" />
                    <c:set var="pageSize" value="5" />
                    <c:set var="currPage" value="${not empty param.page ? param.page : 1}" />
                    <c:set var="startIdx" value="${(currPage - 1) * pageSize + 1}" />
                    <c:set var="endIdx" value="${currPage * pageSize}" />

                    <!-- ORDERS LIST -->
                    <c:set var="matchedCount" value="0" />
                    <c:set var="displayedCount" value="0" />
                    <c:forEach items="${requestScope.orders}" var="order">
                        <c:if test="${currentTab eq 'ALL' or order.orderStatus eq currentTab}">
                            <c:set var="isMatch" value="false" />
                            <c:choose>
                                <c:when test="${empty kwLower}">
                                    <c:set var="isMatch" value="true" />
                                </c:when>
                                <c:otherwise>
                                    <c:set var="orderCode" value="#ord-${order.orderId}" />
                                    <c:if test="${fn:contains(orderCode, kwLower) or fn:contains(fn:toLowerCase(order.shippingAddress), kwLower)}">
                                        <c:set var="isMatch" value="true" />
                                    </c:if>
                                    <c:forEach items="${order.items}" var="it">
                                        <c:if test="${fn:contains(fn:toLowerCase(it.productName), kwLower)}">
                                            <c:set var="isMatch" value="true" />
                                        </c:if>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>

                            <c:if test="${isMatch}">
                                <c:set var="matchedCount" value="${matchedCount + 1}" />
                                <c:if test="${matchedCount >= startIdx and matchedCount <= endIdx}">
                                    <c:set var="displayedCount" value="${displayedCount + 1}" />
                                    <div class="order-card">
                                <!-- Card Header: Order ID + Date + Status -->
                                <div class="order-card-header">
                                    <div>
                                        <strong class="order-id-title">Order: #ORD-${order.orderId}</strong>
                                        <span class="text-muted order-date-text">
                                            <i class="fa fa-calendar"></i> ${order.orderDate}
                                        </span>
                                    </div>
                                    <div>
                                        <c:choose>
                                            <c:when test="${order.orderStatus eq 'PENDING'}">
                                                <span class="order-status-badge badge-pending">
                                                    <i class="fa fa-hourglass-half"></i> Pending Confirmation
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
                                            <p class="info-pill-text">
                                                <i class="fa fa-map-marker icon-brand"></i> 
                                                <strong>Shipping Address:</strong> ${order.shippingAddress}
                                            </p>
                                        </div>
                                        <div class="col-md-5 text-right">
                                            <p class="info-pill-text">
                                                <i class="fa fa-motorcycle icon-brand"></i> 
                                                <strong>Delivery Person (Shipper):</strong> 
                                                <c:choose>
                                                    <c:when test="${order.shippingName ne 'Unassigned' && order.shippingName ne 'Chưa phân công' && not empty order.shippingName}">
                                                        <span class="shipper-name">${order.shippingName}</span> 
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
                                    <div class="table-responsive order-items-wrap">
                                        <table class="table order-items-table">
                                            <thead>
                                                <tr>
                                                    <th width="80">Image</th>
                                                    <th>Product</th>
                                                    <th class="text-center" width="120">Quantity</th>
                                                    <th class="text-right" width="160">Price</th>
                                                    <th class="text-right" width="180">Total</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${order.items}" var="item">
                                                    <tr>
                                                        <td>
                                                            <a href="javascript:void(0);"
                                                               onclick="showOrderedProductModal(this)"
                                                               data-name="${item.productName}"
                                                               data-brand="${not empty item.brandName ? item.brandName : 'N/A'}"
                                                               data-category="${not empty item.categoryName ? item.categoryName : 'Headphone'}"
                                                               data-price="<fmt:formatNumber value='${item.price}' pattern='#,##0' />"
                                                               data-qty="${item.quantity}"
                                                               data-total="<fmt:formatNumber value='${item.price * item.quantity}' pattern='#,##0' />"
                                                               data-img="${empty item.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(item.imageUrl, 'http') ? item.imageUrl : pageContext.request.contextPath.concat('/').concat(item.imageUrl))}"
                                                               data-desc="${not empty item.description ? item.description : 'High-quality audio device.'}"
                                                               data-conn="${not empty item.connectionType ? item.connectionType : 'Standard'}"
                                                               data-driver="${item.driverSize > 0 ? item.driverSize : 'Standard'}"
                                                               data-anc="${item.noiseCancelling ? 'Yes (Active Noise Cancelling)' : 'No'}"
                                                               data-battery="${item.batteryLife > 0 ? item.batteryLife : 'Wired / N/A'}"
                                                               data-mic="${item.microphone ? 'Yes (Built-in Mic)' : 'No'}"
                                                               data-water="${not empty item.waterResistance ? item.waterResistance : 'None'}"
                                                               data-weight="${item.weight > 0 ? item.weight : 'N/A'}">
                                                                <c:choose>
                                                                    <c:when test="${not empty item.imageUrl}">
                                                                        <img src="${fn:startsWith(item.imageUrl, 'http') ? item.imageUrl : pageContext.request.contextPath.concat('/').concat(item.imageUrl)}" class="product-img-thumb" alt="${item.productName}"
                                                                             onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/product01.png';">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <img src="${pageContext.request.contextPath}/assets/img/product01.png" class="product-img-thumb" alt="${item.productName}">
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </a>
                                                        </td>
                                                        <td>
                                                            <a href="javascript:void(0);"
                                                               onclick="showOrderedProductModal(this)"
                                                               data-name="${item.productName}"
                                                               data-brand="${not empty item.brandName ? item.brandName : 'N/A'}"
                                                               data-category="${not empty item.categoryName ? item.categoryName : 'Headphone'}"
                                                               data-price="<fmt:formatNumber value='${item.price}' pattern='#,##0' />"
                                                               data-qty="${item.quantity}"
                                                               data-total="<fmt:formatNumber value='${item.price * item.quantity}' pattern='#,##0' />"
                                                               data-img="${empty item.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(item.imageUrl, 'http') ? item.imageUrl : pageContext.request.contextPath.concat('/').concat(item.imageUrl))}"
                                                               data-desc="${not empty item.description ? item.description : 'High-quality audio device.'}"
                                                               data-conn="${not empty item.connectionType ? item.connectionType : 'Standard'}"
                                                               data-driver="${item.driverSize > 0 ? item.driverSize : 'Standard'}"
                                                               data-anc="${item.noiseCancelling ? 'Yes (Active Noise Cancelling)' : 'No'}"
                                                               data-battery="${item.batteryLife > 0 ? item.batteryLife : 'Wired / N/A'}"
                                                               data-mic="${item.microphone ? 'Yes (Built-in Mic)' : 'No'}"
                                                               data-water="${not empty item.waterResistance ? item.waterResistance : 'None'}"
                                                               data-weight="${item.weight > 0 ? item.weight : 'N/A'}"
                                                               class="product-name-link">
                                                                <strong>${item.productName}</strong>
                                                            </a>
                                                        </td>
                                                        <td class="text-center">
                                                            x${item.quantity}
                                                        </td>
                                                        <td class="text-right">
                                                            $<fmt:formatNumber value="${item.price}" pattern="#,##0" />
                                                        </td>
                                                        <td class="text-right">
                                                            <strong class="price-highlight">$<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0" /></strong>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                                <!-- Card Footer: Payment Method + Cancel Button + Total -->
                                <div class="order-card-footer">
                                    <span class="text-muted payment-info-text">
                                        <c:choose>
                                            <c:when test="${order.paymentMethod eq 'VNPAY'}">
                                                <i class="fa fa-credit-card"></i> Payment Method: <strong>VNPay Online</strong>
                                                <c:choose>
                                                    <c:when test="${order.paymentStatus eq 'SUCCESS'}">
                                                        <span class="payment-tag payment-paid"><i class="fa fa-check"></i> Paid</span>
                                                    </c:when>
                                                    <c:when test="${order.paymentStatus eq 'FAILED'}">
                                                        <span class="payment-tag payment-failed">Payment Failed</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="payment-tag payment-unpaid">Unpaid</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa fa-money"></i> Payment Method: <strong>Cash on Delivery (COD)</strong>
                                                <c:choose>
                                                    <c:when test="${order.paymentStatus eq 'SUCCESS'}">
                                                        <span class="payment-tag payment-paid"><i class="fa fa-check"></i> Paid</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="payment-tag payment-unpaid">Pay on Delivery</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                    <div class="order-footer-actions">
                                        <!-- NÚT XEM CHI TIẾT ĐƠN HÀNG (MỞ SCREEN RIÊNG /order-detail) -->
                                        <a href="${pageContext.request.contextPath}/order-detail?id=${order.orderId}" class="btn btn-default btn-sm">
                                            View Details
                                        </a>

                                        <!-- NÚT HỦY ĐƠN HÀNG (Chỉ hiện khi đơn đang PENDING hoặc CONFIRMED) -->
                                        <c:if test="${order.orderStatus eq 'PENDING' or order.orderStatus eq 'CONFIRMED'}">
                                            <button type="button" class="btn btn-danger btn-sm"
                                                    onclick="openCancelOrderModal('${order.orderId}')">
                                                Cancel Order
                                            </button>
                                        </c:if>

                                        <div>
                                            <span class="order-total-label">Order Total:</span>
                                            <strong class="order-total-amount">$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /></strong>
                                        </div>
                                    </div>
                                </div>
                                    </div>
                                </c:if>
                            </c:if>
                        </c:if>
                    </c:forEach>

                    <!-- THANH PHÂN TRANG (5 ĐƠN HÀNG / TRANG) -->
                    <c:set var="totalPages" value="${matchedCount == 0 ? 1 : ((matchedCount + pageSize - 1) - ((matchedCount + pageSize - 1) % pageSize)) / pageSize}" />
                    <fmt:parseNumber var="totalPagesInt" integerOnly="true" type="number" value="${totalPages}" />
                    <c:if test="${totalPagesInt > 1}">
                        <div class="text-center order-pagination-wrap">
                            <ul class="pagination order-pagination">
                                <!-- Nút Previous -->
                                <li class="${currPage <= 1 ? 'disabled' : ''}">
                                    <c:choose>
                                        <c:when test="${currPage <= 1}">
                                            <span>&laquo; Prev</span>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/my-orders?status=${currentTab}&keyword=${fn:escapeXml(param.keyword)}&page=${currPage - 1}">&laquo; Prev</a>
                                        </c:otherwise>
                                    </c:choose>
                                </li>

                                <!-- Các số trang 1, 2, 3... -->
                                <c:forEach begin="1" end="${totalPagesInt}" var="p">
                                    <li class="${p == currPage ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/my-orders?status=${currentTab}&keyword=${fn:escapeXml(param.keyword)}&page=${p}">
                                            ${p}
                                        </a>
                                    </li>
                                </c:forEach>

                                <!-- Nút Next -->
                                <li class="${currPage >= totalPagesInt ? 'disabled' : ''}">
                                    <c:choose>
                                        <c:when test="${currPage >= totalPagesInt}">
                                            <span>Next &raquo;</span>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/my-orders?status=${currentTab}&keyword=${fn:escapeXml(param.keyword)}&page=${currPage + 1}">Next &raquo;</a>
                                        </c:otherwise>
                                    </c:choose>
                                </li>
                            </ul>
                        </div>
                    </c:if>

                    <!-- TRƯỜNG HỢP TAB HIỆN TẠI KHÔNG CÓ ĐƠN HÀNG NÀO -->
                    <c:if test="${displayedCount == 0}">
                        <div class="text-center empty-orders-box">
                            <i class="fa fa-shopping-bag empty-orders-icon"></i>
                            <h4 class="empty-orders-title">
                                <c:choose>
                                    <c:when test="${currentTab eq 'ALL'}">You have no orders yet!</c:when>
                                    <c:otherwise>No orders in "${currentTab}" status.</c:otherwise>
                                </c:choose>
                            </h4>
                            <p class="empty-orders-desc">Explore our collection of premium headphones and earbuds.</p>
                            <a href="${pageContext.request.contextPath}/home" class="primary-btn empty-orders-btn">
                                Continue Shopping
                            </a>
                        </div>
                    </c:if>

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

    <!-- MODAL XEM CHI TIẾT SẢN PHẨM ĐÃ ĐẶT -->
    <div id="orderedProductModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title" id="modal_prod_name">Product Details</h4>
                </div>
                <div class="modal-body">
                    <div class="row modal-prod-top">
                        <div class="col-sm-4 text-center">
                            <img id="modal_prod_img" src="" alt="Product Image"
                                 class="modal-prod-img"
                                 onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/product01.png';">
                        </div>
                        <div class="col-sm-8">
                            <p><strong>Brand:</strong> <span id="modal_prod_brand"></span> | <strong>Category:</strong> <span id="modal_prod_category"></span></p>
                            <p><strong>Price:</strong> <span id="modal_prod_price"></span> | <strong>Quantity:</strong> <span id="modal_prod_qty"></span></p>
                            <p><strong>Total:</strong> <span id="modal_prod_total" class="price-highlight"></span></p>
                            <p id="modal_prod_desc" class="text-muted modal-prod-desc"></p>
                        </div>
                    </div>

                    <table class="table table-bordered modal-specs-table">
                        <tbody>
                            <tr>
                                <th width="40%">Connection Type</th>
                                <td id="modal_prod_conn"></td>
                            </tr>
                            <tr>
                                <th>Driver Size</th>
                                <td id="modal_prod_driver"></td>
                            </tr>
                            <tr>
                                <th>Noise Cancelling</th>
                                <td id="modal_prod_anc"></td>
                            </tr>
                            <tr>
                                <th>Battery Life</th>
                                <td id="modal_prod_battery"></td>
                            </tr>
                            <tr>
                                <th>Microphone</th>
                                <td id="modal_prod_mic"></td>
                            </tr>
                            <tr>
                                <th>Water Resistance</th>
                                <td id="modal_prod_water"></td>
                            </tr>
                            <tr>
                                <th>Weight</th>
                                <td id="modal_prod_weight"></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL XÁC NHẬN HỦY ĐƠN HÀNG -->
    <div id="cancelOrderModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-sm" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Cancel Order</h4>
                </div>
                <form action="${pageContext.request.contextPath}/my-orders" method="POST" class="modal-form-clean">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="orderId" id="cancel_modal_orderId">
                        <p class="modal-confirm-text">Are you sure you want to cancel order <strong id="cancel_modal_orderLabel"></strong>?</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">No</button>
                        <button type="submit" class="btn btn-danger">Yes, Cancel</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- jQuery Plugins -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script>
        function openCancelOrderModal(orderId) {
            document.getElementById('cancel_modal_orderId').value = orderId;
            document.getElementById('cancel_modal_orderLabel').textContent = '#ORD-' + orderId;
            $('#cancelOrderModal').modal('show');
        }

        function showOrderedProductModal(elem) {
            var driver = elem.getAttribute('data-driver');
            var battery = elem.getAttribute('data-battery');
            var weight = elem.getAttribute('data-weight');

            document.getElementById('modal_prod_name').textContent = elem.getAttribute('data-name');
            document.getElementById('modal_prod_brand').textContent = elem.getAttribute('data-brand');
            document.getElementById('modal_prod_category').textContent = elem.getAttribute('data-category');
            document.getElementById('modal_prod_price').textContent = '$' + elem.getAttribute('data-price');
            document.getElementById('modal_prod_qty').textContent = 'x' + elem.getAttribute('data-qty');
            document.getElementById('modal_prod_total').textContent = '$' + elem.getAttribute('data-total');
            document.getElementById('modal_prod_img').src = elem.getAttribute('data-img');
            document.getElementById('modal_prod_desc').textContent = elem.getAttribute('data-desc');
            document.getElementById('modal_prod_conn').textContent = elem.getAttribute('data-conn');
            document.getElementById('modal_prod_driver').textContent = (driver && driver !== 'Standard') ? driver + ' mm' : 'Standard';
            document.getElementById('modal_prod_anc').textContent = elem.getAttribute('data-anc');
            document.getElementById('modal_prod_battery').textContent = (battery && battery !== 'Wired / N/A') ? battery + ' hours' : 'Wired / N/A';
            document.getElementById('modal_prod_mic').textContent = elem.getAttribute('data-mic');
            document.getElementById('modal_prod_water').textContent = elem.getAttribute('data-water');
            document.getElementById('modal_prod_weight').textContent = (weight && weight !== 'N/A') ? weight + ' g' : 'N/A';

            $('#orderedProductModal').modal('show');
        }
    </script>
</body>
</html>
