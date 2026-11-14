<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en" data-theme="light" data-bs-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Change Password - Admin Portal</title>

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

  <script>
    (function() {
      const savedTheme = localStorage.getItem('adminTheme') || 'light';
      document.documentElement.setAttribute('data-theme', savedTheme);
      document.documentElement.setAttribute('data-bs-theme', savedTheme);
    })();
  </script>

  <style>
    html[data-theme="dark"] body {
      background-color: var(--admin-bg, #0f172a) !important;
      color: var(--admin-text, #e5edf7) !important;
    }
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
    html[data-theme="dark"] .text-dark {
      color: #f1f5f9 !important;
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
            <i class="bi bi-key-fill text-primary me-2"></i>Administrator Security Settings
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
                <li><a class="dropdown-item active" href="${pageContext.request.contextPath}/admin/change-password"><i class="bi bi-key me-2"></i>Change Password</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Sign Out</a></li>
              </ul>
            </div>
          </div>
        </div>
      </nav>

      <!-- PAGE BODY -->
      <main class="dashboard-content overflow-auto py-4">
        <div class="container-fluid px-3">
          <div class="row justify-content-center">
            <div class="col-12 col-md-8 col-lg-6">

              <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                  <h1 class="h4 mb-0 fw-bold text-dark">Change Administrator Password</h1>
                  <p class="text-muted small mb-0">Update your own Admin Portal login credentials securely.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary btn-sm">
                  <i class="bi bi-arrow-left me-1"></i>Back to Users
                </a>
              </div>

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

              <div class="card border-0 shadow-sm">
                <div class="card-body p-4">
                  <div class="user-info-banner p-3 rounded mb-4 border bg-light d-flex align-items-center gap-3">
                    <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center" style="width: 44px; height: 44px; font-size: 1.25rem;">
                      <i class="bi bi-shield-lock-fill"></i>
                    </div>
                    <div>
                      <div class="fw-bold text-dark">
                        <c:out value="${sessionScope.staff.fullName}"/>
                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle ms-1">
                          <c:out value="${sessionScope.staff.roleName}"/>
                        </span>
                      </div>
                      <div class="text-muted small"><c:out value="${sessionScope.staff.email}"/></div>
                    </div>
                  </div>

                  <form method="post" action="${pageContext.request.contextPath}/admin/change-password" id="adminChangePwForm">
                    <div class="mb-3">
                      <label class="form-label fw-semibold fs-7 mb-1">Current Password <span class="text-danger">*</span></label>
                      <div class="input-group input-group-sm">
                        <input type="password" class="form-control" name="currentPassword" id="currentPassword" required placeholder="Enter current password">
                        <button class="btn btn-outline-secondary btn-toggle-pw" type="button" data-target="currentPassword" aria-label="Toggle password">
                          <i class="bi bi-eye"></i>
                        </button>
                      </div>
                    </div>

                    <div class="mb-3">
                      <label class="form-label fw-semibold fs-7 mb-1">New Password <span class="text-danger">*</span></label>
                      <div class="input-group input-group-sm">
                        <input type="password" class="form-control" name="newPassword" id="newPassword" required minlength="6" placeholder="Minimum 6 characters">
                        <button class="btn btn-outline-secondary btn-toggle-pw" type="button" data-target="newPassword" aria-label="Toggle password">
                          <i class="bi bi-eye"></i>
                        </button>
                      </div>
                    </div>

                    <div class="mb-4">
                      <label class="form-label fw-semibold fs-7 mb-1">Confirm New Password <span class="text-danger">*</span></label>
                      <div class="input-group input-group-sm">
                        <input type="password" class="form-control" name="confirmPassword" id="confirmPassword" required minlength="6" placeholder="Re-enter new password">
                        <button class="btn btn-outline-secondary btn-toggle-pw" type="button" data-target="confirmPassword" aria-label="Toggle password">
                          <i class="bi bi-eye"></i>
                        </button>
                      </div>
                      <div class="invalid-feedback d-block d-none" id="pwMismatchFeedback">New password and confirmation do not match.</div>
                    </div>

                    <div class="d-flex justify-content-end gap-2">
                      <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary btn-sm">Cancel</a>
                      <button type="submit" class="btn btn-primary btn-sm fw-bold px-3">
                        <i class="bi bi-check2-circle me-1"></i>Update Password
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
      document.querySelectorAll('.btn-toggle-pw').forEach(function(btn) {
        btn.addEventListener('click', function() {
          var input = document.getElementById(btn.getAttribute('data-target'));
          if (!input) return;
          var isPw = input.type === 'password';
          input.type = isPw ? 'text' : 'password';
          btn.querySelector('i').className = isPw ? 'bi bi-eye-slash' : 'bi bi-eye';
        });
      });

      var form = document.getElementById('adminChangePwForm');
      var newPw = document.getElementById('newPassword');
      var confirmPw = document.getElementById('confirmPassword');
      var mismatchEl = document.getElementById('pwMismatchFeedback');

      if (form) {
        form.addEventListener('submit', function(e) {
          if (newPw.value !== confirmPw.value) {
            mismatchEl.classList.remove('d-none');
            confirmPw.classList.add('is-invalid');
            e.preventDefault();
          }
        });
        confirmPw.addEventListener('input', function() {
          mismatchEl.classList.add('d-none');
          confirmPw.classList.remove('is-invalid');
        });
      }

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
          themeIcon.className = theme === 'dark' ? 'bi bi-sun-fill text-warning' : 'bi bi-moon-stars';
        }
      }
      applyTheme(localStorage.getItem('adminTheme') || 'light');
      if (themeToggleBtn) {
        themeToggleBtn.addEventListener('click', function() {
          var next = (htmlTag.getAttribute('data-theme') || 'light') === 'dark' ? 'light' : 'dark';
          applyTheme(next);
        });
      }
    });
  </script>
</body>
</html>
