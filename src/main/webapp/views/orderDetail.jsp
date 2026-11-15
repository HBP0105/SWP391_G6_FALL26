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
    <title>Order Details #ORD-${requestScope.order.orderId} - Headphone Store</title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Main Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />

    <!-- Custom Order Detail Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/orderDetail.css" />
</head>
<body>
    <!-- HEADER (dùng chung với trang Home) -->
    <c:set var="activeNav" value="my-orders" scope="request" />
    <jsp:include page="/assets/components/header.jsp" />

    <c:set var="order" value="${requestScope.order}" />

    <div class="section order-detail-section">
        <div class="container">
            <!-- Nút quay lại My Orders -->
            <div class="detail-top-actions">
                <a href="${pageContext.request.contextPath}/my-orders" class="btn btn-default btn-sm">
                    &laquo; Back to My Orders
                </a>
                <c:if test="${order.orderStatus eq 'SHIPPING'}">
                    <button type="button" class="btn btn-success btn-sm" style="margin-left: 5px;"
                            data-toggle="modal" data-target="#receivedDetailModal">
                        <i class="fa fa-check-circle"></i> Order Received
                    </button>
                </c:if>    
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
            <!-- ORDER DELIVERED SUCCESS ALERT -->
            <c:if test="${param.deliveredSuccess eq 'true'}">
                <div class="alert alert-success">
                    <i class="fa fa-check-circle"></i> <strong>Order Completed!</strong> Order <strong>#ORD-${order.orderId}</strong> has been marked as <strong>DELIVERED</strong>. Thank you for shopping with us!
                </div>
            </c:if>        
            <!-- KHỐI 1: TIÊU ĐỀ ĐƠN HÀNG & TIẾN TRÌNH TRẠNG THÁI -->
            <div class="detail-box">
                <div class="detail-header-row">
                    <div>
                        <h4 class="detail-title">Order Details: #ORD-${order.orderId}</h4>
                        <span class="text-muted detail-date">Placed on: ${order.orderDate}</span>
                    </div>
                    <div>
                        <strong>Status: </strong>
                        <span class="label ${order.orderStatus eq 'CANCELLED' ? 'label-danger' : (order.orderStatus eq 'DELIVERED' ? 'label-success' : 'label-info')} detail-status-label">
                            ${order.orderStatus}
                        </span>
                    </div>
                </div>

                <!-- Thanh tiến trình 4 bước (Ẩn nếu đơn đã bị hủy) -->
                <c:choose>
                    <c:when test="${order.orderStatus eq 'CANCELLED'}">
                        <p class="text-danger detail-cancelled-msg">
                            This order has been cancelled.
                            <c:if test="${not empty order.cancelReason}">
                                <br><span style="font-size: 13px; color: #555;"><strong>Cancellation Reason:</strong> <c:out value="${order.cancelReason}" /></span>
                            </c:if>
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
                    <div class="detail-box detail-info-card">
                        <h5 class="detail-box-heading">
                            Shipping & Delivery Information
                        </h5>
                        <p class="detail-line"><strong>Customer:</strong> ${sessionScope.customer.fullName} (${sessionScope.customer.phone})</p>
                        <p class="detail-line"><strong>Shipping Address:</strong> ${order.shippingAddress}</p>
                        <p class="detail-line">
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
                            <p class="detail-line"><strong>Carrier:</strong> ${order.shippingProvider} | <strong>Tracking No:</strong> ${order.trackingNumber}</p>
                        </c:if>
                        <c:if test="${not empty order.estimatedDeliveryDate}">
                            <p class="detail-line-last"><strong>Estimated Delivery:</strong> ${order.estimatedDeliveryDate}</p>
                        </c:if>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="detail-box detail-info-card">
                        <h5 class="detail-box-heading">
                            Payment Summary
                        </h5>
                        <p class="detail-line">
                            <strong>Payment Method:</strong>
                            ${order.paymentMethod eq 'VNPAY' ? 'VNPay Online' : 'Cash on Delivery (COD)'}
                        </p>
                        <p class="detail-line">
                            <strong>Payment Status:</strong>
                            ${not empty order.paymentStatus ? order.paymentStatus : 'PENDING'}
                        </p>
                        <c:if test="${not empty order.transactionId}">
                            <p class="detail-line"><strong>VNPay Transaction No:</strong> ${order.transactionId}</p>
                        </c:if>
                        <c:if test="${not empty order.paymentDate}">
                            <p class="detail-line"><strong>Payment Time:</strong> ${order.paymentDate}</p>
                        </c:if>
                        <p class="detail-total-row">
                            <strong>Total Amount:</strong>
                            <span class="detail-total-price">$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /></span>
                        </p>
                    </div>
                </div>
            </div>

            <!-- KHỐI 3: DANH SÁCH SẢN PHẨM & THÔNG SỐ KỸ THUẬT CHI TIẾT -->
            <div class="detail-box">
                <h5 class="detail-box-heading-lg">
                    Ordered Products & Specifications (${order.items.size()})
                </h5>

                <div class="table-responsive">
                    <table class="table table-bordered detail-products-table">
                        <thead>
                            <tr class="detail-table-head">
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
                                    <td class="text-center align-middle">
                                        <c:choose>
                                            <c:when test="${not empty item.imageUrl}">
                                                <img src="${fn:startsWith(item.imageUrl, 'http') ? item.imageUrl : pageContext.request.contextPath.concat('/').concat(item.imageUrl)}" class="product-thumb" alt="${item.productName}"
                                                     onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/product01.png';">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/assets/img/product01.png" class="product-thumb" alt="${item.productName}">
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <strong class="detail-prod-name">${item.productName}</strong>
                                        <div class="text-muted detail-prod-meta">
                                            Brand: <strong>${not empty item.brandName ? item.brandName : 'N/A'}</strong> |
                                            Category: <strong>${not empty item.categoryName ? item.categoryName : 'Headphone'}</strong>
                                        </div>
                                        <c:if test="${not empty item.description}">
                                            <p class="detail-prod-desc">${item.description}</p>
                                        </c:if>
                                        <div class="detail-prod-specs">
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
                                    <td class="text-right align-middle">
                                        $<fmt:formatNumber value="${item.price}" pattern="#,##0" />
                                    </td>
                                    <td class="text-center align-middle">
                                        x${item.quantity}
                                    </td>
                                    <td class="text-right align-middle">
                                        <strong class="detail-subtotal-price">$<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0" /></strong>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL CANCEL ORDER WITH REASONS -->
    <div id="cancelDetailModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content" style="border-radius: 6px; overflow: hidden; border: none; box-shadow: 0 5px 25px rgba(0,0,0,0.2);">
                <form action="${pageContext.request.contextPath}/order-detail" method="POST" id="cancelDetailForm" onsubmit="return validateDetailCancel();">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="orderId" value="${order.orderId}">

                    
                    <div class="modal-header" style="background-color: #D10024; color: #fff; padding: 15px 20px;">
                        <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.9; font-size: 24px;">&times;</button>
                        <h4 class="modal-title" style="font-weight: 700; color: #fff;">
                            <i class="fa fa-times-circle"></i> Cancel Order #ORD-${order.orderId}
                        </h4>
                    </div>

                    <div class="modal-body" style="padding: 20px;">
                        <p class="text-muted" style="margin-bottom: 15px; font-size: 13px;">
                            Please specify the reason for cancelling this order. This reason will be logged into system records.
                        </p>

                        
                        <div class="form-group">
                            <label style="font-weight: 600; font-size: 13px;">Select Cancellation Reason: <span class="text-danger">*</span></label>
                            <select class="form-control" id="detailPresetReason" onchange="onDetailPresetReasonChange();" style="height: 40px; font-size: 13px;">
                                <option value="">-- Choose a cancellation reason --</option>
                                <option value="Change of mind / No longer needed">Change of mind / No longer needed</option>
                                <option value="Need to change shipping address or phone number">Need to change shipping address or phone number</option>
                                <option value="Want to change payment method">Want to change payment method</option>
                                <option value="Found a better price elsewhere">Found a better price elsewhere</option>
                                <option value="Ordered by mistake / Duplicate order">Ordered by mistake / Duplicate order</option>
                                <option value="Delivery time takes too long">Delivery time takes too long</option>
                                <option value="OTHER">Other reason (Type specific reason below)...</option>
                            </select>
                        </div>

                        <!-- Ô nhập lý do chi tiết -->
                        <div class="form-group" style="margin-bottom: 0;">
                            <label style="font-weight: 600; font-size: 13px;">
                                Detailed Reason / Note: <span id="detailReasonAsterisk" class="text-danger" style="display: none;">*</span>
                            </label>
                            <textarea class="form-control" name="cancelReason" id="detailCancelReasonText" rows="3" 
                                      placeholder="Enter detailed reason for cancellation..." style="resize: vertical; font-size: 13px;"></textarea>
                        </div>
                    </div>

                    <div class="modal-footer" style="background-color: #f8f9fa; border-top: 1px solid #eee; padding: 12px 20px;">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-danger" style="background-color: #D10024; border-color: #D10024; font-weight: 600;">
                            <i class="fa fa-times"></i> Confirm Cancellation
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- MODAL CONFIRM ORDER RECEIVED -->
    <div id="receivedDetailModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-sm" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Confirm Received</h4>
                </div>
                <form action="${pageContext.request.contextPath}/order-detail" method="POST" class="modal-form-clean">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="received">
                        <input type="hidden" name="orderId" value="${order.orderId}">
                        <p class="modal-confirm-text">Have you received order <strong>#ORD-${order.orderId}</strong> in good condition?</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">No</button>
                        <button type="submit" class="btn btn-success">Yes, Received</button>
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
    <script>
        function onDetailPresetReasonChange() {
            var preset = document.getElementById('detailPresetReason').value;
            var reasonInput = document.getElementById('detailCancelReasonText');
            var asterisk = document.getElementById('detailReasonAsterisk');

            if (preset === 'OTHER') {
                reasonInput.value = '';
                reasonInput.focus();
                asterisk.style.display = 'inline';
            } else if (preset) {
                reasonInput.value = preset;
                asterisk.style.display = 'none';
            } else {
                reasonInput.value = '';
                asterisk.style.display = 'none';
            }
        }

        function validateDetailCancel() {
            var reason = document.getElementById('detailCancelReasonText').value.trim();
            if (!reason) {
                alert('Please select or enter a reason for cancelling the order!');
                document.getElementById('detailPresetReason').focus();
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
