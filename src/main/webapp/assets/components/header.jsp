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
                <li class="${activeNav == 'search' && selectedCategoryIds != null && selectedCategoryIds.contains(1) ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/productList?category=1">Headphones</a>
                </li>
                <li class="${activeNav == 'search' && selectedCategoryIds != null && selectedCategoryIds.contains(2) ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/productList?category=2">Earbuds</a>
                </li>
                <li class="${activeNav == 'compare' ? 'active' : ''}"><a href="${pageContext.request.contextPath}/compare">Compare</a></li>
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

    /* ===== GLOBAL HEADER SEARCH AUTOCOMPLETE ===== */
    .search-suggestion-item {
        display: flex;
        align-items: center;
        padding: 8px 12px;
        cursor: pointer;
        border-bottom: 1px solid #f0f0f0;
        text-decoration: none !important;
        color: #333;
        transition: background 0.15s ease;
    }
    .search-suggestion-item:last-child {
        border-bottom: none;
    }
    .search-suggestion-item:hover,
    .search-suggestion-item.active {
        background-color: #f5f5f5;
    }
    .suggestion-img {
        width: 40px;
        height: 40px;
        object-fit: cover;
        border-radius: 4px;
        margin-right: 10px;
        flex-shrink: 0;
        border: 1px solid #eee;
    }
    .suggestion-info {
        flex: 1;
        overflow: hidden;
        text-align: left;
    }
    .suggestion-name {
        font-size: 13px;
        font-weight: 600;
        color: #333;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .suggestion-meta {
        font-size: 11px;
        color: #999;
        margin-top: 2px;
    }
    .suggestion-price {
        font-size: 13px;
        font-weight: 700;
        color: #D10024;
        white-space: nowrap;
        margin-left: 8px;
    }
    .suggestion-no-result {
        padding: 12px;
        text-align: center;
        color: #999;
        font-size: 13px;
    }
</style>

<script>
    (function () {
        var searchInput = document.getElementById('search-input');
        var suggestionsBox = document.getElementById('search-suggestions');
        var searchForm = document.getElementById('search-form');
        var contextPath = window.__contextPath || '';
        var debounceTimer = null;
        var activeIndex = -1;

        if (!searchInput || !suggestionsBox) return;
        if (searchInput.getAttribute('data-suggest-bound') === '1') return;
        searchInput.setAttribute('data-suggest-bound', '1');

        function debounce(fn, delay) {
            return function () {
                var args = arguments;
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(function () { fn.apply(null, args); }, delay);
            };
        }

        function formatPrice(price) {
            return parseFloat(price).toLocaleString('vi-VN') + ' \u20ab';
        }

        function escapeHtml(text) {
            var div = document.createElement('div');
            div.appendChild(document.createTextNode(text || ''));
            return div.innerHTML;
        }

        function renderSuggestions(data) {
            suggestionsBox.innerHTML = '';
            activeIndex = -1;

            if (!data || data.length === 0) {
                suggestionsBox.innerHTML = '<div class="suggestion-no-result">No products found</div>';
                suggestionsBox.style.display = 'block';
                return;
            }

            data.forEach(function (item, idx) {
                var a = document.createElement('a');
                a.className = 'search-suggestion-item';
                a.href = contextPath + '/productDetail?id=' + item.productID;
                a.setAttribute('data-index', idx);

                var imgUrl = item.imageUrl || 'assets/img/product01.png';
                var imgSrc = imgUrl.indexOf('http') === 0
                    ? imgUrl
                    : contextPath + '/' + imgUrl;

                a.innerHTML =
                    '<img class="suggestion-img" src="' + imgSrc + '" alt="' + escapeHtml(item.productName) + '" onerror="this.src=\'' + contextPath + '/assets/img/product01.png\'">' +
                    '<div class="suggestion-info">' +
                        '<div class="suggestion-name">' + escapeHtml(item.productName) + '</div>' +
                        '<div class="suggestion-meta">' + escapeHtml(item.categoryName || '') + '</div>' +
                    '</div>' +
                    '<span class="suggestion-price">' + formatPrice(item.price) + '</span>';

                suggestionsBox.appendChild(a);
            });

            suggestionsBox.style.display = 'block';
        }

        function hideSuggestions() {
            suggestionsBox.style.display = 'none';
            activeIndex = -1;
        }

        function fetchSuggestions(keyword) {
            if (keyword.length < 3) {
                hideSuggestions();
                return;
            }
            var xhr = new XMLHttpRequest();
            xhr.open('GET', contextPath + '/searchSuggest?q=' + encodeURIComponent(keyword), true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        renderSuggestions(JSON.parse(xhr.responseText));
                    } catch (e) {
                        hideSuggestions();
                    }
                }
            };
            xhr.send();
        }

        var debouncedFetch = debounce(fetchSuggestions, 300);

        searchInput.addEventListener('keydown', function (e) {
            var items = suggestionsBox.querySelectorAll('.search-suggestion-item');
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                activeIndex = Math.min(activeIndex + 1, items.length - 1);
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                activeIndex = Math.max(activeIndex - 1, -1);
            } else if (e.key === 'Escape') {
                hideSuggestions();
                return;
            }
            items.forEach(function (item, i) {
                item.classList.toggle('active', i === activeIndex);
            });
        });

        searchInput.addEventListener('input', function () {
            debouncedFetch(this.value.trim());
        });

        document.addEventListener('click', function (e) {
            if (!searchInput.contains(e.target) && !suggestionsBox.contains(e.target)) {
                hideSuggestions();
            }
        });

        searchInput.addEventListener('focus', function () {
            if (this.value.trim().length >= 3 && suggestionsBox.innerHTML !== '') {
                suggestionsBox.style.display = 'block';
            }
        });

        if (searchForm) {
            searchForm.addEventListener('submit', function () {
                hideSuggestions();
            });
        }
    })();
