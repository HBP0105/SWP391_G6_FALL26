<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.swp391.model.Customer" %>
<%@ page import="com.swp391.model.Staff" %>

<%
    Object sessionUser = session.getAttribute("customer");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String email = "";
    if (sessionUser instanceof Customer) {
        email = ((Customer) sessionUser).getEmail();
    } else if (sessionUser instanceof Staff) {
        email = ((Staff) sessionUser).getEmail();
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

        <title>Change Password - Headphone Store</title>

        <!-- Google Font -->
        <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

        <!-- Bootstrap -->
        <link type="text/css"
              rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

        <!-- Font Awesome -->
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

        <!-- Main Style -->
        <link type="text/css"
              rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/style.css" />
    </head>

    <body>

        <!-- HEADER -->
        <header>
            <div class="container">
                <div class="row">
                    <div class="col-md-12 text-center">
                        <div class="header-logo" style="padding: 25px 0;">
                            <a href="${pageContext.request.contextPath}/home" class="logo">
                                <h2 style="margin: 0; font-weight: 700; color: #ffffff;">
                                    HEADPHONE STORE
                                </h2>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <!-- CHANGE PASSWORD -->
        <div class="section" style="min-height: 70vh; display: flex; align-items: center;">
            <div class="container">
                <div class="row">

                    <div class="col-md-6 col-md-offset-3">

                        <div class="billing-details">

                            <div class="section-title">
                                <h3 class="title text-center">
                                    <%= isResetStep ? "Set New Password" : "Change Password" %>
                                </h3>
                            </div>

                            <!-- Error -->
                            <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger">
                                <i class="fa fa-exclamation-triangle"></i> <%= request.getAttribute("error") %>
                            </div>
                            <% } %>

                            <!-- Success -->
                            <% if (request.getAttribute("successMessage") != null) { %>
                            <div class="alert alert-success">
                                <i class="fa fa-check-circle"></i> <%= request.getAttribute("successMessage") %>
                            </div>
                            <% } %>

                            <% if (isResetStep) { %>
                            <p class="text-center" style="margin-bottom: 20px;">
                                Enter a new password for <strong><%= checkedEmail %></strong>
                                <br><small class="text-danger"><i class="fa fa-info-circle"></i> New password must not be the same as your old password.</small>
                            </p>

                            <form action="${pageContext.request.contextPath}/change-password"
                                  method="post">
                                <input type="hidden" name="action" value="changePassword">
                                <input type="hidden" name="email" value="<%= checkedEmail %>">

                                <div class="form-group">
                                    <input class="input"
                                           type="password"
                                           name="newPassword"
                                           placeholder="New Password (at least 6 characters)"
                                           required>
                                </div>

                                <div class="form-group">
                                    <input class="input"
                                           type="password"
                                           name="confirmPassword"
                                           placeholder="Confirm New Password"
                                           required>
                                </div>

                                <button type="submit"
                                        class="primary-btn btn-block">
                                    UPDATE PASSWORD
                                </button>
                            </form>

                            <div class="text-center" style="margin-top: 15px;">
                                <a href="${pageContext.request.contextPath}/change-password" class="text-muted">
                                    <i class="fa fa-refresh"></i> Re-verify Email
                                </a>
                            </div>

                            <% } else { %>
                            <p class="text-center">
                                To change your password, please confirm your registered email address below.
                            </p>

                            <form action="${pageContext.request.contextPath}/change-password"
                                  method="post">
                                <input type="hidden" name="action" value="checkEmail">

                                <!-- Email -->
                                <div class="form-group">
                                    <input class="input"
                                           type="email"
                                           name="email"
                                           value="<%= checkedEmail %>"
                                           placeholder="Email"
                                           required>
                                </div>

                                <!-- Continue -->
                                <button type="submit"
                                        class="primary-btn btn-block">
                                    VERIFY EMAIL &amp; CONTINUE
                                </button>
                            </form>
                            <% } %>

                            <!-- Back to Profile -->
                            <div class="text-center" style="margin-top: 25px;">
                                <p>
                                    <a href="${pageContext.request.contextPath}/profile">
                                        <i class="fa fa-arrow-left"></i> Back to Profile
                                    </a>
                                </p>
                            </div>

                            <!-- Back Home -->
                            <div class="text-center">
                                <a href="${pageContext.request.contextPath}/views/home.jsp">
                                    <i class="fa fa-home"></i> Back to Home
                                </a>
                            </div>

                        </div>

                    </div>

                </div>
            </div>
        </div>

        <!-- jQuery Plugins -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/slick.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/nouislider.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/jquery.zoom.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

    </body>
</html>
