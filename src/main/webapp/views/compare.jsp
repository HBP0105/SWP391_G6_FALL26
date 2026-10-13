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

    <title>So Sánh Sản Phẩm - Electro</title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

    <!-- Slick -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick.css" />
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick-theme.css" />

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Custom stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/compare.css?v=1.0" />
</head>
<body>
    <c:set var="activeNav" value="compare" scope="request" />

    <!-- HEADER COMPONENT -->
    <jsp:include page="/assets/components/header.jsp" />

    <!-- BREADCRUMB -->
    <div id="breadcrumb" class="section" style="padding: 15px 0; background: #FBFBFC; border-bottom: 1px solid #E4E7ED; margin-bottom: 25px;">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <ul class="breadcrumb-tree" style="list-style: none; padding: 0; margin: 0; display: flex; align-items: center; gap: 8px; font-size: 13px; color: #8D99AE;">
                        <li><a href="${pageContext.request.contextPath}/home" style="color: #333; text-decoration: none;">Home</a></li>
                        <li style="color: #E4E7ED;">/</li>
                        <li class="active" style="color: #D10024; font-weight: 600;">So Sánh Sản Phẩm</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <!-- /BREADCRUMB -->

    <!-- MAIN COMPARE CONTAINER -->
    <div class="compare-page-container">

        <!-- Title Section -->
        <div class="compare-title-section">
            <h1>So Sánh Sản Phẩm Tai Nghe</h1>
            <p>Đối chiếu trực quan thông số kỹ thuật, tính năng và giá cả giữa 2 mẫu tai nghe để chọn ra thiết bị phù hợp nhất</p>
        </div>

        <!-- 1. TOP COMPARISON ROW: Product A - Swap - Product B - Specs List -->
        <div class="compare-top-row" id="compareTopRow">

            <!-- SLOT PRODUCT A -->
            <div id="slotProductA">
                <c:choose>
                    <c:when test="${not empty productA}">
                        <div class="compare-product-box">
                            <span class="compare-slot-badge slot-a">Sản phẩm A</span>
                            <button type="button" class="compare-btn-remove-slot" title="Bỏ chọn" onclick="removeSlot('A')">
                                <i class="fa fa-times"></i>
                            </button>
                            <div class="compare-img-wrap">
                                <c:choose>
                                    <c:when test="${not empty productA.imageUrl}">
                                        <img src="${fn:startsWith(productA.imageUrl, 'http') || fn:startsWith(productA.imageUrl, '/') ? productA.imageUrl : pageContext.request.contextPath.concat('/').concat(productA.imageUrl)}"
                                             alt="${fn:escapeXml(productA.productName)}"
                                             onerror="this.src='${pageContext.request.contextPath}/assets/img/product01.png'"/>
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/assets/img/product01.png" alt="${fn:escapeXml(productA.productName)}"/>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="compare-meta-wrap">
                                <div class="compare-prod-brand">${not empty productA.brandName ? productA.brandName : 'Authentic'}</div>
                                <h4 class="compare-prod-name">
                                    <a href="${pageContext.request.contextPath}/productDetail?id=${productA.productId}">${productA.productName}</a>
                                </h4>
                                <div class="compare-prod-price">
                                    <fmt:formatNumber value="${productA.price}" type="number" groupingUsed="true"/> &#8363;
                                </div>
                                <form action="${pageContext.request.contextPath}/cart" method="POST" style="margin:0;">
                                    <input type="hidden" name="action" value="add"/>
                                    <input type="hidden" name="productId" value="${productA.productId}"/>
                                    <input type="hidden" name="quantity" value="1"/>
                                    <button type="submit" class="compare-btn-cart"><i class="fa fa-shopping-cart"></i> Thêm giỏ hàng</button>
                                </form>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="compare-product-box compare-empty-slot" onclick="focusSearch()">
                            <span class="compare-slot-badge slot-a">Sản phẩm A</span>
                            <div class="compare-empty-icon"><i class="fa fa-plus-circle"></i></div>
                            <div class="compare-empty-text">Chưa chọn Sản phẩm A</div>
                            <div class="compare-empty-subtext">Chọn tai nghe từ danh sách bên dưới để so sánh</div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- CENTER SWAP BUTTON -->
            <div class="compare-swap-column">
                <button type="button" class="btn-swap-products" onclick="swapProducts()" title="Đổi vị trí A ⇄ B">
                    <i class="fa fa-arrows-h"></i>
                </button>
            </div>

            <!-- SLOT PRODUCT B -->
            <div id="slotProductB">
                <c:choose>
                    <c:when test="${not empty productB}">
                        <div class="compare-product-box">
                            <span class="compare-slot-badge slot-b">Sản phẩm B</span>
                            <button type="button" class="compare-btn-remove-slot" title="Bỏ chọn" onclick="removeSlot('B')">
                                <i class="fa fa-times"></i>
                            </button>
                            <div class="compare-img-wrap">
                                <c:choose>
                                    <c:when test="${not empty productB.imageUrl}">
                                        <img src="${fn:startsWith(productB.imageUrl, 'http') || fn:startsWith(productB.imageUrl, '/') ? productB.imageUrl : pageContext.request.contextPath.concat('/').concat(productB.imageUrl)}"
                                             alt="${fn:escapeXml(productB.productName)}"
                                             onerror="this.src='${pageContext.request.contextPath}/assets/img/product01.png'"/>
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/assets/img/product01.png" alt="${fn:escapeXml(productB.productName)}"/>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="compare-meta-wrap">
                                <div class="compare-prod-brand">${not empty productB.brandName ? productB.brandName : 'Authentic'}</div>
                                <h4 class="compare-prod-name">
                                    <a href="${pageContext.request.contextPath}/productDetail?id=${productB.productId}">${productB.productName}</a>
                                </h4>
                                <div class="compare-prod-price">
                                    <fmt:formatNumber value="${productB.price}" type="number" groupingUsed="true"/> &#8363;
                                </div>
                                <form action="${pageContext.request.contextPath}/cart" method="POST" style="margin:0;">
                                    <input type="hidden" name="action" value="add"/>
                                    <input type="hidden" name="productId" value="${productB.productId}"/>
                                    <input type="hidden" name="quantity" value="1"/>
                                    <button type="submit" class="compare-btn-cart"><i class="fa fa-shopping-cart"></i> Thêm giỏ hàng</button>
                                </form>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="compare-product-box compare-empty-slot" onclick="focusSearch()">
                            <span class="compare-slot-badge slot-b">Sản phẩm B</span>
                            <div class="compare-empty-icon"><i class="fa fa-plus-circle"></i></div>
                            <div class="compare-empty-text">Chưa chọn Sản phẩm B</div>
                            <div class="compare-empty-subtext">Chọn tai nghe từ danh sách bên dưới để so sánh</div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- RIGHT SPECS COMPARISON CARD -->
            <div class="compare-specs-card">
                <div class="compare-specs-header">
                    <h3><i class="fa fa-sliders" style="color: #D10024;"></i> Bảng So Sánh Thông Số</h3>
                    <div class="compare-specs-legend">
                        <span class="tag-a"><i class="fa fa-circle"></i> SP A</span>
                        <span class="tag-b"><i class="fa fa-circle"></i> SP B</span>
                    </div>
                </div>

                <ul class="compare-specs-list" id="compareSpecsList">
                    <%-- Rendered dynamically and synchronized by compare.js --%>
                </ul>
            </div>

        </div>
        <!-- /TOP COMPARISON ROW -->

        <!-- 2. FILTER TOOLBAR: Categories options - Brands options - Search bar -->
        <div class="compare-filter-toolbar">
            <!-- Categories Options -->
            <div class="compare-filter-item">
                <select id="compareCategorySelect" class="compare-select">
                    <option value="0">Tất cả danh mục (Categories)</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}" ${selectedCatId == cat.categoryId ? 'selected' : ''}>
                            ${cat.categoryName} (${cat.productCount})
                        </option>
                    </c:forEach>
                </select>
            </div>

            <!-- Brands Options -->
            <div class="compare-filter-item">
                <select id="compareBrandSelect" class="compare-select">
                    <option value="0">Tất cả thương hiệu (Brands)</option>
                    <c:forEach var="br" items="${brands}">
                        <option value="${br.brandId}" ${selectedBrandId == br.brandId ? 'selected' : ''}>
                            ${br.brandName} (${br.productCount})
                        </option>
                    </c:forEach>
                </select>
            </div>

            <!-- Search Bar -->
            <div class="compare-search-wrapper">
                <input type="text" id="compareKeywordInput" class="compare-search-input"
                       placeholder="Tìm kiếm theo tên tai nghe để so sánh..."
                       value="${fn:escapeXml(searchKeyword)}"/>
                <button type="button" id="btnCompareSearch" class="compare-search-btn">
                    <i class="fa fa-search"></i> Tìm kiếm
                </button>
            </div>
        </div>
        <!-- /FILTER TOOLBAR -->

        <!-- 3. SEARCH RESULTS GRID -->
        <div class="compare-results-section">
            <div class="compare-results-header">
                <h2>
                    <i class="fa fa-th-large" style="color:#D10024; margin-right:6px;"></i>
                    Danh Sách Sản Phẩm (Search Results)
                </h2>
                <span class="compare-results-count" id="compareResultsCount">
                    (${totalCount} sản phẩm)
                </span>
            </div>

            <div class="compare-grid" id="compareGridContainer">
                <c:choose>
                    <c:when test="${not empty searchResults}">
                        <c:forEach var="p" items="${searchResults}">
                            <div class="compare-grid-item ${productA != null && productA.productId == p.productId ? 'selected-as-a' : ''} ${productB != null && productB.productId == p.productId ? 'selected-as-b' : ''}"
                                 data-product-id="${p.productId}">

                                <c:if test="${productA != null && productA.productId == p.productId}">
                                    <span class="selected-badge-flag flag-a">Đang là SP A</span>
                                </c:if>
                                <c:if test="${productB != null && productB.productId == p.productId}">
                                    <span class="selected-badge-flag flag-b">Đang là SP B</span>
                                </c:if>

                                <div class="compare-grid-img-wrap">
                                    <c:choose>
                                        <c:when test="${not empty p.imageUrl}">
                                            <img src="${fn:startsWith(p.imageUrl, 'http') || fn:startsWith(p.imageUrl, '/') ? p.imageUrl : pageContext.request.contextPath.concat('/').concat(p.imageUrl)}"
                                                 alt="${fn:escapeXml(p.productName)}"
                                                 onerror="this.src='${pageContext.request.contextPath}/assets/img/product01.png'"/>
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/assets/img/product01.png" alt="${fn:escapeXml(p.productName)}"/>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="compare-grid-cat">${not empty p.categoryName ? p.categoryName : 'Headphones'}</div>
                                <h4 class="compare-grid-name">
                                    <a href="${pageContext.request.contextPath}/productDetail?id=${p.productId}">${p.productName}</a>
                                </h4>
                                <div class="compare-grid-price">
                                    <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/> &#8363;
                                </div>
                                <div class="compare-grid-actions">
                                    <button type="button" class="btn-select-compare btn-select-a"
                                            onclick="selectProductForSlot('A', ${p.productId})">
                                        <i class="fa fa-plus"></i> Chọn vào A
                                    </button>
                                    <button type="button" class="btn-select-compare btn-select-b"
                                            onclick="selectProductForSlot('B', ${p.productId})">
                                        <i class="fa fa-plus"></i> Chọn vào B
                                    </button>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div style="grid-column: 1 / -1; text-align: center; padding: 40px 20px; color: #8D99AE; font-size: 14px;">
                            <i class="fa fa-search" style="font-size: 32px; margin-bottom: 10px; display: block; opacity: 0.5;"></i>
                            Không tìm thấy sản phẩm nào phù hợp tiêu chí tìm kiếm.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- PAGINATION CONTAINER -->
            <div class="compare-pagination-wrapper" id="comparePaginationContainer">
                <c:if test="${totalCount > 0}">
                    <div class="store-filter clearfix">
                        <span class="store-qty">
                            Hiển thị <strong>${fromIndex}-${toIndex}</strong> trên <strong>${totalCount}</strong> sản phẩm
                        </span>
                        <c:if test="${totalPages > 1}">
                            <ul class="store-pagination">
                                <c:if test="${currentPage > 1}">
                                    <li><a href="javascript:void(0)" onclick="goToComparePage(${currentPage - 1})"><i class="fa fa-angle-left"></i></a></li>
                                </c:if>
                                <c:forEach var="i" begin="1" end="${totalPages}">
                                    <c:choose>
                                        <c:when test="${i == currentPage}"><li class="active"><span>${i}</span></li></c:when>
                                        <c:otherwise><li><a href="javascript:void(0)" onclick="goToComparePage(${i})">${i}</a></li></c:otherwise>
                                    </c:choose>
                                </c:forEach>
                                <c:if test="${currentPage < totalPages}">
                                    <li><a href="javascript:void(0)" onclick="goToComparePage(${currentPage + 1})"><i class="fa fa-angle-right"></i></a></li>
                                </c:if>
                            </ul>
                        </c:if>
                    </div>
                </c:if>
            </div>
            <!-- /PAGINATION CONTAINER -->

        </div>
        <!-- /SEARCH RESULTS GRID -->

    </div>
    <!-- /MAIN COMPARE CONTAINER -->

    <!-- FOOTER COMPONENT -->
    <jsp:include page="/assets/components/footer.jsp" />

    <!-- jQuery Plugins -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/slick.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/nouislider.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

    <!-- Compare Interactive Script -->
    <script>
        window.__contextPath = '${pageContext.request.contextPath}';
        window.__initialProductA = ${not empty productAJson ? productAJson : 'null'};
        window.__initialProductB = ${not empty productBJson ? productBJson : 'null'};
        window.__initialCurrentPage = ${currentPage != null ? currentPage : 1};
        window.__initialTotalPages = ${totalPages != null ? totalPages : 1};
        window.__initialTotalCount = ${totalCount != null ? totalCount : 0};
        window.__initialFromIndex = ${fromIndex != null ? fromIndex : 0};
        window.__initialToIndex = ${toIndex != null ? toIndex : 0};
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/compare.js?v=1.1"></script>
</body>
</html>
