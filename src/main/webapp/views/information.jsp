<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Customer Information - Headphone Shop</title>
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <jsp:include page="/assets/components/header.jsp" />

    <main class="section">
        <div class="container">
            <div class="row">
                <aside class="col-md-3">
                    <div class="section-title"><h3 class="title">Information</h3></div>
                    <div class="list-group">
                        <a class="list-group-item ${topic == 'about' ? 'active' : ''}" href="${pageContext.request.contextPath}/information?topic=about">About Us</a>
                        <a class="list-group-item ${topic == 'contact' ? 'active' : ''}" href="${pageContext.request.contextPath}/information?topic=contact">Contact Us</a>
                        <a class="list-group-item ${topic == 'privacy' ? 'active' : ''}" href="${pageContext.request.contextPath}/information?topic=privacy">Privacy Policy</a>
                        <a class="list-group-item ${topic == 'returns' ? 'active' : ''}" href="${pageContext.request.contextPath}/information?topic=returns">Orders &amp; Returns</a>
                        <a class="list-group-item ${topic == 'terms' ? 'active' : ''}" href="${pageContext.request.contextPath}/information?topic=terms">Terms &amp; Conditions</a>
                        <a class="list-group-item ${topic == 'help' ? 'active' : ''}" href="${pageContext.request.contextPath}/information?topic=help">Help</a>
                    </div>
                </aside>
                <section class="col-md-9">
                    <div class="panel panel-default" style="padding: 28px; border: 1px solid #e4e7ed;">
                        <c:choose>
                            <c:when test="${topic == 'contact'}">
                                <h1>Contact Us</h1>
                                <p>Need help choosing a product or checking an order? Contact our support team.</p>
                                <p><i class="fa fa-phone"></i> <a href="tel:+8421955184">+021-95-51-84</a></p>
                                <p><i class="fa fa-envelope-o"></i> <a href="mailto:support@headphone-shop.com">support@headphone-shop.com</a></p>
                            </c:when>
                            <c:when test="${topic == 'privacy'}">
                                <h1>Privacy Policy</h1>
                                <p>We use customer information only to operate accounts, orders, delivery, support and product recommendations. We do not display payment credentials or passwords.</p>
                                <p>You can review and update your account information from the <a href="${pageContext.request.contextPath}/profile">profile page</a>.</p>
                            </c:when>
                            <c:when test="${topic == 'returns'}">
                                <h1>Orders &amp; Returns</h1>
                                <p>Use My Orders to review order status and open an eligible cancellation or return action.</p>
                                <a class="primary-btn" href="${pageContext.request.contextPath}/my-orders">View My Orders</a>
                            </c:when>
                            <c:when test="${topic == 'terms'}">
                                <h1>Terms &amp; Conditions</h1>
                                <p>Orders are confirmed at the displayed price and availability. Delivery, cancellation and return options depend on the current order status.</p>
                            </c:when>
                            <c:when test="${topic == 'help'}">
                                <h1>Help Center</h1>
                                <p>Browse products, compare models, manage your wishlist and track purchases from the links below.</p>
                                <p><a href="${pageContext.request.contextPath}/productList">Browse products</a> · <a href="${pageContext.request.contextPath}/compare">Compare products</a> · <a href="${pageContext.request.contextPath}/my-orders">Track an order</a></p>
                            </c:when>
                            <c:otherwise>
                                <h1>About Headphone Shop</h1>
                                <p>Headphone Shop specializes in authentic headphones and earbuds selected for sound quality, comfort and everyday reliability.</p>
                                <p>Our catalog supports clear product comparison, wishlists, order tracking and AI-assisted product discovery.</p>
                                <a class="primary-btn" href="${pageContext.request.contextPath}/productList">Shop Products</a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </section>
            </div>
        </div>
    </main>

    <jsp:include page="/assets/components/footer.jsp" />
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
