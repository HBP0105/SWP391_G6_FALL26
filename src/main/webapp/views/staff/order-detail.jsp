<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Order Details #ORD-${order.orderID} | Manager Dashboard</title>

  <!-- Bootstrap 5 CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- adminHMD Custom Style -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminhmd-style.css">

  <style>
    html, body {
      height: 100vh;
      margin: 0;
      overflow: hidden;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    }
    .admin-shell {
      height: 100vh;
      overflow: hidden;
      display: flex;
    }
    .admin-main {
      height: 100vh;
      display: flex;
      flex-direction: column;
      flex: 1;
      overflow: hidden;
    }
    .dashboard-content {
      flex: 1;
      overflow-y: auto !important;
      padding: 0.5rem 0.85rem !important;
      display: flex;
      flex-direction: column;
      background: var(--admin-bg, #f8fafc);
    }
    .panel-compact {
      padding: 0.45rem 0.7rem !important;
      margin-bottom: 0.4rem !important;
      border-radius: 8px;
      border: 1px solid rgba(0,0,0,0.06);
      box-shadow: 0 1px 3px rgba(0,0,0,0.03);
    }
    .invoice-table td, .invoice-table th {
      padding: 0.3rem 0.55rem !important;
      font-size: 0.75rem !important;
    }
    .items-table-wrapper {
      max-height: 250px;
      overflow-y: auto;
    }
    .price-badge {
      font-weight: 700;
      color: #0284c7;
      font-size: 0.75rem;
    }

    /* PRINT ONLY STYLES FOR OFFICIAL INVOICE RECEIPT */
    @media print {
      html, body {
        height: auto !important;
        overflow: visible !important;
        background: #ffffff !important;
      }
      .admin-shell, .admin-main, .dashboard-content, .admin-sidebar, .navbar, .modal {
        display: none !important;
      }
      .print-official-invoice {
        display: block !important;
        width: 100% !important;
      }
    }
  </style>
</head>

<body>

  <!-- ================================================================= -->
  <!-- DEDICATED OFFICIAL PRINT INVOICE RECEIPT (ONLY VISIBLE ON PRINT)  -->
  <!-- ================================================================= -->
  <div class="print-official-invoice d-none d-print-block p-4 bg-white text-dark" style="font-family: Arial, sans-serif; font-size: 12px; line-height: 1.4;">
    <!-- Store Header -->
    <div class="d-flex justify-content-between align-items-start border-bottom pb-3 mb-3">
      <div>
        <h2 class="fw-bold mb-1 text-primary" style="letter-spacing: -0.5px;">HEADPHONE STORE</h2>
        <p class="mb-0 text-secondary fw-semibold">SALES INVOICE & DELIVERY RECEIPT</p>
        <div class="text-muted small mt-1">
          <div>Address: 123 Nguyen Trai, Thanh Xuan Dist, Hanoi</div>
          <div>Hotline: 1900-8888 | Email: cskh@headphonestore.vn | Website: headphone.store.vn</div>
        </div>
      </div>
      <div class="text-end border p-2 rounded bg-light" style="min-width: 230px;">
        <h4 class="fw-bold text-dark mb-0">INVOICE #ORD-${order.orderID}</h4>
      </div>
    </div>

    <!-- 2 Columns Box: Buyer & Delivery Address -->
    <div class="row g-3 mb-3">
      <div class="col-6">
        <div class="p-2.5 border rounded h-100 bg-light">
          <h6 class="fw-bold border-bottom pb-1 mb-2 text-uppercase text-secondary" style="font-size: 11px;">1. CUSTOMER & DELIVERY INFORMATION</h6>
          <div><strong>Full Name:</strong> <c:out value="${not empty address && not empty address.receiverName ? address.receiverName : (not empty customer && not empty customer.fullName ? customer.fullName : 'N/A')}" /></div>
          <div><strong>Email Address:</strong> <c:out value="${not empty customer && not empty customer.email ? customer.email : 'N/A'}" /></div>
          <div><strong>Phone Number:</strong> <c:out value="${not empty address && not empty address.receiverPhone ? address.receiverPhone : (not empty customer && not empty customer.phone ? customer.phone : 'N/A')}" /></div>
          <div><strong>Account ID:</strong> #CUST-${order.customerID}</div>
          <div><strong>Delivery Address:</strong> <c:out value="${not empty address && not empty address.fullAddress ? address.fullAddress : (not empty order.shippingAddress ? order.shippingAddress : 'N/A')}" /></div>
        </div>
      </div>
      <div class="col-6">
        <div class="p-2.5 border rounded h-100 bg-light">
          <h6 class="fw-bold border-bottom pb-1 mb-2 text-uppercase text-secondary" style="font-size: 11px;">2. ORDER & SHIPPING DETAILS</h6>
          <div><strong>Order Date:</strong> <c:out value="${order.formattedOrderDateTime}" /></div>
          <div><strong>Status:</strong> <c:out value="${order.orderStatus}" /></div>
          <c:if test="${(order.orderStatus == 'SHIPPING' || order.orderStatus == 'Shipping' || order.orderStatus == 'DELIVERED' || order.orderStatus == 'Delivered') && not empty order.shippingName}">
            <div><strong>Assigned Shipper:</strong> <c:out value="${order.shippingName}" /> <c:if test="${not empty order.shippingPhone}">(Phone: <c:out value="${order.shippingPhone}" />)</c:if></div>
          </c:if>
          <c:if test="${not empty shipment}">
            <div><strong>Courier / Carrier:</strong> <c:out value="${not empty shipment.shippingProvider ? shipment.shippingProvider : 'Standard Express Delivery'}" /> <c:if test="${not empty shipment.trackingNumber}">(Tracking Code: <c:out value="${shipment.trackingNumber}" />)</c:if></div>
          </c:if>
          <div><strong>Estimated Delivery Date:</strong> 
            <c:choose>
              <c:when test="${not empty shipment && not empty shipment.formattedEstimatedDate}">
                <c:out value="${shipment.formattedEstimatedDate}" />
              </c:when>
              <c:otherwise>3-5 business days</c:otherwise>
            </c:choose>
          </div>
          <div><strong>Actual Delivery Date:</strong> 
            <c:choose>
              <c:when test="${not empty shipment && not empty shipment.formattedDeliveredAt}">
                <c:out value="${shipment.formattedDeliveredAt}" />
              </c:when>
              <c:when test="${order.orderStatus == 'DELIVERED' || order.orderStatus == 'Delivered'}">
                <c:choose>
                  <c:when test="${not empty order.updatedAt}">
                    <c:out value="${order.formattedUpdatedAt}" />
                  </c:when>
                  <c:otherwise><c:out value="${order.formattedOrderDateTime}" /></c:otherwise>
                </c:choose>
              </c:when>
              <c:otherwise>Pending Delivery</c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </div>

    <!-- Purchased Products Table -->
    <div class="mb-3">
      <h6 class="fw-bold mb-2 text-uppercase text-secondary" style="font-size: 11px;">3. PURCHASED PRODUCTS LIST</h6>
      <table class="table table-bordered align-middle mb-0" style="font-size: 11px;">
        <thead class="table-secondary">
          <tr>
            <th class="text-center" style="width: 40px;">#</th>
            <th>Headphone Product Name</th>
            <th class="text-center" style="width: 90px;">Product ID</th>
            <th class="text-end" style="width: 110px;">Unit Price</th>
            <th class="text-center" style="width: 50px;">Qty</th>
            <th class="text-end" style="width: 120px;">Subtotal</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="item" items="${items}" varStatus="loop">
            <tr>
              <td class="text-center fw-bold">${loop.index + 1}</td>
              <td><strong class="text-dark"><c:out value="${item.productName}" /></strong></td>
              <td class="text-center">#${item.productID}</td>
              <td class="text-end"><fmt:formatNumber value="${item.unitPrice}" pattern="#,###"/> VND</td>
              <td class="text-center fw-bold">${item.quantity}</td>
              <td class="text-end fw-bold"><fmt:formatNumber value="${item.subtotal}" pattern="#,###"/> VND</td>
            </tr>
          </c:forEach>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="5" class="text-end fw-bold">ITEMS TOTAL:</td>
            <td class="text-end fw-bold"><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/> VND</td>
          </tr>
          <tr>
            <td colspan="5" class="text-end fw-bold">SHIPPING FEE:</td>
            <td class="text-end text-success fw-bold">0 VND (Free)</td>
          </tr>
          <tr class="table-light">
            <td colspan="5" class="text-end fw-bold fs-6">GRAND TOTAL:</td>
            <td class="text-end fw-bold text-primary fs-6"><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/> VND</td>
          </tr>
        </tfoot>
      </table>
    </div>

    <!-- Payment Summary Box -->
    <div class="p-2 border rounded bg-light mb-4 small">
      <strong>Payment Method:</strong> 
      <span class="fw-bold"><c:out value="${detailPayMethod}" /></span> 
      <span class="badge ${isDetailPaid ? 'text-bg-success' : 'text-bg-warning'} ms-1">${isDetailPaid ? 'Paid' : 'Unpaid'}</span>
      <span class="ms-3">|</span> <span class="ms-3 text-muted">Note: Please inspect items carefully before signing receipt.</span>
    </div>

    <!-- Signatures -->
    <div class="row text-center mt-4 pt-3">
      <div class="col-6">
        <div class="fw-bold">RECEIVER SIGNATURE</div>
        <div class="small text-muted">(Sign & Print Full Name)</div>
        <div style="height: 60px;"></div>
        <div class="fw-semibold"><c:out value="${not empty address ? address.receiverName : (not empty customer ? customer.fullName : '')}" /></div>
      </div>
      <div class="col-6">
        <div class="fw-bold">STORE REPRESENTATIVE</div>
        <div class="small text-muted">(Sign & Stamp)</div>
        <div style="height: 60px;"></div>
        <div class="fw-semibold">Headphone Store Manager</div>
      </div>
    </div>
  </div>


  <!-- ================================================================= -->
  <!-- SCREEN DASHBOARD UI (FIT 1 SCREEN VIEWPORT WITHOUT SCROLLING)     -->
  <!-- ================================================================= -->
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
      <!-- TOP NAVBAR (UNIFIED HEADER BAR WITH ORDER INFO, STATUS & ACTIONS) -->
      <nav class="navbar admin-navbar navbar-expand bg-white py-1 px-3 border-bottom shadow-sm">
        <div class="container-fluid px-0 d-flex align-items-center justify-content-between">
          
          <!-- Left: Order Title, Back Button & Status Badge -->
          <div class="d-flex align-items-center gap-2">
            <a href="${pageContext.request.contextPath}/staff/orders" class="btn btn-outline-secondary btn-sm px-2 py-0.5" style="font-size: 0.72rem;">
              <i class="bi bi-arrow-left me-1"></i> Orders
            </a>
            <span class="text-muted fs-7">/</span>
            <span class="fw-bold text-dark" style="font-size: 0.9rem;">Order #ORD-${order.orderID}</span>
            <c:choose>
              <c:when test="${order.orderStatus == 'PENDING'}">
                <span class="badge text-bg-warning" style="font-size: 0.68rem;"><i class="bi bi-clock me-1"></i>PENDING</span>
              </c:when>
              <c:when test="${order.orderStatus == 'CONFIRMED'}">
                <span class="badge text-bg-info" style="font-size: 0.68rem;"><i class="bi bi-check-lg me-1"></i>CONFIRMED</span>
              </c:when>
              <c:when test="${order.orderStatus == 'SHIPPING'}">
                <span class="badge text-bg-primary" style="font-size: 0.68rem;"><i class="bi bi-truck me-1"></i>SHIPPING</span>
              </c:when>
              <c:when test="${order.orderStatus == 'DELIVERED'}">
                <span class="badge text-bg-success" style="font-size: 0.68rem;"><i class="bi bi-check-circle me-1"></i>DELIVERED</span>
              </c:when>
              <c:otherwise>
                <span class="badge text-bg-danger" style="font-size: 0.68rem;"><i class="bi bi-x-circle me-1"></i>CANCELLED</span>
              </c:otherwise>
            </c:choose>
          </div>

          <!-- Right: Print Official Invoice Button, Theme Toggle Moon Icon & Profile Dropdown -->
          <div class="navbar-actions d-flex align-items-center gap-2 ms-auto">
            <button onclick="window.print();" class="btn btn-primary btn-sm px-2.5 py-0.5 shadow-sm fw-bold me-1" style="font-size: 0.73rem;">
              <i class="bi bi-printer-fill me-1"></i> Print Official Invoice
            </button>
            <button class="icon-button theme-toggle" id="themeToggleBtn" type="button" title="Switch Light/Dark Theme">
              <i class="bi bi-moon-stars" id="themeIcon"></i>
            </button>
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

      <!-- DASHBOARD CONTENT (FIT 1 SCREEN) -->
      <main class="dashboard-content">

        <!-- Alert Notifications -->
        <c:if test="${not empty msgSuccess || not empty sessionScope.msgSuccess}">
          <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-2 py-1 px-2" role="alert" style="font-size: 0.76rem;">
            <i class="bi bi-check-circle-fill me-1"></i><strong>Success!</strong> Order <strong>#ORD-<c:out value="${not empty msgSuccessOrderId ? msgSuccessOrderId : sessionScope.msgSuccessOrderId}"/></strong> updated to: <strong><c:out value="${not empty msgSuccessStatus ? msgSuccessStatus : sessionScope.msgSuccessStatus}"/></strong>
            <button type="button" class="btn-close py-1" data-bs-dismiss="alert" aria-label="Close"></button>
          </div>
        </c:if>

        <c:if test="${not empty msgErrorStatus || not empty sessionScope.msgErrorStatus}">
          <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-2 py-1 px-2" role="alert" style="font-size: 0.76rem;">
            <i class="bi bi-x-octagon-fill me-1"></i><strong>Action Rejected:</strong> <c:out value="${not empty msgErrorStatus ? msgErrorStatus : sessionScope.msgErrorStatus}"/>
            <button type="button" class="btn-close py-1" data-bs-dismiss="alert" aria-label="Close"></button>
          </div>
        </c:if>

        <!-- Main Workspace Container (Top Summary divided into 2 boxes + Bottom Purchased Products Table) -->
        <div class="d-flex flex-column h-100 overflow-hidden gap-2" style="min-height: 0;">

          <!-- TOP SECTION: Order Summary (Divided into 2 Equal Cards Side-by-Side) -->
          <div class="row g-2 flex-shrink-0">
            <!-- Box 1: Customer & Receiver Details -->
            <div class="col-md-6">
              <section class="panel panel-compact bg-white h-100 mb-0 d-flex flex-column justify-content-between">
                <div>
                  <div class="d-flex align-items-center justify-content-between mb-1 border-bottom pb-1">
                    <h2 class="h6 mb-0 section-title" style="font-size: 0.78rem;">
                      <i class="bi bi-person-circle text-primary me-1.5"></i>1. Customer & Receiver Details
                    </h2>
                    <span class="badge text-bg-primary" style="font-size: 0.65rem;">#CUST-${order.customerID}</span>
                  </div>
                  <table class="table table-sm table-bordered align-middle mb-0 summary-info-table" style="font-size: 0.73rem;">
                    <tbody>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1" style="width: 36%;">
                          <i class="bi bi-person-vcard text-primary me-1"></i>Receiver Name
                        </th>
                        <td class="py-1">
                          <span class="fw-bold text-dark"><c:out value="${not empty address ? address.receiverName : (not empty customer ? customer.fullName : 'N/A')}" /></span>
                        </td>
                      </tr>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1">
                          <i class="bi bi-telephone-fill text-success me-1"></i>Phone
                        </th>
                        <td class="py-1">
                          <span class="fw-bold text-dark"><c:out value="${not empty address ? address.receiverPhone : (not empty customer ? customer.phone : 'N/A')}" /></span>
                        </td>
                      </tr>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1">
                          <i class="bi bi-envelope-fill text-info me-1"></i>Email
                        </th>
                        <td class="py-1">
                          <span class="fw-semibold text-dark"><c:out value="${not empty customer && not empty customer.email ? customer.email : 'N/A'}" /></span>
                        </td>
                      </tr>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1">
                          <i class="bi bi-geo-alt-fill text-danger me-1"></i>Delivery Address
                        </th>
                        <td class="py-1">
                          <div class="text-dark fw-semibold" style="line-height: 1.25; font-size: 0.71rem;">
                            <c:out value="${not empty address && not empty address.fullAddress ? address.fullAddress : (not empty order.shippingAddress ? order.shippingAddress : 'N/A')}" />
                          </div>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </section>
            </div>

            <!-- Box 2: Order & Shipping Details -->
            <div class="col-md-6">
              <section class="panel panel-compact bg-white h-100 mb-0 d-flex flex-column justify-content-between">
                <div>
                  <div class="d-flex align-items-center justify-content-between mb-1 border-bottom pb-1">
                    <h2 class="h6 mb-0 section-title" style="font-size: 0.78rem;">
                      <i class="bi bi-truck text-info me-1.5"></i>2. Order & Shipping Details
                    </h2>
                    <span class="badge text-bg-secondary" style="font-size: 0.65rem;">#ORD-${order.orderID}</span>
                  </div>
                  <table class="table table-sm table-bordered align-middle mb-0 summary-info-table" style="font-size: 0.73rem;">
                    <tbody>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1" style="width: 36%;">
                          <i class="bi bi-truck text-info me-1"></i>Assigned Shipper
                        </th>
                        <td class="py-1">
                          <c:choose>
                            <c:when test="${(order.orderStatus == 'SHIPPING' || order.orderStatus == 'DELIVERED') && not empty order.shippingName}">
                              <span class="fw-bold text-dark"><c:out value="${order.shippingName}" /></span>
                              <c:if test="${not empty order.shippingPhone}">
                                <small class="text-muted ms-1">(<c:out value="${order.shippingPhone}" />)</small>
                              </c:if>
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted fst-italic">Pending Assignment</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                      </tr>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1">
                          <i class="bi bi-barcode text-primary me-1"></i>Tracking Code
                        </th>
                        <td class="py-1">
                          <span class="fw-bold text-primary"><c:out value="${not empty shipment && not empty shipment.trackingNumber ? shipment.trackingNumber : 'N/A'}" /></span>
                          <c:if test="${not empty shipment && not empty shipment.shippingProvider}">
                            <small class="text-muted ms-1">(<c:out value="${shipment.shippingProvider}" />)</small>
                          </c:if>
                        </td>
                      </tr>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1">
                          <i class="bi bi-clock-history text-info me-1"></i>Order Date
                        </th>
                        <td class="py-1">
                          <span class="fw-bold text-dark"><c:out value="${order.formattedOrderDateTime}" /></span>
                        </td>
                      </tr>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1">
                          <i class="bi bi-calendar-event text-warning me-1"></i>Estimated Delivery
                        </th>
                        <td class="py-1">
                          <span class="fw-bold text-dark">
                            <c:choose>
                              <c:when test="${not empty shipment && not empty shipment.formattedEstimatedDate}">
                                <c:out value="${shipment.formattedEstimatedDate}" />
                              </c:when>
                              <c:otherwise>3-5 business days</c:otherwise>
                            </c:choose>
                          </span>
                        </td>
                      </tr>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1">
                          <i class="bi bi-calendar-check text-success me-1"></i>Actual Delivery
                        </th>
                        <td class="py-1">
                          <span class="fw-bold text-dark">
                            <c:choose>
                              <c:when test="${not empty shipment && not empty shipment.formattedDeliveredAt}">
                                <c:out value="${shipment.formattedDeliveredAt}" />
                              </c:when>
                              <c:when test="${order.orderStatus == 'DELIVERED' || order.orderStatus == 'Delivered'}">
                                <c:choose>
                                  <c:when test="${not empty order.updatedAt}">
                                    <c:out value="${order.formattedUpdatedAt}" />
                                  </c:when>
                                  <c:otherwise><c:out value="${order.formattedOrderDateTime}" /></c:otherwise>
                                </c:choose>
                              </c:when>
                              <c:otherwise>
                                <span class="text-muted fst-italic">Pending Delivery</span>
                              </c:otherwise>
                            </c:choose>
                          </span>
                        </td>
                      </tr>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1">
                          <i class="bi bi-gear-fill text-primary me-1"></i>Status & Actions
                        </th>
                        <td class="py-1">
                          <div class="d-flex align-items-center justify-content-between flex-wrap gap-1">
                            <c:choose>
                              <c:when test="${order.orderStatus == 'PENDING'}">
                                <span class="badge text-bg-warning"><i class="bi bi-clock me-1"></i>PENDING</span>
                              </c:when>
                              <c:when test="${order.orderStatus == 'CONFIRMED'}">
                                <span class="badge text-bg-info"><i class="bi bi-check-lg me-1"></i>CONFIRMED</span>
                              </c:when>
                              <c:when test="${order.orderStatus == 'SHIPPING'}">
                                <span class="badge text-bg-primary"><i class="bi bi-truck me-1"></i>SHIPPING</span>
                              </c:when>
                              <c:when test="${order.orderStatus == 'DELIVERED'}">
                                <span class="badge text-bg-success"><i class="bi bi-check-circle me-1"></i>DELIVERED</span>
                              </c:when>
                              <c:otherwise>
                                <span class="badge text-bg-danger"><i class="bi bi-x-circle me-1"></i>CANCELLED</span>
                              </c:otherwise>
                            </c:choose>

                            <div class="d-flex gap-1.5 ms-auto">
                              <c:choose>
                                <c:when test="${order.orderStatus == 'PENDING'}">
                                  <form method="post" action="${pageContext.request.contextPath}/staff/order-detail" class="m-0" onsubmit="return confirm('Confirm order #ORD-${order.orderID}?');">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="orderId" value="${order.orderID}">
                                    <input type="hidden" name="newStatus" value="CONFIRMED">
                                    <button type="submit" class="btn btn-info btn-sm text-white fw-bold px-2 py-0.5" style="font-size: 0.70rem;">
                                      <i class="bi bi-check-lg me-1"></i> Confirm
                                    </button>
                                  </form>
                                  <button type="button" class="btn btn-danger btn-sm fw-bold px-2 py-0.5" style="font-size: 0.70rem;" onclick="openCancelModal(${order.orderID})">
                                    <i class="bi bi-x-lg me-1"></i> Cancel
                                  </button>
                                </c:when>
                                <c:when test="${order.orderStatus == 'CONFIRMED'}">
                                  <c:set var="detailDeliveryAddr" value="${not empty address && not empty address.fullAddress ? address.fullAddress : (not empty order.shippingAddress ? order.shippingAddress : '')}" />
                                  <button type="button" class="btn btn-primary btn-sm fw-bold px-2 py-0.5" style="font-size: 0.70rem;" onclick="openShipModal(${order.orderID}, '${fn:escapeXml(order.shippingName)}', '${fn:escapeXml(order.shippingPhone)}', '${fn:escapeXml(detailDeliveryAddr)}')">
                                    <i class="bi bi-truck me-1"></i> Ship
                                  </button>
                                  <button type="button" class="btn btn-danger btn-sm fw-bold px-2 py-0.5" style="font-size: 0.70rem;" onclick="openCancelModal(${order.orderID})">
                                    <i class="bi bi-x-lg me-1"></i> Cancel
                                  </button>
                                </c:when>
                                <c:when test="${order.orderStatus == 'SHIPPING'}">
                                  <form method="post" action="${pageContext.request.contextPath}/staff/order-detail" class="m-0" onsubmit="return confirm('Mark order #ORD-${order.orderID} as COMPLETED?');">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="orderId" value="${order.orderID}">
                                    <input type="hidden" name="newStatus" value="DELIVERED">
                                    <button type="submit" class="btn btn-success btn-sm fw-bold px-2 py-0.5" style="font-size: 0.70rem;">
                                      <i class="bi bi-check-circle me-1"></i> Complete Order
                                    </button>
                                  </form>
                                </c:when>
                                <c:otherwise>
                                  <c:choose>
                                    <c:when test="${order.orderStatus == 'CANCELLED'}">
                                      <span class="text-danger small fw-medium" style="font-size: 0.7rem;">
                                        <i class="bi bi-x-octagon-fill me-1"></i>Cancelled <c:if test="${not empty order.cancelReason}">(<c:out value="${order.cancelReason}" />)</c:if>
                                      </span>
                                    </c:when>
                                    <c:otherwise>
                                      <span class="text-muted small" style="font-size: 0.7rem;"><i class="bi bi-lock-fill me-1"></i>Completed</span>
                                    </c:otherwise>
                                  </c:choose>
                                </c:otherwise>
                              </c:choose>
                            </div>
                          </div>
                        </td>
                      </tr>
                      <tr>
                        <th class="bg-light text-muted fw-semibold py-1">
                          <i class="bi bi-credit-card-2-front text-success me-1"></i>Payment Method
                        </th>
                        <td class="py-1">
                          <c:set var="isDetailPaid" value="${(not empty payment && (payment.paymentStatus == 'SUCCESS' || payment.paymentStatus == 'Paid' || payment.paymentStatus == 'PAID' || payment.paymentStatus == 'COMPLETED' || payment.paymentStatus == 'Completed')) || order.orderStatus == 'DELIVERED' || order.orderStatus == 'Delivered'}" />
                          <c:set var="detailPayMethod" value="${not empty payment && not empty payment.paymentMethod ? payment.paymentMethod : 'COD'}" />
                          
                          <span class="badge ${detailPayMethod == 'VNPAY' ? 'text-bg-primary' : (detailPayMethod == 'BANK_TRANSFER' || detailPayMethod == 'Banking' ? 'text-bg-info text-white' : 'text-bg-secondary')}" style="font-size: 0.65rem;">
                            <i class="bi ${detailPayMethod == 'VNPAY' ? 'bi-qr-code-scan' : (detailPayMethod == 'BANK_TRANSFER' || detailPayMethod == 'Banking' ? 'bi-bank' : 'bi-cash-stack')} me-1"></i><c:out value="${detailPayMethod}" />
                          </span>
                          <span class="badge ${isDetailPaid ? 'text-bg-success' : 'text-bg-warning'} ms-1" style="font-size: 0.65rem;">
                            <i class="bi ${isDetailPaid ? 'bi-check-circle-fill' : 'bi-clock-history'} me-1"></i><c:out value="${isDetailPaid ? 'PAID' : 'UNPAID'}" />
                          </span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </section>
            </div>
          </div>

          <!-- BOTTOM SECTION: Purchased Products & Price Details -->
          <section class="panel panel-compact bg-white d-flex flex-column flex-grow-1 overflow-hidden mb-0">
            <div class="d-flex align-items-center justify-content-between mb-1 border-bottom pb-1">
              <h2 class="h6 mb-0 section-title" style="font-size: 0.82rem;">
                <i class="bi bi-bag-check me-1.5 text-primary"></i>Purchased Products & Pricing Details (${items.size()})
              </h2>
              <span class="badge text-bg-light border text-secondary" style="font-size: 0.7rem;">Order Total: <fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/> VND</span>
            </div>

            <div class="items-table-wrapper flex-grow-1">
              <table class="table align-middle mb-0 invoice-table" style="font-size: 0.76rem;">
                <thead class="sticky-top bg-light">
                  <tr class="table-light">
                    <th class="text-center py-1.5" style="width: 45px;">#</th>
                    <th class="py-1.5">Headphone Product Name</th>
                    <th class="text-end py-1.5" style="width: 140px;">Unit Price</th>
                    <th class="text-center py-1.5" style="width: 80px;">Qty</th>
                    <th class="text-end py-1.5" style="width: 160px;">Subtotal</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="item" items="${items}" varStatus="loop">
                    <tr>
                      <td class="text-center text-muted fw-bold py-1.5">${loop.index + 1}</td>
                      <td class="py-1.5">
                        <div class="fw-bold text-dark" style="line-height: 1.2; font-size: 0.78rem;"><c:out value="${item.productName}" /></div>
                        <small class="text-muted" style="font-size: 0.68rem;">Product ID: #${item.productID}</small>
                      </td>
                      <td class="text-end py-1.5 fw-semibold"><fmt:formatNumber value="${item.unitPrice}" pattern="#,###"/> VND</td>
                      <td class="text-center fw-bold py-1.5">x${item.quantity}</td>
                      <td class="text-end fw-bold price-badge py-1.5 fs-7"><fmt:formatNumber value="${item.subtotal}" pattern="#,###"/> VND</td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty items}">
                    <tr>
                      <td colspan="5" class="text-center py-3 text-muted">No items recorded for this order.</td>
                    </tr>
                  </c:if>
                </tbody>
              </table>
            </div>

            <!-- Compact Total Footer Bar -->
            <div class="pt-1.5 mt-1 border-top bg-light rounded px-3 py-1.5 d-flex align-items-center justify-content-between" style="font-size: 0.78rem;">
              <div><span class="text-muted me-1">Shipping Fee:</span><strong class="text-success">FREE</strong></div>
              <div>
                <span class="fw-bold me-1">GRAND TOTAL:</span>
                <strong class="text-primary fs-6"><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/> VND</strong>
              </div>
            </div>
          </section>

          <!-- AI 512-VECTOR RECOMMENDATION & CROSS-SELL SECTION -->
          <section class="panel panel-compact bg-white flex-shrink-0 mb-1" style="border-left: 4px solid #6366f1; background: linear-gradient(180deg, #faf5ff 0%, #ffffff 100%);">
            <div class="d-flex align-items-center justify-content-between mb-1.5 border-bottom pb-1">
              <div class="d-flex align-items-center gap-1.5">
                <span class="badge" style="background: linear-gradient(135deg, #6366f1, #8b5cf6); color: white; font-size: 0.68rem;">
                  <i class="bi bi-stars me-1"></i>AI 512 Vector
                </span>
                <h2 class="h6 mb-0 section-title fw-bold text-dark" style="font-size: 0.8rem;">
                  Smart Cross-Sell & Upsell Recommendations
                </h2>
                <small class="text-muted d-none d-md-inline" style="font-size: 0.68rem;">(Cosine Similarity on 512-D Semantic Embeddings)</small>
              </div>
              <span class="badge text-bg-light border text-primary" style="font-size: 0.65rem;">
                <i class="bi bi-cpu-fill text-primary me-1"></i>Model: CLIP-ViT-B-32
              </span>
            </div>

            <!-- List of AI Recommended Products -->
            <c:choose>
              <c:when test="${not empty aiRecommendations}">
                <div class="row g-2">
                  <c:forEach var="rec" items="${aiRecommendations}">
                    <div class="col-md-4">
                      <div class="p-2 border rounded bg-white h-100 shadow-sm d-flex flex-column justify-content-between" style="font-size: 0.72rem; transition: transform 0.2s;">
                        <div class="d-flex gap-2 align-items-start">
                          <img src="${not empty rec.imageUrl ? rec.imageUrl : 'https://placehold.co/100x100?text=Headphone'}" 
                               alt="${rec.productName}" 
                               class="rounded border p-1 bg-light flex-shrink-0" 
                               style="width: 50px; height: 50px; object-fit: contain;">
                          <div class="flex-grow-1 overflow-hidden">
                            <div class="d-flex align-items-center justify-content-between mb-0.5">
                              <span class="badge text-bg-success" style="font-size: 0.62rem;">
                                <i class="bi bi-bullseye me-1"></i>${rec.similarityPercent}% Match
                              </span>
                              <span class="badge text-bg-light text-secondary border" style="font-size: 0.6rem;">
                                <c:out value="${rec.recommendationType}" />
                              </span>
                            </div>
                            <div class="fw-bold text-dark text-truncate" title="${rec.productName}" style="font-size: 0.75rem;">
                              <c:out value="${rec.productName}" />
                            </div>
                            <div class="text-primary fw-bold" style="font-size: 0.74rem;">
                              <fmt:formatNumber value="${rec.price}" pattern="#,###"/> VND
                            </div>
                          </div>
                        </div>

                        <div class="mt-1 pt-1 border-top text-muted" style="font-size: 0.66rem; line-height: 1.25;">
                          <i class="bi bi-lightbulb-fill text-warning me-1"></i>
                          <span><c:out value="${rec.reason}" /></span>
                        </div>
                      </div>
                    </div>
                  </c:forEach>
                </div>
              </c:when>
              <c:otherwise>
                <div class="text-center py-2 text-muted" style="font-size: 0.72rem;">
                  <i class="bi bi-info-circle me-1"></i>No recommendations generated yet. Run AI analysis to compute 512-D embeddings.
                </div>
              </c:otherwise>
            </c:choose>
          </section>

        </div>
      </main>
    </div>
  </div>

  <!-- CANCEL REASON MODAL -->
  <div class="modal fade" id="cancelOrderModal" tabindex="-1" aria-labelledby="cancelOrderModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content shadow-lg border-0">
        <form method="post" action="${pageContext.request.contextPath}/staff/order-detail" id="cancelOrderForm" onsubmit="return validateCancelModal();">
          <input type="hidden" name="action" value="updateStatus">
          <input type="hidden" name="newStatus" value="CANCELLED">
          <input type="hidden" name="orderId" id="modalOrderId" value="${order.orderID}">

          <div class="modal-header bg-danger text-white py-2">
            <h6 class="modal-title fw-bold" id="cancelOrderModalLabel">
              <i class="bi bi-x-circle me-1"></i>Cancel Order <span id="modalOrderDisplayId">#ORD-${order.orderID}</span>
            </h6>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>

          <div class="modal-body py-2">
            <p class="text-secondary small mb-2" style="font-size: 0.78rem;">Please specify the reason for cancelling this order.</p>
            
            <div class="mb-2">
              <label class="form-label fw-semibold fs-7 mb-1">Select Standard Reason:</label>
              <select class="form-select form-select-sm" id="modalPresetReason" onchange="onPresetReasonChange()">
                <option value="">-- Choose a standard reason --</option>
                <option value="Customer requested order cancellation">Customer requested order cancellation</option>
                <option value="Out of stock / Product currently unavailable">Out of stock / Product currently unavailable</option>
                <option value="Invalid shipping address or contact phone">Invalid shipping address or contact phone</option>
                <option value="Unable to contact customer after multiple attempts">Unable to contact customer after multiple attempts</option>
                <option value="OTHER">Other reason (Type below)...</option>
              </select>
            </div>

            <div class="mb-1">
              <label class="form-label fw-semibold fs-7 mb-1">
                Detailed Reason / Note: <span id="reasonAsterisk" class="text-danger d-none">*</span>
              </label>
              <textarea class="form-control form-control-sm" name="cancelReason" id="modalCancelReason" rows="2" maxlength="500" placeholder="Enter detailed reason..."></textarea>
            </div>
          </div>

          <div class="modal-footer bg-light py-1.5">
            <button type="button" class="btn btn-outline-secondary btn-sm py-0.5" data-bs-dismiss="modal">Close</button>
            <button type="submit" class="btn btn-danger btn-sm px-3 fw-bold py-0.5">
              <i class="bi bi-x-lg me-1"></i> Confirm Cancellation
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- SHIPPING INFORMATION MODAL (FEATURE 2) -->
  <div class="modal fade" id="shipOrderModal" tabindex="-1" aria-labelledby="shipOrderModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content shadow border-0">
        <form method="post" action="${pageContext.request.contextPath}/staff/order-detail">
          <input type="hidden" name="action" value="updateStatus">
          <input type="hidden" name="orderId" id="shipModalOrderId">
          <input type="hidden" name="newStatus" value="SHIPPING">

          <div class="modal-header bg-primary text-white py-2">
            <h5 class="modal-title h6 fw-bold mb-0" id="shipOrderModalLabel">
              <i class="bi bi-truck me-1.5"></i>Start Shipping Order <span id="shipModalOrderDisplayId" class="badge text-bg-light text-primary ms-1">#ORD-0</span>
            </h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>

          <div class="modal-body p-3">
            <p class="text-muted fs-7 mb-3">Please select the shipping courier, enter shipper details, and tracking code for this delivery.</p>

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
              <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-building text-primary me-1"></i>Courier / Shipping Carrier:</label>
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

          <div class="modal-footer bg-light py-1.5">
            <button type="button" class="btn btn-outline-secondary btn-sm py-0.5" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-primary btn-sm px-3 fw-bold py-0.5">
              <i class="bi bi-truck me-1"></i> Confirm & Start Shipping
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Bootstrap 5 JS Bundle -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    // Smart Shipping Courier & Tracking Number Helpers
    function autoDetectShippingProvider(address) {
      if (!address) return 'Giao Hàng Nhanh (GHN)';
      var addr = address.toLowerCase();
      if (addr.indexOf('hà nội') !== -1 || addr.indexOf('ha noi') !== -1 ||
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

      var modalEl = new bootstrap.Modal(document.getElementById('shipOrderModal'));
      modalEl.show();
    }

    function openCancelModal(orderId) {
      document.getElementById('modalOrderId').value = orderId;
      document.getElementById('modalOrderDisplayId').innerText = '#ORD-' + orderId;
      document.getElementById('modalPresetReason').value = '';
      document.getElementById('modalCancelReason').value = '';
      document.getElementById('reasonAsterisk').classList.add('d-none');
      var modalEl = new bootstrap.Modal(document.getElementById('cancelOrderModal'));
      modalEl.show();
    }

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

    function validateCancelModal() {
      var reason = document.getElementById('modalCancelReason').value.trim();
      if (!reason) {
        alert('Please enter or select a reason for cancelling the order!');
        return false;
      }
      return true;
    }

    // Theme Toggle
    var themeToggleBtn = document.getElementById('themeToggleBtn');
    var themeIcon = document.getElementById('themeIcon');
    var htmlTag = document.documentElement;

    if (themeToggleBtn) {
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
    }
  </script>
</body>
</html>
