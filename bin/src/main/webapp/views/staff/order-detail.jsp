<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    .order-stepper {
      display: flex;
      justify-content: space-between;
      align-items: center;
      position: relative;
      margin: 0.6rem 0;
    }
    .order-stepper::before {
      content: "";
      position: absolute;
      top: 50%;
      left: 10%;
      right: 10%;
      height: 3px;
      background: var(--admin-border);
      z-index: 1;
      transform: translateY(-50%);
    }
    .stepper-step {
      position: relative;
      z-index: 2;
      background: var(--admin-surface);
      border: 2px solid var(--admin-border);
      border-radius: 50%;
      width: 36px;
      height: 36px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 0.95rem;
      color: var(--admin-muted);
      transition: all 0.2s ease;
    }
    .stepper-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 0.2rem;
      z-index: 2;
    }
    .stepper-label {
      font-size: 0.72rem;
      font-weight: 700;
      color: var(--admin-muted);
      text-transform: uppercase;
    }
    .stepper-item.completed .stepper-step {
      background: var(--admin-primary);
      border-color: var(--admin-primary);
      color: #fff;
    }
    .stepper-item.completed .stepper-label {
      color: var(--admin-primary);
    }
    .stepper-item.active .stepper-step {
      background: var(--admin-warning);
      border-color: var(--admin-warning);
      color: #fff;
      box-shadow: 0 0 0 3px rgba(217, 119, 6, 0.2);
    }
    .stepper-item.active .stepper-label {
      color: var(--admin-warning);
    }
    .stepper-item.delivered.completed .stepper-step {
      background: #0f766e;
      border-color: #0f766e;
    }
    .stepper-item.cancelled .stepper-step {
      background: #dc2626;
      border-color: #dc2626;
      color: #fff;
    }
    .stepper-item.cancelled .stepper-label {
      color: #dc2626;
    }
    .panel-compact {
      padding: 0.65rem 0.85rem !important;
      margin-bottom: 0.65rem !important;
    }
    .invoice-table td, .invoice-table th {
      padding: 0.35rem 0.6rem !important;
      font-size: 0.78rem !important;
    }
    @media print {
      .admin-sidebar, .navbar, .heading-actions, .status-actions-card, .btn, .breadcrumb, .theme-toggle, .order-stepper-panel {
        display: none !important;
      }
      .admin-main {
        margin-left: 0 !important;
        padding: 0 !important;
      }
      .panel {
        box-shadow: none !important;
        border: 1px solid #ddd !important;
        margin-bottom: 0.6rem !important;
      }
      .dashboard-content {
        padding: 0 !important;
      }
      .d-print-block {
        display: block !important;
      }
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

      <!-- DASHBOARD CONTENT -->
      <main class="dashboard-content">
        <div class="container-fluid px-2 px-md-3 py-2">

          <!-- Print Only Official Invoice Header -->
          <div class="print-only-header d-none d-print-block mb-3 border-bottom pb-3">
            <div class="d-flex justify-content-between align-items-center">
              <div>
                <h3 class="fw-bold mb-0 text-dark" style="letter-spacing: -0.5px;">HEADPHONE STORE</h3>
                <p class="text-muted small mb-0">Official Sales & Order Invoice Receipt</p>
                <small class="text-muted">Hotline: 1900-8888 | Website: headphone.store.vn</small>
              </div>
              <div class="text-end">
                <h4 class="fw-bold text-primary mb-0">INVOICE #ORD-${order.orderID}</h4>
                <div class="small fw-semibold text-secondary">Date: ${order.formattedOrderDate}</div>
                <span class="badge text-bg-secondary mt-1">Status: ${order.orderStatus}</span>
              </div>
            </div>
          </div>

          <!-- Breadcrumb -->
          <nav aria-label="breadcrumb" class="mb-2">
            <ol class="breadcrumb fs-7 mb-0">
              <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/staff/orders">Manager Portal</a></li>
              <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/staff/orders">Orders</a></li>
              <li class="breadcrumb-item active" aria-current="page">#ORD-${order.orderID}</li>
            </ol>
          </nav>

          <!-- Page Heading -->
          <div class="page-heading d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
            <div class="page-heading-copy d-flex align-items-center gap-2">
              <span class="page-icon" style="width: 38px; height: 38px; font-size: 1.1rem;"><i class="bi bi-receipt"></i></span>
              <div>
                <p class="eyebrow mb-0" style="font-size: 0.72rem;">Order Details</p>
                <h1 class="h4 mb-0 fw-bold">Order #ORD-${order.orderID}</h1>
              </div>
            </div>
            <div class="heading-actions d-flex gap-2">
              <a href="${pageContext.request.contextPath}/staff/orders" class="btn btn-outline-secondary btn-sm px-3 shadow-sm">
                <i class="bi bi-arrow-left me-1"></i> Back to Orders
              </a>
              <button onclick="window.print();" class="btn btn-primary btn-sm px-3 shadow-sm">
                <i class="bi bi-printer me-1"></i> Print Invoice
              </button>
            </div>
          </div>

          <!-- Alert Notifications -->
          <c:if test="${not empty sessionScope.msgSuccess}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-3 py-2" role="alert">
              <i class="bi bi-check-circle-fill me-2"></i><strong>Success!</strong> Order <strong>#ORD-${sessionScope.msgSuccessOrderId}</strong> updated to: <strong>${sessionScope.msgSuccessStatus}</strong>
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% 
              session.removeAttribute("msgSuccess"); 
              session.removeAttribute("msgSuccessOrderId"); 
              session.removeAttribute("msgSuccessStatus"); 
            %>
          </c:if>

          <c:if test="${not empty sessionScope.msgErrorStatus}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-3 py-2" role="alert">
              <i class="bi bi-x-octagon-fill me-2"></i><strong>Action Rejected:</strong> ${sessionScope.msgErrorStatus}
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% session.removeAttribute("msgErrorStatus"); %>
          </c:if>

          <!-- Order Status Timeline Stepper -->
          <section class="panel panel-compact order-stepper-panel mb-3">
            <h2 class="h6 mb-2 section-title" style="font-size: 0.88rem;"><i class="bi bi-diagram-3 me-2"></i>Order Processing Timeline</h2>
            
            <c:choose>
              <c:when test="${order.orderStatus == 'CANCELLED'}">
                <div class="p-3 bg-danger-subtle rounded-3 border border-danger text-center">
                  <div class="badge text-bg-danger fs-6 px-3 py-1.5 mb-1">
                    <i class="bi bi-x-circle-fill me-2"></i>THIS ORDER HAS BEEN CANCELLED
                  </div>
                  <div class="mt-2 text-danger-emphasis" style="font-size: 0.85rem;">
                    <i class="bi bi-exclamation-triangle-fill me-1"></i><strong>Cancellation Reason:</strong>
                    <span class="fw-semibold text-dark bg-white px-2 py-1 rounded border ms-1"><c:out value="${not empty order.cancelReason ? order.cancelReason : 'No specific reason logged in system'}" /></span>
                  </div>
                </div>
              </c:when>
              <c:otherwise>
                <div class="order-stepper">
                  <div class="stepper-item ${order.orderStatus == 'PENDING' ? 'active' : 'completed'}">
                    <div class="stepper-step"><i class="bi bi-clock-history"></i></div>
                    <span class="stepper-label">Pending</span>
                  </div>

                  <div class="stepper-item ${order.orderStatus == 'CONFIRMED' ? 'active' : (order.orderStatus == 'SHIPPING' || order.orderStatus == 'DELIVERED' ? 'completed' : '')}">
                    <div class="stepper-step"><i class="bi bi-check2-square"></i></div>
                    <span class="stepper-label">Confirmed</span>
                  </div>

                  <div class="stepper-item ${order.orderStatus == 'SHIPPING' ? 'active' : (order.orderStatus == 'DELIVERED' ? 'completed' : '')}">
                    <div class="stepper-step"><i class="bi bi-truck"></i></div>
                    <span class="stepper-label">Shipping</span>
                  </div>

                  <div class="stepper-item delivered ${order.orderStatus == 'DELIVERED' ? 'completed' : ''}">
                    <div class="stepper-step"><i class="bi bi-check-circle-fill"></i></div>
                    <span class="stepper-label">Delivered</span>
                  </div>
                </div>
              </c:otherwise>
            </c:choose>
          </section>

          <div class="row g-3">
            <!-- Left Column: Items & Actions -->
            <div class="col-lg-8">
              <!-- Purchased Items Card -->
              <section class="panel panel-compact mb-3">
                <div class="panel-header mb-2">
                  <h2 class="h6 mb-0 section-title" style="font-size: 0.88rem;"><i class="bi bi-bag-check me-2"></i>Purchased Items (${items.size()})</h2>
                </div>

                <div class="table-responsive">
                  <table class="table align-middle mb-0 invoice-table" style="font-size: 0.78rem;">
                    <thead>
                      <tr class="table-light">
                        <th class="text-center py-2" style="width: 40px;">#</th>
                        <th class="py-2">Product Name</th>
                        <th class="text-end py-2" style="width: 110px;">Unit Price</th>
                        <th class="text-center py-2" style="width: 60px;">Qty</th>
                        <th class="text-end py-2" style="width: 130px;">Subtotal</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="item" items="${items}" varStatus="loop">
                        <tr>
                          <td class="text-center text-muted fw-bold py-2">${loop.index + 1}</td>
                          <td class="py-2">
                            <div class="fw-bold text-dark"><c:out value="${item.productName}" /></div>
                            <small class="text-muted" style="font-size: 0.72rem;">Product ID: #${item.productID}</small>
                          </td>
                          <td class="text-end py-2">${item.formattedUnitPrice} VND</td>
                          <td class="text-center fw-bold py-2">x${item.quantity}</td>
                          <td class="text-end fw-bold price-badge py-2">${item.formattedSubtotal} VND</td>
                        </tr>
                      </c:forEach>
                      <c:if test="${empty items}">
                        <tr>
                          <td colspan="5" class="text-center py-3 text-muted">No items recorded for this order.</td>
                        </tr>
                      </c:if>
                    </tbody>
                    <tfoot class="border-top" style="font-size: 0.82rem;">
                      <tr>
                        <td colspan="4" class="text-end fw-semibold py-1">Subtotal:</td>
                        <td class="text-end fw-bold py-1">${order.formattedTotalAmount} VND</td>
                      </tr>
                      <tr>
                        <td colspan="4" class="text-end fw-semibold py-1">Shipping Fee:</td>
                        <td class="text-end text-success fw-bold py-1">FREE</td>
                      </tr>
                      <tr class="table-light">
                        <td colspan="4" class="text-end fw-bold py-2">Grand Total:</td>
                        <td class="text-end fw-bold text-primary py-2" style="font-size: 0.95rem;">${order.formattedTotalAmount} VND</td>
                      </tr>
                    </tfoot>
                  </table>
                </div>
              </section>

              <!-- Status Action Processing Panel -->
              <section class="panel panel-compact status-actions-card">
                <div class="panel-header mb-2">
                  <h2 class="h6 mb-0 section-title" style="font-size: 0.88rem;"><i class="bi bi-gear-wide-connected me-2"></i>Status Processing & Actions</h2>
                </div>

                <div class="p-2.5 rounded-3 bg-light border p-2">
                  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <div class="d-flex align-items-center gap-2">
                      <span class="text-muted small">Current Status:</span>
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
                    </div>

                    <div class="d-flex gap-2">
                      <c:choose>
                        <c:when test="${order.orderStatus == 'PENDING'}">
                          <form method="post" action="${pageContext.request.contextPath}/staff/order-detail" class="m-0" onsubmit="return confirm('Are you sure you want to CONFIRM order #ORD-${order.orderID}?');">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="orderId" value="${order.orderID}">
                            <input type="hidden" name="newStatus" value="CONFIRMED">
                            <button type="submit" class="btn btn-info btn-sm text-white fw-bold px-3">
                              <i class="bi bi-check-lg me-1"></i> Confirm Order
                            </button>
                          </form>
                          <button type="button" class="btn btn-danger btn-sm fw-bold px-3" onclick="openCancelModal(${order.orderID})">
                            <i class="bi bi-x-lg me-1"></i> Cancel Order
                          </button>
                        </c:when>
                        <c:when test="${order.orderStatus == 'CONFIRMED'}">
                          <form method="post" action="${pageContext.request.contextPath}/staff/order-detail" class="m-0" onsubmit="return confirm('Are you sure you want to start SHIPPING order #ORD-${order.orderID}?');">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="orderId" value="${order.orderID}">
                            <input type="hidden" name="newStatus" value="SHIPPING">
                            <button type="submit" class="btn btn-primary btn-sm fw-bold px-3">
                              <i class="bi bi-truck me-1"></i> Start Shipping
                            </button>
                          </form>
                          <button type="button" class="btn btn-danger btn-sm fw-bold px-3" onclick="openCancelModal(${order.orderID})">
                            <i class="bi bi-x-lg me-1"></i> Cancel Order
                          </button>
                        </c:when>
                        <c:when test="${order.orderStatus == 'SHIPPING'}">
                          <form method="post" action="${pageContext.request.contextPath}/staff/order-detail" class="m-0" onsubmit="return confirm('Are you sure you want to mark order #ORD-${order.orderID} as COMPLETED?');">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="orderId" value="${order.orderID}">
                            <input type="hidden" name="newStatus" value="DELIVERED">
                            <button type="submit" class="btn btn-success btn-sm fw-bold px-3">
                              <i class="bi bi-check-circle me-1"></i> Complete Order
                            </button>
                          </form>
                        </c:when>
                        <c:otherwise>
                          <c:choose>
                            <c:when test="${order.orderStatus == 'CANCELLED'}">
                              <span class="text-danger small align-self-center fw-medium">
                                <i class="bi bi-x-octagon-fill me-1"></i>Cancelled Reason: <c:out value="${not empty order.cancelReason ? order.cancelReason : 'No reason recorded'}" />
                              </span>
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted small align-self-center"><i class="bi bi-lock-fill me-1"></i>No further actions permitted</span>
                            </c:otherwise>
                          </c:choose>
                        </c:otherwise>
                      </c:choose>
                    </div>
                  </div>
                </div>
              </section>
            </div>

            <!-- Right Column: Customer & Delivery Info -->
            <div class="col-lg-4">
              <!-- Customer Info Card -->
              <section class="panel panel-compact mb-3">
                <h2 class="h6 mb-2 section-title" style="font-size: 0.88rem;"><i class="bi bi-person me-2"></i>Customer Information</h2>
                <div class="d-flex align-items-center gap-2 mb-2">
                  <div class="rounded-circle bg-light p-2 text-primary fs-5">
                    <i class="bi bi-person-fill"></i>
                  </div>
                  <div>
                    <div class="fw-bold" style="font-size: 0.85rem;">
                      <c:out value="${not empty order.shippingName ? order.shippingName : 'N/A'}" />
                    </div>
                    <small class="text-muted d-block" style="font-size: 0.72rem;">Customer ID: #CUST-${order.customerID}</small>
                  </div>
                </div>
                <div class="border-top pt-2">
                  <div>
                    <small class="text-muted me-2"><i class="bi bi-telephone me-1"></i>Phone:</small>
                    <span class="fw-bold" style="font-size: 0.82rem;">
                      <c:out value="${not empty order.shippingPhone ? order.shippingPhone : 'N/A'}" />
                    </span>
                  </div>
                </div>
              </section>

              <!-- Shipping Address Card -->
              <section class="panel panel-compact mb-3">
                <h2 class="h6 mb-2 section-title" style="font-size: 0.88rem;"><i class="bi bi-geo-alt me-2"></i>Shipping Address</h2>
                <div class="p-2 bg-light rounded border" style="font-size: 0.8rem; line-height: 1.3;">
                  <i class="bi bi-geo-alt-fill text-danger me-1"></i>
                  <span class="fw-semibold">
                    <c:out value="${not empty order.shippingAddress ? order.shippingAddress : 'N/A'}" />
                  </span>
                </div>
              </section>

              <!-- Timeline Meta Card -->
              <section class="panel panel-compact">
                <h2 class="h6 mb-2 section-title" style="font-size: 0.88rem;"><i class="bi bi-clock-history me-2"></i>Order Metadata</h2>
                <ul class="list-group list-group-flush" style="font-size: 0.8rem;">
                  <li class="list-group-item px-0 py-1.5 d-flex justify-content-between align-items-center">
                    <span class="text-muted">Order Date:</span>
                    <span class="fw-bold text-nowrap">${order.formattedOrderDate}</span>
                  </li>
                  <li class="list-group-item px-0 py-1.5 d-flex justify-content-between align-items-center">
                    <span class="text-muted">Last Updated:</span>
                    <span class="fw-bold text-nowrap">${order.formattedUpdatedAt}</span>
                  </li>
                </ul>
              </section>
            </div>
          </div>

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

          <div class="modal-header bg-danger text-white">
            <h5 class="modal-title fw-bold" id="cancelOrderModalLabel">
              <i class="bi bi-x-circle me-2"></i>Cancel Order <span id="modalOrderDisplayId">#ORD-${order.orderID}</span>
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
              <textarea class="form-control" name="cancelReason" id="modalCancelReason" rows="3" maxlength="500" placeholder="Enter detailed reason for cancellation..."></textarea>
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

  <script>
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
