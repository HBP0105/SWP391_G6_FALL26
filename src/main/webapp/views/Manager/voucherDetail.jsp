<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Voucher Detail | Headphone Store</title>

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
                    <a class="brand-mark" href="${pageContext.request.contextPath}/Manager/Dashboard">
                        <span class="brand-icon"><i class="bi bi-headphones"></i></span>
                        <span class="brand-copy">
                            <span class="brand-title">Headphone Store</span>
                            <span class="brand-subtitle">Manager Panel</span>
                        </span>
                    </a>
                </div>

                <nav class="sidebar-nav">
                    <a class="nav-link" href="${pageContext.request.contextPath}/Manager/Dashboard">
                        <span class="nav-icon"><i class="bi bi-speedometer2"></i></span>
                        <span class="nav-text">Dashboard</span>
                    </a>
                    <a class="nav-link" href="${pageContext.request.contextPath}/Manager/products">
                        <span class="nav-icon"><i class="bi bi-box-seam"></i></span>
                        <span class="nav-text">Products</span>
                    </a>
                    <a class="nav-link" href="${pageContext.request.contextPath}/Manager/OrderManagement">
                        <span class="nav-icon"><i class="bi bi-cart-check"></i></span>
                        <span class="nav-text">Orders</span>
                    </a>
                    <a class="nav-link" href="${pageContext.request.contextPath}/Manager/Inventory">
                        <span class="nav-icon"><i class="bi bi-boxes"></i></span>
                        <span class="nav-text">Inventory</span>
                    </a>
                    <a class="nav-link active" href="${pageContext.request.contextPath}/Manager/Voucher">
                        <span class="nav-icon"><i class="bi bi-ticket-perforated"></i></span>
                        <span class="nav-text">Vouchers</span>
                    </a>
                    <a class="nav-link" href="${pageContext.request.contextPath}/Manager/Report">
                        <span class="nav-icon"><i class="bi bi-bar-chart-line"></i></span>
                        <span class="nav-text">Reports</span>
                    </a>
                    <a class="nav-link" href="${pageContext.request.contextPath}/Manager/Profile">
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
                        <button class="sidebar-toggle" type="button" data-sidebar-toggle aria-label="Toggle sidebar">
                            <span></span><span></span><span></span>
                        </button>

                        <div class="navbar-actions ms-auto">
                            <button class="icon-button theme-toggle" type="button" data-theme-toggle title="Switch color theme">
                                <i class="bi bi-moon-stars" data-theme-icon></i>
                            </button>

                            <div class="dropdown">
                                <button class="profile-button dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                    <img class="avatar-img avatar-sm"
                                         src="${pageContext.request.contextPath}/assets/Admin_Manager/images/avatar/gumball.jpg"
                                         alt="Manager">
                                    <span class="profile-name d-none d-sm-inline">Manager</span>
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

                        <div class="page-heading">
                            <div class="page-heading-copy">
                                <span class="page-icon">
                                    <i class="bi bi-ticket-detailed"></i>
                                </span>
                                <div>
                                    <p class="eyebrow mb-1">Manager</p>
                                    <h1 class="h3 mb-1">Voucher Detail: ${voucher.voucherCode}</h1>
                                    <p class="text-muted mb-0">Detailed settings and usage statistics for this discount voucher.</p>
                                </div>
                            </div>
                            <div class="d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/Manager/Voucher" class="btn btn-light">
                                    <i class="bi bi-arrow-left me-1"></i>
                                    Back to Vouchers
                                </a>

                                <c:choose>
                                    <c:when test="${voucher.status eq 'ACTIVE'}">
                                        <form action="${pageContext.request.contextPath}/Manager/Voucher" method="post" class="d-inline">
                                            <input type="hidden" name="action" value="changeStatus">
                                            <input type="hidden" name="voucherId" value="${voucher.voucherId}">
                                            <input type="hidden" name="status" value="INACTIVE">
                                            <button type="submit" class="btn btn-warning" onclick="return confirm('Disable this voucher?');">
                                                <i class="bi bi-pause-circle me-1"></i>
                                                Disable Voucher
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <form action="${pageContext.request.contextPath}/Manager/Voucher" method="post" class="d-inline">
                                            <input type="hidden" name="action" value="changeStatus">
                                            <input type="hidden" name="voucherId" value="${voucher.voucherId}">
                                            <input type="hidden" name="status" value="ACTIVE">
                                            <button type="submit" class="btn btn-success" onclick="return confirm('Activate this voucher?');">
                                                <i class="bi bi-play-circle me-1"></i>
                                                Activate Voucher
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="row g-3">
                            <div class="col-12 col-lg-8">
                                <section class="panel mb-3">
                                    <div class="panel-header">
                                        <div>
                                            <h2 class="h5 mb-1 section-title">
                                                <i class="bi bi-info-circle"></i>
                                                <span>General Information</span>
                                            </h2>
                                            <p class="text-muted mb-0">Code and discount parameters.</p>
                                        </div>
                                        <div>
                                            <c:choose>
                                                <c:when test="${voucher.status eq 'ACTIVE'}">
                                                    <span class="badge text-bg-success fs-6">Active</span>
                                                </c:when>
                                                <c:when test="${voucher.status eq 'INACTIVE'}">
                                                    <span class="badge text-bg-secondary fs-6">Inactive</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge text-bg-danger fs-6">${voucher.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <div class="p-3 p-lg-4">
                                        <table class="table table-borderless mb-0">
                                            <tbody>
                                                <tr>
                                                    <th class="text-muted w-25">Voucher ID:</th>
                                                    <td class="fw-bold">#V${voucher.voucherId}</td>
                                                </tr>
                                                <tr>
                                                    <th class="text-muted">Voucher Code:</th>
                                                    <td>
                                                        <span class="badge text-bg-dark fs-6 px-3 py-2 font-monospace">
                                                            ${voucher.voucherCode}
                                                        </span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th class="text-muted">Description:</th>
                                                    <td>${not empty voucher.description ? voucher.description : '—'}</td>
                                                </tr>
                                                <tr>
                                                    <th class="text-muted">Discount Type:</th>
                                                    <td>
                                                        <span class="badge text-bg-info">
                                                            ${voucher.discountType eq 'PERCENT' ? 'Percentage Discount' : 'Fixed Amount'}
                                                        </span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th class="text-muted">Discount Value:</th>
                                                    <td class="fs-5 fw-bold text-success">
                                                        <c:choose>
                                                            <c:when test="${voucher.discountType eq 'PERCENT'}">
                                                                <fmt:formatNumber value="${voucher.discountValue}" maxFractionDigits="2"/> %
                                                            </c:when>
                                                            <c:otherwise>
                                                                <fmt:formatNumber value="${voucher.discountValue}" maxFractionDigits="0"/> VND
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th class="text-muted">Min Order Amount:</th>
                                                    <td>
                                                        <fmt:formatNumber value="${voucher.minOrderAmount}" maxFractionDigits="0"/> VND
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th class="text-muted">Max Discount Cap:</th>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty voucher.maxDiscount}">
                                                                <fmt:formatNumber value="${voucher.maxDiscount}" maxFractionDigits="0"/> VND
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">No limit</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </section>
                            </div>

                            <div class="col-12 col-lg-4">
                                <section class="panel mb-3">
                                    <div class="panel-header">
                                        <div>
                                            <h2 class="h5 mb-1 section-title">
                                                <i class="bi bi-clock-history"></i>
                                                <span>Validity & Usage</span>
                                            </h2>
                                            <p class="text-muted mb-0">Redemption limits and dates.</p>
                                        </div>
                                    </div>

                                    <div class="p-3 p-lg-4">
                                        <div class="mb-3">
                                            <small class="text-muted d-block mb-1">Start Date:</small>
                                            <div class="fw-semibold">
                                                <i class="bi bi-calendar-event me-1 text-primary"></i>
                                                ${voucher.formattedStartDate}
                                            </div>
                                        </div>

                                        <div class="mb-3">
                                            <small class="text-muted d-block mb-1">End Date:</small>
                                            <div class="fw-semibold">
                                                <i class="bi bi-calendar-check me-1 text-danger"></i>
                                                ${voucher.formattedEndDate}
                                            </div>
                                        </div>

                                        <hr>

                                        <div class="mb-3">
                                            <small class="text-muted d-block mb-1">Redemption Count:</small>
                                            <div class="d-flex align-items-baseline gap-2">
                                                <span class="fs-4 fw-bold text-primary">${voucher.usedCount}</span>
                                                <span class="text-muted">
                                                    / <c:choose>
                                                        <c:when test="${not empty voucher.usageLimit}">
                                                            ${voucher.usageLimit} limit
                                                        </c:when>
                                                        <c:otherwise>
                                                            Unlimited
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                        </div>

                                        <c:if test="${not empty voucher.createdAt}">
                                            <div>
                                                <small class="text-muted d-block mb-1">Created At:</small>
                                                <div class="text-muted small">
                                                    ${voucher.formattedCreatedAt}
                                                </div>
                                            </div>
                                        </c:if>
                                    </div>
                                </section>
                            </div>
                        </div>

                    </div>
                </main>

                <footer class="admin-footer">
                    <div class="container-fluid px-3 px-lg-4">
                        <span>Copyright 2026 Headphone Store.<br>Manager Voucher Management</span>
                        <span>Headphone Store E-commerce System.</span>
                    </div>
                </footer>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>
    </body>
</html>
