/**
 * Product Comparison Page Interactive Script
 */
(function() {
    var contextPath = window.__contextPath || '';
    var currentProductA = window.__initialProductA || null;
    var currentProductB = window.__initialProductB || null;
    var aiSimWeight = typeof window.__aiSimWeight === 'number' ? window.__aiSimWeight : 0.5;
    var aiBehWeight = typeof window.__aiBehWeight === 'number' ? window.__aiBehWeight : 0.5;

    // Format currency VND
    function formatVND(amount) {
        if (amount == null || isNaN(amount)) return '0 ₫';
        return Number(amount).toLocaleString('vi-VN') + ' ₫';
    }

    // Format star rating rounded to 2 decimal places
    function formatRating(prod) {
        if (!prod || prod.rating == null || isNaN(prod.rating) || Number(prod.rating) <= 0) {
            return 'No ratings yet';
        }
        var count = prod.reviewCount || 0;
        var rounded = Number(prod.rating).toFixed(2);
        return rounded + ' ★ (' + count + ')';
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
                    '<span class="compare-slot-badge ' + (slot === 'A' ? 'slot-a' : 'slot-b') + '">Product ' + slot + '</span>' +
                    '<div class="compare-empty-icon"><i class="fa fa-plus-circle"></i></div>' +
                    '<div class="compare-empty-text">Product ' + slot + ' not selected</div>' +
                    '<div class="compare-empty-subtext">Select a headphone from the list below to compare</div>' +
                '</div>';
        } else {
            // Render Active Product
            var imgSrc = product.imageUrl ? (product.imageUrl.startsWith('http') || product.imageUrl.startsWith('/') ? product.imageUrl : contextPath + '/' + product.imageUrl) : contextPath + '/assets/img/product01.png';
            container.innerHTML = 
                '<div class="compare-product-box">' +
                    '<span class="compare-slot-badge ' + (slot === 'A' ? 'slot-a' : 'slot-b') + '">Product ' + slot + '</span>' +
                    '<button type="button" class="compare-btn-remove-slot" title="Remove" onclick="removeSlot(\'' + slot + '\')">' +
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
                            '<button type="submit" class="compare-btn-cart"><i class="fa fa-shopping-cart"></i> Add to cart</button>' +
                        '</form>' +
                    '</div>' +
                '</div>';
        }
    }

    // Generate 512-Dimensional Normalized Feature Vector for Cosine Similarity
    function generate512FeatureVector(p) {
        var vec = new Array(512);
        var priceNorm = Math.min(1.0, (Number(p.price) || 0) / 15000000.0);
        var batNorm = Math.min(1.0, (Number(p.batteryLife) || 0) / 120.0);
        var drvNorm = Math.min(1.0, (Number(p.driverSize) || 0) / 55.0);
        var wtNorm = Math.min(1.0, (Number(p.weight) || 0) / 400.0);
        var ancVal = p.noiseCancelling ? 1.0 : 0.0;
        var micVal = p.microphone ? 1.0 : 0.0;
        var waterVal = (p.waterResistance && p.waterResistance.toLowerCase() !== 'none') ? 1.0 : 0.0;
        var catVal = (p.categoryName && p.categoryName.toLowerCase().indexOf('earbud') !== -1) ? 1.0 : 0.3;
        var connVal = (p.connectionType && p.connectionType.toUpperCase() === 'WIRED') ? 0.2 : 1.0;

        var baseFeatures = [priceNorm, batNorm, drvNorm, wtNorm, ancVal, micVal, waterVal, catVal, connVal];
        var textSeed = (p.categoryName || '') + '|' + (p.connectionType || '') + '|' + (p.noiseCancelling ? 'ANC' : 'STD');

        var sumSq = 0;
        for (var i = 0; i < 512; i++) {
            var fVal = baseFeatures[i % baseFeatures.length];
            var h = ((i + 1) * 31 + textSeed.charCodeAt(i % Math.max(1, textSeed.length))) % 100;
            var val = (fVal * 0.8) + ((h / 100.0) * 0.2);
            vec[i] = val;
            sumSq += val * val;
        }
        var norm = Math.sqrt(sumSq);
        if (norm > 0) {
            for (var j = 0; j < 512; j++) {
                vec[j] = vec[j] / norm;
            }
        }
        return vec;
    }

    function calculateCosineSimilarity512(pA, pB) {
        var vA = generate512FeatureVector(pA);
        var vB = generate512FeatureVector(pB);
        var dot = 0, nA = 0, nB = 0;
        for (var i = 0; i < 512; i++) {
            dot += vA[i] * vB[i];
            nA += vA[i] * vA[i];
            nB += vB[i] * vB[i];
        }
        if (nA === 0 || nB === 0) return 0.75;
        return Math.max(0, Math.min(1, dot / (Math.sqrt(nA) * Math.sqrt(nB))));
    }

    // Compute AI Hybrid Score (0 - 100) using Admin weights (w_sim * TechnicalScore + w_beh * BehaviorScore)
    function computeAIHybridScore(p, other) {
        var techScore = 0.50;
        if (p.noiseCancelling) techScore += 0.14;
        if (p.microphone) techScore += 0.06;
        if (p.waterResistance && p.waterResistance.toLowerCase() !== 'none') techScore += 0.08;
        if (Number(p.batteryLife) > 0) techScore += Math.min(0.14, (Number(p.batteryLife) / 80.0) * 0.14);
        if (Number(p.driverSize) > 0) techScore += Math.min(0.08, (Number(p.driverSize) / 50.0) * 0.08);
        techScore = Math.min(0.98, techScore);

        var ratingVal = Number(p.rating) > 0 ? Number(p.rating) / 5.0 : 0.75;
        var revBoost = Math.min(0.10, (Number(p.reviewCount) || 0) * 0.015);
        var behScore = Math.min(0.98, ratingVal * 0.9 + revBoost);

        // Value-for-money adjustment relative to peer
        if (other && Number(p.price) > 0 && Number(other.price) > 0 && Number(p.price) < Number(other.price)) {
            var savingsRatio = (Number(other.price) - Number(p.price)) / Number(other.price);
            techScore = Math.min(0.99, techScore + Math.min(0.06, savingsRatio * 0.12));
        }

        var hybrid = (aiSimWeight * techScore) + (aiBehWeight * behScore);
        return Math.round(hybrid * 100);
    }

    // Build Pros & Cons arrays for Product `target` compared against `peer`
    function buildProsAndCons(target, peer) {
        var pros = [];
        var cons = [];

        var pPrice = Number(target.price) || 0;
        var oPrice = Number(peer.price) || 0;
        if (pPrice > 0 && oPrice > 0) {
            if (pPrice < oPrice) {
                var diff = oPrice - pPrice;
                var pct = Math.round((diff / oPrice) * 100);
                pros.push('More budget-friendly: saves <strong>' + formatVND(diff) + '</strong> (' + pct + '% cheaper) compared to ' + escapeHtml(peer.productName) + '.');
            } else if (pPrice > oPrice) {
                var diffMore = pPrice - oPrice;
                var pctMore = Math.round((diffMore / oPrice) * 100);
                cons.push('Higher price tag: costs <strong>' + formatVND(diffMore) + '</strong> (+' + pctMore + '%) more than ' + escapeHtml(peer.productName) + '.');
            }
        }

        // Noise Cancelling
        if (target.noiseCancelling && !peer.noiseCancelling) {
            pros.push('Equipped with <strong>Active Noise Cancelling (ANC)</strong> for superior ambient noise isolation.');
        } else if (!target.noiseCancelling && peer.noiseCancelling) {
            cons.push('Lacks Active Noise Cancelling (ANC), whereas ' + escapeHtml(peer.productName) + ' supports ANC.');
        } else if (target.noiseCancelling && peer.noiseCancelling) {
            pros.push('Supports <strong>Active Noise Cancelling (ANC)</strong> for immersive listening.');
        }

        // Battery Life
        var pBat = Number(target.batteryLife) || 0;
        var oBat = Number(peer.batteryLife) || 0;
        if (pBat > 0 && oBat > 0) {
            if (pBat > oBat) {
                pros.push('Longer battery endurance: <strong>' + pBat + ' hours</strong> (+' + (pBat - oBat) + ' hrs longer than ' + escapeHtml(peer.productName) + ').');
            } else if (pBat < oBat) {
                cons.push('Shorter battery life: <strong>' + pBat + ' hours</strong> (' + (oBat - pBat) + ' hrs less than ' + escapeHtml(peer.productName) + ').');
            }
        } else if (pBat > 0 && oBat === 0) {
            pros.push('Wireless freedom with up to <strong>' + pBat + ' hours</strong> of built-in battery life.');
        } else if (pBat === 0 && oBat > 0) {
            pros.push('Zero-latency wired connection that never requires battery charging.');
            cons.push('Requires a physical cable connection (no wireless battery portability).');
        }

        // Driver Size
        var pDrv = Number(target.driverSize) || 0;
        var oDrv = Number(peer.driverSize) || 0;
        if (pDrv > 0 && oDrv > 0) {
            if (pDrv > oDrv) {
                pros.push('Larger <strong>' + pDrv + ' mm</strong> acoustic driver (vs ' + oDrv + ' mm) for deeper bass and wider soundstage.');
            } else if (pDrv < oDrv) {
                cons.push('Smaller <strong>' + pDrv + ' mm</strong> driver compared to ' + escapeHtml(peer.productName) + '\'s ' + oDrv + ' mm driver.');
            }
        }

        // Weight (Lighter is more comfortable)
        var pWt = Number(target.weight) || 0;
        var oWt = Number(peer.weight) || 0;
        if (pWt > 0 && oWt > 0) {
            if (pWt < oWt) {
                pros.push('Lighter &amp; more comfortable build at <strong>' + pWt + ' g</strong> (' + (oWt - pWt).toFixed(1).replace(/\.0$/, '') + ' g lighter for long listening sessions).');
            } else if (pWt > oWt) {
                cons.push('Heavier form factor at <strong>' + pWt + ' g</strong> (+' + (pWt - oWt).toFixed(1).replace(/\.0$/, '') + ' g heavier than ' + escapeHtml(peer.productName) + ').');
            }
        }

        // Water Resistance
        var pWater = (target.waterResistance && target.waterResistance.toLowerCase() !== 'none') ? target.waterResistance : null;
        var oWater = (peer.waterResistance && peer.waterResistance.toLowerCase() !== 'none') ? peer.waterResistance : null;
        if (pWater && !oWater) {
            pros.push('Certified <strong>' + escapeHtml(pWater) + '</strong> water/sweat resistance, ideal for workouts and outdoor use.');
        } else if (!pWater && oWater) {
            cons.push('No water resistance rating (unlike ' + escapeHtml(peer.productName) + ' with ' + escapeHtml(oWater) + ').');
        } else if (pWater && oWater && pWater !== oWater) {
            pros.push('Features <strong>' + escapeHtml(pWater) + '</strong> water protection.');
        }

        // Microphone
        if (target.microphone && !peer.microphone) {
            pros.push('Includes a <strong>built-in microphone</strong> for voice calls and online meetings.');
        } else if (!target.microphone && peer.microphone) {
            cons.push('No built-in microphone for hands-free voice calls.');
        }

        // Customer Rating
        var pRate = Number(target.rating) || 0;
        var oRate = Number(peer.rating) || 0;
        if (pRate > 0 && oRate > 0) {
            if (pRate > oRate) {
                pros.push('Higher customer satisfaction rating: <strong>' + pRate.toFixed(2) + ' ★</strong> (' + (target.reviewCount || 0) + ' reviews).');
            } else if (pRate < oRate) {
                cons.push('Slightly lower community rating (' + pRate.toFixed(2) + ' ★ vs ' + oRate.toFixed(2) + ' ★).');
            }
        }

        // Fallbacks if lists are empty (e.g., identical specs)
        if (pros.length === 0) {
            pros.push('Reliable <strong>' + escapeHtml(target.brandName || 'Authentic') + '</strong> build quality in the ' + escapeHtml(target.categoryName || 'Headphone') + ' segment.');
        }
        if (cons.length === 0) {
            cons.push('No major technical drawbacks compared to ' + escapeHtml(peer.productName) + ' in its class.');
        }

        return { pros: pros, cons: cons };
    }

    // Render AI Smart Comparison Section (Between Top Row and Filter Toolbar)
    function renderAIComparison() {
        var bodyContainer = document.getElementById('aiCompareBody');
        var headerBadges = document.getElementById('aiCompareHeaderBadges');
        if (!bodyContainer) return;

        var a = currentProductA;
        var b = currentProductB;

        if (!a || !b) {
            if (headerBadges) {
                headerBadges.innerHTML = '<span class="ai-engine-pill"><i class="fa fa-microchip"></i> 512-D Vector Engine</span>';
            }
            var missingText = (!a && !b)
                ? 'Please select <strong>Product A</strong> and <strong>Product B</strong> from the list below to generate an AI-powered Pros &amp; Cons comparison.'
                : (!a ? 'Please select <strong>Product A</strong> to complete the AI comparison against <strong>' + escapeHtml(b.productName) + '</strong>.'
                      : 'Please select <strong>Product B</strong> to complete the AI comparison against <strong>' + escapeHtml(a.productName) + '</strong>.');
            bodyContainer.innerHTML =
                '<div class="ai-empty-notice">' +
                    '<i class="fa fa-lightbulb-o"></i>' +
                    '<div>' + missingText + '</div>' +
                '</div>';
            return;
        }

        var simScore = calculateCosineSimilarity512(a, b);
        var simPct = Math.round(simScore * 100);
        var scoreA = computeAIHybridScore(a, b);
        var scoreB = computeAIHybridScore(b, a);

        if (headerBadges) {
            headerBadges.innerHTML =
                '<span class="ai-sim-pill" title="512-Dimensional Cosine Similarity">' +
                    '<i class="fa fa-bullseye"></i> AI Vector Similarity: ' + simPct + '%' +
                '</span>' +
                '<span class="ai-engine-pill" title="Active Admin Hybrid Weights">' +
                    '<i class="fa fa-sliders"></i> Weights: w<sub>sim</sub>=' + aiSimWeight.toFixed(2) + ' | w<sub>beh</sub>=' + aiBehWeight.toFixed(2) +
                '</span>';
        }

        var analysisA = buildProsAndCons(a, b);
        var analysisB = buildProsAndCons(b, a);

        var sameCategory = (a.categoryName && b.categoryName && a.categoryName.toLowerCase() === b.categoryName.toLowerCase());
        var segmentDesc = sameCategory
            ? 'Both models compete directly in the <strong>' + escapeHtml(a.categoryName) + '</strong> category with a <strong>' + simPct + '%</strong> 512-D feature similarity.'
            : 'Cross-category comparison between a <strong>' + escapeHtml(a.categoryName || 'Headphone') + '</strong> (' + escapeHtml(a.productName) + ') and a <strong>' + escapeHtml(b.categoryName || 'Headphone') + '</strong> (' + escapeHtml(b.productName) + ') with a <strong>' + simPct + '%</strong> feature similarity.';

        var verdictHtml = '';
        if (scoreA > scoreB) {
            verdictHtml = 'Based on the active AI Hybrid Scoring model (<strong>' + scoreA + '/100</strong> vs <strong>' + scoreB + '/100</strong>), <strong>' + escapeHtml(a.productName) + '</strong> holds the overall edge. '
                + 'Choose <strong>' + escapeHtml(a.productName) + '</strong> for its stronger overall feature-to-value balance, or pick <strong>' + escapeHtml(b.productName) + '</strong> if its specific strengths better match your listening habits.';
        } else if (scoreB > scoreA) {
            verdictHtml = 'Based on the active AI Hybrid Scoring model (<strong>' + scoreB + '/100</strong> vs <strong>' + scoreA + '/100</strong>), <strong>' + escapeHtml(b.productName) + '</strong> holds the overall edge. '
                + 'Choose <strong>' + escapeHtml(b.productName) + '</strong> for its superior overall feature-to-value score, or pick <strong>' + escapeHtml(a.productName) + '</strong> if its advantages align with your personal preferences.';
        } else {
            verdictHtml = 'Both <strong>' + escapeHtml(a.productName) + '</strong> and <strong>' + escapeHtml(b.productName) + '</strong> are evenly matched with an identical AI Hybrid Score of <strong>' + scoreA + '/100</strong>. Your choice comes down to whether you prefer the ergonomics and sound signature of ' + escapeHtml(a.brandName || 'Product A') + ' or ' + escapeHtml(b.brandName || 'Product B') + '.';
        }

        var html = '';
        // 1. Summary Banner
        html += '<div class="ai-summary-banner">';
        html += '<i class="fa fa-info-circle" style="color:#D10024; margin-right:6px;"></i> ';
        html += segmentDesc;
        html += '</div>';

        // 2. Pros & Cons Grid (Product A vs Product B)
        html += '<div class="ai-pros-cons-grid">';

        // Column A
        html += '<div class="ai-prod-col col-a">';
        html += '<div class="ai-prod-col-header">';
        html += '<h4 class="ai-prod-col-title"><span class="compare-slot-badge slot-a" style="position:static;">Prod A</span> ' + escapeHtml(a.productName) + '</h4>';
        html += '<span class="ai-score-badge score-a">AI Score: ' + scoreA + '/100</span>';
        html += '</div>';
        html += '<div class="ai-list-heading pros-heading"><i class="fa fa-thumbs-up"></i> Pros (Advantages)</div>';
        html += '<ul class="ai-point-list">';
        analysisA.pros.forEach(function(item) {
            html += '<li><i class="fa fa-check-circle"></i><span>' + item + '</span></li>';
        });
        html += '</ul>';
        html += '<div class="ai-list-heading cons-heading"><i class="fa fa-exclamation-circle"></i> Cons (Trade-offs)</div>';
        html += '<ul class="ai-point-list">';
        analysisA.cons.forEach(function(item) {
            html += '<li><i class="fa fa-minus-circle"></i><span>' + item + '</span></li>';
        });
        html += '</ul>';
        html += '</div>';

        // Column B
        html += '<div class="ai-prod-col col-b">';
        html += '<div class="ai-prod-col-header">';
        html += '<h4 class="ai-prod-col-title"><span class="compare-slot-badge slot-b" style="position:static;">Prod B</span> ' + escapeHtml(b.productName) + '</h4>';
        html += '<span class="ai-score-badge score-b">AI Score: ' + scoreB + '/100</span>';
        html += '</div>';
        html += '<div class="ai-list-heading pros-heading"><i class="fa fa-thumbs-up"></i> Pros (Advantages)</div>';
        html += '<ul class="ai-point-list">';
        analysisB.pros.forEach(function(item) {
            html += '<li><i class="fa fa-check-circle"></i><span>' + item + '</span></li>';
        });
        html += '</ul>';
        html += '<div class="ai-list-heading cons-heading"><i class="fa fa-exclamation-circle"></i> Cons (Trade-offs)</div>';
        html += '<ul class="ai-point-list">';
        analysisB.cons.forEach(function(item) {
            html += '<li><i class="fa fa-minus-circle"></i><span>' + item + '</span></li>';
        });
        html += '</ul>';
        html += '</div>';

        html += '</div>';

        // 3. Final Verdict Box
        html += '<div class="ai-verdict-box">';
        html += '<div class="ai-verdict-title"><i class="fa fa-trophy"></i> AI Buying Verdict &amp; Recommendation</div>';
        html += '<div>' + verdictHtml + '</div>';
        html += '</div>';

        bodyContainer.innerHTML = html;
    }

    // Render Specs Comparison List (Right Column)
    function renderSpecsComparison() {
        var listContainer = document.getElementById('compareSpecsList');
        if (!listContainer) return;

        var a = currentProductA;
        var b = currentProductB;

        var specs = [
            {
                label: 'Price',
                valA: a ? formatVND(a.price) : '—',
                valB: b ? formatVND(b.price) : '—',
                betterA: a && b && (Number(a.price) < Number(b.price)),
                betterB: a && b && (Number(b.price) < Number(a.price))
            },
            {
                label: 'Category',
                valA: a && a.categoryName ? a.categoryName : '—',
                valB: b && b.categoryName ? b.categoryName : '—'
            },
            {
                label: 'Brand',
                valA: a && a.brandName ? a.brandName : '—',
                valB: b && b.brandName ? b.brandName : '—'
            },
            {
                label: 'Connection Type',
                valA: a && a.connectionType ? a.connectionType : '—',
                valB: b && b.connectionType ? b.connectionType : '—'
            },
            {
                label: 'Noise Cancelling (ANC)',
                valA: a ? (a.noiseCancelling ? '<span class="spec-better">Yes (ANC)</span>' : 'No') : '—',
                valB: b ? (b.noiseCancelling ? '<span class="spec-better">Yes (ANC)</span>' : 'No') : '—',
                betterA: a && a.noiseCancelling && b && !b.noiseCancelling,
                betterB: b && b.noiseCancelling && a && !a.noiseCancelling
            },
            {
                label: 'Battery Life',
                valA: a && a.batteryLife ? a.batteryLife + ' hours' : '—',
                valB: b && b.batteryLife ? b.batteryLife + ' hours' : '—',
                betterA: a && b && (Number(a.batteryLife) > Number(b.batteryLife)),
                betterB: a && b && (Number(b.batteryLife) > Number(a.batteryLife))
            },
            {
                label: 'Microphone',
                valA: a ? (a.microphone ? 'Built-in' : 'No') : '—',
                valB: b ? (b.microphone ? 'Built-in' : 'No') : '—'
            },
            {
                label: 'Driver Size',
                valA: a && a.driverSize ? a.driverSize + ' mm' : '—',
                valB: b && b.driverSize ? b.driverSize + ' mm' : '—'
            },
            {
                label: 'Water Resistance',
                valA: a && a.waterResistance ? a.waterResistance : 'None',
                valB: b && b.waterResistance ? b.waterResistance : 'None'
            },
            {
                label: 'Weight',
                valA: a && a.weight ? a.weight + ' g' : '—',
                valB: b && b.weight ? b.weight + ' g' : '—'
            },
            {
                label: 'Customer Rating',
                valA: formatRating(a),
                valB: formatRating(b),
                betterA: a && b && (Number(a.rating) > Number(b.rating)),
                betterB: a && b && (Number(b.rating) > Number(a.rating))
            },
            {
                label: 'Availability',
                valA: a ? (a.stockQuantity > 0 ? '<span class="spec-better">In Stock</span>' : '<span style="color:#C62828;">Out of Stock</span>') : '—',
                valB: b ? (b.stockQuantity > 0 ? '<span class="spec-better">In Stock</span>' : '<span style="color:#C62828;">Out of Stock</span>') : '—'
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
        renderAIComparison();
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
                bA.innerText = 'Selected as Prod A';
                el.appendChild(bA);
            } else if (pid === idB) {
                el.classList.add('selected-as-b');
                var bB = document.createElement('span');
                bB.className = 'selected-badge-flag flag-b';
                bB.innerText = 'Selected as Prod B';
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
            showSiteWishlistToast('Swapped Product A and Product B positions!', false);
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
                        showSiteWishlistToast('Selected ' + data.product.productName + ' for Product ' + slot + '!', false);
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
                        countContainer.innerText = '(' + (data.totalCount || 0) + ' products)';
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

    window.jumpToComparePage = function(maxPages) {
        var inp = document.getElementById('compareJumpPageInput');
        if (!inp) return;
        var val = parseInt(inp.value, 10);
        if (isNaN(val)) return;
        if (val < 1) val = 1;
        if (val > maxPages) val = maxPages;
        window.goToComparePage(val);
    };

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
        html += 'Showing <strong>' + fromIndex + '-' + toIndex + '</strong> of <strong>' + totalCount + '</strong> products';
        html += '</span>';

        if (totalPages > 1) {
            var startPage = curPage - 2 > 1 ? curPage - 2 : 1;
            var endPage = startPage + 4 < totalPages ? startPage + 4 : totalPages;
            if (endPage - startPage < 4) {
                startPage = endPage - 4 > 1 ? endPage - 4 : 1;
            }

            html += '<div class="store-pagination-wrap">';
            html += '<ul class="store-pagination">';
            if (curPage > 1) {
                html += '<li><a href="javascript:void(0)" onclick="goToComparePage(1)" title="First Page"><i class="fa fa-angle-double-left"></i></a></li>';
                html += '<li><a href="javascript:void(0)" onclick="goToComparePage(' + (curPage - 1) + ')" title="Previous Page"><i class="fa fa-angle-left"></i></a></li>';
            }
            for (var i = startPage; i <= endPage; i++) {
                if (i === curPage) {
                    html += '<li class="active"><span>' + i + '</span></li>';
                } else {
                    html += '<li><a href="javascript:void(0)" onclick="goToComparePage(' + i + ')">' + i + '</a></li>';
                }
            }
            if (curPage < totalPages) {
                html += '<li><a href="javascript:void(0)" onclick="goToComparePage(' + (curPage + 1) + ')" title="Next Page"><i class="fa fa-angle-right"></i></a></li>';
                html += '<li><a href="javascript:void(0)" onclick="goToComparePage(' + totalPages + ')" title="Last Page"><i class="fa fa-angle-double-right"></i></a></li>';
            }
            html += '</ul>';
            html += '<div class="pagination-jump-box">';
            html += '<input type="number" id="compareJumpPageInput" class="pagination-jump-input" min="1" max="' + totalPages + '" value="' + curPage + '" placeholder="Page" onkeydown="if(event.key===\'Enter\'){event.preventDefault();jumpToComparePage(' + totalPages + ');}">';
            html += '<button type="button" class="pagination-jump-btn" onclick="jumpToComparePage(' + totalPages + ')">Go</button>';
            html += '</div>';
            html += '</div>';
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
                             'No products found matching your search criteria.</div>';
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
            html += '<button type="button" class="btn-select-compare btn-select-a" onclick="selectProductForSlot(\'A\', ' + p.productId + ')"><i class="fa fa-plus"></i> Select for A</button>';
            html += '<button type="button" class="btn-select-compare btn-select-b" onclick="selectProductForSlot(\'B\', ' + p.productId + ')"><i class="fa fa-plus"></i> Select for B</button>';
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
