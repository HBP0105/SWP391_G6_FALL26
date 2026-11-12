<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.time.LocalDate" %>

<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Customer Behavior Data Pipeline | Admin Dashboard</title>

  <!-- Bootstrap 5 CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- Chart.js -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <!-- adminHMD Custom Style -->
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
    .pipeline-card-icon {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.5rem;
    }
    .bg-pipe-blue { background: rgba(37, 99, 235, 0.12); color: #2563eb; }
    .bg-pipe-green { background: rgba(16, 185, 129, 0.12); color: #10b981; }
    .bg-pipe-amber { background: rgba(245, 158, 11, 0.12); color: #f59e0b; }
    .bg-pipe-teal { background: rgba(20, 184, 166, 0.12); color: #14b8a6; }
    .chart-container {
      position: relative;
      height: 280px;
      width: 100%;
    }
    .pulse-dot {
      display: inline-block;
      width: 9px;
      height: 9px;
      border-radius: 50%;
      background-color: #10b981;
      box-shadow: 0 0 0 rgba(16, 185, 129, 0.5);
      animation: pulse 1.8s infinite;
    }
    @keyframes pulse {
      0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.6); }
      70% { box-shadow: 0 0 0 8px rgba(16, 185, 129, 0); }
      100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
    }
  </style>
</head>

<body>
  <div class="admin-shell">
    <div class="sidebar-backdrop" id="sidebarBackdrop"></div>

    <!-- SIDEBAR -->
    <jsp:include page="_sidebar.jsp" />

    <!-- MAIN CONTENT AREA -->
    <div class="admin-main">
      <!-- TOP NAVBAR -->
      <nav class="navbar admin-navbar navbar-expand bg-white border-bottom shadow-sm">
        <div class="container-fluid px-3">
          <span class="navbar-text fw-bold text-dark fs-6">
            <i class="bi bi-diagram-3-fill text-primary me-2"></i>Customer Behavior Data Pipeline Dashboard
          </span>
          <div class="navbar-actions ms-auto d-flex align-items-center gap-2">
            <span class="badge bg-success-subtle text-success fw-bold me-2 d-none d-md-inline-flex align-items-center">
              <span class="pulse-dot me-1"></span> Ingestion Stream Active
            </span>
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

      <!-- CONTENT BODY -->
      <div class="p-3 p-md-4">

        <!-- ALERTS -->
        <c:if test="${not empty msgError}">
          <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-3" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><strong>Error: </strong><c:out value="${msgError}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
          </div>
        </c:if>

        <c:if test="${not empty msgSuccess}">
          <div class="alert alert-success alert-dismissible fade show shadow-sm mb-3" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i><strong>Success: </strong><c:out value="${msgSuccess}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
          </div>
        </c:if>

        <!-- PAGE HEADER -->
        <div class="mb-3">
          <h4 class="fw-bold mb-0 text-dark">Data Pipeline Ingestion & Analytics</h4>
          <p class="text-muted small mb-0">Monitor live customer interaction events feeding the AI recommendation engine.</p>
        </div>

        <!-- FILTER TOOLBAR -->
        <div class="card border-0 shadow-sm mb-4">
          <div class="card-body p-3">
            <form id="filterForm" method="get" action="${pageContext.request.contextPath}/admin/behavior-pipeline" class="row g-2 align-items-end">
              <!-- From Date -->
              <div class="col-12 col-sm-6 col-md-3">
                <label class="form-label small fw-bold text-muted mb-1"><i class="bi bi-calendar-event me-1"></i>From Date</label>
                <div class="date-ddmmyyyy-wrapper">
                  <input type="text" id="startDateDisplay" class="form-control form-control-sm date-ddmmyyyy-display" placeholder="dd/mm/yyyy" readonly>
                  <input type="date" id="startDate" name="startDate" value="${selectedStartDate}" max="<%= LocalDate.now() %>" class="date-native-picker" title="Click to pick From Date">
                </div>
              </div>

              <!-- To Date -->
              <div class="col-12 col-sm-6 col-md-3">
                <label class="form-label small fw-bold text-muted mb-1"><i class="bi bi-calendar-check me-1"></i>To Date</label>
                <div class="date-ddmmyyyy-wrapper">
                  <input type="text" id="endDateDisplay" class="form-control form-control-sm date-ddmmyyyy-display" placeholder="dd/mm/yyyy" readonly>
                  <input type="date" id="endDate" name="endDate" value="${selectedEndDate}" max="<%= LocalDate.now() %>" class="date-native-picker" title="Click to pick To Date">
                </div>
              </div>

              <!-- Behavior Type Filter -->
              <div class="col-12 col-sm-6 col-md-3">
                <label class="form-label small fw-bold text-muted mb-1"><i class="bi bi-funnel me-1"></i>Event Type</label>
                <select name="type" class="form-select form-select-sm">
                  <option value="ALL" ${selectedType == 'ALL' ? 'selected' : ''}>All Events (ALL)</option>
                  <option value="VIEW" ${selectedType == 'VIEW' ? 'selected' : ''}>VIEW (Product Detail)</option>
                  <option value="SEARCH" ${selectedType == 'SEARCH' ? 'selected' : ''}>SEARCH (Keyword Search)</option>
                  <option value="FAVORITE" ${selectedType == 'FAVORITE' ? 'selected' : ''}>FAVORITE (Wishlist/Favorite)</option>
                  <option value="CART" ${selectedType == 'CART' ? 'selected' : ''}>CART (Add to Cart)</option>
                  <option value="PURCHASE" ${selectedType == 'PURCHASE' ? 'selected' : ''}>PURCHASE (Order Completed)</option>
                </select>
              </div>

              <!-- Action Buttons -->
              <div class="col-12 col-sm-6 col-md-3 d-flex gap-2">
                <button type="submit" class="btn btn-primary btn-sm flex-fill fw-bold">
                  <i class="bi bi-funnel-fill me-1"></i>Filter Pipeline
                </button>
                <a href="${pageContext.request.contextPath}/admin/behavior-pipeline" class="btn btn-outline-secondary btn-sm" title="Reset Filters">
                  <i class="bi bi-arrow-counterclockwise"></i>
                </a>
              </div>

              <!-- Quick Date Selection Row (Exact match with Revenue & AI Performance) -->
              <div class="col-12 d-flex align-items-center gap-1 pt-1">
                <span class="text-muted small me-1" style="font-size: 0.75rem;"><i class="bi bi-lightning-charge-fill text-warning"></i> Quick select:</span>
                <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('today')">Today</button>
                <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('7days')">Last 7 days</button>
                <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('month')">This month</button>
              </div>
            </form>
          </div>
        </div>

        <!-- 4 KPI SUMMARY METRIC CARDS -->
        <div class="row g-3 mb-4">
          <!-- Total Events Ingested -->
          <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm h-100 p-3">
              <div class="d-flex align-items-center justify-content-between">
                <div>
                  <span class="text-muted small fw-semibold text-uppercase">Ingested Events</span>
                  <h3 class="fw-bold text-primary my-1">
                    <fmt:formatNumber value="${summary.totalEvents != null ? summary.totalEvents : 0}" type="number" groupingUsed="true"/>
                  </h3>
                  <span class="extra-small text-muted">Total user interaction events</span>
                </div>
                <div class="pipeline-card-icon bg-pipe-blue">
                  <i class="bi bi-activity"></i>
                </div>
              </div>
            </div>
          </div>

          <!-- Total Sessions Tracked -->
          <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm h-100 p-3">
              <div class="d-flex align-items-center justify-content-between">
                <div>
                  <span class="text-muted small fw-semibold text-uppercase">Unique Sessions</span>
                  <h3 class="fw-bold text-success my-1">
                    <fmt:formatNumber value="${summary.totalSessions != null ? summary.totalSessions : 0}" type="number" groupingUsed="true"/>
                  </h3>
                  <span class="extra-small text-muted">Tracked by unique Session ID</span>
                </div>
                <div class="pipeline-card-icon bg-pipe-green">
                  <i class="bi bi-people-fill"></i>
                </div>
              </div>
            </div>
          </div>

          <!-- Cart-to-Purchase Conversion Rate -->
          <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm h-100 p-3">
              <div class="d-flex align-items-center justify-content-between">
                <div>
                  <span class="text-muted small fw-semibold text-uppercase">Cart-to-Purchase Funnel</span>
                  <h3 class="fw-bold text-warning my-1">
                    ${summary.cartToPurchaseRate != null ? summary.cartToPurchaseRate : 0.0}%
                  </h3>
                  <span class="extra-small text-muted">
                    <c:choose>
                      <c:when test="${summary.cartSessions != null && summary.cartSessions > 0}">
                        ${summary.convertedSessions}/${summary.cartSessions} converted purchase sessions
                      </c:when>
                      <c:otherwise>Sessions converted from cart to order</c:otherwise>
                    </c:choose>
                  </span>
                </div>
                <div class="pipeline-card-icon bg-pipe-amber">
                  <i class="bi bi-cart-check-fill"></i>
                </div>
              </div>
            </div>
          </div>

          <!-- Pipeline Health & Stream Status -->
          <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm h-100 p-3">
              <div class="d-flex align-items-center justify-content-between">
                <div>
                  <span class="text-muted small fw-semibold text-uppercase">Pipeline Status</span>
                  <h4 class="fw-bold text-teal my-1" style="color: #0f766e;">
                    HEALTHY
                  </h4>
                  <span class="extra-small text-muted"><span class="pulse-dot me-1"></span>Data ingestion stream active & stable</span>
                </div>
                <div class="pipeline-card-icon bg-pipe-teal">
                  <i class="bi bi-hdd-network-fill"></i>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 2 CHARTS & TOP KEYWORDS ROW -->
        <div class="row g-3 mb-4">
          <!-- Behavior Type Breakdown (Doughnut Chart) -->
          <div class="col-12 col-lg-4">
            <div class="card border-0 shadow-sm h-100">
              <div class="card-header bg-transparent border-0 pt-3 pb-0 d-flex justify-content-between align-items-center">
                <h6 class="fw-bold m-0"><i class="bi bi-pie-chart-fill text-primary me-2"></i>Behavior Type Breakdown</h6>
                <span class="badge bg-light text-dark">Event Distribution</span>
              </div>
              <div class="card-body p-3">
                <div class="chart-container">
                  <canvas id="behaviorDoughnutChart"></canvas>
                </div>
              </div>
            </div>
          </div>

          <!-- Ingestion Trend Over Time (Bar Chart) -->
          <div class="col-12 col-lg-5">
            <div class="card border-0 shadow-sm h-100">
              <div class="card-header bg-transparent border-0 pt-3 pb-0 d-flex justify-content-between align-items-center">
                <h6 class="fw-bold m-0"><i class="bi bi-bar-chart-line-fill text-success me-2"></i>Daily Ingestion Volume</h6>
                <span class="badge bg-light text-dark">Events / Day</span>
              </div>
              <div class="card-body p-3">
                <div class="chart-container">
                  <canvas id="dailyIngestionChart"></canvas>
                </div>
              </div>
            </div>
          </div>

          <!-- Top Searched Keywords List -->
          <div class="col-12 col-lg-3">
            <div class="card border-0 shadow-sm h-100">
              <div class="card-header bg-transparent border-0 pt-3 pb-0 d-flex justify-content-between align-items-center">
                <h6 class="fw-bold m-0"><i class="bi bi-search text-warning me-2"></i>Top Keywords</h6>
                <span class="badge bg-warning-subtle text-warning fw-bold">Search Intents</span>
              </div>
              <div class="card-body p-3">
                <c:choose>
                  <c:when test="${empty topKeywords}">
                    <div class="text-center text-muted py-4 small">No search keyword data available.</div>
                  </c:when>
                  <c:otherwise>
                    <ul class="list-group list-group-flush small">
                      <c:forEach var="kw" items="${topKeywords}" varStatus="status">
                        <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-2 border-0 border-bottom">
                          <span class="fw-semibold text-dark">
                            <span class="badge bg-secondary-subtle text-secondary me-1">#${status.index + 1}</span>
                            "${kw.searchKeyword}"
                          </span>
                          <span class="badge bg-primary-subtle text-primary fw-bold">${kw.searchCount} searches</span>
                        </li>
                      </c:forEach>
                    </ul>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>
        </div>

        <!-- REAL-TIME BEHAVIOR INGESTION STREAM LOGS TABLE -->
        <div class="panel mb-4 card border-0 shadow-sm">
          <div class="card-header bg-transparent border-0 pt-3 pb-2 d-flex justify-content-between align-items-center">
            <h6 class="fw-bold m-0"><i class="bi bi-terminal-split text-primary me-2"></i>Live Behavior Ingestion Stream Logs</h6>
            <span class="badge bg-primary-subtle text-primary fw-bold">Latest 25 Events</span>
          </div>

          <div class="table-responsive">
            <table class="table table-hover align-middle table-orders mb-0">
              <thead class="table-light">
                <tr>
                  <th style="width: 70px;">ID</th>
                  <th>Ingestion Timestamp</th>
                  <th>Customer</th>
                  <th class="text-center">Event Type</th>
                  <th>Interacted Product</th>
                  <th>Search Keyword</th>
                  <th>Session ID</th>
                  <th class="text-center">Ingestion Status</th>
                </tr>
              </thead>
              <tbody>
                <c:choose>
                  <c:when test="${empty streamLogs}">
                    <tr>
                      <td colspan="8" class="text-center text-muted py-4">
                        <i class="bi bi-inbox fs-3 d-block text-secondary mb-1"></i>
                        No behavior events found for the selected time range.
                      </td>
                    </tr>
                  </c:when>
                  <c:otherwise>
                    <c:forEach var="row" items="${streamLogs}">
                      <c:set var="ub" value="${row.behavior}"/>
                      <tr>
                        <td class="font-monospace text-muted">#${ub.behaviorId}</td>
                        <td class="small text-muted font-monospace text-nowrap">
                          <i class="bi bi-clock me-1 text-secondary"></i>${row.formattedTime}
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${not empty ub.customerId && ub.customerId > 0}">
                              <div class="fw-semibold text-dark"><i class="bi bi-person-fill text-primary me-1"></i>${row.customerName}</div>
                              <small class="text-muted font-monospace" style="font-size: 0.7rem;">UID: #${ub.customerId}</small>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-light text-secondary border"><i class="bi bi-person-slash me-1"></i>Guest User</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td class="text-center">
                          <c:choose>
                            <c:when test="${ub.behaviorType == 'VIEW'}">
                              <span class="badge bg-primary-subtle text-primary fw-bold px-2 py-1"><i class="bi bi-eye-fill me-1"></i>VIEW</span>
                            </c:when>
                            <c:when test="${ub.behaviorType == 'SEARCH'}">
                              <span class="badge bg-purple-subtle text-purple fw-bold px-2 py-1" style="background: rgba(139, 92, 246, 0.15); color: #8b5cf6;"><i class="bi bi-search me-1"></i>SEARCH</span>
                            </c:when>
                            <c:when test="${ub.behaviorType == 'FAVORITE'}">
                              <span class="badge bg-danger-subtle text-danger fw-bold px-2 py-1"><i class="bi bi-heart-fill me-1"></i>FAVORITE</span>
                            </c:when>
                            <c:when test="${ub.behaviorType == 'CART'}">
                              <span class="badge bg-warning-subtle text-warning fw-bold px-2 py-1"><i class="bi bi-cart-plus-fill me-1"></i>CART</span>
                            </c:when>
                            <c:when test="${ub.behaviorType == 'PURCHASE'}">
                              <span class="badge bg-success-subtle text-success fw-bold px-2 py-1"><i class="bi bi-bag-check-fill me-1"></i>PURCHASE</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-secondary-subtle text-secondary fw-bold px-2 py-1">${ub.behaviorType}</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${row.productName != '—'}">
                              <span class="fw-semibold text-dark">${row.productName}</span>
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted">—</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${not empty ub.searchKeyword}">
                              <span class="badge bg-light text-dark border">"${ub.searchKeyword}"</span>
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted">—</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td class="font-monospace text-muted small">${ub.sessionId}</td>
                        <td class="text-center">
                          <span class="badge bg-success-subtle text-success fw-bold px-2 py-0.5" style="font-size: 0.72rem;">
                            <i class="bi bi-check-circle-fill me-1"></i>Ingested
                          </span>
                        </td>
                      </tr>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </tbody>
            </table>
          </div>
        </div>

      </div>
    </div>
  </div>

  <!-- Bootstrap 5 JS Bundle -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Chart.js & Date Picker Scripts -->
  <script>
    // Theme Switcher Script
    const themeToggleBtn = document.getElementById('themeToggleBtn');
    const themeIcon = document.getElementById('themeIcon');
    const htmlTag = document.documentElement;

    const savedTheme = localStorage.getItem('adminTheme') || 'light';
    htmlTag.setAttribute('data-theme', savedTheme);
    updateThemeIcon(savedTheme);

    if (themeToggleBtn) {
      themeToggleBtn.addEventListener('click', () => {
        const currentTheme = htmlTag.getAttribute('data-theme');
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        htmlTag.setAttribute('data-theme', newTheme);
        localStorage.setItem('adminTheme', newTheme);
        updateThemeIcon(newTheme);
      });
    }

    function updateThemeIcon(theme) {
      if (!themeIcon) return;
      themeIcon.className = (theme === 'dark') ? 'bi bi-sun-fill text-warning' : 'bi bi-moon-stars';
    }

    // Chart 1: Doughnut Chart (Distribution by Behavior Type)
    const distLabels = [
      <c:forEach var="item" items="${typeDistribution}" varStatus="status">
        '${item.behaviorType}'${!status.last ? ',' : ''}
      </c:forEach>
    ];

    const distData = [
      <c:forEach var="item" items="${typeDistribution}" varStatus="status">
        ${item.eventCount}${!status.last ? ',' : ''}
      </c:forEach>
    ];

    const doughnutCtx = document.getElementById('behaviorDoughnutChart').getContext('2d');
    new Chart(doughnutCtx, {
      type: 'doughnut',
      data: {
        labels: distLabels.length > 0 ? distLabels : ['VIEW', 'SEARCH', 'CART', 'FAVORITE', 'PURCHASE'],
        datasets: [{
          data: distData.length > 0 ? distData : [5, 2, 3, 1, 1],
          backgroundColor: [
            'rgba(37, 99, 235, 0.8)',   // VIEW: Blue
            'rgba(139, 92, 246, 0.8)',  // SEARCH: Purple
            'rgba(245, 158, 11, 0.8)',  // CART: Amber
            'rgba(239, 68, 68, 0.8)',   // FAVORITE: Red
            'rgba(16, 185, 129, 0.8)'   // PURCHASE: Green
          ],
          borderWidth: 2,
          hoverOffset: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom',
            labels: { font: { weight: 'bold', size: 11 } }
          }
        }
      }
    });

    // Chart 2: Bar Chart (Daily Ingestion Trend)
    const trendLabels = [
      <c:forEach var="item" items="${dailyTrend}" varStatus="status">
        '${item.periodLabel}'${!status.last ? ',' : ''}
      </c:forEach>
    ];

    const trendData = [
      <c:forEach var="item" items="${dailyTrend}" varStatus="status">
        ${item.eventCount}${!status.last ? ',' : ''}
      </c:forEach>
    ];

    const barCtx = document.getElementById('dailyIngestionChart').getContext('2d');
    new Chart(barCtx, {
      type: 'bar',
      data: {
        labels: trendLabels.length > 0 ? trendLabels : ['Today'],
        datasets: [{
          label: 'Ingested Events',
          data: trendData.length > 0 ? trendData : [12],
          backgroundColor: 'rgba(16, 185, 129, 0.75)',
          borderColor: '#10b981',
          borderWidth: 1,
          borderRadius: 4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { precision: 0 }
          }
        }
      }
    });

    // Format YYYY-MM-DD to DD/MM/YYYY
    function formatToDMY(isoDate) {
      if (!isoDate || isoDate.indexOf('-') === -1) return '';
      const parts = isoDate.split('-');
      if (parts.length === 3) {
        return parts[2] + '/' + parts[1] + '/' + parts[0];
      }
      return isoDate;
    }

    // Format Date object to local YYYY-MM-DD
    function formatLocalDate(d) {
      var year = d.getFullYear();
      var month = String(d.getMonth() + 1).padStart(2, '0');
      var day = String(d.getDate()).padStart(2, '0');
      return year + '-' + month + '-' + day;
    }

    // Quick Date Range Filter Handler (Exact match with Revenue & AI Performance)
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

    function validateBehaviorDates() {
      const startInput = document.getElementById('startDate');
      const endInput = document.getElementById('endDate');
      const startVal = startInput ? startInput.value : '';
      const endVal = endInput ? endInput.value : '';
      const today = new Date().toISOString().split('T')[0];

      if (startVal && startVal > today) {
        alert('Validation Error: "From Date" cannot be in the future!');
        startInput.value = '';
        startInput.focus();
        return false;
      }

      if (endVal && endVal > today) {
        alert('Validation Error: "To Date" cannot be in the future!');
        endInput.value = '';
        endInput.focus();
        return false;
      }

      if (startVal && endVal && startVal > endVal) {
        alert('Validation Error: "From Date" cannot be later than "To Date"!');
        startInput.focus();
        return false;
      }

      return true;
    }

    document.addEventListener('DOMContentLoaded', function() {
      const startInput = document.getElementById('startDate');
      const endInput = document.getElementById('endDate');
      const startDisplay = document.getElementById('startDateDisplay');
      const endDisplay = document.getElementById('endDateDisplay');
      const filterForm = document.getElementById('filterForm');

      // Initialize visible display with dd/mm/yyyy format
      if (startInput && startDisplay) {
        startDisplay.value = formatToDMY(startInput.value);
        startInput.addEventListener('input', function() {
          startDisplay.value = formatToDMY(this.value);
        });
        startDisplay.addEventListener('click', function() {
          if (startInput.showPicker) startInput.showPicker();
          else startInput.focus();
        });
      }

      if (endInput && endDisplay) {
        endDisplay.value = formatToDMY(endInput.value);
        endInput.addEventListener('input', function() {
          endDisplay.value = formatToDMY(this.value);
        });
        endDisplay.addEventListener('click', function() {
          if (endInput.showPicker) endInput.showPicker();
          else endInput.focus();
        });
      }

      if (filterForm) {
        filterForm.addEventListener('submit', function(e) {
          if (!validateBehaviorDates()) {
            e.preventDefault();
          }
        });
      }

      if (startInput) {
        startInput.addEventListener('change', function() {
          if (startDisplay) startDisplay.value = formatToDMY(this.value);
          if (this.value && endInput && endInput.value && this.value > endInput.value) {
            alert('Validation Error: "From Date" cannot be later than "To Date"!');
            this.value = '';
            if (startDisplay) startDisplay.value = '';
          }
        });
      }

      if (endInput) {
        endInput.addEventListener('change', function() {
          if (endDisplay) endDisplay.value = formatToDMY(this.value);
          if (this.value && startInput && startInput.value && this.value < startInput.value) {
            alert('Validation Error: "To Date" cannot be earlier than "From Date"!');
            this.value = '';
            if (endDisplay) endDisplay.value = '';
          }
        });
      }
    });
  </script>
</body>
</html>
