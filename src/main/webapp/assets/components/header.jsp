<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.swp391.model.Customer" %>
<%@ page import="com.swp391.model.Staff" %>
<script>
    window.__contextPath = '${pageContext.request.contextPath}';
</script>
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
                <%
                    Object currentUser = session.getAttribute("customer");
                    if (currentUser == null) {
                        currentUser = session.getAttribute("user");
                    }
                    if (currentUser == null) {
                %>
                <!-- Chua dang nhap -->
                <li>
                    <a href="${pageContext.request.contextPath}/login">
                        <i class="fa fa-user-o"></i> My Account
                    </a>
                </li>
                <%
                    } else {
                        String displayName = "";
                        if (currentUser instanceof Customer) {
                            displayName = ((Customer) currentUser).getFullName();
                        } else if (currentUser instanceof Staff) {
                            displayName = ((Staff) currentUser).getFullName();
                        }
                %>
                <!-- Da dang nhap -->
                <li>
                    <a href="${pageContext.request.contextPath}/profile">
                        <i class="fa fa-user"></i> <%= displayName %>
                    </a>
                </li>
                <%
                    }
                %>
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
                            <input id="search-input" class="input" name="q" placeholder="Search here" type="text"
                                   value="${param.q}">
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
                        <!-- Wishlist -->
                        <div>
                            <a href="${pageContext.request.contextPath}/wishlist">
                                <i class="fa fa-heart-o"></i>
                                <span>Your Wishlist</span>
                                <div class="qty" id="headerWishlistQty">${sessionScope.wishlistCount != null ? sessionScope.wishlistCount : 0}</div>
                            </a>
                        </div>
                        <!-- /Wishlist -->

                        <!-- Cart -->
                        <div class="dropdown">
                            <a class="dropdown-toggle" data-toggle="dropdown" aria-expanded="true">
                                <i class="fa fa-shopping-cart"></i>
                                <span>Your Cart</span>
                                <div class="qty">0</div>
                            </a>
                            <div class="cart-dropdown">
                                <div class="cart-list">
                                </div>
                                <div class="cart-summary">
                                    <small>0 Item(s) selected</small>
                                    <h5>SUBTOTAL: $0.00</h5>
                                </div>
                                <div class="cart-btns">
                                    <a href="${pageContext.request.contextPath}/cart">View Cart</a>
                                    <a href="${pageContext.request.contextPath}/checkout">Checkout <i class="fa fa-arrow-circle-right"></i></a>
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
                <li class="${activeNav == 'home' ? 'active' : ''}"><a href="${pageContext.request.contextPath}/home">Home</a></li>
                <li><a href="${pageContext.request.contextPath}/home#hot-deal">Hot Deals</a></li>
                <li><a href="${pageContext.request.contextPath}/search?category=1">Headphones</a></li>
                <li><a href="${pageContext.request.contextPath}/search?category=2">Earbuds</a></li>
                <li class="${activeNav == 'compare' ? 'active' : ''}"><a href="${pageContext.request.contextPath}/compare"><i class="fa fa-exchange" style="margin-right: 4px;"></i> Compare</a></li>
            </ul>
            <!-- /NAV -->
        </div>
        <!-- /responsive-nav -->
    </div>
    <!-- /container -->
</nav>
<!-- /NAVIGATION -->

<%-- Khởi tạo danh sách wishlist trong session từ database nếu khách hàng đã đăng nhập nhưng chưa nạp session --%>
<c:if test="${not empty sessionScope.customer && sessionScope.wishlistProductIds == null}">
    <%
        com.swp391.model.Customer curCust = (com.swp391.model.Customer) session.getAttribute("customer");
        if (curCust != null && session.getAttribute("wishlistProductIds") == null) {
            com.swp391.dao.FavoriteDAO fDao = new com.swp391.dao.FavoriteDAO();
            java.util.List<com.swp391.model.WishlistItemDTO> wItems = fDao.getFavoritesByCustomerId(curCust.getCustomerID());
            java.util.Set<Integer> pIdSet = new java.util.LinkedHashSet<>();
            if (wItems != null) {
                for (com.swp391.model.WishlistItemDTO itm : wItems) {
                    if (itm != null) pIdSet.add(itm.getProductId());
                }
            } else {
                wItems = new java.util.ArrayList<>();
            }
            session.setAttribute("wishlistItems", wItems);
            session.setAttribute("wishlistProductIds", pIdSet);
            session.setAttribute("wishlistCount", wItems.size());
            session.setAttribute("wishlistModified", false);
        }
    %>
