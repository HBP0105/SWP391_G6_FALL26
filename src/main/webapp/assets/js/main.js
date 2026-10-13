(function ($) {
	"use strict"

	// Mobile Nav toggle
	$('.menu-toggle > a').on('click', function (e) {
		e.preventDefault();
		$('#responsive-nav').toggleClass('active');
	})

	// Fix cart dropdown from closing
	$('.cart-dropdown').on('click', function (e) {
		e.stopPropagation();
	});

	/////////////////////////////////////////

	// Products Slick
	$('.products-slick').each(function () {
		var $this = $(this),
			$nav = $this.attr('data-nav');

		$this.slick({
			slidesToShow: 4,
			slidesToScroll: 1,
			autoplay: true,
			infinite: true,
			speed: 300,
			dots: false,
			arrows: true,
			appendArrows: $nav ? $nav : false,
			responsive: [{
				breakpoint: 991,
				settings: {
					slidesToShow: 2,
					slidesToScroll: 1,
				}
			},
			{
				breakpoint: 480,
				settings: {
					slidesToShow: 1,
					slidesToScroll: 1,
				}
			},
			]
		});
	});

	// Products Widget Slick
	$('.products-widget-slick').each(function () {
		var $this = $(this),
			$nav = $this.attr('data-nav');

		$this.slick({
			infinite: true,
			autoplay: true,
			speed: 300,
			dots: false,
			arrows: true,
			appendArrows: $nav ? $nav : false,
		});
	});

	/////////////////////////////////////////

	// Product Main img Slick
	$('#product-main-img').slick({
		infinite: true,
		speed: 300,
		dots: false,
		arrows: true,
		fade: true,
		asNavFor: '#product-imgs',
	});

	// Product imgs Slick
	$('#product-imgs').slick({
		slidesToShow: 3,
		slidesToScroll: 1,
		arrows: true,
		centerMode: true,
		focusOnSelect: true,
		centerPadding: 0,
		vertical: true,
		asNavFor: '#product-main-img',
		responsive: [{
			breakpoint: 991,
			settings: {
				vertical: false,
				arrows: false,
				dots: true,
			}
		},
		]
	});

	// Product img zoom
	var zoomMainProduct = document.getElementById('product-main-img');
	if (zoomMainProduct) {
		$('#product-main-img .product-preview').zoom();
	}

	/////////////////////////////////////////

	// Input number
	$('.input-number').each(function () {
		var $this = $(this),
			$input = $this.find('input[type="number"]'),
			up = $this.find('.qty-up'),
			down = $this.find('.qty-down');

		down.on('click', function () {
			var value = parseInt($input.val()) - 1;
			value = value < 1 ? 1 : value;
			$input.val(value);
			$input.change();
			updatePriceSlider($this, value)
		})

		up.on('click', function () {
			var value = parseInt($input.val()) + 1;
			$input.val(value);
			$input.change();
			updatePriceSlider($this, value)
		})
	});

	var priceInputMax = document.getElementById('price-max'),
		priceInputMin = document.getElementById('price-min');

	if (priceInputMax) {
		priceInputMax.addEventListener('change', function () {
			updatePriceSlider($(this).parent(), this.value)
		});
	}

	if (priceInputMin) {
		priceInputMin.addEventListener('change', function () {
			updatePriceSlider($(this).parent(), this.value)
		});
	}

	function updatePriceSlider(elem, value) {
		if (!priceSlider || !priceSlider.noUiSlider) return;
		if (elem.hasClass('price-min')) {
			console.log('min')
			priceSlider.noUiSlider.set([value, null]);
		} else if (elem.hasClass('price-max')) {
			console.log('max')
			priceSlider.noUiSlider.set([null, value]);
		}
	}

	// Price Slider
	var priceSlider = document.getElementById('price-slider');
	if (priceSlider) {
		noUiSlider.create(priceSlider, {
			start: [1, 999],
			connect: true,
			step: 1,
			range: {
				'min': 1,
				'max': 999
			}
		});

		priceSlider.noUiSlider.on('update', function (values, handle) {
			var value = values[handle];
			handle ? priceInputMax.value = value : priceInputMin.value = value
		});
	}

	// Wishlist click handled by header.jsp listener (with capture phase and stopPropagation).
	// Fallback listener in case header.jsp listener is absent:
	$(document).on('click', '.add-to-wishlist', function (e) {
		var $btn = $(this);
		if ($btn.hasClass('in-wishlist')) {
			e.preventDefault();
			e.stopPropagation();
			showSiteToast('Sản phẩm đã có trong wishlist!', false);
			return false;
		}
	});

	function showSiteToast(msg, isError, loginUrl) {
		var $toast = $('#siteWishlistToast');
		if (!$toast.length) {
			$toast = $('<div id="siteWishlistToast" style="display:none;position:fixed;bottom:24px;right:24px;background:#1e1f29;color:#fff;padding:14px 20px;border-radius:4px;box-shadow:0 6px 20px rgba(0,0,0,0.35);z-index:999999;font-size:13px;align-items:center;gap:10px;opacity:0;transition:opacity 0.3s ease;max-width:400px;line-height:1.4;"><i id="siteWishlistToastIcon"></i><span id="siteWishlistToastContent" class="toast-content"></span></div>');
			$('body').append($toast);
		}

		var $icon = $toast.find('i');
		var $content = $toast.find('.toast-content');
		if (!$content.length) {
			$content = $toast.find('#siteWishlistToastContent');
		}

		if (isError) {
			$icon.attr('class', 'fa fa-exclamation-circle').css('color', '#D10024').css('font-size', '16px');
		} else {
			$icon.attr('class', 'fa fa-check-circle').css('color', '#4CAF50').css('font-size', '16px');
		}

		if (loginUrl) {
			$content.html(msg + ' <a href="' + loginUrl + '" style="color:#FFD54F;text-decoration:underline;margin-left:6px;font-weight:700;">Đăng nhập ngay</a>');
		} else {
			$content.text(msg);
		}

		$toast.css({ 'display': 'flex' });
		setTimeout(function() {
			$toast.css('opacity', '1');
		}, 10);

		if (window.__toastTimeout) {
			clearTimeout(window.__toastTimeout);
		}
		window.__toastTimeout = setTimeout(function () {
			$toast.css('opacity', '0');
			setTimeout(function() {
				$toast.css('display', 'none');
			}, 300);
		}, loginUrl ? 5000 : 3000);
	}

	// Add to compare click handler
	$(document).on('click', '.add-to-compare', function (e) {
		if (window.location.pathname.indexOf('/compare') !== -1) {
			return; // Handled by compare.js if on compare page
		}
		e.preventDefault();
		var pid = $(this).attr('data-product-id');
		if (!pid) {
			pid = $(this).closest('.product').find('[data-product-id]').attr('data-product-id');
		}
		var ctx = window.__contextPath || '';
		if (pid) {
			window.location.href = ctx + '/compare?idA=' + encodeURIComponent(pid);
		} else {
			window.location.href = ctx + '/compare';
		}
	});

	window.showSiteToast = showSiteToast;
	window.showSiteWishlistToast = showSiteToast;

})(jQuery);

