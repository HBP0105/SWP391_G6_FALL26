<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Login - Headphone Store</title>

        <!-- Google Font -->
        <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700"
              rel="stylesheet">

        <!-- Bootstrap -->
        <link type="text/css"
              rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">

        <!-- Font Awesome -->
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

        <!-- Main Style -->
        <link type="text/css"
              rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/style.css">
    </head>

    <body>

        <!-- LOGIN -->
        <div class="section"
             style="min-height: 70vh; display: flex; align-items: center;">

            <div class="container">
                <div class="row">

                    <div class="col-md-6 col-md-offset-3">

                        <div class="billing-details">

                            <div class="section-title">
                                <h3 class="title text-center">
                                    Login
                                </h3>
                            </div>

                            <form action="${pageContext.request.contextPath}/login"
                                  method="post">

                                <% if (request.getAttribute("error") != null) { %>
                                <div class="alert alert-danger">
                                    <%= request.getAttribute("error") %>
                                </div>
                                <% } %>
                                <% if ("true".equals(request.getParameter("registerSuccess"))) { %>
                                <div class="alert alert-success" style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin-bottom: 15px;">
                                    Register successfully. Please login!
                                </div>
                                <% } %>
                                <% if ("true".equals(request.getParameter("resetSuccess"))) { %>
                                <div class="alert alert-success" style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin-bottom: 15px;">
                                    Password reset successfully! Please login with your new password.
                                </div>
                                <% } %>

                                <div class="form-group">
                                    <input class="input"
                                           type="text"
                                           name="username"
                                           placeholder="Email"
                                           required>
                                </div>

                                <div class="form-group">
                                    <input class="input"
                                           type="password"
                                           name="password"
                                           placeholder="Password"
                                           required>
                                </div>

                                <div class="row">

                                    <div class="col-md-6">
                                        <label>
                                            <input type="checkbox"
                                                   name="remember">
                                            Remember me
                                        </label>
                                    </div>

                                    <div class="col-md-6 text-right">
                                        <a href="${pageContext.request.contextPath}/forgot-password">
                                            Forgot Password?
                                        </a>
                                    </div>

                                </div>

                                <button type="submit"
                                        class="primary-btn btn-block">
                                    LOGIN
                                </button>

                            </form>

                            <div class="text-center">
                                <p>
                                    Don't have an account?
                                    <a href="${pageContext.request.contextPath}/register">
                                        <b>Register</b>
                                    </a>
                                </p>
                            </div>

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

        <!-- JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/slick.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/nouislider.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/jquery.zoom.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

    </body>

</html>