<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
  pageContext.setAttribute("dtFmt", DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
  pageContext.setAttribute("dmyFmt", DateTimeFormatter.ofPattern("dd/MM/yyyy"));
%>

<!DOCTYPE html>
<html lang="en" data-theme="light" data-bs-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>System Audit Logs - Admin Portal</title>

  <!-- Google Fonts: Inter -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

  <!-- Bootstrap 5 CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- AdminHMD Custom Style -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminhmd-style.css">

  <style>
    /* Mini Stat Card Styling */
    .mini-stat-card {
      border: 1px solid rgba(226, 232, 240, 0.8);
      border-radius: 10px;
      padding: 12px 16px;
      background: #ffffff;
      transition: all 0.2s ease-in-out;
    }
    .mini-stat-card:hover {
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
      transform: translateY(-1px);
    }
    .mini-stat-icon {
      width: 40px;
      height: 40px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.25rem;
    }
    .bg-icon-primary { background: rgba(37, 99, 235, 0.1); color: #2563eb; }
    .bg-icon-success { background: rgba(5, 150, 105, 0.1); color: #059669; }
    .bg-icon-warning { background: rgba(217, 119, 6, 0.1); color: #d97706; }
    .bg-icon-purple  { background: rgba(147, 51, 234, 0.1); color: #9333ea; }

    /* Date picker wrapper */
    .date-ddmmyyyy-wrapper { position: relative; }
    .date-ddmmyyyy-display { background-color: #fff !important; cursor: pointer; }
    .date-native-picker {
      position: absolute; top: 0; right: 0; width: 36px; height: 100%;
      opacity: 0; cursor: pointer; z-index: 2;
    }

    .badge-action {
      font-size: 0.68rem;
      padding: 0.35em 0.65em;
      font-weight: 600;
      letter-spacing: 0.02em;
    }

    .log-details-box {
      font-family: SFMono-Regular, Menlo, Monaco, Consolas, "Courier New", monospace;
      font-size: 0.75rem;
      background: rgba(241, 245, 249, 0.85);
      border-radius: 6px;
      padding: 4px 8px;
      border: 1px solid rgba(226, 232, 240, 0.8);
      max-width: 440px;
      word-break: break-word;
    }

    html[data-theme="dark"] .mini-stat-card {
      background: var(--admin-surface, #182235) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .log-details-box {
      background: rgba(30, 41, 59, 0.7) !important;
      border-color: rgba(51, 65, 85, 0.8) !important;
      color: #cbd5e1 !important;
    }
    html[data-theme="dark"] .form-select,
    html[data-theme="dark"] .form-control,
    html[data-theme="dark"] .date-ddmmyyyy-display {
      background-color: var(--admin-surface, #182235) !important;
      color: var(--admin-text, #e5edf7) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
  </style>
</head>

<body>
  <div class="admin-shell">
    <div class="sidebar-backdrop" id="sidebarBackdrop"></div>

    <!-- SIDEBAR -->
    <aside class="admin-sidebar" id="adminSidebar">
      <div class="sidebar-header">
        <a class="brand-mark" href="${pageContext.request.contextPath}/admin/revenue-report">
          <span class="brand-icon"><i class="bi bi-shield-lock-fill"></i></span>
          <span class="brand-copy">
            <span class="brand-title">Admin Portal</span>
            <span class="brand-subtitle">Headphone Shop</span>
          </span>
        </a>
      </div>

      <nav class="sidebar-nav">
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/revenue-report">
          <span class="nav-icon"><i class="bi bi-graph-up-arrow"></i></span>
          <span class="nav-text">Revenue Report</span>
        </a>
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/ai-performance">
          <span class="nav-icon"><i class="bi bi-robot"></i></span>
          <span class="nav-text">AI Performance & Config</span>
        </a>
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/behavior-pipeline">
          <span class="nav-icon"><i class="bi bi-diagram-3"></i></span>
          <span class="nav-text">Behavior Pipeline</span>
        </a>
        <a class="nav-link active" href="${pageContext.request.contextPath}/admin/audit-logs">
          <span class="nav-icon"><i class="bi bi-clock-history"></i></span>
          <span class="nav-text">Audit Logs</span>
        </a>
      </nav>
    </aside>

    <!-- MAIN CONTENT -->
    <div class="admin-main">
      <!-- TOP NAVBAR -->
      <nav class="navbar admin-navbar navbar-expand bg-white">
        <div class="container-fluid px-0">
          <button class="icon-button d-lg-none" id="sidebarToggleBtn" type="button" aria-label="Toggle Sidebar">
            <i class="bi bi-list fs-5"></i>
          </button>

          <span class="navbar-text fw-bold text-dark fs-6 d-none d-sm-inline">
            <i class="bi bi-clock-history text-primary me-2"></i>System Audit Trail & Compliance
          </span>

          <div class="navbar-actions ms-auto d-flex align-items-center gap-2">
            <!-- Theme Toggle -->
            <button class="icon-button theme-toggle" id="themeToggleBtn" type="button" title="Switch Light/Dark Theme">
              <i class="bi bi-moon-stars" id="themeIcon"></i>
            </button>

            <!-- Profile Dropdown -->
            <div class="dropdown">
              <button class="profile-button dropdown-toggle border-0" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-person-circle text-primary fs-5 me-1"></i>
                <span class="profile-name d-none d-sm-inline fw-semibold">Administrator</span>
              </button>
              <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/home"><i class="bi bi-shop me-2"></i>Storefront</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Sign Out</a></li>
              </ul>
            </div>
          </div>
        </div>
      </nav>

      <!-- PAGE BODY -->
      <main class="dashboard-content overflow-auto py-3">
        <div class="container-fluid px-3">

          <!-- PAGE HEADING -->
          <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <div>
              <h1 class="h4 mb-0 fw-bold text-dark">System Activity & Audit Logs</h1>
              <p class="text-muted small mb-0">Track administrative activities, staff operations, order lifecycle transitions, and system events.</p>
            </div>
            <div>
              <span class="badge bg-light text-dark border px-2.5 py-1.5 fs-7">
                <i class="bi bi-shield-check text-success me-1"></i>Tamper-Evident Audit Trail
              </span>
            </div>
          </div>

          <!-- Alert Notification Error -->
          <c:if test="${not empty msgError}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-3 py-2" role="alert">
              <i class="bi bi-exclamation-triangle-fill me-2"></i><strong>Validation Error: </strong> <c:out value="${msgError}"/>
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
          </c:if>

          <!-- 4 MINI STAT CARDS -->
          <div class="row g-2 mb-3">
            <div class="col-6 col-md-3">
              <div class="mini-stat-card d-flex align-items-center justify-content-between">
                <div>
                  <div class="text-muted extra-small fw-semibold text-uppercase">Total System Logs</div>
                  <div class="h4 fw-bold text-primary mb-0"><fmt:formatNumber value="${totalLogs}" pattern="#,###"/></div>
                </div>
                <div class="mini-stat-icon bg-icon-primary"><i class="bi bi-journal-text"></i></div>
              </div>
            </div>

            <div class="col-6 col-md-3">
              <div class="mini-stat-card d-flex align-items-center justify-content-between">
                <div>
                  <div class="text-muted extra-small fw-semibold text-uppercase">Recorded Today</div>
                  <div class="h4 fw-bold text-success mb-0"><fmt:formatNumber value="${todayLogs}" pattern="#,###"/></div>
                </div>
                <div class="mini-stat-icon bg-icon-success"><i class="bi bi-calendar-check"></i></div>
              </div>
            </div>

            <div class="col-6 col-md-3">
              <div class="mini-stat-card d-flex align-items-center justify-content-between">
                <div>
                  <div class="text-muted extra-small fw-semibold text-uppercase">Order Lifecycle Events</div>
                  <div class="h4 fw-bold text-warning mb-0"><fmt:formatNumber value="${orderLogs}" pattern="#,###"/></div>
                </div>
                <div class="mini-stat-icon bg-icon-warning"><i class="bi bi-bag-check"></i></div>
              </div>
            </div>

            <div class="col-6 col-md-3">
              <div class="mini-stat-card d-flex align-items-center justify-content-between">
                <div>
                  <div class="text-muted extra-small fw-semibold text-uppercase">Config & System Events</div>
                  <div class="h4 fw-bold text-purple mb-0" style="color: #9333ea;"><fmt:formatNumber value="${configLogs}" pattern="#,###"/></div>
                </div>
                <div class="mini-stat-icon bg-icon-purple"><i class="bi bi-sliders"></i></div>
              </div>
            </div>
          </div>

          <!-- UNIFIED FILTER & SEARCH BAR -->
          <div class="card border-0 shadow-sm p-3 mb-3">
            <form method="get" action="${pageContext.request.contextPath}/admin/audit-logs" id="filterForm">
              <div class="row g-2 align-items-end">
                <!-- Search Keyword -->
                <div class="col-12 col-lg-3">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-search me-1 text-primary"></i>Search Keyword:</label>
                  <input type="search" class="form-control form-control-sm" name="keyword" value="<c:out value='${selectedKeyword}'/>" placeholder="Staff name, email, #ORD..." autocomplete="off">
                </div>

                <!-- Action Filter -->
                <div class="col-6 col-sm-4 col-lg-2">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-funnel me-1 text-primary"></i>Action Category:</label>
                  <select name="action" class="form-select form-select-sm" onchange="document.getElementById('filterForm').submit();">
                    <option value="ALL" ${selectedAction == 'ALL' ? 'selected' : ''}>-- All Actions --</option>
                    <c:forEach var="act" items="${distinctActions}">
                      <option value="${act}" ${selectedAction == act ? 'selected' : ''}><c:out value="${act}"/></option>
                    </c:forEach>
                  </select>
                </div>

                <!-- From Date -->
                <div class="col-6 col-sm-4 col-lg-2">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-calendar-event me-1 text-primary"></i>From Date:</label>
                  <div class="date-ddmmyyyy-wrapper">
                    <input type="text" id="startDateDisplay" placeholder="dd/mm/yyyy" class="form-control form-control-sm date-ddmmyyyy-display" readonly>
                    <input type="date" name="startDate" id="startDate" value="<c:out value='${selectedStartDate}'/>" max="<%= LocalDate.now() %>" class="date-native-picker" title="Click to pick From Date">
                  </div>
                </div>

                <!-- To Date -->
                <div class="col-6 col-sm-4 col-lg-2">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-calendar-check me-1 text-primary"></i>To Date:</label>
                  <div class="date-ddmmyyyy-wrapper">
                    <input type="text" id="endDateDisplay" placeholder="dd/mm/yyyy" class="form-control form-control-sm date-ddmmyyyy-display" readonly>
                    <input type="date" name="endDate" id="endDate" value="<c:out value='${selectedEndDate}'/>" max="<%= LocalDate.now() %>" class="date-native-picker" title="Click to pick To Date">
                  </div>
                </div>

                <!-- Action Buttons -->
                <div class="col-6 col-lg-3 d-flex gap-2">
                  <button type="submit" class="btn btn-primary btn-sm flex-fill fw-bold">
                    <i class="bi bi-funnel-fill me-1"></i> Filter Logs
                  </button>
                  <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn btn-outline-secondary btn-sm" title="Reset Filters">
                    <i class="bi bi-arrow-counterclockwise"></i>
                  </a>
                </div>

                <!-- Quick Select Buttons Inline -->
                <div class="col-12 d-flex align-items-center gap-1 pt-1">
                  <span class="text-muted small me-1" style="font-size: 0.75rem;"><i class="bi bi-lightning-charge-fill text-warning"></i> Quick select:</span>
                  <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('today')">Today</button>
                  <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('7days')">Last 7 days</button>
                  <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('month')">This month</button>
                </div>
              </div>
            </form>
          </div>

          <!-- AUDIT LOGS TABLE PANEL -->
          <div class="card border-0 shadow-sm p-3 mb-4">
            <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
              <h2 class="h6 mb-0 fw-bold text-dark">
                <i class="bi bi-list-ul text-primary me-2"></i>Audit Records (<fmt:formatNumber value="${totalCount}" pattern="#,###"/>)
              </h2>
              <c:if test="${not empty selectedAction && selectedAction != 'ALL'}">
                <span class="badge bg-primary-subtle text-primary border">Action: <c:out value="${selectedAction}"/></span>
              </c:if>
            </div>

            <div class="table-responsive">
              <table class="table table-hover align-middle mb-0" style="font-size: 0.8rem;">
                <thead class="table-light">
                  <tr>
                    <th style="width: 60px;" class="text-center">#ID</th>
                    <th style="width: 150px;">Timestamp</th>
                    <th style="width: 180px;">Actor / Staff</th>
                    <th style="width: 130px;">Action</th>
                    <th style="width: 130px;">Entity</th>
                    <th>Audit Details & State Transition</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="log" items="${logs}">
                    <tr>
                      <!-- ID -->
                      <td class="text-center fw-bold text-muted">#<c:out value="${log.auditLogId}"/></td>

                      <!-- Timestamp -->
                      <td>
                        <div class="fw-semibold text-dark">
                          <i class="bi bi-clock me-1 text-primary"></i>
                          <c:out value="${not empty log.createdAt ? log.createdAt.format(dtFmt) : 'N/A'}"/>
                        </div>
                      </td>

                      <!-- Actor / Staff -->
                      <td>
                        <c:choose>
                          <c:when test="${not empty log.staffName}">
                            <div class="fw-bold text-dark"><c:out value="${log.staffName}"/></div>
                            <small class="text-muted"><c:out value="${log.staffEmail}"/></small>
                            <c:if test="${not empty log.roleName}">
                              <div><span class="badge text-bg-light border text-secondary" style="font-size: 0.65rem;"><c:out value="${log.roleName}"/></span></div>
                            </c:if>
                          </c:when>
                          <c:otherwise>
                            <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle">
                              <i class="bi bi-cpu me-1"></i>System Auto
                            </span>
                          </c:otherwise>
                        </c:choose>
                      </td>

                      <!-- Action Badge -->
                      <td>
                        <c:choose>
                          <c:when test="${fn:contains(log.action, 'CANCEL') || fn:contains(log.action, 'DELETE')}">
                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle badge-action">
                              <i class="bi bi-x-circle me-1"></i><c:out value="${log.action}"/>
                            </span>
                          </c:when>
                          <c:when test="${fn:contains(log.action, 'CREATE')}">
                            <span class="badge bg-success-subtle text-success border border-success-subtle badge-action">
                              <i class="bi bi-plus-circle me-1"></i><c:out value="${log.action}"/>
                            </span>
                          </c:when>
                          <c:when test="${fn:contains(log.action, 'STATUS')}">
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle badge-action">
                              <i class="bi bi-arrow-repeat me-1"></i><c:out value="${log.action}"/>
                            </span>
                          </c:when>
                          <c:when test="${fn:contains(log.action, 'CONFIG')}">
                            <span class="badge bg-warning-subtle text-warning border border-warning-subtle badge-action">
                              <i class="bi bi-sliders me-1"></i><c:out value="${log.action}"/>
                            </span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge bg-info-subtle text-info border border-info-subtle badge-action">
                              <i class="bi bi-activity me-1"></i><c:out value="${log.action}"/>
                            </span>
                          </c:otherwise>
                        </c:choose>
                      </td>

                      <!-- Target Entity -->
                      <td>
                        <span class="badge bg-light text-dark border fw-bold">
                          <c:out value="${not empty log.entityName ? log.entityName : 'System'}"/>
                        </span>
                        <c:if test="${not empty log.entityId}">
                          <div class="fw-semibold text-primary mt-1" style="font-size: 0.75rem;"><c:out value="${log.entityId}"/></div>
                        </c:if>
                      </td>

                      <!-- Details -->
                      <td>
                        <div class="log-details-box">
                          <c:choose>
                            <c:when test="${not empty log.oldData && not empty log.newData}">
                              <span class="text-danger fw-semibold"><c:out value="${log.oldData}"/></span>
                              <i class="bi bi-arrow-right mx-1 text-muted"></i>
                              <span class="text-success fw-bold"><c:out value="${log.newData}"/></span>
                            </c:when>
                            <c:when test="${not empty log.newData}">
                              <span class="text-dark"><c:out value="${log.newData}"/></span>
                            </c:when>
                            <c:when test="${not empty log.oldData}">
                              <span class="text-muted"><c:out value="${log.oldData}"/></span>
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted fst-italic">No details provided</span>
                            </c:otherwise>
                          </c:choose>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>

                  <c:if test="${empty logs}">
                    <tr>
                      <td colspan="6" class="text-center py-5">
                        <div class="text-muted">
                          <i class="bi bi-journal-x fs-1 opacity-50 d-block mb-2"></i>
                          <h6 class="fw-bold">No Audit Log Records Found</h6>
                          <p class="small mb-0">No activity records matched your selected search and date parameters.</p>
                        </div>
                      </td>
                    </tr>
                  </c:if>
                </tbody>
              </table>
            </div>

            <!-- PAGINATION BAR -->
            <c:if test="${totalPages > 1}">
              <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 pt-3 border-top mt-3">
                <div class="text-muted small">
                  Showing ${(page - 1) * pageSize + 1} - ${Math.min(page * pageSize, totalCount)} of ${totalCount} records (Page ${page}/${totalPages})
                </div>

                <ul class="pagination pagination-sm mb-0">
                  <!-- Prev -->
                  <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${page - 1}&action=${selectedAction}&startDate=${selectedStartDate}&endDate=${selectedEndDate}&keyword=${selectedKeyword}">
                      &laquo; Prev
                    </a>
                  </li>

                  <!-- Page numbers -->
                  <c:forEach var="p" begin="1" end="${totalPages}">
                    <c:if test="${p == 1 || p == totalPages || (p >= page - 2 && p <= page + 2)}">
                      <li class="page-item ${p == page ? 'active' : ''}">
                        <a class="page-link" href="?page=${p}&action=${selectedAction}&startDate=${selectedStartDate}&endDate=${selectedEndDate}&keyword=${selectedKeyword}">
                          ${p}
                        </a>
                      </li>
                    </c:if>
                    <c:if test="${(p == page - 3 && p > 1) || (p == page + 3 && p < totalPages)}">
                      <li class="page-item disabled"><span class="page-link">...</span></li>
                    </c:if>
                  </c:forEach>

                  <!-- Next -->
                  <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${page + 1}&action=${selectedAction}&startDate=${selectedStartDate}&endDate=${selectedEndDate}&keyword=${selectedKeyword}">
                      Next &raquo;
                    </a>
                  </li>
                </ul>
              </div>
            </c:if>
          </div>

        </div>
      </main>
    </div>
  </div>

  <!-- Bootstrap 5 JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    // Format YYYY-MM-DD to DD/MM/YYYY
    function formatToDMY(isoDate) {
      if (!isoDate || isoDate.indexOf('-') === -1) return '';
      var parts = isoDate.split('-');
      if (parts.length === 3) {
        return parts[2] + '/' + parts[1] + '/' + parts[0];
      }
      return isoDate;
    }

    // Format Date object to YYYY-MM-DD
    function formatLocalDate(d) {
      var year = d.getFullYear();
      var month = ('0' + (d.getMonth() + 1)).slice(-2);
      var day = ('0' + d.getDate()).slice(-2);
      return year + '-' + month + '-' + day;
    }

    // Client-side Date Validation (Future Date & Range Check)
    function validateAuditDates(changedField) {
      var startInput = document.getElementById('startDate');
      var endInput = document.getElementById('endDate');
      var startDisplay = document.getElementById('startDateDisplay');
      var endDisplay = document.getElementById('endDateDisplay');
      var startVal = startInput ? startInput.value : '';
      var endVal = endInput ? endInput.value : '';
      var todayStr = formatLocalDate(new Date());

      if (changedField === 'startDate') {
        if (startVal && startVal > todayStr) {
          alert('Validation Error: "From Date" cannot be in the future!');
          startInput.value = '';
          if (startDisplay) startDisplay.value = '';
          return false;
        }
        if (startVal && endVal && startVal > endVal) {
          alert('Validation Error: "From Date" cannot be later than "To Date"!');
          startInput.value = '';
          if (startDisplay) startDisplay.value = '';
          return false;
        }
      }

      if (changedField === 'endDate') {
        if (endVal && endVal > todayStr) {
          alert('Validation Error: "To Date" cannot be in the future!');
          endInput.value = '';
          if (endDisplay) endDisplay.value = '';
          return false;
        }
        if (startVal && endVal && endVal < startVal) {
          alert('Validation Error: "To Date" cannot be earlier than "From Date"!');
          endInput.value = '';
          if (endDisplay) endDisplay.value = '';
          return false;
        }
      }

      if (!changedField) {
        if (startVal && startVal > todayStr) {
          alert('Validation Error: "From Date" cannot be in the future!');
          if (startInput) startInput.focus();
          return false;
        }
        if (endVal && endVal > todayStr) {
          alert('Validation Error: "To Date" cannot be in the future!');
          if (endInput) endInput.focus();
          return false;
        }
        if (startVal && endVal && startVal > endVal) {
          alert('Validation Error: "From Date" cannot be later than "To Date"!');
          if (startInput) startInput.focus();
          return false;
        }
      }
      return true;
    }

    // Quick Select handler (Today, 7 days, This month)
    function setQuickDate(type) {
      var now = new Date();
      var todayStr = formatLocalDate(now);
      var startStr = '';
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

    document.addEventListener('DOMContentLoaded', function() {
      // Sidebar mobile toggle
      var toggleBtn = document.getElementById('sidebarToggleBtn');
      var sidebar = document.getElementById('adminSidebar');
      var backdrop = document.getElementById('sidebarBackdrop');
      if (toggleBtn && sidebar) {
        toggleBtn.addEventListener('click', function() {
          sidebar.classList.toggle('show');
          if (backdrop) backdrop.classList.toggle('show');
        });
        if (backdrop) {
          backdrop.addEventListener('click', function() {
            sidebar.classList.remove('show');
            backdrop.classList.remove('show');
          });
        }
      }

      // Date Display Sync & Change Validation
      var startInput = document.getElementById('startDate');
      var endInput = document.getElementById('endDate');
      var startDisplay = document.getElementById('startDateDisplay');
      var endDisplay = document.getElementById('endDateDisplay');
      var filterForm = document.getElementById('filterForm');

      if (startInput && startDisplay) {
        startDisplay.value = formatToDMY(startInput.value);
        startInput.addEventListener('change', function() {
          if (!validateAuditDates('startDate')) return;
          startDisplay.value = formatToDMY(this.value);
          if (filterForm) filterForm.submit();
        });
        startDisplay.addEventListener('click', function() {
          if (startInput.showPicker) startInput.showPicker();
          else startInput.focus();
        });
      }

      if (endInput && endDisplay) {
        endDisplay.value = formatToDMY(endInput.value);
        endInput.addEventListener('change', function() {
          if (!validateAuditDates('endDate')) return;
          endDisplay.value = formatToDMY(this.value);
          if (filterForm) filterForm.submit();
        });
        endDisplay.addEventListener('click', function() {
          if (endInput.showPicker) endInput.showPicker();
          else endInput.focus();
        });
      }

      // Intercept Form Submit for Full Validation
      if (filterForm) {
        filterForm.addEventListener('submit', function(e) {
          if (!validateAuditDates()) {
            e.preventDefault();
          }
        });
      }

      // Dark / Light Theme Toggle & Persistence
      var themeToggleBtn = document.getElementById('themeToggleBtn');
      var themeIcon = document.getElementById('themeIcon');
      var htmlTag = document.documentElement;

      function applyTheme(theme) {
        htmlTag.setAttribute('data-theme', theme);
        htmlTag.setAttribute('data-bs-theme', theme);
        localStorage.setItem('adminTheme', theme);
        if (themeIcon) {
          if (theme === 'dark') {
            themeIcon.className = 'bi bi-sun-fill text-warning';
          } else {
            themeIcon.className = 'bi bi-moon-stars';
          }
        }
      }

      var savedTheme = localStorage.getItem('adminTheme') || 'light';
      applyTheme(savedTheme);

      if (themeToggleBtn) {
        themeToggleBtn.addEventListener('click', function() {
          var current = htmlTag.getAttribute('data-theme') || 'light';
          var next = (current === 'dark') ? 'light' : 'dark';
          applyTheme(next);
        });
      }
    });
  </script>
</body>
</html>