</c:if>

<!-- STYLE NÚT KHI SẢN PHẨM ĐÃ CÓ TRONG WISHLIST -->
<style>
    .add-to-wishlist.in-wishlist {
        color: #D10024 !important;
    }
    .add-to-wishlist.in-wishlist i {
        color: #D10024 !important;
    }
    .product .product-body .product-btns > button.add-to-wishlist.in-wishlist {
        background-color: #FFF0F2 !important;
        border-color: #D10024 !important;
        color: #D10024 !important;
    }
    .product .product-body .product-btns > button.add-to-wishlist.in-wishlist:hover {
        background-color: #FFE5E8 !important;
    }
    .product .product-body .product-btns > button.add-to-wishlist.in-wishlist .tooltipp {
        width: auto !important;
        min-width: 160px !important;
        white-space: nowrap !important;
        padding: 10px !important;
        font-size: 12px !important;
        line-height: 10px !important;
        background: #1e1f29 !important;
        color: #FFFFFF !important;
        text-transform: uppercase !important;
        font-weight: inherit !important;
        letter-spacing: normal !important;
        border-radius: 0 !important;
    }
    .product-details .product-btns li a.add-to-wishlist.in-wishlist {
        color: #D10024 !important;
        font-weight: 600;
    }
</style>

<!-- GLOBAL WISHLIST TOAST & SCRIPT -->
<div id="siteWishlistToast" style="display:none;position:fixed;bottom:24px;right:24px;background:#1e1f29;color:#fff;padding:14px 20px;border-radius:4px;box-shadow:0 6px 20px rgba(0,0,0,0.35);z-index:999999;font-size:13px;align-items:center;gap:10px;max-width:420px;line-height:1.4;">
    <i id="siteWishlistToastIcon" class="fa fa-heart" style="font-size:16px;"></i>
    <span id="siteWishlistToastContent"></span>
</div>

