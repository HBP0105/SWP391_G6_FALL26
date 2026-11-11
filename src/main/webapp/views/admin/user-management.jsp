<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en" data-theme="light" data-bs-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>User & Access Management - Admin Portal</title>

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

  <!-- Early Theme Initialization to prevent white flash -->
  <script>
    (function() {
      const savedTheme = localStorage.getItem('adminTheme') || 'light';
      document.documentElement.setAttribute('data-theme', savedTheme);
      document.documentElement.setAttribute('data-bs-theme', savedTheme);
    })();
  </script>

  <style>
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

    html[data-theme="dark"] body {
      background-color: var(--admin-bg, #0f172a) !important;
      color: var(--admin-text, #e5edf7) !important;
    }
    html[data-theme="dark"] .admin-navbar,
    html[data-theme="dark"] .bg-white {
      background-color: var(--admin-surface, #182235) !important;
      color: var(--admin-text, #e5edf7) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .card {
      background-color: var(--admin-surface, #182235) !important;
      color: var(--admin-text, #e5edf7) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .mini-stat-card {
      background: var(--admin-surface, #182235) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .table {
      color: var(--admin-text, #e5edf7) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .table-light th,
    html[data-theme="dark"] .table-light td {
      background-color: var(--admin-surface-soft, #111827) !important;
      color: #94a3b8 !important;
    }
    html[data-theme="dark"] .form-select,
    html[data-theme="dark"] .form-control {
      background-color: var(--admin-surface, #182235) !important;
      color: var(--admin-text, #e5edf7) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .modal-content {
      background-color: var(--admin-surface, #182235) !important;
      color: var(--admin-text, #e5edf7) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .user-info-banner {
      background: rgba(30, 41, 59, 0.7) !important;
      border-color: rgba(51, 65, 85, 0.8) !important;
    }
  </style>
</head>

<body>
  <div class="admin-shell">
    <div class="sidebar-backdrop" id="sidebarBackdrop"></div>

    <!-- SIDEBAR -->
    <jsp:include page="_sidebar.jsp" />

    <!-- MAIN CONTENT -->
    <div class="admin-main">
      <!-- TOP NAVBAR -->
      <nav class="navbar admin-navbar navbar-expand bg-white">
        <div class="container-fluid px-0">
          <button class="icon-button d-lg-none" id="sidebarToggleBtn" type="button" aria-label="Toggle Sidebar">
            <i class="bi bi-list fs-5"></i>
          </button>

          <span class="navbar-text fw-bold text-dark fs-6 d-none d-sm-inline">
            <i class="bi bi-people-fill text-primary me-2"></i>User Directory & Role Access Control
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
              <h1 class="h4 mb-0 fw-bold text-dark">User & Access Management</h1>
              <p class="text-muted small mb-0">Oversee customer and staff accounts, assign staff privileges, and manage account statuses.</p>
            </div>
            <div>
              <span class="badge bg-light text-dark border px-2.5 py-1.5 fs-7">
                <i class="bi bi-shield-check text-success me-1"></i>Role-Based Access Control (RBAC)
              </span>
            </div>
          </div>

          <!-- FLASH ALERTS -->
          <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-3 py-2" role="alert">
              <i class="bi bi-check-circle-fill me-2"></i><strong>Success: </strong> <c:out value="${successMessage}"/>
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
          </c:if>

          <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-3 py-2" role="alert">
              <i class="bi bi-exclamation-triangle-fill me-2"></i><strong>Error: </strong> <c:out value="${errorMessage}"/>
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
          </c:if>

          <!-- 4 MINI STAT CARDS -->
          <div class="row g-2 mb-3">
            <div class="col-6 col-md-3">
              <div class="mini-stat-card d-flex align-items-center justify-content-between">
                <div>
                  <div class="text-muted extra-small fw-semibold text-uppercase">Total Accounts</div>
                  <div class="h4 fw-bold text-primary mb-0"><fmt:formatNumber value="${stats.totalAccounts}" pattern="#,###"/></div>
                </div>
                <div class="mini-stat-icon bg-icon-primary"><i class="bi bi-people-fill"></i></div>
              </div>
            </div>

            <div class="col-6 col-md-3">
              <div class="mini-stat-card d-flex align-items-center justify-content-between">
                <div>
                  <div class="text-muted extra-small fw-semibold text-uppercase">Customer Accounts</div>
                  <div class="h4 fw-bold text-success mb-0"><fmt:formatNumber value="${stats.totalCustomers}" pattern="#,###"/></div>
                </div>
                <div class="mini-stat-icon bg-icon-success"><i class="bi bi-person-badge"></i></div>
              </div>
            </div>

            <div class="col-6 col-md-3">
              <div class="mini-stat-card d-flex align-items-center justify-content-between">
                <div>
                  <div class="text-muted extra-small fw-semibold text-uppercase">Staff & Admins</div>
                  <div class="h4 fw-bold text-purple mb-0" style="color: #9333ea;"><fmt:formatNumber value="${stats.totalStaff}" pattern="#,###"/></div>
                </div>
                <div class="mini-stat-icon bg-icon-purple"><i class="bi bi-person-gear"></i></div>
              </div>
            </div>

            <div class="col-6 col-md-3">
              <div class="mini-stat-card d-flex align-items-center justify-content-between">
                <div>
                  <div class="text-muted extra-small fw-semibold text-uppercase">Active / Banned</div>
                  <div class="h4 fw-bold text-warning mb-0">
                    <span class="text-success"><fmt:formatNumber value="${stats.totalActive}" pattern="#,###"/></span>
                    <span class="text-muted fs-6">/</span>
                    <span class="text-danger"><fmt:formatNumber value="${stats.totalBanned}" pattern="#,###"/></span>
                  </div>
                </div>
                <div class="mini-stat-icon bg-icon-warning"><i class="bi bi-shield-lock"></i></div>
              </div>
            </div>
          </div>

          <!-- SEARCH & FILTER BAR -->
          <div class="card border-0 shadow-sm p-3 mb-3">
            <form method="get" action="${pageContext.request.contextPath}/admin/users" id="filterForm">
              <div class="row g-2 align-items-end">
                <div class="col-12 col-md-4">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-search me-1 text-primary"></i>Search Keyword:</label>
                  <input type="search" class="form-control form-control-sm" name="keyword" value="<c:out value='${keyword}'/>" placeholder="ID, name, email or phone..." autocomplete="off">
                </div>

                <div class="col-6 col-md-2">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-person-badge me-1 text-primary"></i>Account Type:</label>
                  <select name="userType" class="form-select form-select-sm" onchange="document.getElementById('filterForm').submit();">
                    <option value="ALL" ${selectedUserType == 'ALL' ? 'selected' : ''}>-- All Types --</option>
                    <option value="CUSTOMER" ${selectedUserType == 'CUSTOMER' ? 'selected' : ''}>Customer</option>
                    <option value="STAFF" ${selectedUserType == 'STAFF' ? 'selected' : ''}>Staff</option>
                  </select>
                </div>

                <div class="col-6 col-md-2">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-funnel me-1 text-primary"></i>Status:</label>
                  <select name="status" class="form-select form-select-sm" onchange="document.getElementById('filterForm').submit();">
                    <option value="ALL" ${selectedStatus == 'ALL' ? 'selected' : ''}>-- All Statuses --</option>
                    <option value="ACTIVE" ${selectedStatus == 'ACTIVE' ? 'selected' : ''}>Active</option>
                    <option value="INACTIVE" ${selectedStatus == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                    <option value="BANNED" ${selectedStatus == 'BANNED' ? 'selected' : ''}>Banned</option>
                  </select>
                </div>

                <div class="col-6 col-md-2">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-list-ol me-1 text-primary"></i>Page Size:</label>
                  <select name="pageSize" class="form-select form-select-sm" onchange="document.getElementById('filterForm').submit();">
                    <option value="10" ${pageSize == 10 ? 'selected' : ''}>10 / page</option>
                    <option value="20" ${pageSize == 20 ? 'selected' : ''}>20 / page</option>
                    <option value="50" ${pageSize == 50 ? 'selected' : ''}>50 / page</option>
                  </select>
                </div>

                <div class="col-6 col-md-2 d-flex gap-2">
                  <button type="submit" class="btn btn-primary btn-sm flex-fill fw-bold">
                    <i class="bi bi-funnel-fill me-1"></i> Filter
                  </button>
                  <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary btn-sm" title="Reset Filters">
                    <i class="bi bi-arrow-counterclockwise"></i>
                  </a>
                </div>
              </div>
            </form>
          </div>

          <!-- DATA TABLE CARD -->
          <div class="card border-0 shadow-sm">
            <div class="card-header bg-white d-flex justify-content-between align-items-center py-2.5">
              <span class="fw-bold text-dark fs-7">
                <i class="bi bi-table text-primary me-2"></i>Accounts & Roles Directory
              </span>
              <span class="badge bg-light text-muted border fs-7">
                <fmt:formatNumber value="${totalItems}" pattern="#,###"/> user(s) found
              </span>
            </div>

            <div class="table-responsive">
              <table class="table align-middle mb-0">
                <thead class="table-light fs-7 text-uppercase">
                  <tr>
                    <th style="width: 70px;">ID</th>
                    <th style="width: 100px;">Type</th>
                    <th>User Profile</th>
                    <th>Contact Info</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Created</th>
                    <th class="text-end" style="min-width: 140px;">Action</th>
                  </tr>
                </thead>
                <tbody class="fs-7">
                  <c:forEach var="u" items="${users}">
                    <c:set var="isSelf" value="${u.userType == 'STAFF' && not empty currentAdminId && currentAdminId == u.userId}" />
                    <tr>
                      <td class="text-muted fw-bold">#${u.userId}</td>
                      <td>
                        <c:choose>
                          <c:when test="${u.userType == 'STAFF'}">
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle">
                              <i class="bi bi-person-gear me-1"></i>Staff
                            </span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge bg-light text-secondary border">
                              <i class="bi bi-person me-1"></i>Customer
                            </span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <div class="fw-bold text-dark">
                          <c:out value="${u.fullName}"/>
                          <c:if test="${isSelf}">
                            <span class="badge bg-info-subtle text-info border border-info-subtle ms-1">You</span>
                          </c:if>
                        </div>
                      </td>
                      <td>
                        <div><i class="bi bi-envelope me-1 text-muted"></i><c:out value="${u.email}"/></div>
                        <div class="text-muted extra-small">
                          <i class="bi bi-telephone me-1"></i><c:out value="${empty u.phone ? 'None' : u.phone}"/>
                        </div>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${u.userType == 'STAFF'}">
                            <c:choose>
                              <c:when test="${u.roleName == 'ADMIN'}">
                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle fw-semibold">
                                  <i class="bi bi-shield-fill-check me-1"></i>ADMIN
                                </span>
                              </c:when>
                              <c:otherwise>
                                <span class="badge bg-warning-subtle text-dark border border-warning-subtle fw-semibold">
                                  <i class="bi bi-shield-shaded me-1"></i>MANAGER
                                </span>
                              </c:otherwise>
                            </c:choose>
                          </c:when>
                          <c:otherwise>
                            <span class="badge bg-light text-muted border">Customer</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${u.status == 'ACTIVE'}">
                            <span class="badge bg-success-subtle text-success border border-success-subtle fw-semibold">
                              <i class="bi bi-check-circle-fill me-1"></i>ACTIVE
                            </span>
                          </c:when>
                          <c:when test="${u.status == 'BANNED'}">
                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle fw-semibold">
                              <i class="bi bi-slash-circle-fill me-1"></i>BANNED
                            </span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge bg-secondary-subtle text-secondary border fw-semibold">
                              <i class="bi bi-pause-circle-fill me-1"></i>INACTIVE
                            </span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-muted">
                        <c:choose>
                          <c:when test="${not empty u.createdAt}">
                            <fmt:formatDate value="${u.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                          </c:when>
                          <c:otherwise>-</c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-end">
                        <c:choose>
                          <c:when test="${isSelf}">
                            <span class="badge bg-light text-muted border py-1.5 px-2" title="You cannot modify your own administrative account">
                              <i class="bi bi-lock-fill me-1"></i>Self
                            </span>
                          </c:when>
                          <c:otherwise>
                            <button type="button" class="btn btn-outline-primary btn-sm py-1 px-2.5 fw-medium btn-manage-access"
                                    data-usertype="${u.userType}"
                                    data-userid="${u.userId}"
                                    data-fullname="<c:out value='${u.fullName}'/>"
                                    data-email="<c:out value='${u.email}'/>"
                                    data-roleid="${u.roleId}"
                                    data-rolename="<c:out value='${u.roleName}'/>"
                                    data-status="${u.status}">
                              <i class="bi bi-sliders me-1"></i>Manage Access
                            </button>
                          </c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty users}">
                    <tr>
                      <td colspan="8" class="text-center text-muted py-5">
                        <i class="bi bi-people fs-2 d-block mb-2 text-muted"></i>
                        No user accounts match the selected criteria.
                      </td>
                    </tr>
                  </c:if>
                </tbody>
              </table>
            </div>

            <!-- PAGINATION FOOTER -->
            <div class="card-footer bg-white d-flex flex-wrap justify-content-between align-items-center py-2.5 gap-2">
              <span class="text-muted small">
                Showing page <strong>${currentPage}</strong> of <strong>${totalPages}</strong>
                (<fmt:formatNumber value="${totalItems}" pattern="#,###"/> total accounts)
              </span>

              <div class="btn-group btn-group-sm">
                <c:if test="${currentPage > 1}">
                  <a class="btn btn-outline-secondary"
                     href="?keyword=${keyword}&userType=${selectedUserType}&status=${selectedStatus}&pageSize=${pageSize}&page=${currentPage - 1}">
                    <i class="bi bi-chevron-left"></i> Previous
                  </a>
                </c:if>

                <c:set var="startPage" value="${currentPage - 2 > 1 ? currentPage - 2 : 1}" />
                <c:set var="endPage" value="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}" />
                <c:forEach begin="${startPage}" end="${endPage}" var="p">
                  <a class="btn ${p == currentPage ? 'btn-primary' : 'btn-outline-secondary'}"
                     href="?keyword=${keyword}&userType=${selectedUserType}&status=${selectedStatus}&pageSize=${pageSize}&page=${p}">
                    ${p}
                  </a>
                </c:forEach>

                <c:if test="${currentPage < totalPages}">
                  <a class="btn btn-outline-secondary"
                     href="?keyword=${keyword}&userType=${selectedUserType}&status=${selectedStatus}&pageSize=${pageSize}&page=${currentPage + 1}">
                    Next <i class="bi bi-chevron-right"></i>
                  </a>
                </c:if>
              </div>
            </div>
          </div>

        </div>
      </main>
    </div>
  </div>

  <!-- UNIFIED MANAGE ACCESS MODAL -->
  <div class="modal fade" id="manageAccessModal" tabindex="-1" aria-labelledby="manageAccessModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content border-0 shadow">
        <form method="post" action="${pageContext.request.contextPath}/admin/users">
          <input type="hidden" name="action" value="updateAccess">
          <input type="hidden" name="targetUserType" id="modalTargetUserType">
          <input type="hidden" name="userId" id="modalUserId">

          <!-- Hidden preserved filters for smooth redirect -->
          <input type="hidden" name="keyword" value="<c:out value='${keyword}'/>">
          <input type="hidden" name="userType" value="${selectedUserType}">
          <input type="hidden" name="statusParam" value="${selectedStatus}">
          <input type="hidden" name="page" value="${currentPage}">
          <input type="hidden" name="pageSize" value="${pageSize}">

          <div class="modal-header border-bottom">
            <h5 class="modal-title fw-bold fs-6" id="manageAccessModalLabel">
              <i class="bi bi-shield-lock-fill text-primary me-2"></i>Manage Access & Permissions
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>

          <div class="modal-body p-4">
            <!-- Account Info Summary -->
            <div class="user-info-banner p-3 rounded mb-3 border bg-light">
              <div class="d-flex align-items-center gap-3">
                <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center" style="width: 44px; height: 44px; font-size: 1.25rem;">
                  <i class="bi bi-person-fill"></i>
                </div>
                <div>
                  <div class="fw-bold text-dark fs-6" id="modalFullName"></div>
                  <div class="text-muted small" id="modalEmail"></div>
                  <div class="mt-1" id="modalTypeBadge"></div>
                </div>
              </div>
            </div>

            <!-- Role Control (Shown for Staff) -->
            <div class="mb-3" id="modalRoleContainer">
              <label class="form-label fw-semibold fs-7 mb-1">
                <i class="bi bi-person-gear text-primary me-1"></i>Staff System Role:
              </label>
              <select class="form-select form-select-sm" name="roleId" id="modalRoleId">
                <c:forEach var="r" items="${roles}">
                  <option value="${r.roleId}">${r.roleName}</option>
                </c:forEach>
              </select>
              <div class="form-text extra-small text-muted">
                Admin has full system access. Manager has store management & reporting access.
              </div>
            </div>

            <!-- Customer Note (Shown for Customer) -->
            <div class="mb-3 d-none" id="modalCustomerNote">
              <div class="alert alert-light border py-2 px-3 small text-muted mb-0">
                <i class="bi bi-info-circle me-1 text-primary"></i>Customer accounts do not hold internal staff roles.
              </div>
            </div>

            <!-- Status Control -->
            <div class="mb-3">
              <label class="form-label fw-semibold fs-7 mb-1">
                <i class="bi bi-toggle-on text-primary me-1"></i>Account Status:
              </label>
              <select class="form-select form-select-sm" name="status" id="modalStatus">
                <option value="ACTIVE">ACTIVE - Normal account operations</option>
                <option value="INACTIVE">INACTIVE - Account deactivated</option>
                <option value="BANNED">BANNED - Prohibited from accessing system</option>
              </select>
              <div class="form-text extra-small text-danger">
                Setting status to BANNED immediately restricts account login.
              </div>
            </div>
          </div>

          <div class="modal-footer border-top bg-light">
            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-primary btn-sm fw-bold">
              <i class="bi bi-check2-circle me-1"></i>Save Access Changes
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Bootstrap 5 Bundle JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    document.addEventListener('DOMContentLoaded', function() {
      // Event delegation for Manage Access buttons
      document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-manage-access');
        if (!btn) return;

        var userType = btn.getAttribute('data-usertype') || '';
        var userId = btn.getAttribute('data-userid') || '';
        var fullName = btn.getAttribute('data-fullname') || '';
        var email = btn.getAttribute('data-email') || '';
        var roleId = btn.getAttribute('data-roleid') || '';
        var status = btn.getAttribute('data-status') || 'ACTIVE';

        document.getElementById('modalTargetUserType').value = userType;
        document.getElementById('modalUserId').value = userId;
        document.getElementById('modalFullName').textContent = fullName;
        document.getElementById('modalEmail').textContent = email;

        var typeBadge = document.getElementById('modalTypeBadge');
        var roleContainer = document.getElementById('modalRoleContainer');
        var customerNote = document.getElementById('modalCustomerNote');
        var roleSelect = document.getElementById('modalRoleId');

        if (userType === 'STAFF') {
          typeBadge.innerHTML = '<span class="badge bg-primary-subtle text-primary border border-primary-subtle">Staff Account (ID: #' + userId + ')</span>';
          roleContainer.classList.remove('d-none');
          customerNote.classList.add('d-none');
          if (roleId && roleSelect) {
            roleSelect.value = roleId;
          }
        } else {
          typeBadge.innerHTML = '<span class="badge bg-light text-secondary border">Customer Account (ID: #' + userId + ')</span>';
          roleContainer.classList.add('d-none');
          customerNote.classList.remove('d-none');
        }

        var statusSelect = document.getElementById('modalStatus');
        if (statusSelect && status) {
          statusSelect.value = status;
        }

        var modalEl = document.getElementById('manageAccessModal');
        var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();
      });

      // Sidebar Mobile Toggle
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
