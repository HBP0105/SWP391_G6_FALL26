<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="Headphone Store Manager">
        <title>Order Management | Headphone Store</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css">
    </head>

    <body>

        <div class="admin-shell">

            <div class="sidebar-backdrop" data-sidebar-close></div>

            <!-- ================= SIDEBAR ================= -->
            <aside class="admin-sidebar" id="adminSidebar" aria-label="Main navigation">

                <div class="sidebar-header">
                    <a class="brand-mark"
                       href="${pageContext.request.contextPath}/Manager/Dashboard"
                       aria-label="Headphone Store Manager">

                        <span class="brand-icon">
                            <i class="bi bi-headphones" aria-hidden="true"></i>
                        </span>

                        <span class="brand-copy">
                            <span class="brand-title">Headphone Store</span>
                            <span class="brand-subtitle">Manager Panel</span>
                        </span>

                    </a>
                </div>


                <nav class="sidebar-nav">

                    <a class="nav-link ${activePage == 'dashboard' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Dashboard">

                        <span class="nav-icon">
                            <i class="bi bi-speedometer2"></i>
                        </span>

                        <span class="nav-text">
                            Dashboard
                        </span>

                    </a>

                    <a class="nav-link ${activePage == 'products' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/products">

                        <span class="nav-icon">
                            <i class="bi bi-box-seam"></i>
                        </span>

                        <span class="nav-text">
                            Products
                        </span>

                    </a>

                    <a class="nav-link ${activePage == 'orders' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/OrderManagement">

                        <span class="nav-icon">
                            <i class="bi bi-cart-check"></i>
                        </span>

                        <span class="nav-text">
                            Orders
                        </span>

                    </a>

                    <a class="nav-link ${activePage == 'inventory' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Inventory">

                        <span class="nav-icon">
                            <i class="bi bi-boxes"></i>
                        </span>

                        <span class="nav-text">
                            Inventory
                        </span>

                    </a>

                    <a class="nav-link ${activePage == 'voucher' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Voucher">

                        <span class="nav-icon">
                            <i class="bi bi-ticket-perforated"></i>
                        </span>

                        <span class="nav-text">
                            Vouchers
                        </span>

                    </a>

                    <a class="nav-link ${activePage == 'reports' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Report">

                        <span class="nav-icon">
                            <i class="bi bi-bar-chart-line"></i>
                        </span>

                        <span class="nav-text">
                            Reports
                        </span>

                    </a>

                    <a class="nav-link ${activePage == 'profile' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Profile">

                        <span class="nav-icon">
                            <i class="bi bi-person-badge"></i>
                        </span>

                        <span class="nav-text">
                            Profile
                        </span>

                    </a>

                </nav>

                <div class="sidebar-footer">

                    <span class="status-dot"></span>

                    <span class="sidebar-footer-text">
                        System running smoothly
                    </span>

                </div>

            </aside>


            <div class="admin-main">


                <nav class="navbar admin-navbar navbar-expand bg-white">

                    <div class="container-fluid px-3 px-lg-4">

                        <button class="sidebar-toggle"
                                type="button"
                                data-sidebar-toggle
                                aria-controls="adminSidebar"
                                aria-expanded="true"
                                aria-label="Toggle sidebar">

                            <span></span>
                            <span></span>
                            <span></span>

                        </button>





                        <div class="navbar-actions ms-auto">


                            <!-- Theme -->
                            <button class="icon-button theme-toggle"
                                    type="button"
                                    data-theme-toggle
                                    aria-label="Switch color theme"
                                    title="Switch color theme">

                                <i class="bi bi-moon-stars"
                                   data-theme-icon
                                   aria-hidden="true"></i>

                            </button>


                            <div class="dropdown">

                                <button class="icon-button"
                                        type="button"
                                        data-bs-toggle="dropdown"
                                        aria-expanded="false"
                                        aria-label="Notifications">

                                    <span class="notification-dot"></span>

                                    <i class="bi bi-bell"
                                       aria-hidden="true"></i>

                                </button>


                                <div class="dropdown-menu dropdown-menu-end notification-menu">

                                    <div class="dropdown-header fw-bold text-body">
                                        Notifications
                                    </div>
                                    <c:choose>
                                        <c:when test="${not empty notifications}">
                                            <c:forEach var="notification" items="${notifications}" begin="0" end="2">
                                                <a class="dropdown-item"
                                                   href="${not empty notification.link ? notification.link : '#'}">
                                                    <span class="notification-title">
                                                        ${notification.message}
                                                    </span>
                                                    <span class="notification-time">
                                                        ${notification.timeAgo}
                                                    </span>
                                                </a>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="dropdown-item text-muted">No new notifications.</span>
                                        </c:otherwise>
                                    </c:choose>

                                </div>

                            </div>


                            <div class="dropdown">

                                <button class="profile-button dropdown-toggle"
                                        type="button"
                                        data-bs-toggle="dropdown"
                                        aria-expanded="false">

                                    <img class="avatar-img avatar-sm"
                                         src="${pageContext.request.contextPath}/assets/Admin_Manager/images/avatar/gumball.jpg"
                                         alt="Manager">

                                    <span class="profile-name d-none d-sm-inline">
                                        Manager
                                    </span>

                                </button>


                                <ul class="dropdown-menu dropdown-menu-end">

                                    <li>
                                        <a class="dropdown-item"
                                           href="${pageContext.request.contextPath}/Manager/Profile">
                                            Profile
                                        </a>
                                    </li>

                                    <li>
                                        <a class="dropdown-item"
                                           href="${pageContext.request.contextPath}/logout">
                                            Sign out
                                        </a>
                                    </li>

                                </ul>

                            </div>

                        </div>

                    </div>

                </nav>


                <!-- ================= CONTENT ================= -->
                <main class="dashboard-content">

                    <div class="container-fluid px-3 px-lg-4 py-4">


                        <!-- PAGE HEADING -->
                        <div class="page-heading">

                            <div class="page-heading-copy">

                                <span class="page-icon">
                                    <i class="bi bi-cart-check"
                                       aria-hidden="true"></i>
                                </span>


                                <div>

                                    <p class="eyebrow mb-1">
                                        Manager
                                    </p>

                                    <h1 class="h3 mb-1">
                                        Order Management
                                    </h1>

                                    <p class="text-muted mb-0">
                                        View and manage customer orders and order status.
                                    </p>

                                </div>

                            </div>

                        </div>


                        <!-- ================= ORDER TABLE ================= -->
                        <section class="panel">

                            <div class="panel-header">

                                <div>

                                    <h2 class="h5 mb-1 section-title">

                                        <i class="bi bi-cart-check"
                                           aria-hidden="true"></i>

                                        <span>Order List</span>

                                    </h2>

                                    <p class="text-muted mb-0">
                                        View and manage all customer orders.
                                    </p>

                                </div>


                                <!-- SEARCH -->
                                <input class="form-control form-control-sm table-search"
                                       type="search"
                                       placeholder="Search orders"
                                       data-table-search="ordersTable"
                                       aria-label="Search orders">

                            </div>


                            <div class="table-responsive">

                                <table class="table align-middle mb-0"
                                       id="ordersTable"
                                       data-searchable-table>

                                    <thead>

                                        <tr>

                                            <th>Order ID</th>

                                            <th>Customer</th>

                                            <th>Order Date</th>

                                            <th>Total Amount</th>

                                            <th>Payment</th>

                                            <th>Status</th>

                                            <th class="text-end">
                                                Action
                                            </th>

                                        </tr>

                                    </thead>


                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty orders}">
                                                <c:forEach var="order" items="${orders}">
                                                    <tr>
                                                        <td class="fw-semibold">
                                                            #${order.orderID}
                                                        </td>
                                                        <td>
                                                            ${order.customerName}
                                                        </td>
                                                        <td>
                                                            <fmt:formatDate value="${order.orderDate}" pattern="dd/MM/yyyy"/>
                                                        </td>
                                                        <td>
                                                            $<fmt:formatNumber value="${order.totalAmount}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${order.paymentStatus eq 'SUCCESS'}">
                                                                    <span class="badge text-bg-success">Paid</span>
                                                                </c:when>
                                                                <c:when test="${order.paymentStatus eq 'FAILED' or order.paymentStatus eq 'CANCELLED'}">
                                                                    <span class="badge text-bg-danger">${order.paymentStatus}</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge text-bg-warning">${order.paymentStatus}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${order.orderStatus eq 'PENDING'}">
                                                                    <span class="badge text-bg-warning">Pending</span>
                                                                </c:when>
                                                                <c:when test="${order.orderStatus eq 'CONFIRMED'}">
                                                                    <span class="badge text-bg-info">Processing</span>
                                                                </c:when>
                                                                <c:when test="${order.orderStatus eq 'SHIPPING'}">
                                                                    <span class="badge text-bg-primary">Shipped</span>
                                                                </c:when>
                                                                <c:when test="${order.orderStatus eq 'DELIVERED'}">
                                                                    <span class="badge text-bg-success">Completed</span>
                                                                </c:when>
                                                                <c:when test="${order.orderStatus eq 'CANCELLED'}">
                                                                    <span class="badge text-bg-danger">Cancelled</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge text-bg-secondary">${order.orderStatus}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="text-end">
                                                            <a href="${pageContext.request.contextPath}/Manager/OrderManagement?action=detail&id=${order.orderID}"
                                                               class="btn btn-sm btn-outline-primary">
                                                                <i class="bi bi-eye"></i>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="7" class="text-center text-muted py-4">
                                                        No orders found.
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose></tbody>

                                </table>

                            </div>

                        </section>

                    </div>

                </main>


                <!-- ================= FOOTER ================= -->
                <footer class="admin-footer">

                    <div class="container-fluid px-3 px-lg-4">

                        <span>
                            Copyright 2026 Headphone Store.
                            <br>
                            Manager Order Management
                        </span>

                        <span>
                            Headphone Store E-commerce System.
                        </span>

                    </div>

                </footer>

            </div>

        </div>


        <!-- ================= JS ================= -->

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>
    </body>

</html>