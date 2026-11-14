<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en" data-theme="light" data-bs-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Administrator Profile - Admin Portal</title>

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
    html[data-theme="dark"] body { background-color: var(--admin-bg, #0f172a) !important; color: var(--admin-text, #e5edf7) !important; }
    html[data-theme="dark"] .admin-navbar,
    html[data-theme="dark"] .bg-white,
    html[data-theme="dark"] .card {
      background-color: var(--admin-surface, #182235) !important;
      color: var(--admin-text, #e5edf7) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .form-control {
      background-color: var(--admin-surface, #182235) !important;
      color: var(--admin-text, #e5edf7) !important;
      border-color: var(--admin-border, #2f3b52) !important;
    }
    html[data-theme="dark"] .user-info-banner {
      background: rgba(30, 41, 59, 0.7) !important;
      border-color: rgba(51, 65, 85, 0.8) !important;
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
            <i class="bi bi-person-badge-fill text-primary me-2"></i>Administrator Profile
          </span>

          <div class="navbar-actions ms-auto d-flex align-items-center gap-2">
            <button class="icon-button theme-toggle" id="themeToggleBtn" type="button" title="Switch Light/Dark Theme">
              <i class="bi bi-moon-stars" id="themeIcon"></i>
            </button>
            <div class="dropdown">
              <button class="profile-button dropdown-toggle border-0" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-person-circle text-primary fs-5 me-1"></i>
                <span class="profile-name d-none d-sm-inline fw-semibold"><c:out value="${profile.fullName}"/></span>
              </button>
              <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                <li><a class="dropdown-item active" href="${pageContext.request.contextPath}/admin/profile"><i class="bi bi-person-badge me-2"></i>My Profile</a></li>
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/change-password"><i class="bi bi-key me-2"></i>Change Password</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Sign Out</a></li>
              </ul>
            </div>
          </div>
        </div>
      </nav>

      <main class="dashboard-content overflow-auto py-4">
        <div class="container-fluid px-3">
          <div class="row justify-content-center">
            <div class="col-12 col-md-9 col-lg-7">

              <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                  <h1 class="h4 mb-0 fw-bold text-dark">Administrator Profile</h1>
                  <p class="text-muted small mb-0">View and update your personal Admin Portal account information.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/change-password" class="btn btn-outline-primary btn-sm">
                  <i class="bi bi-key me-1"></i>Change Password
                </a>
              </div>

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

              <div class="card border-0 shadow-sm">
                <div class="card-body p-4">
                  <div class="user-info-banner p-3 rounded border bg-light mb-4 d-flex flex-wrap justify-content-between align-items-center gap-2">
                    <div class="d-flex align-items-center gap-3">
                      <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center" style="width: 48px; height: 48px; font-size: 1.4rem;">
                        <i class="bi bi-person-fill"></i>
                      </div>
                      <div>
                        <div class="fw-bold text-dark fs-6">
                          <c:out value="${profile.fullName}"/>
                          <span class="text-muted fw-normal small">#${profile.userId}</span>
                        </div>
                        <div class="text-muted small"><c:out value="${profile.email}"/></div>
                      </div>
                    </div>
                    <div class="text-end">
                      <span class="badge bg-primary-subtle text-primary border border-primary-subtle">${profile.roleName}</span>
                      <span class="badge bg-success-subtle text-success border border-success-subtle ms-1">${profile.status}</span>
                    </div>
                  </div>

                  <form method="post" action="${pageContext.request.contextPath}/admin/profile">
                    <div class="row g-3">
                      <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold small">Full Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-sm" name="fullName"
                               value="<c:out value='${profile.fullName}'/>" required maxlength="100">
                      </div>
                      <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold small">Phone Number</label>
                        <input type="text" class="form-control form-control-sm" name="phone"
                               value="<c:out value='${profile.phone}'/>" maxlength="20" placeholder="09xxxxxxxx">
                      </div>
                      <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold small">Email Address</label>
                        <input type="text" class="form-control form-control-sm" value="<c:out value='${profile.email}'/>" disabled>
                      </div>
                      <div class="col-12 col-md-6">
                        <label class="form-label fw-semibold small">Account Created</label>
                        <input type="text" class="form-control form-control-sm"
                               value="<c:if test='${not empty profile.createdAt}'><fmt:formatDate value='${profile.createdAt}' pattern='yyyy-MM-dd HH:mm'/></c:if>" disabled>
                      </div>
                    </div>

                    <div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
                      <button type="submit" class="btn btn-primary btn-sm fw-bold px-3">
                        <i class="bi bi-save me-1"></i>Save Profile Changes
                      </button>
                    </div>
                  </form>
                </div>
              </div>

            </div>
          </div>
        </div>
      </main>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
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
