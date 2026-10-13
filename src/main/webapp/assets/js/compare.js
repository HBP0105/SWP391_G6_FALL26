/**
 * Product Comparison Page Interactive Script
 */
(function() {
    var contextPath = window.__contextPath || '';
    var currentProductA = window.__initialProductA || null;
    var currentProductB = window.__initialProductB || null;

    // Format currency VND
    function formatVND(amount) {
        if (amount == null || isNaN(amount)) return '0 ₫';
        return Number(amount).toLocaleString('vi-VN') + ' ₫';
    }

    // Update URL query parameters without reloading
    function updateUrl() {
        var params = new URLSearchParams(window.location.search);
        if (currentProductA && currentProductA.productId) {
            params.set('idA', currentProductA.productId);
        } else {
            params.delete('idA');
        }

        if (currentProductB && currentProductB.productId) {
            params.set('idB', currentProductB.productId);
        } else {
            params.delete('idB');
        }

        var newUrl = window.location.pathname + (params.toString() ? '?' + params.toString() : '');
        window.history.replaceState({}, '', newUrl);
    }

    // Render Product into Slot A or Slot B
    function renderProductSlot(slot, product) {
        var container = document.getElementById(slot === 'A' ? 'slotProductA' : 'slotProductB');
        if (!container) return;

        if (!product) {
            // Render Empty State
            container.innerHTML = 
                '<div class="compare-product-box compare-empty-slot" onclick="focusSearch()">' +
                    '<span class="compare-slot-badge ' + (slot === 'A' ? 'slot-a' : 'slot-b') + '">Sản phẩm ' + slot + '</span>' +
                    '<div class="compare-empty-icon"><i class="fa fa-plus-circle"></i></div>' +
                    '<div class="compare-empty-text">Chưa chọn Sản phẩm ' + slot + '</div>' +
                    '<div class="compare-empty-subtext">Chọn tai nghe từ danh sách bên dưới để so sánh</div>' +
                '</div>';
        } else {
            // Render Active Product
            var imgSrc = product.imageUrl ? (product.imageUrl.startsWith('http') || product.imageUrl.startsWith('/') ? product.imageUrl : contextPath + '/' + product.imageUrl) : contextPath + '/assets/img/product01.png';
            container.innerHTML = 
                '<div class="compare-product-box">' +
                    '<span class="compare-slot-badge ' + (slot === 'A' ? 'slot-a' : 'slot-b') + '">Sản phẩm ' + slot + '</span>' +
                    '<button type="button" class="compare-btn-remove-slot" title="Bỏ chọn" onclick="removeSlot(\'' + slot + '\')">' +
                        '<i class="fa fa-times"></i>' +
                    '</button>' +
                    '<div class="compare-img-wrap">' +
                        '<img src="' + imgSrc + '" alt="' + escapeHtml(product.productName) + '" onerror="this.src=\'' + contextPath + '/assets/img/product01.png\'"/>' +
                    '</div>' +
                    '<div class="compare-meta-wrap">' +
                        '<div class="compare-prod-brand">' + escapeHtml(product.brandName || 'Authentic') + '</div>' +
                        '<h4 class="compare-prod-name">' +
                            '<a href="' + contextPath + '/productDetail?id=' + product.productId + '">' + escapeHtml(product.productName) + '</a>' +
                        '</h4>' +
                        '<div class="compare-prod-price">' + formatVND(product.price) + '</div>' +
                        '<form action="' + contextPath + '/cart" method="POST" style="margin:0;">' +
                            '<input type="hidden" name="action" value="add"/>' +
                            '<input type="hidden" name="productId" value="' + product.productId + '"/>' +
                            '<input type="hidden" name="quantity" value="1"/>' +
                            '<button type="submit" class="compare-btn-cart"><i class="fa fa-shopping-cart"></i> Thêm giỏ hàng</button>' +
                        '</form>' +
                    '</div>' +
                '</div>';
        }
    }

    // Render Specs Comparison List (Right Column)
    function renderSpecsComparison() {
        var listContainer = document.getElementById('compareSpecsList');
        if (!listContainer) return;

        var a = currentProductA;
        var b = currentProductB;

        var specs = [
            {
                label: 'Giá bán',
                valA: a ? formatVND(a.price) : '—',
                valB: b ? formatVND(b.price) : '—',
                betterA: a && b && (Number(a.price) < Number(b.price)),
                betterB: a && b && (Number(b.price) < Number(a.price))
            },
            {
                label: 'Danh mục',
                valA: a && a.categoryName ? a.categoryName : '—',
                valB: b && b.categoryName ? b.categoryName : '—'
            },
            {
                label: 'Thương hiệu',
                valA: a && a.brandName ? a.brandName : '—',
                valB: b && b.brandName ? b.brandName : '—'
            },
            {
                label: 'Kiểu kết nối',
                valA: a && a.connectionType ? a.connectionType : '—',
                valB: b && b.connectionType ? b.connectionType : '—'
            },
            {
                label: 'Chống ồn (ANC)',
                valA: a ? (a.noiseCancelling ? '<span class="spec-better">Có (ANC)</span>' : 'Không') : '—',
                valB: b ? (b.noiseCancelling ? '<span class="spec-better">Có (ANC)</span>' : 'Không') : '—',
                betterA: a && a.noiseCancelling && b && !b.noiseCancelling,
                betterB: b && b.noiseCancelling && a && !a.noiseCancelling
            },
            {
                label: 'Thời lượng pin',
                valA: a && a.batteryLife ? a.batteryLife + ' giờ' : '—',
                valB: b && b.batteryLife ? b.batteryLife + ' giờ' : '—',
                betterA: a && b && (Number(a.batteryLife) > Number(b.batteryLife)),
                betterB: a && b && (Number(b.batteryLife) > Number(a.batteryLife))
            },
            {
                label: 'Microphone',
                valA: a ? (a.microphone ? 'Tích hợp' : 'Không') : '—',
                valB: b ? (b.microphone ? 'Tích hợp' : 'Không') : '—'
            },
            {
                label: 'Màng loa (Driver)',
                valA: a && a.driverSize ? a.driverSize + ' mm' : '—',
                valB: b && b.driverSize ? b.driverSize + ' mm' : '—'
            },
            {
                label: 'Kháng nước',
                valA: a && a.waterResistance ? a.waterResistance : 'Không',
                valB: b && b.waterResistance ? b.waterResistance : 'Không'
            },
            {
                label: 'Trọng lượng',
                valA: a && a.weight ? a.weight + ' g' : '—',
                valB: b && b.weight ? b.weight + ' g' : '—'
            },
            {
                label: 'Đánh giá sao',
                valA: a && a.rating ? a.rating + ' ★ (' + (a.reviewCount || 0) + ')' : 'Chưa có',
                valB: b && b.rating ? b.rating + ' ★ (' + (b.reviewCount || 0) + ')' : 'Chưa có',
                betterA: a && b && (Number(a.rating) > Number(b.rating)),
                betterB: a && b && (Number(b.rating) > Number(a.rating))
            },
            {
                label: 'Tình trạng kho',
                valA: a ? (a.stockQuantity > 0 ? '<span class="spec-better">Còn hàng</span>' : '<span style="color:#C62828;">Hết hàng</span>') : '—',
                valB: b ? (b.stockQuantity > 0 ? '<span class="spec-better">Còn hàng</span>' : '<span style="color:#C62828;">Hết hàng</span>') : '—'
            }
        ];

        var html = '';
        specs.forEach(function(s) {
            html += '<li class="compare-spec-item">';
            html += '<span class="compare-spec-label">' + s.label + '</span>';
            html += '<span class="compare-spec-val-a ' + (s.betterA ? 'spec-better' : '') + '">' + s.valA + '</span>';
            html += '<span class="compare-spec-vs">vs</span>';
            html += '<span class="compare-spec-val-b ' + (s.betterB ? 'spec-better' : '') + '">' + s.valB + '</span>';
            html += '</li>';
        });

        listContainer.innerHTML = html;
        updateSearchGridBadges();
    }

    // Highlight items in the search grid that are currently selected as A or B
    function updateSearchGridBadges() {
        var items = document.querySelectorAll('.compare-grid-item');
        var idA = currentProductA ? currentProductA.productId : 0;
        var idB = currentProductB ? currentProductB.productId : 0;

        items.forEach(function(el) {
            var pid = parseInt(el.getAttribute('data-product-id'), 10);
            el.classList.remove('selected-as-a', 'selected-as-b');
            var existingBadge = el.querySelector('.selected-badge-flag');
            if (existingBadge) existingBadge.remove();

            if (pid === idA) {
                el.classList.add('selected-as-a');
                var bA = document.createElement('span');
                bA.className = 'selected-badge-flag flag-a';
                bA.innerText = 'Đang là SP A';
                el.appendChild(bA);
            } else if (pid === idB) {
                el.classList.add('selected-as-b');
                var bB = document.createElement('span');
                bB.className = 'selected-badge-flag flag-b';
                bB.innerText = 'Đang là SP B';
                el.appendChild(bB);
            }
        });
    }

    // Swap Slot A and Slot B
    window.swapProducts = function() {
        var temp = currentProductA;
        currentProductA = currentProductB;
        currentProductB = temp;

        renderProductSlot('A', currentProductA);
        renderProductSlot('B', currentProductB);
        renderSpecsComparison();
        updateUrl();

        if (typeof showSiteWishlistToast === 'function') {
            showSiteWishlistToast('Đã đổi vị trí giữa Sản phẩm A và B!', false);
        }
    };

    // Remove product from a slot
    window.removeSlot = function(slot) {
        if (slot === 'A') {
            currentProductA = null;
            renderProductSlot('A', null);
        } else {
            currentProductB = null;
            renderProductSlot('B', null);
        }
        renderSpecsComparison();
        updateUrl();
    };

    // Select Product from Search Results into Slot A or Slot B
    window.selectProductForSlot = function(slot, productId) {
        if (!productId) return;

        fetch(contextPath + '/compare?action=get_product_ajax&productId=' + productId)
            .then(function(res) { return res.json(); })
            .then(function(data) {
                if (data.success && data.product) {
                    if (slot === 'A') {
                        currentProductA = data.product;
                        renderProductSlot('A', currentProductA);
                    } else {
                        currentProductB = data.product;
                        renderProductSlot('B', currentProductB);
                    }
                    renderSpecsComparison();
                    updateUrl();

                    if (typeof showSiteWishlistToast === 'function') {
                        showSiteWishlistToast('Đã chọn ' + data.product.productName + ' vào Sản phẩm ' + slot + '!', false);
                    }

                    // Smooth scroll up to compare section
                    var topSection = document.getElementById('compareTopRow');
                    if (topSection) {
                        topSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                }
            })
            .catch(function(err) {
                console.error('Error fetching product for comparison:', err);
            });
    };

    // Live search & filter with pagination
    var searchTimeout = null;
    var currentSearchPage = window.__initialCurrentPage || 1;

    window.goToComparePage = function(pageNum) {
        triggerLiveSearch(pageNum, true);
    };

    function triggerLiveSearch(page, scrollOnComplete) {
        if (searchTimeout) clearTimeout(searchTimeout);
        var delay = (typeof page === 'number') ? 0 : 250;

        searchTimeout = setTimeout(function() {
            var catId = document.getElementById('compareCategorySelect') ? document.getElementById('compareCategorySelect').value : 0;
            var brandId = document.getElementById('compareBrandSelect') ? document.getElementById('compareBrandSelect').value : 0;
            var keyword = document.getElementById('compareKeywordInput') ? document.getElementById('compareKeywordInput').value.trim() : '';

            currentSearchPage = (typeof page === 'number') ? page : 1;

            var url = contextPath + '/compare?action=search_ajax'
                + '&category=' + encodeURIComponent(catId)
                + '&brand=' + encodeURIComponent(brandId)
                + '&keyword=' + encodeURIComponent(keyword)
                + '&page=' + encodeURIComponent(currentSearchPage);

            var gridContainer = document.getElementById('compareGridContainer');
            var countContainer = document.getElementById('compareResultsCount');
            if (gridContainer) {
                gridContainer.style.opacity = '0.4';
            }

            fetch(url)
                .then(function(res) { return res.json(); })
                .then(function(data) {
                    if (gridContainer) {
                        gridContainer.style.opacity = '1';
                        renderSearchResults(data.products || []);
                    }
                    if (countContainer) {
                        countContainer.innerText = '(' + (data.totalCount || 0) + ' sản phẩm)';
                    }
                    renderPagination(data);
                    updateSearchGridBadges();

                    if (scrollOnComplete) {
                        var target = document.querySelector('.compare-results-header') || gridContainer;
                        if (target) {
                            target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                        }
                    }
                })
                .catch(function(err) {
                    if (gridContainer) gridContainer.style.opacity = '1';
                    console.error('Search error:', err);
                });
        }, delay);
    }

    // Render Pagination Bar
    function renderPagination(data) {
        var container = document.getElementById('comparePaginationContainer');
        if (!container) return;

        var totalCount = data.totalCount || 0;
        var totalPages = data.totalPages || 1;
        var curPage = data.currentPage || 1;
        var fromIndex = data.fromIndex || 0;
        var toIndex = data.toIndex || 0;

        if (totalCount <= 0) {
            container.innerHTML = '';
            return;
        }

        var html = '<div class="store-filter clearfix">';
        html += '<span class="store-qty">';
        html += 'Hiển thị <strong>' + fromIndex + '-' + toIndex + '</strong> trên <strong>' + totalCount + '</strong> sản phẩm';
        html += '</span>';

        if (totalPages > 1) {
            html += '<ul class="store-pagination">';
            if (curPage > 1) {
                html += '<li><a href="javascript:void(0)" onclick="goToComparePage(' + (curPage - 1) + ')"><i class="fa fa-angle-left"></i></a></li>';
            }
            for (var i = 1; i <= totalPages; i++) {
                if (i === curPage) {
                    html += '<li class="active"><span>' + i + '</span></li>';
                } else {
                    html += '<li><a href="javascript:void(0)" onclick="goToComparePage(' + i + ')">' + i + '</a></li>';
                }
            }
            if (curPage < totalPages) {
                html += '<li><a href="javascript:void(0)" onclick="goToComparePage(' + (curPage + 1) + ')"><i class="fa fa-angle-right"></i></a></li>';
            }
            html += '</ul>';
        }
        html += '</div>';

        container.innerHTML = html;
    }

    // Render Search Results into grid
    function renderSearchResults(products) {
        var grid = document.getElementById('compareGridContainer');
        if (!grid) return;

        if (!products || products.length === 0) {
            grid.innerHTML = '<div style="grid-column: 1 / -1; text-align: center; padding: 40px 20px; color: #8D99AE; font-size: 14px;">' +
                             '<i class="fa fa-search" style="font-size: 32px; margin-bottom: 10px; display: block; opacity: 0.5;"></i>' +
                             'Không tìm thấy sản phẩm nào phù hợp tiêu chí tìm kiếm.</div>';
            return;
        }

        var html = '';
        products.forEach(function(p) {
            var imgSrc = p.imageUrl ? (p.imageUrl.startsWith('http') || p.imageUrl.startsWith('/') ? p.imageUrl : contextPath + '/' + p.imageUrl) : contextPath + '/assets/img/product01.png';
            html += '<div class="compare-grid-item" data-product-id="' + p.productId + '">';
            html += '<div class="compare-grid-img-wrap">';
            html += '<img src="' + imgSrc + '" alt="' + escapeHtml(p.productName) + '" onerror="this.src=\'' + contextPath + '/assets/img/product01.png\'"/>';
            html += '</div>';
            html += '<div class="compare-grid-cat">' + escapeHtml(p.categoryName || 'Headphones') + '</div>';
            html += '<h4 class="compare-grid-name"><a href="' + contextPath + '/productDetail?id=' + p.productId + '">' + escapeHtml(p.productName) + '</a></h4>';
            html += '<div class="compare-grid-price">' + formatVND(p.price) + '</div>';
            html += '<div class="compare-grid-actions">';
            html += '<button type="button" class="btn-select-compare btn-select-a" onclick="selectProductForSlot(\'A\', ' + p.productId + ')"><i class="fa fa-plus"></i> Chọn vào A</button>';
            html += '<button type="button" class="btn-select-compare btn-select-b" onclick="selectProductForSlot(\'B\', ' + p.productId + ')"><i class="fa fa-plus"></i> Chọn vào B</button>';
            html += '</div>';
            html += '</div>';
        });

        grid.innerHTML = html;
    }

    window.focusSearch = function() {
        var input = document.getElementById('compareKeywordInput');
        if (input) {
            input.focus();
            input.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    };

    function escapeHtml(text) {
        if (!text) return '';
        var map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
        return text.replace(/[&<>"']/g, function(m) { return map[m]; });
    }

    // Initialize events on page load
    document.addEventListener('DOMContentLoaded', function() {
        renderSpecsComparison();

        var catSelect = document.getElementById('compareCategorySelect');
        var brandSelect = document.getElementById('compareBrandSelect');
        var keywordInput = document.getElementById('compareKeywordInput');
        var searchBtn = document.getElementById('btnCompareSearch');

        if (catSelect) catSelect.addEventListener('change', triggerLiveSearch);
        if (brandSelect) brandSelect.addEventListener('change', triggerLiveSearch);
        if (keywordInput) {
            keywordInput.addEventListener('input', triggerLiveSearch);
            keywordInput.addEventListener('keydown', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    triggerLiveSearch();
                }
            });
        }
        if (searchBtn) searchBtn.addEventListener('click', triggerLiveSearch);
    });

})();
