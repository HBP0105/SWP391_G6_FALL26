<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Order Details #ORD-${requestScope.order.orderId} - Headphone Store</title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Main Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />

    <style>
        .detail-box {
            background: #fff;
            border: 1px solid #E4E7ED;
            border-radius: 4px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .step-wizard {
            display: flex;
            justify-content: space-between;
            margin: 15px 0 5px 0;
            padding: 0;
            list-style: none;
        }
        .step-item {
            flex: 1;
            text-align: center;
            padding: 10px 5px;
            border-bottom: 4px solid #E4E7ED;
            color: #888;
            font-size: 13px;
            font-weight: 600;
        }
        .step-item.completed {
            border-bottom-color: #28a745;
            color: #155724;
        }
        .step-item.current {
            border-bottom-color: #D10024;
            color: #D10024;
        }
        .product-thumb {
            width: 80px;
            height: 80px;
            object-fit: contain;
            border: 1px solid #E4E7ED;
            padding: 4px;
            background: #fff;
        }
    </style>
</head>
<body>
    <!-- HEADER -->
    <header>
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
                    <li><a href="#"><i class="fa fa-phone"></i> <%= displayPhone %></a></li>
                    <% } %>
                    <% if (!displayEmail.isEmpty()) { %>
                    <li><a href="#"><i class="fa fa-envelope-o"></i> <%= displayEmail %></a></li>
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

        <div id="header">
            <div class="container">
                <div class="row">
                    <div class="col-md-3">
                        <div class="header-logo">
                            <a href="${pageContext.request.contextPath}/home" class="logo">
                                <img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="Logo">
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
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

    <c:set var="order" value="${requestScope.order}" />

    <div class="section" style="padding-top: 30px; padding-bottom: 60px;">
        <div class="container">
            <!-- Nút quay lại My Orders -->
            <div style="margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center;">
                <a href="${pageContext.request.contextPath}/my-orders" class="btn btn-default btn-sm">
                    &laquo; Back to My Orders
                </a>
                <c:if test="${order.orderStatus eq 'PENDING' or order.orderStatus eq 'CONFIRMED'}">
                    <button type="button" class="btn btn-danger btn-sm" data-toggle="modal" data-target="#cancelDetailModal">
                        Cancel This Order
                    </button>
                </c:if>
            </div>

            <c:if test="${param.cancelSuccess eq 'true'}">
                <div class="alert alert-warning">
                    <strong>Order Cancelled!</strong> Order <strong>#ORD-${order.orderId}</strong> has been cancelled.
                </div>
            </c:if>

            <!-- KHỐI 1: TIÊU ĐỀ ĐƠN HÀNG & TIẾN TRÌNH TRẠNG THÁI -->
            <div class="detail-box">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #eee; padding-bottom: 12px;">
                    <div>
                        <h4 style="margin: 0;">Order Details: #ORD-${order.orderId}</h4>
                        <span class="text-muted" style="font-size: 13px;">Placed on: ${order.orderDate}</span>
                    </div>
                    <div>
                        <strong>Status: </strong>
                        <span class="label ${order.orderStatus eq 'CANCELLED' ? 'label-danger' : (order.orderStatus eq 'DELIVERED' ? 'label-success' : 'label-info')}" style="font-size: 13px; padding: 5px 10px;">
                            ${order.orderStatus}
                        </span>
                    </div>
                </div>

                <!-- Thanh tiến trình 4 bước (Ẩn nếu đơn đã bị hủy) -->
                <c:choose>
                    <c:when test="${order.orderStatus eq 'CANCELLED'}">
                        <p class="text-danger" style="margin: 15px 0 0 0; font-weight: 600;">
                            This order has been cancelled.
                        </p>
                    </c:when>
                    <c:otherwise>
                        <ul class="step-wizard">
                            <li class="step-item ${order.orderStatus eq 'PENDING' ? 'current' : 'completed'}">
                                1. Pending Confirmation
                            </li>
                            <li class="step-item ${order.orderStatus eq 'CONFIRMED' ? 'current' : (order.orderStatus eq 'SHIPPING' or order.orderStatus eq 'DELIVERED' ? 'completed' : '')}">
                                2. Confirmed
                            </li>
                            <li class="step-item ${order.orderStatus eq 'SHIPPING' ? 'current' : (order.orderStatus eq 'DELIVERED' ? 'completed' : '')}">
                                3. Shipping
                            </li>
                            <li class="step-item ${order.orderStatus eq 'DELIVERED' ? 'completed' : ''}">
                                4. Delivered
                            </li>
                        </ul>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- KHỐI 2: THÔNG TIN GIAO HÀNG & THÔNG TIN THANH TOÁN -->
            <div class="row">
                <div class="col-md-6">
                    <div class="detail-box" style="min-height: 190px;">
                        <h5 style="margin-top: 0; border-bottom: 1px solid #eee; padding-bottom: 8px; font-weight: 700;">
                            Shipping & Delivery Information
                        </h5>
                        <p style="margin-bottom: 6px;"><strong>Customer:</strong> ${sessionScope.customer.fullName} (${sessionScope.customer.phone})</p>
                        <p style="margin-bottom: 6px;"><strong>Shipping Address:</strong> ${order.shippingAddress}</p>
                        <p style="margin-bottom: 6px;">
                            <strong>Delivery Person (Shipper):</strong>
                            <c:choose>
                                <c:when test="${order.shippingName ne 'Unassigned' && not empty order.shippingName}">
                                    ${order.shippingName} (${order.shippingPhone})
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Awaiting assignment</span>
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <c:if test="${not empty order.shippingProvider}">
                            <p style="margin-bottom: 6px;"><strong>Carrier:</strong> ${order.shippingProvider} | <strong>Tracking No:</strong> ${order.trackingNumber}</p>
                        </c:if>
                        <c:if test="${not empty order.estimatedDeliveryDate}">
                            <p style="margin-bottom: 0;"><strong>Estimated Delivery:</strong> ${order.estimatedDeliveryDate}</p>
                        </c:if>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="detail-box" style="min-height: 190px;">
                        <h5 style="margin-top: 0; border-bottom: 1px solid #eee; padding-bottom: 8px; font-weight: 700;">
                            Payment Summary
                        </h5>
                        <p style="margin-bottom: 6px;">
                            <strong>Payment Method:</strong>
                            ${order.paymentMethod eq 'VNPAY' ? 'VNPay Online' : 'Cash on Delivery (COD)'}
                        </p>
                        <p style="margin-bottom: 6px;">
                            <strong>Payment Status:</strong>
                            ${not empty order.paymentStatus ? order.paymentStatus : 'PENDING'}
                        </p>
                        <c:if test="${not empty order.transactionId}">
                            <p style="margin-bottom: 6px;"><strong>VNPay Transaction No:</strong> ${order.transactionId}</p>
                        </c:if>
                        <c:if test="${not empty order.paymentDate}">
                            <p style="margin-bottom: 6px;"><strong>Payment Time:</strong> ${order.paymentDate}</p>
                        </c:if>
                        <p style="margin-bottom: 0; font-size: 16px;">
                            <strong>Total Amount:</strong>
                            <span style="color: #D10024; font-weight: 700;">$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /></span>
                        </p>
                    </div>
                </div>
            </div>

            <!-- KHỐI 3: DANH SÁCH SẢN PHẨM & THÔNG SỐ KỸ THUẬT CHI TIẾT -->
            <div class="detail-box">
                <h5 style="margin-top: 0; border-bottom: 1px solid #eee; padding-bottom: 10px; font-weight: 700;">
                    Ordered Products & Specifications (${order.items.size()})
                </h5>

                <div class="table-responsive">
                    <table class="table table-bordered" style="margin-bottom: 0;">
                        <thead>
                            <tr style="background: #f9f9f9;">
                                <th width="100" class="text-center">Image</th>
                                <th>Product Information & Technical Specifications</th>
                                <th width="130" class="text-right">Unit Price</th>
                                <th width="90" class="text-center">Qty</th>
                                <th width="140" class="text-right">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${order.items}" var="item">
                                <tr>
                                    <td class="text-center" style="vertical-align: middle;">
                                        <c:choose>
                                            <c:when test="${not empty item.imageUrl}">
                                                <img src="${item.imageUrl}" class="product-thumb" alt="${item.productName}"
                                                     onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/product01.png';">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/assets/img/product01.png" class="product-thumb" alt="${item.productName}">
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <strong style="font-size: 15px; color: #2B2D42;">${item.productName}</strong>
                                        <div class="text-muted" style="font-size: 12px; margin-bottom: 6px;">
                                            Brand: <strong>${not empty item.brandName ? item.brandName : 'N/A'}</strong> |
                                            Category: <strong>${not empty item.categoryName ? item.categoryName : 'Headphone'}</strong>
                                        </div>
                                        <c:if test="${not empty item.description}">
                                            <p style="font-size: 13px; color: #555; margin-bottom: 6px;">${item.description}</p>
                                        </c:if>
                                        <div style="font-size: 12px; color: #444; background: #f9f9f9; padding: 6px 10px; border-radius: 3px;">
                                            <strong>Specs:</strong>
                                            Connection: ${not empty item.connectionType ? item.connectionType : 'Standard'} |
                                            Driver: ${item.driverSize > 0 ? item.driverSize : 'Standard'} mm |
                                            ANC: ${item.noiseCancelling ? 'Yes' : 'No'} |
                                            Battery: ${item.batteryLife > 0 ? item.batteryLife : 'N/A'} hrs |
                                            Mic: ${item.microphone ? 'Yes' : 'No'} |
                                            Water Resistance: ${not empty item.waterResistance ? item.waterResistance : 'None'} |
                                            Weight: ${item.weight > 0 ? item.weight : 'N/A'} g
                                        </div>
                                    </td>
                                    <td class="text-right" style="vertical-align: middle;">
                                        $<fmt:formatNumber value="${item.price}" pattern="#,##0" />
                                    </td>
                                    <td class="text-center" style="vertical-align: middle;">
                                        x${item.quantity}
                                    </td>
                                    <td class="text-right" style="vertical-align: middle;">
                                        <strong style="color: #D10024;">$<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0" /></strong>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL XÁC NHẬN HỦY ĐƠN -->
    <div id="cancelDetailModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-sm" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Cancel Order</h4>
                </div>
                <form action="${pageContext.request.contextPath}/order-detail" method="POST" style="margin: 0;">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="orderId" value="${order.orderId}">
                        <p style="margin: 0;">Are you sure you want to cancel order <strong>#ORD-${order.orderId}</strong>?</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">No</button>
                        <button type="submit" class="btn btn-danger">Yes, Cancel</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

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

    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
