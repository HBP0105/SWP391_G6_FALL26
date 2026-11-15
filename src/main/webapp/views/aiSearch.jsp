<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>AI Audio Search & Visual Lookup | Electro Headphone Store</title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css"/>

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Custom stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css"/>

    <style>
        .ai-hero-section {
            background: linear-gradient(135deg, #15161D 0%, #2B2D42 100%);
            color: #FFF;
            padding: 40px 0 35px 0;
            border-bottom: 3px solid #D10024;
            margin-bottom: 30px;
        }
        .ai-badge {
            display: inline-block;
            background: linear-gradient(135deg, #D10024 0%, #ff4b6b 100%);
            color: #FFF;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 4px 12px;
            border-radius: 20px;
            margin-bottom: 12px;
        }
        .ai-tab-btn {
            background: #f4f5f8;
            color: #333;
            border: 2px solid transparent;
            border-radius: 8px;
            font-weight: 600;
            padding: 12px 20px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.25s ease;
            margin-right: 10px;
            outline: none;
        }
        .ai-tab-btn:hover {
            background: #e9ecef;
            color: #D10024;
        }
        .ai-tab-btn.active {
            background: #D10024;
            color: #FFF;
            border-color: #D10024;
            box-shadow: 0 4px 12px rgba(209, 0, 36, 0.3);
        }
        .ai-search-card {
            background: #FFF;
            border-radius: 12px;
            box-shadow: 0 6px 25px rgba(0,0,0,0.07);
            border: 1px solid #eef0f3;
            padding: 30px;
            margin-bottom: 35px;
        }
        /* Dropzone Styles */
        .ai-dropzone {
            border: 2px dashed #cbd5e1;
            border-radius: 10px;
            background: #f8fafc;
            padding: 35px 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.25s ease;
            position: relative;
        }
        .ai-dropzone:hover, .ai-dropzone.dragover {
            border-color: #D10024;
            background: #fff5f6;
        }
        .ai-dropzone-icon {
            font-size: 44px;
            color: #D10024;
            margin-bottom: 12px;
        }
        .ai-preview-container {
            display: none;
            width: 100%;
            margin: 0 auto 10px auto;
        }
        .ai-preview-grid {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            align-items: center;
            gap: 14px;
            margin-bottom: 12px;
        }
        .ai-preview-item {
            position: relative;
            width: 135px;
            height: 135px;
            border-radius: 8px;
            border: 2px solid #e2e8f0;
            background: #ffffff;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            transition: all 0.2s ease;
        }
        .ai-preview-item:hover {
            border-color: #D10024;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(209, 0, 36, 0.15);
        }
        .ai-preview-item img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
            padding: 6px;
        }
        .ai-preview-num {
            position: absolute;
            bottom: 4px;
            left: 4px;
            background: rgba(30, 41, 59, 0.8);
            color: #fff;
            font-size: 10px;
            font-weight: 700;
            padding: 1px 6px;
            border-radius: 3px;
            z-index: 2;
        }
        .ai-remove-item {
            position: absolute;
            top: 4px;
            right: 4px;
            background: rgba(209, 0, 36, 0.85);
            color: #FFF;
            border: none;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            font-size: 11px;
            line-height: 24px;
            text-align: center;
            cursor: pointer;
            transition: background 0.2s;
            z-index: 3;
            padding: 0;
        }
        .ai-remove-item:hover {
            background: #b91c1c;
            transform: scale(1.1);
        }
        .ai-add-slot {
            width: 135px;
            height: 135px;
            border: 2px dashed #cbd5e1;
            border-radius: 8px;
            background: #f8fafc;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: #64748b;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .ai-add-slot:hover {
            border-color: #D10024;
            color: #D10024;
            background: #fff5f6;
        }
        .ai-add-slot i {
            font-size: 24px;
            margin-bottom: 4px;
        }
        .ai-add-slot span {
            font-size: 11px;
            font-weight: 600;
        }
        .chip-pill {
            display: inline-block;
            background: #f1f3f7;
            color: #4b5563;
            font-size: 12px;
            padding: 6px 14px;
            border-radius: 18px;
            margin: 4px;
            cursor: pointer;
            transition: all 0.2s;
            border: 1px solid #e5e7eb;
        }
        .chip-pill:hover {
            background: #D10024;
            color: #FFF;
            border-color: #D10024;
        }
        /* Results Section */
        .ai-insight-box {
            background: #fcfcfd;
            border-left: 4px solid #D10024;
            border-radius: 0 8px 8px 0;
            padding: 16px 20px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .ai-product-card {
            background: #FFF;
            border: 1px solid #E4E7ED;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 25px;
            transition: all 0.25s ease;
            position: relative;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .ai-product-card:hover {
            box-shadow: 0 8px 24px rgba(0,0,0,0.12);
            border-color: #D10024;
            transform: translateY(-3px);
        }
        .ai-match-badge {
            position: absolute;
            top: 12px;
            left: 12px;
            background: #059669;
            color: #FFF;
            font-size: 11px;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 4px;
            z-index: 2;
        }
        .ai-visual-tag {
            position: absolute;
            top: 12px;
            right: 12px;
            background: #1e293b;
            color: #FFF;
            font-size: 10px;
            font-weight: 600;
            padding: 2px 7px;
            border-radius: 4px;
            z-index: 2;
        }
        .ai-prod-img-box {
            height: 180px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            margin-bottom: 12px;
            background: #fafafa;
            border-radius: 6px;
        }
        .ai-prod-img-box img {
            max-height: 160px;
            max-width: 100%;
            object-fit: contain;
            transition: transform 0.3s;
        }
        .ai-product-card:hover .ai-prod-img-box img {
            transform: scale(1.05);
        }
        .ai-spinner {
            display: inline-block;
            width: 18px;
            height: 18px;
            border: 2px solid rgba(255,255,255,0.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 0.8s ease-in-out infinite;
            vertical-align: middle;
            margin-right: 6px;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>

    <!-- HEADER COMPONENT -->
    <jsp:include page="/assets/components/header.jsp" />

    <!-- HERO HEADER -->
    <div class="ai-hero-section">
        <div class="container">
            <div class="row">
                <div class="col-md-12 text-center">
                    <span class="ai-badge"><i class="fa fa-magic"></i> Multimodal AI Technology</span>
                    <h1 style="color: #FFF; font-weight: 700; margin-top: 5px;">AI Audio Search & Headphone Discovery</h1>
                    <p style="color: #cbd5e1; font-size: 15px; max-width: 680px; margin: 0 auto;">
                        Upload photos of headphones you like or ask questions in natural language. Artificial intelligence will analyze design, specifications, and find the closest matching products.
                    </p>
                </div>
            </div>
        </div>
    </div>

    <!-- MAIN SEARCH CONTAINER -->
    <div class="container">
        <!-- MODE TABS -->
        <div class="row" style="margin-bottom: 20px;">
            <div class="col-md-12 text-center">
                <button type="button" class="ai-tab-btn active" id="tabImageBtn" onclick="switchMode('IMAGE')">
                    <i class="fa fa-camera"></i> Visual Image Search
                </button>
                <button type="button" class="ai-tab-btn" id="tabTextBtn" onclick="switchMode('TEXT')">
                    <i class="fa fa-comments"></i> Natural Language & Text Search
                </button>
            </div>
        </div>

        <!-- SEARCH FORM CARD -->
        <div class="row">
            <div class="col-md-10 col-md-offset-1">
                <div class="ai-search-card">

                    <!-- ========================================== -->
                    <!-- PANEL 1: IMAGE SEARCH                      -->
                    <!-- ========================================== -->
                    <div id="panelImageSearch">
                        <!-- Dropzone Area -->
                        <div class="ai-dropzone" id="aiDropzone" onclick="triggerFileInput();">
                            <input type="file" id="aiFileInput" multiple accept="image/png, image/jpeg, image/jpg, image/webp" style="display: none;" onchange="handleFileSelect(event)">
                            <div id="dropzonePrompt">
                                <div class="ai-dropzone-icon"><i class="fa fa-cloud-upload"></i></div>
                                <h4 style="font-weight: 600; margin-bottom: 6px;">Drag & Drop headphone photos here or Click to browse</h4>
                                <p class="text-muted" style="margin-bottom: 4px; font-size: 13px;">Upload up to <strong>4 images</strong> (PNG, JPG, JPEG, WEBP - Max 10MB each)</p>
                                <span style="font-size: 11px; background: #fee2e2; color: #dc2626; padding: 2px 8px; border-radius: 10px; font-weight: 600;">
                                    <i class="fa fa-camera"></i> Multi-angle photos supported for highest AI accuracy
                                </span>
                            </div>

                            <!-- Multi-Image Preview Box -->
                            <div class="ai-preview-container" id="aiPreviewBox" onclick="event.stopPropagation();">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; padding: 0 4px;">
                                    <span style="font-size: 13px; font-weight: 700; color: #1e293b;">
                                        <i class="fa fa-picture-o text-danger"></i> Selected Images (<span id="aiImageCountText" style="color: #D10024;">0/4</span>):
                                    </span>
                                    <button type="button" class="btn btn-default btn-xs" style="color: #ef4444; font-weight: 600;" onclick="clearAllImages();">
                                        <i class="fa fa-trash-o"></i> Clear all photos
                                    </button>
                                </div>
                                <div class="ai-preview-grid" id="aiPreviewGrid">
                                    <!-- Rendered dynamically via JS -->
                                </div>
                            </div>
                        </div>

                        <!-- Optional Note & Search Button -->
                        <div class="row" style="margin-top: 20px;">
                            <div class="col-md-8 col-sm-8">
                                <div class="form-group" style="margin-bottom: 10px;">
                                    <input type="text" id="aiImageNote" class="form-control input" placeholder="Optional note for AI (e.g., black color, or price under 3 million...)">
                                </div>
                            </div>
                            <div class="col-md-4 col-sm-4 text-right">
                                <button type="button" id="btnSearchImage" class="btn btn-danger primary-btn" style="width: 100%; border-radius: 4px; padding: 11px;" onclick="executeImageSearch()">
                                    <span id="btnImgSpinner" class="ai-spinner" style="display: none;"></span>
                                    <i class="fa fa-search"></i> Analyze & Search
                                </button>
                            </div>
                        </div>

                        <!-- Quick Sample Images -->
                        <div style="margin-top: 15px; padding-top: 15px; border-top: 1px dashed #e2e8f0;">
                            <span style="font-size: 12px; font-weight: 600; color: #64748b; margin-right: 8px;">
                                <i class="fa fa-lightbulb-o text-warning"></i> Quick sample photos:
                            </span>
                            <span class="chip-pill" onclick="loadSampleImage('${pageContext.request.contextPath}/assets/img/product01.png', 'Sony Over-ear Headphones')">
                                <i class="fa fa-headphones"></i> Sony Over-ear Headphones
                            </span>
                            <span class="chip-pill" onclick="loadSampleImage('${pageContext.request.contextPath}/assets/img/product02.png', 'True Wireless Earbuds')">
                                <i class="fa fa-dot-circle-o"></i> True Wireless Earbuds
                            </span>
                            <span class="chip-pill" onclick="loadSampleImage('${pageContext.request.contextPath}/assets/img/product03.png', 'Gaming Headset')">
                                <i class="fa fa-gamepad"></i> Gaming Headset
                            </span>
                        </div>
                    </div>

                    <!-- ========================================== -->
                    <!-- PANEL 2: TEXT / NATURAL LANGUAGE SEARCH    -->
                    <!-- ========================================== -->
                    <div id="panelTextSearch" style="display: none;">
                        <div class="form-group">
                            <label style="font-weight: 600; color: #334155; margin-bottom: 8px;">
                                <i class="fa fa-commenting text-danger"></i> Enter your question or audio shopping request:
                            </label>
                            <div class="input-group">
                                <input type="text" id="aiTextQuery" class="form-control input" style="height: 48px; font-size: 15px;" placeholder="e.g. noise-cancelling over-ear headphones for travel under 4 million..." value="<c:out value='${initialQuery}'/>" onkeypress="if(event.keyCode===13) executeTextSearch();">
                                <span class="input-group-btn">
                                    <button class="btn btn-danger primary-btn" id="btnSearchText" type="button" style="height: 48px; padding: 0 24px;" onclick="executeTextSearch()">
                                        <span id="btnTxtSpinner" class="ai-spinner" style="display: none;"></span>
                                        <i class="fa fa-paper-plane"></i> Search
                                    </button>
                                </span>
                            </div>
                        </div>

                        <!-- Sample Prompts -->
                        <div style="margin-top: 15px;">
                            <span style="font-size: 12px; font-weight: 600; color: #64748b; display: block; margin-bottom: 6px;">
                                <i class="fa fa-magic text-danger"></i> Sample prompt suggestions:
                            </span>
                            <span class="chip-pill" onclick="fillPrompt('best ANC noise cancelling travel headphones under 3 million')">
                                ✈️ Travel ANC headphones &lt; 3M
                            </span>
                            <span class="chip-pill" onclick="fillPrompt('Sony over-ear headphones with battery life over 30 hours')">
                                🔋 Sony headphones with 30h+ battery
                            </span>
                            <span class="chip-pill" onclick="fillPrompt('waterproof bluetooth sport gym earbuds')">
                                🏃 Waterproof sports earbuds
                            </span>
                            <span class="chip-pill" onclick="fillPrompt('office meeting headset with clear microphone')">
                                🎙️ Office meeting headset with clear mic
                            </span>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <!-- ========================================== -->
        <!-- SEARCH RESULTS DISPLAY AREA                -->
        <!-- ========================================== -->
        <div id="aiResultsSection" style="${not empty initialProducts ? '' : 'display: none;'} margin-bottom: 50px;">
            <div class="row">
                <div class="col-md-10 col-md-offset-1">
                    
                    <!-- AI Insight Banner -->
                    <div class="ai-insight-box">
                        <h4 style="margin-top: 0; font-weight: 700; color: #1e293b;">
                            <i class="fa fa-check-circle text-success"></i> AI Analysis & Recommendations
                        </h4>
                        <p id="aiAnalysisText" style="font-weight: 600; color: #334155; margin-bottom: 5px;">
                            <c:out value="${initialAnalysis}" default="Feature analysis completed."/>
                        </p>
                        <p id="aiReplyText" class="text-muted" style="margin-bottom: 0;">
                            <c:out value="${initialReply}" default="Here are the best matching products for your request:"/>
                        </p>
                    </div>

                    <!-- Products Grid -->
                    <div class="row" id="aiProductsGrid">
                        <c:forEach var="p" items="${initialProducts}">
                            <div class="col-md-4 col-sm-6">
                                <div class="ai-product-card">
                                    <span class="ai-match-badge"><i class="fa fa-bolt"></i> ${p.matchPercentage}% Match</span>
                                    <span class="ai-visual-tag">${not empty p.visualTag ? p.visualTag : 'Recommended'}</span>
                                    <div class="ai-prod-img-box">
                                        <img src="${empty p.imageUrl ? pageContext.request.contextPath.concat('/assets/img/product01.png') : (fn:startsWith(p.imageUrl, 'http') ? p.imageUrl : pageContext.request.contextPath.concat('/').concat(p.imageUrl))}" alt="${p.productName}" onerror="this.src='${pageContext.request.contextPath}/assets/img/product01.png'">
                                    </div>
                                    <div style="flex: 1; display: flex; flex-direction: column;">
                                        <div class="text-muted" style="font-size: 11px; text-transform: uppercase; font-weight: 600;">
                                            ${p.brandName} • ${p.categoryName}
                                        </div>
                                        <h4 style="font-size: 14px; font-weight: 700; margin: 6px 0 10px 0; line-height: 1.3;">
                                            <a href="${pageContext.request.contextPath}/productDetail?id=${p.productId}" style="color: #1e293b;">
                                                <c:out value="${p.productName}"/>
                                            </a>
                                        </h4>
                                        <div style="margin-top: auto; padding-top: 10px; border-top: 1px solid #f1f5f9; display: flex; align-items: center; justify-content: space-between;">
                                            <div style="color: #D10024; font-weight: 700; font-size: 15px;">
                                                <fmt:formatNumber value="${p.price}" pattern="#,###"/> ₫
                                            </div>
                                            <a href="${pageContext.request.contextPath}/productDetail?id=${p.productId}" class="btn btn-default btn-xs" style="font-weight: 600; padding: 4px 10px;">
                                                View <i class="fa fa-arrow-right"></i>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                </div>
            </div>
        </div>

    </div>

    <!-- FOOTER COMPONENT -->
    <jsp:include page="/assets/components/footer.jsp" />

    <!-- jQuery & Bootstrap Scripts -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>

    <!-- AI SEARCH ENGINE INTERACTIVE SCRIPT -->
    <script>
        var uploadedImages = []; // Array of { id: string, base64: string, mimeType: string }
        var contextPath = '${pageContext.request.contextPath}';

        function switchMode(mode) {
            if (mode === 'IMAGE') {
                $('#tabImageBtn').addClass('active');
                $('#tabTextBtn').removeClass('active');
                $('#panelImageSearch').show();
                $('#panelTextSearch').hide();
            } else {
                $('#tabTextBtn').addClass('active');
                $('#tabImageBtn').removeClass('active');
                $('#panelTextSearch').show();
                $('#panelImageSearch').hide();
                $('#aiTextQuery').focus();
            }
        }

        function triggerFileInput() {
            if (uploadedImages.length >= 4) {
                alert('You have selected the maximum of 4 images! Please remove an image before adding another.');
                return;
            }
            $('#aiFileInput').click();
        }

        // Drag & Drop Setup
        var dropzone = document.getElementById('aiDropzone');
        ['dragenter', 'dragover'].forEach(function(eventName) {
            dropzone.addEventListener(eventName, function(e) {
                e.preventDefault();
                e.stopPropagation();
                dropzone.classList.add('dragover');
            }, false);
        });

        ['dragleave', 'drop'].forEach(function(eventName) {
            dropzone.addEventListener(eventName, function(e) {
                e.preventDefault();
                e.stopPropagation();
                dropzone.classList.remove('dragover');
            }, false);
        });

        dropzone.addEventListener('drop', function(e) {
            var dt = e.dataTransfer;
            var files = dt.files;
            if (files && files.length > 0) {
                processImageFiles(files);
            }
        }, false);

        // Paste image from clipboard
        window.addEventListener('paste', function(e) {
            var items = (e.clipboardData || e.originalEvent.clipboardData).items;
            var pasteFiles = [];
            for (var i = 0; i < items.length; i++) {
                if (items[i].type.indexOf('image') !== -1) {
                    var blob = items[i].getAsFile();
                    if (blob) pasteFiles.push(blob);
                }
            }
            if (pasteFiles.length > 0) {
                processImageFiles(pasteFiles);
            }
        });

        function handleFileSelect(event) {
            var files = event.target.files;
            if (files && files.length > 0) {
                processImageFiles(files);
            }
            $('#aiFileInput').val(''); // Reset input so same file can be re-selected if deleted
        }

        function processImageFiles(files) {
            if (!files || files.length === 0) return;

            var currentCount = uploadedImages.length;
            if (currentCount >= 4) {
                alert('You have reached the maximum limit of 4 images!');
                return;
            }

            var availableSlots = 4 - currentCount;
            if (files.length > availableSlots) {
                alert('Only up to 4 images are supported. Automatically selected the first ' + availableSlots + ' image(s)!');
            }

            var limit = Math.min(files.length, availableSlots);
            for (var i = 0; i < limit; i++) {
                (function(file) {
                    if (!file.type.match('image.*')) {
                        alert('File "' + file.name + '" is not a valid image format!');
                        return;
                    }
                    if (file.size > 10 * 1024 * 1024) {
                        alert('Image "' + file.name + '" exceeds the maximum size of 10MB!');
                        return;
                    }

                    var reader = new FileReader();
                    reader.onload = function(e) {
                        uploadedImages.push({
                            id: 'img_' + Date.now() + '_' + Math.floor(Math.random() * 10000),
                            base64: e.target.result,
                            mimeType: file.type || 'image/jpeg'
                        });
                        renderPreviewGrid();
                    };
                    reader.readAsDataURL(file);
                })(files[i]);
            }
        }

        function renderPreviewGrid() {
            var count = uploadedImages.length;
            $('#aiImageCountText').text(count + '/4');

            if (count === 0) {
                $('#aiPreviewBox').hide();
                $('#dropzonePrompt').show();
                return;
            }

            $('#dropzonePrompt').hide();
            var grid = $('#aiPreviewGrid');
            grid.empty();

            uploadedImages.forEach(function(item, idx) {
                var html = '<div class="ai-preview-item" onclick="event.stopPropagation();">' +
                    '<span class="ai-preview-num">Image #' + (idx + 1) + '</span>' +
                    '<button type="button" class="ai-remove-item" title="Remove this image" onclick="removeImageById(\'' + item.id + '\'); event.stopPropagation();">' +
                        '<i class="fa fa-times"></i>' +
                    '</button>' +
                    '<img src="' + item.base64 + '" alt="Headphone photo #' + (idx + 1) + '">' +
                '</div>';
                grid.append(html);
            });

            if (count < 4) {
                var addSlot = '<div class="ai-add-slot" onclick="triggerFileInput(); event.stopPropagation();" title="Click to add more photos (up to 4)">' +
                    '<i class="fa fa-plus-circle"></i>' +
                    '<span>Add Photo (' + count + '/4)</span>' +
                '</div>';
                grid.append(addSlot);
            }

            $('#aiPreviewBox').show();
        }

        function removeImageById(id) {
            uploadedImages = uploadedImages.filter(function(item) {
                return item.id !== id;
            });
            renderPreviewGrid();
        }

        function clearAllImages() {
            uploadedImages = [];
            $('#aiFileInput').val('');
            renderPreviewGrid();
        }

        function loadSampleImage(imageUrl, label) {
            $('#aiImageNote').val('Find similar model to: ' + label);
            fetch(imageUrl)
                .then(function(res) { return res.blob(); })
                .then(function(blob) {
                    var reader = new FileReader();
                    reader.onloadend = function() {
                        if (uploadedImages.length >= 4) {
                            uploadedImages = []; // reset if full to prioritize sample
                        }
                        uploadedImages.push({
                            id: 'sample_' + Date.now(),
                            base64: reader.result,
                            mimeType: blob.type || 'image/png'
                        });
                        renderPreviewGrid();
                    };
                    reader.readAsDataURL(blob);
                })
                .catch(function(err) {
                    alert('Unable to load sample image at this time.');
                });
        }

        function fillPrompt(text) {
            $('#aiTextQuery').val(text);
            executeTextSearch();
        }

        function executeImageSearch() {
            if (uploadedImages.length === 0) {
                alert('Please select or drag & drop 1 to 4 headphone images before searching!');
                return;
            }

            var note = $('#aiImageNote').val().trim();
            $('#btnImgSpinner').show();
            $('#btnSearchImage').prop('disabled', true);

            var b64List = uploadedImages.map(function(item) { return item.base64; });
            var mimeList = uploadedImages.map(function(item) { return item.mimeType; });

            $.ajax({
                url: contextPath + '/ai-search',
                type: 'POST',
                data: {
                    action: 'search_image',
                    'images[]': b64List,
                    'mimeTypes[]': mimeList,
                    userNote: note
                },
                dataType: 'json',
                success: function(res) {
                    $('#btnImgSpinner').hide();
                    $('#btnSearchImage').prop('disabled', false);

                    if (res && res.success) {
                        renderResults(res);
                    } else {
                        alert(res.message || 'Unable to analyze image at this time. Please try again!');
                    }
                },
                error: function() {
                    $('#btnImgSpinner').hide();
                    $('#btnSearchImage').prop('disabled', false);
                    alert('An error occurred while connecting to the AI server.');
                }
            });
        }

        function executeTextSearch() {
            var q = $('#aiTextQuery').val().trim();
            if (!q) {
                alert('Please enter a question or product description!');
                $('#aiTextQuery').focus();
                return;
            }

            $('#btnTxtSpinner').show();
            $('#btnSearchText').prop('disabled', true);

            $.ajax({
                url: contextPath + '/ai-search',
                type: 'POST',
                data: {
                    action: 'search_text',
                    query: q
                },
                dataType: 'json',
                success: function(res) {
                    $('#btnTxtSpinner').hide();
                    $('#btnSearchText').prop('disabled', false);

                    if (res && res.success) {
                        renderResults(res);
                    } else {
                        alert(res.message || 'Unable to perform search at this time. Please try again!');
                    }
                },
                error: function() {
                    $('#btnTxtSpinner').hide();
                    $('#btnSearchText').prop('disabled', false);
                    alert('An error occurred during search lookup.');
                }
            });
        }

        function renderResults(data) {
            $('#aiAnalysisText').text(data.analysis || 'Analysis completed.');
            $('#aiReplyText').text(data.reply || '');

            var grid = $('#aiProductsGrid');
            grid.empty();

            var products = data.products || [];
            if (products.length === 0) {
                grid.append('<div class="col-md-12 text-center py-4"><p class="text-muted">No products found matching these criteria in our store.</p></div>');
            } else {
                products.forEach(function(p) {
                    var formattedPrice = Number(p.price || 0).toLocaleString('vi-VN') + ' ₫';
                    var matchPct = p.matchPercentage || 85;
                    var tag = p.visualTag || (matchPct >= 90 ? 'High Visual Match' : 'Similar Recommendation');
                    var imgUrl = p.imageUrl || (contextPath + '/assets/img/product01.png');

                    var cardHtml = '<div class="col-md-4 col-sm-6">' +
                        '<div class="ai-product-card">' +
                            '<span class="ai-match-badge"><i class="fa fa-bolt"></i> ' + matchPct + '% Match</span>' +
                            '<span class="ai-visual-tag">' + escapeHtml(tag) + '</span>' +
                            '<div class="ai-prod-img-box">' +
                                '<img src="' + imgUrl + '" alt="' + escapeHtml(p.productName) + '" onerror="this.src=\'' + contextPath + '/assets/img/product01.png\'">' +
                            '</div>' +
                            '<div style="flex: 1; display: flex; flex-direction: column;">' +
                                '<div class="text-muted" style="font-size: 11px; text-transform: uppercase; font-weight: 600;">' +
                                    escapeHtml(p.brandName || '') + ' • ' + escapeHtml(p.categoryName || '') +
                                '</div>' +
                                '<h4 style="font-size: 14px; font-weight: 700; margin: 6px 0 10px 0; line-height: 1.3;">' +
                                    '<a href="' + contextPath + '/productDetail?id=' + p.productId + '" style="color: #1e293b;">' +
                                        escapeHtml(p.productName) +
                                    '</a>' +
                                '</h4>' +
                                '<div style="margin-top: auto; padding-top: 10px; border-top: 1px solid #f1f5f9; display: flex; align-items: center; justify-content: space-between;">' +
                                    '<div style="color: #D10024; font-weight: 700; font-size: 15px;">' + formattedPrice + '</div>' +
                                    '<a href="' + contextPath + '/productDetail?id=' + p.productId + '" class="btn btn-default btn-xs" style="font-weight: 600; padding: 4px 10px;">' +
                                        'View <i class="fa fa-arrow-right"></i>' +
                                    '</a>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>';

                    grid.append(cardHtml);
                });
            }

            $('#aiResultsSection').fadeIn();
            $('html, body').animate({
                scrollTop: $('#aiResultsSection').offset().top - 80
            }, 500);
        }

        function escapeHtml(text) {
            if (!text) return '';
            return text.replace(/&/g, "&amp;")
                       .replace(/</g, "&lt;")
                       .replace(/>/g, "&gt;")
                       .replace(/"/g, "&quot;")
                       .replace(/'/g, "&#039;");
        }
    </script>
</body>
</html>

