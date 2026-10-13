<%@ page contentType="text/html;charset=UTF-8" language="java" %>
	<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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

			<link type="text/css" rel="stylesheet"
				href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />
			<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick.css" />
			<link type="text/css" rel="stylesheet"
				href="${pageContext.request.contextPath}/assets/css/slick-theme.css" />
			<link type="text/css" rel="stylesheet"
			<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">
			<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />
			<link type="text/css" rel="stylesheet"
				href="${pageContext.request.contextPath}/assets/css/searchPage.css" />
			<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
			<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
			<!--[if lt IE 9]>
		  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
		  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
		<![endif]-->

		</head>

		<body>
			<c:set var="activeNav" value="search" scope="request" />
			<jsp:include page="/assets/components/header.jsp" />

			<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
			<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

			<%-- Base URL (keeps keyword + filters + sort) used for pagination links --%>
			<c:url var="pageBaseUrl" value="/productList">
				<c:param name="q" value="${keyword}" />
				<c:forEach var="cid" items="${selectedCategoryIds}"><c:param name="category" value="${cid}" /></c:forEach>
				<c:forEach var="bid" items="${selectedBrandIds}"><c:param name="brand" value="${bid}" /></c:forEach>
				<c:param name="minPrice" value="${minPrice}" />
				<c:param name="maxPrice" value="${maxPrice}" />
				<c:param name="sort" value="${sort}" />
			</c:url>
			<c:url var="clearFilterUrl" value="/productList">
				<c:param name="q" value="${keyword}" />
			</c:url>

			<!-- BREADCRUMB -->
			<div id="breadcrumb" class="section">
				<div class="container">
					<div class="row">
						<div class="col-md-12">
							<ul class="breadcrumb-tree">
								<li><a href="${pageContext.request.contextPath}/home">Home</a></li>
								<li><a href="${pageContext.request.contextPath}/productList">All Products</a></li>
								<li class="active">
									<c:choose>
										<c:when test="${not empty keyword}">"${fn:escapeXml(keyword)}"</c:when>
										<c:otherwise>Search</c:otherwise>
									</c:choose>
									(${totalResults} Results)
								</li>
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
						<!-- ASIDE (filter form) -->
						<div id="aside" class="col-md-3">
							<form id="filter-form" action="${pageContext.request.contextPath}/productList" method="get">
								<input type="hidden" name="q" value="${fn:escapeXml(keyword)}">

								<!-- Categories -->
								<div class="aside">
									<h3 class="aside-title">Categories</h3>
									<div class="checkbox-filter">
										<c:choose>
											<c:when test="${not empty categories}">
												<c:forEach var="cat" items="${categories}">
													<div class="input-checkbox">
														<input type="checkbox" id="category-${cat.categoryId}" name="category"
															value="${cat.categoryId}" class="auto-submit"
															${selectedCategoryIds.contains(cat.categoryId) ? 'checked' : ''}>
														<label for="category-${cat.categoryId}">
															<span></span>
															${fn:escapeXml(cat.categoryName)}
															<small>(${cat.productCount})</small>
														</label>
													</div>
												</c:forEach>
											</c:when>
											<c:otherwise>
												<%-- Database has no categories: keep template defaults --%>
												<div class="input-checkbox">
													<input type="checkbox" id="category-1">
													<label for="category-1"><span></span>Laptops<small>(120)</small></label>
												</div>
												<div class="input-checkbox">
													<input type="checkbox" id="category-2">
													<label for="category-2"><span></span>Smartphones<small>(740)</small></label>
												</div>
												<div class="input-checkbox">
													<input type="checkbox" id="category-3">
													<label for="category-3"><span></span>Cameras<small>(1450)</small></label>
												</div>
												<div class="input-checkbox">
													<input type="checkbox" id="category-4">
													<label for="category-4"><span></span>Accessories<small>(578)</small></label>
												</div>
												<div class="input-checkbox">
													<input type="checkbox" id="category-5">
													<label for="category-5"><span></span>Laptops<small>(120)</small></label>
												</div>
												<div class="input-checkbox">
													<input type="checkbox" id="category-6">
													<label for="category-6"><span></span>Smartphones<small>(740)</small></label>
												</div>
											</c:otherwise>
										</c:choose>
									</div>
								</div>
								<!-- /Categories -->

								<!-- Price (no slider) -->
								<div class="aside">
									<h3 class="aside-title">Price</h3>
									<div class="price-filter">
										<div class="input-number price-min">
											<input id="filter-price-min" name="minPrice" type="number" min="0" step="1000"
												placeholder="Min" value="${minPrice}">
										</div>
										<span>-</span>
										<div class="input-number price-max">
											<input id="filter-price-max" name="maxPrice" type="number" min="0" step="1000"
												placeholder="Max" value="${maxPrice}">
										</div>
									</div>
									<button type="submit" id="price-apply-btn" class="primary-btn"
										style="margin-top:15px;width:100%;padding:8px 0;">Apply</button>
								</div>
								<!-- /Price -->

								<!-- Brand -->
								<div class="aside">
									<h3 class="aside-title">Brand</h3>
									<div class="checkbox-filter">
										<c:choose>
											<c:when test="${not empty brands}">
												<c:forEach var="br" items="${brands}">
													<div class="input-checkbox">
														<input type="checkbox" id="brand-${br.brandId}" name="brand"
															value="${br.brandId}" class="auto-submit"
															${selectedBrandIds.contains(br.brandId) ? 'checked' : ''}>
														<label for="brand-${br.brandId}">
															<span></span>
															${fn:escapeXml(br.brandName)}
															<small>(${br.productCount})</small>
														</label>
													</div>
												</c:forEach>
											</c:when>
											<c:otherwise>
												<%-- Database has no brands: keep template defaults --%>
												<div class="input-checkbox">
													<input type="checkbox" id="brand-1">
													<label for="brand-1"><span></span>SAMSUNG<small>(578)</small></label>
												</div>
												<div class="input-checkbox">
													<input type="checkbox" id="brand-2">
													<label for="brand-2"><span></span>LG<small>(125)</small></label>
												</div>
												<div class="input-checkbox">
													<input type="checkbox" id="brand-3">
													<label for="brand-3"><span></span>SONY<small>(755)</small></label>
												</div>
												<div class="input-checkbox">
													<input type="checkbox" id="brand-4">
													<label for="brand-4"><span></span>SAMSUNG<small>(578)</small></label>
												</div>
												<div class="input-checkbox">
													<input type="checkbox" id="brand-5">
													<label for="brand-5"><span></span>LG<small>(125)</small></label>
												</div>
												<div class="input-checkbox">
													<input type="checkbox" id="brand-6">
													<label for="brand-6"><span></span>SONY<small>(755)</small></label>
												</div>
											</c:otherwise>
										</c:choose>
									</div>
								</div>
								<!-- /Brand -->

								<c:if test="${not empty selectedCategoryIds or not empty selectedBrandIds or not empty minPrice or not empty maxPrice}">
									<div class="aside" style="text-align:center;">
										<a href="${clearFilterUrl}" style="color:#D10024;"><i class="fa fa-times"></i> Clear filters</a>
									</div>
								</c:if>
							</form>
						</div>
						<!-- /ASIDE -->

						<!-- STORE -->
						<div id="store" class="col-md-9">
							<!-- store top filter -->
							<div class="store-filter clearfix">
								<div class="store-sort">
									<label>
										Sort By:
										<%-- form="filter-form": select lives outside the form but submits with it --%>
										<select id="sort-select" class="input-select auto-submit" name="sort" form="filter-form">
											<option value="newest" ${sort == 'newest' ? 'selected' : ''}>Newest</option>
											<option value="price_asc" ${sort == 'price_asc' ? 'selected' : ''}>Price: Low to High</option>
											<option value="price_desc" ${sort == 'price_desc' ? 'selected' : ''}>Price: High to Low</option>
											<option value="rating_desc" ${sort == 'rating_desc' ? 'selected' : ''}>Top Rated</option>
										</select>
									</label>
								</div>
							</div>
							<!-- /store top filter -->

							<!-- store products -->
							<div class="row">
								<c:if test="${empty products}">
									<div class="col-md-12 text-center" style="padding:60px 0;">
										<i class="fa fa-search" style="font-size:48px;color:#ccc;"></i>
										<h3 style="margin-top:15px;">No products found</h3>
										<p>
											<c:choose>
												<c:when test="${not empty keyword}">No product matches "${fn:escapeXml(keyword)}".</c:when>
												<c:otherwise>Try changing your filters.</c:otherwise>
											</c:choose>
										</p>
									</div>
								</c:if>

								<c:forEach var="product" items="${products}" varStatus="st">
									<!-- product -->
									<div class="col-md-4 col-xs-6">
										<div class="product">
											<div class="product-img">
												<img src="${pageContext.request.contextPath}/${product.imageUrl}"
													alt="${fn:escapeXml(product.productName)}"
													onerror="this.src='${pageContext.request.contextPath}/assets/img/product01.png'">
											</div>
											<div class="product-body">
												<p class="product-category">${fn:escapeXml(product.categoryName)}</p>
												<h3 class="product-name">
													<a href="${pageContext.request.contextPath}/productDetail?id=${product.productId}">${fn:escapeXml(product.productName)}</a>
												</h3>
												<h4 class="product-price">
													<fmt:formatNumber value="${product.price}" type="number" groupingUsed="true" /> &#8363;
												</h4>
												<div class="product-rating">
													<c:forEach var="i" begin="1" end="5">
														<c:choose>
															<c:when test="${product.rating >= i}"><i class="fa fa-star"></i></c:when>
															<c:when test="${product.rating >= i - 0.5}"><i class="fa fa-star-half-o"></i></c:when>
															<c:otherwise><i class="fa fa-star-o"></i></c:otherwise>
														</c:choose>
													</c:forEach>
												</div>
												<div class="product-btns">
													<c:set var="inWishlist" value="${sessionScope.wishlistProductIds != null && sessionScope.wishlistProductIds.contains(product.productId)}" />
													<button type="button" class="add-to-wishlist ${inWishlist ? 'in-wishlist' : ''}" data-product-id="${product.productId}" title="${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}"><i class="fa ${inWishlist ? 'fa-heart' : 'fa-heart-o'}" ${inWishlist ? 'style="color: #D10024;"' : ''}></i><span class="tooltipp">${inWishlist ? 'Product is in wishlist' : 'add to wishlist'}</span></button>
													<button type="button" class="add-to-compare" data-product-id="${product.productId}"><i class="fa fa-exchange"></i><span class="tooltipp">add to compare</span></button>
													<button class="quick-view" onclick="location.href='${pageContext.request.contextPath}/productDetail?id=${product.productId}'"><i class="fa fa-eye"></i><span class="tooltipp">quick view</span></button>
												</div>
											</div>
											<div class="add-to-cart">
												<form action="${pageContext.request.contextPath}/cart" method="post" style="margin:0;">
													<input type="hidden" name="action" value="add">
													<input type="hidden" name="productId" value="${product.productId}">
													<input type="hidden" name="quantity" value="1">
													<button type="submit" class="add-to-cart-btn"><i class="fa fa-shopping-cart"></i> add to cart</button>
												</form>
											</div>
										</div>
									</div>
									<!-- /product -->
									<c:if test="${st.count % 2 == 0}"><div class="clearfix visible-sm visible-xs"></div></c:if>
									<c:if test="${st.count % 3 == 0}"><div class="clearfix visible-lg visible-md"></div></c:if>
								</c:forEach>
							</div>
							<!-- /store products -->

							<!-- store bottom filter (pagination) -->
							<c:if test="${totalResults > 0}">
								<div class="store-filter clearfix">
									<span class="store-qty">Showing ${fromIndex}-${toIndex} of ${totalResults} products</span>
									<c:if test="${totalPages > 1}">
										<ul class="store-pagination">
											<c:if test="${currentPage > 1}">
												<li><a href="${pageBaseUrl}&page=${currentPage - 1}"><i class="fa fa-angle-left"></i></a></li>
											</c:if>
											<c:forEach var="i" begin="1" end="${totalPages}">
												<c:choose>
													<c:when test="${i == currentPage}"><li class="active">${i}</li></c:when>
													<c:otherwise><li><a href="${pageBaseUrl}&page=${i}">${i}</a></li></c:otherwise>
												</c:choose>
											</c:forEach>
											<c:if test="${currentPage < totalPages}">
												<li><a href="${pageBaseUrl}&page=${currentPage + 1}"><i class="fa fa-angle-right"></i></a></li>
											</c:if>
										</ul>
									</c:if>
								</div>
							</c:if>
							<!-- /store bottom filter -->
						</div>
						<!-- /STORE -->
					</div>
				</div>
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
									<script>document.write(new Date().getFullYear());</script> All rights reserved |
									This
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
			<script src="${pageContext.request.contextPath}/assets/js/jquery.zoom.min.js"></script>
			<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
			<script>window.__contextPath = '${pageContext.request.contextPath}';</script>
			<script src="${pageContext.request.contextPath}/assets/js/searchPage.js"></script>

			<script>
				// Auto-submit filter form when a category/brand checkbox or the sort option changes
				document.querySelectorAll('.auto-submit').forEach(function (el) {
					el.addEventListener('change', function () { document.getElementById('filter-form').submit(); });
				});
			</script>
		</body>

		</html>
