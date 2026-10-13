<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">

    <head>

        <meta charset="UTF-8">

        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">

        <meta name="description"
              content="Headphone Store Manager">

        <title>Voucher Management | Headphone Store</title>


        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css">

    </head>


    <body>

        <div class="admin-shell">


            <div class="sidebar-backdrop"
                 data-sidebar-close>
            </div>



            <aside class="admin-sidebar"
                   id="adminSidebar"
                   aria-label="Main navigation">


                <div class="sidebar-header">

                    <a class="brand-mark"
                       href="${pageContext.request.contextPath}/Manager/Dashboard"
                       aria-label="Headphone Store Manager">

                        <span class="brand-icon">
                            <i class="bi bi-headphones"
                               aria-hidden="true"></i>
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

                    <!-- Dashboard -->
                    <a class="nav-link ${activePage == 'dashboard' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Dashboard">

                        <span class="nav-icon">
                            <i class="bi bi-speedometer2"></i>
                        </span>

                        <span class="nav-text">Dashboard</span>
                    </a>

                    <!-- Products -->
                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/products">

                        <span class="nav-icon">
                            <i class="bi bi-box-seam"></i>
                        </span>

                        <span class="nav-text">Products</span>
                    </a>

                    <!-- Orders -->
                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/OrderManagement">

                        <span class="nav-icon">
                            <i class="bi bi-cart-check"></i>
                        </span>

                        <span class="nav-text">Orders</span>
                    </a>

                    <!-- Inventory -->
                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/Inventory">

                        <span class="nav-icon">
                            <i class="bi bi-boxes"></i>
                        </span>

                        <span class="nav-text">Inventory</span>
                    </a>

                    <!-- Vouchers -->
                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/Voucher">

                        <span class="nav-icon">
                            <i class="bi bi-ticket-perforated"></i>
                        </span>

                        <span class="nav-text">Vouchers</span>
                    </a>

                    <!-- Reports -->
                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/Report">

                        <span class="nav-icon">
                            <i class="bi bi-bar-chart-line"></i>
                        </span>

                        <span class="nav-text">Reports</span>
                    </a>

                    <!-- Profile -->
                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/Profile">

                        <span class="nav-icon">
                            <i class="bi bi-person-badge"></i>
                        </span>

                        <span class="nav-text">Profile</span>
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

                        <!-- SIDEBAR TOGGLE -->

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

                        


                        <!-- NAVBAR ACTIONS -->

                        <div class="navbar-actions ms-auto">


                            <!-- THEME -->

                            <button class="icon-button theme-toggle"
                                    type="button"
                                    data-theme-toggle
                                    aria-label="Switch color theme"
                                    title="Switch color theme">

                                <i class="bi bi-moon-stars"
                                   data-theme-icon
                                   aria-hidden="true"></i>

                            </button>


                            <!-- NOTIFICATION -->

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

                                    <a class="dropdown-item" href="#">

                                        <span class="notification-title">
                                            Low stock product
                                        </span>

                                        <span class="notification-time">
                                            4 minutes ago
                                        </span>

                                    </a>


                                    <a class="dropdown-item" href="#">

                                        <span class="notification-title">
                                            New order received
                                        </span>

                                        <span class="notification-time">
                                            32 minutes ago
                                        </span>

                                    </a>


                                    <a class="dropdown-item" href="#">

                                        <span class="notification-title">
                                            Product updated
                                        </span>

                                        <span class="notification-time">
                                            1 hour ago
                                        </span>

                                    </a>

                                </div>

                            </div>


                            <!-- PROFILE -->

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

                                    <i class="bi bi-ticket-perforated"
                                       aria-hidden="true"></i>

                                </span>


                                <div>

                                    <p class="eyebrow mb-1">
                                        Manager
                                    </p>

                                    <h1 class="h3 mb-1">
                                        Voucher Management
                                    </h1>

                                    <p class="text-muted mb-0">
                                        Create and manage discount vouchers for customers.
                                    </p>

                                </div>

                            </div>


                            <!-- ADD VOUCHER -->

                            <div>

                                <a href="${pageContext.request.contextPath}/Manager/Voucher?action=add"
                                   class="btn btn-success">

                                    <i class="bi bi-plus-lg me-1"></i>

                                    Add Voucher

                                </a>

                            </div>

                        </div>


                        <!-- ================= MESSAGE ================= -->

                        <c:if test="${not empty sessionScope.successMessage}">

                            <div class="alert alert-success alert-dismissible fade show"
                                 role="alert">

                                ${sessionScope.successMessage}

                                <button type="button"
                                        class="btn-close"
                                        data-bs-dismiss="alert">
                                </button>

                            </div>

                            <c:remove var="successMessage"
                                      scope="session"/>

                        </c:if>


                        <c:if test="${not empty sessionScope.errorMessage}">

                            <div class="alert alert-danger alert-dismissible fade show"
                                 role="alert">

                                ${sessionScope.errorMessage}

                                <button type="button"
                                        class="btn-close"
                                        data-bs-dismiss="alert">
                                </button>

                            </div>

                            <c:remove var="errorMessage"
                                      scope="session"/>

                        </c:if>


                        <!-- ================= VOUCHER TABLE ================= -->

                        <section class="panel">


                            <!-- PANEL HEADER -->

                            <div class="panel-header">

                                <div>

                                    <h2 class="h5 mb-1 section-title">

                                        <i class="bi bi-ticket-perforated"
                                           aria-hidden="true"></i>

                                        <span>
                                            Voucher List
                                        </span>

                                    </h2>

                                    <p class="text-muted mb-0">
                                        ${totalItems} voucher(s) found.
                                    </p>

                                </div>

                            </div>


                            <!-- Server-side search and filtering -->
                            <div class="px-3 pt-3 pb-2">
                                <form method="get"
                                      action="${pageContext.request.contextPath}/Manager/Voucher"
                                      class="row g-3 align-items-end">

                                    <div class="col-xl-3 col-lg-4 col-md-6">
                                        <label class="form-label">Search</label>
                                        <input class="form-control"
                                               type="search"
                                               name="keyword"
                                               value="${keyword}"
                                               placeholder="Voucher code or description">
                                    </div>

                                    <div class="col-xl-2 col-lg-4 col-md-6">
                                        <label class="form-label">Discount Type</label>
                                        <select name="discountType" class="form-select">
                                            <option value="">All Types</option>
                                            <option value="PERCENT" ${selectedDiscountType == 'PERCENT' ? 'selected' : ''}>
                                                Percentage (%)
                                            </option>
                                            <option value="FIXED" ${selectedDiscountType == 'FIXED' ? 'selected' : ''}>
                                                Fixed Amount (đ)
                                            </option>
                                        </select>
                                    </div>

                                    <div class="col-xl-2 col-lg-4 col-md-6">
                                        <label class="form-label">Status</label>
                                        <select name="status" class="form-select">
                                            <option value="">All Statuses</option>
                                            <option value="ACTIVE" ${selectedStatus == 'ACTIVE' ? 'selected' : ''}>
                                                Active
                                            </option>
                                            <option value="INACTIVE" ${selectedStatus == 'INACTIVE' ? 'selected' : ''}>
                                                Inactive
                                            </option>
                                            <option value="EXPIRED" ${selectedStatus == 'EXPIRED' ? 'selected' : ''}>
                                                Expired
                                            </option>
                                        </select>
                                    </div>

                                    <div class="col-xl-2 col-lg-4 col-md-6">
                                        <label class="form-label">Valid Period</label>
                                        <select name="validPeriod" class="form-select">
                                            <option value="">All Periods</option>
                                            <option value="valid_now" ${selectedValidPeriod == 'valid_now' ? 'selected' : ''}>
                                                Currently Valid
                                            </option>
                                            <option value="upcoming" ${selectedValidPeriod == 'upcoming' ? 'selected' : ''}>
                                                Upcoming
                                            </option>
                                            <option value="expired" ${selectedValidPeriod == 'expired' ? 'selected' : ''}>
                                                Expired Period
                                            </option>
                                        </select>
                                    </div>

                                    <div class="col-xl-3 col-lg-4 col-md-6">
                                        <label class="form-label">Sort</label>
                                        <select name="sort" class="form-select">
                                            <option value="" ${empty selectedSort ? 'selected' : ''}>Newest</option>
                                            <option value="minorder_asc" ${selectedSort == 'minorder_asc' ? 'selected' : ''}>
                                                Min Order: Low to High
                                            </option>
                                            <option value="minorder_desc" ${selectedSort == 'minorder_desc' ? 'selected' : ''}>
                                                Min Order: High to Low
                                            </option>
                                            <option value="discount_asc" ${selectedSort == 'discount_asc' ? 'selected' : ''}>
                                                Discount Value: Low to High
                                            </option>
                                            <option value="discount_desc" ${selectedSort == 'discount_desc' ? 'selected' : ''}>
                                                Discount Value: High to Low
                                            </option>
                                            <option value="expiring_soon" ${selectedSort == 'expiring_soon' ? 'selected' : ''}>
                                                Expiring Soon
                                            </option>
                                        </select>
                                    </div>

                                    <div class="col-12 d-flex gap-2">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-search me-1"></i>
                                            Filter / Search
                                        </button>

                                        <a href="${pageContext.request.contextPath}/Manager/Voucher"
                                           class="btn btn-light">
                                            Reset
                                        </a>
                                    </div>
                                </form>
                            </div>


                            <!-- ================= TABLE ================= -->

                            <div class="table-responsive">

                                <table class="table align-middle mb-0"
                                       id="vouchersTable">

                                    <thead>

                                        <tr>

                                            <th>
                                                Code
                                            </th>

                                            <th>
                                                Discount
                                            </th>

                                            <th>
                                                Min Order
                                            </th>

                                            <th>
                                                Max Discount
                                            </th>

                                            <th>
                                                Valid Period
                                            </th>

                                            <th>
                                                Usage
                                            </th>

                                            <th>
                                                Status
                                            </th>

                                            <th class="text-end">
                                                Action
                                            </th>

                                        </tr>

                                    </thead>


                                    <tbody>


                                        <!-- ================= DYNAMIC DATA ================= -->

                                        <c:choose>

                                            <c:when test="${not empty vouchers}">


                                                <c:forEach var="voucher"
                                                           items="${vouchers}">

                                                    <tr>


                                                        <!-- CODE -->

                                                        <td>

                                                            <div class="table-media">

                                                                <div class="product-thumb">

                                                                    <i class="bi bi-ticket-perforated"></i>

                                                                </div>


                                                                <span>

                                                                    <strong>
                                                                        ${voucher.voucherCode}
                                                                    </strong>

                                                                    <br>

                                                                    <small class="text-muted">
                                                                        ${voucher.description}
                                                                    </small>

                                                                </span>

                                                            </div>

                                                        </td>


                                                        <!-- DISCOUNT -->

                                                        <td>

                                                            <strong>

                                                                <c:choose>

                                                                    <c:when test="${voucher.discountType == 'PERCENT'}">

                                                                        <fmt:formatNumber
                                                                            value="${voucher.discountValue}"
                                                                            maxFractionDigits="2"/>

                                                                        %

                                                                    </c:when>

                                                                    <c:otherwise>

                                                                        <fmt:formatNumber
                                                                            value="${voucher.discountValue}"
                                                                            maxFractionDigits="0"/>

                                                                        đ

                                                                    </c:otherwise>

                                                                </c:choose>

                                                            </strong>

                                                        </td>


                                                        <!-- MIN ORDER -->

                                                        <td>

                                                            <fmt:formatNumber
                                                                value="${voucher.minOrderAmount}"
                                                                maxFractionDigits="0"/>

                                                            đ

                                                        </td>


                                                        <!-- MAX DISCOUNT -->

                                                        <td>

                                                            <c:choose>

                                                                <c:when test="${not empty voucher.maxDiscount}">

                                                                    <fmt:formatNumber
                                                                        value="${voucher.maxDiscount}"
                                                                        maxFractionDigits="0"/>

                                                                    đ

                                                                </c:when>

                                                                <c:otherwise>
                                                                    —
                                                                </c:otherwise>

                                                            </c:choose>

                                                        </td>


                                                        <!-- VALID PERIOD -->

                                                        <td>

                                                            <div>
                                                                ${voucher.formattedStartDate}
                                                            </div>

                                                            <div class="text-muted small">
                                                                → ${voucher.formattedEndDate}
                                                            </div>

                                                        </td>


                                                        <!-- USAGE -->

                                                        <td>

                                                            <strong>
                                                                ${voucher.usedCount}
                                                            </strong>

                                                            <c:choose>

                                                                <c:when test="${not empty voucher.usageLimit}">

                                                                    /
                                                                    ${voucher.usageLimit}

                                                                </c:when>

                                                                <c:otherwise>

                                                                    / Unlimited

                                                                </c:otherwise>

                                                            </c:choose>

                                                        </td>


                                                        <!-- STATUS -->

                                                        <td>

                                                            <c:choose>

                                                                <c:when test="${voucher.status == 'ACTIVE'}">

                                                                    <span class="badge text-bg-success">
                                                                        Active
                                                                    </span>

                                                                </c:when>


                                                                <c:when test="${voucher.status == 'INACTIVE'}">

                                                                    <span class="badge text-bg-secondary">
                                                                        Inactive
                                                                    </span>

                                                                </c:when>


                                                                <c:otherwise>

                                                                    <span class="badge text-bg-secondary">
                                                                        Expired
                                                                    </span>

                                                                </c:otherwise>

                                                            </c:choose>

                                                        </td>


                                                        <!-- ACTION -->

                                                        <td class="text-end">

                                                            <!-- DETAIL -->

                                                            <a href="${pageContext.request.contextPath}/Manager/Voucher?action=detail&id=${voucher.voucherId}"
                                                               class="btn btn-light btn-sm"
                                                               title="View details">

                                                                <i class="bi bi-eye"></i>

                                                                Detail

                                                            </a>

                                                            <!-- ACTIVE -->

                                                            <c:if test="${voucher.status == 'ACTIVE'}">

                                                                <form action="${pageContext.request.contextPath}/Manager/Voucher"
                                                                      method="post"
                                                                      style="display:inline;">

                                                                    <input type="hidden"
                                                                           name="action"
                                                                           value="changeStatus">

                                                                    <input type="hidden"
                                                                           name="voucherId"
                                                                           value="${voucher.voucherId}">

                                                                    <input type="hidden"
                                                                           name="status"
                                                                           value="INACTIVE">

                                                                    <button type="submit"
                                                                            class="btn btn-light btn-sm"
                                                                            onclick="return confirm('Are you sure you want to disable this voucher?');">

                                                                        <i class="bi bi-pause-circle"></i>

                                                                        Disable

                                                                    </button>

                                                                </form>

                                                            </c:if>


                                                            <!-- INACTIVE -->

                                                            <c:if test="${voucher.status == 'INACTIVE'}">

                                                                <form action="${pageContext.request.contextPath}/Manager/Voucher"
                                                                      method="post"
                                                                      style="display:inline;">

                                                                    <input type="hidden"
                                                                           name="action"
                                                                           value="changeStatus">

                                                                    <input type="hidden"
                                                                           name="voucherId"
                                                                           value="${voucher.voucherId}">

                                                                    <input type="hidden"
                                                                           name="status"
                                                                           value="ACTIVE">

                                                                    <button type="submit"
                                                                            class="btn btn-light btn-sm"
                                                                            onclick="return confirm('Are you sure you want to activate this voucher?');">

                                                                        <i class="bi bi-play-circle"></i>

                                                                        Activate

                                                                    </button>

                                                                </form>

                                                            </c:if>


                                                        </td>

                                                    </tr>

                                                </c:forEach>


                                            </c:when>


                                            <c:otherwise>

                                                <tr>

                                                    <td colspan="8"
                                                        class="text-center py-5">

                                                        <i class="bi bi-ticket-perforated fs-1 text-muted"></i>

                                                        <p class="text-muted mt-2 mb-0">
                                                            No vouchers found.
                                                        </p>

                                                    </td>

                                                </tr>

                                            </c:otherwise>

                                        </c:choose>


                                    </tbody>

                                </table>

                            </div>

                            <c:if test="${totalPages > 1}">
                                <div class="card-footer bg-white d-flex justify-content-between align-items-center py-3 px-3">
                                    <small class="text-muted">
                                        Page ${currentPage} of ${totalPages} — ${totalItems} item(s)
                                    </small>

                                    <nav aria-label="Voucher pagination">
                                        <ul class="pagination pagination-sm mb-0">

                                            <c:url var="previousUrl" value="/Manager/Voucher">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="discountType" value="${selectedDiscountType}"/>
                                                <c:param name="status" value="${selectedStatus}"/>
                                                <c:param name="validPeriod" value="${selectedValidPeriod}"/>
                                                <c:param name="sort" value="${selectedSort}"/>
                                                <c:param name="pageSize" value="${pageSize}"/>
                                                <c:param name="page" value="${currentPage - 1}"/>
                                            </c:url>

                                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                                <a class="page-link" href="${previousUrl}">Previous</a>
                                            </li>

                                            <c:forEach var="p" begin="1" end="${totalPages}">
                                                <c:url var="pageUrl" value="/Manager/Voucher">
                                                    <c:param name="keyword" value="${keyword}"/>
                                                    <c:param name="discountType" value="${selectedDiscountType}"/>
                                                    <c:param name="status" value="${selectedStatus}"/>
                                                    <c:param name="validPeriod" value="${selectedValidPeriod}"/>
                                                    <c:param name="sort" value="${selectedSort}"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:param name="page" value="${p}"/>
                                                </c:url>

                                                <li class="page-item ${p == currentPage ? 'active' : ''}">
                                                    <a class="page-link" href="${pageUrl}">${p}</a>
                                                </li>
                                            </c:forEach>

                                            <c:url var="nextUrl" value="/Manager/Voucher">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="discountType" value="${selectedDiscountType}"/>
                                                <c:param name="status" value="${selectedStatus}"/>
                                                <c:param name="validPeriod" value="${selectedValidPeriod}"/>
                                                <c:param name="sort" value="${selectedSort}"/>
                                                <c:param name="pageSize" value="${pageSize}"/>
                                                <c:param name="page" value="${currentPage + 1}"/>
                                            </c:url>

                                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                                <a class="page-link" href="${nextUrl}">Next</a>
                                            </li>
                                        </ul>
                                    </nav>
                                </div>
                            </c:if>

                        </section>

                    </div>

                </main>


                <!-- ================= FOOTER ================= -->

                <footer class="admin-footer">

                    <div class="container-fluid px-3 px-lg-4">

                        <span>

                            Copyright 2026 Headphone Store.

                            <br>

                            Manager Voucher Management

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