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
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/productDetail.css" />
    </head>

    <body>
        <c:set var="activeNav" value="productDetail" scope="request" />
        <jsp:include page="/assets/components/header.jsp" />

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

                                    <%-- Rating (dynamic from DB) --%>
                                    <div>
                                        <div class="product-rating">
                                            <c:forEach var="i" begin="1" end="5">
                                                <c:choose>
                                                    <c:when test="${product.rating >= i}"><i class="fa fa-star"></i></c:when>
                                                    <c:when test="${product.rating >= i - 0.5}"><i class="fa fa-star-half-o"></i></c:when>
                                                    <c:otherwise><i class="fa fa-star-o"></i></c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </div>
                                        <a class="review-link" href="#tab3">
                                            <c:choose>
                                                <c:when test="${product.reviewCount > 0}">
                                                    <fmt:formatNumber value="${product.rating}" maxFractionDigits="1" minFractionDigits="1"/> (${product.reviewCount} Review<c:if test="${product.reviewCount > 1}">s</c:if>) | Add your review
                                                </c:when>
                                                <c:otherwise>
                                                    0 Review(s) | Add your review
                                                </c:otherwise>
                                            </c:choose>
                                        </a>
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
                                        <li><a data-toggle="tab" href="#tab3">Reviews (${reviewSummary != null ? reviewSummary.totalReviews : (product != null ? product.reviewCount : 0)})</a></li>
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
                                                </div>
                                                <!-- Reviews list -->
                                                <div class="col-md-6">
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
                                                                                <p>${fn:escapeXml(rev.comment)}</p>
                                                                            </div>
                                                                        </li>
                                                                    </c:forEach>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <li style="text-align: center; padding: 40px 15px; color: #888;">
                                                                        <i class="fa fa-comment-o" style="font-size: 38px; color: #ccc; margin-bottom: 12px; display: block;"></i>
                                                                        <p style="font-size: 14px; font-weight: 600; color: #555; margin-bottom: 4px;">No reviews yet</p>
                                                                        <p style="font-size: 13px; color: #999;">Be the first to review this product!</p>
                                                                    </li>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </ul>
                                                    </div>
                                                </div>
                                                <!-- Review Form / Login prompt -->
                                                <div class="col-md-3">
                                                    <div id="review-form">
                                                        <c:if test="${param.reviewSuccess == 'true'}">
                                                            <div class="alert alert-success" style="padding: 10px; font-size: 13px; margin-bottom: 15px; border-radius: 4px;">
                                                                <i class="fa fa-check-circle"></i> Thank you! Your review has been saved.
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${param.reviewError == 'invalid'}">
                                                            <div class="alert alert-danger" style="padding: 10px; font-size: 13px; margin-bottom: 15px; border-radius: 4px;">
                                                                <i class="fa fa-exclamation-circle"></i> Please select a rating (1-5 stars) and enter your comment.
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${param.reviewError == 'failed'}">
                                                            <div class="alert alert-danger" style="padding: 10px; font-size: 13px; margin-bottom: 15px; border-radius: 4px;">
                                                                <i class="fa fa-exclamation-circle"></i> Failed to submit review. Please try again.
                                                            </div>
                                                        </c:if>

                                                        <c:choose>
                                                            <c:when test="${not empty sessionScope.customer}">
                                                                <!-- Đã đăng nhập: Form viết / cập nhật đánh giá -->
                                                                <form class="review-form" action="${pageContext.request.contextPath}/productDetail" method="post">
                                                                    <input type="hidden" name="productId" value="${product.productId}">

                                                                    <div style="margin-bottom: 10px; font-size: 13px; color: #555;">
                                                                        Reviewing as: <strong style="color: #D10024;">${sessionScope.customer.fullName}</strong>
                                                                    </div>

                                                                    <textarea class="input" name="comment" placeholder="Write your review here..." required style="height: 110px; resize: vertical;">${userReview != null ? userReview.comment : ''}</textarea>

                                                                    <div class="input-rating" style="margin-top: 10px;">
                                                                        <span>Your Rating: </span>
                                                                        <div class="stars">
                                                                            <input id="star5" name="rating" value="5" type="radio" ${userReview != null && userReview.rating == 5 ? 'checked' : ''} required><label for="star5"></label>
                                                                            <input id="star4" name="rating" value="4" type="radio" ${userReview != null && userReview.rating == 4 ? 'checked' : ''}><label for="star4"></label>
                                                                            <input id="star3" name="rating" value="3" type="radio" ${userReview != null && userReview.rating == 3 ? 'checked' : ''}><label for="star3"></label>
                                                                            <input id="star2" name="rating" value="2" type="radio" ${userReview != null && userReview.rating == 2 ? 'checked' : ''}><label for="star2"></label>
                                                                            <input id="star1" name="rating" value="1" type="radio" ${userReview != null && userReview.rating == 1 ? 'checked' : ''}><label for="star1"></label>
                                                                        </div>
                                                                    </div>
                                                                    <button type="submit" class="primary-btn" style="margin-top: 12px; width: 100%; border-radius: 4px;">
                                                                        ${userReview != null ? 'Update Review' : 'Submit Review'}
                                                                    </button>
                                                                </form>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <!-- Chưa đăng nhập: Khóa chức năng tạo review -->
                                                                <div style="background: #fbfbfb; border: 1px dashed #dcdcdc; border-radius: 6px; padding: 22px 16px; text-align: center;">
                                                                    <i class="fa fa-lock" style="font-size: 32px; color: #D10024; margin-bottom: 12px; display: block;"></i>
                                                                    <h5 style="margin-bottom: 8px; color: #333; font-weight: 700;">Login Required</h5>
                                                                    <p style="font-size: 12px; color: #666; margin-bottom: 16px; line-height: 1.5;">
                                                                        You must be logged in to leave a review for this product.
                                                                    </p>
                                                                    <a href="${pageContext.request.contextPath}/login" class="primary-btn" style="display: block; width: 100%; padding: 9px 0; text-align: center; text-transform: uppercase; font-size: 12px; font-weight: 700; border-radius: 4px;">
                                                                        <i class="fa fa-sign-in"></i> Log In to Review
                                                                    </a>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
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
        <script>window.__contextPath = '${pageContext.request.contextPath}';</script>
        <script src="${pageContext.request.contextPath}/assets/js/productDetail.js"></script>

    </body>
</html>
