<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- NEWSLETTER -->
<div id="newsletter" class="section">
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
                    <div class="footer" id="about-us">
                        <h3 class="footer-title">About Us</h3>
                        <p>Specialized in premium headphones, audiophile gear, and wireless earbuds with guaranteed authenticity.</p>
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
                            <li><a href="${pageContext.request.contextPath}/productList?category=2">Wireless Earbuds</a></li>
                            <li><a href="${pageContext.request.contextPath}/productList?q=noise+cancelling">Noise Cancelling</a></li>
                            <li><a href="${pageContext.request.contextPath}/productList?q=gaming">Gaming Headsets</a></li>
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
                            <li><a href="${pageContext.request.contextPath}/compare">Compare Products</a></li>
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
                        Copyright &copy;
                        <script>document.write(new Date().getFullYear());</script> All rights reserved | Headphone Shop
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
