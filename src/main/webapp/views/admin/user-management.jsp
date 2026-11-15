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

    .detail-metric-box {
      border: 1px solid rgba(226, 232, 240, 0.9);
      border-radius: 8px;
      padding: 10px 12px;
      background: #f8fafc;
    }

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
    html[data-theme="dark"] .mini-stat-card,
    html[data-theme="dark"] .detail-metric-box {
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
    html[data-theme="dark"] .modal-footer.bg-light,
    html[data-theme="dark"] .user-info-banner {
      background: rgba(30, 41, 59, 0.7) !important;
      border-color: rgba(51, 65, 85, 0.8) !important;
    }
    html[data-theme="dark"] .text-dark {
      color: #f1f5f9 !important;
    }
  </style>
</head>

<body>
  <c:url var="exportCsvUrl" value="/admin/users">
    <c:param name="action" value="exportCsv"/>
    <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
    <c:if test="${selectedUserType != 'ALL'}"><c:param name="userType" value="${selectedUserType}"/></c:if>
    <c:if test="${selectedRole != 'ALL'}"><c:param name="role" value="${selectedRole}"/></c:if>
    <c:if test="${selectedStatus != 'ALL'}"><c:param name="status" value="${selectedStatus}"/></c:if>
    <c:if test="${selectedSort != 'newest'}"><c:param name="sort" value="${selectedSort}"/></c:if>
  </c:url>

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
            <i class="bi bi-people-fill text-primary me-2"></i>User Directory &amp; Role Access Control
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
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/change-password"><i class="bi bi-key me-2 text-primary"></i>Change Password</a></li>
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
              <h1 class="h4 mb-0 fw-bold text-dark">User &amp; Access Management</h1>
              <p class="text-muted small mb-0">Manage customer &amp; staff directory, inspect account details, create staff, assign roles, and enforce account lock policies.</p>
            </div>
            <div class="d-flex flex-wrap align-items-center gap-2">
              <a href="${exportCsvUrl}" class="btn btn-outline-success btn-sm fw-semibold">
                <i class="bi bi-file-earmark-spreadsheet me-1"></i>Export CSV
              </a>
              <button type="button" class="btn btn-primary btn-sm fw-semibold" data-bs-toggle="modal" data-bs-target="#addStaffModal">
                <i class="bi bi-person-plus-fill me-1"></i>Add Staff
              </button>
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
                  <div class="text-muted extra-small fw-semibold text-uppercase">Staff &amp; Admins</div>
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

          <!-- SEARCH & FILTER BAR (Fixed 10 items/page) -->
          <div class="card border-0 shadow-sm p-3 mb-3">
            <form method="get" action="${pageContext.request.contextPath}/admin/users" id="filterForm">
              <div class="row g-2 align-items-end">
                <div class="col-12 col-md-3">
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
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-shield-check me-1 text-primary"></i>Role:</label>
                  <select name="role" class="form-select form-select-sm" onchange="document.getElementById('filterForm').submit();">
                    <option value="ALL" ${selectedRole == 'ALL' ? 'selected' : ''}>-- All Roles --</option>
                    <option value="ADMIN" ${selectedRole == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                    <option value="MANAGER" ${selectedRole == 'MANAGER' ? 'selected' : ''}>MANAGER</option>
                    <option value="CUSTOMER" ${selectedRole == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                  </select>
                </div>

                <div class="col-6 col-md-2">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-funnel me-1 text-primary"></i>Status:</label>
                  <select name="status" class="form-select form-select-sm" onchange="document.getElementById('filterForm').submit();">
                    <option value="ALL" ${selectedStatus == 'ALL' ? 'selected' : ''}>-- All Statuses --</option>
                    <option value="ACTIVE" ${selectedStatus == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                    <option value="INACTIVE" ${selectedStatus == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                    <option value="BANNED" ${selectedStatus == 'BANNED' ? 'selected' : ''}>BANNED</option>
                  </select>
                </div>

                <div class="col-6 col-md-2">
                  <label class="form-label fw-semibold fs-7 mb-1"><i class="bi bi-sort-down me-1 text-primary"></i>Sort By:</label>
                  <select name="sort" class="form-select form-select-sm" onchange="document.getElementById('filterForm').submit();">
                    <option value="newest" ${selectedSort == 'newest' ? 'selected' : ''}>Newest Created</option>
                    <option value="oldest" ${selectedSort == 'oldest' ? 'selected' : ''}>Oldest Created</option>
                    <option value="name_asc" ${selectedSort == 'name_asc' ? 'selected' : ''}>Name (A - Z)</option>
                    <option value="name_desc" ${selectedSort == 'name_desc' ? 'selected' : ''}>Name (Z - A)</option>
                  </select>
                </div>

                <div class="col-12 col-md-1 d-flex gap-1">
                  <button type="submit" class="btn btn-primary btn-sm flex-fill fw-bold" title="Apply Filters">
                    <i class="bi bi-search"></i>
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
                <i class="bi bi-table text-primary me-2"></i>Accounts &amp; Roles Directory
              </span>
              <span class="badge bg-light text-muted border fs-7">
                <fmt:formatNumber value="${totalItems}" pattern="#,###"/> user(s) found (10 / page)
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
                    <th class="text-end" style="min-width: 205px;">Action</th>
                  </tr>
                </thead>
                <tbody class="fs-7">
                  <c:forEach var="u" items="${users}">
                    <c:set var="isSelf" value="${u.userType == 'STAFF' && not empty currentAdminId && currentAdminId == u.userId}" />
                    <c:set var="isPeerAdmin" value="${!isSelf && u.userType == 'STAFF' && u.roleName == 'ADMIN'}" />
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
                            <fmt:formatDate value="${u.createdAt}" pattern="HH:mm:ss dd/MM/yyyy"/>
                          </c:when>
                          <c:otherwise>-</c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-end">
                        <div class="d-inline-flex align-items-center gap-1">
                          <c:url var="detailUrl" value="/admin/users">
                            <c:param name="action" value="detail"/>
                            <c:param name="detailUserType" value="${u.userType}"/>
                            <c:param name="detailUserId" value="${u.userId}"/>
                            <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                            <c:if test="${selectedUserType != 'ALL'}"><c:param name="userType" value="${selectedUserType}"/></c:if>
                            <c:if test="${selectedRole != 'ALL'}"><c:param name="role" value="${selectedRole}"/></c:if>
                            <c:if test="${selectedStatus != 'ALL'}"><c:param name="status" value="${selectedStatus}"/></c:if>
                            <c:if test="${selectedSort != 'newest'}"><c:param name="sort" value="${selectedSort}"/></c:if>
                            <c:if test="${currentPage > 1}"><c:param name="page" value="${currentPage}"/></c:if>
                          </c:url>
                          <a href="${detailUrl}" class="btn btn-outline-secondary btn-sm py-1 px-2" title="View Account Details">
                            <i class="bi bi-eye"></i>
                          </a>

                          <c:choose>
                            <c:when test="${isSelf}">
                              <a href="${pageContext.request.contextPath}/admin/change-password"
                                 class="btn btn-outline-info btn-sm py-1 px-2" title="Change Your Password">
                                <i class="bi bi-key"></i>
                              </a>
                              <span class="badge bg-light text-muted border py-1.5 px-2" title="You cannot lock or demote your own administrative account">
                                <i class="bi bi-lock-fill me-1"></i>Self
                              </span>
                            </c:when>
                            <c:when test="${isPeerAdmin}">
                              <span class="badge bg-light text-muted border py-1.5 px-2" title="Administrator accounts cannot be modified by peers">
                                <i class="bi bi-shield-lock-fill me-1"></i>Protected
                              </span>
                            </c:when>
                            <c:otherwise>
                              <c:if test="${u.userType == 'STAFF'}">
                                <button type="button" class="btn btn-outline-warning btn-sm py-1 px-2 btn-edit-staff"
                                        data-staffid="${u.userId}"
                                        data-fullname="<c:out value='${u.fullName}'/>"
                                        data-email="<c:out value='${u.email}'/>"
                                        data-phone="<c:out value='${u.phone}'/>"
                                        title="Edit Staff Info / Reset Password">
                                  <i class="bi bi-pencil-square"></i>
                                </button>
                              </c:if>
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
                        </div>
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

            <!-- PAGINATION FOOTER (URL-encoded properly via c:url) -->
            <div class="card-footer bg-white d-flex flex-wrap justify-content-between align-items-center py-2.5 gap-2">
              <span class="text-muted small">
                Showing page <strong>${currentPage}</strong> of <strong>${totalPages}</strong>
                (<fmt:formatNumber value="${totalItems}" pattern="#,###"/> total accounts)
              </span>

              <div class="btn-group btn-group-sm">
                <c:if test="${currentPage > 1}">
                  <c:url var="prevUrl" value="/admin/users">
                    <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                    <c:if test="${selectedUserType != 'ALL'}"><c:param name="userType" value="${selectedUserType}"/></c:if>
                    <c:if test="${selectedRole != 'ALL'}"><c:param name="role" value="${selectedRole}"/></c:if>
                    <c:if test="${selectedStatus != 'ALL'}"><c:param name="status" value="${selectedStatus}"/></c:if>
                    <c:if test="${selectedSort != 'newest'}"><c:param name="sort" value="${selectedSort}"/></c:if>
                    <c:param name="page" value="${currentPage - 1}"/>
                  </c:url>
                  <a class="btn btn-outline-secondary" href="${prevUrl}">
                    <i class="bi bi-chevron-left"></i> Previous
                  </a>
                </c:if>

                <c:set var="startPage" value="${currentPage - 2 > 1 ? currentPage - 2 : 1}" />
                <c:set var="endPage" value="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}" />
                <c:forEach begin="${startPage}" end="${endPage}" var="p">
                  <c:url var="pageUrl" value="/admin/users">
                    <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                    <c:if test="${selectedUserType != 'ALL'}"><c:param name="userType" value="${selectedUserType}"/></c:if>
                    <c:if test="${selectedRole != 'ALL'}"><c:param name="role" value="${selectedRole}"/></c:if>
                    <c:if test="${selectedStatus != 'ALL'}"><c:param name="status" value="${selectedStatus}"/></c:if>
                    <c:if test="${selectedSort != 'newest'}"><c:param name="sort" value="${selectedSort}"/></c:if>
                    <c:param name="page" value="${p}"/>
                  </c:url>
                  <a class="btn ${p == currentPage ? 'btn-primary' : 'btn-outline-secondary'}" href="${pageUrl}">
                    ${p}
                  </a>
                </c:forEach>

                <c:if test="${currentPage < totalPages}">
                  <c:url var="nextUrl" value="/admin/users">
                    <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                    <c:if test="${selectedUserType != 'ALL'}"><c:param name="userType" value="${selectedUserType}"/></c:if>
                    <c:if test="${selectedRole != 'ALL'}"><c:param name="role" value="${selectedRole}"/></c:if>
                    <c:if test="${selectedStatus != 'ALL'}"><c:param name="status" value="${selectedStatus}"/></c:if>
                    <c:if test="${selectedSort != 'newest'}"><c:param name="sort" value="${selectedSort}"/></c:if>
                    <c:param name="page" value="${currentPage + 1}"/>
                  </c:url>
                  <a class="btn btn-outline-secondary" href="${nextUrl}">
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

  <!-- 1. UNIFIED MANAGE ACCESS MODAL -->
  <div class="modal fade" id="manageAccessModal" tabindex="-1" aria-labelledby="manageAccessModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content border-0 shadow">
        <form method="post" action="${pageContext.request.contextPath}/admin/users" id="manageAccessForm" novalidate>
          <input type="hidden" name="action" value="updateAccess">
          <input type="hidden" name="targetUserType" id="modalTargetUserType">
          <input type="hidden" name="userId" id="modalUserId">
          <input type="hidden" id="modalOriginalStatus">

          <!-- Hidden preserved filters for smooth redirect -->
          <input type="hidden" name="keyword" value="<c:out value='${keyword}'/>">
          <input type="hidden" name="userType" value="${selectedUserType}">
          <input type="hidden" name="roleParam" value="${selectedRole}">
          <input type="hidden" name="statusParam" value="${selectedStatus}">
          <input type="hidden" name="sort" value="${selectedSort}">
          <input type="hidden" name="page" value="${currentPage}">

          <div class="modal-header border-bottom">
            <h5 class="modal-title fw-bold fs-6" id="manageAccessModalLabel">
              <i class="bi bi-shield-lock-fill text-primary me-2"></i>Manage Access &amp; Permissions
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>

          <div class="modal-body p-4">
            <div class="alert alert-danger py-2 px-3 small d-none modal-inline-error mb-3" role="alert"></div>
            <c:if test="${modalAction == 'updateAccess' && not empty modalError}">
              <div class="alert alert-danger py-2 px-3 small mb-3" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-1"></i><c:out value="${modalError}"/>
              </div>
            </c:if>
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
              <div class="invalid-feedback"></div>
              <div class="form-text extra-small text-muted">
                Admin has full system access. Manager has store management &amp; reporting access.
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
                <option value="INACTIVE">INACTIVE - Account temporarily deactivated</option>
                <option value="BANNED">BANNED - Permanently prohibited from system</option>
              </select>
              <div class="invalid-feedback"></div>
            </div>

            <!-- Ban Warning Alert -->
            <div class="alert alert-danger py-2 px-3 small d-none mb-3" id="modalBanWarning">
              <i class="bi bi-exclamation-octagon-fill me-1"></i>
              <strong>Immediate Lockout:</strong> Banning this account invalidates any active session immediately and blocks future logins.
            </div>

            <!-- Reason / Audit Note -->
            <div class="mb-0">
              <label class="form-label fw-semibold fs-7 mb-1">
                <i class="bi bi-journal-text text-primary me-1"></i>Reason / Audit Note
                <span class="text-danger d-none" id="modalReasonRequired">*</span>
                <span class="text-muted fw-normal small" id="modalReasonOptional">(Optional)</span>:
              </label>
              <textarea class="form-control form-control-sm" name="reason" id="modalReason" rows="2" maxlength="250"
                        placeholder="Enter reason for status or role change (recorded in Audit Logs)..."></textarea>
              <div class="invalid-feedback"></div>
            </div>
          </div>

          <div class="modal-footer border-top bg-light">
            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-primary btn-sm fw-bold" id="modalSaveBtn">
              <i class="bi bi-check2-circle me-1"></i>Save Access Changes
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- 2. USER DETAIL MODAL -->
  <div class="modal fade" id="userDetailModal" tabindex="-1" aria-labelledby="userDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content border-0 shadow">
        <div class="modal-header border-bottom">
          <h5 class="modal-title fw-bold fs-6" id="userDetailModalLabel">
            <i class="bi bi-person-vcard-fill text-primary me-2"></i>Account Profile &amp; Activity Summary
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body p-4" id="userDetailBody">
          <c:if test="${not empty userDetail}">
            <div class="user-info-banner p-3 rounded mb-3 border bg-light">
              <div class="d-flex justify-content-between align-items-start gap-2">
                <div>
                  <div class="fw-bold text-dark fs-6">
                    <c:out value="${userDetail.fullName}"/>
                    <span class="text-muted fw-normal small">#${userDetail.userId}</span>
                  </div>
                  <div class="text-muted small"><i class="bi bi-envelope me-1"></i><c:out value="${userDetail.email}"/></div>
                  <div class="text-muted small">
                    <i class="bi bi-telephone me-1"></i>
                    <c:out value="${not empty userDetail.phone ? userDetail.phone : 'None'}"/>
                  </div>
                </div>
                <div class="text-end">
                  <div>
                    <c:choose>
                      <c:when test="${userDetail.status == 'ACTIVE'}">
                        <span class="badge bg-success-subtle text-success border border-success-subtle">ACTIVE</span>
                      </c:when>
                      <c:when test="${userDetail.status == 'BANNED'}">
                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle">BANNED</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge bg-secondary">${userDetail.status}</span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <div class="mt-1">
                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle">${userDetail.roleName}</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="row g-2 mb-3 small">
              <div class="col-6">
                <div class="detail-metric-box">
                  <div class="text-muted extra-small">Created At</div>
                  <div class="fw-semibold">
                    <c:choose>
                      <c:when test="${not empty userDetail.createdAt}">
                        <fmt:formatDate value="${userDetail.createdAt}" pattern="HH:mm:ss dd/MM/yyyy"/>
                      </c:when>
                      <c:otherwise>-</c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </div>
              <div class="col-6">
                <div class="detail-metric-box">
                  <div class="text-muted extra-small">Last Updated</div>
                  <div class="fw-semibold">
                    <c:choose>
                      <c:when test="${not empty userDetail.updatedAt}">
                        <fmt:formatDate value="${userDetail.updatedAt}" pattern="HH:mm:ss dd/MM/yyyy"/>
                      </c:when>
                      <c:otherwise>Never</c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </div>
            </div>

            <c:choose>
              <c:when test="${userDetail.userType == 'CUSTOMER'}">
                <div class="fw-semibold small text-uppercase text-muted mb-2">Customer Order Summary</div>
                <div class="row g-2 small">
                  <div class="col-6">
                    <div class="detail-metric-box">
                      <div class="text-muted extra-small">Total Orders</div>
                      <div class="fw-bold fs-6 text-primary">${userDetail.totalOrders != null ? userDetail.totalOrders : 0}</div>
                    </div>
                  </div>
                  <div class="col-6">
                    <div class="detail-metric-box">
                      <div class="text-muted extra-small">Delivered Spend</div>
                      <div class="fw-bold fs-6 text-success">
                        <fmt:formatNumber value="${userDetail.totalSpent != null ? userDetail.totalSpent : 0}" pattern="#,##0"/> VND
                      </div>
                    </div>
                  </div>
                  <div class="col-6">
                    <div class="detail-metric-box">
                      <div class="text-muted extra-small">Delivered / Cancelled</div>
                      <div class="fw-semibold">
                        ${userDetail.deliveredOrders != null ? userDetail.deliveredOrders : 0} /
                        <span class="text-danger">${userDetail.cancelledOrders != null ? userDetail.cancelledOrders : 0}</span>
                      </div>
                    </div>
                  </div>
                  <div class="col-6">
                    <div class="detail-metric-box">
                      <div class="text-muted extra-small">Last Order Date</div>
                      <div class="fw-semibold">
                        <c:choose>
                          <c:when test="${not empty userDetail.lastOrderDate}">
                            <fmt:formatDate value="${userDetail.lastOrderDate}" pattern="HH:mm:ss dd/MM/yyyy"/>
                          </c:when>
                          <c:otherwise>No orders yet</c:otherwise>
                        </c:choose>
                      </div>
                    </div>
                  </div>
                </div>
              </c:when>
              <c:otherwise>
                <div class="fw-semibold small text-uppercase text-muted mb-2">Staff Audit Activity</div>
                <div class="row g-2 small">
                  <div class="col-6">
                    <div class="detail-metric-box">
                      <div class="text-muted extra-small">Recorded Audit Actions</div>
                      <div class="fw-bold fs-6 text-primary">${userDetail.totalAuditActions != null ? userDetail.totalAuditActions : 0}</div>
                    </div>
                  </div>
                  <div class="col-6">
                    <div class="detail-metric-box">
                      <div class="text-muted extra-small">Last Audit Activity</div>
                      <div class="fw-semibold">
                        <c:choose>
                          <c:when test="${not empty userDetail.lastAuditAt}">
                            <fmt:formatDate value="${userDetail.lastAuditAt}" pattern="HH:mm:ss dd/MM/yyyy"/>
                          </c:when>
                          <c:otherwise>No activity yet</c:otherwise>
                        </c:choose>
                      </div>
                    </div>
                  </div>
                </div>
              </c:otherwise>
            </c:choose>

            <div class="fw-semibold small text-uppercase text-muted mt-3 mb-2">Latest Administrative Change</div>
            <c:choose>
              <c:when test="${not empty userDetail.lastChangeAction}">
                <div class="detail-metric-box small">
                  <div class="d-flex justify-content-between align-items-center mb-1">
                    <span class="badge bg-info-subtle text-info border border-info-subtle"><c:out value="${userDetail.lastChangeAction}"/></span>
                    <span class="text-muted extra-small">
                      <c:if test="${not empty userDetail.lastChangeAt}">
                        <fmt:formatDate value="${userDetail.lastChangeAt}" pattern="HH:mm:ss dd/MM/yyyy"/>
                      </c:if>
                    </span>
                  </div>
                  <div class="mb-1">
                    <strong>By:</strong>
                    <c:out value="${not empty userDetail.lastChangedByName ? userDetail.lastChangedByName : 'System'}"/>
                    <c:if test="${not empty userDetail.lastChangedByEmail}">
                      <span class="text-muted">(<c:out value="${userDetail.lastChangedByEmail}"/>)</span>
                    </c:if>
                  </div>
                  <c:if test="${not empty userDetail.lastChangeOldData}">
                    <div class="mb-1"><strong>Before:</strong> <code><c:out value="${userDetail.lastChangeOldData}"/></code></div>
                  </c:if>
                  <c:if test="${not empty userDetail.lastChangeNewData}">
                    <div class="mb-0"><strong>After:</strong> <code><c:out value="${userDetail.lastChangeNewData}"/></code></div>
                  </c:if>
                </div>
              </c:when>
              <c:otherwise>
                <div class="detail-metric-box small text-muted">No administrative access or status changes recorded yet.</div>
              </c:otherwise>
            </c:choose>
          </c:if>
        </div>

        <div class="modal-footer border-top bg-light">
          <c:if test="${not empty userDetail and userDetail.userType == 'STAFF'}">
            <c:url var="staffAuditUrl" value="/admin/audit-logs">
              <c:param name="keyword" value="${not empty userDetail.email ? userDetail.email : userDetail.fullName}"/>
            </c:url>
            <a href="${staffAuditUrl}" class="btn btn-outline-primary btn-sm">
              <i class="bi bi-clock-history me-1"></i>View Staff Audit Logs
            </a>
          </c:if>
          <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
        </div>
      </div>
    </div>
  </div>

  <!-- 3. ADD STAFF MODAL -->
  <div class="modal fade" id="addStaffModal" tabindex="-1" aria-labelledby="addStaffModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content border-0 shadow">
        <form method="post" action="${pageContext.request.contextPath}/admin/users" id="addStaffForm" novalidate>
          <input type="hidden" name="action" value="createStaff">

          <div class="modal-header border-bottom">
            <h5 class="modal-title fw-bold fs-6" id="addStaffModalLabel">
              <i class="bi bi-person-plus-fill text-primary me-2"></i>Create New Staff Account
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>

          <div class="modal-body p-4">
            <div class="alert alert-danger py-2 px-3 small d-none modal-inline-error mb-3" role="alert"></div>
            <c:if test="${modalAction == 'createStaff' && not empty modalError}">
              <div class="alert alert-danger py-2 px-3 small mb-3" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-1"></i><c:out value="${modalError}"/>
              </div>
            </c:if>
            <div class="mb-3">
              <label class="form-label fw-semibold fs-7 mb-1">Full Name <span class="text-danger">*</span></label>
              <input type="text" class="form-control form-control-sm" name="fullName" required maxlength="100" placeholder="e.g., Nguyen Van A" value="<c:out value='${modalAction == "createStaff" ? modalFullName : ""}'/>">
              <div class="invalid-feedback"></div>
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold fs-7 mb-1">Email Address <span class="text-danger">*</span></label>
              <input type="email" class="form-control form-control-sm" name="email" required maxlength="150" placeholder="staff@headphonestore.com" value="<c:out value='${modalAction == "createStaff" ? modalEmail : ""}'/>">
              <div class="invalid-feedback"></div>
            </div>

            <div class="row g-2 mb-3">
              <div class="col-6">
                <label class="form-label fw-semibold fs-7 mb-1">Phone Number</label>
                <input type="text" class="form-control form-control-sm" name="phone" maxlength="20" placeholder="09xxxxxxxx" value="<c:out value='${modalAction == "createStaff" ? modalPhone : ""}'/>">
                <div class="invalid-feedback"></div>
              </div>
              <div class="col-6">
                <label class="form-label fw-semibold fs-7 mb-1">Initial Password <span class="text-danger">*</span></label>
                <input type="password" class="form-control form-control-sm" name="password" required minlength="6" placeholder="Min 6 characters">
                <div class="invalid-feedback"></div>
              </div>
            </div>

            <div class="row g-2">
              <div class="col-6">
                <label class="form-label fw-semibold fs-7 mb-1">System Role <span class="text-danger">*</span></label>
                <select class="form-select form-select-sm" name="roleId" required>
                  <c:forEach var="r" items="${roles}">
                    <option value="${r.roleId}" ${(modalAction == 'createStaff' && modalRoleId == r.roleId) || (modalAction != 'createStaff' && r.roleName == 'MANAGER') ? 'selected' : ''}>${r.roleName}</option>
                  </c:forEach>
                </select>
                <div class="invalid-feedback"></div>
              </div>
              <div class="col-6">
                <label class="form-label fw-semibold fs-7 mb-1">Initial Status <span class="text-danger">*</span></label>
                <select class="form-select form-select-sm" name="status" required>
                  <option value="ACTIVE" ${modalAction == 'createStaff' && modalStatus == 'INACTIVE' ? '' : 'selected'}>ACTIVE</option>
                  <option value="INACTIVE" ${modalAction == 'createStaff' && modalStatus == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                </select>
                <div class="invalid-feedback"></div>
              </div>
            </div>
          </div>

          <div class="modal-footer border-top bg-light">
            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-primary btn-sm fw-bold">
              <i class="bi bi-plus-circle me-1"></i>Create Staff Account
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- 4. EDIT STAFF INFO & RESET PASSWORD MODAL -->
  <div class="modal fade" id="editStaffModal" tabindex="-1" aria-labelledby="editStaffModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content border-0 shadow">
        <div class="modal-header border-bottom">
          <h5 class="modal-title fw-bold fs-6" id="editStaffModalLabel">
            <i class="bi bi-pencil-square text-warning me-2"></i>Update Staff Account
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body p-4">
          <div class="user-info-banner p-2.5 rounded mb-3 border bg-light">
            <div class="fw-bold text-dark fs-7" id="editStaffBannerTitle"></div>
            <div class="text-muted extra-small" id="editStaffBannerEmail"></div>
          </div>

          <ul class="nav nav-tabs nav-fill mb-3 small" id="editStaffTabs" role="tablist">
            <li class="nav-item" role="presentation">
              <button class="nav-link active fw-semibold" id="tab-edit-info" data-bs-toggle="tab"
                      data-bs-target="#pane-edit-info" type="button" role="tab">
                <i class="bi bi-person-lines-fill me-1"></i>Edit Profile Info
              </button>
            </li>
            <li class="nav-item" role="presentation">
              <button class="nav-link fw-semibold" id="tab-reset-pw" data-bs-toggle="tab"
                      data-bs-target="#pane-reset-pw" type="button" role="tab">
                <i class="bi bi-key-fill me-1"></i>Reset Password
              </button>
            </li>
          </ul>

          <div class="tab-content">
            <!-- Tab 1: Edit Profile Info -->
            <div class="tab-pane fade show active" id="pane-edit-info" role="tabpanel">
              <form method="post" action="${pageContext.request.contextPath}/admin/users" id="editStaffInfoForm" novalidate>
                <input type="hidden" name="action" value="updateStaffInfo">
                <input type="hidden" name="staffId" id="editInfoStaffId" value="<c:out value='${modalAction == "updateStaffInfo" ? modalStaffId : ""}'/>">
                <input type="hidden" name="keyword" value="<c:out value='${keyword}'/>">
                <input type="hidden" name="userType" value="${selectedUserType}">
                <input type="hidden" name="roleParam" value="${selectedRole}">
                <input type="hidden" name="statusParam" value="${selectedStatus}">
                <input type="hidden" name="sort" value="${selectedSort}">
                <input type="hidden" name="page" value="${currentPage}">

                <div class="alert alert-danger py-2 px-3 small d-none modal-inline-error mb-3" role="alert"></div>
                <c:if test="${modalAction == 'updateStaffInfo' && not empty modalError}">
                  <div class="alert alert-danger py-2 px-3 small mb-3" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-1"></i><c:out value="${modalError}"/>
                  </div>
                </c:if>

                <div class="mb-3">
                  <label class="form-label fw-semibold fs-7 mb-1">Full Name <span class="text-danger">*</span></label>
                  <input type="text" class="form-control form-control-sm" name="fullName" id="editStaffFullName" required maxlength="100" value="<c:out value='${modalAction == "updateStaffInfo" ? modalFullName : ""}'/>">
                  <div class="invalid-feedback"></div>
                </div>

                <div class="mb-3">
                  <label class="form-label fw-semibold fs-7 mb-1">Phone Number</label>
                  <input type="text" class="form-control form-control-sm" name="phone" id="editStaffPhone" maxlength="20" placeholder="09xxxxxxxx" value="<c:out value='${modalAction == "updateStaffInfo" ? modalPhone : ""}'/>">
                  <div class="invalid-feedback"></div>
                </div>

                <div class="d-flex justify-content-end gap-2 pt-2 border-top">
                  <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                  <button type="submit" class="btn btn-primary btn-sm fw-bold">
                    <i class="bi bi-save me-1"></i>Save Profile Info
                  </button>
                </div>
              </form>
            </div>

            <!-- Tab 2: Reset Password -->
            <div class="tab-pane fade" id="pane-reset-pw" role="tabpanel">
              <form method="post" action="${pageContext.request.contextPath}/admin/users" id="resetPasswordForm" novalidate>
                <input type="hidden" name="action" value="resetPassword">
                <input type="hidden" name="staffId" id="resetPwStaffId" value="<c:out value='${modalAction == "resetPassword" ? modalStaffId : ""}'/>">
                <input type="hidden" name="keyword" value="<c:out value='${keyword}'/>">
                <input type="hidden" name="userType" value="${selectedUserType}">
                <input type="hidden" name="roleParam" value="${selectedRole}">
                <input type="hidden" name="statusParam" value="${selectedStatus}">
                <input type="hidden" name="sort" value="${selectedSort}">
                <input type="hidden" name="page" value="${currentPage}">

                <div class="alert alert-danger py-2 px-3 small d-none modal-inline-error mb-3" role="alert"></div>
                <c:if test="${modalAction == 'resetPassword' && not empty modalError}">
                  <div class="alert alert-danger py-2 px-3 small mb-3" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-1"></i><c:out value="${modalError}"/>
                  </div>
                </c:if>

                <div class="alert alert-warning py-2 px-3 small mb-3">
                  <i class="bi bi-shield-exclamation me-1"></i>
                  Resetting password updates the staff login credential immediately and records an entry in Audit Logs.
                </div>

                <div class="mb-3">
                  <label class="form-label fw-semibold fs-7 mb-1">New Password <span class="text-danger">*</span></label>
                  <input type="password" class="form-control form-control-sm" name="newPassword" id="resetNewPassword" required minlength="6" placeholder="Min 6 characters">
                  <div class="invalid-feedback"></div>
                </div>

                <div class="mb-3">
                  <label class="form-label fw-semibold fs-7 mb-1">Confirm New Password <span class="text-danger">*</span></label>
                  <input type="password" class="form-control form-control-sm" name="confirmPassword" id="resetConfirmPassword" required minlength="6" placeholder="Re-enter password">
                  <div class="invalid-feedback">Passwords do not match.</div>
                </div>

                <div class="d-flex justify-content-end gap-2 pt-2 border-top">
                  <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                  <button type="submit" class="btn btn-warning btn-sm fw-bold text-dark">
                    <i class="bi bi-key-fill me-1"></i>Reset Password
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Bootstrap 5 Bundle JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    document.addEventListener('DOMContentLoaded', function() {
      function escapeHtml(value) {
        if (value === null || value === undefined) return '';
        return String(value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;')
          .replace(/'/g, '&#39;');
      }

      function updateBanWarningUi() {
        var statusSelect = document.getElementById('modalStatus');
        var originalStatus = document.getElementById('modalOriginalStatus').value;
        var banWarning = document.getElementById('modalBanWarning');
        var reasonInput = document.getElementById('modalReason');
        var reqStar = document.getElementById('modalReasonRequired');
        var optLabel = document.getElementById('modalReasonOptional');
        var saveBtn = document.getElementById('modalSaveBtn');

        var isSwitchingToBanned = statusSelect.value === 'BANNED' && originalStatus !== 'BANNED';
        banWarning.classList.toggle('d-none', statusSelect.value !== 'BANNED');
        reqStar.classList.toggle('d-none', !isSwitchingToBanned);
        optLabel.classList.toggle('d-none', isSwitchingToBanned);
        reasonInput.required = isSwitchingToBanned;

        if (statusSelect.value === 'BANNED') {
          saveBtn.classList.remove('btn-primary');
          saveBtn.classList.add('btn-danger');
        } else {
          saveBtn.classList.remove('btn-danger');
          saveBtn.classList.add('btn-primary');
        }
      }

      var modalStatusEl = document.getElementById('modalStatus');
      if (modalStatusEl) {
        modalStatusEl.addEventListener('change', updateBanWarningUi);
      }

      var EMAIL_REGEX = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
      var PHONE_REGEX = /^[0-9+\-\s().]{7,20}$/;

      function findFeedbackEl(input) {
        if (!input || !input.parentElement) return null;
        return input.parentElement.querySelector('.invalid-feedback');
      }

      function clearFieldError(input) {
        if (!input) return;
        input.classList.remove('is-invalid');
        var fb = findFeedbackEl(input);
        if (fb) fb.textContent = '';
      }

      function clearFormErrors(form) {
        if (!form) return;
        form.querySelectorAll('.is-invalid').forEach(function(el) {
          el.classList.remove('is-invalid');
        });
        form.querySelectorAll('.invalid-feedback').forEach(function(fb) {
          fb.textContent = '';
        });
        var box = form.querySelector('.modal-inline-error');
        if (box) {
          box.classList.add('d-none');
          box.textContent = '';
        }
      }

      function showFormError(form, fieldName, message) {
        if (!form) return;
        if (fieldName) {
          var target = form.querySelector('[name="' + fieldName + '"]');
          if (target && target.offsetParent !== null) {
            target.classList.add('is-invalid');
            var fb = findFeedbackEl(target);
            if (fb) {
              fb.textContent = message;
            }
            target.focus();
            return;
          }
        }
        var box = form.querySelector('.modal-inline-error');
        if (box) {
          box.textContent = message;
          box.classList.remove('d-none');
        }
      }

      function getFieldValidationError(form, input) {
        if (!input || !input.name) return null;
        var val = input.value ? input.value.trim() : '';
        switch (input.name) {
          case 'fullName':
            if (!val) return 'Full name is required.';
            if (val.length > 100) return 'Full name must be at most 100 characters.';
            return null;
          case 'email':
            if (!val) return 'Email address is required.';
            if (val.length > 150 || !EMAIL_REGEX.test(val)) return 'Please enter a valid email address.';
            return null;
          case 'phone':
            if (val && !PHONE_REGEX.test(val)) return 'Phone number format is invalid (7-20 digits/characters).';
            return null;
          case 'password':
            if (!val || val.length < 6) return 'Initial password must be at least 6 characters.';
            return null;
          case 'newPassword':
            if (!val || val.length < 6) return 'New password must be at least 6 characters.';
            return null;
          case 'confirmPassword':
            var pwEl = form.querySelector('[name="newPassword"]');
            var pwVal = pwEl && pwEl.value ? pwEl.value.trim() : '';
            if (!val) return 'Please confirm the new password.';
            if (val !== pwVal) return 'Confirm password does not match.';
            return null;
          case 'reason':
            if (form.id === 'manageAccessForm') {
              var orig = document.getElementById('modalOriginalStatus').value;
              var nextStatus = document.getElementById('modalStatus').value;
              if (nextStatus === 'BANNED' && orig !== 'BANNED' && !val) {
                return 'Please provide a reason when banning an account.';
              }
            }
            return null;
          default:
            return null;
        }
      }

      function bindModalForm(formId, beforeSubmit) {
        var form = document.getElementById(formId);
        if (!form) return;

        form.addEventListener('input', function(e) {
          if (e.target && e.target.name) {
            clearFieldError(e.target);
          }
          var box = form.querySelector('.modal-inline-error');
          if (box) {
            box.classList.add('d-none');
            box.textContent = '';
          }
        });

        form.addEventListener('change', function(e) {
          if (e.target && e.target.name) {
            clearFieldError(e.target);
          }
          var box = form.querySelector('.modal-inline-error');
          if (box) {
            box.classList.add('d-none');
            box.textContent = '';
          }
        });

        form.addEventListener('focusout', function(e) {
          var target = e.target;
          if (!target || !target.name || target.offsetParent === null) return;
          if (target.name === 'fullName' || target.name === 'email' || target.name === 'phone'
              || target.name === 'password' || target.name === 'newPassword' || target.name === 'confirmPassword') {
            var err = getFieldValidationError(form, target);
            if (err) {
              target.classList.add('is-invalid');
              var fb = findFeedbackEl(target);
              if (fb) fb.textContent = err;
            }
          }
        });

        form.addEventListener('submit', function(e) {
          clearFormErrors(form);

          var inputs = form.querySelectorAll('input[name], select[name], textarea[name]');
          for (var i = 0; i < inputs.length; i++) {
            var input = inputs[i];
            if (input.type === 'hidden' || input.offsetParent === null) continue;
            var err = getFieldValidationError(form, input);
            if (err) {
              e.preventDefault();
              showFormError(form, input.name, err);
              return;
            }
          }

          if (typeof beforeSubmit === 'function' && beforeSubmit(form) === false) {
            e.preventDefault();
            return;
          }

          var submitBtn = form.querySelector('button[type="submit"]');
          if (submitBtn) {
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Saving...';
          }
        });
      }

      bindModalForm('manageAccessForm', function() {
        var originalStatus = document.getElementById('modalOriginalStatus').value;
        var newStatus = document.getElementById('modalStatus').value;
        var fullName = document.getElementById('modalFullName').textContent;
        if (newStatus === 'BANNED' && originalStatus !== 'BANNED') {
          return confirm('Confirm banning account "' + fullName + '"? Active sessions will be invalidated immediately.');
        }
        return true;
      });

      bindModalForm('addStaffForm');
      bindModalForm('editStaffInfoForm');
      bindModalForm('resetPasswordForm', function() {
        var title = document.getElementById('editStaffBannerTitle').textContent;
        return confirm('Reset password for ' + title + '?');
      });

      var addStaffModalEl = document.getElementById('addStaffModal');
      if (addStaffModalEl) {
        addStaffModalEl.addEventListener('show.bs.modal', function() {
          clearFormErrors(document.getElementById('addStaffForm'));
        });
      }
      document.querySelectorAll('#editStaffTabs button[data-bs-toggle="tab"]').forEach(function(tabBtn) {
        tabBtn.addEventListener('shown.bs.tab', function() {
          clearFormErrors(document.getElementById('editStaffInfoForm'));
          clearFormErrors(document.getElementById('resetPasswordForm'));
        });
      });

      // Event delegation for Edit Staff, Manage Access & View Detail buttons
      document.addEventListener('click', function(e) {
        var editBtn = e.target.closest('.btn-edit-staff');
        if (editBtn) {
          var sId = editBtn.getAttribute('data-staffid') || '';
          var sName = editBtn.getAttribute('data-fullname') || '';
          var sEmail = editBtn.getAttribute('data-email') || '';
          var sPhone = editBtn.getAttribute('data-phone') || '';

          document.getElementById('editInfoStaffId').value = sId;
          document.getElementById('resetPwStaffId').value = sId;
          document.getElementById('editStaffBannerTitle').textContent = sName + ' (Staff #' + sId + ')';
          document.getElementById('editStaffBannerEmail').textContent = sEmail;
          document.getElementById('editStaffFullName').value = sName;
          document.getElementById('editStaffPhone').value = sPhone;
          document.getElementById('resetNewPassword').value = '';
          document.getElementById('resetConfirmPassword').value = '';
          clearFormErrors(document.getElementById('editStaffInfoForm'));
          clearFormErrors(document.getElementById('resetPasswordForm'));

          bootstrap.Tab.getOrCreateInstance(document.getElementById('tab-edit-info')).show();
          bootstrap.Modal.getOrCreateInstance(document.getElementById('editStaffModal')).show();
          return;
        }

        var manageBtn = e.target.closest('.btn-manage-access');
        if (manageBtn) {
          var userType = manageBtn.getAttribute('data-usertype') || '';
          var userId = manageBtn.getAttribute('data-userid') || '';
          var fullName = manageBtn.getAttribute('data-fullname') || '';
          var email = manageBtn.getAttribute('data-email') || '';
          var roleId = manageBtn.getAttribute('data-roleid') || '';
          var status = manageBtn.getAttribute('data-status') || 'ACTIVE';

          document.getElementById('modalTargetUserType').value = userType;
          document.getElementById('modalUserId').value = userId;
          document.getElementById('modalOriginalStatus').value = status;
          document.getElementById('modalFullName').textContent = fullName;
          document.getElementById('modalEmail').textContent = email;
          document.getElementById('modalReason').value = '';

          var typeBadge = document.getElementById('modalTypeBadge');
          var roleContainer = document.getElementById('modalRoleContainer');
          var customerNote = document.getElementById('modalCustomerNote');
          var roleSelect = document.getElementById('modalRoleId');

          if (userType === 'STAFF') {
            typeBadge.innerHTML = '<span class="badge bg-primary-subtle text-primary border border-primary-subtle">Staff Account (ID: #' + escapeHtml(userId) + ')</span>';
            roleContainer.classList.remove('d-none');
            customerNote.classList.add('d-none');
            if (roleId && roleSelect) {
              roleSelect.value = roleId;
            }
          } else {
            typeBadge.innerHTML = '<span class="badge bg-light text-secondary border">Customer Account (ID: #' + escapeHtml(userId) + ')</span>';
            roleContainer.classList.add('d-none');
            customerNote.classList.remove('d-none');
          }

          var statusSelect = document.getElementById('modalStatus');
          if (statusSelect && status) {
            statusSelect.value = status;
          }
          updateBanWarningUi();
          clearFormErrors(document.getElementById('manageAccessForm'));

          bootstrap.Modal.getOrCreateInstance(document.getElementById('manageAccessModal')).show();
          return;
        }
      });

      <c:if test="${not empty userDetail}">
        var userDetailModalEl = document.getElementById('userDetailModal');
        if (userDetailModalEl) {
          bootstrap.Modal.getOrCreateInstance(userDetailModalEl).show();
        }
      </c:if>

      // Auto-reopen modal on server-side validation error (Solution 2)
      <c:if test="${modalAction == 'createStaff' && not empty modalError}">
        var addStaffModalEl = document.getElementById('addStaffModal');
        if (addStaffModalEl) bootstrap.Modal.getOrCreateInstance(addStaffModalEl).show();
      </c:if>
      <c:if test="${modalAction == 'updateStaffInfo' && not empty modalError}">
        var editStaffModalEl = document.getElementById('editStaffModal');
        if (editStaffModalEl) {
          bootstrap.Modal.getOrCreateInstance(editStaffModalEl).show();
          var tabBtn = document.getElementById('tab-edit-info');
          if (tabBtn) bootstrap.Tab.getOrCreateInstance(tabBtn).show();
        }
      </c:if>
      <c:if test="${modalAction == 'resetPassword' && not empty modalError}">
        var editStaffModalEl = document.getElementById('editStaffModal');
        if (editStaffModalEl) {
          bootstrap.Modal.getOrCreateInstance(editStaffModalEl).show();
          var tabBtn = document.getElementById('tab-reset-pw');
          if (tabBtn) bootstrap.Tab.getOrCreateInstance(tabBtn).show();
        }
      </c:if>
      <c:if test="${modalAction == 'updateAccess' && not empty modalError}">
        var manageAccessModalEl = document.getElementById('manageAccessModal');
        if (manageAccessModalEl) bootstrap.Modal.getOrCreateInstance(manageAccessModalEl).show();
      </c:if>

      // Clear previous server error alert on fresh Add Staff button click
      var addStaffBtn = document.querySelector('[data-bs-target="#addStaffModal"]');
      if (addStaffBtn) {
        addStaffBtn.addEventListener('click', function() {
          var errAlert = document.querySelectorAll('#addStaffModal .alert-danger:not(.modal-inline-error)');
          errAlert.forEach(function(el) { el.remove(); });
        });
      }

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
