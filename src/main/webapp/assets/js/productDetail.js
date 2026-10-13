/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

/* ===== IMAGE SLIDER ===== */
(function () {
    var track = document.getElementById('pdTrack');
    var thumbs = document.querySelectorAll('#pdThumbs .pd-thumb');
    var btnPrev = document.getElementById('pdPrev');
    var btnNext = document.getElementById('pdNext');
    if (!track) return;

    var total = track.children.length;
    var current = 0;

    function goTo(idx) {
        if (idx < 0) idx = total - 1;
        if (idx >= total) idx = 0;
        current = idx;
        track.style.transform = 'translateX(-' + (current * 100) + '%)';
        thumbs.forEach(function (t, i) {
            t.classList.toggle('active', i === current);
        });
    }

    if (btnPrev) {
        btnPrev.addEventListener('click', function () { goTo(current - 1); });
    }
    if (btnNext) {
        btnNext.addEventListener('click', function () { goTo(current + 1); });
    }

    thumbs.forEach(function (thumb) {
        thumb.addEventListener('click', function () {
            goTo(parseInt(this.getAttribute('data-index')));
        });
    });
})();

/* ===== SEARCH AUTOCOMPLETE ===== */
(function () {
    var searchInput = document.getElementById('search-input');
    var suggestionsBox = document.getElementById('search-suggestions');
    var searchForm = document.getElementById('search-form');
    var contextPath = window.__contextPath || '';
    var debounceTimer = null;

    if (!searchInput || !suggestionsBox) return;

    function formatPrice(price) {
        return parseFloat(price).toLocaleString('vi-VN') + ' \u20ab';
    }

    function escapeHtml(text) {
        var d = document.createElement('div');
        d.appendChild(document.createTextNode(text));
        return d.innerHTML;
    }

    function renderSuggestions(data) {
        suggestionsBox.innerHTML = '';
        if (!data || data.length === 0) {
            suggestionsBox.innerHTML = '<div class="suggestion-no-result">No products found</div>';
            suggestionsBox.style.display = 'block';
            return;
        }
        data.forEach(function (item) {
            var a = document.createElement('a');
            a.className = 'search-suggestion-item';
            a.href = contextPath + '/productDetail?id=' + item.productID;
            var imgSrc = item.imageUrl.indexOf('http') === 0 ? item.imageUrl : contextPath + '/' + item.imageUrl;
            a.innerHTML = '<img class="suggestion-img" src="' + imgSrc + '" alt="' + escapeHtml(item.productName) + '">' +
                    '<div class="suggestion-info"><div class="suggestion-name">' + escapeHtml(item.productName) + '</div>' +
                    '<div class="suggestion-meta">' + escapeHtml(item.categoryName || '') + '</div></div>' +
                    '<span class="suggestion-price">' + formatPrice(item.price) + '</span>';
            suggestionsBox.appendChild(a);
        });
        suggestionsBox.style.display = 'block';
    }

    function hideSuggestions() {
        suggestionsBox.style.display = 'none';
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

    searchInput.addEventListener('input', function () {
        clearTimeout(debounceTimer);
        var kw = this.value.trim();
        debounceTimer = setTimeout(function () {
            fetchSuggestions(kw);
        }, 300);
    });

    document.addEventListener('click', function (e) {
        if (!searchInput.contains(e.target) && !suggestionsBox.contains(e.target))
            hideSuggestions();
    });

    searchInput.addEventListener('focus', function () {
        if (this.value.trim().length >= 3 && suggestionsBox.innerHTML)
            suggestionsBox.style.display = 'block';
    });

    if (searchForm) {
        searchForm.addEventListener('submit', function () {
            hideSuggestions();
        });
    }
})();
