    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

    <!DOCTYPE html>
    <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta name="description" content="Headphone Store Manager - Sales & Business Reports">
            <title>Reports & Analytics | Headphone Store</title>

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
                            <span class="nav-text">Dashboard</span>
                        </a>

                        <a class="nav-link ${activePage == 'products' ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/Manager/products">
                            <span class="nav-icon">
                                <i class="bi bi-box-seam"></i>
                            </span>
                            <span class="nav-text">Products</span>
                        </a>

                        <a class="nav-link ${activePage == 'orders' ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/Manager/OrderManagement">
                            <span class="nav-icon">
                                <i class="bi bi-cart-check"></i>
                            </span>
                            <span class="nav-text">Orders</span>
                        </a>

                        <a class="nav-link ${activePage == 'inventory' ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/Manager/Inventory">
                            <span class="nav-icon">
                                <i class="bi bi-boxes"></i>
                            </span>
                            <span class="nav-text">Inventory</span>
                        </a>

                        <a class="nav-link ${activePage == 'voucher' ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/Manager/Voucher">
                            <span class="nav-icon">
                                <i class="bi bi-ticket-perforated"></i>
                            </span>
                            <span class="nav-text">Vouchers</span>
                        </a>

                        <a class="nav-link ${activePage == 'reports' ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/Manager/Report">
                            <span class="nav-icon">
                                <i class="bi bi-bar-chart-line"></i>
                            </span>
                            <span class="nav-text">Reports</span>
                        </a>

                        <a class="nav-link ${activePage == 'profile' ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/Manager/Profile">
                            <span class="nav-icon">
                                <i class="bi bi-person-badge"></i>
                            </span>
                            <span class="nav-text">Profile</span>
                        </a>

                    </nav>

                    <div class="sidebar-footer">
                        <span class="status-dot"></span>
                        <span class="sidebar-footer-text">System running smoothly</span>
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

                                <button class="icon-button theme-toggle"
                                        type="button"
                                        data-theme-toggle
                                        aria-label="Switch color theme">
                                    <i class="bi bi-moon-stars" data-theme-icon></i>
                                </button>

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
                                        <span class="dropdown-item text-muted">
                                            No new notifications.
                                        </span>
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

                            <!-- PAGE HEADING -->
                            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">

                                <div class="page-heading-copy">
                                    <span class="page-icon">
                                        <i class="bi bi-bar-chart-line"></i>
                                    </span>
                                    <div>
                                        <p class="eyebrow mb-1">Manager / Analytics</p>
                                        <h1 class="h3 mb-1">Reports & Analytics</h1>
                                        <p class="text-muted mb-0">
                                            Track revenue, sales volume, top products, and fulfillment statistics.
                                        </p>
                                    </div>
                                </div>

                                <div class="d-flex gap-2">
                                    <button type="button" class="btn btn-outline-secondary btn-sm" onclick="window.print()">
                                        <i class="bi bi-printer me-1"></i> Print
                                    </button>
                                    <button type="button" class="btn btn-primary btn-sm" onclick="exportReportToCSV()">
                                        <i class="bi bi-download me-1"></i> Export CSV
                                    </button>
                                </div>

                            </div>

                            <section class="panel mb-4">

                                <div class="panel-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                                    <div>
                                        <h2 class="h5 mb-1 section-title">
                                            <i class="bi bi-funnel"></i>
                                            <span>Report Filters</span>
                                        </h2>
                                        <p class="text-muted mb-0">Filter metrics by date range, preset intervals, or order status.</p>
                                    </div>

                                    <!-- Quick Presets -->
                                    <div class="btn-group btn-group-sm" role="group" aria-label="Preset filters">
                                        <a href="${pageContext.request.contextPath}/Manager/Report?period=all" 
                                           class="btn btn-outline-primary ${selectedPeriod == 'all' ? 'active' : ''}">All</a>
                                        <a href="${pageContext.request.contextPath}/Manager/Report?period=today" 
                                           class="btn btn-outline-primary ${selectedPeriod == 'today' ? 'active' : ''}">Today</a>
                                        <a href="${pageContext.request.contextPath}/Manager/Report?period=this_week" 
                                           class="btn btn-outline-primary ${selectedPeriod == 'this_week' ? 'active' : ''}">This Week</a>
                                        <a href="${pageContext.request.contextPath}/Manager/Report?period=this_month" 
                                           class="btn btn-outline-primary ${selectedPeriod == 'this_month' ? 'active' : ''}">This Month</a>
                                        <a href="${pageContext.request.contextPath}/Manager/Report?period=this_year" 
                                           class="btn btn-outline-primary ${selectedPeriod == 'this_year' ? 'active' : ''}">This Year</a>
                                    </div>
                                </div>

                                <form action="${pageContext.request.contextPath}/Manager/Report" method="GET" class="row g-3 align-items-end">

                                    <div class="col-12 col-md-3">
                                        <label class="form-label small text-muted mb-1">Start Date</label>
                                        <input type="date" class="form-control form-control-sm" name="startDate" value="${startDate}">
                                    </div>

                                    <div class="col-12 col-md-3">
                                        <label class="form-label small text-muted mb-1">End Date</label>
                                        <input type="date" class="form-control form-control-sm" name="endDate" value="${endDate}">
                                    </div>

                                    <div class="col-12 col-md-3">
                                        <label class="form-label small text-muted mb-1">Order Status</label>
                                        <select class="form-select form-select-sm" name="status">
                                            <option value="ALL" ${selectedStatus == 'ALL' ? 'selected' : ''}>All Statuses</option>
                                            <option value="DELIVERED" ${selectedStatus == 'DELIVERED' ? 'selected' : ''}>Delivered</option>
                                            <option value="SHIPPING" ${selectedStatus == 'SHIPPING' ? 'selected' : ''}>Shipping</option>
                                            <option value="PENDING" ${selectedStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                                            <option value="CANCELLED" ${selectedStatus == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                                        </select>
                                    </div>

                                    <div class="col-12 col-md-3 d-flex gap-2">
                                        <button type="submit" class="btn btn-primary btn-sm flex-fill">
                                            <i class="bi bi-search me-1"></i> Apply Filter
                                        </button>
                                        <a href="${pageContext.request.contextPath}/Manager/Report" class="btn btn-light btn-sm">
                                            Reset
                                        </a>
                                    </div>

                                </form>

                            </section>

                            <div class="row g-3 mb-4">

                                <div class="col-12 col-sm-6 col-xl-3">
                                    <div class="panel h-100">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div>
                                                <p class="text-muted mb-1">Total Revenue</p>
                                                <h2 class="h3 mb-1">
                                                    $<fmt:formatNumber value="${overviewStats.totalRevenue}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                                </h2>
                                                <small class="text-success">
                                                    <i class="bi bi-check-circle me-1"></i>Active & delivered sales
                                                </small>
                                            </div>
                                            <span class="page-icon">
                                                <i class="bi bi-cash-stack"></i>
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12 col-sm-6 col-xl-3">
                                    <div class="panel h-100">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div>
                                                <p class="text-muted mb-1">Total Orders</p>
                                                <h2 class="h3 mb-1">${overviewStats.totalOrders}</h2>
                                                <small class="text-primary">
                                                    <i class="bi bi-truck me-1"></i>${overviewStats.completedOrders} Delivered / ${overviewStats.pendingOrders} Pending
                                                </small>
                                            </div>
                                            <span class="page-icon">
                                                <i class="bi bi-cart-check"></i>
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12 col-sm-6 col-xl-3">
                                    <div class="panel h-100">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div>
                                                <p class="text-muted mb-1">Units Sold</p>
                                                <h2 class="h3 mb-1">${overviewStats.totalUnitsSold}</h2>
                                                <small class="text-info">
                                                    <i class="bi bi-headphones me-1"></i>Headphone units purchased
                                                </small>
                                            </div>
                                            <span class="page-icon">
                                                <i class="bi bi-box-seam"></i>
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12 col-sm-6 col-xl-3">
                                    <div class="panel h-100">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div>
                                                <p class="text-muted mb-1">Avg Order Value</p>
                                                <h2 class="h3 mb-1">
                                                    $<fmt:formatNumber value="${overviewStats.avgOrderValue}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                                </h2>
                                                <small class="${overviewStats.cancellationRate > 15 ? 'text-danger' : 'text-muted'}">
                                                    <i class="bi bi-x-circle me-1"></i>${overviewStats.cancellationRate}% Cancellation
                                                </small>
                                            </div>
                                            <span class="page-icon">
                                                <i class="bi bi-calculator"></i>
                                            </span>
                                        </div>
                                    </div>
                                </div>

                            </div>

                            <div class="row g-3 mb-4">

                                <div class="col-12 col-xl-8">
                                    <section class="panel h-100">
                                        <div class="panel-header d-flex justify-content-between align-items-center">
                                            <div>
                                                <h2 class="h5 mb-1 section-title">
                                                    <i class="bi bi-graph-up"></i>
                                                    <span>Revenue Performance (${currentYear})</span>
                                                </h2>
                                                <p class="text-muted mb-0">Monthly breakdown of gross headphone sales.</p>
                                            </div>

                                            <form action="${pageContext.request.contextPath}/Manager/Report" method="GET" class="d-inline-flex align-items-center gap-1">
                                                <select name="year" class="form-select form-select-sm" onchange="this.form.submit()">
                                                    <option value="2026" ${currentYear == 2026 ? 'selected' : ''}>2026</option>
                                                    <option value="2025" ${currentYear == 2025 ? 'selected' : ''}>2025</option>
                                                    <option value="2024" ${currentYear == 2024 ? 'selected' : ''}>2024</option>
                                                </select>
                                            </form>
                                        </div>

                                        <div class="chart-bars" style="grid-template-columns: repeat(12, minmax(18px, 1fr));">
                                            <c:forEach var="item" items="${monthlyRevenue}">
                                                <div class="chart-column" title="${item.monthName}: $<fmt:formatNumber value='${item.revenue}' type='number' maxFractionDigits='0'/> (${item.ordersCount} orders)">
                                                    <span style="--bar-size: ${item.barHeight}%;"></span>
                                                    ${item.monthName}
                                                </div>
                                            </c:forEach>
                                        </div>

                                        <div class="d-flex justify-content-between align-items-center mt-3 pt-2 border-top text-muted small">
                                            <span><i class="bi bi-info-circle me-1"></i>Hover over each month's bar to view specific revenue and order counts.</span>
                                            <span>Year ${currentYear}</span>
                                        </div>
                                    </section>
                                </div>

                                <div class="col-12 col-xl-4">
                                    <section class="panel h-100 d-flex flex-column">
                                        <div class="panel-header">
                                            <h2 class="h5 mb-1 section-title">
                                                <i class="bi bi-pie-chart"></i>
                                                <span>Order Status Distribution</span>
                                            </h2>
                                            <p class="text-muted mb-0">Breakdown of orders by fulfillment stage.</p>
                                        </div>

                                        <div class="d-flex justify-content-center my-3">
                                            <div class="donut-chart" 
                                                 style="background: conic-gradient(
                                                     var(--admin-success) 0 ${statusDistribution.deliveredPct}%, 
                                                     #0dcaf0 ${statusDistribution.deliveredPct}% ${statusDistribution.deliveredPct + statusDistribution.shippingPct}%, 
                                                     var(--admin-warning) ${statusDistribution.deliveredPct + statusDistribution.shippingPct}% ${statusDistribution.deliveredPct + statusDistribution.shippingPct + statusDistribution.pendingPct}%, 
                                                     var(--admin-danger) ${statusDistribution.deliveredPct + statusDistribution.shippingPct + statusDistribution.pendingPct}% 100%
                                                 );">
                                                <span>${statusDistribution.total}</span>
                                            </div>
                                        </div>

                                        <div class="legend-list mt-auto">
                                            <div class="d-flex align-items-center border-bottom">
                                                <span class="legend-dot bg-success me-2"></span>
                                                <span>Delivered</span>
                                                <strong class="ms-auto">${statusDistribution.delivered} (${statusDistribution.deliveredPct}%)</strong>
                                            </div>
                                            <div class="d-flex align-items-center border-bottom">
                                                <span class="legend-dot bg-info me-2"></span>
                                                <span>Shipping</span>
                                                <strong class="ms-auto">${statusDistribution.shipping} (${statusDistribution.shippingPct}%)</strong>
                                            </div>
                                            <div class="d-flex align-items-center border-bottom">
                                                <span class="legend-dot bg-warning me-2"></span>
                                                <span>Pending</span>
                                                <strong class="ms-auto">${statusDistribution.pending} (${statusDistribution.pendingPct}%)</strong>
                                            </div>
                                            <div class="d-flex align-items-center">
                                                <span class="legend-dot bg-danger me-2"></span>
                                                <span>Cancelled</span>
                                                <strong class="ms-auto">${statusDistribution.cancelled} (${statusDistribution.cancelledPct}%)</strong>
                                            </div>
                                        </div>
                                    </section>
                                </div>

                            </div>

                            <div class="row g-3 mb-4">

                                <!-- TOP SELLING PRODUCTS -->
                                <div class="col-12 col-xl-7">
                                    <section class="panel h-100">
                                        <div class="panel-header d-flex justify-content-between align-items-center">
                                            <div>
                                                <h2 class="h5 mb-1 section-title">
                                                    <i class="bi bi-trophy"></i>
                                                    <span>Top Selling Products</span>
                                                </h2>
                                                <p class="text-muted mb-0">Highest grossing and top performing headphones.</p>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/Manager/products" class="btn btn-light btn-sm">
                                                View Products
                                            </a>
                                        </div>

                                        <div class="table-responsive">
                                            <table class="table align-middle mb-0">
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <th>Product Name</th>
                                                        <th>Category</th>
                                                        <th>Price</th>
                                                        <th>Units Sold</th>
                                                        <th>Total Sales</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${not empty topProducts}">
                                                            <c:forEach var="p" items="${topProducts}">
                                                                <tr>
                                                                    <td>
                                                                        <span class="badge ${p.rank == 1 ? 'text-bg-warning' : (p.rank == 2 ? 'text-bg-secondary' : 'text-bg-light')}">
                                                                            #${p.rank}
                                                                        </span>
                                                                    </td>
                                                                    <td class="fw-semibold">
                                                                        ${p.productName}
                                                                        <c:if test="${not empty p.brandName}">
                                                                            <br><small class="text-muted">${p.brandName}</small>
                                                                        </c:if>
                                                                    </td>
                                                                    <td>
                                                                        <span class="badge text-bg-light">${p.categoryName}</span>
                                                                    </td>
                                                                    <td>
                                                                        $<fmt:formatNumber value="${p.price}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                                                    </td>
                                                                    <td class="fw-bold text-primary">
                                                                        ${p.unitsSold}
                                                                    </td>
                                                                    <td class="fw-bold text-success">
                                                                        $<fmt:formatNumber value="${p.totalRevenue}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <tr>
                                                                <td colspan="6" class="text-center py-4 text-muted">
                                                                    No product sales data available for this period.
                                                                </td>
                                                            </tr>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </tbody>
                                            </table>
                                        </div>
                                    </section>
                                </div>

                                <!-- SALES BY CATEGORY -->
                                <div class="col-12 col-xl-5">
                                    <section class="panel h-100">
                                        <div class="panel-header">
                                            <h2 class="h5 mb-1 section-title">
                                                <i class="bi bi-tag"></i>
                                                <span>Sales by Category</span>
                                            </h2>
                                            <p class="text-muted mb-0">Revenue distribution across headphone categories.</p>
                                        </div>

                                        <div class="d-flex flex-column gap-3 py-2">
                                            <c:choose>
                                                <c:when test="${not empty categorySales}">
                                                    <c:forEach var="cat" items="${categorySales}">
                                                        <div>
                                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                                <span class="fw-semibold">${cat.categoryName}</span>
                                                                <span class="text-muted small">
                                                                    ${cat.unitsSold} units | 
                                                                    <strong class="text-body">$<fmt:formatNumber value="${cat.revenue}" type="number" minFractionDigits="2" maxFractionDigits="2"/></strong>
                                                                    (${cat.sharePct}%)
                                                                </span>
                                                            </div>
                                                            <div class="progress">
                                                                <div class="progress-bar bg-primary" 
                                                                     role="progressbar" 
                                                                     style="width: ${cat.sharePct}%;" 
                                                                     aria-valuenow="${cat.sharePct}" 
                                                                     aria-valuemin="0" 
                                                                     aria-valuemax="100">
                                                                    <c:if test="${cat.sharePct > 10}">${cat.sharePct}%</c:if>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <p class="text-center py-4 text-muted mb-0">
                                                        No category sales recorded.
                                                    </p>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </section>
                                </div>

                            </div>

                            <!-- SECTION: Detailed Orders Report Table -->
                            <section class="panel">

                                <div class="panel-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                                    <div>
                                        <h2 class="h5 mb-1 section-title">
                                            <i class="bi bi-journal-text"></i>
                                            <span>Order Transactions Report</span>
                                        </h2>
                                        <p class="text-muted mb-0">Individual sales records matching current filter criteria.</p>
                                    </div>

                                    <!-- Native search input using data-table-search -->
                                    <div class="d-flex align-items-center gap-2">
                                        <input class="form-control form-control-sm table-search"
                                               type="search"
                                               placeholder="Search order or customer..."
                                               data-table-search="reportOrdersTable"
                                               aria-label="Search orders">
                                    </div>
                                </div>

                                <div class="table-responsive">
                                    <table class="table align-middle mb-0" id="reportOrdersTable">
                                        <thead>
                                            <tr>
                                                <th>Order ID</th>
                                                <th>Date</th>
                                                <th>Customer</th>
                                                <th>Email</th>
                                                <th>Items</th>
                                                <th>Payment</th>
                                                <th>Amount</th>
                                                <th>Order Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty ordersReport}">
                                                    <c:forEach var="ord" items="${ordersReport}">
                                                        <tr>
                                                            <td class="fw-semibold">
                                                                <a href="${pageContext.request.contextPath}/Manager/OrderManagement?action=detail&id=${ord.orderID}" 
                                                                   class="text-decoration-none">
                                                                    #${ord.orderID}
                                                                </a>
                                                            </td>
                                                            <td>${ord.orderDate}</td>
                                                            <td class="fw-semibold">${ord.customerName}</td>
                                                            <td class="text-muted">${ord.customerEmail}</td>
                                                            <td>
                                                                <span class="badge text-bg-light">${ord.totalItems} items</span>
                                                            </td>
                                                            <td>
                                                                <span class="badge ${ord.paymentStatus == 'SUCCESS' ? 'text-bg-success' : 'text-bg-secondary'}">
                                                                    ${ord.paymentMethod}
                                                                </span>
                                                            </td>
                                                            <td class="fw-bold">
                                                                $<fmt:formatNumber value="${ord.totalAmount}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${ord.orderStatus == 'DELIVERED'}">
                                                                        <span class="badge text-bg-success">Delivered</span>
                                                                    </c:when>
                                                                    <c:when test="${ord.orderStatus == 'SHIPPING'}">
                                                                        <span class="badge text-bg-info">Shipping</span>
                                                                    </c:when>
                                                                    <c:when test="${ord.orderStatus == 'PENDING'}">
                                                                        <span class="badge text-bg-warning">Pending</span>
                                                                    </c:when>
                                                                    <c:when test="${ord.orderStatus == 'CANCELLED'}">
                                                                        <span class="badge text-bg-danger">Cancelled</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge text-bg-secondary">${ord.orderStatus}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="8" class="text-center py-4 text-muted">
                                                            No orders found matching the selected criteria.
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

                    <!-- FOOTER -->
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

            <script>
                function exportReportToCSV() {
                    var table = document.getElementById("reportOrdersTable");
                    if (!table) return;

                    var csv = [];
                    var rows = table.querySelectorAll("tr");

                    for (var i = 0; i < rows.length; i++) {
                        if (rows[i].hidden) continue; // Skip filtered rows
                        var row = [], cols = rows[i].querySelectorAll("td, th");

                        for (var j = 0; j < cols.length; j++) {
                            var cleanText = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, " ").trim();
                            cleanText = cleanText.replace(/"/g, '""');
                            row.push('"' + cleanText + '"');
                        }
                        csv.push(row.join(","));
                    }

                    if (csv.length <= 1) {
                        alert("No data available to export.");
                        return;
                    }

                    var csvContent = "data:text/csv;charset=utf-8,\uFEFF" + csv.join("\n");
                    var encodedUri = encodeURI(csvContent);
                    var link = document.createElement("a");
                    link.setAttribute("href", encodedUri);
                    link.setAttribute("download", "Orders_Report_" + new Date().toISOString().slice(0, 10) + ".csv");
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                }
            </script>

        </body>

    </html>
