<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.time.LocalDate" %>

<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Order Management | Manager Dashboard</title>

  <!-- Bootstrap 5 CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- adminHMD Custom Style -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminhmd-style.css">

  <style>
    .price-badge {
      font-weight: 700;
      color: var(--admin-primary);
      font-size: 0.76rem;
    }
    .btn-action-sm {
      padding: 0.15rem 0.35rem;
      font-size: 0.71rem;
      font-weight: 700;
      border-radius: 4px;
    }
  </style>
</head>

<body>
  <div class="admin-shell">
    <div class="sidebar-backdrop" id="sidebarBackdrop"></div>

    <!-- SIDEBAR -->
    <aside class="admin-sidebar" id="adminSidebar">
      <div class="sidebar-header">
        <a class="brand-mark" href="${pageContext.request.contextPath}/staff/orders">
          <span class="brand-icon"><i class="bi bi-grid-1x2-fill"></i></span>
          <span class="brand-copy">
            <span class="brand-title">Manager</span>
            <span class="brand-subtitle">Headphone Store</span>
          </span>
        </a>
      </div>

      <nav class="sidebar-nav">
        <a class="nav-link active" href="${pageContext.request.contextPath}/staff/orders">
          <span class="nav-icon"><i class="bi bi-table"></i></span>
          <span class="nav-text">Order Management</span>
        </a>
        <a class="nav-link" href="#">
          <span class="nav-icon"><i class="bi bi-archive"></i></span>
          <span class="nav-text">Inventory</span>
        </a>
        <a class="nav-link" href="#">
          <span class="nav-icon"><i class="bi bi-ticket-perforated"></i></span>
          <span class="nav-text">Vouchers</span>
        </a>
        <a class="nav-link" href="${pageContext.request.contextPath}/home">
          <span class="nav-icon"><i class="bi bi-shop"></i></span>
          <span class="nav-text">Customer Store</span>
        </a>
      </nav>
    </aside>

    <!-- MAIN CONTENT AREA -->
    <div class="admin-main">
      <!-- TOP NAVBAR -->
      <nav class="navbar admin-navbar navbar-expand bg-white">
        <div class="container-fluid px-0">
          <div class="navbar-actions ms-auto d-flex align-items-center gap-2">
            <!-- Theme Toggle Button -->
            <button class="icon-button theme-toggle" id="themeToggleBtn" type="button" title="Switch Light/Dark Theme">
              <i class="bi bi-moon-stars" id="themeIcon"></i>
            </button>

            <!-- Profile Dropdown -->
            <div class="dropdown">
              <button class="profile-button dropdown-toggle border-0" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-person-circle fs-5 me-1"></i>
                <span class="profile-name d-none d-sm-inline">Manager</span>
              </button>
              <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/home"><i class="bi bi-box-arrow-right me-2"></i>Exit to Store</a></li>
              </ul>
            </div>
          </div>
        </div>
      </nav>

      <!-- DASHBOARD CONTENT -->
      <main class="dashboard-content">
        <div class="container-fluid px-2 px-md-3 py-3">
          
          <!-- Page Heading -->
          <div class="page-heading">
            <div class="page-heading-copy">
              <span class="page-icon"><i class="bi bi-bag-check-fill"></i></span>
              <div>
                <p class="eyebrow mb-1">Manager Portal</p>
                <h1 class="h3 mb-1 fw-bold">Order Management</h1>
                <p class="text-muted mb-0">Manage, process, filter and track headphone customer orders.</p>
              </div>
            </div>
            <div class="heading-actions d-flex gap-2">
              <button onclick="exportOrdersToCSV();" class="btn btn-success btn-sm px-3 shadow-sm" title="Export all matching orders to Excel/CSV">
                <i class="bi bi-file-earmark-excel me-1"></i> Export Excel
              </button>
            </div>
          </div>

          <!-- Alert Notification Success -->
          <c:if test="${not empty sessionScope.msgSuccess}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
              <i class="bi bi-check-circle-fill me-2"></i><strong>Success!</strong> Order <strong>#ORD-${sessionScope.msgSuccessOrderId}</strong> updated to: <strong>${sessionScope.msgSuccessStatus}</strong>
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% 
              session.removeAttribute("msgSuccess"); 
              session.removeAttribute("msgSuccessOrderId"); 
              session.removeAttribute("msgSuccessStatus"); 
            %>
          </c:if>

          <!-- Alert Notification Error Status Transition -->
          <c:if test="${not empty sessionScope.msgErrorStatus}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
              <i class="bi bi-x-octagon-fill me-2"></i><strong>Action Rejected:</strong> ${sessionScope.msgErrorStatus}
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% session.removeAttribute("msgErrorStatus"); %>
          </c:if>

          <!-- Alert Notification Error Validation -->
          <c:if test="${not empty msgError}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
              <i class="bi bi-exclamation-triangle-fill me-2"></i><strong>Validation Error:</strong> ${msgError}
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
          </c:if>

          <!-- 5 Stat Metric Cards -->
          <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-xl-5 g-3 mb-4">
            <div class="col">
              <div class="metric-card metric-warning ${selectedStatus == 'PENDING' ? 'active-metric' : ''}" onclick="filterByCardStatus('PENDING')" title="Click to filter Pending orders">
                <div class="metric-top">
                  <span class="metric-label">PENDING</span>
                  <span class="metric-icon"><i class="bi bi-clock-history"></i></span>
                </div>
                <div class="metric-value">${pendingCount != null ? pendingCount : 0}</div>
                <div class="metric-meta"><small class="text-muted">Pending approval</small></div>
              </div>
            </div>

            <div class="col">
              <div class="metric-card metric-info ${selectedStatus == 'CONFIRMED' ? 'active-metric' : ''}" onclick="filterByCardStatus('CONFIRMED')" title="Click to filter Confirmed orders">
                <div class="metric-top">
                  <span class="metric-label">CONFIRMED</span>
                  <span class="metric-icon"><i class="bi bi-check2-square"></i></span>
                </div>
                <div class="metric-value">${confirmedCount != null ? confirmedCount : 0}</div>
                <div class="metric-meta"><small class="text-muted">Confirmed & processing</small></div>
              </div>
            </div>

            <div class="col">
              <div class="metric-card metric-primary ${selectedStatus == 'SHIPPING' ? 'active-metric' : ''}" onclick="filterByCardStatus('SHIPPING')" title="Click to filter Shipping orders">
                <div class="metric-top">
                  <span class="metric-label">SHIPPING</span>
                  <span class="metric-icon"><i class="bi bi-truck"></i></span>
                </div>
                <div class="metric-value">${shippingCount != null ? shippingCount : 0}</div>
                <div class="metric-meta"><small class="text-muted">In transit to customer</small></div>
              </div>
            </div>

            <div class="col">
              <div class="metric-card metric-success ${selectedStatus == 'DELIVERED' ? 'active-metric' : ''}" onclick="filterByCardStatus('DELIVERED')" title="Click to filter Delivered orders">
                <div class="metric-top">
                  <span class="metric-label">DELIVERED</span>
                  <span class="metric-icon"><i class="bi bi-check-circle-fill"></i></span>
                </div>
                <div class="metric-value">${deliveredCount != null ? deliveredCount : 0}</div>
                <div class="metric-meta"><small class="text-muted">Successfully delivered</small></div>
              </div>
            </div>

            <div class="col">
              <div class="metric-card metric-danger ${selectedStatus == 'CANCELLED' ? 'active-metric' : ''}" onclick="filterByCardStatus('CANCELLED')" title="Click to filter Cancelled orders">
                <div class="metric-top">
                  <span class="metric-label">CANCELLED</span>
                  <span class="metric-icon"><i class="bi bi-x-circle-fill"></i></span>
                </div>
                <div class="metric-value">${cancelledCount != null ? cancelledCount : 0}</div>
                <div class="metric-meta"><small class="text-muted">Cancelled or rejected</small></div>
              </div>
            </div>
          </div>

          <!-- Filter Panel -->
          <section class="panel mb-4">
            <div class="panel-header mb-3">
              <div>
                <h2 class="h5 mb-1 section-title"><i class="bi bi-funnel"></i><span>Filter & Search</span></h2>
                <p class="text-muted mb-0">Filter orders by status and custom date ranges.</p>
              </div>
            </div>

            <form method="get" action="${pageContext.request.contextPath}/staff/orders" id="filterForm">
              <input type="hidden" name="keyword" value="${selectedKeyword}">
              <div class="row g-3 align-items-end">
                <div class="col-md-3">
                  <label class="form-label fw-semibold fs-7 mb-1">Order Status:</label>
                  <select name="status" class="form-select form-select-sm" onchange="validateAndSubmit('status')">
                    <option value="ALL" ${selectedStatus == 'ALL' || empty selectedStatus ? 'selected' : ''}>-- All Statuses --</option>
                    <option value="PENDING" ${selectedStatus == 'PENDING' ? 'selected' : ''}>Pending (PENDING)</option>
                    <option value="CONFIRMED" ${selectedStatus == 'CONFIRMED' ? 'selected' : ''}>Confirmed (CONFIRMED)</option>
                    <option value="SHIPPING" ${selectedStatus == 'SHIPPING' ? 'selected' : ''}>Shipping (SHIPPING)</option>
                    <option value="DELIVERED" ${selectedStatus == 'DELIVERED' ? 'selected' : ''}>Delivered (DELIVERED)</option>
                    <option value="CANCELLED" ${selectedStatus == 'CANCELLED' ? 'selected' : ''}>Cancelled (CANCELLED)</option>
                  </select>
                </div>

                <div class="col-md-3">
                  <label class="form-label fw-semibold fs-7 mb-1">From Date:</label>
                  <input type="date" name="startDate" id="startDate" value="${selectedStartDate}" max="<%= LocalDate.now() %>" class="form-control form-control-sm" onchange="validateAndSubmit('startDate')">
                </div>

                <div class="col-md-3">
                  <label class="form-label fw-semibold fs-7 mb-1">To Date:</label>
                  <input type="date" name="endDate" id="endDate" value="${selectedEndDate}" max="<%= LocalDate.now() %>" class="form-control form-control-sm" onchange="validateAndSubmit('endDate')">
                </div>

                <div class="col-md-3 text-end">
                  <a href="${pageContext.request.contextPath}/staff/orders" class="btn btn-outline-secondary btn-sm w-100">
                    <i class="bi bi-x-circle me-1"></i> Clear Filter
                  </a>
                </div>
              </div>
            </form>
          </section>

          <!-- Orders Table Panel -->
          <section class="panel">
            <div class="panel-header d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
              <div>
                <h2 class="h5 mb-1 section-title"><i class="bi bi-table"></i><span>Order Records</span></h2>
                <p class="text-muted mb-0">Showing records matching active filter parameters.</p>
              </div>
              <div style="max-width: 320px;" class="w-100">
                <form method="get" action="${pageContext.request.contextPath}/staff/orders" class="m-0" id="searchForm">
                  <input type="hidden" name="status" value="${selectedStatus}">
                  <input type="hidden" name="startDate" value="${selectedStartDate}">
                  <input type="hidden" name="endDate" value="${selectedEndDate}">
                  <div class="input-group input-group-sm">
                    <button type="submit" class="input-group-text bg-white text-muted border-end-0" style="cursor: pointer;" title="Search entire database"><i class="bi bi-search"></i></button>
                    <input class="form-control form-control-sm border-start-0 ps-0" name="keyword" value="${selectedKeyword}" id="searchInput" type="search" placeholder="Search Order ID, Name, Phone..." aria-label="Search" autocomplete="off">
                  </div>
                </form>
              </div>
            </div>

            <div class="table-responsive">
              <table class="table align-middle mb-0 table-orders" id="ordersTable">
                <thead>
                  <tr>
                    <th class="text-center">Order ID</th>
                    <th>Customer</th>
                    <th>Phone</th>
                    <th>Shipping Address</th>
                    <th class="text-end">Total</th>
                    <th>Order Date</th>
                    <th class="text-center">Status</th>
                    <th class="text-end pe-2">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="o" items="${orders}">
                    <tr>
                      <td class="text-center fw-bold text-nowrap" style="font-size: 0.76rem;">#ORD-${o.orderID}</td>
                      <td>
                        <div class="fw-bold" style="font-size: 0.76rem;" title="${o.shippingName}">${o.shippingName}</div>
                      </td>
                      <td class="text-nowrap" style="font-size: 0.74rem;"><i class="bi bi-telephone text-muted me-1"></i>${o.shippingPhone}</td>
                      <td>
                        <div class="address-cell" title="${o.shippingAddress}">
                          <i class="bi bi-geo-alt text-danger me-1"></i>${o.shippingAddress}
                        </div>
                      </td>
                      <td class="text-end price-badge text-nowrap" style="font-size: 0.76rem;">${o.formattedTotalAmount} VND</td>
                      <td>
                        <div class="lh-sm text-nowrap" style="font-size: 0.71rem;">
                          <div><i class="bi bi-calendar3 me-1 text-muted"></i>${not empty o.formattedOrderDate && o.formattedOrderDate.length() >= 10 ? o.formattedOrderDate.substring(0, 10) : o.formattedOrderDate}</div>
                          <c:if test="${not empty o.formattedOrderDate && o.formattedOrderDate.length() >= 19}">
                            <small class="text-muted d-block" style="font-size: 0.67rem; margin-left: 1.1rem;">${o.formattedOrderDate.substring(11)}</small>
                          </c:if>
                        </div>
                      </td>
                      <td class="text-center">
                        <c:choose>
                          <c:when test="${o.orderStatus == 'PENDING'}">
                            <span class="badge text-bg-warning" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-clock me-1"></i>Pending</span>
                          </c:when>
                          <c:when test="${o.orderStatus == 'CONFIRMED'}">
                            <span class="badge text-bg-info" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-check-lg me-1"></i>Confirmed</span>
                          </c:when>
                          <c:when test="${o.orderStatus == 'SHIPPING'}">
                            <span class="badge text-bg-primary" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-truck me-1"></i>Shipping</span>
                          </c:when>
                          <c:when test="${o.orderStatus == 'DELIVERED'}">
                            <span class="badge text-bg-success" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-check-circle me-1"></i>Delivered</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge text-bg-danger" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-x-circle me-1"></i>Cancelled</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-end pe-2" style="white-space: nowrap;">
                        <c:choose>
                          <c:when test="${o.orderStatus == 'PENDING'}">
                            <form method="post" action="${pageContext.request.contextPath}/staff/orders" style="display:inline;" onsubmit="return confirm('Are you sure you want to CONFIRM order #ORD-${o.orderID}?');">
                              <input type="hidden" name="action" value="updateStatus">
                              <input type="hidden" name="orderId" value="${o.orderID}">
                              <input type="hidden" name="newStatus" value="CONFIRMED">
                              <button type="submit" class="btn btn-info btn-action-sm text-white" title="Confirm order">
                                <i class="bi bi-check-lg"></i> Confirm
                              </button>
                            </form>
                            <button type="button" class="btn btn-danger btn-action-sm" title="Cancel order" onclick="openCancelModal(${o.orderID})">
                              <i class="bi bi-x-lg"></i> Cancel
                            </button>
                          </c:when>
                          <c:when test="${o.orderStatus == 'CONFIRMED'}">
                            <form method="post" action="${pageContext.request.contextPath}/staff/orders" style="display:inline;" onsubmit="return confirm('Are you sure you want to start SHIPPING order #ORD-${o.orderID}?');">
                              <input type="hidden" name="action" value="updateStatus">
                              <input type="hidden" name="orderId" value="${o.orderID}">
                              <input type="hidden" name="newStatus" value="SHIPPING">
                              <button type="submit" class="btn btn-primary btn-action-sm" title="Start shipping">
                                <i class="bi bi-truck"></i> Ship
                              </button>
                            </form>
                            <button type="button" class="btn btn-danger btn-action-sm" title="Cancel order" onclick="openCancelModal(${o.orderID})">
                              <i class="bi bi-x-lg"></i> Cancel
                            </button>
                          </c:when>
                          <c:when test="${o.orderStatus == 'SHIPPING'}">
                            <form method="post" action="${pageContext.request.contextPath}/staff/orders" style="display:inline;" onsubmit="return confirm('Are you sure you want to mark order #ORD-${o.orderID} as COMPLETED?');">
                              <input type="hidden" name="action" value="updateStatus">
                              <input type="hidden" name="orderId" value="${o.orderID}">
                              <input type="hidden" name="newStatus" value="DELIVERED">
                              <button type="submit" class="btn btn-success btn-action-sm" title="Complete order">
                                <i class="bi bi-check-circle"></i> Complete
                              </button>
                            </form>
                          </c:when>
                        </c:choose>

                        <a href="${pageContext.request.contextPath}/staff/order-detail?id=${o.orderID}" class="btn btn-light btn-action-sm border">
                          <i class="bi bi-eye"></i> Details
                        </a>
                      </td>
                    </tr>
                  </c:forEach>

                  <c:if test="${empty orders}">
                    <tr>
                      <td colspan="8" class="text-center py-5 text-muted">
                        <i class="bi bi-folder2-open fs-2 d-block mb-2"></i>
                        <span>No matching orders found!</span>
                      </td>
                    </tr>
                  </c:if>
                </tbody>
              </table>
            </div>

            <!-- Pagination Bar -->
            <c:if test="${totalPages > 0}">
              <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 pt-3 border-top mt-3">
                <small class="text-muted">
                  Showing <b>${totalOrders > 0 ? (currentPage - 1) * pageSize + 1 : 0}</b> - <b>${currentPage * pageSize > totalOrders ? totalOrders : currentPage * pageSize}</b> of <b>${totalOrders}</b> orders (Page <b>${currentPage}</b>/<b>${totalPages}</b>)
                </small>

                <ul class="pagination pagination-sm mb-0">
                  <c:if test="${currentPage > 1}">
                    <li class="page-item">
                      <a class="page-link" href="${pageContext.request.contextPath}/staff/orders?page=${currentPage - 1}&status=${selectedStatus}&startDate=${selectedStartDate}&endDate=${selectedEndDate}&keyword=${selectedKeyword}">
                        &laquo; Prev
                      </a>
                    </li>
                  </c:if>
                  
                  <c:forEach var="p" begin="1" end="${totalPages}">
                    <li class="page-item ${p == currentPage ? 'active' : ''}">
                      <a class="page-link" href="${pageContext.request.contextPath}/staff/orders?page=${p}&status=${selectedStatus}&startDate=${selectedStartDate}&endDate=${selectedEndDate}&keyword=${selectedKeyword}">
                        ${p}
                      </a>
                    </li>
                  </c:forEach>
                  
                  <c:if test="${currentPage < totalPages}">
                    <li class="page-item">
                      <a class="page-link" href="${pageContext.request.contextPath}/staff/orders?page=${currentPage + 1}&status=${selectedStatus}&startDate=${selectedStartDate}&endDate=${selectedEndDate}&keyword=${selectedKeyword}">
                        Next &raquo;
                      </a>
                    </li>
                  </c:if>
                </ul>
              </div>
            </c:if>
          </section>

        </div>
      </main>

      <!-- FOOTER -->
      <footer class="admin-footer border-top bg-white py-3">
        <div class="container-fluid px-3 px-lg-4 d-flex align-items-center justify-content-between text-muted fs-7">
          <span>Copyright &copy; 2026 <strong>Manager</strong> • Headphone Store System</span>
          <span>Manager Order Management Dashboard</span>
        </div>
      </footer>
    </div>
  </div>

  <!-- CANCEL REASON MODAL -->
  <div class="modal fade" id="cancelOrderModal" tabindex="-1" aria-labelledby="cancelOrderModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content shadow-lg border-0">
        <form method="post" action="${pageContext.request.contextPath}/staff/orders" id="cancelOrderForm" onsubmit="return validateCancelModal();">
          <input type="hidden" name="action" value="updateStatus">
          <input type="hidden" name="newStatus" value="CANCELLED">
          <input type="hidden" name="orderId" id="modalOrderId" value="">

          <div class="modal-header bg-danger text-white">
            <h5 class="modal-title fw-bold" id="cancelOrderModalLabel">
              <i class="bi bi-x-circle me-2"></i>Cancel Order <span id="modalOrderDisplayId">#ORD-0</span>
            </h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>

          <div class="modal-body">
            <p class="text-secondary small mb-3">Please specify the reason for cancelling this order. This reason will be logged into system records.</p>
            
            <div class="mb-3">
              <label class="form-label fw-semibold fs-7 mb-2">Select Standard Reason:</label>
              <select class="form-select form-select-sm mb-2" id="modalPresetReason" onchange="onPresetReasonChange()">
                <option value="">-- Choose a standard reason --</option>
                <option value="Customer requested order cancellation">Customer requested order cancellation</option>
                <option value="Out of stock / Product currently unavailable">Out of stock / Product currently unavailable</option>
                <option value="Invalid shipping address or contact phone">Invalid shipping address or contact phone</option>
                <option value="Unable to contact customer after multiple attempts">Unable to contact customer after multiple attempts</option>
                <option value="OTHER">Other reason (Type below)...</option>
              </select>
            </div>

            <div class="mb-2">
              <label class="form-label fw-semibold fs-7 mb-1">
                Detailed Reason / Note: <span id="reasonAsterisk" class="text-danger d-none">*</span>
              </label>
              <textarea class="form-control" name="cancelReason" id="modalCancelReason" rows="3" placeholder="Enter detailed reason for cancellation..."></textarea>
            </div>
          </div>

          <div class="modal-footer bg-light">
            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Close</button>
            <button type="submit" class="btn btn-danger btn-sm px-3 fw-bold">
              <i class="bi bi-x-lg me-1"></i> Confirm Cancellation
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Bootstrap 5 JS Bundle -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  
  <!-- Client-side Search, Date Validation, Modal, Export CSV & Theme Toggle Script -->
  <script>
    // Export ALL Matching Orders to Excel / CSV via Servlet Action
    function exportOrdersToCSV() {
      var status = "${selectedStatus}";
      var startDate = document.getElementById('startDate') ? document.getElementById('startDate').value : '';
      var endDate = document.getElementById('endDate') ? document.getElementById('endDate').value : '';
      var keyword = document.getElementById('searchInput') ? document.getElementById('searchInput').value : '';

      var exportUrl = "${pageContext.request.contextPath}/staff/orders?action=export"
        + "&status=" + encodeURIComponent(status)
        + "&startDate=" + encodeURIComponent(startDate)
        + "&endDate=" + encodeURIComponent(endDate)
        + "&keyword=" + encodeURIComponent(keyword);

      window.location.href = exportUrl;
    }

    // Open Cancel Reason Modal
    function openCancelModal(orderId) {
      document.getElementById('modalOrderId').value = orderId;
      document.getElementById('modalOrderDisplayId').innerText = '#ORD-' + orderId;
      document.getElementById('modalPresetReason').value = '';
      document.getElementById('modalCancelReason').value = '';
      document.getElementById('reasonAsterisk').classList.add('d-none');
      var modalEl = new bootstrap.Modal(document.getElementById('cancelOrderModal'));
      modalEl.show();
    }

    // Preset Reason Selection Change
    function onPresetReasonChange() {
      var preset = document.getElementById('modalPresetReason').value;
      var reasonInput = document.getElementById('modalCancelReason');
      var asterisk = document.getElementById('reasonAsterisk');

      if (preset === 'OTHER') {
        reasonInput.value = '';
        reasonInput.focus();
        asterisk.classList.remove('d-none');
      } else if (preset) {
        reasonInput.value = preset;
        asterisk.classList.add('d-none');
      } else {
        reasonInput.value = '';
        asterisk.classList.add('d-none');
      }
    }

    // Validate Cancel Modal Before Submit
    function validateCancelModal() {
      var preset = document.getElementById('modalPresetReason').value;
      var reason = document.getElementById('modalCancelReason').value.trim();
      if (!reason) {
        alert('Please enter or select a reason for cancelling the order!');
        return false;
      }
      return true;
    }

    // Server-side Full Database Search across ALL pages
    var searchTimeout = null;
    var searchInput = document.getElementById('searchInput');
    if (searchInput) {
      searchInput.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') {
          e.preventDefault();
          clearTimeout(searchTimeout);
          document.getElementById('searchForm').submit();
        }
      });

      searchInput.addEventListener('input', function() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(function() {
          document.getElementById('searchForm').submit();
        }, 500);
      });
    }

    // Quick Filter by Metric Card Click
    function filterByCardStatus(status) {
      var statusSelect = document.querySelector('select[name="status"]');
      if (statusSelect) {
        if (statusSelect.value === status) {
          // Toggle back to ALL if clicking active card again
          statusSelect.value = 'ALL';
        } else {
          statusSelect.value = status;
        }
        document.getElementById('filterForm').submit();
      }
    }

    // Date Validation and Submit Handler
    function validateAndSubmit(changedField) {
      var startDateInput = document.getElementById('startDate');
      var endDateInput = document.getElementById('endDate');
      var startVal = startDateInput ? startDateInput.value : '';
      var endVal = endDateInput ? endDateInput.value : '';
      var todayStr = new Date().toISOString().split('T')[0];

      if (changedField === 'startDate') {
        if (startVal && startVal > todayStr) {
          alert('Validation Error: Cannot select future dates!');
          startDateInput.value = '';
          return false;
        }
        if (startVal && endVal && startVal > endVal) {
          alert('Validation Error: "From Date" cannot be later than "To Date"!');
          startDateInput.value = '';
          return false;
        }
      }

      if (changedField === 'endDate') {
        if (endVal && endVal > todayStr) {
          alert('Validation Error: Cannot select future dates!');
          endDateInput.value = '';
          return false;
        }
        if (startVal && endVal && endVal < startVal) {
          alert('Validation Error: "To Date" cannot be earlier than "From Date"!');
          endDateInput.value = '';
          return false;
        }
      }

      document.getElementById('filterForm').submit();
    }

    // Dark / Light Mode Toggle
    var themeToggleBtn = document.getElementById('themeToggleBtn');
    var themeIcon = document.getElementById('themeIcon');
    var htmlTag = document.documentElement;

    themeToggleBtn.addEventListener('click', function() {
      var currentTheme = htmlTag.getAttribute('data-theme');
      if (currentTheme === 'dark') {
        htmlTag.setAttribute('data-theme', 'light');
        themeIcon.className = 'bi bi-moon-stars';
      } else {
        htmlTag.setAttribute('data-theme', 'dark');
        themeIcon.className = 'bi bi-sun-fill';
      }
    });
  </script>
</body>
</html>