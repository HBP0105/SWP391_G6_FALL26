<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

        <title>Electro - HTML Ecommerce Template</title>

        <!-- Google font -->
        <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick.css" />
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick-theme.css" />
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/nouislider.min.css" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />
        <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
        <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
        <!--[if lt IE 9]>
                  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
                  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
                <![endif]-->

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
                            <%@ page import="com.swp391.model.Customer" %>
                            <%@ page import="com.swp391.model.Staff" %>
                            <%
                                    Object currentUser = session.getAttribute("customer");
                                    if (currentUser == null) {
                                        currentUser = session.getAttribute("user");
                                    }
                                    if (currentUser == null) {
                            %>
                        <!-- Chua dang nhap -->
                        <li>
                            <a href="${pageContext.request.contextPath}/login">
                                <i class="fa fa-user-o"></i> My Account
                            </a>
                        </li>
                        <%
                                } else {
                                        String displayName = "";
                                        if (currentUser instanceof Customer) {
                                                displayName = ((Customer) currentUser).getFullName();
                                        } else if (currentUser instanceof Staff) {
                                                displayName = ((Staff) currentUser).getFullName();
                                        }
                        %>
                        <!-- Da dang nhap -->
                        <li>
                            <a href="${pageContext.request.contextPath}/profile">
                                <i class="fa fa-user"></i> <%= displayName %>
                            </a>
                        </li>
                        <%
                                }
                        %>
                    </ul>
                </div>
            </div>
            <!-- /TOP HEADER -->

            <!-- MAIN HEADER -->
            <div id="header">
                <!-- container -->
                <div class="container">
                    <!-- row -->
                    <div class="row">
                        <!-- LOGO -->
                        <div class="col-md-3">
                            <div class="header-logo">
                                <a href="#" class="logo">
                                    <img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="">
                                </a>
                            </div>
                        </div>
                        <!-- /LOGO -->

                        <!-- SEARCH BAR -->
                        <div class="col-md-6">
                            <div class="header-search" style="position: relative;">
                                <form id="search-form" action="${pageContext.request.contextPath}/productList" method="get" autocomplete="off">
                                    <input id="search-input" class="input" name="q" placeholder="Search here" type="text">
                                    <button type="submit" class="search-btn"><i class="fa fa-search"></i> Search</button>
                                </form>
                                <!-- Autocomplete dropdown -->
                                <div id="search-suggestions" style="
                                    display: none;
                                    position: absolute;
                                    top: 100%;
                                    left: 0;
                                    right: 0;
                                    background: #fff;
                                    border: 1px solid #d4d4d4;
                                    border-top: none;
                                    z-index: 9999;
                                    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                                    border-radius: 0 0 4px 4px;
                                    max-height: 320px;
                                    overflow-y: auto;
                                "></div>
                            </div>
                        </div>
                        <!-- /SEARCH BAR -->

                        <!-- ACCOUNT -->
                        <div class="col-md-3 clearfix">
                            <div class="header-ctn">
                                <!-- Wishlist -->
                                <div>
                                    <a href="#">
                                        <i class="fa fa-heart-o"></i>
                                        <span>Your Wishlist</span>
                                        <div class="qty">2</div>
                                    </a>
                                </div>
                                <!-- /Wishlist -->

                                <!-- Cart -->
                                <div class="dropdown">
                                    <a class="dropdown-toggle" data-toggle="dropdown" aria-expanded="true">
                                        <i class="fa fa-shopping-cart"></i>
                                        <span>Your Cart</span>
                                        <div class="qty">3</div>
                                    </a>
                                    <div class="cart-dropdown">
                                        <div class="cart-list">
                                            <div class="product-widget">
                                                <div class="product-img">
                                                    <img src="${pageContext.request.contextPath}/assets/img/product01.png" alt="">
                                                </div>
                                                <div class="product-body">
                                                    <h3 class="product-name"><a href="#">product name goes here</a></h3>
                                                    <h4 class="product-price"><span class="qty">1x</span>$980.00</h4>
                                                </div>
                                                <button class="delete"><i class="fa fa-close"></i></button>
                                            </div>

                                            <div class="product-widget">
                                                <div class="product-img">
                                                    <img src="${pageContext.request.contextPath}/assets/img/product02.png" alt="">
                                                </div>
                                                <div class="product-body">
                                                    <h3 class="product-name"><a href="#">product name goes here</a></h3>
                                                    <h4 class="product-price"><span class="qty">3x</span>$980.00</h4>
                                                </div>
                                                <button class="delete"><i class="fa fa-close"></i></button>
                                            </div>
                                        </div>
                                        <div class="cart-summary">
                                            <small>3 Item(s) selected</small>
                                            <h5>SUBTOTAL: $2940.00</h5>
                                        </div>
                                        <div class="cart-btns">
                                            <a href="cart.jsp">View Cart</a>
                                            <a href="checkout.jsp">Checkout <i class="fa fa-arrow-circle-right"></i></a>
                                        </div>
                                    </div>
                                </div>
                                <!-- /Cart -->

                                <!-- Menu Toogle -->
                                <div class="menu-toggle">
                                    <a href="#">
                                        <i class="fa fa-bars"></i>
                                        <span>Menu</span>
                                    </a>
                                </div>
                                <!-- /Menu Toogle -->
                            </div>
                        </div>
                        <!-- /ACCOUNT -->
                    </div>
                    <!-- row -->
                </div>
                <!-- container -->
            </div>
            <!-- /MAIN HEADER -->
        </header>
        <!-- /HEADER -->

        <!-- NAVIGATION -->
        <nav id="navigation">
            <!-- container -->
            <div class="container">
                <!-- responsive-nav -->
                <div id="responsive-nav">
                    <!-- NAV -->
                    <ul class="main-nav nav navbar-nav">
                        <li class="active"><a href="${pageContext.request.contextPath}/home">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/home#hot-deal">Hot Deals</a></li>
                        <li><a href="#">Headphones</a></li>
                        <li><a href="#">Earbuds</a></li>
                    </ul>
                    <!-- /NAV -->
                </div>
                <!-- /responsive-nav -->
            </div>
            <!-- /container -->
        </nav>
        <!-- /NAVIGATION -->

        <!-- SECTION -->
        <div class="section">
            <!-- container -->
            <div class="container">
                <!-- row -->
                <div class="row">
                    <!-- shop -->
                    <div class="col-md-4 col-xs-6">
                        <div class="shop">
                            <div class="shop-img">
                                <img src="${pageContext.request.contextPath}/assets/img/shop01.png" alt="Headphones">
                            </div>
                            <div class="shop-body">
                                <h3>Headphones<br>Collection</h3>
                                <a href="#" class="cta-btn">Shop now <i class="fa fa-arrow-circle-right"></i></a>
                            </div>
                        </div>
                    </div>
                    <!-- /shop -->

                    <!-- shop -->
                    <div class="col-md-4 col-xs-6">
                        <div class="shop">
                            <div class="shop-img">
                                <img src="${pageContext.request.contextPath}/assets/img/shop03.png" alt="Earbuds">
                            </div>
                            <div class="shop-body">
                                <h3>Earbuds<br>Collection</h3>
                                <a href="#" class="cta-btn">Shop now <i class="fa fa-arrow-circle-right"></i></a>
                            </div>
                        </div>
                    </div>
                    <!-- /shop -->

                    <!-- shop -->
                    <div class="col-md-4 col-xs-6">
                        <div class="shop">
                            <div class="shop-img">
                                <img src="${pageContext.request.contextPath}/assets/img/shop02.png" alt="Wireless Audio">
                            </div>
                            <div class="shop-body">
                                <h3>Wireless Audio<br>Collection</h3>
                                <a href="#" class="cta-btn">Shop now <i class="fa fa-arrow-circle-right"></i></a>
                            </div>
                        </div>
                    </div>
                    <!-- /shop -->
                </div>
                <!-- /row -->
            </div>
            <!-- /container -->
        </div>
        <!-- /SECTION -->

        <!-- SECTION -->
        <div class="section">
            <!-- container -->
            <div class="container">
                <!-- row -->
                <div class="row">

                    <!-- section title -->
                    <div class="col-md-12">
                        <div class="section-title">
                            <h3 class="title">New Products</h3>
                            <div class="section-nav">
                                <ul class="section-tab-nav tab-nav">
                                    <li class="active"><a data-toggle="tab" href="#tab1">All</a></li>
                                    <li><a data-toggle="tab" href="#tab1">Headphones</a></li>
                                    <li><a data-toggle="tab" href="#tab1">Earbuds</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <!-- /section title -->

                    <!-- Products tab & slick -->
                    <div class="col-md-12">
                        <div class="row">
                            <div class="products-tabs">
                                <!-- tab -->
                                <div id="tab1" class="tab-pane active">
                                    <div class="products-slick" data-nav="#slick-nav-1">
                                        <c:forEach var="product" items="${newProducts}">
                                            <!-- product -->
                                            <div class="product">
                                                <div class="product-img">
                                                    <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.productName}">
                                                    <div class="product-label">
                                                        <span class="new">NEW</span>
                                                    </div>
                                                </div>
                                                <div class="product-body">
                                                    <p class="product-category">${product.categoryName}</p>
                                                    <h3 class="product-name"><a href="#">${product.productName}</a></h3>
                                                    <h4 class="product-price"><fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/> &#8363;</h4>
                                                    <div class="product-rating">
                                                        <i class="fa fa-star"></i>
                                                        <i class="fa fa-star"></i>
                                                        <i class="fa fa-star"></i>
                                                        <i class="fa fa-star"></i>
                                                        <i class="fa fa-star-o"></i>
                                                    </div>
                                                    <div class="product-btns">
                                                        <button class="add-to-wishlist"><i class="fa fa-heart-o"></i><span class="tooltipp">add to wishlist</span></button>
                                                        <button class="add-to-compare"><i class="fa fa-exchange"></i><span class="tooltipp">add to compare</span></button>
                                                        <button class="quick-view"><i class="fa fa-eye"></i><span class="tooltipp">quick view</span></button>
                                                    </div>
                                                </div>
                                                <div class="add-to-cart">
                                                    <button class="add-to-cart-btn"><i class="fa fa-shopping-cart"></i> add to cart</button>
                                                </div>
                                            </div>
                                            <!-- /product -->
                                        </c:forEach>
                                    </div>
                                    <div id="slick-nav-1" class="products-slick-nav"></div>
                                </div>
                                <!-- /tab -->
                            </div>
                        </div>
                    </div>
                    <!-- Products tab & slick -->
                </div>
                <!-- /row -->
            </div>
            <!-- /container -->
        </div>
        <!-- /SECTION -->

        <!-- HOT DEAL SECTION -->
        <div id="hot-deal" class="section">
            <!-- container -->
            <div class="container">
                <!-- row -->
                <div class="row">
                    <div class="col-md-12">
                        <div class="hot-deal">
                            <ul class="hot-deal-countdown">
                                <li>
                                    <div>
                                        <h3>02</h3>
                                        <span>Days</span>
                                    </div>
                                </li>
                                <li>
                                    <div>
                                        <h3>10</h3>
                                        <span>Hours</span>
                                    </div>
                                </li>
                                <li>
                                    <div>
                                        <h3>34</h3>
                                        <span>Mins</span>
                                    </div>
                                </li>
                                <li>
                                    <div>
                                        <h3>60</h3>
                                        <span>Secs</span>
                                    </div>
                                </li>
                            </ul>
                            <h2 class="text-uppercase">hot deal this week</h2>
                            <p>New Collection Up to 50% OFF</p>
                            <a class="primary-btn cta-btn" href="#">Shop now</a>
                        </div>
                    </div>
                </div>
                <!-- /row -->
            </div>
            <!-- /container -->
        </div>
        <!-- /HOT DEAL SECTION -->

        <!-- SECTION -->
        <div class="section">
            <!-- container -->
            <div class="container">
                <!-- row -->
                <div class="row">

                    <!-- section title -->
                    <div class="col-md-12">
                        <div class="section-title">
                            <h3 class="title">Top Selling</h3>
                            <div class="section-nav">
                                <ul class="section-tab-nav tab-nav">
                                    <li class="active"><a data-toggle="tab" href="#tab2">All</a></li>
                                    <li><a data-toggle="tab" href="#tab2">Headphones</a></li>
                                    <li><a data-toggle="tab" href="#tab2">Earbuds</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <!-- /section title -->

                    <!-- Products tab & slick -->
                    <div class="col-md-12">
                        <div class="row">
                            <div class="products-tabs">
                                <!-- tab -->
                                <div id="tab2" class="tab-pane fade in active">
                                    <div class="products-slick" data-nav="#slick-nav-2">
                                        <c:forEach var="product" items="${topSellingProducts}">
                                            <!-- product -->
                                            <div class="product">
                                                <div class="product-img">
                                                    <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.productName}">
                                                </div>
                                                <div class="product-body">
                                                    <p class="product-category">${product.categoryName}</p>
                                                    <h3 class="product-name"><a href="#">${product.productName}</a></h3>
                                                    <h4 class="product-price"><fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/> &#8363;</h4>
                                                    <div class="product-rating">
                                                        <i class="fa fa-star"></i>
                                                        <i class="fa fa-star"></i>
                                                        <i class="fa fa-star"></i>
                                                        <i class="fa fa-star"></i>
                                                        <i class="fa fa-star-o"></i>
                                                    </div>
                                                    <div class="product-btns">
                                                        <button class="add-to-wishlist"><i class="fa fa-heart-o"></i><span class="tooltipp">add to wishlist</span></button>
                                                        <button class="add-to-compare"><i class="fa fa-exchange"></i><span class="tooltipp">add to compare</span></button>
                                                        <button class="quick-view"><i class="fa fa-eye"></i><span class="tooltipp">quick view</span></button>
                                                    </div>
                                                </div>
                                                <div class="add-to-cart">
                                                    <button class="add-to-cart-btn"><i class="fa fa-shopping-cart"></i> add to cart</button>
                                                </div>
                                            </div>
                                            <!-- /product -->
                                        </c:forEach>
                                    </div>
                                    <div id="slick-nav-2" class="products-slick-nav"></div>
                                </div>
                                <!-- /tab -->
                            </div>
                        </div>
                    </div>
                    <!-- /Products tab & slick -->
                </div>
                <!-- /row -->
            </div>
            <!-- /container -->
        </div>
        <!-- /SECTION -->
        <!-- SECTION -->
        <div class="section">
            <!-- container -->
            <div class="container">
                <!-- row -->
                <div class="row">

                    <div class="col-md-4 col-xs-6">
                        <div class="section-title">
                            <h4 class="title">Top Selling - Earbuds</h4>
                            <div class="section-nav">
                                <div id="slick-nav-3" class="products-slick-nav"></div>
                            </div>
                        </div>

                        <div class="products-widget-slick" data-nav="#slick-nav-3">
                            <div>
                                <c:forEach var="product" items="${topEarbuds}" begin="0" end="2">
                                    <!-- product widget -->
                                    <div class="product-widget">
                                        <div class="product-img">
                                            <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.productName}">
                                        </div>
                                        <div class="product-body">
                                            <p class="product-category">${product.categoryName}</p>
                                            <h3 class="product-name"><a href="#">${product.productName}</a></h3>
                                            <h4 class="product-price"><fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/> &#8363;</h4>
                                        </div>
                                    </div>
                                    <!-- /product widget -->
                                </c:forEach>
                            </div>
                            <div>
                                <c:forEach var="product" items="${topEarbuds}" begin="3" end="5">
                                    <!-- product widget -->
                                    <div class="product-widget">
                                        <div class="product-img">
                                            <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.productName}">
                                        </div>
                                        <div class="product-body">
                                            <p class="product-category">${product.categoryName}</p>
                                            <h3 class="product-name"><a href="#">${product.productName}</a></h3>
                                            <h4 class="product-price"><fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/> &#8363;</h4>
                                        </div>
                                    </div>
                                    <!-- /product widget -->
                                </c:forEach>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4 col-xs-6">
                        <div class="section-title">
                            <h4 class="title">Top Selling - Headphones</h4>
                            <div class="section-nav">
                                <div id="slick-nav-4" class="products-slick-nav"></div>
                            </div>
                        </div>

                        <div class="products-widget-slick" data-nav="#slick-nav-4">
                            <div>
                                <c:forEach var="product" items="${topHeadphones}" begin="0" end="2">
                                    <!-- product widget -->
                                    <div class="product-widget">
                                        <div class="product-img">
                                            <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.productName}">
                                        </div>
                                        <div class="product-body">
                                            <p class="product-category">${product.categoryName}</p>
                                            <h3 class="product-name"><a href="#">${product.productName}</a></h3>
                                            <h4 class="product-price"><fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/> &#8363;</h4>
                                        </div>
                                    </div>
                                    <!-- /product widget -->
                                </c:forEach>
                            </div>
                            <div>
                                <c:forEach var="product" items="${topHeadphones}" begin="3" end="5">
                                    <!-- product widget -->
                                    <div class="product-widget">
                                        <div class="product-img">
                                            <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.productName}">
                                        </div>
                                        <div class="product-body">
                                            <p class="product-category">${product.categoryName}</p>
                                            <h3 class="product-name"><a href="#">${product.productName}</a></h3>
                                            <h4 class="product-price"><fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/> &#8363;</h4>
                                        </div>
                                    </div>
                                    <!-- /product widget -->
                                </c:forEach>
                            </div>
                        </div>
                    </div>

                    <div class="clearfix visible-sm visible-xs"></div>

                    <div class="col-md-4 col-xs-6">
                        <div class="section-title">
                            <h4 class="title">Top Selling - All</h4>
                            <div class="section-nav">
                                <div id="slick-nav-5" class="products-slick-nav"></div>
                            </div>
                        </div>

                        <div class="products-widget-slick" data-nav="#slick-nav-5">
                            <div>
                                <c:forEach var="product" items="${topSellingProducts}" begin="0" end="2">
                                    <!-- product widget -->
                                    <div class="product-widget">
                                        <div class="product-img">
                                            <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.productName}">
                                        </div>
                                        <div class="product-body">
                                            <p class="product-category">${product.categoryName}</p>
                                            <h3 class="product-name"><a href="#">${product.productName}</a></h3>
                                            <h4 class="product-price"><fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/> &#8363;</h4>
                                        </div>
                                    </div>
                                    <!-- /product widget -->
                                </c:forEach>
                            </div>
                            <div>
                                <c:forEach var="product" items="${topSellingProducts}" begin="3" end="5">
                                    <!-- product widget -->
                                    <div class="product-widget">
                                        <div class="product-img">
                                            <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.productName}">
                                        </div>
                                        <div class="product-body">
                                            <p class="product-category">${product.categoryName}</p>
                                            <h3 class="product-name"><a href="#">${product.productName}</a></h3>
                                            <h4 class="product-price"><fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/> &#8363;</h4>
                                        </div>
                                    </div>
                                    <!-- /product widget -->
                                </c:forEach>
                            </div>
                        </div>
                    </div>

                </div>
                <!-- /row -->
            </div>
            <!-- /container -->
        </div>
        <!-- /SECTION -->

        <!-- NEWSLETTER -->
        <div id="newsletter" class="section">
            <!-- container -->
            <div class="container">
                <!-- row -->
                <div class="row">
                    <div class="col-md-12">
                        <div class="newsletter">
                            <p>Sign Up for the <strong>NEWSLETTER</strong></p>
                            <form>
                                <input class="input" type="email" placeholder="Enter Your Email">
                                <button class="newsletter-btn"><i class="fa fa-envelope"></i> Subscribe</button>
                            </form>
                            <ul class="newsletter-follow">
                                <li>
                                    <a href="#"><i class="fa fa-facebook"></i></a>
                                </li>
                                <li>
                                    <a href="#"><i class="fa fa-twitter"></i></a>
                                </li>
                                <li>
                                    <a href="#"><i class="fa fa-instagram"></i></a>
                                </li>
                                <li>
                                    <a href="#"><i class="fa fa-pinterest"></i></a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
                <!-- /row -->
            </div>
            <!-- /container -->
        </div>
        <!-- /NEWSLETTER -->

        <!-- FOOTER -->
        <footer id="footer">
            <!-- top footer -->
            <div class="section">
                <!-- container -->
                <div class="container">
                    <!-- row -->
                    <div class="row">
                        <div class="col-md-3 col-xs-6">
                            <div class="footer">
                                <h3 class="footer-title">About Us</h3>
                                <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
                                    incididunt ut.</p>
                                <ul class="footer-links">
                                    <li><a href="#"><i class="fa fa-map-marker"></i>1734 Stonecoal Road</a></li>
                                    <li><a href="#"><i class="fa fa-phone"></i>+021-95-51-84</a></li>
                                    <li><a href="#"><i class="fa fa-envelope-o"></i>email@email.com</a></li>
                                </ul>
                            </div>
                        </div>

                        <div class="col-md-3 col-xs-6">
                            <div class="footer">
                                <h3 class="footer-title">Categories</h3>
                                <ul class="footer-links">
                                    <li><a href="#">Hot deals</a></li>
                                    <li><a href="#">Laptops</a></li>
                                    <li><a href="#">Smartphones</a></li>
                                    <li><a href="#">Cameras</a></li>
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
                                    <li><a href="#">Orders and Returns</a></li>
                                    <li><a href="#">Terms & Conditions</a></li>
                                </ul>
                            </div>
                        </div>

                        <div class="col-md-3 col-xs-6">
                            <div class="footer">
                                <h3 class="footer-title">Service</h3>
                                <ul class="footer-links">
                                    <li><a href="#">My Account</a></li>
                                    <li><a href="#">View Cart</a></li>
                                    <li><a href="#">Wishlist</a></li>
                                    <li><a href="#">Track My Order</a></li>
                                    <li><a href="#">Help</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <!-- /row -->
                </div>
                <!-- /container -->
            </div>
            <!-- /top footer -->

            <!-- bottom footer -->
            <div id="bottom-footer" class="section">
                <div class="container">
                    <!-- row -->
                    <div class="row">
                        <div class="col-md-12 text-center">
                            <ul class="footer-payments">
                                <li><a href="#"><i class="fa fa-cc-visa"></i></a></li>
                                <li><a href="#"><i class="fa fa-credit-card"></i></a></li>
                                <li><a href="#"><i class="fa fa-cc-paypal"></i></a></li>
                                <li><a href="#"><i class="fa fa-cc-mastercard"></i></a></li>
                                <li><a href="#"><i class="fa fa-cc-discover"></i></a></li>
                                <li><a href="#"><i class="fa fa-cc-amex"></i></a></li>
                            </ul>
                            <span class="copyright">
                                <!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. -->
                                Copyright &copy;
                                <script>document.write(new Date().getFullYear());</script> All rights reserved | This
                                template is made with <i class="fa fa-heart-o" aria-hidden="true"></i> by <a
                                    href="https://colorlib.com" target="_blank">Colorlib</a>
                                <!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. -->
                            </span>
                        </div>
                    </div>
                    <!-- /row -->
                </div>
                <!-- /container -->
            </div>
            <!-- /bottom footer -->
        </footer>
        <!-- /FOOTER -->

        <!-- jQuery Plugins -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/slick.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/nouislider.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/jquery.zoom.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

        <!-- Search Autocomplete Script -->
        <style>
            .search-suggestion-item {
                display: flex;
                align-items: center;
                padding: 8px 12px;
                cursor: pointer;
                border-bottom: 1px solid #f0f0f0;
                text-decoration: none;
                color: #333;
                transition: background 0.15s ease;
            }
            .search-suggestion-item:last-child {
                border-bottom: none;
            }
            .search-suggestion-item:hover,
            .search-suggestion-item.active {
                background-color: #f5f5f5;
            }
            .suggestion-img {
                width: 40px;
                height: 40px;
                object-fit: cover;
                border-radius: 4px;
                margin-right: 10px;
                flex-shrink: 0;
                border: 1px solid #eee;
            }
            .suggestion-info {
                flex: 1;
                overflow: hidden;
            }
            .suggestion-name {
                font-size: 13px;
                font-weight: 600;
                color: #333;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            .suggestion-meta {
                font-size: 11px;
                color: #999;
                margin-top: 2px;
            }
            .suggestion-price {
                font-size: 13px;
                font-weight: 700;
                color: #D10024;
                white-space: nowrap;
                margin-left: 8px;
            }
            .suggestion-no-result {
                padding: 12px;
                text-align: center;
                color: #999;
                font-size: 13px;
            }
        </style>
        <script>
            (function () {
                var searchInput = document.getElementById('search-input');
                var suggestionsBox = document.getElementById('search-suggestions');
                var searchForm = document.getElementById('search-form');
                var contextPath = '${pageContext.request.contextPath}';
                var debounceTimer = null;
                var activeIndex = -1;
                var currentSuggestions = [];

                if (!searchInput || !suggestionsBox) return;

                // Debounce function
                function debounce(fn, delay) {
                    return function () {
                        var args = arguments;
                        clearTimeout(debounceTimer);
                        debounceTimer = setTimeout(function () { fn.apply(null, args); }, delay);
                    };
                }

                // Format number với dấu phẩy
                function formatPrice(price) {
                    return parseFloat(price).toLocaleString('vi-VN') + ' ₫';
                }

                // Render suggestions vào dropdown
                function renderSuggestions(data) {
                    suggestionsBox.innerHTML = '';
                    activeIndex = -1;
                    currentSuggestions = data;

                    if (!data || data.length === 0) {
                        suggestionsBox.innerHTML = '<div class="suggestion-no-result">Không tìm thấy sản phẩm</div>';
                        suggestionsBox.style.display = 'block';
                        return;
                    }

                    data.forEach(function (item, idx) {
                        var a = document.createElement('a');
                        a.className = 'search-suggestion-item';
                        a.href = contextPath + '/productDetail?id=' + item.productID;
                        a.setAttribute('data-index', idx);

                        var imgSrc = item.imageUrl.indexOf('http') === 0
                            ? item.imageUrl
                            : contextPath + '/' + item.imageUrl;

                        a.innerHTML =
                            '<img class="suggestion-img" src="' + imgSrc + '" alt="' + escapeHtml(item.productName) + '" onerror="this.src=\'' + contextPath + '/assets/img/product01.png\'">' +
                            '<div class="suggestion-info">' +
                                '<div class="suggestion-name">' + escapeHtml(item.productName) + '</div>' +
                                '<div class="suggestion-meta">' + escapeHtml(item.categoryName || '') + '</div>' +
                            '</div>' +
                            '<span class="suggestion-price">' + formatPrice(item.price) + '</span>';

                        suggestionsBox.appendChild(a);
                    });

                    suggestionsBox.style.display = 'block';
                }

                // Ẩn suggestions
                function hideSuggestions() {
                    suggestionsBox.style.display = 'none';
                    activeIndex = -1;
                }

                // Escape HTML
                function escapeHtml(text) {
                    var div = document.createElement('div');
                    div.appendChild(document.createTextNode(text));
                    return div.innerHTML;
                }

                // Gọi API gợi ý
                function fetchSuggestions(keyword) {
                    if (keyword.length < 3) {
                        hideSuggestions();
                        return;
                    }

                    var xhr = new XMLHttpRequest();
                    xhr.open('GET', contextPath + '/searchSuggest?q=' + encodeURIComponent(keyword), true);
                    xhr.onreadystatechange = function () {
                        if (xhr.readyState === 4 && xhr.status === 200) {
                            try {
                                var data = JSON.parse(xhr.responseText);
                                renderSuggestions(data);
                            } catch (e) {
                                hideSuggestions();
                            }
                        }
                    };
                    xhr.send();
                }

                var debouncedFetch = debounce(fetchSuggestions, 300);

                // Xử lý keyboard navigation trong dropdown
                searchInput.addEventListener('keydown', function (e) {
                    var items = suggestionsBox.querySelectorAll('.search-suggestion-item');
                    if (e.key === 'ArrowDown') {
                        e.preventDefault();
                        activeIndex = Math.min(activeIndex + 1, items.length - 1);
                        updateActive(items);
                    } else if (e.key === 'ArrowUp') {
                        e.preventDefault();
                        activeIndex = Math.max(activeIndex - 1, -1);
                        updateActive(items);
                    } else if (e.key === 'Escape') {
                        hideSuggestions();
                    }
                    // Enter được xử lý bởi form submit
                });

                function updateActive(items) {
                    items.forEach(function (item, i) {
                        if (i === activeIndex) {
                            item.classList.add('active');
                        } else {
                            item.classList.remove('active');
                        }
                    });
                }

                // Lắng nghe input
                searchInput.addEventListener('input', function () {
                    var keyword = this.value.trim();
                    debouncedFetch(keyword);
                });

                // Click ngoài dropdown -> đóng
                document.addEventListener('click', function (e) {
                    if (!searchInput.contains(e.target) && !suggestionsBox.contains(e.target)) {
                        hideSuggestions();
                    }
                });

                // Focus lại input -> hiện lại nếu có kết quả
                searchInput.addEventListener('focus', function () {
                    if (this.value.trim().length >= 3 && suggestionsBox.innerHTML !== '') {
                        suggestionsBox.style.display = 'block';
                    }
                });

                // Submit form (Enter hoặc nút Search) -> dẫn đến trang danh sách
                searchForm.addEventListener('submit', function () {
                    hideSuggestions();
                    // Form submit bình thường, không cần làm gì thêm
                });
            })();
        </script>

    </body>

</html>