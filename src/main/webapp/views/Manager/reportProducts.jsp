<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="Headphone Store Manager - Product Performance Report">
        <title>Product Performance | Headphone Store</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css?v=20261109-1">
    </head>

    <body class="report-page report-products">

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
                                    <i class="bi bi-box-seam"></i>
                                </span>
                                <div>
                                    <p class="eyebrow mb-1">Manager / Analytics</p>
                                    <h1 class="h3 mb-1">Product Performance</h1>
                                    <p class="text-muted mb-0">
                                        Monitor units sold, order frequency, gross revenue, category, and brand sales metrics.
                                    </p>
                                </div>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-outline-secondary btn-sm" onclick="window.print()">
                                    <i class="bi bi-printer me-1"></i> Print
                                </button>
                                <button type="button" class="btn btn-primary btn-sm" onclick="exportProductsToCSV()">
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

                        <!-- KPI SUMMARY CARDS -->
                        <div class="report-kpi-grid row g-3 mb-4">
                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Total Products</p>
                                            <h2 class="h3 mb-1">${summary.totalProducts}</h2>
                                            <small class="text-primary">
                                                <i class="bi bi-check-circle me-1"></i>Catalog products evaluated
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
                                            <p class="text-muted mb-1">Total Units Sold</p>
                                            <h2 class="h3 mb-1 text-primary">${summary.totalUnitsSold}</h2>
                                            <small class="text-info">
                                                <i class="bi bi-headphones me-1"></i>Total volume across filtered items
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-basket"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="panel h-100">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <p class="text-muted mb-1">Total Product Revenue</p>
                                            <h2 class="h3 mb-1 text-success">
                                                <fmt:formatNumber value="${summary.totalRevenue}" pattern="#,##0"/> VND
                                            </h2>
                                            <small class="text-success">
                                                <i class="bi bi-cash me-1"></i>Gross product sales
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
                                            <p class="text-muted mb-1">Avg Revenue / Product</p>
                                            <h2 class="h3 mb-1">
                                                <fmt:formatNumber value="${summary.avgRevenuePerProduct}" pattern="#,##0"/> VND
                                            </h2>
                                            <small class="text-muted">
                                                <i class="bi bi-calculator me-1"></i>Per evaluated product
                                            </small>
                                        </div>
                                        <span class="page-icon">
                                            <i class="bi bi-bar-chart"></i>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- PRODUCT FILTER PANEL -->
                        <section class="panel report-filter-panel mb-4">
                            <div class="panel-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                                <div>
                                    <h2 class="h5 mb-1 section-title">
                                        <i class="bi bi-funnel"></i>
                                        <span>Product Filters & Controls</span>
                                    </h2>
                                    <p class="text-muted mb-0">Filter by category, brand, date range, search keyword, and sort order.</p>
                                </div>

                                <!-- Quick Presets -->
                                <div class="btn-group btn-group-sm" role="group" aria-label="Preset filters">
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=products&period=all&tableCategoryId=${tableCategoryId}&tableBrandId=${tableBrandId}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'all' ? 'active' : ''}">All</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=products&period=today&tableCategoryId=${tableCategoryId}&tableBrandId=${tableBrandId}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'today' ? 'active' : ''}">Today</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=products&period=this_week&tableCategoryId=${tableCategoryId}&tableBrandId=${tableBrandId}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'this_week' ? 'active' : ''}">This Week</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=products&period=this_month&tableCategoryId=${tableCategoryId}&tableBrandId=${tableBrandId}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'this_month' ? 'active' : ''}">This Month</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=products&period=last_30_days&tableCategoryId=${tableCategoryId}&tableBrandId=${tableBrandId}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'last_30_days' ? 'active' : ''}">Last 30 Days</a>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=products&period=this_year&tableCategoryId=${tableCategoryId}&tableBrandId=${tableBrandId}&tableSort=${tableSort}&tableKeyword=${tableKeyword}"
                                       class="btn btn-outline-primary ${selectedPeriod == 'this_year' ? 'active' : ''}">This Year</a>
                                </div>
                            </div>

                            <form action="${pageContext.request.contextPath}/Manager/Report" method="GET" class="row g-3 align-items-end report-table-filter-form report-product-table-filter-form">
                                <input type="hidden" name="tab" value="products">

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Start Date</label>
                                    <input type="date" class="form-control form-control-sm" name="startDate" value="${startDate}" max="${today}">
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">End Date</label>
                                    <input type="date" class="form-control form-control-sm" name="endDate" value="${endDate}" max="${today}">
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Category</label>
                                    <select class="form-select form-select-sm" name="tableCategoryId">
                                        <option value="">All Categories</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat.categoryID}" ${tableCategoryId == cat.categoryID ? 'selected' : ''}>
                                                ${cat.categoryName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Brand</label>
                                    <select class="form-select form-select-sm" name="tableBrandId">
                                        <option value="">All Brands</option>
                                        <c:forEach var="b" items="${brands}">
                                            <option value="${b.brandID}" ${tableBrandId == b.brandID ? 'selected' : ''}>
                                                ${b.brandName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Sort By</label>
                                    <select class="form-select form-select-sm" name="tableSort">
                                        <option value="revenue_desc" ${tableSort == 'revenue_desc' ? 'selected' : ''}>Revenue: High to Low</option>
                                        <option value="revenue_asc" ${tableSort == 'revenue_asc' ? 'selected' : ''}>Revenue: Low to High</option>
                                        <option value="units_desc" ${tableSort == 'units_desc' ? 'selected' : ''}>Units Sold: High to Low</option>
                                        <option value="units_asc" ${tableSort == 'units_asc' ? 'selected' : ''}>Units Sold: Low to High</option>
                                        <option value="orders_desc" ${tableSort == 'orders_desc' ? 'selected' : ''}>Order Count: High to Low</option>
                                        <option value="orders_asc" ${tableSort == 'orders_asc' ? 'selected' : ''}>Order Count: Low to High</option>
                                        <option value="name_asc" ${tableSort == 'name_asc' ? 'selected' : ''}>Name: A to Z</option>
                                        <option value="name_desc" ${tableSort == 'name_desc' ? 'selected' : ''}>Name: Z to A</option>
                                        <option value="id_desc" ${tableSort == 'id_desc' ? 'selected' : ''}>Product ID: Newest First</option>
                                        <option value="id_asc" ${tableSort == 'id_asc' ? 'selected' : ''}>Product ID: Oldest First</option>
                                    </select>
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Keyword</label>
                                    <input type="text" class="form-control form-control-sm" name="tableKeyword"
                                           placeholder="Product Name or ID..." value="${tableKeyword}">
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2">
                                    <label class="form-label small text-muted mb-1">Page Size</label>
                                    <select class="form-select form-select-sm" name="tablePageSize">
                                        <option value="10" ${pageSize == 10 ? 'selected' : ''}>10 per page</option>
                                        <option value="20" ${pageSize == 20 ? 'selected' : ''}>20 per page</option>
                                        <option value="50" ${pageSize == 50 ? 'selected' : ''}>50 per page</option>
                                    </select>
                                </div>

                                <div class="col-12 col-sm-6 col-md-3 col-xl-2 d-flex gap-2">
                                    <button type="submit" class="btn btn-primary btn-sm flex-fill">
                                        <i class="bi bi-search me-1"></i> Filter
                                    </button>
                                    <a href="${pageContext.request.contextPath}/Manager/Report?tab=products" class="btn btn-light btn-sm">
                                        Reset
                                    </a>
                                </div>
                            </form>
                        </section>

                        <!-- PRODUCT PERFORMANCE DATA TABLE -->
                        <section class="panel">
                            <div class="panel-header d-flex flex-wrap justify-content-between align-items-center gap-2">
                                <div>
                                    <h2 class="h5 mb-1 section-title">
                                        <i class="bi bi-trophy"></i>
                                        <span>Product Sales & Volume Breakdown</span>
                                    </h2>
                                    <p class="text-muted mb-0">
                                        Displaying ${productList.size()} product(s) on this page (Total: ${totalItems}).
                                    </p>
                                </div>

                            </div>

                            <div class="table-responsive">
                                <table class="table align-middle mb-0" id="productPerfTable">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>
                                                <c:url var="sortIdUrl" value="/Manager/Report">
                                                    <c:param name="tab" value="products"/>
                                                    <c:param name="period" value="${selectedPeriod}"/>
                                                    <c:param name="startDate" value="${startDate}"/>
                                                    <c:param name="endDate" value="${endDate}"/>
<c:param name="tableCategoryId" value="${tableCategoryId}"/>
<c:param name="tableBrandId" value="${tableBrandId}"/>
<c:param name="tableKeyword" value="${tableKeyword}"/>
<c:param name="tablePageSize" value="${pageSize}"/>
                                                    <c:param name="tableSort" value="${tableSort == 'id_desc' ? 'id_asc' : 'id_desc'}"/>
                                                </c:url>
                                                <a href="${sortIdUrl}" class="text-decoration-none text-muted">
                                                    Product ID <i class="bi bi-arrow-down-up small"></i>
                                                </a>
                                            </th>
                                            <th>
                                                <c:url var="sortNameUrl" value="/Manager/Report">
                                                    <c:param name="tab" value="products"/>
                                                    <c:param name="period" value="${selectedPeriod}"/>
                                                    <c:param name="startDate" value="${startDate}"/>
                                                    <c:param name="endDate" value="${endDate}"/>
<c:param name="tableCategoryId" value="${tableCategoryId}"/>
<c:param name="tableBrandId" value="${tableBrandId}"/>
<c:param name="tableKeyword" value="${tableKeyword}"/>
<c:param name="tablePageSize" value="${pageSize}"/>
                                                    <c:param name="tableSort" value="${tableSort == 'name_asc' ? 'name_desc' : 'name_asc'}"/>
                                                </c:url>
                                                <a href="${sortNameUrl}" class="text-decoration-none text-muted">
                                                    Product Name <i class="bi bi-arrow-down-up small"></i>
                                                </a>
                                            </th>
                                            <th>Brand</th>
                                            <th>Category</th>
                                            <th class="text-end">Unit Price</th>
                                            <th class="text-center">
                                                <c:url var="sortUnitsUrl" value="/Manager/Report">
                                                    <c:param name="tab" value="products"/>
                                                    <c:param name="period" value="${selectedPeriod}"/>
                                                    <c:param name="startDate" value="${startDate}"/>
                                                    <c:param name="endDate" value="${endDate}"/>
<c:param name="tableCategoryId" value="${tableCategoryId}"/>
<c:param name="tableBrandId" value="${tableBrandId}"/>
<c:param name="tableKeyword" value="${tableKeyword}"/>
<c:param name="tablePageSize" value="${pageSize}"/>
                                                    <c:param name="tableSort" value="${tableSort == 'units_desc' ? 'units_asc' : 'units_desc'}"/>
                                                </c:url>
                                                <a href="${sortUnitsUrl}" class="text-decoration-none text-muted">
                                                    Units Sold <i class="bi bi-arrow-down-up small"></i>
                                                </a>
                                            </th>
                                            <th class="text-center">
                                                <c:url var="sortOrdersUrl" value="/Manager/Report">
                                                    <c:param name="tab" value="products"/>
                                                    <c:param name="period" value="${selectedPeriod}"/>
                                                    <c:param name="startDate" value="${startDate}"/>
                                                    <c:param name="endDate" value="${endDate}"/>
<c:param name="tableCategoryId" value="${tableCategoryId}"/>
<c:param name="tableBrandId" value="${tableBrandId}"/>
<c:param name="tableKeyword" value="${tableKeyword}"/>
<c:param name="tablePageSize" value="${pageSize}"/>
                                                    <c:param name="tableSort" value="${tableSort == 'orders_desc' ? 'orders_asc' : 'orders_desc'}"/>
                                                </c:url>
                                                <a href="${sortOrdersUrl}" class="text-decoration-none text-muted">
                                                    Order Count <i class="bi bi-arrow-down-up small"></i>
                                                </a>
                                            </th>
                                            <th class="text-end">
                                                <c:url var="sortRevUrl" value="/Manager/Report">
                                                    <c:param name="tab" value="products"/>
                                                    <c:param name="period" value="${selectedPeriod}"/>
                                                    <c:param name="startDate" value="${startDate}"/>
                                                    <c:param name="endDate" value="${endDate}"/>
<c:param name="tableCategoryId" value="${tableCategoryId}"/>
<c:param name="tableBrandId" value="${tableBrandId}"/>
<c:param name="tableKeyword" value="${tableKeyword}"/>
<c:param name="tablePageSize" value="${pageSize}"/>
                                                    <c:param name="tableSort" value="${tableSort == 'revenue_desc' ? 'revenue_asc' : 'revenue_desc'}"/>
                                                </c:url>
                                                <a href="${sortRevUrl}" class="text-decoration-none text-muted">
                                                    Revenue <i class="bi bi-arrow-down-up small"></i>
                                                </a>
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty productList}">
                                                <c:forEach var="p" items="${productList}">
                                                    <tr>
                                                        <td>
                                                            <span class="badge ${p.rank == 1 ? 'text-bg-warning' : (p.rank == 2 ? 'text-bg-secondary' : 'text-bg-light')}">
                                                                #${p.rank}
                                                            </span>
                                                        </td>
                                                        <td class="fw-semibold">
                                                            <a href="${pageContext.request.contextPath}/Manager/products?action=detail&id=${p.productID}" 
                                                               class="text-decoration-none">
                                                                #${p.productID}
                                                            </a>
                                                        </td>
                                                        <td>
                                                            <span class="fw-semibold text-body">${p.productName}</span>
                                                        </td>
                                                        <td>
                                                            <span class="badge text-bg-light border">${p.brandName}</span>
                                                        </td>
                                                        <td>
                                                            <span class="badge text-bg-light">${p.categoryName}</span>
                                                        </td>
                                                        <td class="text-end text-muted">
                                                            <fmt:formatNumber value="${p.price}" pattern="#,##0"/> VND
                                                        </td>
                                                        <td class="text-center fw-bold text-primary">
                                                            ${p.unitsSold}
                                                        </td>
                                                        <td class="text-center">
                                                            <span class="badge text-bg-light border">${p.orderCount}</span>
                                                        </td>
                                                        <td class="text-end fw-bold text-success">
                                                            <fmt:formatNumber value="${p.revenue}" pattern="#,##0"/> VND
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="9" class="text-center py-4 text-muted">
                                                        No product performance data matches current filters.
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
                                        Page ${currentPage} of ${totalPages} — Total ${totalItems} product(s)
                                    </small>

                                    <nav aria-label="Product performance pagination">
                                        <ul class="pagination pagination-sm mb-0">

                                            <c:url var="previousUrl" value="/Manager/Report">
                                                <c:param name="tab" value="products"/>
                                                <c:param name="period" value="${selectedPeriod}"/>
                                                <c:param name="startDate" value="${startDate}"/>
                                                <c:param name="endDate" value="${endDate}"/>
<c:param name="tableCategoryId" value="${tableCategoryId}"/>
<c:param name="tableBrandId" value="${tableBrandId}"/>
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
                                                        <c:param name="tab" value="products"/>
                                                        <c:param name="period" value="${selectedPeriod}"/>
                                                        <c:param name="startDate" value="${startDate}"/>
                                                        <c:param name="endDate" value="${endDate}"/>
<c:param name="tableCategoryId" value="${tableCategoryId}"/>
<c:param name="tableBrandId" value="${tableBrandId}"/>
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
                                                <c:param name="tab" value="products"/>
                                                <c:param name="period" value="${selectedPeriod}"/>
                                                <c:param name="startDate" value="${startDate}"/>
                                                <c:param name="endDate" value="${endDate}"/>
<c:param name="tableCategoryId" value="${tableCategoryId}"/>
<c:param name="tableBrandId" value="${tableBrandId}"/>
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
                            Manager Product Performance
                        </span>
                        <span>Headphone Store E-commerce System.</span>
                    </div>
                </footer>

            </div>

        </div>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js?v=20261109-1"></script>

        <script>
            function exportProductsToCSV() {
                var table = document.getElementById("productPerfTable");
                if (!table) return;

                var csv = [];
                var rows = table.querySelectorAll("tr");

                for (var i = 0; i < rows.length; i++) {
                    if (rows[i].hidden) continue;
                    var row = [], cols = rows[i].querySelectorAll("td, th");

                    for (var j = 0; j < cols.length; j++) {
                        var cleanText = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, " ").trim();
                        cleanText = cleanText.replace(/"/g, '""');
                        row.push('"' + cleanText + '"');
                    }
                    csv.push(row.join(","));
                }

                if (csv.length <= 1) {
                    alert("No product performance data available to export.");
                    return;
                }

                var csvContent = "data:text/csv;charset=utf-8,\uFEFF" + csv.join("\n");
                var encodedUri = encodeURI(csvContent);
                var link = document.createElement("a");
                link.setAttribute("href", encodedUri);
                link.setAttribute("download", "Product_Performance_" + new Date().toISOString().slice(0, 10) + ".csv");
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
        </script>

    </body>

</html>
