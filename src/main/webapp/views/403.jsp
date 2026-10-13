<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>403 - Forbidden</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/style.css">

    <style>
        .error-section {
            text-align: center;
            padding: 100px 0;
        }

        .error-code {
            font-size: 120px;
            font-weight: 700;
            color: #D10024;
        }

        .error-text {
            font-size: 24px;
            margin-bottom: 20px;
        }

        .error-section p {
            color: #555;
            margin-bottom: 0;
        }

        .error-btn {
            margin-top: 20px;
        }
    </style>
</head>

<body>

    <div class="section">
        <div class="container">
            <div class="error-section">

                <div class="error-code">403</div>

                <div class="error-text">
                    Access Forbidden
                </div>

                <p>
                    Sorry, you do not have permission to access this page.
                </p>

                <a href="${pageContext.request.contextPath}/home"
                   class="primary-btn error-btn">
                    Back to Home
                </a>

            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>

</body>
</html>