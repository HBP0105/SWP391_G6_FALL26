<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">

	<title>Shopping Cart - Electro</title>

	<!-- Google font -->
	<link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

	<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />
	<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick.css" />
	<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/slick-theme.css" />
	<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/nouislider.min.css" />
	<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">
	<link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />

	<style>
		/* Cart Page Styles */
		.cart-table {
			width: 100%;
			border-collapse: collapse;
		}

		.cart-table thead {
			background-color: #D10024;
			color: #FFF;
		}

		.cart-table thead th {
			padding: 15px;
			text-transform: uppercase;
			font-size: 13px;
			font-weight: 700;
			text-align: center;
		}

		.cart-table tbody td {
			padding: 15px;
			vertical-align: middle;
			text-align: center;
			border-bottom: 1px solid #E4E7ED;
		}

		.cart-table .product-col {
			display: flex;
			align-items: center;
			text-align: left;
		}

		.cart-table .product-col .product-img {
			width: 80px;
			height: 80px;
			margin-right: 15px;
			flex-shrink: 0;
		}

		.cart-table .product-col .product-img img {
			width: 100%;
			height: 100%;
			object-fit: contain;
		}

		.cart-table .product-col .product-name {
			font-size: 14px;
			font-weight: 500;
			color: #333;
		}

		.cart-table .product-col .product-name a {
			color: #333;
		}

		.cart-table .product-col .product-name a:hover {
			color: #D10024;
		}

		.cart-table .product-price {
			font-weight: 700;
			color: #D10024;
			font-size: 16px;
		}

		.cart-table .qty-input {
			display: inline-flex;
			align-items: center;
		}

		.cart-table .qty-input .qty-btn {
			width: 32px;
			height: 32px;
			border: 1px solid #E4E7ED;
			background: #FFF;
			cursor: pointer;
			font-size: 16px;
			font-weight: 700;
			color: #333;
			display: flex;
			align-items: center;
			justify-content: center;
			transition: all 0.2s;
		}

		.cart-table .qty-input .qty-btn:hover {
			background: #D10024;
			color: #FFF;
			border-color: #D10024;
		}

		.cart-table .qty-input input {
			width: 45px;
			height: 32px;
			text-align: center;
			border: 1px solid #E4E7ED;
			border-left: none;
			border-right: none;
			font-size: 14px;
			font-weight: 500;
		}

		.cart-table .product-subtotal {
			font-weight: 700;
			color: #333;
			font-size: 16px;
		}

		.cart-table .delete-btn {
			background: none;
			border: none;
			color: #999;
			font-size: 18px;
			cursor: pointer;
			transition: color 0.2s;
		}

		.cart-table .delete-btn:hover {
			color: #D10024;
		}

		.cart-actions {
			margin-top: 20px;
			display: flex;
			justify-content: space-between;
			align-items: center;
		}

		.cart-actions .continue-shopping {
			display: inline-block;
			padding: 10px 20px;
			background: #1e1f29;
			color: #FFF;
			font-weight: 700;
			text-transform: uppercase;
			font-size: 13px;
			border-radius: 3px;
			transition: background 0.2s;
			text-decoration: none;
		}

		.cart-actions .continue-shopping:hover {
			background: #D10024;
			color: #FFF;
		}

		.cart-actions .update-cart-btn {
			display: inline-block;
			padding: 10px 20px;
			background: #D10024;
			color: #FFF;
			font-weight: 700;
			text-transform: uppercase;
			font-size: 13px;
			border: none;
			border-radius: 3px;
			cursor: pointer;
			transition: opacity 0.2s;
		}

		.cart-actions .update-cart-btn:hover {
			opacity: 0.9;
		}

		/* Order Summary */
		.cart-summary-box {
			background: #f5f5f5;
			padding: 30px;
			border-radius: 3px;
		}

		.cart-summary-box .summary-title {
			font-size: 18px;
			font-weight: 700;
			text-transform: uppercase;
			margin-bottom: 20px;
			padding-bottom: 15px;
			border-bottom: 2px solid #D10024;
		}

		.cart-summary-box .summary-row {
			display: flex;
			justify-content: space-between;
			padding: 10px 0;
			border-bottom: 1px solid #E4E7ED;
			font-size: 14px;
		}

		.cart-summary-box .summary-row.total-row {
			border-bottom: none;
			font-size: 18px;
			font-weight: 700;
			padding-top: 15px;
			color: #D10024;
		}

		.cart-summary-box .checkout-btn {
			display: block;
			width: 100%;
			padding: 15px;
			background: #D10024;
			color: #FFF;
			font-weight: 700;
			text-transform: uppercase;
			font-size: 14px;
			border: none;
			border-radius: 3px;
			cursor: pointer;
			margin-top: 20px;
			text-align: center;
			text-decoration: none;
			transition: opacity 0.2s;
		}

		.cart-summary-box .checkout-btn:hover {
			opacity: 0.9;
			color: #FFF;
		}

		.cart-summary-box .checkout-btn i {
			margin-left: 5px;
		}

		/* Empty Cart */
		.empty-cart {
			text-align: center;
			padding: 60px 0;
		}

		.empty-cart i {
			font-size: 80px;
			color: #E4E7ED;
			margin-bottom: 20px;
		}

		.empty-cart h3 {
			font-size: 24px;
			font-weight: 700;
			margin-bottom: 10px;
			color: #333;
		}

		.empty-cart p {
			color: #999;
			margin-bottom: 20px;
		}

		/* Responsive */
		@media (max-width: 767px) {
			.cart-table thead {
				display: none;
			}

			.cart-table tbody tr {
				display: block;
				margin-bottom: 15px;
				border: 1px solid #E4E7ED;
				padding: 15px;
			}

			.cart-table tbody td {
				display: block;
				text-align: right;
				border-bottom: none;
				padding: 8px 0;
				position: relative;
				padding-left: 50%;
			}

			.cart-table tbody td:before {
				content: attr(data-label);
				position: absolute;
				left: 0;
				font-weight: 700;
				text-transform: uppercase;
				font-size: 12px;
			}

			.cart-table .product-col {
				justify-content: flex-end;
			}
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
						<div class="header-search">
							<form>
								<select class="input-select">
									<option value="0">All Categories</option>
									<option value="1">Category 01</option>
									<option value="1">Category 02</option>
								</select>
								<input class="input" placeholder="Search here">
								<button class="search-btn">Search</button>
							</form>
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
										<a href="#">View Cart</a>
										<a href="#">Checkout <i class="fa fa-arrow-circle-right"></i></a>
									</div>
								</div>
							</div>
							<!-- /Cart -->

							<!-- Menu Toggle -->
							<div class="menu-toggle">
								<a href="#">
									<i class="fa fa-bars"></i>
									<span>Menu</span>
								</a>
							</div>
							<!-- /Menu Toggle -->
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
					<li><a href="#">Home</a></li>
					<li><a href="#">Hot Deals</a></li>
					<li><a href="#">Categories</a></li>
					<li><a href="#">Laptops</a></li>
					<li><a href="#">Smartphones</a></li>
					<li><a href="#">Cameras</a></li>
					<li><a href="#">Accessories</a></li>
				</ul>
				<!-- /NAV -->
			</div>
			<!-- /responsive-nav -->
		</div>
		<!-- /container -->
	</nav>
	<!-- /NAVIGATION -->

	<!-- BREADCRUMB -->
	<div id="breadcrumb" class="section">
		<!-- container -->
		<div class="container">
			<!-- row -->
			<div class="row">
				<div class="col-md-12">
					<h3 class="breadcrumb-header">Shopping Cart</h3>
					<ul class="breadcrumb-tree">
						<li><a href="#">Home</a></li>
						<li class="active">Shopping Cart</li>
					</ul>
				</div>
			</div>
			<!-- /row -->
		</div>
		<!-- /container -->
	</div>
	<!-- /BREADCRUMB -->

	<!-- SECTION -->
	<div class="section">
		<!-- container -->
		<div class="container">
			<!-- row -->
			<div class="row">
				<!-- Cart Items -->
				<div class="col-md-8">
					<table class="cart-table">
						<thead>
							<tr>
								<th>Product</th>
								<th>Price</th>
								<th>Quantity</th>
								<th>Subtotal</th>
								<th></th>
							</tr>
						</thead>
						<tbody>
							<!-- Cart Item 1 -->
							<tr>
								<td data-label="Product">
									<div class="product-col">
										<div class="product-img">
											<img src="${pageContext.request.contextPath}/assets/img/product01.png" alt="">
										</div>
										<div class="product-name">
											<a href="#">Laptop ASUS VivoBook 15</a>
											<p style="font-size: 12px; color: #999; margin-top: 5px;">Category: Laptops</p>
										</div>
									</div>
								</td>
								<td data-label="Price" class="product-price">$980.00</td>
								<td data-label="Quantity">
									<div class="qty-input">
										<button class="qty-btn" onclick="changeQty(this, -1)">-</button>
										<input type="number" value="1" min="1" max="99">
										<button class="qty-btn" onclick="changeQty(this, 1)">+</button>
									</div>
								</td>
								<td data-label="Subtotal" class="product-subtotal">$980.00</td>
								<td data-label="">
									<button class="delete-btn"><i class="fa fa-trash-o"></i></button>
								</td>
							</tr>

							<!-- Cart Item 2 -->
							<tr>
								<td data-label="Product">
									<div class="product-col">
										<div class="product-img">
											<img src="${pageContext.request.contextPath}/assets/img/product02.png" alt="">
										</div>
										<div class="product-name">
											<a href="#">Samsung Galaxy S21 Ultra</a>
											<p style="font-size: 12px; color: #999; margin-top: 5px;">Category: Smartphones</p>
										</div>
									</div>
								</td>
								<td data-label="Price" class="product-price">$850.00</td>
								<td data-label="Quantity">
									<div class="qty-input">
										<button class="qty-btn" onclick="changeQty(this, -1)">-</button>
										<input type="number" value="2" min="1" max="99">
										<button class="qty-btn" onclick="changeQty(this, 1)">+</button>
									</div>
								</td>
								<td data-label="Subtotal" class="product-subtotal">$1,700.00</td>
								<td data-label="">
									<button class="delete-btn"><i class="fa fa-trash-o"></i></button>
								</td>
							</tr>

							<!-- Cart Item 3 -->
							<tr>
								<td data-label="Product">
									<div class="product-col">
										<div class="product-img">
											<img src="${pageContext.request.contextPath}/assets/img/product03.png" alt="">
										</div>
										<div class="product-name">
											<a href="#">Canon EOS 5D Mark IV</a>
											<p style="font-size: 12px; color: #999; margin-top: 5px;">Category: Cameras</p>
										</div>
									</div>
								</td>
								<td data-label="Price" class="product-price">$1,200.00</td>
								<td data-label="Quantity">
									<div class="qty-input">
										<button class="qty-btn" onclick="changeQty(this, -1)">-</button>
										<input type="number" value="1" min="1" max="99">
										<button class="qty-btn" onclick="changeQty(this, 1)">+</button>
									</div>
								</td>
								<td data-label="Subtotal" class="product-subtotal">$1,200.00</td>
								<td data-label="">
									<button class="delete-btn"><i class="fa fa-trash-o"></i></button>
								</td>
							</tr>
						</tbody>
					</table>

					<!-- Cart Actions -->
					<div class="cart-actions">
						<a href="${pageContext.request.contextPath}/" class="continue-shopping">
							<i class="fa fa-arrow-left"></i> Continue Shopping
						</a>
						<button class="update-cart-btn">
							<i class="fa fa-refresh"></i> Update Cart
						</button>
					</div>
				</div>
				<!-- /Cart Items -->

				<!-- Order Summary -->
				<div class="col-md-4">
					<div class="cart-summary-box">
						<h3 class="summary-title">Cart Summary</h3>
						<div class="summary-row">
							<span>Subtotal</span>
							<span><strong>$3,880.00</strong></span>
						</div>
						<div class="summary-row">
							<span>Shipping</span>
							<span><strong>FREE</strong></span>
						</div>
						<div class="summary-row total-row">
							<span>TOTAL</span>
							<span>$3,880.00</span>
						</div>
						<a href="${pageContext.request.contextPath}/views/checkOut.jsp" class="checkout-btn">
							Proceed to Checkout <i class="fa fa-arrow-circle-right"></i>
						</a>
					</div>
				</div>
				<!-- /Order Summary -->
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

	<script>
		// Change quantity
		function changeQty(btn, delta) {
			var input = btn.parentElement.querySelector('input');
			var newVal = parseInt(input.value) + delta;
			if (newVal >= 1 && newVal <= 99) {
				input.value = newVal;
			}
		}
	</script>

</body>

</html>
