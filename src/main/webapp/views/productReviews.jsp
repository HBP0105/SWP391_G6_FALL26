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

        <title>Rate Product - Electro</title>

        <!-- Google font -->
        <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

        <!-- Bootstrap & Plugins (same as home.jsp) -->
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick.css" />
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick-theme.css" />
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/nouislider.min.css" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />
        <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css" />

        <style>
            :root {
                /* ==============================================================
                   REVIEW FORM WIDTH (CUSTOMIZE AS NEEDED: 950px, 1050px, 1140px, or 100%)
                   ============================================================== */
                --rate-card-max-width: 1050px;
            }

            /* ===== RATE PRODUCT PAGE (ELECTRO HOME THEME) ===== */
            .rate-product-section {
                padding: 40px 0 60px;
                background-color: #FBFBFC;
                min-height: 70vh;
            }

            .rate-card {
                max-width: var(--rate-card-max-width, 1050px);
                width: 100%;
                margin: 0 auto;
                background: #FFFFFF;
                border: 1px solid #E4E7ED;
                border-radius: 6px;
                box-shadow: 0 4px 16px rgba(30, 31, 41, 0.06);
                padding: 32px 40px;
                box-sizing: border-box;
            }

            .rate-card-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                border-bottom: 2px solid #E4E7ED;
                padding-bottom: 16px;
                margin-bottom: 22px;
                width: 100%;
                box-sizing: border-box;
            }

            .rate-card-title {
                font-size: 22px;
                font-weight: 700;
                color: #2B2D42;
                margin: 0;
                text-transform: uppercase;
                letter-spacing: 0.3px;
                position: relative;
            }

            .rate-card-title::after {
                content: '';
                position: absolute;
                left: 0;
                bottom: -18px;
                width: 70px;
                height: 3px;
                background-color: #D10024;
            }

            /* Product Summary Row */
            .rate-product-info {
                display: flex;
                align-items: flex-start;
                gap: 18px;
                padding-bottom: 20px;
                margin-bottom: 24px;
                border-bottom: 1px solid #F0F2F5;
                width: 100%;
                box-sizing: border-box;
            }

            .rate-product-thumb {
                width: 64px;
                height: 64px;
                border: 1px solid #E4E7ED;
                border-radius: 4px;
                overflow: hidden;
                flex-shrink: 0;
                background: #FFF;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .rate-product-thumb img {
                width: 100%;
                height: 100%;
                object-fit: contain;
            }

            .rate-product-meta {
                flex: 1;
                min-width: 0;
            }

            .rate-product-name {
                font-size: 14.5px;
                font-weight: 700;
                color: #2B2D42;
                margin: 0 0 5px;
                line-height: 1.4;
            }

            .rate-product-name a {
                color: #2B2D42;
                text-decoration: none;
            }

            .rate-product-name a:hover {
                color: #D10024;
            }

            .rate-product-variation {
                font-size: 12.5px;
                color: #8D99AE;
                margin: 0;
            }

            /* Product Quality Star Rating Row */
            .rate-quality-row {
                display: flex;
                align-items: center;
                margin-bottom: 22px;
                flex-wrap: wrap;
                gap: 16px;
            }

            .rate-quality-label {
                font-size: 14px;
                font-weight: 600;
                color: #2B2D42;
                min-width: 150px;
            }

            .rate-stars-wrap {
                display: flex;
                align-items: center;
                gap: 14px;
            }

            .rate-star-list {
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }

            .rate-star-btn {
                background: none;
                border: none;
                padding: 2px;
                cursor: pointer;
                font-size: 28px;
                line-height: 1;
                color: #E4E7ED;
                transition: transform 0.15s ease, color 0.15s ease;
            }

            .rate-star-btn:hover {
                transform: scale(1.12);
            }

            .rate-star-btn.active {
                color: #FFB800;
            }

            .rate-star-text {
                font-size: 14px;
                font-weight: 600;
                color: #FFB800;
                min-width: 80px;
            }

            /* Gray Review Container */
            .rate-editor-container {
                background-color: #F5F5F8;
                border: 1px solid #E4E7ED;
                border-radius: 6px;
                padding: 18px;
                margin-bottom: 20px;
            }

            /* Inner White Box with Structured Prompts + Textarea */
            .rate-inner-box {
                background-color: #FFFFFF;
                border: 1px solid #DCDFE6;
                border-radius: 4px;
                padding: 16px 18px;
                margin-bottom: 16px;
                transition: border-color 0.2s ease, box-shadow 0.2s ease;
            }

            .rate-inner-box:focus-within {
                border-color: #D10024;
                box-shadow: 0 0 0 2px rgba(209, 0, 36, 0.08);
            }

            .rate-prompt-group {
                margin-bottom: 12px;
            }

            .rate-prompt-group:last-of-type {
                margin-bottom: 14px;
            }

            .rate-prompt-label {
                display: block;
                font-size: 13.5px;
                font-weight: 700;
                color: #2B2D42;
                margin-bottom: 4px;
            }

            .rate-prompt-input {
                width: 100%;
                border: none;
                outline: none;
                font-size: 13.5px;
                color: #333;
                background: transparent;
                padding: 2px 0;
                font-family: 'Montserrat', sans-serif;
            }

            .rate-prompt-input::placeholder {
                color: #B9BABC;
            }

            .rate-divider {
                border: 0;
                border-top: 1px solid #ECEEF2;
                margin: 12px 0;
            }

            .rate-textarea {
                width: 100%;
                border: none;
                outline: none;
                resize: vertical;
                min-height: 110px;
                font-size: 13.5px;
                color: #333;
                background: transparent;
                padding: 0;
                font-family: 'Montserrat', sans-serif;
                line-height: 1.6;
            }

            .rate-textarea::placeholder {
                color: #B9BABC;
            }

            /* Photo Upload Bar (Only Photo Upload as requested) */
            .rate-upload-area {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .rate-upload-actions {
                display: flex;
                align-items: center;
                gap: 12px;
                flex-wrap: wrap;
            }

            .btn-add-photo {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 9px 18px;
                background-color: #FFFFFF;
                color: #D10024;
                border: 1px solid #D10024;
                border-radius: 4px;
                font-size: 13px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.2s ease;
            }

            .btn-add-photo:hover {
                background-color: #D10024;
                color: #FFFFFF;
            }

            .btn-add-photo i {
                font-size: 15px;
            }

            .rate-photo-counter {
                font-size: 12px;
                color: #8D99AE;
            }

            /* Preview Thumbnails Grid */
            .rate-photo-previews {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
            }

            .rate-photo-item {
                position: relative;
                width: 76px;
                height: 76px;
                border-radius: 4px;
                border: 1px solid #E4E7ED;
                overflow: hidden;
                background: #FFF;
                box-shadow: 0 2px 6px rgba(0, 0, 0, 0.06);
            }

            .rate-photo-item img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .rate-photo-remove {
                position: absolute;
                top: 3px;
                right: 3px;
                width: 20px;
                height: 20px;
                border-radius: 50%;
                background: rgba(30, 31, 41, 0.75);
                color: #FFF;
                border: none;
                font-size: 11px;
                line-height: 1;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: background 0.15s ease;
            }

            .rate-photo-remove:hover {
                background: #D10024;
            }

            /* Show Username Checkbox Row */
            .rate-username-row {
                display: flex;
                align-items: flex-start;
                gap: 12px;
                padding: 8px 0 24px;
                border-bottom: 1px solid #E4E7ED;
                margin-bottom: 24px;
            }

            .rate-checkbox-wrap {
                position: relative;
                display: inline-flex;
                align-items: center;
                margin-top: 2px;
            }

            .rate-checkbox-wrap input[type="checkbox"] {
                appearance: none;
                -webkit-appearance: none;
                width: 18px;
                height: 18px;
                border: 2px solid #D10024;
                border-radius: 3px;
                background-color: #FFF;
                cursor: pointer;
                position: relative;
                margin: 0;
                transition: all 0.15s ease;
            }

            .rate-checkbox-wrap input[type="checkbox"]:checked {
                background-color: #D10024;
                border-color: #D10024;
            }

            .rate-checkbox-wrap input[type="checkbox"]:checked::after {
                content: '\f00c';
                font-family: 'FontAwesome';
                font-size: 11px;
                color: #FFFFFF;
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
            }

            .rate-username-info {
                flex: 1;
            }

            .rate-username-title {
                font-size: 14px;
                font-weight: 600;
                color: #2B2D42;
                margin: 0 0 3px;
                cursor: pointer;
            }

            .rate-username-sub {
                font-size: 12.5px;
                color: #8D99AE;
                margin: 0;
            }

            /* Bottom Action Buttons */
            .rate-actions-footer {
                display: flex;
                align-items: center;
                justify-content: flex-end;
                gap: 14px;
            }

            .btn-rate-cancel {
                padding: 10px 28px;
                background-color: #FFFFFF;
                color: #2B2D42;
                border: 1px solid #E4E7ED;
                border-radius: 4px;
                font-size: 13px;
                font-weight: 700;
                text-transform: uppercase;
                cursor: pointer;
                transition: all 0.2s ease;
                text-decoration: none;
                display: inline-block;
            }

            .btn-rate-cancel:hover {
                background-color: #F5F5F8;
                border-color: #8D99AE;
                color: #2B2D42;
                text-decoration: none;
            }

            .btn-rate-submit {
                padding: 10px 36px;
                background-color: #D10024;
                color: #FFFFFF;
                border: 1px solid #D10024;
                border-radius: 4px;
                font-size: 13px;
                font-weight: 700;
                text-transform: uppercase;
                cursor: pointer;
                transition: all 0.2s ease;
            }

            .btn-rate-submit:hover {
                background-color: #b5001f;
                border-color: #b5001f;
            }

            @media (max-width: 576px) {
                .rate-card {
                    padding: 20px 16px;
                }
                .rate-quality-label {
                    min-width: 100%;
                }
            }
        </style>
    </head>

    <body>
        <c:set var="activeNav" value="home" scope="request" />
        <jsp:include page="/assets/components/header.jsp" />

        <!-- BREADCRUMB -->
<!--        <div id="breadcrumb" class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12">
                        <ul class="breadcrumb-tree">
                            <li><a href="${pageContext.request.contextPath}/home">Home</a></li>
                            <li><a href="${pageContext.request.contextPath}/search">Products</a></li>
                            <li class="active">Rate Product</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>-->
        <!-- /BREADCRUMB -->

        <!-- RATE PRODUCT SECTION -->
        <div class="section rate-product-section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12">

                        <div class="rate-card">
                            <!-- Title -->
                            <div class="rate-card-header">
                                <h2 class="rate-card-title">Rate Product</h2>
                            </div>

                            <!-- Alert Messages -->
                            <c:if test="${not empty successMessage}">
                                <div class="alert alert-success" style="font-size: 13px; border-radius: 4px;">
                                    <i class="fa fa-check-circle"></i> ${successMessage}
                                </div>
                            </c:if>
                            <c:if test="${not empty errorMessage}">
                                <div class="alert alert-danger" style="font-size: 13px; border-radius: 4px;">
                                    <i class="fa fa-exclamation-circle"></i> ${errorMessage}
                                </div>
                            </c:if>

                            <!-- Product Info Row -->
                            <div class="rate-product-info">
                                <div class="rate-product-thumb">
                                    <c:choose>
                                        <c:when test="${not empty product}">
                                            <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${fn:escapeXml(product.productName)}"
                                                 onerror="this.src='${pageContext.request.contextPath}/assets/img/product01.png'">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/assets/img/product01.png" alt="Product">
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="rate-product-meta">
                                    <h4 class="rate-product-name">
                                        <c:choose>
                                            <c:when test="${not empty product}">
                                                <a href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">
                                                    ${fn:escapeXml(product.productName)}
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                Sony WH-1000XM5 Wireless Noise Cancelling Headphones
                                            </c:otherwise>
                                        </c:choose>
                                    </h4>
                                    <p class="rate-product-variation">
                                        <c:choose>
                                            <c:when test="${not empty product}">
                                                Variation: ${not empty product.categoryName ? product.categoryName : 'Audio Gear'}
                                                <c:if test="${not empty product.brandName}"> - ${product.brandName}</c:if>
                                                <c:if test="${not empty product.connectionType}"> (${product.connectionType})</c:if>
                                            </c:when>
                                            <c:otherwise>
                                                Variation: Midnight Black, Wireless Bluetooth 5.2, Active Noise Cancelling
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </div>

                            <!-- Review Form -->
                            <form id="rateProductForm" action="${pageContext.request.contextPath}/ProductReviews" method="post" enctype="multipart/form-data">
                                <input type="hidden" name="productId" value="${not empty product ? product.productId : param.id}" />
                                <input type="hidden" name="rating" id="ratingInput" value="${not empty userReview ? userReview.rating : 5}" />

                                <!-- Product Quality Stars -->
                                <div class="rate-quality-row">
                                    <div class="rate-quality-label">Product Quality</div>
                                    <div class="rate-stars-wrap">
                                        <div class="rate-star-list" id="starList">
                                            <button type="button" class="rate-star-btn active" data-value="1" title="Terrible"><i class="fa fa-star"></i></button>
                                            <button type="button" class="rate-star-btn active" data-value="2" title="Poor"><i class="fa fa-star"></i></button>
                                            <button type="button" class="rate-star-btn active" data-value="3" title="Fair"><i class="fa fa-star"></i></button>
                                            <button type="button" class="rate-star-btn active" data-value="4" title="Good"><i class="fa fa-star"></i></button>
                                            <button type="button" class="rate-star-btn active" data-value="5" title="Amazing"><i class="fa fa-star"></i></button>
                                        </div>
                                        <span class="rate-star-text" id="ratingLabelText">Amazing</span>
                                    </div>
                                </div>

                                <!-- Gray Box with Inner White Box & Upload Photo Button -->
                                <div class="rate-editor-container">
                                    <div class="rate-inner-box">
                                        <div class="rate-prompt-group">
                                            <label class="rate-prompt-label" for="promptComfort">Wearing Comfort:</label>
                                            <input type="text" id="promptComfort" name="promptComfort" class="rate-prompt-input"
                                                   placeholder="e.g. Soft ear cushions, lightweight, comfortable for long listening sessions without pressure..."
                                                   value="${not empty promptComfort ? fn:escapeXml(promptComfort) : ''}" />
                                        </div>

                                        <div class="rate-prompt-group">
                                            <label class="rate-prompt-label" for="promptMic">Microphone Quality:</label>
                                            <input type="text" id="promptMic" name="promptMic" class="rate-prompt-input"
                                                   placeholder="e.g. Clear voice capture, good background noise cancellation for calls and gaming..."
                                                   value="${not empty promptMic ? fn:escapeXml(promptMic) : ''}" />
                                        </div>

                                        <div class="rate-prompt-group">
                                            <label class="rate-prompt-label" for="promptSound">Sound Quality:</label>
                                            <input type="text" id="promptSound" name="promptSound" class="rate-prompt-input"
                                                   placeholder="e.g. Punchy and deep bass, clear mids, crisp and detailed treble..."
                                                   value="${not empty promptSound ? fn:escapeXml(promptSound) : ''}" />
                                        </div>

                                        <hr class="rate-divider" />

                                        <textarea class="rate-textarea" name="comment" id="reviewComment"
                                                  placeholder="Share more thoughts on the product to help other buyers.">${not empty promptGeneralComment ? fn:escapeXml(promptGeneralComment) : (not empty userReview ? fn:escapeXml(userReview.comment) : '')}</textarea>
                                    </div>

                                    <!-- Photo Upload Area -->
                                    <div class="rate-upload-area">
                                        <div class="rate-photo-previews" id="photoPreviews"></div>

                                        <div class="rate-upload-actions">
                                            <input type="file" id="photoUploadInput" name="reviewPhotos" accept="image/*" multiple style="display: none;" />
                                            <button type="button" class="btn-add-photo" id="btnAddPhoto">
                                                <i class="fa fa-camera"></i> Add Photo
                                            </button>
                                            <span class="rate-photo-counter" id="photoCounter">0/5 photos</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Show Username Checkbox -->
                                <c:set var="actualUserName" value="${not empty sessionScope.customer ? sessionScope.customer.fullName : 'fsfu6g6n6u'}" />
                                <div class="rate-username-row">
                                    <div class="rate-checkbox-wrap">
                                        <input type="checkbox" id="showUsernameCheck" name="showUsername" value="true" checked />
                                    </div>
                                    <div class="rate-username-info">
                                        <label for="showUsernameCheck" class="rate-username-title">Show username on your review</label>
                                        <p class="rate-username-sub" id="usernamePreviewText">
                                            Your user name will be shown as <strong id="usernameDisplayVal">${fn:escapeXml(actualUserName)}</strong>
                                        </p>
                                    </div>
                                </div>

                                <!-- Action Buttons -->
                                <div class="rate-actions-footer">
                                    <c:choose>
                                        <c:when test="${not empty product}">
                                            <a href="${pageContext.request.contextPath}/productDetail?id=${product.productId}" class="btn-rate-cancel">CANCEL</a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/home" class="btn-rate-cancel">CANCEL</a>
                                        </c:otherwise>
                                    </c:choose>
                                    <button type="submit" class="btn-rate-submit">SUBMIT</button>
                                </div>
                            </form>

                        </div>

                    </div>
                </div>
            </div>
        </div>
        <!-- /RATE PRODUCT SECTION -->

        <jsp:include page="/assets/components/footer.jsp" />

        <!-- jQuery Plugins (same as home.jsp) -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/slick.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/nouislider.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/jquery.zoom.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

        <script>
            (function () {
                // 1. Interactive 5-Star Rating
                var ratingLabels = {
                    1: 'Terrible',
                    2: 'Poor',
                    3: 'Fair',
                    4: 'Good',
                    5: 'Amazing'
                };
                var ratingColors = {
                    1: '#8D99AE',
                    2: '#8D99AE',
                    3: '#F59E0B',
                    4: '#FFB800',
                    5: '#FFB800'
                };

                var starButtons = document.querySelectorAll('#starList .rate-star-btn');
                var ratingInput = document.getElementById('ratingInput');
                var ratingLabelText = document.getElementById('ratingLabelText');
                var currentRating = parseInt(ratingInput.value, 10) || 5;

                function renderStars(score) {
                    starButtons.forEach(function (btn) {
                        var val = parseInt(btn.getAttribute('data-value'), 10);
                        var icon = btn.querySelector('i');
                        if (val <= score) {
                            btn.classList.add('active');
                            if (icon) icon.className = 'fa fa-star';
                        } else {
                            btn.classList.remove('active');
                            if (icon) icon.className = 'fa fa-star-o';
                        }
                    });
                    if (ratingLabelText) {
                        ratingLabelText.textContent = ratingLabels[score] || 'Amazing';
                        ratingLabelText.style.color = ratingColors[score] || '#FFB800';
                    }
                }

                renderStars(currentRating);

                starButtons.forEach(function (btn) {
                    btn.addEventListener('click', function () {
                        currentRating = parseInt(this.getAttribute('data-value'), 10);
                        ratingInput.value = currentRating;
                        renderStars(currentRating);
                    });

                    btn.addEventListener('mouseenter', function () {
                        var hoverVal = parseInt(this.getAttribute('data-value'), 10);
                        renderStars(hoverVal);
                    });
                });

                var starListEl = document.getElementById('starList');
                if (starListEl) {
                    starListEl.addEventListener('mouseleave', function () {
                        renderStars(currentRating);
                    });
                }

                // 2. Photo Upload & Preview (Max 5 photos, supporting edit & delete existing photos)
                var photoInput = document.getElementById('photoUploadInput');
                var btnAddPhoto = document.getElementById('btnAddPhoto');
                var photoPreviews = document.getElementById('photoPreviews');
                var photoCounter = document.getElementById('photoCounter');
                var rateForm = document.getElementById('rateProductForm');

                var existingImages = [
                    <c:if test="${not empty userReview and not empty userReview.images}">
                        <c:forEach var="exImg" items="${userReview.images}" varStatus="st">
                            {
                                id: ${exImg.imageId},
                                url: '${fn:escapeXml(exImg.imageUrl)}'
                            }<c:if test="${!st.last}">,</c:if>
                        </c:forEach>
                    </c:if>
                ];
                var deletedImageIds = [];
                var selectedFiles = [];
                var MAX_PHOTOS = 5;

                function syncDeletedInputs() {
                    if (!rateForm) return;
                    var oldInputs = rateForm.querySelectorAll('input[name="deletedImageIds"]');
                    oldInputs.forEach(function (inp) { inp.remove(); });

                    deletedImageIds.forEach(function (id) {
                        var hidden = document.createElement('input');
                        hidden.type = 'hidden';
                        hidden.name = 'deletedImageIds';
                        hidden.value = id;
                        rateForm.appendChild(hidden);
                    });
                }

                function syncInputFiles() {
                    if (typeof DataTransfer !== 'undefined' && photoInput) {
                        var dt = new DataTransfer();
                        selectedFiles.forEach(function (file) {
                            dt.items.add(file);
                        });
                        photoInput.files = dt.files;
                    }
                }

                function renderPhotoPreviews() {
                    photoPreviews.innerHTML = '';

                    // A. Render existing images
                    existingImages.forEach(function (exImg, index) {
                        var item = document.createElement('div');
                        item.className = 'rate-photo-item';

                        var img = document.createElement('img');
                        img.src = exImg.url;
                        img.alt = 'Review Photo';

                        var removeBtn = document.createElement('button');
                        removeBtn.type = 'button';
                        removeBtn.className = 'rate-photo-remove';
                        removeBtn.title = 'Remove photo';
                        removeBtn.innerHTML = '<i class="fa fa-times"></i>';
                        removeBtn.addEventListener('click', function () {
                            deletedImageIds.push(exImg.id);
                            existingImages.splice(index, 1);
                            syncDeletedInputs();
                            renderPhotoPreviews();
                        });

                        item.appendChild(img);
                        item.appendChild(removeBtn);
                        photoPreviews.appendChild(item);
                    });

                    // B. Render newly selected files
                    selectedFiles.forEach(function (file, index) {
                        var item = document.createElement('div');
                        item.className = 'rate-photo-item';

                        var img = document.createElement('img');
                        img.alt = file.name;
                        var reader = new FileReader();
                        reader.onload = function (e) {
                            img.src = e.target.result;
                        };
                        reader.readAsDataURL(file);

                        var removeBtn = document.createElement('button');
                        removeBtn.type = 'button';
                        removeBtn.className = 'rate-photo-remove';
                        removeBtn.title = 'Remove photo';
                        removeBtn.innerHTML = '<i class="fa fa-times"></i>';
                        removeBtn.addEventListener('click', function () {
                            selectedFiles.splice(index, 1);
                            syncInputFiles();
                            renderPhotoPreviews();
                        });

                        item.appendChild(img);
                        item.appendChild(removeBtn);
                        photoPreviews.appendChild(item);
                    });

                    var totalPhotos = existingImages.length + selectedFiles.length;
                    if (photoCounter) {
                        photoCounter.textContent = totalPhotos + '/' + MAX_PHOTOS + ' photos';
                    }
                    if (btnAddPhoto) {
                        btnAddPhoto.style.display = totalPhotos >= MAX_PHOTOS ? 'none' : 'inline-flex';
                    }
                }

                if (btnAddPhoto && photoInput) {
                    btnAddPhoto.addEventListener('click', function () {
                        var totalPhotos = existingImages.length + selectedFiles.length;
                        if (totalPhotos < MAX_PHOTOS) {
                            photoInput.click();
                        }
                    });

                    photoInput.addEventListener('change', function (e) {
                        var files = Array.prototype.slice.call(e.target.files || []);
                        files.forEach(function (file) {
                            if (!file.type.startsWith('image/')) return;
                            var totalPhotos = existingImages.length + selectedFiles.length;
                            if (totalPhotos < MAX_PHOTOS) {
                                selectedFiles.push(file);
                            }
                        });
                        photoInput.value = '';
                        syncInputFiles();
                        renderPhotoPreviews();
                    });
                }

                if (rateForm) {
                    rateForm.addEventListener('submit', function () {
                        syncInputFiles();
                        syncDeletedInputs();
                        var submitBtn = rateForm.querySelector('button[type="submit"]');
                        if (submitBtn) {
                            submitBtn.disabled = true;
                            submitBtn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Submitting...';
                        }
                    });
                }

                // Initial render to display any existing review photos
                renderPhotoPreviews();

                // 3. Show Username Toggle
                var showUsernameCheck = document.getElementById('showUsernameCheck');
                var usernameDisplayVal = document.getElementById('usernameDisplayVal');
                var defaultUsername = usernameDisplayVal ? usernameDisplayVal.textContent : 'fsfu6g6n6u';

                function maskUsername(name) {
                    if (!name || name.length <= 2) return 'u***r';
                    return name.charAt(0) + '*****' + name.charAt(name.length - 1);
                }

                if (showUsernameCheck && usernameDisplayVal) {
                    showUsernameCheck.addEventListener('change', function () {
                        usernameDisplayVal.textContent = this.checked ? defaultUsername : maskUsername(defaultUsername);
                    });
                }
            })();
        </script>
    </body>

</html>
