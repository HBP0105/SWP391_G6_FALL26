<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="Headphone Store Manager - Revenue Analysis">
        <title>Revenue Analysis | Headphone Store</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css?v=20261109-1">
    </head>

    <body class="report-page">

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
                                    <i class="bi bi-graph-up-arrow"></i>
                                </span>
                                <div>
                                    <p class="eyebrow mb-1">Manager / Analytics</p>
                                    <h1 class="h3 mb-1">Revenue Analysis</h1>
                                    <p class="text-muted mb-0">
                                        Analyze sales revenue over time, average order value, revenue trends, and payment performance.
                                    </p>
                                </div>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-outline-secondary btn-sm" onclick="window.print()">
                                    <i class="bi bi-printer me-1"></i> Print
                                </button>
                                <button type="button" class="btn btn-primary btn-sm" onclick="exportRevenueToCSV()">
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

                        <!-- DATE FILTER SECTION -->
                        <section class="panel report-filter-panel mb-4">
                            <div class="panel-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                                <div>
                                    <h2 class="h5 mb-1 section-title">
                                        <i class="bi bi-calendar-range"></i>
                                        <span>Revenue Filters</span>
                                    </h2>
                                    <p class="text-muted mb-0">Select a date range or preset period to analyze revenue metrics.</p>
                                </div>

                                <!-- Quick Presets -->
                                <div class="btn-group btn-group-sm" role="group" aria-label="Preset filters">
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=revenue&period=all&groupBy=${groupBy}" 
                                       class="btn btn-outline-primary ${selectedPeriod == 'all' ? 'active' : ''}">All</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=revenue&period=today&groupBy=day" 
                                       class="btn btn-outline-primary ${selectedPeriod == 'today' ? 'active' : ''}">Today</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=revenue&period=last_7_days&groupBy=day" 
                                       class="btn btn-outline-primary ${selectedPeriod == 'last_7_days' ? 'active' : ''}">Last 7 Days</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=revenue&period=this_week&groupBy=day" 
                                       class="btn btn-outline-primary ${selectedPeriod == 'this_week' ? 'active' : ''}">This Week</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=revenue&period=this_month&groupBy=${groupBy}" 
                                       class="btn btn-outline-primary ${selectedPeriod == 'this_month' ? 'active' : ''}">This Month</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=revenue&period=last_30_days&groupBy=day" 
                                       class="btn btn-outline-primary ${selectedPeriod == 'last_30_days' ? 'active' : ''}">Last 30 Days</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=revenue&period=this_year&groupBy=month&year=${currentYear}" 
                                       class="btn btn-outline-primary ${selectedPeriod == 'this_year' ? 'active' : ''}">This Year</a>
                                </div>
                            </div>

                            <form action="${pageContext.request.contextPath}/Manager/Report" method="GET" class="row g-3 align-items-end">
                                <input type="hidden" name="tab" value="revenue">

                                <div class="col-12 col-md-3">
                                    <label class="form-label small text-muted mb-1">Start Date</label>
                                    <input type="date" class="form-control form-control-sm" name="startDate" value="${startDate}" max="${today}">
                                </div>

                                <div class="col-12 col-md-3">
                                    <label class="form-label small text-muted mb-1">End Date</label>
                                    <input type="date" class="form-control form-control-sm" name="endDate" value="${endDate}" max="${today}">
                                </div>

                                <div class="col-12 col-md-2">
                                    <label class="form-label small text-muted mb-1">Group By</label>
                                    <select class="form-select form-select-sm" name="groupBy">
                                        <option value="month" ${groupBy == 'month' ? 'selected' : ''}>Monthly</option>
                                        <option value="day" ${groupBy == 'day' ? 'selected' : ''}>Daily</option>
                                    </select>
                                </div>

                                <div class="col-12 col-md-2">
                                    <label class="form-label small text-muted mb-1">Year</label>
                                    <select class="form-select form-select-sm" name="year">
                                        <option value="2026" ${currentYear == 2026 ? 'selected' : ''}>2026</option>
                                        <option value="2025" ${currentYear == 2025 ? 'selected' : ''}>2025</option>
                                        <option value="2024" ${currentYear == 2024 ? 'selected' : ''}>2024</option>
                                    </select>
                                </div>

                                <div class="col-12 col-md-2 d-flex gap-2">
                                    <button type="submit" class="btn btn-primary btn-sm flex-fill">
                                        <i class="bi bi-funnel me-1"></i> Apply
                                    </button>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=revenue" class="btn btn-light btn-sm">
                                        Reset
                                    </a>
                                </div>
                            </form>
                        </section>

                        <!-- REVENUE KPI CARDS -->
                        <div class="report-kpi-grid row g-3 mb-4">
                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Total Revenue</p>
                                            <h2 class="h3 mb-1 text-success">
                                                <fmt:formatNumber value="${revenueStats.totalRevenue}" pattern="#,##0"/> VND
                                            </h2>
                                            <small class="text-success">
                                                <i class="bi bi-check-circle me-1"></i>Excludes cancelled orders
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
                                            <p class="text-muted mb-1">Average Order Value</p>
                                            <h2 class="h3 mb-1 text-primary">
                                                <fmt:formatNumber value="${revenueStats.avgOrderValue}" pattern="#,##0"/> VND
                                            </h2>
                                            <small class="text-muted">
                                                <i class="bi bi-calculator me-1"></i>Across ${revenueStats.validOrders} valid orders
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-receipt"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Total Units Sold</p>
                                            <h2 class="h3 mb-1">${revenueStats.unitsSold}</h2>
                                            <small class="text-info">
                                                <i class="bi bi-headphones me-1"></i>Headphone items ordered
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-box-seam"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Delivered Revenue</p>
                                            <h2 class="h3 mb-1 text-body">
                                                <fmt:formatNumber value="${revenueStats.deliveredRevenue}" pattern="#,##0"/> VND
                                            </h2>
                                            <small class="text-success">
                                                <i class="bi bi-truck me-1"></i>Fully completed & paid
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-shield-check"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- REVENUE BY STATUS IMPACT -->
                        <div class="row g-3 mb-4">
                            <div class="col-12 col-md-4">
                                <div class="panel p-3 h-100 border-start border-4 border-info">
                                    <p class="text-muted mb-1 small">In-Transit (Shipping) Revenue</p>
                                    <h4 class="mb-0 text-info">
                                        <fmt:formatNumber value="${revenueStats.shippingRevenue}" pattern="#,##0"/> VND
                                    </h4>
                                    <small class="text-muted">Currently in courier delivery</small>
                                </div>
                            </div>

                            <div class="col-12 col-md-4">
                                <div class="panel p-3 h-100 border-start border-4 border-warning">
                                    <p class="text-muted mb-1 small">Pending Order Revenue</p>
                                    <h4 class="mb-0 text-warning">
                                        <fmt:formatNumber value="${revenueStats.pendingRevenue}" pattern="#,##0"/> VND
                                    </h4>
                                    <small class="text-muted">Awaiting confirmation/packing</small>
                                </div>
                            </div>

                            <div class="col-12 col-md-4">
                                <div class="panel p-3 h-100 border-start border-4 border-danger">
                                    <p class="text-muted mb-1 small">Cancelled Revenue (Lost)</p>
                                    <h4 class="mb-0 text-danger">
                                        <fmt:formatNumber value="${revenueStats.cancelledRevenue}" pattern="#,##0"/> VND
                                    </h4>
                                    <small class="text-muted">Potential sales cancelled by buyer/store</small>
                                </div>
                            </div>
                        </div>

                        <!-- REVENUE TREND VISUAL CHART -->
                        <div class="row g-3 mb-4">
                            <div class="col-12 col-xl-8">
                                <section class="panel h-100">
                                    <div class="panel-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                                        <div>
                                            <h2 class="h5 mb-1 section-title">
                                                <i class="bi bi-bar-chart"></i>
                                                <span>Revenue Trend (${groupBy == 'day' ? 'Daily' : 'Monthly'})</span>
                                            </h2>
                                            <p class="text-muted mb-0">
                                                <c:choose>
                                                    <c:when test="${groupBy == 'day'}">
                                                        Daily sales revenue progression for selected date interval.
                                                    </c:when>
                                                    <c:otherwise>
                                                        Monthly gross headphone sales for Year ${currentYear}.
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>

                                        <div class="small text-muted">
                                            <span class="badge text-bg-light border me-1">
                                                <i class="bi bi-arrow-repeat me-1"></i>Grouped: ${groupBy == 'day' ? 'Daily' : 'Monthly'}
                                            </span>
                                        </div>
                                    </div>

                                    <c:choose>
                                        <c:when test="${not empty revenueTrend}">
                                            <div class="chart-bars" style="grid-template-columns: repeat(${revenueTrend.size() > 0 ? revenueTrend.size() : 12}, minmax(16px, 1fr));">
                                                <c:forEach var="item" items="${revenueTrend}">
                                                    <div class="chart-column" title="${item.periodLabel}: <fmt:formatNumber value='${item.revenue}' pattern='#,##0'/> VND (${item.ordersCount} orders, ${item.unitsSold} units)">
                                                        <span style="--bar-size: ${item.barHeight}%;"></span>
                                                        ${item.periodLabel}
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center py-5 text-muted">
                                                No revenue records recorded in this timeframe.
                                            </div>
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="d-flex flex-wrap justify-content-between align-items-center mt-3 pt-2 border-top text-muted small gap-2">
                                        <span><i class="bi bi-info-circle me-1"></i>Hover over any bar to view revenue, order count, and units sold.</span>
                                        <span>Total Periods: ${revenueTrend.size()}</span>
                                    </div>
                                </section>
                            </div>

                            <!-- PAYMENT METHOD REVENUE BREAKDOWN -->
                            <div class="col-12 col-xl-4">
                                <section class="panel h-100 d-flex flex-column">
                                    <div class="panel-header">
                                        <h2 class="h5 mb-1 section-title">
                                            <i class="bi bi-credit-card"></i>
                                            <span>Revenue by Payment Method</span>
                                        </h2>
                                        <p class="text-muted mb-0">Gross sales distribution across payment gateways.</p>
                                    </div>

                                    <div class="d-flex flex-column gap-3 my-auto py-2">
                                        <c:choose>
                                            <c:when test="${not empty paymentBreakdown}">
                                                <c:forEach var="pm" items="${paymentBreakdown}">
                                                    <div>
                                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                                            <span class="fw-semibold">
                                                                <c:choose>
                                                                    <c:when test="${pm.paymentMethod == 'VNPAY'}">
                                                                        <i class="bi bi-qr-code text-primary me-1"></i> VNPay
                                                                    </c:when>
                                                                    <c:when test="${pm.paymentMethod == 'BANK_TRANSFER'}">
                                                                        <i class="bi bi-bank text-info me-1"></i> Bank Transfer
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <i class="bi bi-cash text-success me-1"></i> COD (Cash on Delivery)
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                            <span class="text-muted small">
                                                                ${pm.ordersCount} orders | 
                                                                <strong class="text-body"><fmt:formatNumber value="${pm.revenue}" pattern="#,##0"/> VND</strong>
                                                                (${pm.sharePct}%)
                                                            </span>
                                                        </div>
                                                        <div class="progress" style="height: 8px;">
                                                            <div class="progress-bar ${pm.paymentMethod == 'VNPAY' ? 'bg-primary' : (pm.paymentMethod == 'BANK_TRANSFER' ? 'bg-info' : 'bg-success')}" 
                                                                 role="progressbar" 
                                                                 style="width: ${pm.sharePct}%;" 
                                                                 aria-valuenow="${pm.sharePct}" 
                                                                 aria-valuemin="0" 
                                                                 aria-valuemax="100">
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <p class="text-center text-muted py-4 mb-0">No payment records found.</p>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="mt-auto pt-3 border-top text-muted small">
                                        <i class="bi bi-shield-lock me-1"></i>All figures derived from non-cancelled transactions.
                                    </div>
                                </section>
                            </div>
                        </div>

                        <!-- DETAILED REVENUE TREND TABLE -->
                        <section class="panel">
                            <div class="panel-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                                <div>
                                    <h2 class="h5 mb-1 section-title">
                                        <i class="bi bi-table"></i>
                                        <span>Revenue Timeline Breakdown</span>
                                    </h2>
                                    <p class="text-muted mb-0">Tabular breakdown with filters independent from the chart and KPI cards.</p>
                                </div>
                            </div>

                            <form action="${pageContext.request.contextPath}/Manager/Report" method="GET"
                                  class="row g-2 align-items-end report-table-filter-form report-revenue-table-filter-form mb-3">
                                <input type="hidden" name="tab" value="revenue">
                                <input type="hidden" name="period" value="${selectedPeriod}">
                                <input type="hidden" name="startDate" value="${startDate}">
                                <input type="hidden" name="endDate" value="${endDate}">
                                <input type="hidden" name="groupBy" value="${groupBy}">
                                <input type="hidden" name="year" value="${currentYear}">

                                <div class="col-12 col-md">
                                    <label class="form-label small text-muted mb-1">Search Period</label>
                                    <input type="search" class="form-control form-control-sm" name="tableKeyword"
                                           value="${tableKeyword}" placeholder="Month, quarter or year">
                                </div>
                                <div class="col-12 col-sm-7 col-md-4 col-xl-3">
                                    <label class="form-label small text-muted mb-1">Sort</label>
                                    <select class="form-select form-select-sm" name="tableSort">
                                        <option value="period_asc" ${tableSort == 'period_asc' ? 'selected' : ''}>Period: Ascending</option>
                                        <option value="period_desc" ${tableSort == 'period_desc' ? 'selected' : ''}>Period: Descending</option>
                                        <option value="revenue_desc" ${tableSort == 'revenue_desc' ? 'selected' : ''}>Revenue: High to Low</option>
                                        <option value="revenue_asc" ${tableSort == 'revenue_asc' ? 'selected' : ''}>Revenue: Low to High</option>
                                        <option value="orders_desc" ${tableSort == 'orders_desc' ? 'selected' : ''}>Orders: High to Low</option>
                                        <option value="orders_asc" ${tableSort == 'orders_asc' ? 'selected' : ''}>Orders: Low to High</option>
                                    </select>
                                </div>
                                <div class="col-12 col-sm-auto d-flex gap-2">
                                    <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-search me-1"></i>Filter</button>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=revenue&period=${selectedPeriod}&startDate=${startDate}&endDate=${endDate}&groupBy=${groupBy}&year=${currentYear}"
                                       class="btn btn-light btn-sm">Reset</a>
                                </div>
                            </form>

                            <div class="table-responsive">
                                <table class="table align-middle mb-0" id="revenueTrendTable">
                                    <thead>
                                        <tr>
                                            <th>Period</th>
                                            <th>Orders Count</th>
                                            <th>Units Sold</th>
                                            <th>Average Order Value</th>
                                            <th>Total Revenue</th>
                                            <th>Trend / Visual Share</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty revenueTable}">
                                                <c:forEach var="t" items="${revenueTable}">
                                                    <tr>
                                                        <td class="fw-semibold">
                                                            <i class="bi bi-calendar3 me-1 text-muted"></i>
                                                            ${t.periodLabel}
                                                        </td>
                                                        <td>
                                                            <span class="badge text-bg-light border">${t.ordersCount} orders</span>
                                                        </td>
                                                        <td>
                                                            <span class="text-muted">${t.unitsSold} units</span>
                                                        </td>
                                                        <td class="fw-semibold">
                                                            <fmt:formatNumber value="${t.avgOrderValue}" pattern="#,##0"/> VND
                                                        </td>
                                                        <td class="fw-bold text-success">
                                                            <fmt:formatNumber value="${t.revenue}" pattern="#,##0"/> VND
                                                        </td>
                                                        <td style="min-width: 140px;">
                                                            <div class="d-flex align-items-center gap-2">
                                                                <div class="progress flex-grow-1" style="height: 6px;">
                                                                    <div class="progress-bar bg-success" 
                                                                         style="width: ${t.barHeight}%;" 
                                                                         role="progressbar" 
                                                                         aria-valuenow="${t.barHeight}" 
                                                                         aria-valuemin="0" 
                                                                         aria-valuemax="100">
                                                                    </div>
                                                                </div>
                                                                <small class="text-muted">${t.barHeight}%</small>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="6" class="text-center py-4 text-muted">
                                                        No timeline data available for the chosen filters.
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
                            Copyright 2026 Headphone Store.<br>
                            Manager Revenue Analysis
                        </span>
                        <span>Headphone Store E-commerce System.</span>
                    </div>
                </footer>

            </div>

        </div>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js?v=20261109-1"></script>

        <script>
            function exportRevenueToCSV() {
                var table = document.getElementById("revenueTrendTable");
                if (!table) return;

                var csv = [];
                var rows = table.querySelectorAll("tr");

                for (var i = 0; i < rows.length; i++) {
                    if (rows[i].hidden) continue;
                    var row = [], cols = rows[i].querySelectorAll("td, th");

                    for (var j = 0; j < cols.length - 1; j++) { // exclude visual trend column
                        var cleanText = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, " ").trim();
                        cleanText = cleanText.replace(/"/g, '""');
                        row.push('"' + cleanText + '"');
                    }
                    csv.push(row.join(","));
                }

                if (csv.length <= 1) {
                    alert("No revenue data available to export.");
                    return;
                }

                var csvContent = "data:text/csv;charset=utf-8,\uFEFF" + csv.join("\n");
                var encodedUri = encodeURI(csvContent);
                var link = document.createElement("a");
                link.setAttribute("href", encodedUri);
                link.setAttribute("download", "Revenue_Analysis_" + new Date().toISOString().slice(0, 10) + ".csv");
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
        </script>

    </body>

</html>
