<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">

    <head>

        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="Headphone Store Manager">

        <title>Product Detail | Headphone Store</title>

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

            <aside class="admin-sidebar"
                   id="adminSidebar"
                   aria-label="Main navigation">

                <div class="sidebar-header">

                    <a class="brand-mark"
                       href="${pageContext.request.contextPath}/Manager/Dashboard"
                       aria-label="Headphone Store Manager">

                        <span class="brand-icon">
                            <i class="bi bi-headphones" aria-hidden="true"></i>
                        </span>

                        <span class="brand-copy">

                            <span class="brand-title">
                                Headphone Store
                            </span>

                            <span class="brand-subtitle">
                                Manager Panel
                            </span>

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


            <!-- ================= MAIN ================= -->

            <div class="admin-main">


                <!-- ================= NAVBAR ================= -->

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


                            <!-- Notifications -->

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

                                            <c:forEach var="notification"
                                                       items="${notifications}"
                                                       begin="0"
                                                       end="2">

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

                                            <span class="dropdown-item text-muted">
                                                No new notifications.
                                            </span>

                                        </c:otherwise>

                                    </c:choose>

                                </div>

                            </div>


                            <!-- Profile -->

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


                        <!-- ================= PAGE HEADING ================= -->

                        <div class="page-heading">

                            <div class="page-heading-copy">

                                <span class="page-icon">

                                    <i class="bi bi-box-seam"
                                       aria-hidden="true"></i>

                                </span>


                                <div>

                                    <p class="eyebrow mb-1">
                                        Manager
                                    </p>

                                    <h1 class="h3 mb-1">
                                        Product Detail
                                    </h1>

                                    <p class="text-muted mb-0">
                                        View detailed information about this product.
                                    </p>

                                </div>

                            </div>


                            <div class="d-flex gap-2">

                                <c:choose>
                                    <c:when test="${from eq 'inventory'}">
                                        <a href="${pageContext.request.contextPath}/Manager/Inventory"
                                           class="btn btn-light">
                                            <i class="bi bi-arrow-left me-1"></i>
                                            Back to Inventory
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/Manager/products"
                                           class="btn btn-light">
                                            <i class="bi bi-arrow-left me-1"></i>
                                            Back to Products
                                        </a>
                                    </c:otherwise>
                                </c:choose>


                                <a href="${pageContext.request.contextPath}/Manager/products?action=edit&id=${product.productId}"
                                   class="btn btn-primary">

                                    <i class="bi bi-pencil me-1"></i>

                                    Edit Product

                                </a>

                            </div>

                        </div>


                        <!-- ================= PRODUCT OVERVIEW ================= -->

                        <section class="panel mb-4">

                            <div class="panel-header">

                                <div>

                                    <h2 class="h5 mb-1 section-title">

                                        <i class="bi bi-box-seam"
                                           aria-hidden="true"></i>

                                        <span>
                                            Product Overview
                                        </span>

                                    </h2>

                                    <p class="text-muted mb-0">
                                        Basic information about the selected product.
                                    </p>

                                </div>

                            </div>


                            <div class="p-3 p-lg-4">

                                <div class="row g-4">


                                    <!-- ================= IMAGE ================= -->

                                    <div class="col-lg-4">

                                        <c:choose>

                                            <c:when test="${not empty product.imageURL}">

                                                <div class="text-center">

                                                    <img src="${product.imageURL}"
                                                         alt="${product.productName}"
                                                         class="img-fluid rounded border"
                                                         style="max-height: 320px; object-fit: contain;">

                                                </div>

                                            </c:when>


                                            <c:otherwise>

                                                <div class="border rounded d-flex align-items-center justify-content-center"
                                                     style="height: 320px;">

                                                    <div class="text-muted text-center">

                                                        <i class="bi bi-image fs-1"></i>

                                                        <div class="mt-2">
                                                            No Image
                                                        </div>

                                                    </div>

                                                </div>

                                            </c:otherwise>

                                        </c:choose>

                                    </div>


                                    <!-- ================= BASIC INFO ================= -->

                                    <div class="col-lg-8">

                                        <h2 class="h4 mb-4">
                                            ${product.productName}
                                        </h2>


                                        <div class="row g-4">


                                            <!-- Product ID -->

                                            <div class="col-md-6">

                                                <div class="text-muted small mb-1">
                                                    Product ID
                                                </div>

                                                <div class="fw-semibold">
                                                    #${product.productId}
                                                </div>

                                            </div>


                                            <!-- Brand -->

                                            <div class="col-md-6">

                                                <div class="text-muted small mb-1">
                                                    Brand
                                                </div>

                                                <div class="fw-semibold">
                                                    ${product.brandName}
                                                </div>

                                            </div>


                                            <!-- Category -->

                                            <div class="col-md-6">

                                                <div class="text-muted small mb-1">
                                                    Category
                                                </div>

                                                <div class="fw-semibold">
                                                    ${product.categoryName}
                                                </div>

                                            </div>


                                            <!-- Status -->

                                            <div class="col-md-6">

                                                <div class="text-muted small mb-1">
                                                    Status
                                                </div>

                                                <div>

                                                    <c:choose>

                                                        <c:when test="${product.status eq 'ACTIVE'}">

                                                            <span class="badge text-bg-success">
                                                                Active
                                                            </span>

                                                        </c:when>


                                                        <c:when test="${product.status eq 'INACTIVE'}">

                                                            <span class="badge text-bg-secondary">
                                                                Inactive
                                                            </span>

                                                        </c:when>


                                                        <c:when test="${product.status eq 'OUT_OF_STOCK'}">

                                                            <span class="badge text-bg-danger">
                                                                Out of Stock
                                                            </span>

                                                        </c:when>


                                                        <c:otherwise>

                                                            <span class="badge text-bg-secondary">
                                                                ${product.status}
                                                            </span>

                                                        </c:otherwise>

                                                    </c:choose>

                                                </div>

                                            </div>


                                            <!-- Price -->

                                            <div class="col-md-6">

                                                <div class="text-muted small mb-1">
                                                    Price
                                                </div>

                                                <div class="fw-semibold fs-5">

                                                    <fmt:formatNumber
                                                        value="${product.price}"
                                                        type="number"
                                                        groupingUsed="true"/>

                                                    VND

                                                </div>

                                            </div>


                                            <!-- Stock -->

                                            <div class="col-md-6">

                                                <div class="text-muted small mb-1">
                                                    Stock Quantity
                                                </div>

                                                <div class="fw-semibold fs-5">

                                                    <c:choose>

                                                        <c:when test="${product.stockQuantity == 0}">

                                                            <span class="text-danger">
                                                                0
                                                            </span>

                                                        </c:when>


                                                        <c:when test="${product.stockQuantity <= 10}">

                                                            <span class="text-warning">
                                                                ${product.stockQuantity}
                                                            </span>

                                                        </c:when>


                                                        <c:otherwise>

                                                            <span class="text-success">
                                                                ${product.stockQuantity}
                                                            </span>

                                                        </c:otherwise>

                                                    </c:choose>

                                                </div>

                                            </div>

                                        </div>

                                    </div>

                                </div>

                            </div>

                        </section>


                        <!-- ================= DESCRIPTION ================= -->

                        <section class="panel mb-4">

                            <div class="panel-header">

                                <div>

                                    <h2 class="h5 mb-1 section-title">

                                        <i class="bi bi-card-text"
                                           aria-hidden="true"></i>

                                        <span>
                                            Description
                                        </span>

                                    </h2>

                                </div>

                            </div>


                            <div class="p-3 p-lg-4">

                                <c:choose>

                                    <c:when test="${not empty product.description}">

                                        <p class="mb-0">
                                            ${product.description}
                                        </p>

                                    </c:when>


                                    <c:otherwise>

                                        <p class="text-muted mb-0">
                                            No description available.
                                        </p>

                                    </c:otherwise>

                                </c:choose>

                            </div>

                        </section>


                        <!-- ================= TECHNICAL SPECIFICATIONS ================= -->

                        <section class="panel mb-4">

                            <div class="panel-header">

                                <div>

                                    <h2 class="h5 mb-1 section-title">

                                        <i class="bi bi-sliders"
                                           aria-hidden="true"></i>

                                        <span>
                                            Technical Specifications
                                        </span>

                                    </h2>

                                    <p class="text-muted mb-0">
                                        Technical specifications of this product.
                                    </p>

                                </div>

                            </div>


                            <div class="p-3 p-lg-4">

                                <div class="row">


                                    <!-- Connection -->

                                    <div class="col-md-6 mb-4">

                                        <div class="text-muted small mb-1">
                                            Connection Type
                                        </div>

                                        <div class="fw-semibold">

                                            <c:choose>

                                                <c:when test="${not empty product.connectionType}">
                                                    ${product.connectionType}
                                                </c:when>

                                                <c:otherwise>

                                                    <span class="text-muted">
                                                        Not Specified
                                                    </span>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>

                                    </div>


                                    <!-- Driver -->

                                    <div class="col-md-6 mb-4">

                                        <div class="text-muted small mb-1">
                                            Driver Size
                                        </div>

                                        <div class="fw-semibold">

                                            <c:choose>

                                                <c:when test="${product.driverSize != null}">

                                                    ${product.driverSize} mm

                                                </c:when>

                                                <c:otherwise>

                                                    <span class="text-muted">
                                                        Not Specified
                                                    </span>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>

                                    </div>


                                    <!-- Noise Cancelling -->

                                    <div class="col-md-6 mb-4">

                                        <div class="text-muted small mb-1">
                                            Noise Cancelling
                                        </div>

                                        <div class="fw-semibold">

                                            <c:choose>

                                                <c:when test="${product.noiseCancelling}">

                                                    <span class="text-success">

                                                        <i class="bi bi-check-circle me-1"></i>

                                                        Yes

                                                    </span>

                                                </c:when>


                                                <c:otherwise>

                                                    <span class="text-muted">
                                                        No
                                                    </span>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>

                                    </div>


                                    <!-- Battery -->

                                    <div class="col-md-6 mb-4">

                                        <div class="text-muted small mb-1">
                                            Battery Life
                                        </div>

                                        <div class="fw-semibold">

                                            <c:choose>

                                                <c:when test="${product.batteryLife != null}">

                                                    ${product.batteryLife} hours

                                                </c:when>


                                                <c:otherwise>

                                                    <span class="text-muted">
                                                        Not Specified
                                                    </span>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>

                                    </div>


                                    <!-- Microphone -->

                                    <div class="col-md-6 mb-4">

                                        <div class="text-muted small mb-1">
                                            Microphone
                                        </div>

                                        <div class="fw-semibold">

                                            <c:choose>

                                                <c:when test="${product.microphone}">

                                                    <span class="text-success">

                                                        <i class="bi bi-check-circle me-1"></i>

                                                        Yes

                                                    </span>

                                                </c:when>


                                                <c:otherwise>

                                                    <span class="text-muted">
                                                        No
                                                    </span>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>

                                    </div>


                                    <!-- Water Resistance -->

                                    <div class="col-md-6 mb-4">

                                        <div class="text-muted small mb-1">
                                            Water Resistance
                                        </div>

                                        <div class="fw-semibold">

                                            <c:choose>

                                                <c:when test="${not empty product.waterResistance}">

                                                    ${product.waterResistance}

                                                </c:when>


                                                <c:otherwise>

                                                    <span class="text-muted">
                                                        Not Specified
                                                    </span>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>

                                    </div>

                                </div>

                            </div>

                        </section>


                        <!-- ================= SYSTEM INFORMATION ================= -->

                        <section class="panel mb-4">

                            <div class="panel-header">

                                <div>

                                    <h2 class="h5 mb-1 section-title">

                                        <i class="bi bi-info-circle"
                                           aria-hidden="true"></i>

                                        <span>
                                            System Information
                                        </span>

                                    </h2>

                                </div>

                            </div>


                            <div class="p-3 p-lg-4">

                                <div class="row">


                                    <!-- ID -->

                                    <div class="col-md-6 mb-4">

                                        <div class="text-muted small mb-1">
                                            Product ID
                                        </div>

                                        <div class="fw-semibold">
                                            ${product.productId}
                                        </div>

                                    </div>


                                    <!-- Status -->

                                    <div class="col-md-6 mb-4">

                                        <div class="text-muted small mb-1">
                                            Status
                                        </div>

                                        <div class="fw-semibold">
                                            ${product.status}
                                        </div>

                                    </div>


                                    <!-- Created -->

                                    <div class="col-md-6 mb-4">

                                        <div class="text-muted small mb-1">
                                            Created At
                                        </div>

                                        <div class="fw-semibold">

                                            <c:choose>

                                                <c:when test="${product.createdAt != null}">
                                                    ${product.createdAt}
                                                </c:when>

                                                <c:otherwise>

                                                    <span class="text-muted">
                                                        Not Available
                                                    </span>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>

                                    </div>


                                    <!-- Updated -->

                                    <div class="col-md-6 mb-4">

                                        <div class="text-muted small mb-1">
                                            Updated At
                                        </div>

                                        <div class="fw-semibold">

                                            <c:choose>

                                                <c:when test="${product.updatedAt != null}">
                                                    ${product.updatedAt}
                                                </c:when>

                                                <c:otherwise>

                                                    <span class="text-muted">
                                                        Not Updated
                                                    </span>

                                                </c:otherwise>

                                            </c:choose>

                                        </div>

                                    </div>

                                </div>

                            </div>

                        </section>


                        <!-- ================= BOTTOM ACTIONS ================= -->

                        <div class="d-flex justify-content-end gap-2 mb-4">

                            <c:choose>
                                <c:when test="${from eq 'inventory'}">
                                    <a href="${pageContext.request.contextPath}/Manager/Inventory"
                                       class="btn btn-light">
                                        <i class="bi bi-arrow-left me-1"></i>
                                        Back to Inventory
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/Manager/products"
                                       class="btn btn-light">
                                        <i class="bi bi-arrow-left me-1"></i>
                                        Back to Products
                                    </a>
                                </c:otherwise>
                            </c:choose>


                            <a href="${pageContext.request.contextPath}/Manager/products?action=edit&id=${product.productId}"
                               class="btn btn-primary">

                                <i class="bi bi-pencil me-1"></i>

                                Edit Product

                            </a>

                        </div>

                    </div>

                </main>


                <!-- ================= FOOTER ================= -->

                <footer class="admin-footer">

                    <div class="container-fluid px-3 px-lg-4">

                        <span>

                            Copyright 2026 Headphone Store.
                            <br>
                            Manager Product Detail

                        </span>


                        <span>

                            Headphone Store E-commerce System.

                        </span>

                    </div>

                </footer>

            </div>

        </div>


        <!-- ================= EXISTING JS ================= -->

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>

    </body>

</html>