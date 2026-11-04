<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Add Voucher | Headphone Store</title>

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
                                    <i class="bi bi-plus-circle"></i>
                                </span>
                                <div>
                                    <p class="eyebrow mb-1">Manager</p>
                                    <h1 class="h3 mb-1">Add New Voucher</h1>
                                    <p class="text-muted mb-0">Create a promotional discount code for customer orders.</p>
                                </div>
                            </div>
                            <div>
                                <a href="${pageContext.request.contextPath}/Manager/Voucher" class="btn btn-light">
                                    <i class="bi bi-arrow-left me-1"></i>
                                    Back to Vouchers
                                </a>
                            </div>
                        </div>

                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <i class="bi bi-exclamation-octagon me-2"></i>
                                ${errorMessage}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <section class="panel">
                            <div class="panel-header">
                                <div>
                                    <h2 class="h5 mb-1 section-title">
                                        <i class="bi bi-ticket-perforated"></i>
                                        <span>Voucher Details</span>
                                    </h2>
                                    <p class="text-muted mb-0">Configure discount value, usage limits, and validity dates.</p>
                                </div>
                            </div>

                            <div class="p-3 p-lg-4">
                                <form method="post" action="${pageContext.request.contextPath}/Manager/Voucher">
                                    <input type="hidden" name="action" value="add">

                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Voucher Code <span class="text-danger">*</span></label>
                                            <input type="text"
                                                   name="voucherCode"
                                                   class="form-control text-uppercase"
                                                   placeholder="e.g. SUMMER2026"
                                                   value="${voucherCode}"
                                                   required>
                                            <small class="text-muted">Must be unique, usually uppercase letters and numbers.</small>
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Status <span class="text-danger">*</span></label>
                                            <select name="status" class="form-select">
                                                <option value="ACTIVE" ${empty status || status eq 'ACTIVE' ? 'selected' : ''}>Active</option>
                                                <option value="INACTIVE" ${status eq 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                                            </select>
                                        </div>

                                        <div class="col-12">
                                            <label class="form-label fw-semibold">Description</label>
                                            <textarea name="description"
                                                      class="form-control"
                                                      rows="2"
                                                      placeholder="e.g. 15% discount for headphone orders over 500,000 VND">${description}</textarea>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Discount Type <span class="text-danger">*</span></label>
                                            <select name="discountType" id="discountTypeSelect" class="form-select" required>
                                                <option value="PERCENT" ${empty discountType || discountType eq 'PERCENT' ? 'selected' : ''}>Percentage (%)</option>
                                                <option value="FIXED" ${discountType eq 'FIXED' ? 'selected' : ''}>Fixed Amount (VND)</option>
                                            </select>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Discount Value <span class="text-danger">*</span></label>
                                            <input type="number"
                                                   step="0.01"
                                                   min="0.01"
                                                   name="discountValue"
                                                   class="form-control"
                                                   placeholder="e.g. 15 or 50000"
                                                   value="${discountValue}"
                                                   required>
                                            <small class="text-muted" id="discountValueHint">% (up to 100) or VND amount</small>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Min Order Amount (VND)</label>
                                            <input type="number"
                                                   step="1"
                                                   min="0"
                                                   name="minOrderAmount"
                                                   class="form-control"
                                                   placeholder="0"
                                                   value="${empty minOrderAmount ? '0' : minOrderAmount}">
                                            <small class="text-muted">Minimum cart total to apply.</small>
                                        </div>

                                        <div class="col-md-4" id="maxDiscountGroup">
                                            <label class="form-label fw-semibold">Max Discount (VND)</label>
                                            <input type="number"
                                                   step="1"
                                                   min="0"
                                                   name="maxDiscount"
                                                   class="form-control"
                                                   placeholder="Optional cap for % discount"
                                                   value="${maxDiscount}">
                                            <small class="text-muted">Max discount cap for % types (leave empty for no cap).</small>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Start Date & Time <span class="text-danger">*</span></label>
                                            <input type="datetime-local"
                                                   name="startDate"
                                                   class="form-control"
                                                   value="${startDate}"
                                                   required>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">End Date & Time <span class="text-danger">*</span></label>
                                            <input type="datetime-local"
                                                   name="endDate"
                                                   class="form-control"
                                                   value="${endDate}"
                                                   required>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Usage Limit</label>
                                            <input type="number"
                                                   min="1"
                                                   step="1"
                                                   name="usageLimit"
                                                   class="form-control"
                                                   placeholder="Leave blank for unlimited"
                                                   value="${usageLimit}">
                                            <small class="text-muted">Total times this voucher can be redeemed.</small>
                                        </div>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
                                        <a href="${pageContext.request.contextPath}/Manager/Voucher" class="btn btn-light">
                                            Cancel
                                        </a>
                                        <button type="submit" class="btn btn-success">
                                            <i class="bi bi-check2-circle me-1"></i>
                                            Save Voucher
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </section>
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
