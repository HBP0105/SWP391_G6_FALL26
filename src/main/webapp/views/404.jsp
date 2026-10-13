<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>404 - Not Found</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

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

        .error-btn {
            margin-top: 20px;
        }
    </style>
</head>

<body>

   

    <div class="section">
        <div class="container">
            <div class="error-section">
                <div class="error-code">404</div>
                <div class="error-text">Oops! Page not found</div>
                <p>The page you are looking for might have been removed or is temporarily unavailable.</p>

                <a href="${pageContext.request.contextPath}/home" class="primary-btn error-btn">
                    Back to Home
                </a>
            </div>
        </div>
    </div>


    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
</body>
</html>