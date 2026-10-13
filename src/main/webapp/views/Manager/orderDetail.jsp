<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>Order Detail</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css">
    </head>

    <body>

        <div class="container-fluid py-4">

            <div class="d-flex justify-content-between align-items-center mb-4">

                <div>
                    <h2 class="mb-1">Order Detail</h2>
                    <p class="text-muted mb-0">
                        Order #${order.orderId}
                    </p>
                </div>

                <a href="${pageContext.request.contextPath}/Manager/OrderManagement"
                   class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left"></i>
                    Back to Orders
                </a>

            </div>


            <div class="panel mb-4">

                <h5 class="mb-3">
                    <i class="bi bi-receipt"></i>
                    Order Information
                </h5>

                <div class="row">

                    <div class="col-md-6 mb-3">
                        <strong>Order ID:</strong>
                        ${order.orderId}
                    </div>

                    <div class="col-md-6 mb-3">
                        <strong>Customer ID:</strong>
                        ${order.customerId}
                    </div>

                    <div class="col-md-6 mb-3">
                        <strong>Order Date:</strong>

                        <fmt:formatDate
                            value="${order.orderDate}"
                            pattern="yyyy-MM-dd HH:mm"/>
                    </div>

                    <div class="col-md-6 mb-3">
                        <strong>Status:</strong>

                        <span class="badge bg-warning">
                            ${order.orderStatus}
                        </span>
                    </div>

                </div>

            </div>


            <div class="panel mb-4">

                <h5 class="mb-3">
                    <i class="bi bi-truck"></i>
                    Shipping Information
                </h5>

                <div class="row">

                    <div class="col-md-4 mb-3">
                        <strong>Name</strong>
                        <div>${order.shippingName}</div>
                    </div>

                    <div class="col-md-4 mb-3">
                        <strong>Phone</strong>
                        <div>${order.shippingPhone}</div>
                    </div>

                    <div class="col-md-4 mb-3">
                        <strong>Address</strong>
                        <div>${order.shippingAddress}</div>
                    </div>

                </div>

            </div>


            <div class="panel mb-4">

                <h5 class="mb-3">
                    <i class="bi bi-box-seam"></i>
                    Order Items
                </h5>

                <div class="table-responsive">

                    <table class="table align-middle">

                        <thead>
                            <tr>
                                <th>Product ID</th>
                                <th>Product</th>
                                <th>Quantity</th>
                                <th>Unit Price</th>
                                <th>Subtotal</th>
                            </tr>
                        </thead>

                        <tbody>

                        <c:choose>

                            <c:when test="${not empty orderItems}">

                                <c:forEach var="item" items="${orderItems}">

                                    <tr>

                                        <td>
                                            ${item.productId}
                                        </td>

                                        <td>
                                            ${item.productName}
                                        </td>

                                        <td>
                                            ${item.quantity}
                                        </td>

                                        <td>
                                            ${item.unitPrice}
                                        </td>

                                        <td>
                                            ${item.subtotal}
                                        </td>

                                    </tr>

                                </c:forEach>

                            </c:when>

                            <c:otherwise>

                                <tr>
                                    <td colspan="5"
                                        class="text-center text-muted">
                                        No items found.
                                    </td>
                                </tr>

                            </c:otherwise>

                        </c:choose>

                        </tbody>

                    </table>

                </div>

            </div>


            <div class="panel mb-4">

                <h5 class="mb-3">
                    <i class="bi bi-credit-card"></i>
                    Payment Information
                </h5>

                <div class="row">

                    <div class="col-md-6 mb-3">
                        <strong>Payment ID:</strong>
                        ${order.paymentId}
                    </div>

                    <div class="col-md-6 mb-3">
                        <strong>Payment Method:</strong>
                        ${order.paymentMethod}
                    </div>

                    <div class="col-md-6 mb-3">
                        <strong>Transaction ID:</strong>
                        ${order.transactionId}
                    </div>

                    <div class="col-md-6 mb-3">
                        <strong>Payment Status:</strong>

                        <span class="badge bg-success">
                            ${order.paymentStatus}
                        </span>
                    </div>

                    <div class="col-md-6 mb-3">
                        <strong>Amount:</strong>
                        ${order.paymentAmount}
                    </div>

                    <div class="col-md-6 mb-3">
                        <strong>Payment Date:</strong>

                        <fmt:formatDate
                            value="${order.paymentDate}"
                            pattern="yyyy-MM-dd HH:mm"/>
                    </div>

                </div>

            </div>


            <div class="panel">

                <div class="d-flex justify-content-between align-items-center">

                    <h5 class="mb-0">
                        Total Amount
                    </h5>

                    <h3 class="mb-0">
                        ${order.totalAmount}
                    </h3>

                </div>

            </div>

        </div>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>

    </body>
</html>