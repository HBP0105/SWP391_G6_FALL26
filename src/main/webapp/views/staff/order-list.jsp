<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
  pageContext.setAttribute("dmyFmt", DateTimeFormatter.ofPattern("dd/MM/yyyy"));
  pageContext.setAttribute("timeFmt", DateTimeFormatter.ofPattern("HH:mm:ss"));
%>

<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Order Management | Manager Dashboard</title>

  <!-- Admin_Manager Vendor & Custom Styles -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css?v=20261114-1">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminhmd-style.css">

  <style>
    .date-ddmmyyyy-wrapper {
      position: relative;
    }
    .date-ddmmyyyy-display {
      background-color: #fff !important;
      cursor: pointer;
    }
    .date-native-picker {
      position: absolute;
      top: 0;
      right: 0;
      width: 36px;
      height: 100%;
      opacity: 0;
      cursor: pointer;
      z-index: 2;
    }
    .price-badge {
      font-weight: 700;
      color: var(--admin-primary);
      font-size: 0.76rem;
    }
    .btn-action-sm {
      padding: 0.14rem 0.35rem;
      font-size: 0.67rem;
      font-weight: 600;
      border-radius: 4px;
      white-space: nowrap;
      display: inline-flex;
      align-items: center;
      gap: 2px;
    }
  </style>
</head>

