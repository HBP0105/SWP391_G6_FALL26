<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Forgot Password - Headphone Store</title>

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

        <%
            boolean isResetStep = "reset".equals(request.getAttribute("step"));
            String emailVal = request.getAttribute("email") != null ? (String) request.getAttribute("email") : "";
        %>

        <!-- FORGOT / RESET PASSWORD -->
        <div class="section" style="min-height: 70vh; display: flex; align-items: center;">
            <div class="container">
                <div class="row">

                    <div class="col-md-6 col-md-offset-3">

                        <div class="billing-details">

                            <div class="section-title">
                                <h3 class="title text-center">
                                    <%= isResetStep ? "Reset Password" : "Forgot Password" %>
                                </h3>
                            </div>

                            <!-- Error -->
                            <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger">
                                <%= request.getAttribute("error") %>
                            </div>
                            <% } %>

                            <!-- Success -->
                            <% if (request.getAttribute("message") != null) { %>
                            <div class="alert alert-success">
                                <%= request.getAttribute("message") %>
                            </div>
                            <% } %>

                            <% if (isResetStep) { %>
                            <p class="text-center" style="margin-bottom: 20px;">
                                Enter a new password for <strong><%= emailVal %></strong>
                            </p>

                            <form action="${pageContext.request.contextPath}/forgot-password"
                                  method="post">
                                <input type="hidden" name="action" value="resetPassword">
                                <input type="hidden" name="email" value="<%= emailVal %>">

                                <div class="form-group">
                                    <input class="input"
                                           type="password"
                                           name="newPassword"
                                           placeholder="New Password"
                                           required>
                                </div>

                                <div class="form-group">
                                    <input class="input"
                                           type="password"
                                           name="confirmPassword"
                                           placeholder="Confirm Password"
                                           required>
                                </div>

                                <button type="submit"
                                        class="primary-btn btn-block">
                                    UPDATE PASSWORD
                                </button>
                            </form>
                            <% } else { %>
                            <p class="text-center">
                                Enter your email address to reset your password.
                            </p>

                            <form action="${pageContext.request.contextPath}/forgot-password"
                                  method="post">
                                <input type="hidden" name="action" value="checkEmail">

                                <!-- Email -->
                                <div class="form-group">
                                    <input class="input"
                                           type="email"
                                           name="email"
                                           value="<%= emailVal %>"
                                           placeholder="Email"
                                           required>
                                </div>

                                <!-- Reset -->
                                <button type="submit"
                                        class="primary-btn btn-block">
                                    CONTINUE
                                </button>
                            </form>
                            <% } %>

                            <!-- Login -->
                            <div class="text-center" style="margin-top: 25px;">
                                <p>
                                    Remember your password?
                                    <a href="${pageContext.request.contextPath}/login">
                                        <b>Login</b>
                                    </a>
                                </p>
                            </div>

                            <!-- Register -->
                            <div class="text-center">
                                <p>
                                    Don't have an account?
                                    <a href="${pageContext.request.contextPath}/register">
                                        <b>Register</b>
                                    </a>
                                </p>
                            </div>

                            <!-- Back Home -->
                            <div class="text-center">
                                <a href="${pageContext.request.contextPath}/views/home.jsp">
                                    <i class="fa fa-arrow-left"></i>
                                    Back to Home
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