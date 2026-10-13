<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="Headphone Store Manager">
        <title>Product Management | Headphone Store</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css">
        <style>
            /* Keep all product filters and action buttons on one desktop row. */
            @media (min-width: 1200px) {
                .product-filter-form {
                    display: grid;
                    grid-template-columns: minmax(0, 1.7fr) repeat(4, minmax(0, 1fr)) minmax(0, 2.1fr);
                    gap: 12px;
                    margin: 0;
                    align-items: end;
                }
                .product-filter-form > div {
                    width: auto;
                    max-width: none;
                    min-width: 0;
                    padding: 0;
                    margin: 0;
                }
                .product-filter-form .filter-actions {
                    flex-wrap: nowrap;
                    white-space: nowrap;
                }
                .product-filter-form .filter-actions .btn {
                    font-size: 0.875rem;
                    padding-left: 0.65rem;
                    padding-right: 0.65rem;
                }
            }
        </style>
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
                            <span></span><span></span><span></span>
                        </button>

                        <div class="navbar-actions ms-auto">
                            <button class="icon-button theme-toggle"
                                    type="button"
                                    data-theme-toggle
                                    aria-label="Switch color theme"
                                    title="Switch color theme">
                                <i class="bi bi-moon-stars" data-theme-icon aria-hidden="true"></i>
                            </button>

                            <div class="dropdown">
                                <button class="profile-button dropdown-toggle"
                                        type="button"
                                        data-bs-toggle="dropdown"
                                        aria-expanded="false">
                                    <img class="avatar-img avatar-sm"
                                         src="${pageContext.request.contextPath}/assets/Admin_Manager/images/avatar/gumball.jpg"
                                         alt="Manager">
                                    <span class="profile-name d-none d-sm-inline">Manager</span>
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

                        <div class="page-heading">
                            <div class="page-heading-copy">
                                <span class="page-icon">
                                    <i class="bi bi-box-seam" aria-hidden="true"></i>
                                </span>
                                <div>
                                    <p class="eyebrow mb-1">Manager</p>
                                    <h1 class="h3 mb-1">Product Management</h1>
                                    <p class="text-muted mb-0">
                                        Manage headphone products, prices and inventory.
                                    </p>
                                </div>
                            </div>

                            <div>
                                <a href="${pageContext.request.contextPath}/Manager/products?action=add"
                                   class="btn btn-primary">
                                    <i class="bi bi-plus-lg me-1"></i>
                                    Add Product
                                </a>
                            </div>
                        </div>

                        <section class="panel">
                            <div class="panel-header">
                                <div>
                                    <h2 class="h5 mb-1 section-title">
                                        <i class="bi bi-box-seam" aria-hidden="true"></i>
                                        <span>Product List</span>
                                    </h2>
                                    <p class="text-muted mb-0">
                                        ${totalItems} product(s) found.
                                    </p>
                                </div>
                            </div>

                            <!-- Server-side search/filter. No JS table search here. -->
                            <div class="px-3 pt-3 pb-2">
                                <form method="get"
                                      action="${pageContext.request.contextPath}/Manager/products"
                                      class="row g-3 align-items-end product-filter-form">

                                    <div class="col-xl-3 col-lg-4 col-md-6">
                                        <label class="form-label">Search</label>
                                        <input class="form-control"
                                               type="search"
                                               name="keyword"
                                               value="${keyword}"
                                               placeholder="Product, category or brand">
                                    </div>

                                    <div class="col-xl-2 col-lg-4 col-md-6">
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
                                        <label class="form-label">Stock</label>
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
                                        <label class="form-label">Status</label>
                                        <select name="status" class="form-select">
                                            <option value="">All Status</option>
                                            <option value="ACTIVE" ${selectedStatus == 'ACTIVE' ? 'selected' : ''}>
                                                Active
                                            </option>
                                            <option value="INACTIVE" ${selectedStatus == 'INACTIVE' ? 'selected' : ''}>
                                                Inactive
                                            </option>
                                        </select>
                                    </div>

                                    <div class="col-xl-2 col-lg-4 col-md-6">
                                        <label class="form-label">Sort by Price</label>
                                        <select name="sort" class="form-select">
                                            <option value="" ${empty selectedSort ? 'selected' : ''}>Default</option>
                                            <option value="price_asc" ${selectedSort == 'price_asc' ? 'selected' : ''}>
                                                Low to High
                                            </option>
                                            <option value="price_desc" ${selectedSort == 'price_desc' ? 'selected' : ''}>
                                                High to Low
                                            </option>
                                        </select>
                                    </div>



                                    <div class="col-xl-2 col-lg-4 col-md-6 d-flex gap-2 filter-actions">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-search me-1"></i>
                                            Search / Filter
                                        </button>

                                        <a href="${pageContext.request.contextPath}/Manager/products"
                                           class="btn btn-light">
                                            Reset
                                        </a>
                                    </div>
                                </form>
                            </div>

                            <div class="table-responsive">
                                <table class="table align-middle mb-0" id="productsTable">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Product</th>
                                            <th>Category</th>
                                            <th>Brand</th>
                                            <th>Price</th>
                                            <th>Stock</th>
                                            <th>Status</th>
                                            <th class="text-end">Action</th>
                                        </tr>
                                    </thead>

                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty products}">
                                                <c:forEach var="product" items="${products}">
                                                    <tr>
                                                        <td>#${product.productId}</td>

                                                        <td>
                                                            <div class="table-media">
                                                                <img class="product-thumb"
                                                                     src="${empty product.imageURL
                                                                            ? pageContext.request.contextPath.concat('/assets/Admin_Manager/images/ecommerce/product-1.jpg')
                                                                            : product.imageURL}"
                                                                     alt="${product.productName}">
                                                                <span>${product.productName}</span>
                                                            </div>
                                                        </td>

                                                        <td>${product.categoryName}</td>
                                                        <td>${product.brandName}</td>

                                                        <td>
                                                            <fmt:formatNumber value="${product.price}"
                                                                              type="number"
                                                                              groupingUsed="true"/>
                                                            VND
                                                        </td>

                                                        <td>${product.stockQuantity}</td>

                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${product.status eq 'INACTIVE'}">
                                                                    <span class="badge text-bg-secondary">Inactive</span>
                                                                </c:when>
                                                                <c:when test="${product.stockQuantity eq 0}">
                                                                    <span class="badge text-bg-danger">Out of Stock</span>
                                                                </c:when>
                                                                <c:when test="${product.stockQuantity le 10}">
                                                                    <span class="badge text-bg-warning">Low Stock</span>
                                                                </c:when>
                                                                <c:when test="${product.status eq 'ACTIVE'}">
                                                                    <span class="badge text-bg-success">Available</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge text-bg-secondary">${product.status}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>

                                                        <td class="text-end">
                                                            <a href="${pageContext.request.contextPath}/Manager/products?action=edit&id=${product.productId}"
                                                               class="btn btn-light btn-sm">
                                                                Edit
                                                            </a>

                                                            <a href="${pageContext.request.contextPath}/Manager/products?action=delete&id=${product.productId}"
                                                               class="btn btn-light btn-sm"
                                                               onclick="return confirm('Delete this product?');">
                                                                Delete
                                                            </a>

                                                            <a href="${pageContext.request.contextPath}/Manager/products?action=detail&id=${product.productId}"
                                                               class="btn btn-light btn-sm">
                                                                Detail
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>

                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="8" class="text-center text-muted py-4">
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

                                    <nav aria-label="Product pagination">
                                        <ul class="pagination pagination-sm mb-0">

                                            <c:url var="previousUrl" value="/Manager/products">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="category" value="${selectedCategory}"/>
                                                <c:param name="stock" value="${selectedStock}"/>
                                                <c:param name="status" value="${selectedStatus}"/>
                                                <c:param name="sort" value="${selectedSort}"/>
                                                <c:param name="pageSize" value="${pageSize}"/>
                                                <c:param name="page" value="${currentPage - 1}"/>
                                            </c:url>

                                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                                <a class="page-link" href="${previousUrl}">Previous</a>
                                            </li>

                                            <c:forEach var="p" begin="1" end="${totalPages}">
                                                <c:url var="pageUrl" value="/Manager/products">
                                                    <c:param name="keyword" value="${keyword}"/>
                                                    <c:param name="category" value="${selectedCategory}"/>
                                                    <c:param name="stock" value="${selectedStock}"/>
                                                    <c:param name="status" value="${selectedStatus}"/>
                                                    <c:param name="sort" value="${selectedSort}"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:param name="page" value="${p}"/>
                                                </c:url>

                                                <li class="page-item ${p == currentPage ? 'active' : ''}">
                                                    <a class="page-link" href="${pageUrl}">${p}</a>
                                                </li>
                                            </c:forEach>

                                            <c:url var="nextUrl" value="/Manager/products">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="category" value="${selectedCategory}"/>
                                                <c:param name="stock" value="${selectedStock}"/>
                                                <c:param name="status" value="${selectedStatus}"/>
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

                <footer class="admin-footer">
                    <div class="container-fluid px-3 px-lg-4">
                        <span>
                            Copyright 2026 Headphone Store.<br>
                            Manager Product Management
                        </span>
                        <span>Headphone Store E-commerce System.</span>
                    </div>
                </footer>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>
    </body>
</html>
