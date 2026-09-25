
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title><c:choose>
                <c:when test="${not empty product}">${product.productName} - Headphone Shop</c:when>
                <c:otherwise>Product Not Found - Headphone Shop</c:otherwise>
            </c:choose></title>

        <!-- Google font -->
        <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick.css" />
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick-theme.css" />
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/nouislider.min.css" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />

        <style>
            /* ===== IMAGE SLIDER ===== */
            .pd-img-wrapper {
                position: relative;
                overflow: hidden;
                border: 1px solid #e5e5e5;
                border-radius: 4px;
                background: #fafafa;
            }
            .pd-img-track {
                display: flex;
                transition: transform 0.35s ease;
            }
            .pd-img-slide {
                min-width: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 16px;
            }
            .pd-img-slide img {
                max-width: 100%;
                max-height: 340px;
                object-fit: contain;
            }

            /* Arrow buttons */
            .pd-img-arrow {
                position: absolute;
                top: 50%;
                transform: translateY(-50%);
                background: rgba(255,255,255,0.88);
                border: 1px solid #ddd;
                border-radius: 50%;
                width: 36px;
                height: 36px;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                z-index: 10;
                transition: background 0.2s, box-shadow 0.2s;
                box-shadow: 0 2px 6px rgba(0,0,0,0.12);
            }
            .pd-img-arrow:hover {
                background: #D10024;
                color: #fff;
                border-color: #D10024;
                box-shadow: 0 4px 12px rgba(209,0,36,0.25);
            }
            .pd-img-arrow i {
                font-size: 14px;
            }
            .pd-img-prev {
                left: 10px;
            }
            .pd-img-next {
                right: 10px;
            }

            /* Thumbnails */
            .pd-thumbs {
                display: flex;
                gap: 8px;
                margin-top: 10px;
                justify-content: center;
            }
            .pd-thumb {
                width: 64px;
                height: 64px;
                border: 2px solid #e5e5e5;
                border-radius: 4px;
                overflow: hidden;
                cursor: pointer;
                padding: 4px;
                background: #fff;
                transition: border-color 0.2s;
            }
            .pd-thumb img {
                width: 100%;
                height: 100%;
                object-fit: contain;
            }
            .pd-thumb.active,
            .pd-thumb:hover {
                border-color: #D10024;
            }

            /* ===== PRODUCT INFO ===== */
            .product-details h2.product-name {
                font-size: 22px;
                font-weight: 700;
                margin-bottom: 10px;
                color: #222;
            }
            .detail-badge {
                display: inline-block;
                padding: 3px 10px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: 600;
                margin-bottom: 8px;
            }
            .badge-active   {
                background: #e6f9ed;
                color: #1a7a3a;
            }
            .badge-inactive {
                background: #fdf0f0;
                color: #c0392b;
            }

            /* Specs table in Details tab */
            .specs-table {
                width: 100%;
                border-collapse: collapse;
                font-size: 14px;
            }
            .specs-table tr:nth-child(odd) td {
                background: #f9f9f9;
            }
            .specs-table td {
                padding: 9px 14px;
                border-bottom: 1px solid #eee;
                vertical-align: top;
            }
            .specs-table td:first-child {
                font-weight: 600;
                color: #555;
                width: 40%;
            }

            /* Stock badge */
            .product-available {
                font-size: 13px;
                font-weight: 600;
                color: #1a7a3a;
            }
            .product-unavailable {
                font-size: 13px;
                font-weight: 600;
                color: #c0392b;
            }

            /* Not found box */
            .not-found-box {
                text-align: center;
                padding: 80px 20px;
            }
            .not-found-box i {
                font-size: 60px;
                color: #ddd;
                margin-bottom: 20px;
                display: block;
            }
            .not-found-box h3 {
                color: #888;
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
                        <li><a href="#"><i class="fa fa-user-o"></i> My Account</a></li>
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
                                <a href="${pageContext.request.contextPath}/home" class="logo">
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
                                <div>
                                    <a href="#">
                                        <i class="fa fa-heart-o"></i>
                                        <span>Your Wishlist</span>
                                        <div class="qty">0</div>
                                    </a>
                                </div>
                                <div class="dropdown">
                                    <a class="dropdown-toggle" data-toggle="dropdown" aria-expanded="true">
                                        <i class="fa fa-shopping-cart"></i>
                                        <span>Your Cart</span>
                                        <div class="qty">0</div>
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
                        <!-- /ACCOUNT -->
                    </div>
                </div>
            </div>
            <!-- /MAIN HEADER -->
        </header>
        <!-- /HEADER -->

        <!-- NAVIGATION -->
        <nav id="navigation">
            <div class="container">
                <div id="responsive-nav">
                    <ul class="main-nav nav navbar-nav">
                        <li><a href="${pageContext.request.contextPath}/home">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/home#hot-deal">Hot Deals</a></li>
                        <li><a href="#">Headphones</a></li>
                        <li><a href="#">Earbuds</a></li>
                    </ul>
                </div>
            </div>
        </nav>
        <!-- /NAVIGATION -->

        <!-- BREADCRUMB -->
        <div id="breadcrumb" class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12">
                        <ul class="breadcrumb-tree">
                            <li><a href="${pageContext.request.contextPath}/home">Home</a></li>
                                <c:if test="${not empty product}">
                                <li><a href="#">${product.categoryName}</a></li>
                                <li class="active">${product.productName}</li>
                                </c:if>
                                <c:if test="${empty product}">
                                <li class="active">Product Not Found</li>
                                </c:if>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        <!-- /BREADCRUMB -->

        <!-- SECTION -->
        <div class="section">
            <div class="container">
                <div class="row">

                    <c:choose>
                        <%-- ========== PRODUCT NOT FOUND ========== --%>
                        <c:when test="${empty product}">
                            <div class="col-md-12">
                                <div class="not-found-box">
                                    <i class="fa fa-search"></i>
                                    <h3>Product Not Found</h3>
                                    <p>The product you are looking for does not exist or has been removed.</p>
                                    <a href="${pageContext.request.contextPath}/home" class="primary-btn">Back to Home</a>
                                </div>
                            </div>
                        </c:when>

                        <%-- ========== PRODUCT FOUND ========== --%>
                        <c:otherwise>
                            <%-- Prepare image src once --%>
                            <c:set var="imgSrc" value="${pageContext.request.contextPath}/${product.imageUrl}" />

                            <!-- Product Image Slider -->
                            <div class="col-md-5 col-md-push-2">
                                <div class="pd-img-wrapper" id="pdImgWrapper">
                                    <!-- Arrow Left -->
                                    <div class="pd-img-arrow pd-img-prev" id="pdPrev">
                                        <i class="fa fa-angle-left"></i>
                                    </div>
                                    <!-- Slides track -->
                                    <div class="pd-img-track" id="pdTrack">
                                        <div class="pd-img-slide">
                                            <img src="${imgSrc}" alt="${product.productName}" id="pdMainImg">
                                        </div>
                                        <div class="pd-img-slide">
                                            <img src="${imgSrc}" alt="${product.productName} - view 2">
                                        </div>
                                        <div class="pd-img-slide">
                                            <img src="${imgSrc}" alt="${product.productName} - view 3">
                                        </div>
                                        <div class="pd-img-slide">
                                            <img src="${imgSrc}" alt="${product.productName} - view 4">
                                        </div>
                                    </div>
                                    <!-- Arrow Right -->
                                    <div class="pd-img-arrow pd-img-next" id="pdNext">
                                        <i class="fa fa-angle-right"></i>
                                    </div>
                                </div>

                                <!-- Thumbnails -->
                                <div class="pd-thumbs" id="pdThumbs">
                                    <div class="pd-thumb active" data-index="0">
                                        <img src="${imgSrc}" alt="Thumb 1">
                                    </div>
                                    <div class="pd-thumb" data-index="1">
                                        <img src="${imgSrc}" alt="Thumb 2">
                                    </div>
                                    <div class="pd-thumb" data-index="2">
                                        <img src="${imgSrc}" alt="Thumb 3">
                                    </div>
                                    <div class="pd-thumb" data-index="3">
                                        <img src="${imgSrc}" alt="Thumb 4">
                                    </div>
                                </div>
                            </div>
                            <!-- /Product Image Slider -->

                            <!-- Product Thumb Nav (left column placeholder) -->
                            <div class="col-md-2 col-md-pull-5">
                                <!-- intentionally empty – thumbnails are below the main image -->
                            </div>

                            <!-- Product Details -->
                            <div class="col-md-5">
                                <div class="product-details">
                                    <%-- Category badge --%>
                                    <p class="product-category" style="margin-bottom:6px;">
                                        <c:if test="${not empty product.brandName}">${product.brandName} &bull; </c:if>
                                        ${product.categoryName}
                                    </p>

                                    <h2 class="product-name">${product.productName}</h2>

                                    <%-- Rating (static) --%>
                                    <div>
                                        <div class="product-rating">
                                            <i class="fa fa-star"></i>
                                            <i class="fa fa-star"></i>
                                            <i class="fa fa-star"></i>
                                            <i class="fa fa-star"></i>
                                            <i class="fa fa-star-o"></i>
                                        </div>
                                        <a class="review-link" href="#tab3">Reviews | Add your review</a>
                                    </div>

                                    <%-- Price & Stock --%>
                                    <div style="margin: 14px 0;">
                                        <h3 class="product-price">
                                            <fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/> &#8363;
                                        </h3>
                                        <c:choose>
                                            <c:when test="${product.stockQuantity > 0}">
                                                <span class="product-available">
                                                    <i class="fa fa-check-circle"></i>
                                                    In Stock (${product.stockQuantity} available)
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="product-unavailable">
                                                    <i class="fa fa-times-circle"></i> Out of Stock
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <%-- Short description --%>
                                    <c:if test="${not empty product.description}">
                                        <p style="color:#666; font-size:14px; line-height:1.7;">${product.description}</p>
                                    </c:if>

                                    <%-- Add to Cart --%>
                                    <div class="add-to-cart" style="margin-top:16px;">
                                        <div class="qty-label">
                                            Qty
                                            <div class="input-number">
                                                <input type="number" value="1" min="1" max="${product.stockQuantity}">
                                                <span class="qty-up">+</span>
                                                <span class="qty-down">-</span>
                                            </div>
                                        </div>
                                        <button class="add-to-cart-btn"><i class="fa fa-shopping-cart"></i> add to cart</button>
                                    </div>

                                    <ul class="product-btns" style="margin-top:12px;">
                                        <li><a href="#"><i class="fa fa-heart-o"></i> add to wishlist</a></li>
                                        <li><a href="#"><i class="fa fa-exchange"></i> add to compare</a></li>
                                    </ul>

                                    <%-- Meta links --%>
                                    <ul class="product-links">
                                        <li>Category:</li>
                                        <li><a href="#">${product.categoryName}</a></li>
                                    </ul>
                                    <c:if test="${not empty product.brandName}">
                                        <ul class="product-links">
                                            <li>Brand:</li>
                                            <li><a href="#">${product.brandName}</a></li>
                                        </ul>
                                    </c:if>

                                    <ul class="product-links">
                                        <li>Share:</li>
                                        <li><a href="#"><i class="fa fa-facebook"></i></a></li>
                                        <li><a href="#"><i class="fa fa-twitter"></i></a></li>
                                        <li><a href="#"><i class="fa fa-google-plus"></i></a></li>
                                        <li><a href="#"><i class="fa fa-envelope"></i></a></li>
                                    </ul>
                                </div>
                            </div>
                            <!-- /Product Details -->

                            <!-- Product Tabs -->
                            <div class="col-md-12">
                                <div id="product-tab">
                                    <!-- Tab nav -->
                                    <ul class="tab-nav">
                                        <li class="active"><a data-toggle="tab" href="#tab1">Description</a></li>
                                        <li><a data-toggle="tab" href="#tab2">Specifications</a></li>
                                        <li><a data-toggle="tab" href="#tab3">Reviews (3)</a></li>
                                    </ul>

                                    <div class="tab-content">
                                        <!-- Tab 1: Description -->
                                        <div id="tab1" class="tab-pane fade in active">
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <c:choose>
                                                        <c:when test="${not empty product.description}">
                                                            <p>${product.description}</p>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <p>No description available for this product.</p>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Tab 2: Specifications -->
                                        <div id="tab2" class="tab-pane fade in">
                                            <div class="row">
                                                <div class="col-md-8">
                                                    <table class="specs-table">
                                                        <tbody>
                                                            <c:if test="${not empty product.brandName}">
                                                                <tr>
                                                                    <td>Brand</td>
                                                                    <td>${product.brandName}</td>
                                                                </tr>
                                                            </c:if>
                                                            <c:if test="${not empty product.categoryName}">
                                                                <tr>
                                                                    <td>Category</td>
                                                                    <td>${product.categoryName}</td>
                                                                </tr>
                                                            </c:if>
                                                            <c:if test="${not empty product.connectionType}">
                                                                <tr>
                                                                    <td>Connection Type</td>
                                                                    <td>${product.connectionType}</td>
                                                                </tr>
                                                            </c:if>
                                                            <c:if test="${not empty product.driverSize}">
                                                                <tr>
                                                                    <td>Driver Size</td>
                                                                    <td>${product.driverSize} mm</td>
                                                                </tr>
                                                            </c:if>
                                                            <tr>
                                                                <td>Noise Cancelling</td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${product.noiseCancelling}">
                                                                            <span style="color:#1a7a3a;font-weight:600;"><i class="fa fa-check"></i> Yes</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span style="color:#888;"><i class="fa fa-times"></i> No</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Microphone</td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${product.microphone}">
                                                                            <span style="color:#1a7a3a;font-weight:600;"><i class="fa fa-check"></i> Yes</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span style="color:#888;"><i class="fa fa-times"></i> No</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                            </tr>
                                                            <c:if test="${not empty product.batteryLife}">
                                                                <tr>
                                                                    <td>Battery Life</td>
                                                                    <td>${product.batteryLife} hours</td>
                                                                </tr>
                                                            </c:if>
                                                            <c:if test="${not empty product.waterResistance}">
                                                                <tr>
                                                                    <td>Water Resistance</td>
                                                                    <td>${product.waterResistance}</td>
                                                                </tr>
                                                            </c:if>
                                                            <c:if test="${not empty product.weight}">
                                                                <tr>
                                                                    <td>Weight</td>
                                                                    <td>${product.weight} g</td>
                                                                </tr>
                                                            </c:if>
                                                            <tr>
                                                                <td>Stock</td>
                                                                <td>${product.stockQuantity} units</td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Tab 3: Reviews -->
                                        <div id="tab3" class="tab-pane fade in">
                                            <div class="row">
                                                <!-- Rating summary -->
                                                <div class="col-md-3">
                                                    <div id="rating">
                                                        <div class="rating-avg">
                                                            <span>4.5</span>
                                                            <div class="rating-stars">
                                                                <i class="fa fa-star"></i>
                                                                <i class="fa fa-star"></i>
                                                                <i class="fa fa-star"></i>
                                                                <i class="fa fa-star"></i>
                                                                <i class="fa fa-star-o"></i>
                                                            </div>
                                                        </div>
                                                        <ul class="rating">
                                                            <li>
                                                                <div class="rating-stars"><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i></div>
                                                                <div class="rating-progress"><div style="width:80%;"></div></div>
                                                                <span class="sum">3</span>
                                                            </li>
                                                            <li>
                                                                <div class="rating-stars"><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star-o"></i></div>
                                                                <div class="rating-progress"><div style="width:60%;"></div></div>
                                                                <span class="sum">2</span>
                                                            </li>
                                                            <li>
                                                                <div class="rating-stars"><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star-o"></i><i class="fa fa-star-o"></i></div>
                                                                <div class="rating-progress"><div></div></div>
                                                                <span class="sum">0</span>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </div>
                                                <!-- Reviews list -->
                                                <div class="col-md-6">
                                                    <div id="reviews">
                                                        <ul class="reviews">
                                                            <li>
                                                                <div class="review-heading">
                                                                    <h5 class="name">John</h5>
                                                                    <p class="date">27 DEC 2025, 8:00 PM</p>
                                                                    <div class="review-rating">
                                                                        <i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star-o empty"></i>
                                                                    </div>
                                                                </div>
                                                                <div class="review-body"><p>Great product! Sound quality is amazing.</p></div>
                                                            </li>
                                                            <li>
                                                                <div class="review-heading">
                                                                    <h5 class="name">Sarah</h5>
                                                                    <p class="date">15 JAN 2026, 3:00 PM</p>
                                                                    <div class="review-rating">
                                                                        <i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i>
                                                                    </div>
                                                                </div>
                                                                <div class="review-body"><p>Excellent build quality and comfortable to wear for long periods.</p></div>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </div>
                                                <!-- Review Form -->
                                                <div class="col-md-3">
                                                    <div id="review-form">
                                                        <form class="review-form">
                                                            <input class="input" type="text" placeholder="Your Name">
                                                            <input class="input" type="email" placeholder="Your Email">
                                                            <textarea class="input" placeholder="Your Review"></textarea>
                                                            <div class="input-rating">
                                                                <span>Your Rating: </span>
                                                                <div class="stars">
                                                                    <input id="star5" name="rating" value="5" type="radio"><label for="star5"></label>
                                                                    <input id="star4" name="rating" value="4" type="radio"><label for="star4"></label>
                                                                    <input id="star3" name="rating" value="3" type="radio"><label for="star3"></label>
                                                                    <input id="star2" name="rating" value="2" type="radio"><label for="star2"></label>
                                                                    <input id="star1" name="rating" value="1" type="radio"><label for="star1"></label>
                                                                </div>
                                                            </div>
                                                            <button class="primary-btn">Submit</button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- /Product Tabs -->
                        </c:otherwise>
                    </c:choose>

                </div>
            </div>
        </div>
        <!-- /SECTION -->

        <!-- NEWSLETTER -->
        <div id="newsletter" class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12">
                        <div class="newsletter">
                            <p>Sign Up for the <strong>NEWSLETTER</strong></p>
                            <form>
                                <input class="input" type="email" placeholder="Enter Your Email">
                                <button class="newsletter-btn"><i class="fa fa-envelope"></i> Subscribe</button>
                            </form>
                            <ul class="newsletter-follow">
                                <li><a href="#"><i class="fa fa-facebook"></i></a></li>
                                <li><a href="#"><i class="fa fa-twitter"></i></a></li>
                                <li><a href="#"><i class="fa fa-instagram"></i></a></li>
                                <li><a href="#"><i class="fa fa-pinterest"></i></a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- /NEWSLETTER -->

        <!-- FOOTER -->
        <footer id="footer">
            <div class="section">
                <div class="container">
                    <div class="row">
                        <div class="col-md-3 col-xs-6">
                            <div class="footer">
                                <h3 class="footer-title">About Us</h3>
                                <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut.</p>
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
                                    <li><a href="#">Headphones</a></li>
                                    <li><a href="#">Earbuds</a></li>
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
                                    <li><a href="#">Terms &amp; Conditions</a></li>
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
                </div>
            </div>
            <!-- bottom footer -->
            <div id="bottom-footer" class="section">
                <div class="container">
                    <div class="row">
                        <div class="col-md-12 text-center">
                            <ul class="footer-payments">
                                <li><a href="#"><i class="fa fa-cc-visa"></i></a></li>
                                <li><a href="#"><i class="fa fa-credit-card"></i></a></li>
                                <li><a href="#"><i class="fa fa-cc-paypal"></i></a></li>
                                <li><a href="#"><i class="fa fa-cc-mastercard"></i></a></li>
                            </ul>
                            <span class="copyright">
                                Copyright &copy; <script>document.write(new Date().getFullYear());</script> All rights reserved
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

        <!-- Image Slider Script -->
        <script>
                                    (function () {
                                        var track = document.getElementById('pdTrack');
                                        var thumbs = document.querySelectorAll('#pdThumbs .pd-thumb');
                                        var btnPrev = document.getElementById('pdPrev');
                                        var btnNext = document.getElementById('pdNext');
                                        if (!track)
                                            return;

                                        var total = track.children.length;  // 4
                                        var current = 0;

                                        function goTo(idx) {
                                            if (idx < 0)
                                                idx = total - 1;
                                            if (idx >= total)
                                                idx = 0;
                                            current = idx;
                                            track.style.transform = 'translateX(-' + (current * 100) + '%)';
                                            thumbs.forEach(function (t, i) {
                                                t.classList.toggle('active', i === current);
                                            });
                                        }

                                        btnPrev.addEventListener('click', function () {
                                            goTo(current - 1);
                                        });
                                        btnNext.addEventListener('click', function () {
                                            goTo(current + 1);
                                        });

                                        thumbs.forEach(function (thumb) {
                                            thumb.addEventListener('click', function () {
                                                goTo(parseInt(this.getAttribute('data-index')));
                                            });
                                        });
                                    })();
        </script>

        <!-- Search Autocomplete (same as home.jsp) -->
        <style>
            .search-suggestion-item {
                display:flex;
                align-items:center;
                padding:8px 12px;
                cursor:pointer;
                border-bottom:1px solid #f0f0f0;
                text-decoration:none;
                color:#333;
                transition:background 0.15s;
            }
            .search-suggestion-item:hover, .search-suggestion-item.active {
                background:#f5f5f5;
            }
            .suggestion-img {
                width:40px;
                height:40px;
                object-fit:cover;
                border-radius:4px;
                margin-right:10px;
                flex-shrink:0;
                border:1px solid #eee;
            }
            .suggestion-info {
                flex:1;
                overflow:hidden;
            }
            .suggestion-name {
                font-size:13px;
                font-weight:600;
                color:#333;
                white-space:nowrap;
                overflow:hidden;
                text-overflow:ellipsis;
            }
            .suggestion-meta {
                font-size:11px;
                color:#999;
                margin-top:2px;
            }
            .suggestion-price {
                font-size:13px;
                font-weight:700;
                color:#D10024;
                white-space:nowrap;
                margin-left:8px;
            }
            .suggestion-no-result {
                padding:12px;
                text-align:center;
                color:#999;
                font-size:13px;
            }
        </style>
        <script>
            (function () {
                var searchInput = document.getElementById('search-input');
                var suggestionsBox = document.getElementById('search-suggestions');
                var searchForm = document.getElementById('search-form');
                var contextPath = '${pageContext.request.contextPath}';
                var debounceTimer = null;

                if (!searchInput || !suggestionsBox)
                    return;

                function hideSuggestions() {
                    suggestionsBox.style.display = 'none';
                }

                function escapeHtml(text) {
                    var d = document.createElement('div');
                    d.appendChild(document.createTextNode(text));
                    return d.innerHTML;
                }

                function formatPrice(price) {
                    return parseFloat(price).toLocaleString('vi-VN') + ' &#8363;';
                }

                function renderSuggestions(data) {
                    suggestionsBox.innerHTML = '';
                    if (!data || data.length === 0) {
                        suggestionsBox.innerHTML = '<div class="suggestion-no-result">No products found</div>';
                        suggestionsBox.style.display = 'block';
                        return;
                    }
                    data.forEach(function (item) {
                        var a = document.createElement('a');
                        a.className = 'search-suggestion-item';
                        a.href = contextPath + '/productDetail?id=' + item.productID;
                        var imgSrc = item.imageUrl.indexOf('http') === 0 ? item.imageUrl : contextPath + '/' + item.imageUrl;
                        a.innerHTML = '<img class="suggestion-img" src="' + imgSrc + '" alt="' + escapeHtml(item.productName) + '">' +
                                '<div class="suggestion-info"><div class="suggestion-name">' + escapeHtml(item.productName) + '</div>' +
                                '<div class="suggestion-meta">' + escapeHtml(item.categoryName || '') + '</div></div>' +
                                '<span class="suggestion-price">' + formatPrice(item.price) + '</span>';
                        suggestionsBox.appendChild(a);
                    });
                    suggestionsBox.style.display = 'block';
                }

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
                                renderSuggestions(JSON.parse(xhr.responseText));
                            } catch (e) {
                                hideSuggestions();
                            }
                        }
                    };
                    xhr.send();
                }

                searchInput.addEventListener('input', function () {
                    clearTimeout(debounceTimer);
                    var kw = this.value.trim();
                    debounceTimer = setTimeout(function () {
                        fetchSuggestions(kw);
                    }, 300);
                });

                document.addEventListener('click', function (e) {
                    if (!searchInput.contains(e.target) && !suggestionsBox.contains(e.target))
                        hideSuggestions();
                });

                searchInput.addEventListener('focus', function () {
                    if (this.value.trim().length >= 3 && suggestionsBox.innerHTML)
                        suggestionsBox.style.display = 'block';
                });

                searchForm.addEventListener('submit', function () {
                    hideSuggestions();
                });
            })();
        </script>

    </body>
</html>