<script>
    (function() {
        window.__contextPath = '${pageContext.request.contextPath}';

        // Khởi tạo Set các ID sản phẩm đã có trong wishlist từ Session
        window.__wishlistProductIds = new Set([
            <c:if test="${not empty sessionScope.wishlistProductIds}">
                <c:forEach var="pid" items="${sessionScope.wishlistProductIds}" varStatus="loop">
                    ${pid}${not loop.last ? ',' : ''}
                </c:forEach>
            </c:if>
        ]);

        function showSiteWishlistToast(msg, isError, loginUrl) {
            var toast = document.getElementById('siteWishlistToast');
            if (!toast) return;
            var icon = document.getElementById('siteWishlistToastIcon');
            var content = document.getElementById('siteWishlistToastContent');

            if (isError) {
                icon.className = 'fa fa-exclamation-circle';
                icon.style.color = '#D10024';
            } else {
                icon.className = 'fa fa-check-circle';
                icon.style.color = '#4CAF50';
            }

            if (loginUrl) {
                content.innerHTML = msg + ' <a href="' + loginUrl + '" style="color:#FFD54F;text-decoration:underline;margin-left:6px;font-weight:700;">Đăng nhập ngay</a>';
            } else {
                content.innerText = msg;
            }

            toast.style.display = 'flex';
            if (window.__siteToastTimeout) clearTimeout(window.__siteToastTimeout);
            window.__siteToastTimeout = setTimeout(function() {
                toast.style.display = 'none';
            }, loginUrl ? 5000 : 3000);
        }

        window.showSiteWishlistToast = showSiteWishlistToast;

        function markProductInWishlist(pid) {
            var buttons = document.querySelectorAll('.add-to-wishlist[data-product-id="' + pid + '"]');
            buttons.forEach(function(b) {
                b.classList.add('in-wishlist');
                b.setAttribute('title', 'Product is in wishlist');
                var heartIcon = b.querySelector('i');
                if (heartIcon) {
                    heartIcon.className = 'fa fa-heart';
                    heartIcon.style.color = '#D10024';
                }
                var tooltipp = b.querySelector('.tooltipp');
                if (tooltipp) {
                    tooltipp.innerText = 'Product is in wishlist';
                }
                var textSpan = b.querySelector('span:not(.tooltipp)');
                if (textSpan) {
                    textSpan.innerText = 'Product is in wishlist';
                }
            });
        }
        window.markProductInWishlist = markProductInWishlist;

        function syncAllWishlistButtons() {
            if (window.__wishlistProductIds && window.__wishlistProductIds.size > 0) {
                window.__wishlistProductIds.forEach(function(pid) {
                    markProductInWishlist(pid);
                });
            }
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', syncAllWishlistButtons);
        } else {
            syncAllWishlistButtons();
        }

        document.addEventListener('click', function(e) {
            var btn = e.target.closest('.add-to-wishlist');
            if (!btn) return;

            e.preventDefault();
            e.stopPropagation();

            var productId = btn.getAttribute('data-product-id');
            if (!productId && btn.dataset) {
                productId = btn.dataset.productId;
            }

            if (!productId) {
                console.error('[WISHLIST FRONTEND ERROR] Không tìm thấy data-product-id trên phần tử:', btn);
                return;
            }

            var pidInt = parseInt(productId, 10);

            // Kiểm tra: nếu sản phẩm đã có trong wishlist thì không thể thêm lần nữa
            if (btn.classList.contains('in-wishlist') || (window.__wishlistProductIds && window.__wishlistProductIds.has(pidInt))) {
                showSiteWishlistToast('Sản phẩm đã có trong wishlist!', false);
                return;
            }

            var contextPath = window.__contextPath || '';
            var targetUrl = (contextPath ? contextPath : '') + '/wishlist';

            var formData = new URLSearchParams();
            formData.append('action', 'add');
            formData.append('productId', productId);
            formData.append('format', 'json');

            fetch(targetUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: formData.toString()
            })
            .then(function(res) {
                if (!res.ok) {
                    throw new Error('HTTP ' + res.status + ' (' + res.statusText + ')');
                }
                return res.json();
            })
            .then(function(data) {
                if (data.requireLogin) {
                    var loginUrl = data.loginUrl || ((contextPath ? contextPath : '') + '/authen/login.jsp');
                    showSiteWishlistToast(data.message || 'Vui lòng đăng nhập để thêm sản phẩm vào danh sách yêu thích!', true, loginUrl);
                    return;
                }

                if (data.alreadyInWishlist) {
                    if (window.__wishlistProductIds) {
                        window.__wishlistProductIds.add(pidInt);
                    }
                    markProductInWishlist(pidInt);
                    showSiteWishlistToast(data.message || 'Sản phẩm đã có trong wishlist!', false);
                    return;
                }

                if (data.success) {
                    var badge = document.getElementById('headerWishlistQty');
                    if (badge) badge.innerText = data.count;

                    if (window.__wishlistProductIds) {
                        window.__wishlistProductIds.add(pidInt);
                    }
                    markProductInWishlist(pidInt);

                    showSiteWishlistToast(data.message || 'Đã thêm vào danh sách yêu thích!', false);
                } else {
                    showSiteWishlistToast(data.message || 'Có lỗi xảy ra khi thêm vào danh sách yêu thích.', true);
                }
            })
            .catch(function(err) {
                console.error('[WISHLIST FRONTEND AJAX ERROR]:', err);
                showSiteWishlistToast('Không thể kết nối máy chủ: ' + err.message, true);
            });
        }, true);
    })();
</script>
