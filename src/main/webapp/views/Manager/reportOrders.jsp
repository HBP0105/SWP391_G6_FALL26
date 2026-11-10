<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="Headphone Store Manager - Order Analysis">
        <title>Order Analysis | Headphone Store</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css?v=20261109-1">
    </head>

    <body class="report-page report-orders">

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
                        <span class="nav-icon"><i class="bi bi-speedometer2"></i></span>
                        <span class="nav-text">Dashboard</span>
                    </a>

                    <a class="nav-link ${activePage == 'products' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/products">
                        <span class="nav-icon"><i class="bi bi-box-seam"></i></span>
                        <span class="nav-text">Products</span>
                    </a>

                    <a class="nav-link ${activePage == 'orders' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/OrderManagement">
                        <span class="nav-icon"><i class="bi bi-cart-check"></i></span>
                        <span class="nav-text">Orders</span>
                    </a>

                    <a class="nav-link ${activePage == 'inventory' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Inventory">
                        <span class="nav-icon"><i class="bi bi-boxes"></i></span>
                        <span class="nav-text">Inventory</span>
                    </a>

                    <a class="nav-link ${activePage == 'voucher' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Voucher">
                        <span class="nav-icon"><i class="bi bi-ticket-perforated"></i></span>
                        <span class="nav-text">Vouchers</span>
                    </a>

                    <a class="nav-link ${activePage == 'reports' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Report">
                        <span class="nav-icon"><i class="bi bi-bar-chart-line"></i></span>
                        <span class="nav-text">Reports</span>
                    </a>

                    <a class="nav-link ${activePage == 'profile' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Profile">
                        <span class="nav-icon"><i class="bi bi-person-badge"></i></span>
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
                                <button class="profile-button dropdown-toggle"
                                        type="button"
                                        data-bs-toggle="dropdown"
                                        aria-expanded="false">
                                    <img class="avatar-img avatar-sm"
         src="${pageContext.request.contextPath}/assets/Admin_Manager/images/avatar/gumball.jpg"
         alt="Manager"
         onerror="this.onerror=null;this.src='data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' width=\'34\' height=\'34\' viewBox=\'0 0 34 34\'><rect width=\'34\' height=\'34\' rx=\'8\' fill=\'%232563eb\'/><text x=\'50%25\' y=\'53%25\' dominant-baseline=\'middle\' text-anchor=\'middle\' fill=\'%23ffffff\' font-family=\'sans-serif\' font-size=\'14\' font-weight=\'bold\'>M</text></svg>';">
                                    <span class="profile-name d-none d-sm-inline">${not empty sessionScope.staff.fullName ? sessionScope.staff.fullName : 'Manager'}</span>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/Manager/Profile">Profile</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">Sign out</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </nav>

                <main class="dashboard-content">
                    <div class="container-fluid px-3 px-lg-4 py-4">

                        <!-- PAGE HEADING -->
                        <div class="report-heading d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
                            <div class="page-heading-copy">
                                <span class="page-icon">
                                    <i class="bi bi-receipt"></i>
                                </span>
                                <div>
                                    <p class="eyebrow mb-1">Manager / Analytics</p>
                                    <h1 class="h3 mb-1">Order Analysis</h1>
                                    <p class="text-muted mb-0">
                                        Comprehensive order fulfillment analytics, cancellation rate, items per order, and payment channels.
                                    </p>
                                </div>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-outline-secondary btn-sm" onclick="window.print()">
                                    <i class="bi bi-printer me-1"></i> Print
                                </button>
                                <button type="button" class="btn btn-primary btn-sm" onclick="exportOrdersToCSV()">
                                    <i class="bi bi-download me-1"></i> Export CSV
                                </button>
                            </div>
                        </div>

                        <!-- REPORT NAVIGATION TABS -->
                        <div class="report-tabs mb-4">
                            <div class="nav nav-pills gap-2 p-1 rounded-3 border shadow-sm d-inline-flex flex-wrap" style="background: var(--admin-surface, #ffffff);">
                                <a class="nav-link px-3 py-2 fw-semibold ${currentTab == 'overview' ? 'active' : 'text-body'}" 
                                   href="${pageContext.request.contextPath}/Manager/Report?tab=overview">
                                    <i class="bi bi-grid-1x2 me-1"></i> Overview
                                </a>
                                <a class="nav-link px-3 py-2 fw-semibold ${currentTab == 'revenue' ? 'active' : 'text-body'}" 
                                   href="${pageContext.request.contextPath}/Manager/Report?tab=revenue">
                                    <i class="bi bi-graph-up-arrow me-1"></i> Revenue
                                </a>
                                <a class="nav-link px-3 py-2 fw-semibold ${currentTab == 'products' ? 'active' : 'text-body'}" 
                                   href="${pageContext.request.contextPath}/Manager/Report?tab=products">
                                    <i class="bi bi-box-seam me-1"></i> Products
                                </a>
                                <a class="nav-link px-3 py-2 fw-semibold ${currentTab == 'orders' ? 'active' : 'text-body'}" 
                                   href="${pageContext.request.contextPath}/Manager/Report?tab=orders">
                                    <i class="bi bi-receipt me-1"></i> Orders
                                </a>
                            </div>
                        </div>

                        <c:if test="${not empty reportFilterError}">
                            <div class="alert alert-danger d-flex align-items-center gap-2 mb-4" role="alert">
                                <i class="bi bi-exclamation-triangle-fill"></i>
                                <span>${reportFilterError}</span>
                            </div>
                        </c:if>

                        <!-- 8 ORDER KPI SUMMARY CARDS -->
                        <div class="report-kpi-grid row g-3 mb-4">
                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Total Orders</p>
                                            <h2 class="h3 mb-1">${orderStats.totalOrders}</h2>
                                            <small class="text-primary">
                                                <i class="bi bi-cart me-1"></i>All incoming orders
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-cart-check"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Completed Orders</p>
                                            <h2 class="h3 mb-1 text-success">${orderStats.completedOrders}</h2>
                                            <small class="text-success">
                                                <i class="bi bi-check-all me-1"></i>Delivered successfully
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-check2-circle"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Shipping & Pending</p>
                                            <h2 class="h3 mb-1 text-info">
                                                ${orderStats.shippingOrders} / ${orderStats.pendingOrders}
                                            </h2>
                                            <small class="text-muted">
                                                <i class="bi bi-truck me-1"></i>${orderStats.shippingOrders} Shipping, ${orderStats.pendingOrders} Pending
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-hourglass-split"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Cancellation Rate</p>
                                            <h2 class="h3 mb-1 ${orderStats.cancellationRate > 15 ? 'text-danger' : 'text-body'}">
                                                ${orderStats.cancellationRate}%
                                            </h2>
                                            <small class="${orderStats.cancelledOrders > 0 ? 'text-danger' : 'text-muted'}">
                                                <i class="bi bi-x-circle me-1"></i>${orderStats.cancelledOrders} cancelled order(s)
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-slash-circle"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Average Items / Order</p>
                                            <h2 class="h3 mb-1 text-primary">${orderStats.avgItemsPerOrder}</h2>
                                            <small class="text-muted">
                                                <i class="bi bi-layers me-1"></i>${orderStats.totalUnitsSold} total items sold
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-boxes"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Average Order Value</p>
                                            <h2 class="h3 mb-1">
                                                <fmt:formatNumber value="${orderStats.avgOrderValue}" pattern="#,##0"/> VND
                                            </h2>
                                            <small class="text-muted">
                                                <i class="bi bi-calculator me-1"></i>Per non-cancelled order
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-cash"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Total Revenue</p>
                                            <h2 class="h3 mb-1 text-success">
                                                <fmt:formatNumber value="${orderStats.totalRevenue}" pattern="#,##0"/> VND
                                            </h2>
                                            <small class="text-success">
                                                <i class="bi bi-graph-up me-1"></i>Realized order volume
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-cash-stack"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Fulfillment Rate</p>
                                            <h2 class="h3 mb-1 text-info">
                                                <fmt:formatNumber value="${orderStats.totalOrders > 0 ? ((orderStats.completedOrders * 100.0) / orderStats.totalOrders) : 0}" maxFractionDigits="1"/>%
                                            </h2>
                                            <small class="text-muted">
                                                <i class="bi bi-pie-chart me-1"></i>Delivered / Total Orders
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-speedometer"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- PAYMENT METHOD ANALYSIS ROW -->
                        <div class="row g-3 mb-4">
                            <div class="col-12">
                                <section class="panel">
                                    <div class="panel-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                                        <div>
                                            <h2 class="h5 mb-1 section-title">
                                                <i class="bi bi-credit-card-2-front"></i>
                                                <span>Payment Method Distribution</span>
                                            </h2>
                                            <p class="text-muted mb-0">Breakdown of orders, revenue, and settlement status by payment method.</p>
                                        </div>
                                    </div>

                                    <div class="row g-3">
                                        <c:choose>
                                            <c:when test="${not empty paymentStats}">
                                                <c:forEach var="pm" items="${paymentStats}">
                                                    <div class="col-12 col-md-4">
                                                        <div class="border rounded-3 p-3 h-100" style="background: var(--admin-surface, #ffffff);">
                                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                                <span class="fw-bold fs-6">
                                                                    <c:choose>
                                                                        <c:when test="${pm.paymentMethod == 'VNPAY'}">
                                                                            <span class="badge text-bg-primary me-1">VNPAY</span> Electronic Gateway
                                                                        </c:when>
                                                                        <c:when test="${pm.paymentMethod == 'BANK_TRANSFER'}">
                                                                            <span class="badge text-bg-info me-1">BANK</span> Bank Transfer
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="badge text-bg-success me-1">COD</span> Cash on Delivery
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </span>
                                                                <span class="badge text-bg-light border">${pm.sharePct}%</span>
                                                            </div>

                                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                                <span class="text-muted small">Orders Volume:</span>
                                                                <strong class="text-body">${pm.orderCount} order(s)</strong>
                                                            </div>

                                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                                <span class="text-muted small">Total Value:</span>
                                                                <strong class="text-success"><fmt:formatNumber value="${pm.totalAmount}" pattern="#,##0"/> VND</strong>
                                                            </div>

                                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                                <span class="text-muted small">Successful Payments:</span>
                                                                <span class="badge text-bg-success">${pm.successCount} Success</span>
                                                            </div>

                                                            <div class="progress mt-2" style="height: 6px;">
                                                                <div class="progress-bar ${pm.paymentMethod == 'VNPAY' ? 'bg-primary' : (pm.paymentMethod == 'BANK_TRANSFER' ? 'bg-info' : 'bg-success')}" 
                                                                     style="width: ${pm.sharePct}%;" 
                                                                     role="progressbar" 
                                                                     aria-valuenow="${pm.sharePct}" 
                                                                     aria-valuemin="0" 
                                                                     aria-valuemax="100">
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="col-12 py-3 text-center text-muted">No payment method records found.</div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </section>
                            </div>
                        </div>

                        <!-- FILTER SECTION FOR DETAILED ORDERS -->
                        <section class="panel report-filter-panel mb-4">
                            <div class="panel-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                                <div>
                                    <h2 class="h5 mb-1 section-title">
                                        <i class="bi bi-funnel"></i>
                                        <span>Order List Filters</span>
                                    </h2>
                                    <p class="text-muted mb-0">Search and filter detailed order transactions.</p>
                                </div>

                                <!-- Quick Presets -->
                                <div class="btn-group btn-group-sm" role="group" aria-label="Preset filters">
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=orders&period=all&tableStatus=${tableStatus}&tablePaymentMethod=${tablePaymentMethod}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'all' ? 'active' : ''}">All</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=orders&period=today&tableStatus=${tableStatus}&tablePaymentMethod=${tablePaymentMethod}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'today' ? 'active' : ''}">Today</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=orders&period=this_week&tableStatus=${tableStatus}&tablePaymentMethod=${tablePaymentMethod}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'this_week' ? 'active' : ''}">This Week</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=orders&period=this_month&tableStatus=${tableStatus}&tablePaymentMethod=${tablePaymentMethod}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'this_month' ? 'active' : ''}">This Month</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=orders&period=last_30_days&tableStatus=${tableStatus}&tablePaymentMethod=${tablePaymentMethod}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'last_30_days' ? 'active' : ''}">Last 30 Days</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=orders&period=this_year&tableStatus=${tableStatus}&tablePaymentMethod=${tablePaymentMethod}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'this_year' ? 'active' : ''}">This Year</a>
                                </div>
                            </div>

                            <form action="${pageContext.request.contextPath}/Manager/Report" method="GET" class="row g-3 align-items-end report-table-filter-form report-order-table-filter-form">
                                <input type="hidden" name="tab" value="orders">

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Start Date</label>
                                    <input type="date" class="form-control form-control-sm" name="startDate" value="${startDate}" max="${today}">
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">End Date</label>
                                    <input type="date" class="form-control form-control-sm" name="endDate" value="${endDate}" max="${today}">
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Order Status</label>
                                    <select class="form-select form-select-sm" name="tableStatus">
                                        <option value="ALL" ${tableStatus == 'ALL' ? 'selected' : ''}>All Statuses</option>
                                        <option value="DELIVERED" ${tableStatus == 'DELIVERED' ? 'selected' : ''}>Delivered</option>
                                        <option value="SHIPPING" ${tableStatus == 'SHIPPING' ? 'selected' : ''}>Shipping</option>
                                        <option value="PENDING" ${tableStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                                        <option value="CONFIRMED" ${tableStatus == 'CONFIRMED' ? 'selected' : ''}>Confirmed</option>
                                        <option value="CANCELLED" ${tableStatus == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                                    </select>
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Payment Method</label>
                                    <select class="form-select form-select-sm" name="tablePaymentMethod">
                                        <option value="ALL" ${tablePaymentMethod == 'ALL' ? 'selected' : ''}>All Methods</option>
                                        <option value="COD" ${tablePaymentMethod == 'COD' ? 'selected' : ''}>COD</option>
                                        <option value="VNPAY" ${tablePaymentMethod == 'VNPAY' ? 'selected' : ''}>VNPay</option>
                                        <option value="BANK_TRANSFER" ${tablePaymentMethod == 'BANK_TRANSFER' ? 'selected' : ''}>Bank Transfer</option>
                                    </select>
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Keyword</label>
                                    <input type="text" class="form-control form-control-sm" name="tableKeyword"
                                           placeholder="ID, Customer, Email..." value="${tableKeyword}">
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Sort By</label>
                                    <select class="form-select form-select-sm" name="tableSort">
                                        <option value="date_desc" ${tableSort == 'date_desc' ? 'selected' : ''}>Newest Date</option>
                                        <option value="date_asc" ${tableSort == 'date_asc' ? 'selected' : ''}>Oldest Date</option>
                                        <option value="amount_desc" ${tableSort == 'amount_desc' ? 'selected' : ''}>Amount: High to Low</option>
                                        <option value="amount_asc" ${tableSort == 'amount_asc' ? 'selected' : ''}>Amount: Low to High</option>
                                        <option value="id_desc" ${tableSort == 'id_desc' ? 'selected' : ''}>Order ID: Desc</option>
                                        <option value="id_asc" ${tableSort == 'id_asc' ? 'selected' : ''}>Order ID: Asc</option>
                                    </select>
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-1">
                                    <label class="form-label small text-muted mb-1">Page Size</label>
                                    <select class="form-select form-select-sm" name="tablePageSize">
                                        <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                                        <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
                                        <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
                                    </select>
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-1 d-flex gap-1">
                                    <button type="submit" class="btn btn-primary btn-sm flex-fill" title="Filter">
                                        <i class="bi bi-search"></i>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=orders" class="btn btn-light btn-sm" title="Reset">
                                        <i class="bi bi-arrow-counterclockwise"></i>
                                    </a>
                                </div>
                            </form>
                        </section>

                        <!-- DETAILED ORDER LIST TABLE -->
                        <section class="panel">
                            <div class="panel-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                                <div>
                                    <h2 class="h5 mb-1 section-title">
                                        <i class="bi bi-list-check"></i>
                                        <span>Detailed Order Transactions</span>
                                    </h2>
                                    <p class="text-muted mb-0">
                                        Displaying ${ordersList.size()} order(s) on this page (Total: ${totalOrders}).
                                    </p>
                                </div>

                            </div>

                            <div class="table-responsive">
                                <table class="table align-middle mb-0" id="orderAnalysisTable">
                                    <thead>
                                        <tr>
                                            <th>Order ID</th>
                                            <th>Date</th>
                                            <th>Customer</th>
                                            <th>Phone</th>
                                            <th>Items</th>
                                            <th>Payment Method</th>
                                            <th>Payment Status</th>
                                            <th>Total Amount</th>
                                            <th>Order Status</th>
                                            <th class="text-end">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty ordersList}">
                                                <c:forEach var="ord" items="${ordersList}">
                                                    <tr>
                                                        <td class="fw-semibold">
                                                            <a href="${pageContext.request.contextPath}/Manager/OrderManagement?action=detail&id=${ord.orderID}" 
                                                               class="text-decoration-none">
                                                                #${ord.orderID}
                                                            </a>
                                                        </td>
                                                        <td>${ord.orderDate}</td>
                                                        <td>
                                                            <span class="fw-semibold">${ord.customerName}</span>
                                                            <c:if test="${not empty ord.customerEmail}">
                                                                <br><small class="text-muted">${ord.customerEmail}</small>
                                                            </c:if>
                                                        </td>
                                                        <td class="text-muted">${ord.shippingPhone}</td>
                                                        <td>
                                                            <span class="badge text-bg-light border">${ord.totalItems} item(s)</span>
                                                        </td>
                                                        <td>
                                                            <span class="badge text-bg-light border">${ord.paymentMethod}</span>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${ord.paymentStatus == 'SUCCESS'}">
                                                                    <span class="badge text-bg-success">Success</span>
                                                                </c:when>
                                                                <c:when test="${ord.paymentStatus == 'FAILED'}">
                                                                    <span class="badge text-bg-danger">Failed</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge text-bg-secondary">${ord.paymentStatus}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="fw-bold">
                                                            <fmt:formatNumber value="${ord.totalAmount}" pattern="#,##0"/> VND
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
                                                                <c:when test="${ord.orderStatus == 'CONFIRMED'}">
                                                                    <span class="badge text-bg-primary">Confirmed</span>
                                                                </c:when>
                                                                <c:when test="${ord.orderStatus == 'CANCELLED'}">
                                                                    <span class="badge text-bg-danger">Cancelled</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge text-bg-secondary">${ord.orderStatus}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="text-end">
                                                            <a href="${pageContext.request.contextPath}/Manager/OrderManagement?action=detail&id=${ord.orderID}" 
                                                               class="btn btn-light btn-sm">
                                                                Detail
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="10" class="text-center py-4 text-muted">
                                                        No orders found matching the filter criteria.
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>

                            <!-- SERVER-SIDE PAGINATION -->
                            <c:if test="${totalPages > 1}">
                                <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 p-3 border-top">
                                    <small class="text-muted">
                                        Page ${currentPage} of ${totalPages} — Total ${totalOrders} order(s)
                                    </small>

                                    <nav aria-label="Order analysis pagination">
                                        <ul class="pagination pagination-sm mb-0">

                                            <c:url var="previousUrl" value="/Manager/Report">
                                                <c:param name="tab" value="orders"/>
                                                <c:param name="period" value="${selectedPeriod}"/>
                                                <c:param name="startDate" value="${startDate}"/>
                                                <c:param name="endDate" value="${endDate}"/>
<c:param name="tableStatus" value="${tableStatus}"/>
<c:param name="tablePaymentMethod" value="${tablePaymentMethod}"/>
<c:param name="tableKeyword" value="${tableKeyword}"/>
                                                <c:param name="tableSort" value="${tableSort}"/>
<c:param name="tablePageSize" value="${pageSize}"/>
<c:param name="tablePage" value="${currentPage - 1}"/>
                                            </c:url>

                                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                                <a class="page-link" href="${previousUrl}">Previous</a>
                                            </li>

                                            <c:forEach var="pNum" begin="1" end="${totalPages}">
                                                <c:if test="${pNum == 1 || pNum == totalPages || (pNum >= currentPage - 2 && pNum <= currentPage + 2)}">
                                                    <c:url var="pageUrl" value="/Manager/Report">
                                                        <c:param name="tab" value="orders"/>
                                                        <c:param name="period" value="${selectedPeriod}"/>
                                                        <c:param name="startDate" value="${startDate}"/>
                                                        <c:param name="endDate" value="${endDate}"/>
<c:param name="tableStatus" value="${tableStatus}"/>
<c:param name="tablePaymentMethod" value="${tablePaymentMethod}"/>
<c:param name="tableKeyword" value="${tableKeyword}"/>
                                                        <c:param name="tableSort" value="${tableSort}"/>
<c:param name="tablePageSize" value="${pageSize}"/>
<c:param name="tablePage" value="${pNum}"/>
                                                    </c:url>

                                                    <li class="page-item ${pNum == currentPage ? 'active' : ''}">
                                                        <a class="page-link" href="${pageUrl}">${pNum}</a>
                                                    </li>
                                                </c:if>
                                            </c:forEach>

                                            <c:url var="nextUrl" value="/Manager/Report">
                                                <c:param name="tab" value="orders"/>
                                                <c:param name="period" value="${selectedPeriod}"/>
                                                <c:param name="startDate" value="${startDate}"/>
                                                <c:param name="endDate" value="${endDate}"/>
<c:param name="tableStatus" value="${tableStatus}"/>
<c:param name="tablePaymentMethod" value="${tablePaymentMethod}"/>
<c:param name="tableKeyword" value="${tableKeyword}"/>
                                                <c:param name="tableSort" value="${tableSort}"/>
<c:param name="tablePageSize" value="${pageSize}"/>
<c:param name="tablePage" value="${currentPage + 1}"/>
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

                <!-- FOOTER -->
                <footer class="admin-footer">
                    <div class="container-fluid px-3 px-lg-4">
                        <span>
                            Copyright 2026 Headphone Store.<br>
                            Manager Order Analysis
                        </span>
                        <span>Headphone Store E-commerce System.</span>
                    </div>
                </footer>

            </div>

        </div>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js?v=20261109-1"></script>

        <script>
            function exportOrdersToCSV() {
                var table = document.getElementById("orderAnalysisTable");
                if (!table) return;

                var csv = [];
                var rows = table.querySelectorAll("tr");

                for (var i = 0; i < rows.length; i++) {
                    if (rows[i].hidden) continue;
                    var row = [], cols = rows[i].querySelectorAll("td, th");

                    for (var j = 0; j < cols.length - 1; j++) { // exclude action column
                        var cleanText = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, " ").trim();
                        cleanText = cleanText.replace(/"/g, '""');
                        row.push('"' + cleanText + '"');
                    }
                    csv.push(row.join(","));
                }

                if (csv.length <= 1) {
                    alert("No order data available to export.");
                    return;
                }

                var csvContent = "data:text/csv;charset=utf-8,\uFEFF" + csv.join("\n");
                var encodedUri = encodeURI(csvContent);
                var link = document.createElement("a");
                link.setAttribute("href", encodedUri);
                link.setAttribute("download", "Orders_Analysis_" + new Date().toISOString().slice(0, 10) + ".csv");
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
        </script>

    </body>

</html>