</script>

<!-- GLOBAL WISHLIST TOAST & SCRIPT -->
<div id="siteWishlistToast" style="display:none;position:fixed;bottom:24px;right:24px;background:#1e1f29;color:#fff;padding:14px 20px;border-radius:4px;box-shadow:0 6px 20px rgba(0,0,0,0.35);z-index:999999;font-size:13px;align-items:center;gap:10px;max-width:420px;line-height:1.4;">
    <i id="siteWishlistToastIcon" class="fa fa-heart" style="font-size:16px;"></i>
    <span id="siteWishlistToastContent"></span>
</div>

<script>
    (function () {
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
            if (!toast)
                return;
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
            if (window.__siteToastTimeout)
                clearTimeout(window.__siteToastTimeout);
            window.__siteToastTimeout = setTimeout(function () {
                toast.style.display = 'none';
            }, loginUrl ? 5000 : 3000);
        }

        window.showSiteWishlistToast = showSiteWishlistToast;

        function markProductInWishlist(pid) {
            var buttons = document.querySelectorAll('.add-to-wishlist[data-product-id="' + pid + '"]');
            buttons.forEach(function (b) {
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
                window.__wishlistProductIds.forEach(function (pid) {
                    markProductInWishlist(pid);
                });
            }
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', syncAllWishlistButtons);
        } else {
            syncAllWishlistButtons();
        }

        document.addEventListener('click', function (e) {
            var btn = e.target.closest('.add-to-wishlist');
            if (!btn)
                return;

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
                    .then(function (res) {
                        if (!res.ok) {
                            throw new Error('HTTP ' + res.status + ' (' + res.statusText + ')');
                        }
                        return res.json();
                    })
                    .then(function (data) {
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
                            if (badge)
                                badge.innerText = data.count;

                            if (window.__wishlistProductIds) {
                                window.__wishlistProductIds.add(pidInt);
                            }
                            markProductInWishlist(pidInt);

                            showSiteWishlistToast(data.message || 'Đã thêm vào danh sách yêu thích!', false);
                        } else {
                            showSiteWishlistToast(data.message || 'Có lỗi xảy ra khi thêm vào danh sách yêu thích.', true);
                        }
                    })
                    .catch(function (err) {
                        console.error('[WISHLIST FRONTEND AJAX ERROR]:', err);
                        showSiteWishlistToast('Không thể kết nối máy chủ: ' + err.message, true);
                    });
        }, true);
    })();
</script>
