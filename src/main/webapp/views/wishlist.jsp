<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Phải đăng nhập mới được vào wishlist --%>
<c:if test="${empty sessionScope.customer}">
    <c:redirect url="/authen/login.jsp" />
</c:if>

<%-- If accessed directly without servlet data, redirect to servlet --%>
<c:if test="${wishlistItems == null}">
    <c:redirect url="/wishlist" />
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>
        <c:choose>
            <c:when test="${not empty sessionScope.customer}">
                ${sessionScope.customer.fullName}'s Wishlist - Electro
            </c:when>
            <c:otherwise>
                My Wishlist - Electro
            </c:otherwise>
        </c:choose>
    </title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

    <!-- Slick -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick.css" />
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick-theme.css" />

    <!-- nouislider -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/nouislider.min.css" />

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Custom stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/wishlist.css?v=2.2" />

    <style>
        /* Exact steam layout overrides matching image */
        .steam-layout-container {
            max-width: 1170px;
            margin: 0 auto;
            padding: 20px 15px 40px 15px;
        }

        .steam-header-row {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 24px;
        }

        .steam-avatar-square {
            width: 68px;
            height: 68px;
            background: #fff;
            border: 2px solid #D10024;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 34px;
            font-weight: 700;
            color: #D10024;
            flex-shrink: 0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        .steam-title-text {
            margin: 0;
            font-size: 26px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #2B2D42;
        }

        .steam-toolbar-row {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 16px;
            width: 100%;
        }

        .steam-search-wrapper {
            flex: 1;
            min-width: 250px;
            position: relative;
        }

        .steam-search-input {
            width: 100%;
            height: 38px;
            padding: 0 36px 0 14px;
            border: 1px solid #E4E7ED;
            border-radius: 3px;
            font-size: 13px;
            outline: none;
            background: #fff;
            color: #333;
            box-sizing: border-box;
            transition: border-color 0.2s;
        }

        .steam-search-input:focus {
            border-color: #D10024;
        }

        .steam-search-icon {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #8D99AE;
            font-size: 13px;
        }

        .steam-btn-options {
            height: 38px;
            padding: 0 16px;
            background: #fff;
            border: 1px solid #E4E7ED;
            border-radius: 3px;
            font-size: 13px;
            font-weight: 600;
            color: #2B2D42;
            cursor: pointer;
            white-space: nowrap;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s;
        }

        .steam-btn-options:hover {
            border-color: #D10024;
            color: #D10024;
        }

        .steam-select-sort {
            height: 38px;
            padding: 0 14px;
            background: #fff;
            border: 1px solid #E4E7ED;
            border-radius: 3px;
            font-size: 13px;
            font-weight: 600;
            color: #2B2D42;
            cursor: pointer;
            outline: none;
            white-space: nowrap;
            transition: border-color 0.2s;
        }

        .steam-select-sort:focus,
        .steam-select-sort:hover {
            border-color: #D10024;
        }

        .steam-btn-share {
            width: 38px;
            height: 38px;
            background: #fff;
            border: 1px solid #E4E7ED;
            border-radius: 3px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #2B2D42;
            cursor: pointer;
            flex-shrink: 0;
            transition: all 0.2s;
        }

        .steam-btn-share:hover {
            border-color: #D10024;
            color: #D10024;
        }

        .steam-item-count-label {
            font-size: 12px;
            font-weight: 700;
            color: #8D99AE;
            text-transform: uppercase;
            margin-bottom: 12px;
            letter-spacing: 0.5px;
        }

        .steam-card-row {
            display: flex;
            align-items: stretch;
            background: #fff;
            border: 1px solid #E4E7ED;
            border-radius: 4px;
            margin-bottom: 12px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.03);
            overflow: hidden;
            transition: all 0.2s;
        }

        .steam-card-row:hover {
            border-color: #D10024;
            box-shadow: 0 4px 15px rgba(209, 0, 36, 0.08);
            transform: translateY(-1px);
        }

        .steam-rank-col {
            width: 36px;
            background: #FBFBFC;
            border-right: 1px solid #E4E7ED;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 8px;
            color: #8D99AE;
            flex-shrink: 0;
        }

        .steam-capsule-col {
            width: 292px;
            height: 136px;
            display: block;
            flex-shrink: 0;
            background: #fff;
            overflow: hidden;
            border-right: 1px solid #E4E7ED;
            position: relative;
        }

        .steam-capsule-col img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            padding: 8px;
            box-sizing: border-box;
            transition: transform 0.3s;
        }

        .steam-card-row:hover .steam-capsule-col img {
            transform: scale(1.04);
        }

        .steam-info-col {
            flex: 1;
            padding: 14px 20px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            min-width: 0;
        }

        .steam-item-title {
            margin: 0 0 6px 0;
            font-size: 18px;
            font-weight: 700;
            line-height: 1.25;
        }

        .steam-item-title a {
            color: #2B2D42;
            text-decoration: none;
            transition: color 0.2s;
        }

        .steam-item-title a:hover {
            color: #D10024;
        }

        .steam-meta-row {
            font-size: 11px;
            font-weight: 600;
            color: #8D99AE;
            text-transform: uppercase;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .steam-meta-btn-plus {
            background: #F4F5F7;
            border: 1px solid #E4E7ED;
            border-radius: 2px;
            width: 18px;
            height: 18px;
            font-size: 11px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            color: #2B2D42;
            padding: 0;
        }

        .steam-tags-row {
            display: flex;
            align-items: center;
            gap: 5px;
            flex-wrap: wrap;
            margin-top: 4px;
        }

        .steam-tag-pill {
            background: #F4F5F7;
            color: #2B2D42;
            border: 1px solid #E4E7ED;
            padding: 2px 8px;
            border-radius: 2px;
            font-size: 11px;
            font-weight: 600;
        }

        .steam-actions-col {
            width: 250px;
            padding: 14px 20px;
            background: #FDFDFD;
            border-left: 1px solid #E4E7ED;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: flex-end;
            flex-shrink: 0;
            box-sizing: border-box;
        }

        .steam-btn-remove {
            background: none;
            border: none;
            color: #8D99AE;
            font-size: 11px;
            font-weight: 600;
            cursor: pointer;
            padding: 0;
            display: inline-flex;
            align-items: center;
            gap: 3px;
            transition: color 0.2s;
        }

        .steam-btn-remove:hover {
            color: #D10024;
        }

        .steam-price-text {
            font-size: 16px;
            font-weight: 700;
            color: #D10024;
            white-space: nowrap;
        }

        .steam-btn-cart {
            background: #D10024;
            color: #fff;
            border: 2px solid #D10024;
            border-radius: 40px;
            padding: 7px 16px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            white-space: nowrap;
            transition: all 0.2s;
        }

        .steam-btn-cart:hover {
            background: #fff;
            color: #D10024;
        }

        .steam-empty-box {
            background: #fff;
            border: 1px solid #E4E7ED;
            border-radius: 4px;
            padding: 60px 20px;
            text-align: center;
            margin-bottom: 30px;
        }

        @media (max-width: 991px) {
            .steam-card-row {
                flex-direction: column;
            }
            .steam-rank-col {
                width: 100%;
                height: 28px;
                flex-direction: row;
                border-right: none;
                border-bottom: 1px solid #E4E7ED;
            }
            .steam-capsule-col {
                width: 100%;
                height: 180px;
                border-right: none;
                border-bottom: 1px solid #E4E7ED;
            }
            .steam-actions-col {
                width: 100%;
                flex-direction: row;
                align-items: center;
                border-left: none;
                border-top: 1px solid #E4E7ED;
            }
        }

        @media (max-width: 600px) {
            .steam-toolbar-row {
                flex-direction: column;
                align-items: stretch;
            }
            .steam-search-wrapper {
                width: 100%;
            }
            .steam-actions-col {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
            }
        }
    </style>
</head>
<body>
    <c:set var="activeNav" value="wishlist" scope="request" />

    <!-- HEADER COMPONENT -->
    <jsp:include page="/assets/components/header.jsp" />

    <!-- BREADCRUMB -->
    <div id="breadcrumb" class="section" style="padding: 15px 0; background: #FBFBFC; border-bottom: 1px solid #E4E7ED; margin-bottom: 20px;">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <ul class="breadcrumb-tree" style="list-style: none; padding: 0; margin: 0; display: flex; align-items: center; gap: 8px; font-size: 13px; color: #8D99AE;">
                        <li><a href="${pageContext.request.contextPath}/home" style="color: #333; text-decoration: none;">Home</a></li>
                        <li style="color: #E4E7ED;">/</li>
                        <li class="active" style="color: #D10024; font-weight: 600;">Wishlist</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <!-- /BREADCRUMB -->

    <!-- MAIN CONTENT CONTAINER (STEAM LAYOUT) -->
    <div class="steam-layout-container">

        <!-- 1. HEADER ROW: Avatar Box on Left, Title on Right -->
        <div class="steam-header-row">
            <div class="steam-avatar-square">
                <c:choose>
                    <c:when test="${not empty sessionScope.customer}">
                        ${fn:toUpperCase(fn:substring(sessionScope.customer.fullName, 0, 1))}
                    </c:when>
                    <c:otherwise>?</c:otherwise>
                </c:choose>
            </div>
            <div>
                <h1 class="steam-title-text">
                    <c:choose>
                        <c:when test="${not empty sessionScope.customer}">
                            ${sessionScope.customer.fullName}'s Wishlist
                        </c:when>
                        <c:otherwise>
                            My Wishlist
                        </c:otherwise>
                    </c:choose>
                </h1>
                <p style="margin: 4px 0 0 0; font-size: 13px; color: #8D99AE;">
                    <c:choose>
                        <c:when test="${not empty sessionScope.customer}">
                            Danh sách các sản phẩm yêu thích của khách hàng ${sessionScope.customer.fullName}
                        </c:when>
                        <c:otherwise>
                            Quản lý danh sách các sản phẩm tai nghe bạn quan tâm và yêu thích
                        </c:otherwise>
                    </c:choose>
                </p>
            </div>
        </div>

        <!-- 2. CONTROLS TOOLBAR: Single Horizontal Row -->
        <div class="steam-toolbar-row">
            <div class="steam-search-wrapper">
                <input type="text" id="wishlistFilterInput" class="steam-search-input"
                       placeholder="Search by name, tag, or category" />
                <i class="fa fa-search steam-search-icon"></i>
            </div>

            <button type="button" class="steam-btn-options" id="btnFilterOptions">
                Options <i class="fa fa-caret-down"></i>
            </button>

            <select id="wishlistSortSelect" class="steam-select-sort">
                <option value="rank">Sort by: Your Rank</option>
                <option value="name-asc">Sort by: Name (A-Z)</option>
                <option value="name-desc">Sort by: Name (Z-A)</option>
                <option value="price-asc">Sort by: Price (Low to High)</option>
                <option value="price-desc">Sort by: Price (High to Low)</option>
                <option value="date-desc">Sort by: Date Added</option>
            </select>

            <button type="button" class="steam-btn-share" title="Share wishlist" onclick="shareWishlist()">
                <i class="fa fa-share-alt"></i>
            </button>
        </div>

        <!-- 3. ITEM COUNT: Left Aligned Under Toolbar -->
        <div class="steam-item-count-label" id="wishlistCountLabel">
            <span id="itemCountDisplay">${fn:length(wishlistItems)}</span>
            <span id="itemCountUnit">${fn:length(wishlistItems) == 1 ? 'ITEM' : 'ITEMS'}</span>
        </div>

        <!-- 4. WISHLIST ITEMS CONTAINER -->
        <div id="wishlistItemsContainer">
            <c:forEach var="item" items="${wishlistItems}" varStatus="st">
                <div class="steam-card-row"
                     id="wishlist-item-${item.productId}"
                     data-id="${item.productId}"
                     data-name="${fn:escapeXml(item.productName)}"
                     data-price="${item.price}"
                     data-rank="${st.count}"
                     data-date="${item.addedAt != null ? item.addedAt : ''}"
                     data-tags="${fn:escapeXml(item.productName)} ${fn:escapeXml(item.categoryName)} ${fn:escapeXml(item.brandName)} ${fn:escapeXml(item.connectionType)}">

                    <!-- Col 1: Handle & Rank -->
                    <div class="steam-rank-col">
                        <i class="fa fa-bars" style="font-size: 11px; opacity: 0.6;"></i>
                        <span class="item-rank-number" style="font-size: 12px; font-weight: 700; color: #2B2D42;">${st.count}</span>
                    </div>

                    <!-- Col 2: Capsule Banner Image (292x136) -->
                    <a href="${pageContext.request.contextPath}/productDetail?id=${item.productId}" class="steam-capsule-col">
                        <c:choose>
                            <c:when test="${not empty item.imageUrl}">
                                <img src="${item.imageUrl}" alt="${fn:escapeXml(item.productName)}"
                                     onerror="this.src='${pageContext.request.contextPath}/assets/img/product01.png'"/>
                            </c:when>
                            <c:otherwise>
                                <img src="${pageContext.request.contextPath}/assets/img/product01.png" alt="${fn:escapeXml(item.productName)}"/>
                            </c:otherwise>
                        </c:choose>
                    </a>

                    <!-- Col 3: Details (Title, Categories, Brand, Tags) -->
                    <div class="steam-info-col">
                        <h3 class="steam-item-title">
                            <a href="${pageContext.request.contextPath}/productDetail?id=${item.productId}">
                                ${item.productName}
                            </a>
                        </h3>

                        <!-- My Categories -->
                        <div class="steam-meta-row">
                            <span>MY CATEGORIES:</span>
                            <span style="color: #2B2D42;">${not empty item.categoryName ? item.categoryName : 'Headphones'}</span>
                            <button type="button" class="steam-meta-btn-plus">+</button>
                        </div>

                        <!-- Brand / Release -->
                        <div class="steam-meta-row">
                            <span>BRAND:</span>
                            <span style="color: #2B2D42;">${not empty item.brandName ? item.brandName : 'AUTHENTIC'}</span>
                            <c:if test="${not empty item.connectionType}">
                                <span style="margin-left: 10px;">TYPE:</span>
                                <span style="color: #2B2D42;">${item.connectionType}</span>
                            </c:if>
                        </div>

                        <!-- User Tags -->
                        <div class="steam-tags-row">
                            <span style="font-size: 11px; font-weight: 600; color: #8D99AE; text-transform: uppercase;">USER TAGS:</span>
                            <c:if test="${not empty item.categoryName}">
                                <span class="steam-tag-pill">${item.categoryName}</span>
                            </c:if>
                            <c:if test="${not empty item.brandName}">
                                <span class="steam-tag-pill">${item.brandName}</span>
                            </c:if>
                            <c:if test="${not empty item.connectionType}">
                                <span class="steam-tag-pill">${item.connectionType}</span>
                            </c:if>
                            <c:if test="${item.noiseCancelling}">
                                <span class="steam-tag-pill">Noise Cancelling</span>
                            </c:if>
                            <c:choose>
                                <c:when test="${item.stockQuantity > 0}">
                                    <span class="steam-tag-pill" style="background:#E8F5E9; color:#2E7D32; border-color:#C8E6C9;">In Stock</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="steam-tag-pill" style="background:#FFEBEE; color:#C62828; border-color:#FFCDD2;">Out of Stock</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Col 4: Right Actions & Price -->
                    <div class="steam-actions-col">
                        <div style="display: flex; align-items: center; gap: 8px; font-size: 11px; color: #8D99AE;">
                            <span>Added on ${item.formattedAddedDate}</span>
                            <button type="button" class="steam-btn-remove" onclick="removeWishlistItem(${item.productId})">
                                <span style="color: #D10024; font-weight: bold;">&#10006;</span> remove
                            </button>
                        </div>

                        <div style="display: flex; align-items: center; gap: 10px; margin-top: auto;">
                            <div class="steam-price-text">
                                <fmt:formatNumber value="${item.price}" type="number" groupingUsed="true"/> &#8363;
                            </div>

                            <form action="${pageContext.request.contextPath}/cart" method="POST" style="margin: 0;">
                                <input type="hidden" name="action" value="add"/>
                                <input type="hidden" name="productId" value="${item.productId}"/>
                                <input type="hidden" name="quantity" value="1"/>
                                <button type="submit" class="steam-btn-cart">
                                    <i class="fa fa-shopping-cart"></i> Add to Cart
                                </button>
                            </form>
                        </div>
                    </div>

                </div>
            </c:forEach>
        </div>

        <!-- 5. EMPTY STATE (Visible when wishlist has 0 items) -->
        <div class="steam-empty-box" id="wishlistEmptyState"
             style="display: ${empty wishlistItems ? 'block' : 'none'};">
            <div style="font-size: 52px; color: #D10024; margin-bottom: 12px; opacity: 0.85;">
                <i class="fa fa-heart-o"></i>
            </div>
            <h2 style="font-size: 20px; font-weight: 700; color: #2B2D42; text-transform: uppercase; margin-bottom: 8px;">
                0 ITEMS IN WISHLIST
            </h2>
            <p style="color: #8D99AE; font-size: 13px; max-width: 460px; margin: 0 auto 20px auto; line-height: 1.6;">
                There are no items currently in this wishlist.<br/>
                Explore our catalog to find headphones and audio equipment you love and add them to your wishlist!
            </p>
            <a href="${pageContext.request.contextPath}/search"
               style="background: #D10024; color: #fff; border: 2px solid #D10024; border-radius: 40px; padding: 9px 24px; font-size: 13px; font-weight: 700; text-transform: uppercase; text-decoration: none; display: inline-flex; align-items: center; gap: 8px;">
                <i class="fa fa-shopping-bag"></i> Browse Products
            </a>
        </div>

    </div>
    <!-- /MAIN CONTENT CONTAINER -->

    <!-- FOOTER COMPONENT -->
    <jsp:include page="/assets/components/footer.jsp" />

    <!-- jQuery Plugins -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/slick.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/nouislider.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

    <!-- Wishlist Page Interactive Logic -->
    <script>
        const contextPath = '${pageContext.request.contextPath}';

        // Remove item from Wishlist via AJAX
        function removeWishlistItem(productId) {
            if (!productId) return;

            const itemRow = document.getElementById('wishlist-item-' + productId);
            if (itemRow) {
                itemRow.style.opacity = '0.4';
            }

            const formData = new URLSearchParams();
            formData.append('action', 'remove');
            formData.append('productId', productId);
            formData.append('format', 'json');

            fetch(contextPath + '/wishlist', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: formData.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    if (itemRow) {
                        itemRow.style.transition = 'all 0.3s ease';
                        itemRow.style.transform = 'translateX(40px)';
                        itemRow.style.opacity = '0';
                        setTimeout(() => {
                            itemRow.remove();
                            updateCount(data.count);
                            reindexRanks();
                        }, 300);
                    }
                    // Update header badge
                    const headerBadge = document.getElementById('headerWishlistQty');
                    if (headerBadge) {
                        headerBadge.innerText = data.count;
                    }
                    if (window.__wishlistProductIds) {
                        window.__wishlistProductIds.delete(parseInt(productId, 10));
                    }
                    if (typeof showSiteWishlistToast === 'function') {
                        showSiteWishlistToast(data.message || 'Đã xóa sản phẩm khỏi danh sách yêu thích.', false);
                    }
                } else {
                    if (itemRow) itemRow.style.opacity = '1';
                    if (typeof showSiteWishlistToast === 'function') {
                        showSiteWishlistToast(data.message || 'Có lỗi xảy ra khi xóa sản phẩm.', true);
                    }
                }
            })
            .catch(err => {
                if (itemRow) itemRow.style.opacity = '1';
                console.error(err);
                if (typeof showSiteWishlistToast === 'function') {
                    showSiteWishlistToast('Không thể kết nối đến máy chủ.', true);
                }
            });
        }

        // Update count and toggle empty box
        function updateCount(count) {
            const countDisplay = document.getElementById('itemCountDisplay');
            const countUnit = document.getElementById('itemCountUnit');
            const emptyState = document.getElementById('wishlistEmptyState');
            const itemsContainer = document.getElementById('wishlistItemsContainer');

            if (countDisplay) countDisplay.innerText = count;
            if (countUnit) countUnit.innerText = (count === 1 ? 'ITEM' : 'ITEMS');

            if (count <= 0) {
                if (emptyState) emptyState.style.display = 'block';
                if (itemsContainer) itemsContainer.style.display = 'none';
            } else {
                if (emptyState) emptyState.style.display = 'none';
                if (itemsContainer) itemsContainer.style.display = 'block';
            }
        }

        // Re-index rank numbers
        function reindexRanks() {
            const items = document.querySelectorAll('.steam-card-row');
            items.forEach((item, index) => {
                const rankNum = item.querySelector('.item-rank-number');
                if (rankNum) {
                    rankNum.innerText = (index + 1);
                }
                item.setAttribute('data-rank', (index + 1));
            });
        }

        // Live Search Filter
        const filterInput = document.getElementById('wishlistFilterInput');
        if (filterInput) {
            filterInput.addEventListener('input', function() {
                const term = this.value.trim().toLowerCase();
                const items = document.querySelectorAll('.steam-card-row');
                let visibleCount = 0;

                items.forEach(item => {
                    const tags = (item.getAttribute('data-tags') || '').toLowerCase();
                    if (term === '' || tags.includes(term)) {
                        item.style.display = 'flex';
                        visibleCount++;
                    } else {
                        item.style.display = 'none';
                    }
                });

                const countDisplay = document.getElementById('itemCountDisplay');
                if (countDisplay) {
                    countDisplay.innerText = visibleCount;
                }
            });
        }

        // Live Sorting
        const sortSelect = document.getElementById('wishlistSortSelect');
        if (sortSelect) {
            sortSelect.addEventListener('change', function() {
                const sortType = this.value;
                const container = document.getElementById('wishlistItemsContainer');
                const items = Array.from(container.querySelectorAll('.steam-card-row'));

                items.sort((a, b) => {
                    if (sortType === 'name-asc') {
                        return (a.getAttribute('data-name') || '').localeCompare(b.getAttribute('data-name') || '');
                    } else if (sortType === 'name-desc') {
                        return (b.getAttribute('data-name') || '').localeCompare(a.getAttribute('data-name') || '');
                    } else if (sortType === 'price-asc') {
                        return parseFloat(a.getAttribute('data-price') || 0) - parseFloat(b.getAttribute('data-price') || 0);
                    } else if (sortType === 'price-desc') {
                        return parseFloat(b.getAttribute('data-price') || 0) - parseFloat(a.getAttribute('data-price') || 0);
                    } else if (sortType === 'date-desc') {
                        return (b.getAttribute('data-date') || '').localeCompare(a.getAttribute('data-date') || '');
                    } else {
                        return parseInt(a.getAttribute('data-rank') || 0) - parseInt(b.getAttribute('data-rank') || 0);
                    }
                });

                items.forEach(item => container.appendChild(item));
            });
        }

        // Share Wishlist
        function shareWishlist() {
            if (navigator.clipboard) {
                navigator.clipboard.writeText(window.location.href)
                    .then(() => {
                        if (typeof showSiteWishlistToast === 'function') {
                            showSiteWishlistToast('Đã sao chép liên kết wishlist vào clipboard!', false);
                        }
                    })
                    .catch(() => {
                        if (typeof showSiteWishlistToast === 'function') {
                            showSiteWishlistToast('Không thể sao chép liên kết.', true);
                        }
                    });
            } else {
                if (typeof showSiteWishlistToast === 'function') {
                    showSiteWishlistToast('URL Wishlist: ' + window.location.href, false);
                }
            }
        }
    </script>
</body>
</html>
