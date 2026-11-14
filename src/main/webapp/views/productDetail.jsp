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
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/productDetail.css?v=1.3" />
    </head>

    <body>
        <c:set var="activeNav" value="productDetail" scope="request" />
        <jsp:include page="/assets/components/header.jsp" />

        <!-- BREADCRUMB -->
        <!--        <div id="breadcrumb" class="section">
                    <div class="container">
                        <div class="row">
                            <div class="col-md-12">
                                <ul class="breadcrumb-tree">
                                    <li><a href="${pageContext.request.contextPath}/home">Home</a></li>
        <c:if test="${not empty product}">
        <li><a href="${pageContext.request.contextPath}/productList?category=${product.categoryId}">${product.categoryName}</a></li>
        <li class="active">${product.productName}</li>
        </c:if>
        <c:if test="${empty product}">
        <li class="active">Product Not Found</li>
        </c:if>
</ul>
</div>
</div>
</div>
</div>-->
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
                            <c:set var="imgSrc" value="${empty product.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(product.imageUrl, 'http') ? product.imageUrl : pageContext.request.contextPath.concat('/').concat(product.imageUrl))}" />

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

                                    <%-- Rating (dynamic from DB) --%>
                                    <div style="display: flex; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 14px;">
                                        <div class="product-rating" style="margin-right: 0;">
                                            <c:forEach var="i" begin="1" end="5">
                                                <c:choose>
                                                    <c:when test="${product.rating >= i}"><i class="fa fa-star"></i></c:when>
                                                    <c:when test="${product.rating >= i - 0.5}"><i class="fa fa-star-half-o"></i></c:when>
                                                    <c:otherwise><i class="fa fa-star-o"></i></c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </div>
                                        <a class="review-link" href="#tab3" onclick="switchToReviewsTab(event)" style="color: #8D99AE; font-size: 13px; text-decoration: none;">
                                            <c:choose>
                                                <c:when test="${product.reviewCount > 0}">
                                                    <fmt:formatNumber value="${product.rating}" maxFractionDigits="1" minFractionDigits="1"/> (${product.reviewCount} Reviews)
                                                </c:when>
                                                <c:otherwise>
                                                    0 Reviews
                                                </c:otherwise>
                                            </c:choose>
                                        </a>

                                        <%-- Top Quick Action: Write a Review or Log In --%>
                                        
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.customer || not empty sessionScope.user}">
                                                <a href="${pageContext.request.contextPath}/productReviews?id=${product.productId}"
                                                   class="primary-btn"
                                                   style="padding: 5px 14px; font-size: 12px; border-radius: 4px; font-weight: 700; text-transform: uppercase; display: inline-flex; align-items: center; gap: 6px; color: #FFFFFF !important; background-color: #D10024; text-decoration: none;">
                                                    <i class="fa fa-pencil-square-o"></i> ${userReview != null ? 'Edit Your Review' : 'Write a Review'}
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/login"
                                                   class="primary-btn"
                                                   style="padding: 5px 14px; font-size: 12px; border-radius: 4px; font-weight: 700; text-transform: uppercase; display: inline-flex; align-items: center; gap: 6px; color: #FFFFFF !important; background-color: #2B2D42; text-decoration: none;">
                                                    <i class="fa fa-sign-in"></i> Log In to Review
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                        
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
                                        <c:set var="inWishlist" value="${sessionScope.wishlistProductIds != null && sessionScope.wishlistProductIds.contains(product.productId)}" />
                                        <li><a href="javascript:void(0)" class="add-to-wishlist ${inWishlist ? 'in-wishlist' : ''}" data-product-id="${product.productId}" title="${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}"><i class="fa ${inWishlist ? 'fa-heart' : 'fa-heart-o'}" ${inWishlist ? 'style="color: #D10024;"' : ''}></i> <span>${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}</span></a></li>
                                        <li><a href="${pageContext.request.contextPath}/compare?idA=${product.productId}" class="add-to-compare" data-product-id="${product.productId}"><i class="fa fa-exchange"></i> add to compare</a></li>
                                    </ul>

                                    <%-- Meta links --%>
                                    <ul class="product-links">
                                        <li>Category:</li>
                                        <li><a href="${pageContext.request.contextPath}/productList?category=${product.categoryId}">${product.categoryName}</a></li>
                                    </ul>
                                    <c:if test="${not empty product.brandName}">
                                        <ul class="product-links">
                                            <li>Brand:</li>
                                            <li><a href="${pageContext.request.contextPath}/productList?q=${product.brandName}">${product.brandName}</a></li>
                                        </ul>
                                    </c:if>

                                    <ul class="product-links">
                                        <li>Share:</li>
                                        <li><span aria-label="Facebook"><i class="fa fa-facebook"></i></span></li>
                                        <li><span aria-label="Twitter"><i class="fa fa-twitter"></i></span></li>
                                        <li><span aria-label="Google"><i class="fa fa-google-plus"></i></span></li>
                                        <li><a href="mailto:support@headphone-shop.com?subject=${product.productName}"><i class="fa fa-envelope"></i></a></li>
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
                                        <li><a data-toggle="tab" href="#tab3">Reviews (${reviewSummary != null ? reviewSummary.totalReviews : (product != null ? product.reviewCount : 0)})</a></li>
                                    </ul>

                                    <div class="tab-content">
                                        <!-- Tab 1: Description -->
                                        <div id="tab1" class="tab-pane fade in active">
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <c:choose>
                                                        <c:when test="${not empty product.description}">
                                                            <p style="white-space: pre-line; line-height: 1.6;">${product.description}</p>
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
                                                <div class="col-md-12">
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
                                                <!-- Rating summary & Review Action (Left Column) -->
                                                <div class="col-md-4 pd-review-sidebar">
                                                    <div id="rating">
                                                        <div class="rating-avg">
                                                            <span><fmt:formatNumber value="${reviewSummary != null ? reviewSummary.avgRating : 0}" maxFractionDigits="1" minFractionDigits="1"/></span>
                                                            <div class="rating-stars">
                                                                <c:set var="curAvg" value="${reviewSummary != null ? reviewSummary.avgRating : 0}" />
                                                                <c:forEach var="i" begin="1" end="5">
                                                                    <c:choose>
                                                                        <c:when test="${curAvg >= i}"><i class="fa fa-star"></i></c:when>
                                                                        <c:when test="${curAvg >= i - 0.5}"><i class="fa fa-star-half-o"></i></c:when>
                                                                        <c:otherwise><i class="fa fa-star-o"></i></c:otherwise>
                                                                    </c:choose>
                                                                </c:forEach>
                                                            </div>
                                                        </div>
                                                        <ul class="rating">
                                                            <li>
                                                                <div class="rating-stars"><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i></div>
                                                                <div class="rating-progress"><div style="width:${reviewSummary != null ? reviewSummary.percent5 : 0}%;"></div></div>
                                                                <span class="sum">${reviewSummary != null ? reviewSummary.star5 : 0}</span>
                                                            </li>
                                                            <li>
                                                                <div class="rating-stars"><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star-o"></i></div>
                                                                <div class="rating-progress"><div style="width:${reviewSummary != null ? reviewSummary.percent4 : 0}%;"></div></div>
                                                                <span class="sum">${reviewSummary != null ? reviewSummary.star4 : 0}</span>
                                                            </li>
                                                            <li>
                                                                <div class="rating-stars"><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star-o"></i><i class="fa fa-star-o"></i></div>
                                                                <div class="rating-progress"><div style="width:${reviewSummary != null ? reviewSummary.percent3 : 0}%;"></div></div>
                                                                <span class="sum">${reviewSummary != null ? reviewSummary.star3 : 0}</span>
                                                            </li>
                                                            <li>
                                                                <div class="rating-stars"><i class="fa fa-star"></i><i class="fa fa-star"></i><i class="fa fa-star-o"></i><i class="fa fa-star-o"></i><i class="fa fa-star-o"></i></div>
                                                                <div class="rating-progress"><div style="width:${reviewSummary != null ? reviewSummary.percent2 : 0}%;"></div></div>
                                                                <span class="sum">${reviewSummary != null ? reviewSummary.star2 : 0}</span>
                                                            </li>
                                                            <li>
                                                                <div class="rating-stars"><i class="fa fa-star"></i><i class="fa fa-star-o"></i><i class="fa fa-star-o"></i><i class="fa fa-star-o"></i><i class="fa fa-star-o"></i></div>
                                                                <div class="rating-progress"><div style="width:${reviewSummary != null ? reviewSummary.percent1 : 0}%;"></div></div>
                                                                <span class="sum">${reviewSummary != null ? reviewSummary.star1 : 0}</span>
                                                            </li>
                                                        </ul>
                                                    </div>

                                                    <!-- Review Action Box (Left column) -->
                                                    <div class="pd-review-action-box" style="margin-top: 25px; padding-top: 20px; border-top: 1px solid #E4E7ED;">
                                                        <c:choose>
                                                            <c:when test="${not empty sessionScope.customer || not empty sessionScope.user}">
                                                                <c:set var="loggedInName" value="${not empty sessionScope.customer ? sessionScope.customer.fullName : (not empty sessionScope.user ? sessionScope.user.fullName : '')}" />
                                                                <p style="font-size: 13px; color: #555; margin-bottom: 12px;">
                                                                    Reviewing as: <strong style="color: #2B2D42;">${fn:escapeXml(loggedInName)}</strong>
                                                                </p>
                                                                <a href="${pageContext.request.contextPath}/productReviews?id=${product.productId}"
                                                                   class="primary-btn pd-btn-write-review"
                                                                   style="display: block; width: 100%; text-align: center; border-radius: 4px; padding: 12px 18px; font-weight: 700; text-transform: uppercase; font-size: 13px; letter-spacing: 0.5px; color: #FFFFFF !important; background-color: #D10024; border: 1px solid #D10024; text-decoration: none;">
                                                                    <i class="fa fa-pencil-square-o" style="margin-right: 5px;"></i> ${userReview != null ? 'Edit Your Review' : 'Write a Review'}
                                                                </a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="pd-login-prompt-box" style="background: #FBFBFC; border: 1px dashed #DCDFE6; border-radius: 6px; padding: 20px 16px; text-align: center;">
                                                                    <i class="fa fa-lock" style="font-size: 26px; color: #D10024; margin-bottom: 8px; display: block;"></i>
                                                                    <h5 style="margin-bottom: 6px; color: #333; font-weight: 700;">Login Required</h5>
                                                                    <p style="font-size: 12px; color: #666; margin-bottom: 14px; line-height: 1.5;">
                                                                        You must be logged in to leave a review for this product.
                                                                    </p>
                                                                    <a href="${pageContext.request.contextPath}/login"
                                                                       class="primary-btn pd-btn-login-review"
                                                                       style="display: block; width: 100%; padding: 10px 0; text-align: center; text-transform: uppercase; font-size: 12px; font-weight: 700; border-radius: 4px; color: #FFFFFF !important; background-color: #2B2D42; text-decoration: none;">
                                                                        <i class="fa fa-sign-in"></i> Log In to Review
                                                                    </a>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>

                                                <!-- Reviews list (Right Column - Expanded col-md-8) -->
                                                <div class="col-md-8 pd-reviews-container">
                                                    <!-- Reviews Header Bar with Action Button -->
                                                    <div style="display: flex; align-items: center; justify-content: space-between; border-bottom: 2px solid #E4E7ED; padding-bottom: 14px; margin-bottom: 22px; flex-wrap: wrap; gap: 12px;">
                                                        <h4 style="margin: 0; font-size: 18px; font-weight: 700; color: #2B2D42; text-transform: uppercase;">
                                                            Customer Reviews (${reviewSummary != null ? reviewSummary.totalReviews : (product != null ? product.reviewCount : 0)})
                                                        </h4>
                                                        <%-- 
                                                        <c:choose>
                                                            <c:when test="${not empty sessionScope.customer || not empty sessionScope.user}">
                                                                <a href="${pageContext.request.contextPath}/productReviews?id=${product.productId}"
                                                                   class="primary-btn"
                                                                   style="padding: 8px 18px; border-radius: 4px; font-size: 12.5px; font-weight: 700; text-transform: uppercase; display: inline-flex; align-items: center; gap: 6px; color: #fff !important; background-color: #D10024; text-decoration: none;">
                                                                    <i class="fa fa-pencil-square-o"></i> ${userReview != null ? 'Edit Your Review' : 'Write a Review'}
                                                                </a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <a href="${pageContext.request.contextPath}/login"
                                                                   class="primary-btn"
                                                                   style="padding: 8px 18px; border-radius: 4px; font-size: 12.5px; font-weight: 700; text-transform: uppercase; display: inline-flex; align-items: center; gap: 6px; color: #fff !important; background-color: #2B2D42; text-decoration: none;">
                                                                    <i class="fa fa-sign-in"></i> Log In to Review
                                                                </a>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        --%>
                                                    </div>

                                                    <c:if test="${param.reviewSuccess == 'true'}">
                                                        <div class="alert alert-success" style="padding: 12px 16px; font-size: 13.5px; margin-bottom: 20px; border-radius: 4px;">
                                                            <i class="fa fa-check-circle"></i> Thank you! Your review has been saved successfully.
                                                        </div>
                                                    </c:if>

                                                    <div id="reviews">
                                                        <ul class="reviews">
                                                            <c:choose>
                                                                <c:when test="${not empty reviews}">
                                                                    <c:forEach var="rev" items="${reviews}">
                                                                        <li>
                                                                            <div class="review-heading">
                                                                                <h5 class="name">${fn:escapeXml(rev.customerName)}</h5>
                                                                                <p class="date">${rev.formattedDate}</p>
                                                                                <div class="review-rating">
                                                                                    <c:forEach var="i" begin="1" end="5">
                                                                                        <c:choose>
                                                                                            <c:when test="${rev.rating >= i}"><i class="fa fa-star"></i></c:when>
                                                                                            <c:otherwise><i class="fa fa-star-o empty"></i></c:otherwise>
                                                                                        </c:choose>
                                                                                    </c:forEach>
                                                                                </div>
                                                                            </div>
                                                                            <div class="review-body">
                                                                                <p style="white-space: pre-line; color: #333; font-size: 13.5px; line-height: 1.6; margin-bottom: 8px;">${fn:escapeXml(rev.comment)}</p>
                                                                                <c:if test="${not empty rev.images}">
                                                                                    <div class="review-images-gallery" style="display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px;">
                                                                                        <c:forEach var="img" items="${rev.images}">
                                                                                            <a href="${img.imageUrl}" class="review-photo-link" onclick="openReviewPhotoModal(event, '${img.imageUrl}')" style="display: block; width: 72px; height: 72px; border-radius: 6px; overflow: hidden; border: 1px solid #e4e7ed; box-shadow: 0 1px 3px rgba(0,0,0,0.08); background-color: #f7f7f7; text-decoration: none;">
                                                                                                <img src="${img.imageUrl}" alt="Review photo" style="width: 100%; height: 100%; object-fit: cover; display: block; transition: transform 0.2s;" onmouseover="this.style.transform='scale(1.08)'" onmouseout="this.style.transform='scale(1)'" />
                                                                                            </a>
                                                                                        </c:forEach>
                                                                                    </div>
                                                                                </c:if>
                                                                            </div>
                                                                        </li>
                                                                    </c:forEach>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <li style="text-align: center; padding: 45px 15px; color: #888;">
                                                                        <i class="fa fa-comment-o" style="font-size: 42px; color: #ccc; margin-bottom: 12px; display: block;"></i>
                                                                        <p style="font-size: 15px; font-weight: 600; color: #555; margin-bottom: 6px;">No reviews yet</p>
                                                                        <p style="font-size: 13px; color: #999;">Be the first to review this product!</p>
                                                                    </li>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </ul>
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

        <!-- AI RECOMMENDATIONS SECTION -->
        <c:if test="${not empty aiRecommendations}">
            <div class="section">
                <div class="container">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="section-title text-center">
                                <h3 class="title">
                                    Similar AI Recommendations
                                    <span class="ai-title-badge"><i class="fa fa-magic"></i> AI Powered</span>
                                </h3>
                            </div>
                        </div>

                        <c:forEach var="item" items="${aiRecommendations}" varStatus="st">
                            <div class="col-md-3 col-xs-6">
                                <div class="product">
                                    <div class="product-img">
                                        <c:set var="itemImg" value="${item.imageUrl}"/>
                                        <img src="${empty itemImg ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(itemImg, 'http') ? itemImg : pageContext.request.contextPath.concat('/').concat(itemImg))}" alt="${item.productName}">
                                        <div class="product-label">
                                            <span class="sale ai-match"><i class="fa fa-bolt"></i> ${item.matchPercentage}% MATCH</span>
                                            <span class="new">AI PICK</span>
                                        </div>
                                    </div>
                                    <div class="product-body">
                                        <p class="product-category">${item.categoryName}</p>
                                        <h3 class="product-name">
                                            <a href="${pageContext.request.contextPath}/productDetail?id=${item.productId}&recId=${item.recommendationId}">
                                                ${item.productName}
                                            </a>
                                        </h3>
                                        <c:if test="${not empty item.aiReason}">
                                            <p class="ai-reason-hint"><i class="fa fa-magic"></i> ${item.aiReason}</p>
                                        </c:if>
                                        <h4 class="product-price">
                                            <fmt:formatNumber value="${item.price}" type="number" groupingUsed="true"/> &#8363;
                                        </h4>
                                        <div class="product-rating">
                                            <i class="fa fa-star"></i>
                                            <i class="fa fa-star"></i>
                                            <i class="fa fa-star"></i>
                                            <i class="fa fa-star"></i>
                                            <i class="fa fa-star"></i>
                                        </div>
                                        <div class="product-btns">
                                            <c:set var="inWishlist" value="${sessionScope.wishlistProductIds != null && sessionScope.wishlistProductIds.contains(item.productId)}" />
                                            <button type="button" class="add-to-wishlist ${inWishlist ? 'in-wishlist' : ''}" data-product-id="${item.productId}" title="${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}">
                                                <i class="fa ${inWishlist ? 'fa-heart' : 'fa-heart-o'}" ${inWishlist ? 'style="color: #D10024;"' : ''}></i>
                                                <span class="tooltipp">${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}</span>
                                            </button>
                                            <button type="button" class="add-to-compare" data-product-id="${item.productId}">
                                                <i class="fa fa-exchange"></i>
                                                <span class="tooltipp">add to compare</span>
                                            </button>
                                            <button class="quick-view" onclick="location.href = '${pageContext.request.contextPath}/productDetail?id=${item.productId}&recId=${item.recommendationId}'">
                                                <i class="fa fa-eye"></i>
                                                <span class="tooltipp">quick view</span>
                                            </button>
                                        </div>
                                    </div>
                                    <div class="add-to-cart">
                                        <form action="${pageContext.request.contextPath}/cart" method="POST" style="margin: 0;">
                                            <input type="hidden" name="action" value="add">
                                            <input type="hidden" name="productId" value="${item.productId}">
                                            <input type="hidden" name="quantity" value="1">
                                            <button type="submit" class="add-to-cart-btn">
                                                <i class="fa fa-shopping-cart"></i> add to cart
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                            <c:if test="${st.count % 2 == 0}">
                                <div class="clearfix visible-sm visible-xs"></div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </c:if>
        <!-- /AI RECOMMENDATIONS SECTION -->

        <!-- NEWSLETTER -->
        <div id="newsletter" class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12">
                        <div class="newsletter">
                            <p>Need help choosing the right <strong>HEADPHONES?</strong></p>
                            <a class="primary-btn" href="${pageContext.request.contextPath}/information?topic=help"><i class="fa fa-headphones"></i> Get Shopping Help</a>
                            <ul class="newsletter-follow">
                                <li><span aria-label="Facebook"><i class="fa fa-facebook"></i></span></li>
                                <li><span aria-label="Twitter"><i class="fa fa-twitter"></i></span></li>
                                <li><span aria-label="Instagram"><i class="fa fa-instagram"></i></span></li>
                                <li><span aria-label="Pinterest"><i class="fa fa-pinterest"></i></span></li>
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
                                <p>Authentic headphones and earbuds selected for sound quality, comfort and everyday reliability.</p>
                                <ul class="footer-links">
                                    <li><a href="${pageContext.request.contextPath}/information?topic=contact"><i class="fa fa-map-marker"></i>Contact information</a></li>
                                    <li><a href="tel:+8421955184"><i class="fa fa-phone"></i>+021-95-51-84</a></li>
                                    <li><a href="mailto:support@headphone-shop.com"><i class="fa fa-envelope-o"></i>support@headphone-shop.com</a></li>
                                </ul>
                            </div>
                        </div>
                        <div class="col-md-3 col-xs-6">
                            <div class="footer">
                                <h3 class="footer-title">Categories</h3>
                                <ul class="footer-links">
                                    <li><a href="${pageContext.request.contextPath}/productList?category=1">Headphones</a></li>
                                    <li><a href="${pageContext.request.contextPath}/productList?category=2">Earbuds</a></li>
                                    <li><a href="${pageContext.request.contextPath}/productList">All Products</a></li>
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
                                    <li><a href="${pageContext.request.contextPath}/information?topic=returns">Orders and Returns</a></li>
                                    <li><a href="${pageContext.request.contextPath}/information?topic=terms">Terms &amp; Conditions</a></li>
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
                </div>
            </div>
            <!-- bottom footer -->
            <div id="bottom-footer" class="section">
                <div class="container">
                    <div class="row">
                        <div class="col-md-12 text-center">
                            <ul class="footer-payments">
                                <li><span title="Visa"><i class="fa fa-cc-visa"></i></span></li>
                                <li><span title="Card payment"><i class="fa fa-credit-card"></i></span></li>
                                <li><span title="PayPal"><i class="fa fa-cc-paypal"></i></span></li>
                                <li><span title="Mastercard"><i class="fa fa-cc-mastercard"></i></span></li>
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
        <script>window.__contextPath = '${pageContext.request.contextPath}';</script>
        <script src="${pageContext.request.contextPath}/assets/js/productDetail.js"></script>

        <script>
            function switchToReviewsTab(e) {
                if (e) e.preventDefault();
                var tabLink = document.querySelector('#product-tab .tab-nav a[href="#tab3"]');
                if (tabLink) {
                    $(tabLink).tab('show');
                    var tabEl = document.getElementById('product-tab');
                    if (tabEl) {
                        tabEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                }
            }

            document.addEventListener('DOMContentLoaded', function() {
                if (window.location.hash === '#tab3' || window.location.search.indexOf('reviewSuccess') !== -1) {
                    var tabLink = document.querySelector('#product-tab .tab-nav a[href="#tab3"]');
                    if (tabLink) {
                        $(tabLink).tab('show');
                        var tabEl = document.getElementById('product-tab');
                        if (tabEl) {
                            tabEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
                        }
                    }
                }
            });
        </script>

        <!-- Review Photo Modal Lightbox -->
        <div id="reviewPhotoModal" style="display: none; position: fixed; z-index: 99999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.85); align-items: center; justify-content: center; backdrop-filter: blur(2px);" onclick="closeReviewPhotoModal()">
            <span style="position: absolute; top: 20px; right: 30px; color: #fff; font-size: 36px; font-weight: bold; cursor: pointer; line-height: 1;" onclick="closeReviewPhotoModal()">&times;</span>
            <img id="reviewModalImg" src="" alt="Full Review Photo" style="max-width: 90%; max-height: 85vh; border-radius: 8px; box-shadow: 0 5px 25px rgba(0,0,0,0.5); object-fit: contain;" onclick="event.stopPropagation();" />
        </div>
        <script>
            function openReviewPhotoModal(e, url) {
                if (e) e.preventDefault();
                var modal = document.getElementById('reviewPhotoModal');
                var img = document.getElementById('reviewModalImg');
                if (modal && img) {
                    img.src = url;
                    modal.style.display = 'flex';
                }
            }
            function closeReviewPhotoModal() {
                var modal = document.getElementById('reviewPhotoModal');
                if (modal) {
                    modal.style.display = 'none';
                    var img = document.getElementById('reviewModalImg');
                    if (img) img.src = '';
                }
            }
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') closeReviewPhotoModal();
            });
        </script>
    </body>
</html>
