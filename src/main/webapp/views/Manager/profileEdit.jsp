<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit Profile | Headphone Store</title>

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
                    <a class="brand-mark" href="${pageContext.request.contextPath}/Manager/Dashboard">
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
                        <span class="nav-icon"><i class="bi bi-speedometer2"></i></span>
                        <span class="nav-text">Dashboard</span>
                    </a>

                    <a class="nav-link ${activePage == 'products' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/products">
                        <span class="nav-icon"><i class="bi bi-box-seam"></i></span>
                        <span class="nav-text">Products</span>
                    </a>

                    <a class="nav-link ${activePage == 'orders' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/OrderManagement">
                        <span class="nav-icon"><i class="bi bi-cart-check"></i></span>
                        <span class="nav-text">Orders</span>
                    </a>

                    <a class="nav-link ${activePage == 'inventory' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Inventory">
                        <span class="nav-icon"><i class="bi bi-boxes"></i></span>
                        <span class="nav-text">Inventory</span>
                    </a>

                    <a class="nav-link ${activePage == 'voucher' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Voucher">
                        <span class="nav-icon"><i class="bi bi-ticket-perforated"></i></span>
                        <span class="nav-text">Vouchers</span>
                    </a>

                    <a class="nav-link ${activePage == 'reports' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Report">
                        <span class="nav-icon"><i class="bi bi-bar-chart-line"></i></span>
                        <span class="nav-text">Reports</span>
                    </a>

                    <a class="nav-link ${activePage == 'profile' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/Manager/Profile">
                        <span class="nav-icon"><i class="bi bi-person-badge"></i></span>
                        <span class="nav-text">Profile</span>
                    </a>

                </nav>

                <div class="sidebar-footer">
                    <span class="status-dot"></span>
                    <span class="sidebar-footer-text">System running smoothly</span>
                </div>

            </aside>

            <div class="admin-main">

                <nav class="navbar admin-navbar navbar-expand bg-white">

                    <div class="container-fluid px-3 px-lg-4">

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
                                <i class="bi bi-moon-stars" data-theme-icon aria-hidden="true"></i>
                            </button>

                            <div class="dropdown">

                                <button class="profile-button dropdown-toggle"
                                        type="button"
                                        data-bs-toggle="dropdown"
                                        aria-expanded="false">

                                    <img class="avatar-img avatar-sm"
                                         src="${pageContext.request.contextPath}/assets/Admin_Manager/images/avatar/gumball.jpg"
                                         alt="Manager"
                                         onerror="this.onerror=null;this.src='data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' width=\'34\' height=\'34\' viewBox=\'0 0 34 34\'><rect width=\'34\' height=\'34\' rx=\'8\' fill=\'%232563eb\'/><text x=\'50%25\' y=\'53%25\' dominant-baseline=\'middle\' text-anchor=\'middle\' fill=\'%23ffffff\' font-family=\'sans-serif\' font-size=\'14\' font-weight=\'bold\'>M</text></svg>';">

                                    <span class="profile-name d-none d-sm-inline">
                                        ${not empty staff.fullName ? staff.fullName : 'Manager'}
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

                        <div class="page-heading mb-4">
                            <div class="page-heading-copy">
                                <span class="page-icon">
                                    <i class="bi bi-person-gear" aria-hidden="true"></i>
                                </span>
                                <div>
                                    <p class="eyebrow mb-1">Manager Account</p>
                                    <h1 class="h3 mb-1">Edit Profile</h1>
                                    <p class="text-muted mb-0">Update your personal account information.</p>
                                </div>
                            </div>
                        </div>

                        <c:if test="${not empty errorMsg}">
                            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                                <i class="bi bi-exclamation-triangle-fill fs-5 me-2"></i>
                                <div>${errorMsg}</div>
                                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        </c:if>

                        <div class="row justify-content-center">
                            <div class="col-12 col-xl-9">
                                <section class="panel">
                                    <div class="panel-header d-flex justify-content-between align-items-start gap-3">
                                        <div>
                                            <h2 class="h5 mb-1 section-title">
                                                <i class="bi bi-pencil-square"></i>
                                                <span>Profile Information</span>
                                            </h2>
                                            <p class="text-muted mb-0">Role, status and Staff ID are managed by the system and cannot be edited here.</p>
                                        </div>
                                        <a class="btn btn-light" href="${pageContext.request.contextPath}/Manager/Profile">
                                            <i class="bi bi-arrow-left me-1"></i> Back to Profile
                                        </a>
                                    </div>

                                    <form action="${pageContext.request.contextPath}/Manager/Profile" method="POST" class="needs-validation">
                                        <input type="hidden" name="action" value="updateProfile">

                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label class="form-label" for="profileName">Full Name <span class="text-danger">*</span></label>
                                                <input class="form-control" id="profileName" name="fullName" type="text" value="${staff.fullName}" required>
                                            </div>

                                            <div class="col-md-6">
                                                <label class="form-label" for="profileEmail">Email Address <span class="text-danger">*</span></label>
                                                <input class="form-control" id="profileEmail" name="email" type="email" value="${staff.email}" required>
                                            </div>

                                            <div class="col-md-6">
                                                <label class="form-label" for="profilePhone">Phone Number</label>
                                                <input class="form-control" id="profilePhone" name="phone" type="tel" placeholder="0901234567" value="${staff.phone}">
                                            </div>

                                            <div class="col-md-6">
                                                <label class="form-label" for="profileRole">Role</label>
                                                <input class="form-control bg-light" id="profileRole" type="text" value="${not empty staff.role.roleName ? staff.role.roleName : 'MANAGER'}" readonly>
                                            </div>

                                            <div class="col-md-6">
                                                <label class="form-label" for="profileStaffId">Staff ID</label>
                                                <input class="form-control bg-light" id="profileStaffId" type="text" value="#${staff.staffId}" readonly>
                                            </div>

                                            <div class="col-md-6">
                                                <label class="form-label" for="profileStatus">Account Status</label>
                                                <input class="form-control bg-light" id="profileStatus" type="text" value="${not empty staff.status ? staff.status : 'ACTIVE'}" readonly>
                                            </div>
                                        </div>

                                        <div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
                                            <a class="btn btn-light" href="${pageContext.request.contextPath}/Manager/Profile">Cancel</a>
                                            <button class="btn btn-primary" type="submit">
                                                <i class="bi bi-check2-circle me-1"></i> Save Changes
                                            </button>
                                        </div>
                                    </form>
                                </section>
                            </div>
                        </div>
                    </div>

                </main>

                <footer class="admin-footer">
                    <div class="container-fluid px-3 px-lg-4">
                        <span>
                            Copyright 2026 Headphone Store.<br>
                            Manager Panel
                        </span>
                        <span>Store Management System.</span>
                    </div>
                </footer>

            </div>

        </div>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>

    </body>

</html>
