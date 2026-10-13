<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

        <title>Inventory | Headphone Store</title>

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
                       href="${pageContext.request.contextPath}/Manager/Dashboard">

                        <span class="brand-icon">
                            <i class="bi bi-headphones"></i>
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
                                    aria-label="Switch color theme"
                                    title="Switch color theme">

                                <i class="bi bi-moon-stars"
                                   data-theme-icon>
                                </i>

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

                                    <a class="dropdown-item"
                                       href="${pageContext.request.contextPath}/Manager/OrderManagement">

                                        <span class="notification-title">
                                            Order management
                                        </span>

                                        <span class="notification-time">
                                            View orders
                                        </span>

                                    </a>


                                    <a class="dropdown-item"
                                       href="${pageContext.request.contextPath}/Manager/Inventory">

                                        <span class="notification-title">
                                            Inventory management
                                        </span>

                                        <span class="notification-time">
                                            View stock
                                        </span>

                                    </a>

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
                                           href="${pageContext.request.contextPath}/Manager/profile">

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

                        <div class="page-heading">

                            <div class="page-heading-copy">

                                <span class="page-icon">

                                    <i class="bi bi-boxes"></i>

                                </span>


                                <div>

                                    <p class="eyebrow mb-1">
                                        Manager
                                    </p>

                                    <h1 class="h3 mb-1">
                                        Inventory
                                    </h1>

                                    <p class="text-muted mb-0">
                                        Monitor product stock and manage inventory transactions.
                                    </p>

                                </div>

                            </div>

                        </div>

                        <section class="row g-3 mb-3">

                            <div class="col-12 col-md-6 col-xl-3">

                                <a href="${pageContext.request.contextPath}/Manager/Inventory"
                                   class="text-decoration-none text-reset d-block">

                                    <div class="panel h-100">

                                        <div class="d-flex align-items-center gap-3">

                                            <span class="page-icon">

                                                <i class="bi bi-box-seam"></i>

                                            </span>

                                            <div>

                                                <p class="text-muted mb-1">
                                                    Total Products
                                                </p>

                                                <h2 class="h4 mb-0">
                                                    ${totalProducts}
                                                </h2>

                                            </div>

                                        </div>

                                    </div>

                                </a>

                            </div>

                            <div class="col-12 col-md-6 col-xl-3">

                                <a href="${pageContext.request.contextPath}/Manager/Inventory?stock=in"
                                   class="text-decoration-none text-reset d-block">

                                    <div class="panel h-100">

                                        <div class="d-flex align-items-center gap-3">

                                            <span class="page-icon">

                                                <i class="bi bi-check-circle"></i>

                                            </span>

                                            <div>

                                                <p class="text-muted mb-1">
                                                    In Stock
                                                </p>

                                                <h2 class="h4 mb-0">
                                                    ${inStockProducts}
                                                </h2>

                                            </div>

                                        </div>

                                    </div>

                                </a>

                            </div>

                            <div class="col-12 col-md-6 col-xl-3">

                                <a href="${pageContext.request.contextPath}/Manager/Inventory?stock=low"
                                   class="text-decoration-none text-reset d-block">

                                    <div class="panel h-100">

                                        <div class="d-flex align-items-center gap-3">

                                            <span class="page-icon">

                                                <i class="bi bi-exclamation-triangle"></i>

                                            </span>

                                            <div>

                                                <p class="text-muted mb-1">
                                                    Low Stock
                                                </p>

                                                <h2 class="h4 mb-0">
                                                    ${lowStockProducts}
                                                </h2>

                                            </div>

                                        </div>

                                    </div>

                                </a>

                            </div>

                            <div class="col-12 col-md-6 col-xl-3">

                                <a href="${pageContext.request.contextPath}/Manager/Inventory?stock=out"
                                   class="text-decoration-none text-reset d-block">

                                    <div class="panel h-100">

                                        <div class="d-flex align-items-center gap-3">

                                            <span class="page-icon">

                                                <i class="bi bi-x-circle"></i>

                                            </span>

                                            <div>

                                                <p class="text-muted mb-1">
                                                    Out of Stock
                                                </p>

                                                <h2 class="h4 mb-0">
                                                    ${outOfStockProducts}
                                                </h2>

                                            </div>

                                        </div>

                                    </div>

                                </a>

                            </div>

                        </section>

                        <section class="panel">

                            <div class="panel-header">

                                <div>

                                    <h2 class="h5 mb-1 section-title">

                                        <i class="bi bi-boxes"></i>

                                        <span>
                                            Stock Inventory
                                        </span>

                                    </h2>

                                    <p class="text-muted mb-0">
                                        ${totalItems} product(s) found.
                                    </p>

                                </div>

                            </div>

                            <!-- Server-side search & filter form -->
                            <div class="px-3 pt-3 pb-2">
                                <form method="get"
                                      action="${pageContext.request.contextPath}/Manager/Inventory"
                                      class="row g-3 align-items-end">

                                    <div class="col-xl-3 col-lg-4 col-md-6">
                                        <label class="form-label">Search</label>
                                        <input class="form-control"
                                               type="search"
                                               name="keyword"
                                               value="${keyword}"
                                               placeholder="Product or category name">
                                    </div>

                                    <div class="col-xl-3 col-lg-4 col-md-6">
                                        <label class="form-label">Category</label>
                                        <select name="category" class="form-select">
                                            <option value="">All Categories</option>
                                            <c:forEach var="category" items="${categories}">
                                                <option value="${category.categoryId}"
                                                        ${selectedCategory == category.categoryId ? 'selected' : ''}>
                                                    ${category.categoryName}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div class="col-xl-2 col-lg-4 col-md-6">
                                        <label class="form-label">Stock Status</label>
                                        <select name="stock" class="form-select">
                                            <option value="">All Stock</option>
                                            <option value="in" ${selectedStock == 'in' ? 'selected' : ''}>
                                                In Stock
                                            </option>
                                            <option value="low" ${selectedStock == 'low' ? 'selected' : ''}>
                                                Low Stock
                                            </option>
                                            <option value="out" ${selectedStock == 'out' ? 'selected' : ''}>
                                                Out of Stock
                                            </option>
                                        </select>
                                    </div>

                                    <div class="col-xl-2 col-lg-4 col-md-6">
                                        <label class="form-label">Sort By</label>
                                        <select name="sort" class="form-select">
                                            <option value="" ${empty selectedSort ? 'selected' : ''}>Default (ID)</option>
                                            <option value="stock_asc" ${selectedSort == 'stock_asc' ? 'selected' : ''}>
                                                Stock: Low to High
                                            </option>
                                            <option value="stock_desc" ${selectedSort == 'stock_desc' ? 'selected' : ''}>
                                                Stock: High to Low
                                            </option>
                                            <option value="name_asc" ${selectedSort == 'name_asc' ? 'selected' : ''}>
                                                Name: A to Z
                                            </option>
                                            <option value="name_desc" ${selectedSort == 'name_desc' ? 'selected' : ''}>
                                                Name: Z to A
                                            </option>
                                            <option value="updated_desc" ${selectedSort == 'updated_desc' ? 'selected' : ''}>
                                                Recently Updated
                                            </option>
                                        </select>
                                    </div>

                                    <div class="col-xl-2 col-lg-4 col-md-12 d-flex gap-2">
                                        <button type="submit" class="btn btn-primary flex-grow-1">
                                            <i class="bi bi-search me-1"></i>
                                            Filter
                                        </button>
                                        <a href="${pageContext.request.contextPath}/Manager/Inventory"
                                           class="btn btn-light">
                                            Reset
                                        </a>
                                    </div>
                                </form>
                            </div>

                            <div class="table-responsive">

                                <table class="table align-middle mb-0"
                                       id="inventoryTable">

                                    <thead>

                                        <tr>

                                            <th>Product</th>

                                            <th>Category</th>

                                            <th>Current Stock</th>

                                            <th>Status</th>

                                            <th>Last Updated</th>

                                            <th class="text-end">
                                                Action
                                            </th>

                                        </tr>

                                    </thead>


                                    <tbody>

                                        <c:choose>

                                            <c:when test="${not empty inventoryProducts}">

                                                <c:forEach var="product"
                                                           items="${inventoryProducts}">

                                                    <tr>

                                                        <td>

                                                            <div class="table-media">

                                                                <img class="product-thumb"
                                                                     src="${empty product.imageURL
                                                                            ? pageContext.request.contextPath.concat('/assets/Admin_Manager/images/ecommerce/product-1.jpg')
                                                                            : product.imageURL}"
                                                                     alt="${product.productName}">

                                                                <div>

                                                                    <strong>
                                                                        ${product.productName}
                                                                    </strong>

                                                                    <small>
                                                                        #P${product.productId}
                                                                    </small>

                                                                </div>

                                                            </div>

                                                        </td>

                                                        <td>
                                                            ${product.categoryName}
                                                        </td>

                                                        <td>

                                                            <strong>
                                                                ${product.stockQuantity}
                                                            </strong>

                                                        </td>

                                                        <td>

                                                            <c:choose>

                                                                <c:when test="${product.stockQuantity == 0}">
                                                                    <span class="badge text-bg-danger">
                                                                        Out of Stock
                                                                    </span>
                                                                </c:when>

                                                                <c:when test="${product.stockQuantity <= 10}">
                                                                    <span class="badge text-bg-warning">
                                                                        Low Stock
                                                                    </span>
                                                                </c:when>

                                                                <c:otherwise>
                                                                    <span class="badge text-bg-success">
                                                                        In Stock
                                                                    </span>
                                                                </c:otherwise>

                                                            </c:choose>

                                                        </td>

                                                        <td>

                                                            <c:choose>

                                                                <c:when test="${not empty product.updatedAt}">

                                                                    <fmt:formatDate
                                                                        value="${product.updatedAt}"
                                                                        pattern="yyyy-MM-dd HH:mm"/>

                                                                </c:when>

                                                                <c:otherwise>
                                                                    -
                                                                </c:otherwise>

                                                            </c:choose>

                                                        </td>

                                                        <td class="text-end">

                                                            <a href="${pageContext.request.contextPath}/Manager/products?action=edit&id=${product.productId}&from=inventory"
                                                               class="btn btn-light btn-sm"
                                                               title="Adjust stock / edit product">

                                                                <i class="bi bi-pencil"></i>

                                                                Adjust

                                                            </a>

                                                            <a href="${pageContext.request.contextPath}/Manager/products?action=detail&id=${product.productId}&from=inventory"
                                                               class="btn btn-light btn-sm"
                                                               title="View details">

                                                                <i class="bi bi-eye"></i>

                                                                Detail

                                                            </a>

                                                        </td>

                                                    </tr>

                                                </c:forEach>

                                            </c:when>

                                            <c:otherwise>

                                                <tr>

                                                    <td colspan="6"
                                                        class="text-center text-muted py-4">

                                                        No products found.

                                                    </td>

                                                </tr>

                                            </c:otherwise>

                                        </c:choose>

                                    </tbody>

                                </table>

                            </div>

                            <!-- Server-side pagination -->
                            <c:if test="${totalPages > 1}">
                                <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 p-3">
                                    <small class="text-muted">
                                        Page ${currentPage} of ${totalPages} — ${totalItems} item(s)
                                    </small>

                                    <nav aria-label="Inventory pagination">
                                        <ul class="pagination pagination-sm mb-0">

                                            <c:url var="previousUrl" value="/Manager/Inventory">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="category" value="${selectedCategory}"/>
                                                <c:param name="stock" value="${selectedStock}"/>
                                                <c:param name="sort" value="${selectedSort}"/>
                                                <c:param name="pageSize" value="${pageSize}"/>
                                                <c:param name="page" value="${currentPage - 1}"/>
                                                <c:param name="txPage" value="${currentTxPage}"/>
                                            </c:url>

                                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                                <a class="page-link" href="${previousUrl}">Previous</a>
                                            </li>

                                            <c:forEach var="p" begin="1" end="${totalPages}">
                                                <c:url var="pageUrl" value="/Manager/Inventory">
                                                    <c:param name="keyword" value="${keyword}"/>
                                                    <c:param name="category" value="${selectedCategory}"/>
                                                    <c:param name="stock" value="${selectedStock}"/>
                                                    <c:param name="sort" value="${selectedSort}"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:param name="page" value="${p}"/>
                                                    <c:param name="txPage" value="${currentTxPage}"/>
                                                </c:url>

                                                <li class="page-item ${p == currentPage ? 'active' : ''}">
                                                    <a class="page-link" href="${pageUrl}">${p}</a>
                                                </li>
                                            </c:forEach>

                                            <c:url var="nextUrl" value="/Manager/Inventory">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="category" value="${selectedCategory}"/>
                                                <c:param name="stock" value="${selectedStock}"/>
                                                <c:param name="sort" value="${selectedSort}"/>
                                                <c:param name="pageSize" value="${pageSize}"/>
                                                <c:param name="page" value="${currentPage + 1}"/>
                                                <c:param name="txPage" value="${currentTxPage}"/>
                                            </c:url>

                                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                                <a class="page-link" href="${nextUrl}">Next</a>
                                            </li>
                                        </ul>
                                    </nav>
                                </div>
                            </c:if>

                        </section>

                        <section class="panel mt-3">

                            <div class="panel-header">

                                <div>

                                    <h2 class="h5 mb-1 section-title">

                                        <i class="bi bi-clock-history"></i>

                                        <span>
                                            Recent Inventory Transactions
                                        </span>

                                    </h2>

                                    <p class="text-muted mb-0">
                                        ${totalTx} transaction(s) recorded.
                                    </p>

                                </div>

                            </div>


                            <div class="table-responsive">

                                <table class="table align-middle mb-0">

                                    <thead>

                                        <tr>

                                            <th>Product</th>

                                            <th>Type</th>

                                            <th>Quantity</th>

                                            <th>Previous</th>

                                            <th>New Stock</th>

                                            <th>Reason</th>

                                            <th>Date</th>

                                        </tr>

                                    </thead>


                                    <tbody>


                                        <c:choose>


                                            <c:when test="${not empty recentTransactions}">

                                                <c:forEach var="transaction"
                                                           items="${recentTransactions}">

                                                    <tr>

                                                        <td>

                                                            ${transaction.productName}

                                                        </td>

                                                        <td>

                                                            <c:choose>

                                                                <c:when test="${transaction.transactionType eq 'IMPORT'}">

                                                                    <span class="badge text-bg-success">
                                                                        IMPORT
                                                                    </span>

                                                                </c:when>


                                                                <c:when test="${transaction.transactionType eq 'SALE'}">

                                                                    <span class="badge text-bg-warning">
                                                                        SALE
                                                                    </span>

                                                                </c:when>


                                                                <c:when test="${transaction.transactionType eq 'RETURN'}">

                                                                    <span class="badge text-bg-primary">
                                                                        RETURN
                                                                    </span>

                                                                </c:when>


                                                                <c:when test="${transaction.transactionType eq 'ADJUSTMENT'}">

                                                                    <span class="badge text-bg-info">
                                                                        ADJUSTMENT
                                                                    </span>

                                                                </c:when>


                                                                <c:otherwise>

                                                                    <span class="badge text-bg-secondary">
                                                                        ${transaction.transactionType}
                                                                    </span>

                                                                </c:otherwise>

                                                            </c:choose>

                                                        </td>

                                                        <td>

                                                            <c:choose>

                                                                <c:when test="${transaction.quantity > 0}">
                                                                    +${transaction.quantity}
                                                                </c:when>

                                                                <c:otherwise>
                                                                    ${transaction.quantity}
                                                                </c:otherwise>

                                                            </c:choose>

                                                        </td>

                                                        <td>
                                                            ${transaction.previousQuantity}
                                                        </td>


                                                        <!-- NEW -->

                                                        <td>
                                                            ${transaction.newQuantity}
                                                        </td>


                                                        <!-- REASON -->

                                                        <td>
                                                            ${transaction.reason}
                                                        </td>


                                                        <!-- DATE -->

                                                        <td>

                                                            ${transaction.createdAt}

                                                        </td>

                                                    </tr>

                                                </c:forEach>

                                            </c:when>


                                            <c:otherwise>

                                                <tr>

                                                    <td colspan="7"
                                                        class="text-center text-muted py-4">

                                                        No inventory transactions found.

                                                    </td>

                                                </tr>

                                            </c:otherwise>


                                        </c:choose>


                                    </tbody>

                                </table>

                            </div>

                            <!-- Server-side transaction pagination -->
                            <c:if test="${totalTxPages > 1}">
                                <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 p-3">
                                    <small class="text-muted">
                                        Transaction Page ${currentTxPage} of ${totalTxPages} — ${totalTx} total record(s)
                                    </small>

                                    <nav aria-label="Transaction pagination">
                                        <ul class="pagination pagination-sm mb-0">

                                            <c:url var="prevTxUrl" value="/Manager/Inventory">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="category" value="${selectedCategory}"/>
                                                <c:param name="stock" value="${selectedStock}"/>
                                                <c:param name="sort" value="${selectedSort}"/>
                                                <c:param name="page" value="${currentPage}"/>
                                                <c:param name="pageSize" value="${pageSize}"/>
                                                <c:param name="txPage" value="${currentTxPage - 1}"/>
                                            </c:url>

                                            <li class="page-item ${currentTxPage <= 1 ? 'disabled' : ''}">
                                                <a class="page-link" href="${prevTxUrl}">Previous</a>
                                            </li>

                                            <c:forEach var="tp" begin="1" end="${totalTxPages}">
                                                <c:url var="txPageUrl" value="/Manager/Inventory">
                                                    <c:param name="keyword" value="${keyword}"/>
                                                    <c:param name="category" value="${selectedCategory}"/>
                                                    <c:param name="stock" value="${selectedStock}"/>
                                                    <c:param name="sort" value="${selectedSort}"/>
                                                    <c:param name="page" value="${currentPage}"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:param name="txPage" value="${tp}"/>
                                                </c:url>

                                                <li class="page-item ${tp == currentTxPage ? 'active' : ''}">
                                                    <a class="page-link" href="${txPageUrl}">${tp}</a>
                                                </li>
                                            </c:forEach>

                                            <c:url var="nextTxUrl" value="/Manager/Inventory">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="category" value="${selectedCategory}"/>
                                                <c:param name="stock" value="${selectedStock}"/>
                                                <c:param name="sort" value="${selectedSort}"/>
                                                <c:param name="page" value="${currentPage}"/>
                                                <c:param name="pageSize" value="${pageSize}"/>
                                                <c:param name="txPage" value="${currentTxPage + 1}"/>
                                            </c:url>

                                            <li class="page-item ${currentTxPage >= totalTxPages ? 'disabled' : ''}">
                                                <a class="page-link" href="${nextTxUrl}">Next</a>
                                            </li>
                                        </ul>
                                    </nav>
                                </div>
                            </c:if>

                        </section>


                    </div>

                </main>

                <footer class="admin-footer">

                    <div class="container-fluid px-3 px-lg-4">

                        <span>

                            Copyright 2026 Headphone Store.

                            <br>

                            Manager Panel

                        </span>

                        <span>
                            Store Management System.
                        </span>

                        <span>
                            Inventory Management.
                        </span>

                    </div>

                </footer>


            </div>

        </div>


        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>



    </body>

</html>