<body>
  <div class="admin-shell">
    <div class="sidebar-backdrop" data-sidebar-close id="sidebarBackdrop"></div>

    <!-- SIDEBAR -->
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
        <a class="nav-link active" href="${pageContext.request.contextPath}/Manager/OrderManagement">
          <span class="nav-icon"><i class="bi bi-cart-check"></i></span>
          <span class="nav-text">Orders</span>
        </a>
        <a class="nav-link" href="${pageContext.request.contextPath}/Manager/Inventory">
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

    <!-- MAIN CONTENT AREA -->
    <div class="admin-main">
      <!-- TOP NAVBAR -->
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
                     alt="Manager"
                     onerror="this.onerror=null;this.src='data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' width=\'34\' height=\'34\' viewBox=\'0 0 34 34\'><rect width=\'34\' height=\'34\' rx=\'8\' fill=\'%232563eb\'/><text x=\'50%25\' y=\'53%25\' dominant-baseline=\'middle\' text-anchor=\'middle\' fill=\'%23ffffff\' font-family=\'sans-serif\' font-size=\'14\' font-weight=\'bold\'>M</text></svg>';">
                <span class="profile-name d-none d-sm-inline">${not empty sessionScope.staff.fullName ? sessionScope.staff.fullName : 'Manager'}</span>
              </button>
              <ul class="dropdown-menu dropdown-menu-end">
                <li>
                  <a class="dropdown-item" href="${pageContext.request.contextPath}/Manager/Profile">Profile</a>
                </li>
                <li>
                  <a class="dropdown-item" href="${pageContext.request.contextPath}/logout">Sign out</a>
                </li>
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
          <c:if test="${not empty msgSuccess || not empty sessionScope.msgSuccess}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
              <i class="bi bi-check-circle-fill me-2"></i><strong>Success!</strong> Order <strong>#ORD-<c:out value="${not empty msgSuccessOrderId ? msgSuccessOrderId : sessionScope.msgSuccessOrderId}"/></strong> updated to: <strong><c:out value="${not empty msgSuccessStatus ? msgSuccessStatus : sessionScope.msgSuccessStatus}"/></strong>
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
          </c:if>

          <!-- Alert Notification Error Status Transition -->
          <c:if test="${not empty msgErrorStatus || not empty sessionScope.msgErrorStatus}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
              <i class="bi bi-x-octagon-fill me-2"></i><strong>Action Rejected:</strong> <c:out value="${not empty msgErrorStatus ? msgErrorStatus : sessionScope.msgErrorStatus}"/>
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
          </c:if>

          <!-- Alert Notification Error Validation -->
          <c:if test="${not empty msgError}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
              <i class="bi bi-exclamation-triangle-fill me-2"></i><strong>Validation Error:</strong> <c:out value="${msgError}"/>
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
                <div class="metric-value"><c:out value="${pendingCount}" default="0"/></div>
                <div class="metric-meta"><small class="text-muted">Pending approval</small></div>
              </div>
            </div>

            <div class="col">
              <div class="metric-card metric-info ${selectedStatus == 'CONFIRMED' ? 'active-metric' : ''}" onclick="filterByCardStatus('CONFIRMED')" title="Click to filter Confirmed orders">
                <div class="metric-top">
                  <span class="metric-label">CONFIRMED</span>
                  <span class="metric-icon"><i class="bi bi-check2-square"></i></span>
                </div>
                <div class="metric-value"><c:out value="${confirmedCount}" default="0"/></div>
                <div class="metric-meta"><small class="text-muted">Processing</small></div>
              </div>
            </div>

            <div class="col">
              <div class="metric-card metric-primary ${selectedStatus == 'SHIPPING' ? 'active-metric' : ''}" onclick="filterByCardStatus('SHIPPING')" title="Click to filter Shipping orders">
                <div class="metric-top">
                  <span class="metric-label">SHIPPING</span>
                  <span class="metric-icon"><i class="bi bi-truck"></i></span>
                </div>
                <div class="metric-value"><c:out value="${shippingCount}" default="0"/></div>
                <div class="metric-meta"><small class="text-muted">In transit to customer</small></div>
              </div>
            </div>

            <div class="col">
              <div class="metric-card metric-success ${selectedStatus == 'DELIVERED' ? 'active-metric' : ''}" onclick="filterByCardStatus('DELIVERED')" title="Click to filter Delivered orders">
                <div class="metric-top">
                  <span class="metric-label">DELIVERED</span>
                  <span class="metric-icon"><i class="bi bi-check-circle-fill"></i></span>
                </div>
                <div class="metric-value"><c:out value="${deliveredCount}" default="0"/></div>
                <div class="metric-meta"><small class="text-muted">Successfully delivered</small></div>
              </div>
            </div>

            <div class="col">
              <div class="metric-card metric-danger ${selectedStatus == 'CANCELLED' ? 'active-metric' : ''}" onclick="filterByCardStatus('CANCELLED')" title="Click to filter Cancelled orders">
                <div class="metric-top">
                  <span class="metric-label">CANCELLED</span>
                  <span class="metric-icon"><i class="bi bi-x-circle-fill"></i></span>
                </div>
                <div class="metric-value"><c:out value="${cancelledCount}" default="0"/></div>
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

            <form method="get" action="${pageContext.request.contextPath}/Manager/OrderManagement" id="filterForm">
              <input type="hidden" name="keyword" value="<c:out value='${selectedKeyword}'/>">
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
                  <label class="form-label fw-semibold fs-7 mb-1">From Date</label>
                  <div class="date-ddmmyyyy-wrapper">
                    <input type="text" id="startDateDisplay" placeholder="dd/mm/yyyy" class="form-control form-control-sm date-ddmmyyyy-display" readonly>
                    <input type="date" class="date-native-picker" name="startDate" id="startDate" value="<c:out value='${selectedStartDate}'/>" max="<%= LocalDate.now() %>" title="Click to pick From Date">
                  </div>
                </div>

                <div class="col-md-3">
                  <label class="form-label fw-semibold fs-7 mb-1">To Date</label>
                  <div class="date-ddmmyyyy-wrapper">
                    <input type="text" id="endDateDisplay" placeholder="dd/mm/yyyy" class="form-control form-control-sm date-ddmmyyyy-display" readonly>
                    <input type="date" class="date-native-picker" name="endDate" id="endDate" value="<c:out value='${selectedEndDate}'/>" max="<%= LocalDate.now() %>" title="Click to pick To Date">
                  </div>
                </div>

                <div class="col-md-3 text-end">
                  <a href="${pageContext.request.contextPath}/Manager/OrderManagement" class="btn btn-outline-secondary btn-sm w-100">
                    <i class="bi bi-x-circle me-1"></i> Clear Filter
                  </a>
                </div>

                <div class="col-12 d-flex align-items-center gap-1 pt-1">
                  <span class="text-muted small me-1" style="font-size: 0.75rem;"><i class="bi bi-lightning-charge-fill text-warning"></i> Quick select:</span>
                  <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('today')">Today</button>
                  <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('7days')">Last 7 days</button>
                  <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('month')">This month</button>
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
                <form method="get" action="${pageContext.request.contextPath}/Manager/OrderManagement" class="m-0" id="searchForm">
                  <input type="hidden" name="status" value="<c:out value='${selectedStatus}'/>">
                  <input type="hidden" name="startDate" value="<c:out value='${selectedStartDate}'/>">
                  <input type="hidden" name="endDate" value="<c:out value='${selectedEndDate}'/>">
                  <div class="input-group input-group-sm">
                    <button type="submit" class="input-group-text bg-white text-muted border-end-0" style="cursor: pointer;" title="Search entire database"><i class="bi bi-search"></i></button>
                    <input class="form-control form-control-sm border-start-0 ps-0" name="keyword" value="<c:out value='${selectedKeyword}'/>" id="searchInput" type="search" placeholder="Search Order ID, Name, Phone..." aria-label="Search" autocomplete="off">
                  </div>
                </form>
              </div>
            </div>

            <div class="table-responsive" style="overflow-x: hidden !important;">
              <table class="table align-middle mb-0 table-orders" id="ordersTable" style="table-layout: fixed; width: 100%;">
                <thead>
                  <tr>
                    <th class="text-center" style="width: 7%;">Order ID</th>
                    <th style="width: 19%;">Customer</th>
                    <th style="width: 17%;">Product Name</th>
                    <th class="text-center" style="width: 5%;">Qty</th>
                    <th class="text-end" style="width: 12%;">Total</th>
                    <th class="text-center" style="width: 10%;">Order Date</th>
                    <th class="text-center" style="width: 9%;">Status</th>
                    <th class="text-center" style="width: 21%;">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="o" items="${orders}">
                    <c:set var="cust" value="${o.customer}" />
                    <c:set var="addr" value="${o.address}" />
                    <c:set var="ship" value="${o.shipment}" />
                    <c:set var="pay" value="${o.payment}" />
                    <c:set var="upperStatus" value="${fn:toUpperCase(o.orderStatus)}" />
                    <tr>
                      <td class="text-center fw-bold text-nowrap" style="font-size: 0.76rem;">#ORD-<c:out value="${o.orderID}"/></td>
                      <td>
                        <div class="fw-bold text-dark text-truncate" style="font-size: 0.75rem;">
                          <i class="bi bi-person-circle text-primary me-1"></i><c:out value="${not empty cust && not empty cust.fullName ? cust.fullName : 'N/A'}" />
                          <small class="text-muted ms-1">(<i class="bi bi-telephone me-0.5"></i><c:out value="${not empty addr && not empty addr.receiverPhone ? addr.receiverPhone : (not empty cust && not empty cust.phone ? cust.phone : 'N/A')}" />)</small>
                        </div>
                        <div class="address-cell text-muted text-truncate" style="font-size: 0.68rem;">
                          <i class="bi bi-geo-alt text-danger me-1"></i><c:out value="${not empty o.shippingAddress ? o.shippingAddress : (not empty addr && not empty addr.addressLine ? addr.addressLine : 'N/A')}" />
                        </div>
                      </td>
                      <td>
                        <div class="fw-bold text-dark" style="font-size: 0.75rem; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; line-height: 1.35; max-height: 2.7em; word-break: break-word;" title="<c:out value="${not empty o.productSummary ? o.productSummary : 'Headphone Product'}" />">
                          <i class="bi bi-headphones text-primary me-1"></i><c:out value="${not empty o.productSummary ? o.productSummary : 'Headphone Product'}" />
                        </div>
                        <c:if test="${(upperStatus == 'SHIPPING' || upperStatus == 'DELIVERED') && not empty o.shippingName}">
                          <div style="font-size: 0.65rem;" class="text-info mt-0.5 text-truncate">
                            <i class="bi bi-truck me-1"></i>Shipper: <c:out value="${o.shippingName}" /> <c:if test="${not empty o.shippingPhone}">(<c:out value="${o.shippingPhone}" />)</c:if>
                          </div>
                        </c:if>
                      </td>
                      <td class="text-center text-nowrap">
                        <span class="badge text-bg-light border text-dark fw-bold" style="font-size: 0.72rem; padding: 0.25em 0.55em;" title="Total quantity of items in this order">
                          <c:out value="${o.totalQuantity}" />
                        </span>
                      </td>
                      <td class="text-end price-badge text-nowrap" style="font-size: 0.76rem;">
                        <div><fmt:formatNumber value="${o.totalAmount}" pattern="#,###"/> VND</div>
                        <c:set var="upperPayStatus" value="${not empty pay ? fn:toUpperCase(pay.paymentStatus) : ''}" />
                        <c:set var="isPaid" value="${upperPayStatus == 'SUCCESS' || upperPayStatus == 'PAID' || upperPayStatus == 'COMPLETED' || upperStatus == 'DELIVERED'}" />
                        <c:set var="payMethod" value="${not empty pay && not empty pay.paymentMethod ? fn:toUpperCase(pay.paymentMethod) : 'COD'}" />
                        <c:choose>
                          <c:when test="${payMethod == 'VNPAY'}">
                            <span class="badge ${isPaid ? 'text-bg-success' : 'text-bg-warning'}" style="font-size: 0.62rem; padding: 0.15em 0.38em;">
                              <i class="bi bi-qr-code-scan me-1"></i>VNPAY ${isPaid ? '(Paid)' : '(Unpaid)'}
                            </span>
                          </c:when>
                          <c:when test="${payMethod == 'BANK_TRANSFER' || payMethod == 'BANKING'}">
                            <span class="badge ${isPaid ? 'text-bg-info text-white' : 'text-bg-warning'}" style="font-size: 0.62rem; padding: 0.15em 0.38em;">
                              <i class="bi bi-bank me-1"></i>Banking ${isPaid ? '(Paid)' : '(Unpaid)'}
                            </span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge ${isPaid ? 'text-bg-success' : 'text-bg-light border text-secondary'}" style="font-size: 0.62rem; padding: 0.15em 0.38em;">
                              <i class="bi bi-cash-stack me-1"></i>COD ${isPaid ? '(Paid)' : '(Unpaid)'}
                            </span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-center">
                        <div class="lh-sm text-nowrap" style="font-size: 0.71rem;">
                          <c:if test="${not empty o.orderDate}">
                            <div><i class="bi bi-calendar3 me-1 text-muted"></i><c:out value="${o.orderDate.format(dmyFmt)}"/></div>
                            <small class="text-muted d-block" style="font-size: 0.67rem;"><c:out value="${o.orderDate.format(timeFmt)}"/></small>
                          </c:if>
                        </div>
                      </td>
                      <td class="text-center">
                        <c:choose>
                          <c:when test="${upperStatus == 'PENDING'}">
                            <span class="badge text-bg-warning" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-clock me-1"></i>Pending</span>
                          </c:when>
                          <c:when test="${upperStatus == 'CONFIRMED'}">
                            <span class="badge text-bg-info" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-check-lg me-1"></i>Confirmed</span>
                          </c:when>
                          <c:when test="${upperStatus == 'SHIPPING'}">
                            <span class="badge text-bg-primary" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-truck me-1"></i>Shipping</span>
                          </c:when>
                          <c:when test="${upperStatus == 'DELIVERED'}">
                            <span class="badge text-bg-success" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-check-circle me-1"></i>Delivered</span>
                          </c:when>
                          <c:when test="${upperStatus == 'CANCELLED'}">
                            <span class="badge text-bg-danger" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-x-circle me-1"></i>Cancelled</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge text-bg-secondary" style="font-size: 0.68rem; padding: 0.22em 0.45em;"><i class="bi bi-question-circle me-1"></i><c:out value="${o.orderStatus}" default="Unknown"/></span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-center" style="white-space: nowrap;">
                        <div class="d-inline-flex gap-1 align-items-center justify-content-center">
                          <c:choose>
                            <c:when test="${upperStatus == 'PENDING'}">
                              <form method="post" action="${pageContext.request.contextPath}/Manager/OrderManagement" style="display:inline;" onsubmit="return confirm('Are you sure you want to CONFIRM order #ORD-${o.orderID}?');">
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
                            <c:when test="${upperStatus == 'CONFIRMED'}">
                              <c:set var="rowAddr" value="${not empty addr && not empty addr.fullAddress ? addr.fullAddress : (not empty o.shippingAddress ? o.shippingAddress : '')}" />
                              <button type="button" class="btn btn-primary btn-action-sm" title="Start shipping" onclick="openShipModal(${o.orderID}, '${fn:escapeXml(o.shippingName)}', '${fn:escapeXml(o.shippingPhone)}', '${fn:escapeXml(rowAddr)}')">
                                <i class="bi bi-truck"></i> Ship
                              </button>
                              <button type="button" class="btn btn-danger btn-action-sm" title="Cancel order" onclick="openCancelModal(${o.orderID})">
                                <i class="bi bi-x-lg"></i> Cancel
                              </button>
                            </c:when>
                            <c:when test="${upperStatus == 'SHIPPING'}">
                              <form method="post" action="${pageContext.request.contextPath}/Manager/OrderManagement" style="display:inline;" onsubmit="return confirm('Are you sure you want to mark order #ORD-${o.orderID} as COMPLETED?');">
                                <input type="hidden" name="action" value="updateStatus">
                                <input type="hidden" name="orderId" value="${o.orderID}">
                                <input type="hidden" name="newStatus" value="DELIVERED">
                                <button type="submit" class="btn btn-success btn-action-sm" title="Complete order">
                                  <i class="bi bi-check-circle"></i> Complete
                                </button>
                              </form>
                              <button type="button" class="btn btn-danger btn-action-sm" title="Cancel order" onclick="openCancelModal(${o.orderID})">
                                <i class="bi bi-x-lg"></i> Cancel
                              </button>
                            </c:when>
                          </c:choose>

                          <a href="${pageContext.request.contextPath}/Manager/OrderManagement/Detail?id=${o.orderID}" class="btn btn-light btn-action-sm border" title="View Order Details">
                            <i class="bi bi-eye"></i> Details
                          </a>
                        </div>
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
                    <c:url var="prevPageUrl" value="/Manager/OrderManagement">
                      <c:param name="page" value="${currentPage - 1}"/>
                      <c:param name="status" value="${selectedStatus}"/>
                      <c:param name="startDate" value="${selectedStartDate}"/>
                      <c:param name="endDate" value="${selectedEndDate}"/>
                      <c:param name="keyword" value="${selectedKeyword}"/>
                    </c:url>
                    <li class="page-item">
                      <a class="page-link" href="${prevPageUrl}">&laquo; Prev</a>
                    </li>
                  </c:if>
                  
                  <c:forEach var="p" begin="1" end="${totalPages}">
                    <c:url var="pageUrl" value="/Manager/OrderManagement">
                      <c:param name="page" value="${p}"/>
                      <c:param name="status" value="${selectedStatus}"/>
                      <c:param name="startDate" value="${selectedStartDate}"/>
                      <c:param name="endDate" value="${selectedEndDate}"/>
                      <c:param name="keyword" value="${selectedKeyword}"/>
                    </c:url>
                    <li class="page-item ${p == currentPage ? 'active' : ''}">
                      <a class="page-link" href="${pageUrl}">${p}</a>
                    </li>
                  </c:forEach>
                  
                  <c:if test="${currentPage < totalPages}">
                    <c:url var="nextPageUrl" value="/Manager/OrderManagement">
                      <c:param name="page" value="${currentPage + 1}"/>
                      <c:param name="status" value="${selectedStatus}"/>
                      <c:param name="startDate" value="${selectedStartDate}"/>
                      <c:param name="endDate" value="${selectedEndDate}"/>
                      <c:param name="keyword" value="${selectedKeyword}"/>
                    </c:url>
                    <li class="page-item">
                      <a class="page-link" href="${nextPageUrl}">Next &raquo;</a>
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
        <form method="post" action="${pageContext.request.contextPath}/Manager/OrderManagement" id="cancelOrderForm" onsubmit="return validateCancelModal();">
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

  <!-- SHIPPING INFORMATION MODAL -->
  <div class="modal fade" id="shipOrderModal" tabindex="-1" aria-labelledby="shipOrderModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content shadow-lg border-0">
        <form method="post" action="${pageContext.request.contextPath}/Manager/OrderManagement" onsubmit="return validateShipModal()">
          <input type="hidden" name="action" value="updateStatus">
          <input type="hidden" name="orderId" id="shipModalOrderId">
          <input type="hidden" name="newStatus" value="SHIPPING">

          <div class="modal-header bg-primary text-white">
            <h5 class="modal-title fw-bold" id="shipOrderModalLabel">
              <i class="bi bi-truck me-2"></i>Start Shipping Order <span id="shipModalOrderDisplayId">#ORD-0</span>
            </h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>

          <div class="modal-body">
            <p class="text-secondary small mb-3">Please select the shipping courier, enter shipper details, and tracking code for this delivery.</p>

            <div class="row g-2 mb-3">
              <div class="col-sm-6">
                <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-person-badge text-success me-1"></i>Shipper Name:</label>
                <input type="text" class="form-control form-control-sm" name="shipperName" id="shipModalShipperName" placeholder="e.g. Nguyễn Văn Vận">
              </div>
              <div class="col-sm-6">
                <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-telephone text-success me-1"></i>Shipper Phone:</label>
                <input type="text" class="form-control form-control-sm" name="shipperPhone" id="shipModalShipperPhone" placeholder="e.g. 0988112233">
              </div>
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold fs-7 mb-2"><i class="bi bi-building text-primary me-1"></i>Courier / Shipping Carrier:</label>
              <select class="form-select form-select-sm" name="shippingProvider" id="shipModalProvider" onchange="onShippingProviderChange()">
                <option value="Giao Hàng Nhanh (GHN)">Giao Hàng Nhanh (GHN)</option>
                <option value="Giao Hàng Tiết Kiệm (GHTK)">Giao Hàng Tiết Kiệm (GHTK)</option>
                <option value="Viettel Post (VTP)">Viettel Post (VTP)</option>
                <option value="Shopee Express (SPX)">Shopee Express (SPX)</option>
                <option value="VNPost (Bưu điện Việt Nam)">VNPost (Bưu điện Việt Nam)</option>
              </select>
            </div>

            <div class="mb-2">
              <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-barcode text-info me-1"></i>Tracking Code / Waybill Number:</label>
              <input type="text" class="form-control form-control-sm" name="trackingNumber" id="shipModalTracking" placeholder="e.g. GHN88921049 (Leave empty to auto-generate)">
              <small class="text-muted d-block mt-1 fs-8">* Smart Auto-Fill: Pre-generated based on carrier and customer location.</small>
            </div>
          </div>

          <div class="modal-footer bg-light">
            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-primary btn-sm px-3 fw-bold">
              <i class="bi bi-truck me-1"></i> Confirm & Start Shipping
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Admin_Manager JS Bundle & Main Script -->
  <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js?v=20261114-1"></script>
  
  <!-- Client-side Search, Date Validation, Modal, Export CSV & Theme Toggle Script -->
  <script>
    // Smart Shipping Courier & Tracking Number Helpers
    function autoDetectShippingProvider(address) {
      if (!address) return 'Giao Hàng Nhanh (GHN)';
      var addr = address.toLowerCase();
      if (addr.indexOf('hà nội') !== -1 || addr.indexOf('hanoi') !== -1 ||
          addr.indexOf('hồ chí minh') !== -1 || addr.indexOf('ho chi minh') !== -1 ||
          addr.indexOf('hcm') !== -1 || addr.indexOf('sài gòn') !== -1 || addr.indexOf('sai gon') !== -1 ||
          addr.indexOf('đà nẵng') !== -1 || addr.indexOf('da nang') !== -1) {
        return 'Giao Hàng Nhanh (GHN)';
      }
      return 'Viettel Post (VTP)';
    }

    function generateTrackingNumber(provider) {
      var prefix = 'GHN';
      if (provider.indexOf('GHTK') !== -1) prefix = 'GHTK';
      else if (provider.indexOf('Viettel') !== -1 || provider.indexOf('VTP') !== -1) prefix = 'VTP';
      else if (provider.indexOf('Shopee') !== -1 || provider.indexOf('SPX') !== -1) prefix = 'SPX';
      else if (provider.indexOf('VNPost') !== -1) prefix = 'VNP';
      var randomCode = Math.floor(100000000 + Math.random() * 900000000);
      return prefix + randomCode;
    }

    function onShippingProviderChange() {
      var provider = document.getElementById('shipModalProvider').value;
      var trackingInput = document.getElementById('shipModalTracking');
      if (trackingInput) {
        trackingInput.value = generateTrackingNumber(provider);
      }
    }

    // Open Ship Modal with Smart Auto-detection
    function openShipModal(orderId, shipperName, shipperPhone, address) {
      document.getElementById('shipModalOrderId').value = orderId;
      document.getElementById('shipModalOrderDisplayId').innerText = '#ORD-' + orderId;

      var detectedProvider = autoDetectShippingProvider(address);
      var providerSelect = document.getElementById('shipModalProvider');
      if (providerSelect) {
        providerSelect.value = detectedProvider;
      }

      var trackingInput = document.getElementById('shipModalTracking');
      if (trackingInput) {
        trackingInput.value = generateTrackingNumber(detectedProvider);
      }

      document.getElementById('shipModalShipperName').value = shipperName || '';
      document.getElementById('shipModalShipperPhone').value = shipperPhone || '';

      var shipBtn = document.querySelector('#shipOrderModal button[type="submit"]');
      if (shipBtn) {
        shipBtn.disabled = false;
        shipBtn.dataset.submitting = 'false';
        shipBtn.innerHTML = '<i class="bi bi-truck me-1"></i> Confirm & Start Shipping';
      }

      var modalEl = new bootstrap.Modal(document.getElementById('shipOrderModal'));
      modalEl.show();
    }

    // Validate Ship Modal Form (Shipper Phone Regex & Double-submit Protection)
    function validateShipModal() {
      var phoneInput = document.getElementById('shipModalShipperPhone');
      if (phoneInput && phoneInput.value.trim() !== '') {
        var phoneVal = phoneInput.value.trim();
        var vnPhoneRegex = /^(0[35789])[0-9]{8}$/;
        if (!vnPhoneRegex.test(phoneVal)) {
          alert('Invalid shipper phone number! Please enter a valid 10-digit Vietnamese phone number (starting with 03, 05, 07, 08, 09).');
          phoneInput.focus();
          return false;
        }
      }

      var submitBtn = document.querySelector('#shipOrderModal button[type="submit"]');
      if (submitBtn) {
        if (submitBtn.dataset.submitting === 'true') {
          return false;
        }
        submitBtn.dataset.submitting = 'true';
        setTimeout(function() {
          submitBtn.disabled = true;
          submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Processing...';
        }, 10);
      }
      return true;
    }

    // Export ALL Matching Orders to Excel / CSV via Servlet Action
    function exportOrdersToCSV() {
      var statusSelect = document.querySelector('select[name="status"]');
      var status = statusSelect ? statusSelect.value : 'ALL';
      var startDate = document.getElementById('startDate') ? document.getElementById('startDate').value : '';
      var endDate = document.getElementById('endDate') ? document.getElementById('endDate').value : '';
      var keyword = document.getElementById('searchInput') ? document.getElementById('searchInput').value : '';

      var exportUrl = "${pageContext.request.contextPath}/Manager/OrderManagement?action=export"
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

      var cancelBtn = document.querySelector('#cancelOrderModal button[type="submit"]');
      if (cancelBtn) {
        cancelBtn.disabled = false;
        cancelBtn.dataset.submitting = 'false';
        cancelBtn.innerHTML = '<i class="bi bi-x-lg me-1"></i> Confirm Cancellation';
      }

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

    // Validate Cancel Modal Before Submit (Double-submit Protection)
    function validateCancelModal() {
      var preset = document.getElementById('modalPresetReason').value;
      var reason = document.getElementById('modalCancelReason').value.trim();
      if (!reason) {
        alert('Please enter or select a reason for cancelling the order!');
        return false;
      }
      var submitBtn = document.querySelector('#cancelOrderModal button[type="submit"]');
      if (submitBtn) {
        if (submitBtn.dataset.submitting === 'true') {
          return false;
        }
        submitBtn.dataset.submitting = 'true';
        setTimeout(function() {
          submitBtn.disabled = true;
          submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Processing...';
        }, 10);
      }
      return true;
    }

    // Search input handler (Triggers on Enter key press or search button click)
    var searchInput = document.getElementById('searchInput');
    if (searchInput) {
      searchInput.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') {
          e.preventDefault();
          document.getElementById('searchForm').submit();
        }
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

    // Format Date object to local YYYY-MM-DD
    function formatLocalDate(d) {
      var year = d.getFullYear();
      var month = String(d.getMonth() + 1).padStart(2, '0');
      var day = String(d.getDate()).padStart(2, '0');
      return year + '-' + month + '-' + day;
    }

    // Quick Date Range Filter Handler
    function setQuickDate(type) {
      var now = new Date();
      var todayStr = formatLocalDate(now);
      var startStr = todayStr;
      var endStr = todayStr;

      if (type === 'today') {
        startStr = todayStr;
        endStr = todayStr;
      } else if (type === '7days') {
        var d7 = new Date();
        d7.setDate(now.getDate() - 6);
        startStr = formatLocalDate(d7);
        endStr = todayStr;
      } else if (type === 'month') {
        var firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
        startStr = formatLocalDate(firstDay);
        endStr = todayStr;
      }

      var startInput = document.getElementById('startDate');
      var endInput = document.getElementById('endDate');
      var startDisplay = document.getElementById('startDateDisplay');
      var endDisplay = document.getElementById('endDateDisplay');

      if (startInput) startInput.value = startStr;
      if (endInput) endInput.value = endStr;
      if (startDisplay) startDisplay.value = formatToDMY(startStr);
      if (endDisplay) endDisplay.value = formatToDMY(endStr);

      var form = document.getElementById('filterForm');
      if (form) form.submit();
    }

    // Date formatting helper (yyyy-mm-dd -> dd/mm/yyyy)
    function formatToDMY(isoDateStr) {
      if (!isoDateStr) return '';
      var parts = isoDateStr.split('-');
      if (parts.length === 3) {
        return parts[2] + '/' + parts[1] + '/' + parts[0];
      }
      return isoDateStr;
    }

    // Date Validation and Submit Handler
    function validateAndSubmit(changedField) {
      var startDateInput = document.getElementById('startDate');
      var endDateInput = document.getElementById('endDate');
      var startDisplay = document.getElementById('startDateDisplay');
      var endDisplay = document.getElementById('endDateDisplay');
      var startVal = startDateInput ? startDateInput.value : '';
      var endVal = endDateInput ? endDateInput.value : '';
      var todayStr = new Date().toISOString().split('T')[0];

      if (changedField === 'startDate') {
        if (startVal && startVal > todayStr) {
          alert('Validation Error: Cannot select future dates!');
          startDateInput.value = '';
          if (startDisplay) startDisplay.value = '';
          return false;
        }
        if (startVal && endVal && startVal > endVal) {
          alert('Validation Error: "From Date" cannot be later than "To Date"!');
          startDateInput.value = '';
          if (startDisplay) startDisplay.value = '';
          return false;
        }
      }

      if (changedField === 'endDate') {
        if (endVal && endVal > todayStr) {
          alert('Validation Error: Cannot select future dates!');
          endDateInput.value = '';
          if (endDisplay) endDisplay.value = '';
          return false;
        }
        if (startVal && endVal && endVal < startVal) {
          alert('Validation Error: "To Date" cannot be earlier than "From Date"!');
          endDateInput.value = '';
          if (endDisplay) endDisplay.value = '';
          return false;
        }
      }

      var form = document.getElementById('filterForm');
      if (form) form.submit();
    }

    document.addEventListener('DOMContentLoaded', function() {
      var startInput = document.getElementById('startDate');
      var endInput = document.getElementById('endDate');
      var startDisplay = document.getElementById('startDateDisplay');
      var endDisplay = document.getElementById('endDateDisplay');

      if (startInput && startDisplay) {
        startDisplay.value = formatToDMY(startInput.value);
        startInput.addEventListener('input', function() {
          startDisplay.value = formatToDMY(this.value);
        });
        startInput.addEventListener('change', function() {
          startDisplay.value = formatToDMY(this.value);
          validateAndSubmit('startDate');
        });
        startDisplay.addEventListener('click', function() {
          if (startInput.showPicker) {
            startInput.showPicker();
          } else {
            startInput.focus();
          }
        });
      }

      if (endInput && endDisplay) {
        endDisplay.value = formatToDMY(endInput.value);
        endInput.addEventListener('input', function() {
          endDisplay.value = formatToDMY(this.value);
        });
        endInput.addEventListener('change', function() {
          endDisplay.value = formatToDMY(this.value);
          validateAndSubmit('endDate');
        });
        endDisplay.addEventListener('click', function() {
          if (endInput.showPicker) {
            endInput.showPicker();
          } else {
            endInput.focus();
          }
        });
      }
    });

    // Dark / Light Mode Toggle handled by main.js
    var themeToggleBtn = document.getElementById('themeToggleBtn');
    var themeIcon = document.getElementById('themeIcon');
    var htmlTag = document.documentElement;

    if (themeToggleBtn) {
      themeToggleBtn.addEventListener('click', function() {
        var currentTheme = htmlTag.getAttribute('data-theme');
        if (currentTheme === 'dark') {
          htmlTag.setAttribute('data-theme', 'light');
          if (themeIcon) themeIcon.className = 'bi bi-moon-stars';
        } else {
          htmlTag.setAttribute('data-theme', 'dark');
          if (themeIcon) themeIcon.className = 'bi bi-sun-fill';
        }
      });
    }
  </script>
</body>
</html>
