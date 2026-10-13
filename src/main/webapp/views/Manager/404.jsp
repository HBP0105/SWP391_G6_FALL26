<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="adminHMD error page">
  <title>404 Page Not Found | Manager</title>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">

  <link rel="stylesheet"
    href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">

  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css">
</head>

<body class="auth-body">
  <button class="icon-button theme-toggle auth-theme-toggle" type="button" data-theme-toggle
    aria-label="Switch color theme" title="Switch color theme">
    <i class="bi bi-moon-stars" data-theme-icon aria-hidden="true"></i>
  </button>
  <main class="error-page">
    <section class="error-card">
      <a class="auth-brand justify-content-center" href="index.html"><span class="brand-icon"><i
            class="bi bi-grid-1x2-fill" aria-hidden="true"></i></span><span><strong>Manager</strong><small>Error
            Center</small></span></a>
      <div class="error-code">404</div>
      <h1 class="h3 mb-2">Page Not Found</h1>
      <p class="text-muted mb-4">The page you are looking for does not exist or has been moved.</p>
      <div class="d-flex flex-wrap justify-content-center gap-2"><a class="btn btn-primary" href="${pageContext.request.contextPath}/Manager/Dashboard">><i
            class="bi bi-speedometer2" aria-hidden="true"></i> Back to Dashboard</a></div>
    </section>
  </main>

  <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>

  <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>
</body>

</html>