/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

/* ===== SEARCH AUTOCOMPLETE ===== */
(function () {
    var searchInput = document.getElementById('search-input');
    var suggestionsBox = document.getElementById('search-suggestions');
    var searchForm = document.getElementById('search-form');
    var contextPath = window.__contextPath || '';
    var debounceTimer = null;
    var activeIndex = -1;

    if (!searchInput || !suggestionsBox) return;

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
        div.appendChild(document.createTextNode(text));
        return div.innerHTML;
    }

    function renderSuggestions(data) {
        suggestionsBox.innerHTML = '';
        activeIndex = -1;

        if (!data || data.length === 0) {
            suggestionsBox.innerHTML = '<div class="suggestion-no-result">Kh\u00f4ng t\u00ecm th\u1ea5y s\u1ea3n ph\u1ea9m</div>';
            suggestionsBox.style.display = 'block';
            return;
        }

        data.forEach(function (item, idx) {
            var a = document.createElement('a');
            a.className = 'search-suggestion-item';
            a.href = contextPath + '/productDetail?id=' + item.productID;
            a.setAttribute('data-index', idx);

            var imgSrc = item.imageUrl.indexOf('http') === 0
                ? item.imageUrl
                : contextPath + '/' + item.imageUrl;

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

/* ===== TAB SLICK RE-ALIGNMENT ===== */
(function () {
    if (window.jQuery) {
        window.jQuery(document).on('shown.bs.tab', 'a[data-toggle="tab"]', function (e) {
            var target = window.jQuery(e.target).attr('href');
            if (target) {
                var $target = window.jQuery(target);
                var $slick = $target.find('.products-slick');
                if ($slick.length && $slick.hasClass('slick-initialized')) {
                    $slick.slick('setPosition');
                }
            }
        });
    }
})();
