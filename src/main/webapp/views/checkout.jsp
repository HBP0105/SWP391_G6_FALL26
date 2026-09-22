<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
<%
    // Kiểm tra phân quyền: Chỉ cho phép Customer xem trang checkout
    Object customer = session.getAttribute("customer");
    
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return; 
    }
%>
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Checkout - Headphone Store</title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Main Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />
    
    <!-- Custom Checkout Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/checkout.css" />
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
                </ul>
                <ul class="header-links pull-right">
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
                            <a href="${pageContext.request.contextPath}/views/home.jsp" class="logo">
                                <img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="Logo">
                            </a>
                        </div>
                    </div>
                    <!-- /LOGO -->
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
                    <li><a href="${pageContext.request.contextPath}/views/home.jsp">Home</a></li>
                    <li><a href="#">Categories</a></li>
                    <li><a href="${pageContext.request.contextPath}/views/cart.jsp">Cart</a></li>
                    <li class="active"><a href="#">Checkout</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <!-- /NAVIGATION -->

    <!-- CHECKOUT SECTION -->
    <div class="section checkout-section">
        <div class="container">
            <form action="#" method="POST">
                <div class="row">
                    <!-- Billing Details -->
                    <div class="col-md-7">
                        <div class="checkout-details">
                            <h3>Shipping Address</h3>
                            
                            <div class="form-group">
                                <label for="shippingName">Receiver Name</label>
                                <input type="text" class="form-control" id="shippingName" name="shippingName" placeholder="Enter receiver's name" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="shippingPhone">Receiver Phone</label>
                                <input type="tel" class="form-control" id="shippingPhone" name="shippingPhone" placeholder="Enter receiver's phone number" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="shippingEmail">Email Address</label>
                                <input type="email" class="form-control" id="shippingEmail" name="shippingEmail" placeholder="Enter email for notifications" required>
                            </div>

                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="province">Province/City</label>
                                        <input type="text" class="form-control" id="province" name="province" placeholder="Province" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="district">District</label>
                                        <input type="text" class="form-control" id="district" name="district" placeholder="District" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="ward">Ward</label>
                                        <input type="text" class="form-control" id="ward" name="ward" placeholder="Ward" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="addressLine">Address Line</label>
                                <input type="text" class="form-control" id="addressLine" name="addressLine" placeholder="Street name, house number, etc." required>
                            </div>

                            <div class="form-group">
                                <label for="orderNotes">Order Notes (Optional)</label>
                                <textarea class="form-control" id="orderNotes" name="orderNotes" rows="3" placeholder="Any special requests?"></textarea>
                            </div>
                        </div>
                    </div>
                    <!-- /Billing Details -->

                    <!-- Order Summary -->
                    <div class="col-md-5">
                        <div class="order-summary">
                            <h3>Your Order</h3>
                            
                            <div class="order-products">
                                <div class="order-col order-col-header">
                                    <strong>Product</strong>
                                    <strong>Total</strong>
                                </div>
                                <!-- Static Data Example -->
                                <div class="order-col">
                                    <div>1x Headphone XYZ Model 1</div>
                                    <div>$150.00</div>
                                </div>
                                <div class="order-col">
                                    <div>2x Wireless Earbuds Pro</div>
                                    <div>$400.00</div>
                                </div>
                            </div>
                            
                            <div class="order-col">
                                <div><strong>Subtotal</strong></div>
                                <div><strong>$550.00</strong></div>
                            </div>
                            <div class="order-col">
                                <div><strong>Shipping</strong></div>
                                <div><strong>Free</strong></div>
                            </div>

                            <!-- Discount Voucher in Order Summary -->
                            <div class="form-group" style="margin-top: 15px; margin-bottom: 5px;">
                                <div style="display: flex;">
                                    <input type="text" class="form-control" id="voucherCode" name="voucherCode" placeholder="Discount voucher" style="border-radius: 4px 0 0 4px; border: 1px solid #E4E7ED; padding: 10px;">
                                    <button class="primary-btn" type="button" style="border-radius: 0 4px 4px 0; border: none; padding: 0 15px;">Apply</button>
                                </div>
                            </div>
                            
                            <div class="order-col order-total">
                                <div><strong>TOTAL</strong></div>
                                <div><strong class="order-total-price">$550.00</strong></div>
                            </div>

                            <!-- Payment Method -->
                            <div class="payment-method">
                                <h4>Payment Method</h4>
                                <div class="form-group">
                                    <select class="form-control" name="paymentMethod" id="paymentMethod" style="height: 40px; cursor: pointer;">
                                        <option value="COD">Cash on Delivery (COD)</option>
                                        <option value="VNPAY">VNPay</option>
                                        <option value="BANK_TRANSFER">Bank Transfer</option>
                                    </select>
                                </div>
                            </div>
                            <!-- /Payment Method -->

                            <button type="submit" class="primary-btn place-order-btn">Place Order</button>
                        </div>
                    </div>
                    <!-- /Order Summary -->
                </div>
            </form>
        </div>
    </div>
    <!-- /CHECKOUT SECTION -->

    <!-- FOOTER -->
    <footer id="footer">
        <div class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12 text-center">
                        <p class="text-muted">© 2026 Headphone Store. All rights reserved.</p>
                    </div>
                </div>
            </div>
        </div>
    </footer>
    <!-- /FOOTER -->

    <!-- jQuery Plugins -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
