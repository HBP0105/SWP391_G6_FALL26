<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="en_US" scope="page"/>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${action eq 'edit' ? 'Edit Voucher' : 'Add Voucher'} | Headphone Store</title>

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
                                    <i class="bi ${action eq 'edit' ? 'bi-pencil-square' : 'bi-plus-circle'}"></i>
                                </span>
                                <div>
                                    <p class="eyebrow mb-1">Manager</p>
                                    <h1 class="h3 mb-1">
                                        ${action eq 'edit' ? 'Edit Voucher: ' : 'Add New Voucher'}
                                        <c:if test="${action eq 'edit'}">
                                            <span>${voucher.voucherCode}</span>
                                        </c:if>
                                    </h1>
                                    <p class="text-muted mb-0">
                                        ${action eq 'edit' 
                                          ? 'Update discount settings, usage limits, and validity dates.' 
                                          : 'Create a promotional discount code for customer orders.'}
                                    </p>
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
                                    <p class="text-muted mb-0">
                                        ${action eq 'edit'
                                          ? 'Update discount value, usage limits, and validity dates. Voucher code cannot be modified.'
                                          : 'Configure discount value, usage limits, and validity dates.'}
                                    </p>
                                </div>
                            </div>

                            <div class="p-3 p-lg-4">
                                <form method="post" action="${pageContext.request.contextPath}/Manager/Voucher">
                                    <input type="hidden" name="action" value="${action}">
                                    <c:if test="${action eq 'edit'}">
                                        <input type="hidden" name="voucherId" value="${voucher.voucherId}">
                                    </c:if>

                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">
                                                Voucher Code <c:if test="${action ne 'edit'}"><span class="text-danger">*</span></c:if>
                                            </label>
                                            <c:choose>
                                                <c:when test="${action eq 'edit'}">
                                                    <input type="text"
                                                           name="voucherCode"
                                                           class="form-control text-uppercase"
                                                           value="${voucher.voucherCode}"
                                                           readonly
                                                           style="background-color: var(--bs-secondary-bg, #e9ecef); cursor: not-allowed;">
                                                    <small class="text-muted">Voucher code is read-only and cannot be modified.</small>
                                                </c:when>
                                                <c:otherwise>
                                                    <input type="text"
                                                           name="voucherCode"
                                                           class="form-control text-uppercase"
                                                           placeholder="e.g. SUMMER2026"
                                                           value="${not empty voucher ? voucher.voucherCode : voucherCode}"
                                                           required>
                                                    <small class="text-muted">Must be unique, usually uppercase letters and numbers.</small>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Status <span class="text-danger">*</span></label>
                                            <c:set var="currentStatus" value="${not empty voucher ? voucher.status : status}" />
                                            <select name="status" class="form-select">
                                                <option value="ACTIVE" ${empty currentStatus || currentStatus eq 'ACTIVE' ? 'selected' : ''}>Active</option>
                                                <option value="INACTIVE" ${currentStatus eq 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                                            </select>
                                        </div>

                                        <div class="col-12">
                                            <label class="form-label fw-semibold">Description</label>
                                            <textarea name="description"
                                                      class="form-control"
                                                      rows="2"
                                                      placeholder="e.g. 15% discount for headphone orders over 500,000 VND">${not empty voucher ? voucher.description : description}</textarea>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Discount Type <span class="text-danger">*</span></label>
                                            <c:set var="currentDiscountType" value="${not empty voucher ? voucher.discountType : discountType}" />
                                            <select name="discountType" id="discountTypeSelect" class="form-select" required>
                                                <option value="PERCENT" ${empty currentDiscountType || currentDiscountType eq 'PERCENT' ? 'selected' : ''}>Percentage (%)</option>
                                                <option value="FIXED" ${currentDiscountType eq 'FIXED' ? 'selected' : ''}>Fixed Amount (VND)</option>
                                            </select>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold" id="discountValueLabel">Discount Value <span class="text-danger">*</span></label>
                                            <div class="input-group">
                                                <input type="text"
                                                       name="discountValue"
                                                       id="discountValueInput" autocomplete="off"
                                                       class="form-control"
                                                       placeholder="e.g. 15 or 50,000"
                                                       value="${not empty editDiscountValue ? editDiscountValue : (not empty voucher ? voucher.discountValueForInput : discountValue)}"
                                                       required>
                                                <span class="input-group-text" id="discountValueUnit">%</span>
                                            </div>
                                            <small class="text-muted" id="discountValueHint">% (up to 100) or VND amount</small>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Min Order Amount (VND)</label>
                                            <div class="input-group">
                                                <input type="text"
                                                       name="minOrderAmount"
                                                       id="minOrderAmountInput" autocomplete="off"
                                                       class="form-control vnd-currency-input"
                                                       placeholder="0"
                                                       value="${not empty editMinOrderAmount ? editMinOrderAmount : (not empty voucher ? voucher.minOrderAmountForInput : (empty minOrderAmount ? '0' : minOrderAmount))}">
                                                <span class="input-group-text">VND</span>
                                            </div>
                                            <small class="text-muted">Minimum cart total to apply.</small>
                                        </div>

                                        <div class="col-md-4" id="maxDiscountGroup">
                                            <label class="form-label fw-semibold">Max Discount (VND)</label>
                                            <div class="input-group">
                                                <input type="text"
                                                       name="maxDiscount"
                                                       id="maxDiscountInput" autocomplete="off"
                                                       class="form-control vnd-currency-input"
                                                       placeholder="Optional cap for % discount"
                                                       value="${not empty editMaxDiscount ? editMaxDiscount : (not empty voucher ? voucher.maxDiscountForInput : maxDiscount)}">
                                                <span class="input-group-text">VND</span>
                                            </div>
                                            <small class="text-muted">Max discount cap for % types (leave empty for no cap).</small>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">Start Date & Time <span class="text-danger">*</span></label>
                                            <input type="datetime-local"
                                                   name="startDate"
                                                   class="form-control"
                                                   value="${not empty editStartDate ? editStartDate : (not empty voucher ? voucher.startDateForInput : startDate)}"
                                                   required>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-semibold">End Date & Time <span class="text-danger">*</span></label>
                                            <input type="datetime-local"
                                                   name="endDate"
                                                   class="form-control"
                                                   value="${not empty editEndDate ? editEndDate : (not empty voucher ? voucher.endDateForInput : endDate)}"
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
                                                   value="${not empty editUsageLimit ? editUsageLimit : (not empty voucher ? voucher.usageLimit : usageLimit)}">
                                            <small class="text-muted">Total times this voucher can be redeemed.</small>
                                        </div>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
                                        <a href="${pageContext.request.contextPath}/Manager/Voucher" class="btn btn-light">
                                            Cancel
                                        </a>
                                        <button type="submit" class="btn ${action eq 'edit' ? 'btn-primary' : 'btn-success'}">
                                            <i class="bi bi-check2-circle me-1"></i>
                                            ${action eq 'edit' ? 'Update Voucher' : 'Save Voucher'}
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
        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js?v=2"></script>
        
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                var discountTypeSelect = document.getElementById("discountTypeSelect");
                var discountValueInput = document.getElementById("discountValueInput");
                var discountValueUnit = document.getElementById("discountValueUnit");
                var discountValueHint = document.getElementById("discountValueHint");
                var maxDiscountGroup = document.getElementById("maxDiscountGroup");
                var minOrderAmountInput = document.getElementById("minOrderAmountInput");
                var maxDiscountInput = document.getElementById("maxDiscountInput");

                function formatVndNumber(val) {
                    if (val === null || val === undefined || val === '') return '';
                    var str = val.toString().split('.')[0];
                    var raw = str.replace(/\D/g, '').replace(/^0+(?!$)/, '');
                    if (!raw) return '';
                    return raw.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                }

                function attachAutoComma(input) {
                    if (!input) return;

                    function applyFormat() {
                        var raw = input.value.split('.')[0].replace(/\D/g, '');
                        if (!raw) {
                            input.value = '';
                            return;
                        }

                        var cursorPos = input.selectionStart || 0;
                        var rawBefore = input.value.substring(0, cursorPos).replace(/\D/g, '');
                        var digitsBefore = rawBefore.length;

                        var formatted = formatVndNumber(raw);
                        input.value = formatted;

                        var newCursor = 0;
                        var dCount = 0;
                        for (var i = 0; i < formatted.length; i++) {
                            if (/\d/.test(formatted[i])) {
                                dCount++;
                            }
                            if (dCount === digitsBefore) {
                                newCursor = i + 1;
                                break;
                            }
                        }
                        input.setSelectionRange(newCursor, newCursor);
                    }

                    input.addEventListener('input', applyFormat);
                    input.addEventListener('keyup', applyFormat);
                    input.addEventListener('paste', function () {
                        setTimeout(applyFormat, 10);
                    });

                    if (input.value) {
                        input.value = formatVndNumber(input.value);
                    }
                }

                // Attach to min order amount and max discount
                attachAutoComma(minOrderAmountInput);
                attachAutoComma(maxDiscountInput);

                // Discount value dynamic formatting based on type
                function handleDiscountValueInput() {
                    if (!discountTypeSelect || !discountValueInput) return;
                    if (discountTypeSelect.value === "FIXED") {
                        var raw = discountValueInput.value.split(".")[0].replace(/\D/g, "");
                        if (!raw) {
                            discountValueInput.value = "";
                            return;
                        }
                        var cursorPos = discountValueInput.selectionStart || 0;
                        var rawBefore = discountValueInput.value.substring(0, cursorPos).replace(/\D/g, "");
                        var digitsBefore = rawBefore.length;

                        var formatted = formatVndNumber(raw);
                        discountValueInput.value = formatted;

                        var newCursor = 0;
                        var dCount = 0;
                        for (var i = 0; i < formatted.length; i++) {
                            if (/\d/.test(formatted[i])) {
                                dCount++;
                            }
                            if (dCount === digitsBefore) {
                                newCursor = i + 1;
                                break;
                            }
                        }
                        discountValueInput.setSelectionRange(newCursor, newCursor);
                    }
                }

                discountValueInput.addEventListener("input", handleDiscountValueInput);
                discountValueInput.addEventListener("keyup", handleDiscountValueInput);
                discountValueInput.addEventListener("paste", function () {
                    setTimeout(handleDiscountValueInput, 10);
                });

                function updateDiscountType() {
                    if (!discountTypeSelect || !discountValueInput) return;
                    var isFixed = discountTypeSelect.value === "FIXED";

                    if (isFixed) {
                        discountValueUnit.textContent = "VND";
                        discountValueHint.textContent = "Fixed discount amount in VND (e.g. 50,000 VND).";
                        discountValueInput.placeholder = "e.g. 50,000";
                        if (discountValueInput.value) {
                            discountValueInput.value = formatVndNumber(discountValueInput.value);
                        }
                        if (maxDiscountGroup) {
                            maxDiscountGroup.style.display = "none";
                        }
                    } else {
                        discountValueUnit.textContent = "%";
                        discountValueHint.textContent = "Percentage discount (1% to 100%).";
                        discountValueInput.placeholder = "e.g. 15";
                        discountValueInput.value = discountValueInput.value.replace(/,/g, "");
                        if (maxDiscountGroup) {
                            maxDiscountGroup.style.display = "block";
                        }
                    }
                }

                if (discountTypeSelect) {
                    discountTypeSelect.addEventListener("change", updateDiscountType);
                    updateDiscountType();
                }
            });
        </script>
    </body>
</html>
