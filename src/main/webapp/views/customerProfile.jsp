<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Customer" %>
<%@ page import="com.swp391.model.Staff" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    Object sessionUser = session.getAttribute("customer");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String fullName = "";
    String email = "";
    String phone = "Not updated yet";
    String status = "ACTIVE";
    String createdAtStr = "Not updated yet";
    String roleName = (String) session.getAttribute("role");
    if (roleName == null || roleName.isEmpty()) {
        roleName = "CUSTOMER";
    }

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

    if (sessionUser instanceof Customer) {
        Customer c = (Customer) sessionUser;
        fullName = c.getFullName();
        email = c.getEmail();
        if (c.getPhone() != null && !c.getPhone().trim().isEmpty()) {
            phone = c.getPhone();
        }
        if (c.getStatus() != null && !c.getStatus().trim().isEmpty()) {
            status = c.getStatus();
        }
        if (c.getCreatedAt() != null) {
            createdAtStr = c.getCreatedAt().format(dtf);
        }
    } else if (sessionUser instanceof Staff) {
        Staff s = (Staff) sessionUser;
        fullName = s.getFullName();
        email = s.getEmail();
        if (s.getPhone() != null && !s.getPhone().trim().isEmpty()) {
            phone = s.getPhone();
        }
        if (s.getStatus() != null && !s.getStatus().trim().isEmpty()) {
            status = s.getStatus();
        }
        if (s.getCreatedAt() != null) {
            createdAtStr = s.getCreatedAt().format(dtf);
        }
        if (s.getRole() != null) {
            roleName = s.getRole().getRoleName();
        }
    }

    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) {
        activeTab = request.getParameter("tab");
    }
    if (activeTab == null || activeTab.trim().isEmpty()) {
        activeTab = "info";
    }

    boolean isResetStep = "reset".equals(request.getAttribute("step"));
    String checkedEmail = (String) request.getAttribute("checkedEmail");
    if (checkedEmail == null || checkedEmail.isEmpty()) {
        checkedEmail = (String) request.getAttribute("emailInput");
    }
    if (checkedEmail == null || checkedEmail.isEmpty()) {
        checkedEmail = email;
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Customer Profile - Headphone Store</title>

        <!-- Google Font -->
        <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

        <!-- Bootstrap -->
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css"/>

        <!-- Slick -->
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick.css"/>
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick-theme.css"/>

        <!-- nouislider -->
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/nouislider.min.css"/>

        <!-- Font Awesome Icon -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

        <!-- Custom stylesheet -->
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css"/>

        <style>
            .profile-card {
                background: #ffffff;
                padding: 25px;
                border-radius: 6px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.06);
                border: 1px solid #e4e7ed;
                margin-bottom: 30px;
            }
            .profile-sidebar-header {
                text-align: center;
                padding-bottom: 20px;
                border-bottom: 1px solid #eee;
                margin-bottom: 20px;
            }
            .profile-avatar-icon {
                font-size: 68px;
                color: #D10024;
                margin-bottom: 10px;
            }
            .profile-nav-list {
                list-style: none;
                padding: 0;
                margin: 0;
            }
            .profile-nav-list li {
                margin-bottom: 8px;
            }
            .profile-nav-list li a {
                display: block;
                padding: 12px 16px;
                border-radius: 4px;
                color: #333;
                font-weight: 600;
                transition: 0.2s;
                text-decoration: none;
                background-color: #f8f9fa;
                border-left: 4px solid transparent;
            }
            .profile-nav-list li a i {
                margin-right: 10px;
                width: 18px;
                text-align: center;
            }
            .profile-nav-list li a:hover,
            .profile-nav-list li.active a {
                background-color: #fef2f2;
                color: #D10024;
                border-left-color: #D10024;
            }
            .profile-nav-list li.logout-item a {
                color: #c82333;
                background-color: #fff5f5;
            }
            .profile-nav-list li.logout-item a:hover {
                background-color: #c82333;
                color: #fff;
            }
            .section-title h3.title {
                font-size: 18px;
                font-weight: 700;
                text-transform: uppercase;
                margin-top: 0;
                padding-bottom: 12px;
                border-bottom: 2px solid #D10024;
            }
            .info-label {
                font-size: 12px;
                color: #888;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 4px;
                font-weight: 600;
            }
            .info-value {
                font-size: 15px;
                font-weight: 600;
                color: #2b2d42;
                margin-bottom: 18px;
                padding-bottom: 8px;
                border-bottom: 1px dashed #eee;
            }
            .status-badge {
                display: inline-block;
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 700;
                color: #fff;
                background-color: #28a745;
                letter-spacing: 0.5px;
            }
        </style>
    </head>

    <body>
        <!-- HEADER -->
        <header>
            <!-- TOP HEADER -->
            <div id="top-header">
                <div class="container">
                    <ul class="header-links pull-left">
                        <li><a href="#"><i class="fa fa-phone"></i> +021-95-51-84</a></li>
                        <li><a href="#"><i class="fa fa-envelope-o"></i> email@email.com</a></li>
                        <li><a href="#"><i class="fa fa-map-marker"></i> 1734 Stonecoal Road</a></li>
                    </ul>
                    <ul class="header-links pull-right">
                        <li><a href="#"><i class="fa fa-dollar"></i> USD</a></li>
                        <li>
                            <a href="${pageContext.request.contextPath}/profile">
                                <i class="fa fa-user"></i> <%= fullName %>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
            <!-- /TOP HEADER -->

            <!-- MAIN HEADER -->
            <div id="header">
                <div class="container">
                    <div class="row">
                        <!-- LOGO -->
                        <div class="col-md-3">
                            <div class="header-logo">
                                <a href="${pageContext.request.contextPath}/views/home.jsp" class="logo">
                                    <img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="Headphone Store">
                                </a>
                            </div>
                        </div>
                        <!-- /LOGO -->

                        <!-- SEARCH BAR -->
                        <div class="col-md-6">
                            <div class="header-search">
                                <form action="${pageContext.request.contextPath}/views/home.jsp" method="get">
                                    <select class="input-select">
                                        <option value="0">All Categories</option>
                                    </select>
                                    <input class="input" placeholder="Search products here">
                                    <button class="search-btn">Search</button>
                                </form>
                            </div>
                        </div>
                        <!-- /SEARCH BAR -->

                        <!-- ACCOUNT / CART -->
                        <div class="col-md-3 clearfix">
                            <div class="header-ctn">
                                <div>
                                    <a href="#">
                                        <i class="fa fa-heart-o"></i>
                                        <span>Wishlist</span>
                                    </a>
                                </div>
                                <div>
                                    <a href="#">
                                        <i class="fa fa-shopping-cart"></i>
                                        <span>Your Cart</span>
                                    </a>
                                </div>
                                <div class="menu-toggle">
                                    <a href="#">
                                        <i class="fa fa-bars"></i>
                                        <span>Menu</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- /MAIN HEADER -->
        </header>
        <!-- /HEADER -->

        <!-- BREADCRUMB -->
        <div id="breadcrumb" class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12">
                        <ul class="breadcrumb-tree">
                            <li><a href="${pageContext.request.contextPath}/views/home.jsp">Home</a></li>
                            <li class="active">Customer Profile</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        <!-- /BREADCRUMB -->

        <!-- SECTION: PROFILE CONTENT -->
        <div class="section" style="padding-top: 20px; padding-bottom: 60px;">
            <div class="container">
                <div class="row">

                    <!-- SIDEBAR -->
                    <div class="col-md-4">
                        <div class="profile-card">
                            <div class="profile-sidebar-header">
                                <div class="profile-avatar-icon">
                                    <i class="fa fa-user-circle"></i>
                                </div>
                                <h4 style="margin: 5px 0; font-weight: 700;"><%= fullName %></h4>
                                <span class="text-muted"><%= email %></span>
                            </div>

                            <ul class="profile-nav-list">
                                <li class="<%= !"changePassword".equals(activeTab) ? "active" : "" %>" id="tab-btn-info">
                                    <a href="javascript:void(0);" onclick="switchProfileTab('info')">
                                        <i class="fa fa-id-card-o"></i> Personal Information
                                    </a>
                                </li>
                                <li id="tab-btn-password">
                                    <a href="${pageContext.request.contextPath}/change-password">
                                        <i class="fa fa-key"></i> Change Password
                                    </a>
                                </li>
                                <li class="logout-item">
                                    <a href="${pageContext.request.contextPath}/logout" onclick="return confirm('Are you sure you want to log out?');">
                                        <i class="fa fa-sign-out"></i> Log Out
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                    <!-- /SIDEBAR -->

                    <!-- MAIN TAB CONTENT -->
                    <div class="col-md-8">

                        <!-- ALERTS -->
                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger" style="border-radius: 4px; margin-bottom: 20px;">
                                <i class="fa fa-exclamation-triangle"></i> <%= request.getAttribute("error") %>
                            </div>
                        <% } %>

                        <% if (request.getAttribute("successMessage") != null) { %>
                            <div class="alert alert-success" style="background-color: #d4edda; color: #155724; border-radius: 4px; margin-bottom: 20px;">
                                <i class="fa fa-check-circle"></i> <%= request.getAttribute("successMessage") %>
                            </div>
                        <% } %>

                        <!-- PERSONAL INFORMATION -->
                        <div id="tab-content-info" style="<%= "MAILPassword".equals(activeTab) ? "display: none;" : "display: block;" %>">
                            <div class="profile-card">
                                <div class="section-title">
                                    <h3 class="title"><i class="fa fa-user"></i> Personal Information</h3>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="info-label">Full Name</div>
                                        <div class="info-value"><%= fullName %></div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="info-label">Email Address</div>
                                        <div class="info-value"><%= email %></div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="info-label">Phone Number</div>
                                        <div class="info-value"><%= phone %></div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="info-label">Registration Date</div>
                                        <div class="info-value"><%= createdAtStr %></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- CHANGE PASSWORD -->
                        <div id="tab-content-password" style="<%= "changePassword".equals(activeTab) ? "display: block;" : "display: none;" %>">
                            <div class="profile-card">
                                <div class="section-title">
                                    <h3 class="title"><i class="fa fa-key"></i> <%= isResetStep ? "Reset New Password" : "Change Password" %></h3>
                                </div>

                                <% if (isResetStep) { %>
                                    <!-- NHAP MAT KHAU MOI VA CONFIRM -->
                                    <p style="color: #666; margin-bottom: 20px;">
                                        Please enter your new password for account: <strong><%= checkedEmail %></strong>
                                        <br><small class="text-danger"><i class="fa fa-info-circle"></i> New password must not be the same as your old password.</small>
                                    </p>

                                    <form action="${pageContext.request.contextPath}/profile" method="post">
                                        <input type="hidden" name="action" value="changePassword">
                                        <input type="hidden" name="email" value="<%= checkedEmail %>">

                                        <div class="form-group">
                                            <label style="font-weight: 600;">New Password</label>
                                            <input class="input"
                                                   type="password"
                                                   name="newPassword"
                                                   placeholder="Enter new password (at least 6 characters)"
                                                   required>
                                        </div>

                                        <div class="form-group">
                                            <label style="font-weight: 600;">Confirm New Password</label>
                                            <input class="input"
                                                   type="password"
                                                   name="confirmPassword"
                                                   placeholder="Confirm new password"
                                                   required>
                                        </div>

                                        <div style="margin-top: 25px;">
                                            <button type="submit" class="primary-btn btn-block">
                                                UPDATE PASSWORD
                                            </button>
                                        </div>

                                        <div class="text-center" style="margin-top: 15px;">
                                            <a href="${pageContext.request.contextPath}/profile?tab=changePassword" class="text-muted">
                                                <i class="fa fa-refresh"></i> Re-verify Email
                                            </a>
                                        </div>
                                    </form>

                                <% } else { %>
                                    <!-- NHAP CHECK  -->
                                    <p style="color: #666; margin-bottom: 20px;">
                                        To change your password, please confirm your registered email address below.
                                    </p>

                                    <form action="${pageContext.request.contextPath}/profile" method="post">
                                        <input type="hidden" name="action" value="checkEmail">

                                        <div class="form-group">
                                            <label style="font-weight: 600;">Account Email Address</label>
                                            <input class="input"
                                                   type="email"
                                                   name="email"
                                                   value="<%= checkedEmail %>"
                                                   placeholder="Enter your email"
                                                   required>
                                        </div>

                                        <div style="margin-top: 25px;">
                                            <button type="submit" class="primary-btn btn-block">
                                                VERIFY EMAIL & CONTINUE
                                            </button>
                                        </div>
                                    </form>
                                <% } %>

                            </div>
                        </div>

                    </div>
                    <!-- /MAIN TAB CONTENT -->

                </div>
            </div>
        </div>
        <!-- /SECTION -->

        <!-- FOOTER -->
        <footer id="footer">
            <div class="section">
                <div class="container">
                    <div class="row">
                        <div class="col-md-3 col-xs-6">
                            <div class="footer">
                                <h3 class="footer-title">About Us</h3>
                                <p>We offer premium headphones, earphones, and audio accessories with best quality and warranty.</p>
                                <ul class="footer-links">
                                    <li><a href="#"><i class="fa fa-map-marker"></i> 1734 Stonecoal Road</a></li>
                                    <li><a href="#"><i class="fa fa-phone"></i> +021-95-51-84</a></li>
                                    <li><a href="#"><i class="fa fa-envelope-o"></i> email@email.com</a></li>
                                </ul>
                            </div>
                        </div>

                        <div class="col-md-3 col-xs-6">
                            <div class="footer">
                                <h3 class="footer-title">Categories</h3>
                                <ul class="footer-links">
                                    <li><a href="#">Hot Deals</a></li>
                                    <li><a href="#">Headphones</a></li>
                                    <li><a href="#">Wireless</a></li>
                                    <li><a href="#">Accessories</a></li>
                                </ul>
                            </div>
                        </div>

                        <div class="clearfix visible-xs"></div>

                        <div class="col-md-3 col-xs-6">
                            <div class="footer">
                                <h3 class="footer-title">Information</h3>
                                <ul class="footer-links">
                                    <li><a href="#">About Us</a></li>
                                    <li><a href="#">Contact Us</a></li>
                                    <li><a href="#">Privacy Policy</a></li>
                                    <li><a href="#">Terms & Conditions</a></li>
                                </ul>
                            </div>
                        </div>

                        <div class="col-md-3 col-xs-6">
                            <div class="footer">
                                <h3 class="footer-title">Service</h3>
                                <ul class="footer-links">
                                    <li><a href="${pageContext.request.contextPath}/profile">My Account</a></li>
                                    <li><a href="${pageContext.request.contextPath}/views/home.jsp">Home</a></li>
                                    <li><a href="#">Help</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="bottom-footer" class="section">
                <div class="container">
                    <div class="row">
                        <div class="col-md-12 text-center">
                            <span class="copyright">
                                Copyright &copy; <script>document.write(new Date().getFullYear());</script> Headphone Store | All rights reserved.
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </footer>
        <!-- /FOOTER -->

        <!-- jQuery Plugins -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/slick.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/nouislider.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/jquery.zoom.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

        <script>
            function switchProfileTab(tabName) {
                if (tabName === 'password') {
                    $('#tab-content-info').hide();
                    $('#tab-content-password').show();
                    $('#tab-btn-info').removeClass('active');
                    $('#tab-btn-password').addClass('active');
                } else {
                    $('#tab-content-password').hide();
                    $('#tab-content-info').show();
                    $('#tab-btn-password').removeClass('active');
                    $('#tab-btn-info').addClass('active');
                }
            }
        </script>
    </body>
</html>
