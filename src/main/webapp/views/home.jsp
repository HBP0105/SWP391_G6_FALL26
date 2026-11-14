<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="utf-8">
                    <meta http-equiv="X-UA-Compatible" content="IE=edge">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

                    <title>Headphone Shop</title>

                    <!-- Google font -->
                    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

                    <link type="text/css" rel="stylesheet"
                        href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />
                    <link type="text/css" rel="stylesheet"
                        href="${pageContext.request.contextPath}/assets/css/slick.css" />
                    <link type="text/css" rel="stylesheet"
                        href="${pageContext.request.contextPath}/assets/css/slick-theme.css" />
                    <link type="text/css" rel="stylesheet"
                        href="${pageContext.request.contextPath}/assets/css/nouislider.min.css" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">
                    <link type="text/css" rel="stylesheet"
                        href="${pageContext.request.contextPath}/assets/css/style.css" />
                    <link type="text/css" rel="stylesheet"
                        href="${pageContext.request.contextPath}/assets/css/home.css?v=20261114-3" />
                    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
                    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
                    <!--[if lt IE 9]>
                  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
                  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
                <![endif]-->

                </head>

                <body class="home-page">
                    <c:set var="activeNav" value="home" scope="request" />
                    <jsp:include page="/assets/components/header.jsp" />

                    <c:set var="featuredProduct" value="${not empty topSellingProducts ? topSellingProducts[0] : null}" />
                    <section class="home-hero" aria-labelledby="home-hero-title">
                        <div class="container">
                            <div class="home-hero-panel">
                                <div class="home-hero-copy">
                                    <span class="home-eyebrow"><i class="fa fa-bolt"></i> Premium audio, picked for you</span>
                                    <h1 id="home-hero-title">Hear every detail.<br><span>Feel every beat.</span></h1>
                                    <p>Discover headphones and earbuds selected for sound quality, comfort and everyday performance.</p>
                                    <div class="home-hero-actions">
                                        <a class="primary-btn" href="${pageContext.request.contextPath}/productList">Shop products</a>
                                        <a class="home-secondary-btn" href="${pageContext.request.contextPath}/ai-search">
                                            <i class="fa fa-magic"></i> Try AI Search
                                        </a>
                                    </div>
                                    <ul class="home-hero-benefits" aria-label="Shopping benefits">
                                        <li><i class="fa fa-check-circle"></i> Genuine products</li>
                                        <li><i class="fa fa-truck"></i> Fast delivery</li>
                                        <li><i class="fa fa-headphones"></i> Audio-first support</li>
                                    </ul>
                                </div>

                                <c:if test="${not empty featuredProduct}">
                                    <a class="home-featured-product"
                                       href="${pageContext.request.contextPath}/productDetail?id=${featuredProduct.productId}"
                                       aria-label="View ${featuredProduct.productName}">
                                        <span class="featured-badge">Top pick</span>
                                        <div class="featured-image-wrap">
                                            <img src="${empty featuredProduct.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product05.png') : (fn:startsWith(featuredProduct.imageUrl, 'http') ? featuredProduct.imageUrl : pageContext.request.contextPath.concat('/').concat(featuredProduct.imageUrl))}"
                                                 alt="${featuredProduct.productName}"
                                                 onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/product05.png';">
                                        </div>
                                        <div class="featured-product-info">
                                            <span>${featuredProduct.categoryName}</span>
                                            <strong>${featuredProduct.productName}</strong>
                                            <b><fmt:formatNumber value="${featuredProduct.price}" type="number" groupingUsed="true" /> &#8363;</b>
                                        </div>
                                    </a>
                                </c:if>
                            </div>
                        </div>
                    </section>

                    <!-- SECTION -->
                    <div class="section home-collections">
                        <!-- container -->
                        <div class="container">
                            <!-- row -->
                            <div class="row">
                                <!-- shop -->
                                <div class="col-md-4 col-xs-6">
                                    <div class="shop">
                                        <div class="shop-img">
                                            <c:set var="headphoneBannerImage" value="${not empty topHeadphones ? topHeadphones[0].imageUrl : ''}" />
                                            <img src="${empty headphoneBannerImage ? pageContext.request.contextPath.concat('/assets/img/shop03.png') : (fn:startsWith(headphoneBannerImage, 'http') ? headphoneBannerImage : pageContext.request.contextPath.concat('/').concat(headphoneBannerImage))}"
                                                alt="Headphones"
                                                onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/shop03.png';">
                                        </div>
                                        <div class="shop-body">
                                            <h3>Headphones<br>Collection</h3>
                                            <a href="${pageContext.request.contextPath}/productList?category=1" class="cta-btn">Shop now <i
                                                    class="fa fa-arrow-circle-right"></i></a>
                                        </div>
                                    </div>
                                </div>
                                <!-- /shop -->

                                <!-- shop -->
                                <div class="col-md-4 col-xs-6">
                                    <div class="shop">
                                        <div class="shop-img">
                                            <c:set var="earbudBannerImage" value="${not empty topEarbuds ? topEarbuds[0].imageUrl : ''}" />
                                            <img src="${empty earbudBannerImage ? pageContext.request.contextPath.concat('/assets/img/shop03.png') : (fn:startsWith(earbudBannerImage, 'http') ? earbudBannerImage : pageContext.request.contextPath.concat('/').concat(earbudBannerImage))}"
                                                alt="Earbuds"
                                                onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/shop03.png';">
                                        </div>
                                        <div class="shop-body">
                                            <h3>Earbuds<br>Collection</h3>
                                            <a href="${pageContext.request.contextPath}/productList?category=2" class="cta-btn">Shop now <i
                                                    class="fa fa-arrow-circle-right"></i></a>
                                        </div>
                                    </div>
                                </div>
                                <!-- /shop -->

                                <!-- shop -->
                                <div class="col-md-4 col-xs-6">
                                    <div class="shop">
                                        <div class="shop-img">
                                            <c:set var="wirelessBannerImage" value="${not empty topSellingProducts ? topSellingProducts[0].imageUrl : ''}" />
                                            <img src="${empty wirelessBannerImage ? pageContext.request.contextPath.concat('/assets/img/shop03.png') : (fn:startsWith(wirelessBannerImage, 'http') ? wirelessBannerImage : pageContext.request.contextPath.concat('/').concat(wirelessBannerImage))}"
                                                alt="Wireless Audio"
                                                onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/img/shop03.png';">
                                        </div>
                                        <div class="shop-body">
                                            <h3>Wireless Audio<br>Collection</h3>
                                            <a href="${pageContext.request.contextPath}/productList" class="cta-btn">Shop now <i
                                                    class="fa fa-arrow-circle-right"></i></a>
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

                    <!-- AI RECOMMENDATION SECTION -->
                    <c:if
                        test="${(not empty sessionScope.customer or not empty sessionScope.user) and not empty aiRecommendations}">
                        <div class="section home-products-section home-ai-section">
                            <!-- container -->
                            <div class="container">
                                <!-- row -->
                                <div class="row">

                                    <!-- section title -->
                                    <div class="col-md-12">
                                        <div class="section-title">
                                            <h3 class="title">
                                                AI Recommendation                                               
                                            </h3>
                                            <div class="section-nav">
                                                <ul class="section-tab-nav tab-nav">
                                                    <li class="active"><a data-toggle="tab" href="#tab-ai-all">All</a>
                                                    </li>
                                                    <c:forEach var="cat" items="${categories}">
                                                        <li><a data-toggle="tab"
                                                                href="#tab-ai-${cat.categoryId}">${cat.categoryName}</a>
                                                        </li>
                                                    </c:forEach>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- /section title -->

                                    <!-- Products tab & slick -->
                                    <div class="col-md-12">
                                        <div class="row">
                                            <div class="products-tabs">
                                                <!-- tab All -->
                                                <div id="tab-ai-all" class="tab-pane fade in active">
                                                    <div class="products-slick" data-nav="#slick-nav-ai-all">
                                                        <c:forEach var="product" items="${aiRecommendations}">
                                                            <!-- product -->
                                                            <div class="product">
                                                                <div class="product-img">
                                                                    <c:set var="pImg" value="${product.imageUrl}" />
                                                                    <img src="${empty pImg ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(pImg, 'http') ? pImg : pageContext.request.contextPath.concat('/').concat(pImg))}"
                                                                        alt="${product.productName}">
                                                                    <div class="product-label">
                                                                        <span class="sale ai-match"><i
                                                                                class="fa fa-bolt"></i>
                                                                            ${product.matchPercentage}% MATCH</span>
                                                                        <span class="new">AI PICK</span>
                                                                    </div>
                                                                </div>
                                                                <div class="product-body">
                                                                    <p class="product-category">${product.categoryName}
                                                                    </p>
                                                                    <h3 class="product-name">
                                                                        <a
                                                                            href="${pageContext.request.contextPath}/productDetail?id=${product.productId}&recId=${product.recommendationId}">${product.productName}</a>
                                                                    </h3>
                                                                    <p class="ai-reason-hint"><i
                                                                            class="fa fa-magic"></i> ${product.aiReason}
                                                                    </p>
                                                                    <h4 class="product-price">
                                                                        <fmt:formatNumber value="${product.price}"
                                                                            type="number" groupingUsed="true" /> &#8363;
                                                                    </h4>
                                                                    <div class="product-rating">
                                                                        <i class="fa fa-star"></i>
                                                                        <i class="fa fa-star"></i>
                                                                        <i class="fa fa-star"></i>
                                                                        <i class="fa fa-star"></i>
                                                                        <i class="fa fa-star"></i>
                                                                    </div>
                                                                    <div class="product-btns">
                                                                        <c:set var="inWishlist"
                                                                            value="${sessionScope.wishlistProductIds != null && sessionScope.wishlistProductIds.contains(product.productId)}" />
                                                                        <button type="button"
                                                                            class="add-to-wishlist ${inWishlist ? 'in-wishlist' : ''}"
                                                                            data-product-id="${product.productId}"
                                                                            title="${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}"><i
                                                                                class="fa ${inWishlist ? 'fa-heart' : 'fa-heart-o'}"
                                                                                ${inWishlist ? 'style="color: #D10024;"'
                                                                                : '' }></i><span
                                                                                class="tooltipp">${inWishlist ? 'Product
                                                                                is in wishlist' : 'add to
                                                                                wishlist'}</span></button>
                                                                        <button type="button" class="add-to-compare"
                                                                            data-product-id="${product.productId}"><i
                                                                                class="fa fa-exchange"></i><span
                                                                                class="tooltipp">add to
                                                                                compare</span></button>
                                                                        <button class="quick-view"
                                                                            onclick="location.href = '${pageContext.request.contextPath}/productDetail?id=${product.productId}&recId=${product.recommendationId}'"><i
                                                                                class="fa fa-eye"></i><span
                                                                                class="tooltipp">quick
                                                                                view</span></button>
                                                                    </div>
                                                                </div>
                                                                <div class="add-to-cart">
                                                                    <form
                                                                        action="${pageContext.request.contextPath}/cart"
                                                                        method="POST" style="margin: 0;">
                                                                        <input type="hidden" name="action" value="add">
                                                                        <input type="hidden" name="productId"
                                                                            value="${product.productId}">
                                                                        <input type="hidden" name="quantity" value="1">
                                                                        <button type="submit" class="add-to-cart-btn">
                                                                            <i class="fa fa-shopping-cart"></i> add to
                                                                            cart
                                                                        </button>
                                                                    </form>
                                                                </div>
                                                            </div>
                                                            <!-- /product -->
                                                        </c:forEach>
                                                    </div>
                                                    <div id="slick-nav-ai-all" class="products-slick-nav"></div>
                                                </div>
                                                <!-- /tab All -->

                                                <!-- tabs per category -->
                                                <c:forEach var="cat" items="${categories}">
                                                    <div id="tab-ai-${cat.categoryId}" class="tab-pane fade">
                                                        <c:set var="catAiProducts"
                                                            value="${aiRecommendationsByCategory[cat.categoryId]}" />
                                                        <c:choose>
                                                            <c:when test="${not empty catAiProducts}">
                                                                <div class="products-slick"
                                                                    data-nav="#slick-nav-ai-${cat.categoryId}">
                                                                    <c:forEach var="product" items="${catAiProducts}">
                                                                        <!-- product -->
                                                                        <div class="product">
                                                                            <div class="product-img">
                                                                                <c:set var="pImg"
                                                                                    value="${product.imageUrl}" />
                                                                                <img src="${empty pImg ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(pImg, 'http') ? pImg : pageContext.request.contextPath.concat('/').concat(fn:startsWith(pImg, '/') ? fn:substring(pImg, 1, fn:length(pImg)) : pImg))}"
                                                                                    alt="${product.productName}">
                                                                                <div class="product-label">
                                                                                    <span class="sale ai-match"><i
                                                                                            class="fa fa-bolt"></i>
                                                                                        ${product.matchPercentage}%
                                                                                        MATCH</span>
                                                                                    <span class="new">AI PICK</span>
                                                                                </div>
                                                                            </div>
                                                                            <div class="product-body">
                                                                                <p class="product-category">
                                                                                    ${product.categoryName}</p>
                                                                                <h3 class="product-name">
                                                                                    <a
                                                                                        href="${pageContext.request.contextPath}/productDetail?id=${product.productId}&recId=${product.recommendationId}">${product.productName}</a>
                                                                                </h3>
                                                                                <p class="ai-reason-hint"><i
                                                                                        class="fa fa-magic"></i>
                                                                                    ${product.aiReason}</p>
                                                                                <h4 class="product-price">
                                                                                    <fmt:formatNumber
                                                                                        value="${product.price}"
                                                                                        type="number"
                                                                                        groupingUsed="true" /> &#8363;
                                                                                </h4>
                                                                                <div class="product-rating">
                                                                                    <i class="fa fa-star"></i>
                                                                                    <i class="fa fa-star"></i>
                                                                                    <i class="fa fa-star"></i>
                                                                                    <i class="fa fa-star"></i>
                                                                                    <i class="fa fa-star"></i>
                                                                                </div>
                                                                                <div class="product-btns">
                                                                                    <c:set var="inWishlist"
                                                                                        value="${sessionScope.wishlistProductIds != null && sessionScope.wishlistProductIds.contains(product.productId)}" />
                                                                                    <button type="button"
                                                                                        class="add-to-wishlist ${inWishlist ? 'in-wishlist' : ''}"
                                                                                        data-product-id="${product.productId}"
                                                                                        title="${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}"><i
                                                                                            class="fa ${inWishlist ? 'fa-heart' : 'fa-heart-o'}"
                                                                                            ${inWishlist
                                                                                            ? 'style="color: #D10024;"'
                                                                                            : '' }></i><span
                                                                                            class="tooltipp">${inWishlist
                                                                                            ? 'Product is in wishlist' :
                                                                                            'add to
                                                                                            wishlist'}</span></button>
                                                                                    <button type="button"
                                                                                        class="add-to-compare"
                                                                                        data-product-id="${product.productId}"><i
                                                                                            class="fa fa-exchange"></i><span
                                                                                            class="tooltipp">add to
                                                                                            compare</span></button>
                                                                                    <button class="quick-view"
                                                                                        onclick="location.href = '${pageContext.request.contextPath}/productDetail?id=${product.productId}&recId=${product.recommendationId}'"><i
                                                                                            class="fa fa-eye"></i><span
                                                                                            class="tooltipp">quick
                                                                                            view</span></button>
                                                                                </div>
                                                                            </div>
                                                                            <div class="add-to-cart">
                                                                                <form
                                                                                    action="${pageContext.request.contextPath}/cart"
                                                                                    method="POST" style="margin: 0;">
                                                                                    <input type="hidden" name="action"
                                                                                        value="add">
                                                                                    <input type="hidden"
                                                                                        name="productId"
                                                                                        value="${product.productId}">
                                                                                    <input type="hidden" name="quantity"
                                                                                        value="1">
                                                                                    <button type="submit"
                                                                                        class="add-to-cart-btn">
                                                                                        <i
                                                                                            class="fa fa-shopping-cart"></i>
                                                                                        add to cart
                                                                                    </button>
                                                                                </form>
                                                                            </div>
                                                                        </div>
                                                                        <!-- /product -->
                                                                    </c:forEach>
                                                                </div>
                                                                <div id="slick-nav-ai-${cat.categoryId}"
                                                                    class="products-slick-nav"></div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="text-center"
                                                                    style="padding: 40px 0; color: #8D99AE;">
                                                                    <p>No recommended products in this category.</p>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- /Products tab & slick -->
                                </div>
                                <!-- /row -->
                            </div>
                            <!-- /container -->
                        </div>
                    </c:if>
                    <!-- /AI RECOMMENDATION SECTION -->

                    <!-- SECTION -->
                    <div class="section home-products-section">
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
                                                <li class="active"><a data-toggle="tab" href="#tab-new-all">All</a></li>
                                                <c:forEach var="cat" items="${categories}">
                                                    <li><a data-toggle="tab"
                                                            href="#tab-new-${cat.categoryId}">${cat.categoryName}</a>
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                                <!-- /section title -->

                                <!-- Products tab & slick -->
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="products-tabs">
                                            <!-- tab All -->
                                            <div id="tab-new-all" class="tab-pane fade in active">
                                                <div class="products-slick" data-nav="#slick-nav-new-all">
                                                    <c:forEach var="product" items="${newProducts}">
                                                        <!-- product -->
                                                        <div class="product">
                                                            <div class="product-img">
                                                                <img src="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}"
                                                                    alt="${product.productName}">
                                                                <div class="product-label">
                                                                    <span class="new">NEW</span>
                                                                </div>
                                                            </div>
                                                            <div class="product-body">
                                                                <p class="product-category">${product.categoryName}</p>
                                                                <h3 class="product-name"><a
                                                                        href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${product.productName}</a>
                                                                </h3>
                                                                <h4 class="product-price">
                                                                    <fmt:formatNumber value="${product.price}"
                                                                        type="number" groupingUsed="true" /> &#8363;
                                                                </h4>
                                                                <div class="product-rating">
                                                                    <i class="fa fa-star"></i>
                                                                    <i class="fa fa-star"></i>
                                                                    <i class="fa fa-star"></i>
                                                                    <i class="fa fa-star"></i>
                                                                    <i class="fa fa-star-o"></i>
                                                                </div>
                                                                <div class="product-btns">
                                                                    <c:set var="inWishlist"
                                                                        value="${sessionScope.wishlistProductIds != null && sessionScope.wishlistProductIds.contains(product.productId)}" />
                                                                    <button type="button"
                                                                        class="add-to-wishlist ${inWishlist ? 'in-wishlist' : ''}"
                                                                        data-product-id="${product.productId}"
                                                                        title="${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}"><i
                                                                            class="fa ${inWishlist ? 'fa-heart' : 'fa-heart-o'}"
                                                                            ${inWishlist ? 'style="color: #D10024;"'
                                                                            : '' }></i><span
                                                                            class="tooltipp">${inWishlist ? 'Product is
                                                                            in wishlist' : 'add to
                                                                            wishlist'}</span></button>
                                                                    <button type="button" class="add-to-compare"
                                                                        data-product-id="${product.productId}"><i
                                                                            class="fa fa-exchange"></i><span
                                                                            class="tooltipp">add to
                                                                            compare</span></button>
                                                                    <button class="quick-view"
                                                                        onclick="location.href = '${pageContext.request.contextPath}/productDetail?id=${product.productId}'"><i
                                                                            class="fa fa-eye"></i><span
                                                                            class="tooltipp">quick view</span></button>
                                                                </div>
                                                            </div>
                                                            <div class="add-to-cart">
                                                                <form action="${pageContext.request.contextPath}/cart"
                                                                    method="POST" style="margin: 0;">
                                                                    <input type="hidden" name="action" value="add">
                                                                    <input type="hidden" name="productId"
                                                                        value="${product.productId}">
                                                                    <input type="hidden" name="quantity" value="1">

                                                                    <button type="submit" class="add-to-cart-btn">
                                                                        <i class="fa fa-shopping-cart"></i> add to cart
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </div>
                                                        <!-- /product -->
                                                    </c:forEach>
                                                </div>
                                                <div id="slick-nav-new-all" class="products-slick-nav"></div>
                                            </div>
                                            <!-- /tab All -->

                                            <!-- tabs per category -->
                                            <c:forEach var="cat" items="${categories}">
                                                <div id="tab-new-${cat.categoryId}" class="tab-pane fade">
                                                    <c:choose>
                                                        <c:when test="${not empty cat.newProducts}">
                                                            <div class="products-slick"
                                                                data-nav="#slick-nav-new-${cat.categoryId}">
                                                                <c:forEach var="product" items="${cat.newProducts}">
                                                                    <!-- product -->
                                                                    <div class="product">
                                                                        <div class="product-img">
                                                                            <img src="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}"
                                                                                alt="${product.productName}">
                                                                            <div class="product-label">
                                                                                <span class="new">NEW</span>
                                                                            </div>
                                                                        </div>
                                                                        <div class="product-body">
                                                                            <p class="product-category">
                                                                                ${product.categoryName}</p>
                                                                            <h3 class="product-name"><a
                                                                                    href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${product.productName}</a>
                                                                            </h3>
                                                                            <h4 class="product-price">
                                                                                <fmt:formatNumber
                                                                                    value="${product.price}"
                                                                                    type="number" groupingUsed="true" />
                                                                                &#8363;
                                                                            </h4>
                                                                            <div class="product-rating">
                                                                                <i class="fa fa-star"></i>
                                                                                <i class="fa fa-star"></i>
                                                                                <i class="fa fa-star"></i>
                                                                                <i class="fa fa-star"></i>
                                                                                <i class="fa fa-star-o"></i>
                                                                            </div>
                                                                            <div class="product-btns">
                                                                                <c:set var="inWishlist"
                                                                                    value="${sessionScope.wishlistProductIds != null && sessionScope.wishlistProductIds.contains(product.productId)}" />
                                                                                <button type="button"
                                                                                    class="add-to-wishlist ${inWishlist ? 'in-wishlist' : ''}"
                                                                                    data-product-id="${product.productId}"
                                                                                    title="${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}"><i
                                                                                        class="fa ${inWishlist ? 'fa-heart' : 'fa-heart-o'}"
                                                                                        ${inWishlist
                                                                                        ? 'style="color: #D10024;"' : ''
                                                                                        }></i><span
                                                                                        class="tooltipp">${inWishlist ?
                                                                                        'Product is in wishlist' : 'add
                                                                                        to wishlist'}</span></button>
                                                                                <button type="button"
                                                                                    class="add-to-compare"
                                                                                    data-product-id="${product.productId}"><i
                                                                                        class="fa fa-exchange"></i><span
                                                                                        class="tooltipp">add to
                                                                                        compare</span></button>
                                                                                <button class="quick-view"
                                                                                    onclick="location.href = '${pageContext.request.contextPath}/productDetail?id=${product.productId}'"><i
                                                                                        class="fa fa-eye"></i><span
                                                                                        class="tooltipp">quick
                                                                                        view</span></button>
                                                                            </div>
                                                                        </div>
                                                                        <div class="add-to-cart">
                                                                            <form action="${pageContext.request.contextPath}/cart"
                                                                                method="POST" style="margin: 0;">
                                                                                <input type="hidden" name="action" value="add">
                                                                                <input type="hidden" name="productId"
                                                                                    value="${product.productId}">
                                                                                <input type="hidden" name="quantity" value="1">
                                                                                <button type="submit" class="add-to-cart-btn"><i
                                                                                        class="fa fa-shopping-cart"></i> add
                                                                                    to cart</button>
                                                                            </form>
                                                                        </div>
                                                                    </div>
                                                                    <!-- /product -->
                                                                </c:forEach>
                                                            </div>
                                                            <div id="slick-nav-new-${cat.categoryId}"
                                                                class="products-slick-nav"></div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="text-center"
                                                                style="padding: 40px 0; color: #8D99AE;">
                                                                <p>Không có sản phẩm.</p>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:forEach>
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
                    <div id="hot-deal" class="section home-hot-deal">
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
                                        <a class="primary-btn cta-btn" href="${pageContext.request.contextPath}/productList">Shop now</a>
                                    </div>
                                </div>
                            </div>
                            <!-- /row -->
                        </div>
                        <!-- /container -->
                    </div>
                    <!-- /HOT DEAL SECTION -->

                    <!-- SECTION -->
                    <div class="section home-products-section">
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
                                                <li class="active"><a data-toggle="tab" href="#tab-top-all">All</a></li>
                                                <c:forEach var="cat" items="${categories}">
                                                    <li><a data-toggle="tab"
                                                            href="#tab-top-${cat.categoryId}">${cat.categoryName}</a>
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                                <!-- /section title -->

                                <!-- Products tab & slick -->
                                <div class="col-md-12">
                                    <div class="row">
                                        <div class="products-tabs">
                                            <!-- tab All -->
                                            <div id="tab-top-all" class="tab-pane fade in active">
                                                <div class="products-slick" data-nav="#slick-nav-top-all">
                                                    <c:forEach var="product" items="${topSellingProducts}">
                                                        <!-- product -->
                                                        <div class="product">
                                                            <div class="product-img">
                                                                <img src="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}"
                                                                    alt="${product.productName}">
                                                            </div>
                                                            <div class="product-body">
                                                                <p class="product-category">${product.categoryName}</p>
                                                                <h3 class="product-name"><a
                                                                        href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${product.productName}</a>
                                                                </h3>
                                                                <h4 class="product-price">
                                                                    <fmt:formatNumber value="${product.price}"
                                                                        type="number" groupingUsed="true" /> &#8363;
                                                                </h4>
                                                                <div class="product-rating">
                                                                    <i class="fa fa-star"></i>
                                                                    <i class="fa fa-star"></i>
                                                                    <i class="fa fa-star"></i>
                                                                    <i class="fa fa-star"></i>
                                                                    <i class="fa fa-star-o"></i>
                                                                </div>
                                                                <div class="product-btns">
                                                                    <c:set var="inWishlist"
                                                                        value="${sessionScope.wishlistProductIds != null && sessionScope.wishlistProductIds.contains(product.productId)}" />
                                                                    <button type="button"
                                                                        class="add-to-wishlist ${inWishlist ? 'in-wishlist' : ''}"
                                                                        data-product-id="${product.productId}"
                                                                        title="${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}"><i
                                                                            class="fa ${inWishlist ? 'fa-heart' : 'fa-heart-o'}"
                                                                            ${inWishlist ? 'style="color: #D10024;"'
                                                                            : '' }></i><span
                                                                            class="tooltipp">${inWishlist ? 'Product is
                                                                            in wishlist' : 'add to
                                                                            wishlist'}</span></button>
                                                                    <button type="button" class="add-to-compare"
                                                                        data-product-id="${product.productId}"><i
                                                                            class="fa fa-exchange"></i><span
                                                                            class="tooltipp">add to
                                                                            compare</span></button>
                                                                    <button class="quick-view"
                                                                        onclick="location.href = '${pageContext.request.contextPath}/productDetail?id=${product.productId}'"><i
                                                                            class="fa fa-eye"></i><span
                                                                            class="tooltipp">quick view</span></button>
                                                                </div>
                                                            </div>
                                                            <div class="add-to-cart">
                                                                <form action="${pageContext.request.contextPath}/cart"
                                                                    method="POST" style="margin: 0;">
                                                                    <input type="hidden" name="action" value="add">
                                                                    <input type="hidden" name="productId"
                                                                        value="${product.productId}">
                                                                    <input type="hidden" name="quantity" value="1">

                                                                    <button type="submit" class="add-to-cart-btn">
                                                                        <i class="fa fa-shopping-cart"></i> add to cart
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </div>
                                                        <!-- /product -->
                                                    </c:forEach>
                                                </div>
                                                <div id="slick-nav-top-all" class="products-slick-nav"></div>
                                            </div>
                                            <!-- /tab All -->

                                            <!-- tabs per category -->
                                            <c:forEach var="cat" items="${categories}">
                                                <div id="tab-top-${cat.categoryId}" class="tab-pane fade">
                                                    <c:choose>
                                                        <c:when test="${not empty cat.topSellingProducts}">
                                                            <div class="products-slick"
                                                                data-nav="#slick-nav-top-${cat.categoryId}">
                                                                <c:forEach var="product"
                                                                    items="${cat.topSellingProducts}">
                                                                    <!-- product -->
                                                                    <div class="product">
                                                                        <div class="product-img">
                                                                            <img src="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}"
                                                                                alt="${product.productName}">
                                                                        </div>
                                                                        <div class="product-body">
                                                                            <p class="product-category">
                                                                                ${product.categoryName}</p>
                                                                            <h3 class="product-name"><a
                                                                                    href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${product.productName}</a>
                                                                            </h3>
                                                                            <h4 class="product-price">
                                                                                <fmt:formatNumber
                                                                                    value="${product.price}"
                                                                                    type="number" groupingUsed="true" />
                                                                                &#8363;
                                                                            </h4>
                                                                            <div class="product-rating">
                                                                                <i class="fa fa-star"></i>
                                                                                <i class="fa fa-star"></i>
                                                                                <i class="fa fa-star"></i>
                                                                                <i class="fa fa-star"></i>
                                                                                <i class="fa fa-star-o"></i>
                                                                            </div>
                                                                            <div class="product-btns">
                                                                                <c:set var="inWishlist"
                                                                                    value="${sessionScope.wishlistProductIds != null && sessionScope.wishlistProductIds.contains(product.productId)}" />
                                                                                <button type="button"
                                                                                    class="add-to-wishlist ${inWishlist ? 'in-wishlist' : ''}"
                                                                                    data-product-id="${product.productId}"
                                                                                    title="${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}"><i
                                                                                        class="fa ${inWishlist ? 'fa-heart' : 'fa-heart-o'}"
                                                                                        ${inWishlist
                                                                                        ? 'style="color: #D10024;"' : ''
                                                                                        }></i><span
                                                                                        class="tooltipp">${inWishlist ?
                                                                                        'Product is in wishlist' : 'add
                                                                                        to wishlist'}</span></button>
                                                                                <button type="button"
                                                                                    class="add-to-compare"
                                                                                    data-product-id="${product.productId}"><i
                                                                                        class="fa fa-exchange"></i><span
                                                                                        class="tooltipp">add to
                                                                                        compare</span></button>
                                                                                <button class="quick-view"
                                                                                    onclick="location.href = '${pageContext.request.contextPath}/productDetail?id=${product.productId}'"><i
                                                                                        class="fa fa-eye"></i><span
                                                                                        class="tooltipp">quick
                                                                                        view</span></button>
                                                                            </div>
                                                                        </div>
                                                                        <div class="add-to-cart">
                                                                            <form action="${pageContext.request.contextPath}/cart"
                                                                                method="POST" style="margin: 0;">
                                                                                <input type="hidden" name="action" value="add">
                                                                                <input type="hidden" name="productId"
                                                                                    value="${product.productId}">
                                                                                <input type="hidden" name="quantity" value="1">
                                                                                <button type="submit" class="add-to-cart-btn"><i
                                                                                        class="fa fa-shopping-cart"></i> add
                                                                                    to cart</button>
                                                                            </form>
                                                                        </div>
                                                                    </div>
                                                                    <!-- /product -->
                                                                </c:forEach>
                                                            </div>
                                                            <div id="slick-nav-top-${cat.categoryId}"
                                                                class="products-slick-nav"></div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="text-center"
                                                                style="padding: 40px 0; color: #8D99AE;">
                                                                <p>Không có sản phẩm.</p>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:forEach>
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
                    <div class="section home-widget-section">
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
                                                        <img src="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}"
                                                            alt="${product.productName}">
                                                    </div>
                                                    <div class="product-body">
                                                        <p class="product-category">${product.categoryName}</p>
                                                        <h3 class="product-name"><a href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${product.productName}</a>
                                                        </h3>
                                                        <h4 class="product-price">
                                                            <fmt:formatNumber value="${product.price}" type="number"
                                                                groupingUsed="true" /> &#8363;
                                                        </h4>
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
                                                        <img src="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}"
                                                            alt="${product.productName}">
                                                    </div>
                                                    <div class="product-body">
                                                        <p class="product-category">${product.categoryName}</p>
                                                        <h3 class="product-name"><a href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${product.productName}</a>
                                                        </h3>
                                                        <h4 class="product-price">
                                                            <fmt:formatNumber value="${product.price}" type="number"
                                                                groupingUsed="true" /> &#8363;
                                                        </h4>
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
                                                        <img src="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}"
                                                            alt="${product.productName}">
                                                    </div>
                                                    <div class="product-body">
                                                        <p class="product-category">${product.categoryName}</p>
                                                        <h3 class="product-name"><a href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${product.productName}</a>
                                                        </h3>
                                                        <h4 class="product-price">
                                                            <fmt:formatNumber value="${product.price}" type="number"
                                                                groupingUsed="true" /> &#8363;
                                                        </h4>
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
                                                        <img src="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}"
                                                            alt="${product.productName}">
                                                    </div>
                                                    <div class="product-body">
                                                        <p class="product-category">${product.categoryName}</p>
                                                        <h3 class="product-name"><a href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${product.productName}</a>
                                                        </h3>
                                                        <h4 class="product-price">
                                                            <fmt:formatNumber value="${product.price}" type="number"
                                                                groupingUsed="true" /> &#8363;
                                                        </h4>
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
                                                        <img src="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}"
                                                            alt="${product.productName}">
                                                    </div>
                                                    <div class="product-body">
                                                        <p class="product-category">${product.categoryName}</p>
                                                        <h3 class="product-name"><a href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${product.productName}</a>
                                                        </h3>
                                                        <h4 class="product-price">
                                                            <fmt:formatNumber value="${product.price}" type="number"
                                                                groupingUsed="true" /> &#8363;
                                                        </h4>
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
                                                        <img src="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}"
                                                            alt="${product.productName}">
                                                    </div>
                                                    <div class="product-body">
                                                        <p class="product-category">${product.categoryName}</p>
                                                        <h3 class="product-name"><a href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${product.productName}</a>
                                                        </h3>
                                                        <h4 class="product-price">
                                                            <fmt:formatNumber value="${product.price}" type="number"
                                                                groupingUsed="true" /> &#8363;
                                                        </h4>
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
                    <div id="newsletter" class="section home-newsletter">
                        <!-- container -->
                        <div class="container">
                            <!-- row -->
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="newsletter">
                                        <p>Need help choosing the right <strong>HEADPHONES?</strong></p>
                                        <a class="primary-btn" href="${pageContext.request.contextPath}/information?topic=help"><i class="fa fa-headphones"></i> Get Shopping Help</a>
                                        <ul class="newsletter-follow">
                                            <li>
                                                <span aria-label="Facebook"><i class="fa fa-facebook"></i></span>
                                            </li>
                                            <li>
                                                <span aria-label="Twitter"><i class="fa fa-twitter"></i></span>
                                            </li>
                                            <li>
                                                <span aria-label="Instagram"><i class="fa fa-instagram"></i></span>
                                            </li>
                                            <li>
                                                <span aria-label="Pinterest"><i class="fa fa-pinterest"></i></span>
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
                                            <p>Authentic headphones and earbuds selected for sound quality, comfort and everyday reliability.</p>
                                            <ul class="footer-links">
                                                <li><a href="${pageContext.request.contextPath}/information?topic=contact"><i class="fa fa-map-marker"></i>Contact information</a>
                                                </li>
                                                <li><a href="tel:+8421955184"><i class="fa fa-phone"></i>+021-95-51-84</a></li>
                                                <li><a href="mailto:support@headphone-shop.com"><i class="fa fa-envelope-o"></i>support@headphone-shop.com</a></li>
                                            </ul>
                                        </div>
                                    </div>

                                    <div class="col-md-3 col-xs-6">
                                        <div class="footer">
                                            <h3 class="footer-title">Categories</h3>
                                            <ul class="footer-links">
                                                <li><a href="${pageContext.request.contextPath}/home#hot-deal">Hot deals</a></li>
                                                <li><a href="${pageContext.request.contextPath}/productList?category=1">Headphones</a></li>
                                                <li><a href="${pageContext.request.contextPath}/productList?category=2">Earbuds</a></li>
                                                <li><a href="${pageContext.request.contextPath}/compare">Compare</a></li>
                                                <li><a href="${pageContext.request.contextPath}/ai-search">AI Search</a></li>
                                            </ul>
                                        </div>
                                    </div>

                                    <div class="clearfix visible-xs"></div>

                                    <div class="col-md-3 col-xs-6">
                                        <div class="footer">
                                            <h3 class="footer-title">Information</h3>
                                            <ul class="footer-links">
                                                <li><a href="${pageContext.request.contextPath}/information?topic=about">About Us</a></li>
                                                <li><a href="${pageContext.request.contextPath}/information?topic=contact">Contact Us</a></li>
                                                <li><a href="${pageContext.request.contextPath}/information?topic=privacy">Privacy Policy</a></li>
                                                <li><a href="${pageContext.request.contextPath}/my-orders">Orders and Returns</a></li>
                                                <li><a href="${pageContext.request.contextPath}/information?topic=terms">Terms & Conditions</a></li>
                                            </ul>
                                        </div>
                                    </div>

                                    <div class="col-md-3 col-xs-6">
                                        <div class="footer">
                                            <h3 class="footer-title">Service</h3>
                                            <ul class="footer-links">
                                                <li><a href="${pageContext.request.contextPath}/profile">My Account</a></li>
                                                <li><a href="${pageContext.request.contextPath}/cart">View Cart</a></li>
                                                <li><a href="${pageContext.request.contextPath}/wishlist">Wishlist</a></li>
                                                <li><a href="${pageContext.request.contextPath}/my-orders">Track My Order</a></li>
                                                <li><a href="${pageContext.request.contextPath}/information?topic=help">Help</a></li>
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
                                            <li><span title="Visa"><i class="fa fa-cc-visa"></i></span></li>
                                            <li><span title="Card payment"><i class="fa fa-credit-card"></i></span></li>
                                            <li><span title="PayPal"><i class="fa fa-cc-paypal"></i></span></li>
                                            <li><span title="Mastercard"><i class="fa fa-cc-mastercard"></i></span></li>
                                            <li><span title="Discover"><i class="fa fa-cc-discover"></i></span></li>
                                            <li><span title="American Express"><i class="fa fa-cc-amex"></i></span></li>
                                        </ul>
                                        <span class="copyright">
                                            <!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. -->
                                            Copyright &copy;
                                            <script>document.write(new Date().getFullYear());</script> All rights
                                            reserved | This
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
                    <script>window.__contextPath = '${pageContext.request.contextPath}';</script>
                    <script src="${pageContext.request.contextPath}/assets/js/home.js?v=20261114-2"></script>
                </body>

                </html>
