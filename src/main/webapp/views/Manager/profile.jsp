<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>Profile | Headphone Store</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css">
    </head>

    <body>

        <div class="admin-shell">

            <div class="sidebar-backdrop" data-sidebar-close></div>

            <aside class="admin-sidebar" id="adminSidebar" aria-label="Main navigation">

                <div class="sidebar-header">
                    <a class="brand-mark" href="${pageContext.request.contextPath}/Manager/dashboard">
                        <span class="brand-icon">
                            <i class="bi bi-headphones" aria-hidden="true"></i>
                        </span>

                        <span class="brand-copy">
                            <span class="brand-title">Headphone Store</span>
                            <span class="brand-subtitle">Manager Panel</span>
                        </span>
                    </a>
                </div>

                 <nav class="sidebar-nav">

                    <a class="nav-link ${activePage == 'dashboard' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Dashboard">

                        <span class="nav-icon">
                            <i class="bi bi-speedometer2"></i>
                        </span>

                        <span class="nav-text">Dashboard</span>
                    </a>

                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/products">

                        <span class="nav-icon">
                            <i class="bi bi-box-seam"></i>
                        </span>

                        <span class="nav-text">Products</span>
                    </a>

                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/OrderManagement">

                        <span class="nav-icon">
                            <i class="bi bi-cart-check"></i>
                        </span>

                        <span class="nav-text">Orders</span>
                    </a>

                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/Inventory">

                        <span class="nav-icon">
                            <i class="bi bi-boxes"></i>
                        </span>

                        <span class="nav-text">Inventory</span>
                    </a>

                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/Voucher">

                        <span class="nav-icon">
                            <i class="bi bi-ticket-perforated"></i>
                        </span>

                        <span class="nav-text">Vouchers</span>
                    </a>

                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/Report">

                        <span class="nav-icon">
                            <i class="bi bi-bar-chart-line"></i>
                        </span>

                        <span class="nav-text">Reports</span>
                    </a>

                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/Manager/Profile">

                        <span class="nav-icon">
                            <i class="bi bi-person-badge"></i>
                        </span>

                        <span class="nav-text">Profile</span>
                    </a>

                </nav>

                <div class="sidebar-footer">

                    <span class="status-dot"></span>

                    <span class="sidebar-footer-text">
                        System running smoothly
                    </span>

                </div>

            </aside>

            <div class="admin-main">

                <nav class="navbar admin-navbar navbar-expand bg-white">

                    <div class="container-fluid px-3 px-lg-4">

                        <!-- Sidebar Toggle -->
                        <button class="sidebar-toggle"
                                type="button"
                                data-sidebar-toggle
                                aria-controls="adminSidebar"
                                aria-expanded="true"
                                aria-label="Toggle sidebar">

                            <span></span>
                            <span></span>
                            <span></span>

                        </button>

                        <div class="navbar-actions ms-auto">

                            <button class="icon-button theme-toggle"
                                    type="button"
                                    data-theme-toggle
                                    aria-label="Switch color theme"
                                    title="Switch color theme">

                                <i class="bi bi-moon-stars"
                                   data-theme-icon
                                   aria-hidden="true"></i>

                            </button>

                            <div class="dropdown">

                                <button class="icon-button"
                                        type="button"
                                        data-bs-toggle="dropdown"
                                        aria-expanded="false"
                                        aria-label="Notifications">

                                    <span class="notification-dot"></span>

                                    <i class="bi bi-bell"
                                       aria-hidden="true"></i>

                                </button>


                                <div class="dropdown-menu dropdown-menu-end notification-menu">

                                    <div class="dropdown-header fw-bold text-body">
                                        Notifications
                                    </div>


                                    <a class="dropdown-item"
                                       href="${pageContext.request.contextPath}/manager/orders">

                                        <span class="notification-title">
                                            New order received
                                        </span>

                                        <span class="notification-time">
                                            Recently
                                        </span>

                                    </a>


                                    <a class="dropdown-item"
                                       href="${pageContext.request.contextPath}/manager/inventory">

                                        <span class="notification-title">
                                            Low stock alert
                                        </span>

                                        <span class="notification-time">
                                            Recently
                                        </span>

                                    </a>

                                </div>

                            </div>

                            <div class="dropdown">

                                <button class="profile-button dropdown-toggle"
                                        type="button"
                                        data-bs-toggle="dropdown"
                                        aria-expanded="false">

                                    <img class="avatar-img avatar-sm"
                         src="${pageContext.request.contextPath}/assets/Admin_Manager/images/avatar/gumball.jpg"
                                         alt="Manager">

                                    <span class="profile-name d-none d-sm-inline">
                                        Manager
                                    </span>

                                </button>


                                <ul class="dropdown-menu dropdown-menu-end">

                                    <li>
                                        <a class="dropdown-item"
                                           href="${pageContext.request.contextPath}/Manager/Profile">
                                            Profile
                                        </a>
                                    </li>

                                    <li>
                                        <hr class="dropdown-divider">
                                    </li>

                                    <li>
                                        <a class="dropdown-item"
                                           href="${pageContext.request.contextPath}/logout">
                                            Sign out
                                        </a>
                                    </li>

                                </ul>

                            </div>

                        </div>

                    </div>

                </nav>

                <main class="dashboard-content">

                    <div class="container-fluid px-3 px-lg-4 py-4">


                        <!-- Page Heading -->
                        <div class="page-heading">

                            <div class="page-heading-copy">

                                <span class="page-icon">
                                    <i class="bi bi-person-badge"
                                       aria-hidden="true"></i>
                                </span>

                                <div>

                                    <p class="eyebrow mb-1">
                                        Manager
                                    </p>

                                    <h1 class="h3 mb-1">
                                        Profile
                                    </h1>

                                    <p class="text-muted mb-0">
                                        View and manage your account information.
                                    </p>

                                </div>

                            </div>

                        </div>

                        <section class="row g-3">


                            <!-- Profile Summary -->
                            <div class="col-12 col-xl-4">

                                <div class="panel h-100 text-center profile-card">

                                    <div class="profile-cover">
                                        <img src="${pageContext.request.contextPath}/assets/Admin_Manager/images/png/dasher-ui-bootstrap-5.jpg"
                                             alt="Headphone Store">
                                    </div>

                                    <img class="avatar-img avatar-xl profile-photo"
                         src="${pageContext.request.contextPath}/assets/Admin_Manager/images/avatar/gumball.jpg"
                                         alt="Manager">


                                    <h2 class="h5 mt-3 mb-1">
                                        Manager
                                    </h2>


                                    <p class="text-muted mb-3">
                                        Store Manager
                                    </p>


                                    <div class="d-flex justify-content-center gap-2">

                                        <span class="badge text-bg-primary">
                                            Manager
                                        </span>

                                        <span class="badge text-bg-success">
                                            Active
                                        </span>

                                    </div>

                                    <div class="info-list mt-4 text-start">

                                        <div>
                                            <span>Email</span>
                                            <strong>
                                                manager@example.com
                                            </strong>
                                        </div>


                                        <div>
                                            <span>Role</span>
                                            <strong>
                                                Store Manager
                                            </strong>
                                        </div>


                                        <div>
                                            <span>Status</span>
                                            <strong>
                                                Active
                                            </strong>
                                        </div>

                                    </div>

                                </div>

                            </div>

                            <div class="col-12 col-xl-8">

                                <form class="panel needs-validation"
                                      novalidate>

                                    <div class="panel-header">

                                        <div>

                                            <h2 class="h5 mb-1 section-title">

                                                <i class="bi bi-person-gear"
                                                   aria-hidden="true"></i>

                                                <span>
                                                    Profile Settings
                                                </span>

                                            </h2>

                                            <p class="text-muted mb-0">
                                                Update your personal information.
                                            </p>

                                        </div>

                                    </div>

                                    <div class="row g-3">

                                        <div class="col-md-6">

                                            <label class="form-label"
                                                   for="profileName">
                                                Full Name
                                            </label>

                                            <input class="form-control"
                                                   id="profileName"
                                                   type="text"
                                                   value="Manager"
                                                   required>

                                            <div class="invalid-feedback">
                                                Full name is required.
                                            </div>

                                        </div>

                                        <div class="col-md-6">

                                            <label class="form-label"
                                                   for="profileEmail">
                                                Email
                                            </label>

                                            <input class="form-control"
                                                   id="profileEmail"
                                                   type="email"
                                                   value="manager@example.com"
                                                   required>

                                            <div class="invalid-feedback">
                                                Enter a valid email.
                                            </div>

                                        </div>

                                        <div class="col-md-6">

                                            <label class="form-label"
                                                   for="profilePhone">
                                                Phone
                                            </label>

                                            <input class="form-control"
                                                   id="profilePhone"
                                                   type="text"
                                                   value="">

                                        </div>

                                        <div class="col-md-6">

                                            <label class="form-label"
                                                   for="profileRole">
                                                Role
                                            </label>

                                            <input class="form-control"
                                                   id="profileRole"
                                                   type="text"
                                                   value="Manager"
                                                   readonly>

                                        </div>


                                        <!-- Bio -->
                                        <div class="col-12">

                                            <label class="form-label"
                                                   for="profileBio">
                                                Bio
                                            </label>

                                            <textarea class="form-control"
                                                      id="profileBio"
                                                      rows="4"
                                                      placeholder="Enter a short description about yourself..."></textarea>

                                        </div>

                                    </div>

                                    <div class="d-flex justify-content-end gap-2 mt-4">

                                        <button class="btn btn-light"
                                                type="reset">

                                            Cancel

                                        </button>


                                        <button class="btn btn-primary"
                                                type="submit">

                                            <i class="bi bi-check2-circle"
                                               aria-hidden="true"></i>

                                            Save Profile

                                        </button>

                                    </div>

                                </form>

                            </div>

                        </section>

                    </div>

                </main>

                <footer class="admin-footer">

                    <div class="container-fluid px-3 px-lg-4">

                        <span>
                            Copyright 2026 Headphone Store.
                            <br>
                            Manager Panel
                        </span>

                        <span>
                            Store Management System.
                        </span>

                        <span>
                            Profile Management.
                        </span>

                    </div>

                </footer>

            </div>

        </div>


        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>
        
    </body>

</html>