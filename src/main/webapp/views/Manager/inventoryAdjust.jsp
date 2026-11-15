<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="Headphone Store Manager">
        <title>Adjust Stock | Headphone Store</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css?v=20261114-1">
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
                    <a class="nav-link active" href="${pageContext.request.contextPath}/Manager/Inventory">
                        <span class="nav-icon"><i class="bi bi-boxes"></i></span>
                        <span class="nav-text">Inventory</span>
                    </a>
                    <a class="nav-link" href="${pageContext.request.contextPath}/Manager/Voucher">
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

                        <div class="page-heading">
                            <div class="page-heading-copy">
                                <span class="page-icon">
                                    <i class="bi bi-boxes"></i>
                                </span>
                                <div>
                                    <p class="eyebrow mb-1">Manager / Inventory</p>
                                    <h1 class="h3 mb-1">Adjust Stock</h1>
                                    <p class="text-muted mb-0">Record an inventory transaction and adjust stock quantity for this product.</p>
                                </div>
                            </div>
                            <div>
                                <a href="${pageContext.request.contextPath}/Manager/Inventory" class="btn btn-light">
                                    <i class="bi bi-arrow-left me-1"></i>
                                    Back to Inventory
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
                                        <i class="bi bi-sliders me-1"></i>
                                        <span>Stock Adjustment Form</span>
                                    </h2>
                                    <p class="text-muted mb-0">Update stock for product #${product.productId}.</p>
                                </div>
                            </div>

                            <div class="p-3 p-lg-4">
                                <form method="post" action="${pageContext.request.contextPath}/Manager/Inventory">
                                    <input type="hidden" name="action" value="adjust">

                                    <div class="row g-3">
                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Product ID</label>
                                            <input type="text"
                                                   name="productId"
                                                   class="form-control bg-light"
                                                   value="${product.productId}"
                                                   readonly>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Product Name</label>
                                            <input type="text"
                                                   class="form-control bg-light"
                                                   value="${product.productName}"
                                                   readonly>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Current Stock</label>
                                            <input type="number"
                                                   id="currentStock"
                                                   class="form-control bg-light"
                                                   value="${product.stockQuantity}"
                                                   readonly>
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Transaction Type <span class="text-danger">*</span></label>
                                            <select name="transactionType" id="transactionType" class="form-select" required>
                                                <option value="IMPORT" ${selectedType == 'IMPORT' ? 'selected' : ''}>IMPORT (Nhập kho)</option>
                                                <option value="RETURN" ${selectedType == 'RETURN' ? 'selected' : ''}>RETURN (Khách trả hàng)</option>
                                                <option value="ADJUSTMENT" ${selectedType == 'ADJUSTMENT' ? 'selected' : ''}>ADJUSTMENT (Điều chỉnh kiểm kê)</option>
                                            </select>
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Quantity <span class="text-danger">*</span></label>
                                            <input type="number"
                                                   name="quantity"
                                                   id="quantityInput"
                                                   class="form-control"
                                                   value="${enteredQuantity}"
                                                   placeholder="e.g. 10 (or -5 for ADJUSTMENT)"
                                                   required>
                                            <div class="form-text" id="quantityHelp">
                                                For IMPORT / RETURN: enter quantity to add (> 0). For ADJUSTMENT: enter positive to add, negative to reduce.
                                            </div>
                                        </div>

                                        <div class="col-12">
                                            <label class="form-label fw-semibold">Reason</label>
                                            <textarea name="reason"
                                                      class="form-control"
                                                      rows="3"
                                                      maxlength="500"
                                                      placeholder="Enter reason for stock adjustment (e.g., supplier shipment, damaged items, audit count)...">${enteredReason}</textarea>
                                        </div>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2 mt-4 pt-2 border-top">
                                        <a href="${pageContext.request.contextPath}/Manager/Inventory"
                                           class="btn btn-light">
                                            Cancel
                                        </a>

                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-check2-circle me-1"></i>
                                            Confirm Adjustment
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </section>
                    </div>
                </main>

                <footer class="admin-footer">
                    <div class="container-fluid px-3 px-lg-4">
                        <span>
                            Copyright 2026 Headphone Store.<br>
                            Manager Panel
                        </span>
                        <span>Inventory Management</span>
                    </div>
                </footer>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js?v=20261114-1"></script>
        <script>
            (function () {
                const currentStock = ${product.stockQuantity};
                const typeSelect = document.getElementById('transactionType');
                const qtyInput = document.getElementById('quantityInput');
                const helpDiv = document.getElementById('quantityHelp');

                function updateHelp() {
                    const type = typeSelect.value;
                    const qty = parseInt(qtyInput.value, 10);
                    if (isNaN(qty)) {
                        helpDiv.innerHTML = type === 'ADJUSTMENT'
                            ? 'For ADJUSTMENT: enter positive to add, negative to reduce (new stock cannot be negative).'
                            : 'For ' + type + ': enter quantity to add (> 0).';
                        helpDiv.className = 'form-text';
                        return;
                    }
                    let newStock;
                    if (type === 'IMPORT' || type === 'RETURN') {
                        if (qty <= 0) {
                            helpDiv.innerHTML = '<span class="text-danger">Quantity must be &gt; 0 for ' + type + '.</span>';
                            return;
                        }
                        newStock = currentStock + qty;
                    } else {
                        newStock = currentStock + qty;
                    }
                    if (newStock < 0) {
                        helpDiv.innerHTML = '<span class="text-danger">Projected new stock: <strong>' + newStock + '</strong> (Cannot be negative!)</span>';
                    } else {
                        helpDiv.innerHTML = '<span class="text-success">Projected new stock: <strong>' + newStock + '</strong> (Current: ' + currentStock + ')</span>';
                    }
                }

                typeSelect.addEventListener('change', updateHelp);
                qtyInput.addEventListener('input', updateHelp);
            })();
        </script>
    </body>
</html>
