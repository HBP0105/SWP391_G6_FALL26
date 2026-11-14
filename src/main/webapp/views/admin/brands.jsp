<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
  pageContext.setAttribute("dtFmt", DateTimeFormatter.ofPattern("HH:mm:ss dd/MM/yyyy"));
%>

<!DOCTYPE html>
<html lang="en" data-theme="light" data-bs-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Brand Management - Admin Portal</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminhmd-style.css">

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
    .bg-icon-secondary { background: rgba(100, 116, 139, 0.12); color: #64748b; }

    html[data-theme="dark"] body { background-color: var(--admin-bg, #0f172a) !important; color: var(--admin-text, #e5edf7) !important; }
    html[data-theme="dark"] .admin-navbar,
    html[data-theme="dark"] .bg-white,
    html[data-theme="dark"] .card,
    html[data-theme="dark"] .mini-stat-card,
    html[data-theme="dark"] .modal-content {
      background-color: var(--admin-surface, #182235) !important;
      color: var(--admin-text, #e5edf7) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .table { color: var(--admin-text, #e5edf7) !important; border-color: var(--admin-border, #2f3b52) !important; }
    html[data-theme="dark"] .table-light th { background-color: var(--admin-surface-soft, #111827) !important; color: #94a3b8 !important; }
    html[data-theme="dark"] .form-select,
    html[data-theme="dark"] .form-control {
      background-color: var(--admin-surface, #182235) !important;
      color: var(--admin-text, #e5edf7) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .text-dark { color: #f1f5f9 !important; }
  </style>
</head>

<body>
  <div class="admin-shell">
    <div class="sidebar-backdrop" id="sidebarBackdrop"></div>
    <jsp:include page="_sidebar.jsp" />

    <div class="admin-main">
      <nav class="navbar admin-navbar navbar-expand bg-white">
        <div class="container-fluid px-0">
          <button class="icon-button d-lg-none" id="sidebarToggleBtn" type="button" aria-label="Toggle Sidebar">
            <i class="bi bi-list fs-5"></i>
          </button>

          <span class="navbar-text fw-bold text-dark fs-6 d-none d-sm-inline">
            <i class="bi bi-award-fill text-primary me-2"></i>Brand Management
          </span>

          <div class="navbar-actions ms-auto d-flex align-items-center gap-2">
            <button class="icon-button theme-toggle" id="themeToggleBtn" type="button" title="Switch Light/Dark Theme">
              <i class="bi bi-moon-stars" id="themeIcon"></i>
            </button>
            <div class="dropdown">
              <button class="profile-button dropdown-toggle border-0" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-person-circle text-primary fs-5 me-1"></i>
                <span class="profile-name d-none d-sm-inline fw-semibold">Administrator</span>
              </button>
              <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/profile"><i class="bi bi-person-badge me-2"></i>My Profile</a></li>
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/change-password"><i class="bi bi-key me-2"></i>Change Password</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Sign Out</a></li>
              </ul>
            </div>
          </div>
        </div>
      </nav>

      <main class="dashboard-content overflow-auto py-3">
        <div class="container-fluid px-3">

          <!-- HEADER -->
          <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <div>
              <h1 class="h4 mb-0 fw-bold text-dark">Brand Management</h1>
              <p class="text-muted small mb-0">Manage manufacturer brands, partner trademarks, and product catalog associations.</p>
            </div>
            <button type="button" class="btn btn-primary btn-sm fw-semibold" data-bs-toggle="modal" data-bs-target="#createBrandModal">
              <i class="bi bi-plus-lg me-1"></i>Add Brand
            </button>
          </div>

          <!-- FLASH ALERTS -->
          <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-3 py-2" role="alert">
              <i class="bi bi-check-circle-fill me-2"></i><c:out value="${successMessage}"/>
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
          </c:if>
          <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-3 py-2" role="alert">
              <i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${errorMessage}"/>
              <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
          </c:if>

          <!-- MINI STATS -->
          <div class="row g-3 mb-3">
            <div class="col-12 col-sm-4">
              <div class="mini-stat-card d-flex align-items-center gap-3">
                <div class="mini-stat-icon bg-icon-primary"><i class="bi bi-award-fill"></i></div>
                <div>
                  <div class="text-muted small">Total Brands</div>
                  <div class="fs-5 fw-bold">${stats.totalCount != null ? stats.totalCount : 0}</div>
                </div>
              </div>
            </div>
            <div class="col-12 col-sm-4">
              <div class="mini-stat-card d-flex align-items-center gap-3">
                <div class="mini-stat-icon bg-icon-success"><i class="bi bi-check-circle"></i></div>
                <div>
                  <div class="text-muted small">Active Brands</div>
                  <div class="fs-5 fw-bold text-success">${stats.activeCount != null ? stats.activeCount : 0}</div>
                </div>
              </div>
            </div>
            <div class="col-12 col-sm-4">
              <div class="mini-stat-card d-flex align-items-center gap-3">
                <div class="mini-stat-icon bg-icon-secondary"><i class="bi bi-pause-circle"></i></div>
                <div>
                  <div class="text-muted small">Inactive Brands</div>
                  <div class="fs-5 fw-bold text-secondary">${stats.inactiveCount != null ? stats.inactiveCount : 0}</div>
                </div>
              </div>
            </div>
          </div>

          <!-- SEARCH & FILTER FORM -->
          <div class="card border-0 shadow-sm mb-3">
            <div class="card-body py-2.5">
              <form method="get" action="${pageContext.request.contextPath}/admin/brands" class="row g-2 align-items-end">
                <div class="col-12 col-md-5">
                  <label class="form-label small fw-semibold mb-1">Search Keyword</label>
                  <input type="text" class="form-control form-control-sm" name="keyword"
                         value="<c:out value='${keyword}'/>" placeholder="Search by brand name or description...">
                </div>
                <div class="col-6 col-md-3">
                  <label class="form-label small fw-semibold mb-1">Status</label>
                  <select class="form-select form-select-sm" name="status">
                    <option value="ALL" ${selectedStatus == 'ALL' ? 'selected' : ''}>All Statuses</option>
                    <option value="ACTIVE" ${selectedStatus == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                    <option value="INACTIVE" ${selectedStatus == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                  </select>
                </div>
                <div class="col-6 col-md-4 d-flex gap-2">
                  <button type="submit" class="btn btn-primary btn-sm px-3"><i class="bi bi-search me-1"></i>Filter</button>
                  <a href="${pageContext.request.contextPath}/admin/brands" class="btn btn-outline-secondary btn-sm">Reset</a>
                </div>
              </form>
            </div>
          </div>

          <!-- BRANDS DATA TABLE -->
          <div class="card border-0 shadow-sm">
            <div class="table-responsive">
              <table class="table table-hover align-middle mb-0 small">
                <thead class="table-light">
                  <tr>
                    <th style="width: 70px;">ID</th>
                    <th>Brand Name</th>
                    <th>Description</th>
                    <th class="text-center">Products Linked</th>
                    <th>Status</th>
                    <th>Created At</th>
                    <th class="text-end" style="width: 190px;">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="b" items="${brands}">
                    <tr>
                      <td class="text-muted fw-semibold">#${b.brandId}</td>
                      <td class="fw-semibold text-dark"><c:out value="${b.brandName}"/></td>
                      <td class="text-muted">
                        <c:choose>
                          <c:when test="${not empty b.description}"><c:out value="${b.description}"/></c:when>
                          <c:otherwise><span class="fst-italic text-secondary">No description</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-center">
                        <span class="badge bg-light text-dark border px-2.5 py-1">
                          <i class="bi bi-box-seam me-1 text-primary"></i>${b.productCount}
                        </span>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${b.status == 'ACTIVE'}">
                            <span class="badge bg-success-subtle text-success border border-success-subtle">ACTIVE</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge bg-secondary-subtle text-secondary border">INACTIVE</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-muted">
                        <c:choose>
                          <c:when test="${not empty b.createdAt}"><c:out value="${b.createdAt.format(dtFmt)}"/></c:when>
                          <c:otherwise>-</c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-end">
                        <div class="d-inline-flex gap-1">
                          <!-- EDIT BUTTON -->
                          <button type="button" class="btn btn-outline-primary btn-sm py-1 px-2 btn-edit-brand"
                                  data-id="${b.brandId}"
                                  data-name="<c:out value='${b.brandName}'/>"
                                  data-description="<c:out value='${b.description}'/>"
                                  data-status="${b.status}">
                            <i class="bi bi-pencil-square me-1"></i>Edit
                          </button>

                          <!-- TOGGLE STATUS BUTTON -->
                          <form method="post" action="${pageContext.request.contextPath}/admin/brands" class="d-inline">
                            <input type="hidden" name="action" value="toggleStatus">
                            <input type="hidden" name="id" value="${b.brandId}">
                            <input type="hidden" name="status" value="${b.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}">
                            <input type="hidden" name="keyword" value="<c:out value='${keyword}'/>">
                            <input type="hidden" name="statusParam" value="${selectedStatus}">
                            <input type="hidden" name="page" value="${currentPage}">
                            <button type="submit" class="btn btn-sm py-1 px-2 ${b.status == 'ACTIVE' ? 'btn-outline-secondary' : 'btn-outline-success'}">
                              ${b.status == 'ACTIVE' ? 'Deactivate' : 'Activate'}
                            </button>
                          </form>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty brands}">
                    <tr>
                      <td colspan="7" class="text-center text-muted py-4">No brands found matching your criteria.</td>
                    </tr>
                  </c:if>
                </tbody>
              </table>
            </div>

            <!-- PAGINATION -->
            <div class="card-footer bg-white d-flex flex-wrap justify-content-between align-items-center py-2 gap-2">
              <span class="text-muted small">
                Showing page <strong>${currentPage}</strong> of <strong>${totalPages}</strong> (${totalItems} total brands)
              </span>
              <div class="btn-group btn-group-sm">
                <c:if test="${currentPage > 1}">
                  <c:url var="prevUrl" value="/admin/brands">
                    <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                    <c:if test="${selectedStatus != 'ALL'}"><c:param name="status" value="${selectedStatus}"/></c:if>
                    <c:param name="page" value="${currentPage - 1}"/>
                  </c:url>
                  <a class="btn btn-outline-secondary" href="${prevUrl}">Previous</a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="p">
                  <c:url var="pageUrl" value="/admin/brands">
                    <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                    <c:if test="${selectedStatus != 'ALL'}"><c:param name="status" value="${selectedStatus}"/></c:if>
                    <c:param name="page" value="${p}"/>
                  </c:url>
                  <a class="btn ${p == currentPage ? 'btn-primary' : 'btn-outline-secondary'}" href="${pageUrl}">${p}</a>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                  <c:url var="nextUrl" value="/admin/brands">
                    <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                    <c:if test="${selectedStatus != 'ALL'}"><c:param name="status" value="${selectedStatus}"/></c:if>
                    <c:param name="page" value="${currentPage + 1}"/>
                  </c:url>
                  <a class="btn btn-outline-secondary" href="${nextUrl}">Next</a>
                </c:if>
              </div>
            </div>
          </div>

        </div>
      </main>
    </div>
  </div>

  <!-- CREATE BRAND MODAL -->
  <div class="modal fade" id="createBrandModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content border-0 shadow">
        <form method="post" action="${pageContext.request.contextPath}/admin/brands" id="createBrandForm">
          <input type="hidden" name="action" value="create">
          <div class="modal-header border-bottom">
            <h5 class="modal-title fw-bold fs-6"><i class="bi bi-plus-circle text-primary me-2"></i>Add New Brand</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body p-4">
            <c:if test="${modalAction == 'create' && not empty modalError}">
              <div class="alert alert-danger py-2 small mb-3">
                <i class="bi bi-exclamation-triangle-fill me-1"></i><c:out value="${modalError}"/>
              </div>
            </c:if>
            <div class="mb-3">
              <label class="form-label fw-semibold small">Brand Name <span class="text-danger">*</span></label>
              <input type="text" class="form-control form-control-sm" name="name" required maxlength="100" placeholder="e.g. Sony, Bose, Sennheiser" value="<c:out value='${modalAction == "create" ? modalName : ""}'/>">
            </div>
            <div class="mb-3">
              <label class="form-label fw-semibold small">Description</label>
              <textarea class="form-control form-control-sm" name="description" rows="3" maxlength="500" placeholder="Brief brand description..."><c:out value='${modalAction == "create" ? modalDescription : ""}'/></textarea>
            </div>
            <div class="mb-0">
              <label class="form-label fw-semibold small">Initial Status</label>
              <select class="form-select form-select-sm" name="status">
                <option value="ACTIVE" ${modalAction == 'create' && modalStatus == 'INACTIVE' ? '' : 'selected'}>ACTIVE</option>
                <option value="INACTIVE" ${modalAction == 'create' && modalStatus == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
              </select>
            </div>
          </div>
          <div class="modal-footer border-top bg-light">
            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-primary btn-sm fw-bold">Create Brand</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- EDIT BRAND MODAL -->
  <div class="modal fade" id="editBrandModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content border-0 shadow">
        <form method="post" action="${pageContext.request.contextPath}/admin/brands" id="editBrandForm">
          <input type="hidden" name="action" value="update">
          <input type="hidden" name="id" id="editBrandId" value="<c:out value='${modalAction == "update" ? modalId : ""}'/>">
          <input type="hidden" name="keyword" value="<c:out value='${keyword}'/>">
          <input type="hidden" name="statusParam" value="${selectedStatus}">
          <input type="hidden" name="page" value="${currentPage}">
          <div class="modal-header border-bottom">
            <h5 class="modal-title fw-bold fs-6"><i class="bi bi-pencil-square text-primary me-2"></i>Edit Brand</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body p-4">
            <c:if test="${modalAction == 'update' && not empty modalError}">
              <div class="alert alert-danger py-2 small mb-3">
                <i class="bi bi-exclamation-triangle-fill me-1"></i><c:out value="${modalError}"/>
              </div>
            </c:if>
            <div class="mb-3">
              <label class="form-label fw-semibold small">Brand Name <span class="text-danger">*</span></label>
              <input type="text" class="form-control form-control-sm" name="name" id="editBrandName" required maxlength="100" value="<c:out value='${modalAction == "update" ? modalName : ""}'/>">
            </div>
            <div class="mb-3">
              <label class="form-label fw-semibold small">Description</label>
              <textarea class="form-control form-control-sm" name="description" id="editBrandDescription" rows="3" maxlength="500"><c:out value='${modalAction == "update" ? modalDescription : ""}'/></textarea>
            </div>
            <div class="mb-0">
              <label class="form-label fw-semibold small">Status</label>
              <select class="form-select form-select-sm" name="status" id="editBrandStatus">
                <option value="ACTIVE" ${modalAction == 'update' && modalStatus == 'INACTIVE' ? '' : 'selected'}>ACTIVE</option>
                <option value="INACTIVE" ${modalAction == 'update' && modalStatus == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
              </select>
            </div>
          </div>
          <div class="modal-footer border-top bg-light">
            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-primary btn-sm fw-bold">Save Changes</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      // Auto-reopen modal on server-side validation error (Solution 2)
      <c:if test="${modalAction == 'create' && not empty modalError}">
        var createModalEl = document.getElementById('createBrandModal');
        if (createModalEl) {
          bootstrap.Modal.getOrCreateInstance(createModalEl).show();
        }
      </c:if>
      <c:if test="${modalAction == 'update' && not empty modalError}">
        var editModalEl = document.getElementById('editBrandModal');
        if (editModalEl) {
          bootstrap.Modal.getOrCreateInstance(editModalEl).show();
        }
      </c:if>

      // Clear create modal errors on fresh click
      var createBtn = document.querySelector('[data-bs-target="#createBrandModal"]');
      if (createBtn) {
        createBtn.addEventListener('click', function() {
          var errAlert = document.querySelector('#createBrandModal .alert-danger');
          if (errAlert) errAlert.remove();
        });
      }

      // Event delegation for opening Edit modal
      document.addEventListener('click', function(e) {
        var btn = e.target.closest('.btn-edit-brand');
        if (!btn) return;
        var errAlert = document.querySelector('#editBrandModal .alert-danger');
        if (errAlert) errAlert.remove();

        document.getElementById('editBrandId').value = btn.getAttribute('data-id') || '';
        document.getElementById('editBrandName').value = btn.getAttribute('data-name') || '';
        document.getElementById('editBrandDescription').value = btn.getAttribute('data-description') || '';
        document.getElementById('editBrandStatus').value = btn.getAttribute('data-status') || 'ACTIVE';
        bootstrap.Modal.getOrCreateInstance(document.getElementById('editBrandModal')).show();
      });

      // Mobile sidebar toggle
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

      // Theme toggle (Light / Dark)
      var themeToggleBtn = document.getElementById('themeToggleBtn');
      var themeIcon = document.getElementById('themeIcon');
      var htmlTag = document.documentElement;
      function applyTheme(theme) {
        htmlTag.setAttribute('data-theme', theme);
        htmlTag.setAttribute('data-bs-theme', theme);
        localStorage.setItem('adminTheme', theme);
        if (themeIcon) {
          themeIcon.className = (theme === 'dark') ? 'bi bi-sun-fill text-warning' : 'bi bi-moon-stars';
        }
      }
      applyTheme(localStorage.getItem('adminTheme') || 'light');
      if (themeToggleBtn) {
        themeToggleBtn.addEventListener('click', function() {
          var next = (htmlTag.getAttribute('data-theme') === 'dark') ? 'light' : 'dark';
          applyTheme(next);
        });
      }
    });
  </script>
</body>
</html>
