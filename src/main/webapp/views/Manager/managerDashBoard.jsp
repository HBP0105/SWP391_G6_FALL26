<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="Headphone Store Manager Dashboard">
        <title>Manager Dashboard | Headphone Store</title>

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

            <aside class="admin-sidebar" id="adminSidebar" aria-label="Main navigation">

                <div class="sidebar-header">
                    <a class="brand-mark"
                       href="${pageContext.request.contextPath}/Manager/Dashboard">

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
                                    aria-label="Switch color theme">

                                <i class="bi bi-moon-stars"
                                   data-theme-icon></i>

                            </button>


                            <!-- Notification -->
                            <div class="dropdown">

                                <button class="icon-button"
                                        type="button"
                                        data-bs-toggle="dropdown"
                                        aria-expanded="false"
                                        aria-label="Notifications">

                                    <span class="notification-dot"></span>

                                    <i class="bi bi-bell"></i>

                                </button>


                                <div class="dropdown-menu dropdown-menu-end notification-menu">

                                    <div class="dropdown-header fw-bold text-body">
                                        Notifications
                                    </div>

                                    <c:choose>
                                        <c:when test="${not empty notifications}">
                                            <c:forEach var="notification" items="${notifications}" begin="0" end="2">
                                                <a class="dropdown-item" href="${not empty notification.link ? notification.link : '#'}">
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
                                            <span class="dropdown-item text-muted">
                                                No new notifications.
                                            </span>
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


                <main class="dashboard-content">

                    <div class="container-fluid px-3 px-lg-4 py-4">


                        <div class="page-heading mb-4">

                            <div class="page-heading-copy">

                                <span class="page-icon">
                                    <i class="bi bi-speedometer2"></i>
                                </span>

                                <div>

                                    <p class="eyebrow mb-1">
                                        Manager
                                    </p>

                                    <h1 class="h3 mb-1">
                                        Dashboard
                                    </h1>

                                    <p class="text-muted mb-0">
                                        Overview of your headphone store.
                                    </p>

                                </div>

                            </div>

                        </div>

                        <div class="row g-3 mb-4">

                            <div class="col-12 col-md-6 col-xl-3">

                                <div class="panel h-100">

                                    <div class="d-flex justify-content-between align-items-start">

                                        <div>

                                            <p class="text-muted mb-1">
                                                Total Products
                                            </p>

                                            <h2 class="h3 mb-1">
                                                ${totalProducts}
                                            </h2>

                                            <small class="text-success">
                                                <i class="bi bi-arrow-up"></i>
                                                ${newProductsThisMonth} new this month
                                            </small>

                                        </div>

                                        <span class="page-icon">
                                            <i class="bi bi-box-seam"></i>
                                        </span>

                                    </div>

                                </div>

                            </div>

                            <div class="col-12 col-md-6 col-xl-3">

                                <div class="panel h-100">

                                    <div class="d-flex justify-content-between align-items-start">

                                        <div>

                                            <p class="text-muted mb-1">
                                                Total Orders
                                            </p>

                                            <h2 class="h3 mb-1">
                                                ${totalOrders}
                                            </h2>

                                            <small class="text-success">
                                                <i class="bi bi-arrow-up"></i>
                                                ${orderGrowthPercent}% this month
                                            </small>

                                        </div>

                                        <span class="page-icon">
                                            <i class="bi bi-cart-check"></i>
                                        </span>

                                    </div>

                                </div>

                            </div>

                            <div class="col-12 col-md-6 col-xl-3">

                                <div class="panel h-100">

                                    <div class="d-flex justify-content-between align-items-start">

                                        <div>

                                            <p class="text-muted mb-1">
                                                Revenue
                                            </p>

                                            <h2 class="h3 mb-1">
                                            </h2>

                                            <small class="text-success">
                                                <i class="bi bi-arrow-up"></i>
                                            </small>

                                        </div>

                                        <span class="page-icon">
                                            <i class="bi bi-cash-stack"></i>
                                        </span>

                                    </div>

                                </div>

                            </div>

                            <div class="col-12 col-md-6 col-xl-3">

                                <div class="panel h-100">

                                    <div class="d-flex justify-content-between align-items-start">

                                        <div>

                                            <p class="text-muted mb-1">
                                                Low Stock
                                            </p>

                                            <h2 class="h3 mb-1">
                                                ${lowStockProducts}
                                            </h2>

                                            <small class="text-danger">
                                                <i class="bi bi-exclamation-triangle"></i>
                                                Need attention
                                            </small>

                                        </div>

                                        <span class="page-icon">
                                            <i class="bi bi-exclamation-triangle"></i>
                                        </span>

                                    </div>

                                </div>

                            </div>

                        </div>

                        <section class="panel mb-4">

                            <div class="panel-header">

                                <div>

                                    <h2 class="h5 mb-1 section-title">

                                        <i class="bi bi-lightning-charge"></i>

                                        <span>Quick Actions</span>

                                    </h2>

                                    <p class="text-muted mb-0">
                                        Common manager operations.
                                    </p>

                                </div>

                            </div>

                            <div class="row g-3">

                                <div class="col-12 col-md-4">

                                    <a href="${pageContext.request.contextPath}/Manager/products?action=add"
                                       class="btn btn-success w-100">

                                        <i class="bi bi-plus-lg me-1"></i>
                                        Add Product

                                    </a>

                                </div>

                                <div class="col-12 col-md-4">

                                    <a href="${pageContext.request.contextPath}/Manager/products"
                                       class="btn btn-light w-100">

                                        <i class="bi bi-box-seam me-1"></i>
                                        Manage Products

                                    </a>

                                </div>

                                <div class="col-12 col-md-4">

                                    <a href="${pageContext.request.contextPath}/Manager/OrderManagement"
                                       class="btn btn-light w-100">

                                        <i class="bi bi-cart-check me-1"></i>
                                        Manage Orders

                                    </a>

                                </div>

                            </div>

                        </section>

                        <section class="panel">

                            <div class="panel-header">

                                <div>

                                    <h2 class="h5 mb-1 section-title">

                                        <i class="bi bi-clock-history"></i>

                                        <span>Recent Orders</span>

                                    </h2>

                                    <p class="text-muted mb-0">
                                        Latest customer orders.
                                    </p>

                                </div>


                                <a href="${pageContext.request.contextPath}/Manager/OrderManagement"
                                   class="btn btn-light btn-sm">

                                    View All

                                </a>

                            </div>


                            <div class="table-responsive">

                                <table class="table align-middle mb-0">

                                    <thead>

                                        <tr>

                                            <th>Order</th>
                                            <th>Customer</th>
                                            <th>Amount</th>
                                            <th>Status</th>
                                            <th>Date</th>

                                        </tr>

                                    </thead>

                                    <tbody>

                                        <c:choose>

                                            <c:when test="${not empty recentOrders}">

                                                <c:forEach var="order" items="${recentOrders}">

                                                    <tr>

                                                        <td class="fw-semibold">
                                                            #${order.orderID}
                                                        </td>

                                                        <td>
                                                            ${order.customerName}
                                                        </td>

                                                        <td>
                                                            <fmt:formatNumber value="${order.totalAmount}" type="number" maxFractionDigits="0"/>
                                                        </td>

                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${order.orderStatus == 'DELIVERED'}">
                                                                    <span class="badge text-bg-success">Delivered</span>
                                                                </c:when>
                                                                <c:when test="${order.orderStatus == 'PENDING'}">
                                                                    <span class="badge text-bg-warning">Pending</span>
                                                                </c:when>
                                                                <c:when test="${order.orderStatus == 'SHIPPING'}">
                                                                    <span class="badge text-bg-info">Shipping</span>
                                                                </c:when>
                                                                <c:when test="${order.orderStatus == 'CANCELLED'}">
                                                                    <span class="badge text-bg-danger">Cancelled</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge text-bg-secondary">${order.orderStatus}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>

                                                        <td>
                                                            ${order.formattedDate}                                                        </td>

                                                    </tr>

                                                </c:forEach>

                                            </c:when>

                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="5" class="text-center py-4 text-muted">
                                                        No recent orders.
                                                    </td>
                                                </tr>
                                            </c:otherwise>

                                        </c:choose>

                                    </tbody>

                                </table>

                            </div>

                        </section>

                    </div>

                </main>

                <footer class="admin-footer">

                    <div class="container-fluid px-3 px-lg-4">

                        <span>
                            Copyright 2026 Headphone Store.
                            <br>
                            Manager Dashboard
                        </span>

                        <span>
                            Headphone Store E-commerce System.
                        </span>

                    </div>

                </footer>

            </div>

        </div>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>
    </body>

</html>