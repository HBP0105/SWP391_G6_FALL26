<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.time.LocalDate" %>

<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Revenue Overview Report | Admin Dashboard</title>

  <!-- Bootstrap 5 CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- Chart.js -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <!-- adminHMD Custom Style -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminhmd-style.css">

  <style>
    .revenue-card-icon {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.5rem;
    }
    .bg-revenue-primary { background: rgba(37, 99, 235, 0.12); color: #2563eb; }
    .bg-revenue-success { background: rgba(5, 150, 105, 0.12); color: #059669; }
    .bg-revenue-warning { background: rgba(217, 119, 6, 0.12); color: #d97706; }
    .bg-revenue-purple { background: rgba(147, 51, 234, 0.12); color: #9333ea; }
    .chart-container {
      position: relative;
      height: 320px;
      width: 100%;
    }
    .progress-bar-custom {
      height: 8px;
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
          <span class="brand-icon"><i class="bi bi-shield-lock-fill"></i></span>
          <span class="brand-copy">
            <span class="brand-title">Admin Portal</span>
            <span class="brand-subtitle">Headphone Analytics</span>
          </span>
        </a>
      </div>

      <nav class="sidebar-nav">
        <a class="nav-link active" href="${pageContext.request.contextPath}/admin/revenue-report">
          <span class="nav-icon"><i class="bi bi-graph-up-arrow"></i></span>
          <span class="nav-text">Revenue Report</span>
        </a>
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/ai-performance">
          <span class="nav-icon"><i class="bi bi-robot"></i></span>
          <span class="nav-text">AI Performance & Config</span>
        </a>
        <a class="nav-link" href="${pageContext.request.contextPath}/staff/orders">
          <span class="nav-icon"><i class="bi bi-table"></i></span>
          <span class="nav-text">Order Management</span>
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
      <nav class="navbar admin-navbar navbar-expand bg-white border-bottom shadow-sm">
        <div class="container-fluid px-3">
          <span class="navbar-text fw-bold text-dark fs-6">
            <i class="bi bi-bar-chart-line-fill text-primary me-2"></i>Executive Revenue Dashboard
          </span>
          <div class="navbar-actions ms-auto d-flex align-items-center gap-2">
            <button class="icon-button theme-toggle" id="themeToggleBtn" type="button" title="Switch Light/Dark Theme">
              <i class="bi bi-moon-stars" id="themeIcon"></i>
            </button>
            <div class="dropdown">
              <button class="profile-button dropdown-toggle border-0 bg-transparent" type="button" data-bs-toggle="dropdown">
                <i class="bi bi-person-badge-fill text-primary fs-5 me-1"></i>
                <span class="profile-name d-none d-sm-inline fw-semibold">Administrator</span>
              </button>
              <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/home"><i class="bi bi-box-arrow-right me-2"></i>Exit to Store</a></li>
              </ul>
            </div>
          </div>
        </div>
      </nav>

      <!-- DASHBOARD CONTENT -->
      <main class="dashboard-content overflow-auto py-3">
        <div class="container-fluid px-3">
          
          <!-- Page Heading -->
          <div class="page-heading d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <div>
              <p class="eyebrow mb-1 text-uppercase text-primary fw-bold fs-7">Financial Intelligence</p>
              <h1 class="h3 mb-0 fw-bold">Overview Revenue Report</h1>
              <p class="text-muted small mb-0">Analyze sales revenue, order completion metrics, top products and category performance.</p>
            </div>
            <div class="heading-actions d-flex gap-2">
              <button onclick="exportRevenueCSV();" class="btn btn-success btn-sm px-3 shadow-sm">
                <i class="bi bi-file-earmark-excel me-1"></i> Export Excel (CSV)
              </button>
            </div>
          </div>

          <!-- Alert Notification Error Validation -->
          <c:if test="${not empty msgError}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-3" role="alert">
              <i class="bi bi-exclamation-triangle-fill me-2"></i><strong>Validation Error:</strong> <c:out value="${msgError}"/>
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
          </c:if>

          <!-- 4 Stat Metric Cards -->
          <div class="row g-3 mb-4">
            <div class="col-12 col-sm-6 col-xl-3">
              <div class="card border-0 shadow-sm h-100 p-3">
                <div class="d-flex align-items-center justify-content-between">
                  <div>
                    <span class="text-muted small fw-semibold text-uppercase">Total Revenue</span>
                    <h3 class="fw-bold text-primary my-1">
                      <fmt:formatNumber value="${summary.totalRevenue}" type="number" groupingUsed="true"/> <small class="fs-6">VND</small>
                    </h3>
                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill">
                      <i class="bi bi-check-circle me-1"></i>Delivered Orders
                    </span>
                  </div>
                  <div class="revenue-card-icon bg-revenue-primary">
                    <i class="bi bi-currency-dollar"></i>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-12 col-sm-6 col-xl-3">
              <div class="card border-0 shadow-sm h-100 p-3">
                <div class="d-flex align-items-center justify-content-between">
                  <div>
                    <span class="text-muted small fw-semibold text-uppercase">Successful Orders</span>
                    <h3 class="fw-bold text-success my-1">
                      ${summary.deliveredOrders} <span class="fs-6 text-muted">/ ${summary.totalOrders}</span>
                    </h3>
                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle rounded-pill">
                      <i class="bi bi-x-circle me-1"></i>${summary.cancelledOrders} Cancelled
                    </span>
                  </div>
                  <div class="revenue-card-icon bg-revenue-success">
                    <i class="bi bi-bag-check-fill"></i>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-12 col-sm-6 col-xl-3">
              <div class="card border-0 shadow-sm h-100 p-3">
                <div class="d-flex align-items-center justify-content-between">
                  <div>
                    <span class="text-muted small fw-semibold text-uppercase">Avg Order Value (AOV)</span>
                    <h3 class="fw-bold text-warning my-1">
                      <fmt:formatNumber value="${summary.avgOrderValue}" type="number" groupingUsed="true"/> <small class="fs-6">VND</small>
                    </h3>
                    <span class="text-muted small">Per successful transaction</span>
                  </div>
                  <div class="revenue-card-icon bg-revenue-warning">
                    <i class="bi bi-receipt"></i>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-12 col-sm-6 col-xl-3">
              <div class="card border-0 shadow-sm h-100 p-3">
                <div class="d-flex align-items-center justify-content-between">
                  <div>
                    <span class="text-muted small fw-semibold text-uppercase">Completion Rate</span>
                    <h3 class="fw-bold text-purple my-1">
                      ${summary.completionRate}%
                    </h3>
                    <div class="progress progress-bar-custom mt-2" style="width: 120px;">
                      <div class="progress-bar bg-purple" role="progressbar" style="width: ${summary.completionRate}%;" aria-valuenow="${summary.completionRate}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                  </div>
                  <div class="revenue-card-icon bg-revenue-purple">
                    <i class="bi bi-graph-up"></i>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Filter Panel -->
          <section class="card border-0 shadow-sm p-3 mb-4">
            <form method="get" action="${pageContext.request.contextPath}/admin/revenue-report" id="filterForm">
              <div class="row g-3 align-items-end">
                <div class="col-md-3">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-calendar-event me-1"></i>From Date:</label>
                  <input type="date" name="startDate" id="startDate" value="<c:out value='${selectedStartDate}'/>" max="<%= LocalDate.now() %>" class="form-control form-control-sm">
                </div>
                <div class="col-md-3">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-calendar-check me-1"></i>To Date:</label>
                  <input type="date" name="endDate" id="endDate" value="<c:out value='${selectedEndDate}'/>" max="<%= LocalDate.now() %>" class="form-control form-control-sm">
                </div>
                <div class="col-md-3">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-pie-chart me-1"></i>Group By:</label>
                  <select name="groupBy" class="form-select form-select-sm">
                    <option value="daily" ${selectedGroupBy == 'daily' ? 'selected' : ''}>Daily (Theo Ngày)</option>
                    <option value="monthly" ${selectedGroupBy == 'monthly' ? 'selected' : ''}>Monthly (Theo Tháng)</option>
                  </select>
                </div>
                <div class="col-md-3 d-flex gap-2">
                  <button type="submit" class="btn btn-primary btn-sm flex-fill">
                    <i class="bi bi-funnel-fill me-1"></i> Filter Report
                  </button>
                  <a href="${pageContext.request.contextPath}/admin/revenue-report" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-counterclockwise"></i> Reset
                  </a>
                </div>
              </div>
            </form>
          </section>

          <!-- Charts Section -->
          <div class="row g-3 mb-4">
            <!-- Revenue Trend Chart -->
            <div class="col-12 col-lg-8">
              <div class="card border-0 shadow-sm p-3 h-100">
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <h2 class="h6 fw-bold mb-0 text-dark"><i class="bi bi-graph-up-arrow text-primary me-2"></i>Revenue Over Time Trend</h2>
                  <span class="badge bg-light text-dark border"><c:out value="${selectedGroupBy == 'monthly' ? 'Monthly Trend' : 'Daily Trend'}"/></span>
                </div>
                <div class="chart-container">
                  <canvas id="revenueTrendChart"></canvas>
                </div>
              </div>
            </div>

            <!-- Revenue by Payment Method Chart -->
            <div class="col-12 col-lg-4">
              <div class="card border-0 shadow-sm p-3 h-100">
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <h2 class="h6 fw-bold mb-0 text-dark"><i class="bi bi-credit-card-2-front text-success me-2"></i>Payment Methods</h2>
                </div>
                <div class="chart-container d-flex align-items-center justify-content-center">
                  <canvas id="paymentMethodChart"></canvas>
                </div>
              </div>
            </div>
          </div>

          <!-- Data Breakdown Tables Section -->
          <div class="row g-3 mb-4">
            <!-- Top Selling Products Table -->
            <div class="col-12 col-lg-7">
              <div class="card border-0 shadow-sm p-3 h-100">
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <h2 class="h6 fw-bold mb-0 text-dark"><i class="bi bi-trophy-fill text-warning me-2"></i>Top 5 Best Selling Headphones</h2>
                </div>
                <div class="table-responsive">
                  <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                      <tr>
                        <th style="width: 50px;">#</th>
                        <th>Product Name</th>
                        <th>Category</th>
                        <th class="text-center">Units Sold</th>
                        <th class="text-end">Total Revenue (VND)</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach items="${topProducts}" var="prod" varStatus="loop">
                        <tr>
                          <td>
                            <span class="badge rounded-circle ${loop.index == 0 ? 'bg-warning text-dark' : (loop.index == 1 ? 'bg-secondary' : 'bg-light text-dark border')}">
                              ${loop.index + 1}
                            </span>
                          </td>
                          <td class="fw-semibold text-dark"><c:out value="${prod.productName}"/></td>
                          <td><span class="badge bg-info-subtle text-info border border-info-subtle"><c:out value="${prod.categoryName}"/></span></td>
                          <td class="text-center fw-bold text-primary">${prod.totalQuantitySold}</td>
                          <td class="text-end fw-bold text-success">
                            <fmt:formatNumber value="${prod.totalRevenue}" type="number" groupingUsed="true"/> VND
                          </td>
                        </tr>
                      </c:forEach>
                      <c:if test="${empty topProducts}">
                        <tr>
                          <td colspan="5" class="text-center py-4 text-muted">No sales data found for the selected period.</td>
                        </tr>
                      </c:if>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <!-- Revenue Breakdown by Category -->
            <div class="col-12 col-lg-5">
              <div class="card border-0 shadow-sm p-3 h-100">
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <h2 class="h6 fw-bold mb-0 text-dark"><i class="bi bi-diagram-3-fill text-info me-2"></i>Revenue by Category</h2>
                </div>
                <div class="table-responsive">
                  <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                      <tr>
                        <th>Category</th>
                        <th class="text-center">Orders</th>
                        <th class="text-end">Revenue (VND)</th>
                        <th style="width: 100px;">Share</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach items="${categories}" var="cat">
                        <tr>
                          <td class="fw-semibold"><c:out value="${cat.categoryName}"/></td>
                          <td class="text-center"><span class="badge bg-light text-dark border">${cat.orderCount}</span></td>
                          <td class="text-end fw-bold">
                            <fmt:formatNumber value="${cat.totalRevenue}" type="number" groupingUsed="true"/>
                          </td>
                          <td>
                            <div class="d-flex align-items-center gap-2">
                              <small class="fw-bold">${cat.percentage}%</small>
                              <div class="progress flex-fill progress-bar-custom" style="height: 6px;">
                                <div class="progress-bar bg-primary" role="progressbar" style="width: ${cat.percentage}%;"></div>
                              </div>
                            </div>
                          </td>
                        </tr>
                      </c:forEach>
                      <c:if test="${empty categories}">
                        <tr>
                          <td colspan="4" class="text-center py-4 text-muted">No category revenue data available.</td>
                        </tr>
                      </c:if>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>

        </div>
      </main>
    </div>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Chart.js Render Script -->
  <script>
    // Export CSV Helper Function
    function exportRevenueCSV() {
      const startDate = document.getElementById('startDate').value;
      const endDate = document.getElementById('endDate').value;
      const groupBy = document.querySelector('select[name="groupBy"]').value;

      const exportUrl = `${pageContext.request.contextPath}/admin/revenue-report?action=export&startDate=\${encodeURIComponent(startDate)}&endDate=\${encodeURIComponent(endDate)}&groupBy=\${encodeURIComponent(groupBy)}`;
      window.location.href = exportUrl;
    }

    // 1. Revenue Trend Line Chart
    const trendLabels = [
      <c:forEach items="${trend}" var="t" varStatus="loop">
        "${t.periodLabel}"${!loop.last ? ',' : ''}
      </c:forEach>
    ];

    const trendValues = [
      <c:forEach items="${trend}" var="t" varStatus="loop">
        ${t.revenue}${!loop.last ? ',' : ''}
      </c:forEach>
    ];

    const ctxTrend = document.getElementById('revenueTrendChart').getContext('2d');
    new Chart(ctxTrend, {
      type: 'line',
      data: {
        labels: trendLabels,
        datasets: [{
          label: 'Revenue (VND)',
          data: trendValues,
          borderColor: '#2563eb',
          backgroundColor: 'rgba(37, 99, 235, 0.1)',
          fill: true,
          tension: 0.35,
          borderWidth: 3,
          pointRadius: 4,
          pointBackgroundColor: '#2563eb'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: function(context) {
                let value = context.raw || 0;
                return ' Revenue: ' + new Intl.NumberFormat('vi-VN').format(value) + ' VND';
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return new Intl.NumberFormat('vi-VN', { notation: 'compact' }).format(value) + ' ₫';
              }
            }
          }
        }
      }
    });

    // 2. Payment Method Doughnut Chart
    const paymentLabels = [];
    const paymentData = [];
    <c:forEach items="${paymentMethods}" var="pm">
      paymentLabels.push("${pm.key}");
      paymentData.push(${pm.value});
    </c:forEach>

    const ctxPayment = document.getElementById('paymentMethodChart').getContext('2d');
    new Chart(ctxPayment, {
      type: 'doughnut',
      data: {
        labels: paymentLabels,
        datasets: [{
          data: paymentData,
          backgroundColor: ['#059669', '#2563eb', '#d97706', '#9333ea'],
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom' },
          tooltip: {
            callbacks: {
              label: function(context) {
                let val = context.raw || 0;
                return ' ' + context.label + ': ' + new Intl.NumberFormat('vi-VN').format(val) + ' VND';
              }
            }
          }
        }
      }
    });
  </script>
</body>
</html>
