<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.time.LocalDate" %>

<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Performance & Configuration Report | Admin Dashboard</title>

  <!-- Bootstrap 5 CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- Chart.js -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <!-- adminHMD Custom Style -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminhmd-style.css">

  <style>
    .date-ddmmyyyy-wrapper {
      position: relative;
    }
    .date-ddmmyyyy-display {
      background-color: #fff !important;
      cursor: pointer;
    }
    .date-native-picker {
      position: absolute;
      top: 0;
      right: 0;
      width: 36px;
      height: 100%;
      opacity: 0;
      cursor: pointer;
      z-index: 2;
    }
    .chart-container {
      position: relative;
      height: 320px;
      width: 100%;
    }
    .badge-type {
      font-size: 0.75rem;
      padding: 0.35em 0.65em;
      border-radius: 6px;
      font-weight: 700;
    }
    .config-box {
      border: 1px dashed var(--admin-border);
      border-radius: 8px;
      padding: 1.25rem;
      background: var(--admin-surface-soft);
    }
    .simulator-box {
      background: linear-gradient(135deg, rgba(37, 99, 235, 0.05), rgba(15, 118, 110, 0.05));
      border: 1px solid rgba(37, 99, 235, 0.2);
      border-radius: 8px;
      padding: 1rem;
    }
  </style>
</head>

<body>
  <div class="admin-shell">
    <div class="sidebar-backdrop" id="sidebarBackdrop"></div>

    <!-- SIDEBAR -->
    <aside class="admin-sidebar" id="adminSidebar">
      <div class="sidebar-header">
        <a class="brand-mark" href="${pageContext.request.contextPath}/admin/ai-performance">
          <span class="brand-icon"><i class="bi bi-cpu-fill"></i></span>
          <span class="brand-copy">
            <span class="brand-title">Admin Portal</span>
            <span class="brand-subtitle">AI & Recommendation Analytics</span>
          </span>
        </a>
      </div>

      <nav class="sidebar-nav">
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/revenue-report">
          <span class="nav-icon"><i class="bi bi-graph-up-arrow"></i></span>
          <span class="nav-text">Revenue Report</span>
        </a>
        <a class="nav-link active" href="${pageContext.request.contextPath}/admin/ai-performance">
          <span class="nav-icon"><i class="bi bi-robot"></i></span>
          <span class="nav-text">AI Performance & Config</span>
        </a>
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/behavior-pipeline">
          <span class="nav-icon"><i class="bi bi-diagram-3"></i></span>
          <span class="nav-text">Behavior Pipeline</span>
        </a>
        <a class="nav-link" href="${pageContext.request.contextPath}/admin/audit-logs">
          <span class="nav-icon"><i class="bi bi-clock-history"></i></span>
          <span class="nav-text">Audit Logs</span>
        </a>
      </nav>
    </aside>

    <!-- MAIN CONTENT AREA -->
    <div class="admin-main">
      <!-- TOP NAVBAR -->
      <nav class="navbar admin-navbar navbar-expand bg-white border-bottom shadow-sm">
        <div class="container-fluid px-3">
          <span class="navbar-text fw-bold text-dark fs-6">
            <i class="bi bi-sliders text-primary me-2"></i>AI Recommendation Engine Performance & Configuration
          </span>
          <div class="navbar-actions ms-auto d-flex align-items-center gap-2">
            <button class="icon-button theme-toggle" id="themeToggleBtn" type="button" title="Switch Light/Dark Theme">
              <i class="bi bi-moon-stars" id="themeIcon"></i>
            </button>
            <div class="dropdown">
              <button class="profile-button dropdown-toggle border-0 bg-transparent" type="button" data-bs-toggle="dropdown">
                <i class="bi bi-person-badge-fill text-primary fs-5 me-1"></i>
                <span class="profile-name d-none d-sm-inline fw-semibold">Administrator</span>
              </button>
              <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/home"><i class="bi bi-box-arrow-right me-2"></i>Exit to Store</a></li>
              </ul>
            </div>
          </div>
        </div>
      </nav>

      <!-- CONTENT BODY -->
      <div class="p-3 p-md-4">

        <!-- ALERTS -->
        <c:if test="${not empty msgError || not empty sessionScope.msgError}">
          <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-3" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><strong>Error: </strong><c:out value="${not empty msgError ? msgError : sessionScope.msgError}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
          </div>
        </c:if>

        <c:if test="${not empty msgSuccess || not empty sessionScope.msgSuccess}">
          <div class="alert alert-success alert-dismissible fade show shadow-sm mb-3" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i><strong>Success: </strong><c:out value="${not empty msgSuccess ? msgSuccess : sessionScope.msgSuccess}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
          </div>
        </c:if>

        <!-- PAGE HEADING & FILTER FORM -->
        <div class="panel mb-4">
          <form method="get" action="${pageContext.request.contextPath}/admin/ai-performance" class="row g-3 align-items-end" id="filterForm">
            <div class="col-12 col-md-3">
              <label class="form-label fw-semibold text-muted small"><i class="bi bi-calendar-event me-1"></i>From Date (dd/mm/yyyy)</label>
              <div class="date-ddmmyyyy-wrapper">
                <input type="text" id="startDateDisplay" placeholder="dd/mm/yyyy" class="form-control form-control-sm date-ddmmyyyy-display" readonly>
                <input type="date" class="date-native-picker" name="startDate" id="startDate" value="${selectedStartDate}" max="<%= LocalDate.now() %>" title="Click to pick From Date">
              </div>
            </div>
            <div class="col-12 col-md-3">
              <label class="form-label fw-semibold text-muted small"><i class="bi bi-calendar-check me-1"></i>To Date (dd/mm/yyyy)</label>
              <div class="date-ddmmyyyy-wrapper">
                <input type="text" id="endDateDisplay" placeholder="dd/mm/yyyy" class="form-control form-control-sm date-ddmmyyyy-display" readonly>
                <input type="date" class="date-native-picker" name="endDate" id="endDate" value="${selectedEndDate}" max="<%= LocalDate.now() %>" title="Click to pick To Date">
              </div>
            </div>
            <div class="col-12 col-md-3">
              <label class="form-label fw-semibold text-muted small"><i class="bi bi-funnel me-1"></i>AI Recommendation Type</label>
              <select class="form-select form-select-sm" name="type">
                <option value="ALL" ${selectedType == 'ALL' ? 'selected' : ''}>All Types</option>
                <option value="SIMILAR" ${selectedType == 'SIMILAR' ? 'selected' : ''}>SIMILAR (Product Similarity)</option>
                <option value="PERSONALIZED" ${selectedType == 'PERSONALIZED' ? 'selected' : ''}>PERSONALIZED (Personalized)</option>
                <option value="TRENDING" ${selectedType == 'TRENDING' ? 'selected' : ''}>TRENDING (Trending)</option>
                <option value="BEST_SELLER" ${selectedType == 'BEST_SELLER' ? 'selected' : ''}>BEST_SELLER (Best Sellers)</option>
                <option value="COLD_START" ${selectedType == 'COLD_START' ? 'selected' : ''}>COLD_START (Cold Start / Guests)</option>
              </select>
            </div>
            <div class="col-12 col-md-3 d-flex gap-2">
              <button type="submit" class="btn btn-primary btn-sm flex-fill fw-bold">
                <i class="bi bi-search me-1"></i>Filter Report
              </button>
              <a href="${pageContext.request.contextPath}/admin/ai-performance" class="btn btn-outline-secondary btn-sm" title="Reset">
                <i class="bi bi-arrow-clockwise"></i>
              </a>
            </div>

            <div class="col-12 d-flex align-items-center gap-1 pt-1">
              <span class="text-muted small me-1" style="font-size: 0.75rem;"><i class="bi bi-lightning-charge-fill text-warning"></i> Quick select:</span>
              <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('today')">Today</button>
              <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('7days')">Last 7 days</button>
              <button type="button" class="btn btn-outline-primary btn-sm py-0 px-2" style="font-size: 0.72rem; border-radius: 20px;" onclick="setQuickDate('month')">This month</button>
            </div>
          </form>
        </div>

        <!-- KPI METRIC CARDS ROW (5 COLUMNS) -->
        <div class="row row-cols-1 row-cols-sm-2 row-cols-xl-5 g-3 mb-4">
          <!-- Card 1: Total Recommendations -->
          <div class="col">
            <div class="metric-card metric-primary">
              <div class="metric-top">
                <span class="metric-label">Total Recommendations</span>
                <div class="metric-icon"><i class="bi bi-cpu"></i></div>
              </div>
              <div class="metric-value">
                <fmt:formatNumber value="${summary.totalRecommendations}" type="number" />
              </div>
              <div class="small text-muted mt-2">
                <i class="bi bi-info-circle me-1"></i>Total generated recommendations
              </div>
            </div>
          </div>

          <!-- Card 2: Click-Through Rate (CTR) -->
          <div class="col">
            <div class="metric-card metric-info">
              <div class="metric-top">
                <span class="metric-label">Click-Through Rate (CTR)</span>
                <div class="metric-icon"><i class="bi bi-cursor"></i></div>
              </div>
              <div class="metric-value text-info">
                ${summary.ctrRate}%
              </div>
              <div class="small text-muted mt-2">
                <i class="bi bi-hand-index-thumb me-1"></i>${summary.totalClicked} Clicks
              </div>
            </div>
          </div>

          <!-- Card 3: Conversion Rate -->
          <div class="col">
            <div class="metric-card metric-success">
              <div class="metric-top">
                <span class="metric-label">Conversion Rate</span>
                <div class="metric-icon"><i class="bi bi-bag-check"></i></div>
              </div>
              <div class="metric-value text-success">
                ${summary.conversionRate}%
              </div>
              <div class="small text-muted mt-2">
                <i class="bi bi-cart-check me-1"></i>${summary.totalPurchased} Purchases
              </div>
            </div>
          </div>

          <!-- Card 4: Avg Similarity Score -->
          <div class="col">
            <div class="metric-card metric-warning">
              <div class="metric-top">
                <span class="metric-label">Avg Similarity Score</span>
                <div class="metric-icon"><i class="bi bi-diagram-3"></i></div>
              </div>
              <div class="metric-value text-warning">
                ${summary.avgSimilarityScore}
              </div>
              <div class="small text-muted mt-2">
                <i class="bi bi-sliders me-1"></i>Product feature similarity
              </div>
            </div>
          </div>

          <!-- Card 5: Avg Final Score -->
          <div class="col">
            <div class="metric-card metric-danger">
              <div class="metric-top">
                <span class="metric-label">Avg Confidence Score</span>
                <div class="metric-icon"><i class="bi bi-stars"></i></div>
              </div>
              <div class="metric-value text-danger">
                ${summary.avgFinalScore}
              </div>
              <div class="small text-muted mt-2">
                <i class="bi bi-graph-up me-1"></i>Final recommendation score
              </div>
            </div>
          </div>
        </div>

        <!-- CHARTS & AI CONFIGURATION ROW -->
        <div class="row g-3 mb-4">
          <!-- CHART 1: Recommendation Type Breakdown & CTR -->
          <div class="col-12 col-xl-7">
            <div class="panel h-100">
              <div class="panel-header">
                <h6 class="fw-bold m-0"><i class="bi bi-bar-chart-steps text-primary me-2"></i>Performance Distribution by Recommendation Type</h6>
                <span class="badge bg-secondary-subtle text-secondary fw-bold" title="Always benchmarks all recommendation types system-wide for overall comparison">All-Type Benchmark</span>
              </div>
              <div class="chart-container">
                <canvas id="aiTypeChart"></canvas>
              </div>
            </div>
          </div>

          <!-- AI MODEL CONFIGURATION FORM -->
          <div class="col-12 col-xl-5">
            <div class="panel h-100">
              <div class="panel-header">
                <h6 class="fw-bold m-0 text-primary"><i class="bi bi-sliders2-vertical me-2"></i>AI Algorithm Weight Configuration</h6>
                <span class="badge bg-success-subtle text-success fw-bold">Active Engine</span>
              </div>
              
              <form method="post" action="${pageContext.request.contextPath}/admin/ai-performance" id="aiConfigForm" onsubmit="return validateAIConfigForm(event)">
                <input type="hidden" name="action" value="updateConfig">
                
                <div class="config-box mb-3">
                  <div class="row g-2 mb-2">
                    <div class="col-6">
                      <label class="form-label small fw-bold text-muted mb-1">Similarity Weight (w<sub>sim</sub>) [0.0 - 1.0]</label>
                      <input type="number" step="0.05" min="0" max="1" class="form-control form-control-sm fw-bold text-primary" 
                             id="simWeightInput" name="similarityWeight" value="${aiConfig.similarityWeight}" 
                             onkeydown="if(event.key==='-'||event.key==='+'||event.key==='e'||event.key==='E') event.preventDefault();"
                             oninput="updateScoreSimulator()">
                      <div class="invalid-feedback extra-small" id="simWeightError">Must be between 0.0 and 1.0 (no negative).</div>
                    </div>
                    <div class="col-6">
                      <label class="form-label small fw-bold text-muted mb-1">Behavior Weight (w<sub>beh</sub>) [0.0 - 1.0]</label>
                      <input type="number" step="0.05" min="0" max="1" class="form-control form-control-sm fw-bold text-teal" 
                             id="behWeightInput" name="behaviorWeight" value="${aiConfig.behaviorWeight}" 
                             onkeydown="if(event.key==='-'||event.key==='+'||event.key==='e'||event.key==='E') event.preventDefault();"
                             oninput="updateScoreSimulator()">
                      <div class="invalid-feedback extra-small" id="behWeightError">Must be between 0.0 and 1.0 (no negative).</div>
                    </div>
                  </div>

                  <!-- Dynamic Total Weight Status Badge -->
                  <div class="d-flex align-items-center justify-content-between p-2 rounded mb-3" id="weightStatusBox" style="background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.25);">
                    <span class="extra-small fw-bold text-muted"><i class="bi bi-pie-chart-fill me-1"></i>Total Weights (w<sub>sim</sub> + w<sub>beh</sub>):</span>
                    <span id="weightSumBadge" class="badge bg-success-subtle text-success fw-bold">1.0 (Valid)</span>
                  </div>

                  <div class="mb-3">
                    <label class="form-label small fw-bold text-muted mb-1">Minimum Similarity Threshold (S<sub>min</sub>) [0.0 - 1.0]</label>
                    <input type="number" step="0.05" min="0" max="1" class="form-control form-control-sm" 
                           id="minSimilarityThresholdInput" name="minSimilarityThreshold" value="${aiConfig.minSimilarityThreshold}"
                           onkeydown="if(event.key==='-'||event.key==='+'||event.key==='e'||event.key==='E') event.preventDefault();">
                    <div class="form-text extra-small text-muted">Filter out recommendations with similarity score below this threshold.</div>
                  </div>

                  <div class="row g-2 mb-3">
                    <div class="col-6">
                      <label class="form-label small fw-bold text-muted mb-1">Storefront Display Limit (Top K) [1 - 50]</label>
                      <input type="number" min="1" max="50" step="1" class="form-control form-control-sm" 
                             id="topKLimitInput" name="topKLimit" value="${aiConfig.topKLimit}"
                             onkeydown="if(event.key==='-'||event.key==='+'||event.key==='e'||event.key==='E') event.preventDefault();">
                      <div class="form-text extra-small text-muted">Items shown to customers on Storefront.</div>
                    </div>
                    <div class="col-6">
                      <label class="form-label small fw-bold text-muted mb-1">Fallback Strategy</label>
                      <select class="form-select form-select-sm" name="fallbackStrategy">
                        <option value="COLD_START" ${aiConfig.fallbackStrategy == 'COLD_START' ? 'selected' : ''}>COLD_START (Popular)</option>
                        <option value="BEST_SELLER" ${aiConfig.fallbackStrategy == 'BEST_SELLER' ? 'selected' : ''}>BEST_SELLER (Best Sellers)</option>
                      </select>
                      <div class="form-text extra-small text-muted">Backup strategy when user has no history.</div>
                    </div>
                  </div>
                </div>

                <!-- Score Simulator Preview -->
                <div class="simulator-box mb-3">
                  <div class="d-flex align-items-center justify-content-between mb-2">
                    <span class="small fw-bold text-dark"><i class="bi bi-calculator me-1"></i>Score Simulator Preview:</span>
                    <span class="badge bg-primary" id="simScoreResult">0.875</span>
                  </div>
                  <div class="extra-small text-muted">
                    <span class="badge bg-light text-dark border me-1">Formula</span>
                    Final Score = (w<sub>sim</sub> &times; Similarity) + (w<sub>beh</sub> &times; Behavior)
                  </div>
                  <div class="extra-small text-muted" style="font-size: 0.72rem;">
                    <i class="bi bi-info-circle me-1 text-primary"></i>Sample test: S<sub>sim</sub> = 0.90, S<sub>beh</sub> = 0.85
                  </div>
                </div>

                <button type="submit" id="btnSaveConfig" class="btn btn-primary btn-sm w-100 fw-bold shadow-sm">
                  <i class="bi bi-floppy-fill me-1"></i>Save Configuration & Update AI Engine
                </button>
              </form>
            </div>
          </div>
        </div>

        <!-- TOP RECOMMENDED PRODUCTS TABLE -->
        <div class="panel mb-4">
          <div class="panel-header">
            <h6 class="fw-bold m-0">
              <i class="bi bi-trophy-fill text-warning me-2"></i>Top 10 Recommended Products
              <c:if test="${not empty selectedType && selectedType != 'ALL'}">
                <span class="badge bg-primary-subtle text-primary fw-bold ms-2" style="font-size: 0.72rem;">
                  <i class="bi bi-funnel-fill me-1"></i>Type: ${selectedType}
                </span>
              </c:if>
            </h6>
            <span class="badge bg-secondary-subtle text-secondary fw-bold">Performance Matrix (Top 10)</span>
          </div>

          <div class="table-responsive">
            <table class="table table-hover align-middle table-orders mb-0">
              <thead class="table-light">
                <tr>
                  <th style="width: 50px;">ID</th>
                  <th>Product Name</th>
                  <th>Category</th>
                  <th>Brand</th>
                  <th class="text-end">Unit Price (VND)</th>
                  <th class="text-center">Recommendations</th>
                  <th class="text-center">Clicks</th>
                  <th class="text-center">Purchases</th>
                  <th class="text-center">CTR</th>
                  <th class="text-center">Conversion Rate</th>
                  <th class="text-end">Avg Score</th>
                </tr>
              </thead>
              <tbody>
                <c:choose>
                  <c:when test="${empty topProducts}">
                    <tr>
                      <td colspan="11" class="text-center text-muted py-4">No recommendation data found for this period.</td>
                    </tr>
                  </c:when>
                  <c:otherwise>
                    <c:forEach var="p" items="${topProducts}">
                      <tr>
                        <td class="fw-bold text-muted">#${p.productID}</td>
                        <td class="fw-bold text-dark product-name-cell" title="${p.productName}">${p.productName}</td>
                        <td><span class="badge bg-light text-dark border">${p.categoryName}</span></td>
                        <td><span class="badge bg-info-subtle text-info">${p.brandName}</span></td>
                        <td class="text-end fw-semibold">
                          <fmt:formatNumber value="${p.price}" type="number" /> ₫
                        </td>
                        <td class="text-center fw-bold text-primary">${p.recommendCount}</td>
                        <td class="text-center fw-bold text-info">${p.clickedCount}</td>
                        <td class="text-center fw-bold text-success">${p.purchasedCount}</td>
                        <td class="text-center fw-bold text-indigo">
                          <span class="badge bg-primary-subtle text-primary">${p.ctrRate}%</span>
                        </td>
                        <td class="text-center fw-bold">
                          <span class="badge bg-success-subtle text-success">${p.conversionRate}%</span>
                        </td>
                        <td class="text-end fw-bold text-danger">${p.avgFinalScore}</td>
                      </tr>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </tbody>
            </table>
          </div>
        </div>

        <!-- RECENT AI RECOMMENDATION LOGS (FULL WIDTH) -->
        <div class="panel mb-4">
          <div class="panel-header">
            <h6 class="fw-bold m-0"><i class="bi bi-journal-text text-primary me-2"></i>Recent Recommendation Logs (Real-time Pipeline)</h6>
            <span class="badge bg-info-subtle text-info fw-bold"><i class="bi bi-broadcast me-1"></i>Latest 20 Events</span>
          </div>
          <div class="table-responsive" style="max-height: 420px; overflow-y: auto;">
            <table class="table table-hover align-middle mb-0" style="font-size: 0.82rem;">
              <thead class="table-light sticky-top">
                <tr>
                  <th>Rec ID</th>
                  <th>Customer / Session</th>
                  <th>Product</th>
                  <th>Recommendation Type</th>
                  <th class="text-center">Similarity</th>
                  <th class="text-center">Behavior</th>
                  <th class="text-center">Final Score</th>
                  <th class="text-center">Status</th>
                </tr>
              </thead>
              <tbody>
                <c:choose>
                  <c:when test="${empty recentLogs}">
                    <tr>
                      <td colspan="8" class="text-center text-muted py-3">No recommendation logs recorded.</td>
                    </tr>
                  </c:when>
                  <c:otherwise>
                    <c:forEach var="item" items="${recentLogs}">
                      <c:set var="rec" value="${item.recommendation}" />
                      <tr>
                        <td class="fw-bold text-muted">#${rec.recommendationID}</td>
                        <td>
                          <div class="fw-semibold text-dark">${item.customerName}</div>
                          <div class="extra-small text-muted">${rec.sessionID}</div>
                        </td>
                        <td class="fw-bold text-dark" style="max-width: 260px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${item.productName}">
                          ${item.productName}
                        </td>
                        <td>
                          <c:set var="t" value="${rec.recommendationType}" />
                          <c:choose>
                            <c:when test="${t == 'SIMILAR'}"><span class="badge bg-primary-subtle text-primary badge-type">SIMILAR</span></c:when>
                            <c:when test="${t == 'PERSONALIZED'}"><span class="badge bg-success-subtle text-success badge-type">PERSONALIZED</span></c:when>
                            <c:when test="${t == 'TRENDING'}"><span class="badge bg-warning-subtle text-warning badge-type">TRENDING</span></c:when>
                            <c:when test="${t == 'BEST_SELLER'}"><span class="badge bg-purple-subtle text-purple badge-type" style="background:#f3e8ff; color:#9333ea;">BEST_SELLER</span></c:when>
                            <c:otherwise><span class="badge bg-secondary-subtle text-secondary badge-type">COLD_START</span></c:otherwise>
                          </c:choose>
                        </td>
                        <td class="text-center font-monospace">${rec.similarityScore}</td>
                        <td class="text-center font-monospace">${rec.behaviorScore}</td>
                        <td class="text-center fw-bold text-primary font-monospace">${rec.finalScore}</td>
                        <td class="text-center">
                          <c:if test="${rec.clicked}">
                            <span class="badge bg-info text-white" title="Customer Clicked"><i class="bi bi-cursor-fill"></i> Clicked</span>
                          </c:if>
                          <c:if test="${rec.purchased}">
                            <span class="badge bg-success text-white" title="Customer Purchased"><i class="bi bi-bag-check-fill"></i> Purchased</span>
                          </c:if>
                          <c:if test="${!rec.clicked && !rec.purchased}">
                            <span class="badge bg-light text-muted border">Impression</span>
                          </c:if>
                        </td>
                      </tr>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </tbody>
            </table>
          </div>
        </div>

      </div>
    </div>
  </div>

  <!-- Bootstrap 5 JS Bundle -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Chart.js & Dashboard Logic Script -->
  <script>
/**
 * AI Performance & Configuration Dashboard Scripts
 * Handles: Theme toggle, Score Simulator, Weight Bounds Validation,
 * Date Range Formatting (dd/mm/yyyy), Quick Filters, and Chart.js rendering.
 */

// Theme Toggle Script
function initThemeToggle() {
  const themeToggleBtn = document.getElementById('themeToggleBtn');
  const themeIcon = document.getElementById('themeIcon');
  const htmlTag = document.documentElement;

  const savedTheme = localStorage.getItem('adminTheme') || 'light';
  htmlTag.setAttribute('data-theme', savedTheme);
  updateThemeIcon(savedTheme);

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', () => {
      const currentTheme = htmlTag.getAttribute('data-theme');
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      htmlTag.setAttribute('data-theme', newTheme);
      localStorage.setItem('adminTheme', newTheme);
      updateThemeIcon(newTheme);
    });
  }

  function updateThemeIcon(theme) {
    if (!themeIcon) return;
    if (theme === 'dark') {
      themeIcon.className = 'bi bi-sun-fill text-warning';
    } else {
      themeIcon.className = 'bi bi-moon-stars';
    }
  }
}

// Score Simulator & Total Weight Indicator Script (Standards [0.0 - 1.0], Sum = 1.0)
function updateScoreSimulator() {
  const simInput = document.getElementById('simWeightInput');
  const behInput = document.getElementById('behWeightInput');
  const simValStr = simInput ? simInput.value.trim() : '';
  const behValStr = behInput ? behInput.value.trim() : '';

  const simW = parseFloat(simValStr);
  const behW = parseFloat(behValStr);

  const sumBadge = document.getElementById('weightSumBadge');
  const statusBox = document.getElementById('weightStatusBox');
  const submitBtn = document.getElementById('btnSaveConfig');
  const scoreElem = document.getElementById('simScoreResult');

  let hasNegative = false;
  let hasOutOfRange = false;
  let hasNaN = false;

  // Validate Similarity Weight
  if (simValStr === '' || isNaN(simW)) {
    hasNaN = true;
    if (simInput) simInput.classList.add('is-invalid');
  } else if (simW < 0) {
    hasNegative = true;
    if (simInput) simInput.classList.add('is-invalid');
  } else if (simW > 1.0) {
    hasOutOfRange = true;
    if (simInput) simInput.classList.add('is-invalid');
  } else {
    if (simInput) simInput.classList.remove('is-invalid');
  }

  // Validate Behavior Weight
  if (behValStr === '' || isNaN(behW)) {
    hasNaN = true;
    if (behInput) behInput.classList.add('is-invalid');
  } else if (behW < 0) {
    hasNegative = true;
    if (behInput) behInput.classList.add('is-invalid');
  } else if (behW > 1.0) {
    hasOutOfRange = true;
    if (behInput) behInput.classList.add('is-invalid');
  } else {
    if (behInput) behInput.classList.remove('is-invalid');
  }

  if (hasNaN) {
    if (sumBadge && statusBox) {
      sumBadge.className = 'badge bg-danger-subtle text-danger fw-bold';
      sumBadge.innerHTML = '<i class="bi bi-exclamation-triangle-fill me-1"></i>Please enter valid numbers [0.0 - 1.0]';
      statusBox.style.background = 'rgba(239, 68, 68, 0.08)';
      statusBox.style.borderColor = 'rgba(239, 68, 68, 0.25)';
    }
    if (submitBtn) submitBtn.disabled = true;
    if (scoreElem) scoreElem.innerText = '0.000';
    return;
  }

  if (hasNegative) {
    if (sumBadge && statusBox) {
      sumBadge.className = 'badge bg-danger-subtle text-danger fw-bold';
      sumBadge.innerHTML = '<i class="bi bi-slash-circle-fill me-1"></i>No negative numbers allowed [0.0 - 1.0]!';
      statusBox.style.background = 'rgba(239, 68, 68, 0.08)';
      statusBox.style.borderColor = 'rgba(239, 68, 68, 0.25)';
    }
    if (submitBtn) submitBtn.disabled = true;
    if (scoreElem) scoreElem.innerText = 'Invalid';
    return;
  }

  if (hasOutOfRange) {
    if (sumBadge && statusBox) {
      sumBadge.className = 'badge bg-danger-subtle text-danger fw-bold';
      sumBadge.innerHTML = '<i class="bi bi-exclamation-triangle-fill me-1"></i>Values cannot exceed 1.0!';
      statusBox.style.background = 'rgba(239, 68, 68, 0.08)';
      statusBox.style.borderColor = 'rgba(239, 68, 68, 0.25)';
    }
    if (submitBtn) submitBtn.disabled = true;
    if (scoreElem) scoreElem.innerText = 'Invalid';
    return;
  }

  const sum = Math.round((simW + behW) * 1000) / 1000;
  const isValid = Math.abs(sum - 1.0) <= 0.001;

  if (sumBadge && statusBox) {
    if (isValid) {
      sumBadge.className = 'badge bg-success-subtle text-success fw-bold';
      sumBadge.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i>Total: ' + sum.toFixed(2) + ' (Valid)';
      statusBox.style.background = 'rgba(16, 185, 129, 0.08)';
      statusBox.style.borderColor = 'rgba(16, 185, 129, 0.25)';
      if (submitBtn) submitBtn.disabled = false;
    } else {
      sumBadge.className = 'badge bg-danger-subtle text-danger fw-bold';
      sumBadge.innerHTML = '<i class="bi bi-exclamation-triangle-fill me-1"></i>Total: ' + sum.toFixed(2) + ' (Must equal 1.0)';
      statusBox.style.background = 'rgba(239, 68, 68, 0.08)';
      statusBox.style.borderColor = 'rgba(239, 68, 68, 0.25)';
      if (submitBtn) submitBtn.disabled = true;
    }
  }

  // Calculate sample Final Score (Sample: S_sim = 0.90, S_beh = 0.85)
  const score = (simW * 0.90) + (behW * 0.85);
  if (scoreElem) scoreElem.innerText = score.toFixed(4);
}

// Client-side validation before submitting AI config
function validateAIConfigForm(e) {
  const simInput = document.getElementById('simWeightInput');
  const behInput = document.getElementById('behWeightInput');
  const minInput = document.getElementById('minSimilarityThresholdInput');
  const topKInput = document.getElementById('topKLimitInput');

  const simW = parseFloat(simInput ? simInput.value : '');
  const behW = parseFloat(behInput ? behInput.value : '');
  const minTh = parseFloat(minInput ? minInput.value : '');
  const topK = parseInt(topKInput ? topKInput.value : '');

  if (isNaN(simW) || simW < 0.0 || simW > 1.0) {
    alert('Validation Error: Similarity Weight must be a number between 0.0 and 1.0 (No negative numbers)!');
    if (simInput) { simInput.focus(); simInput.classList.add('is-invalid'); }
    if (e && e.preventDefault) e.preventDefault();
    return false;
  }
  if (isNaN(behW) || behW < 0.0 || behW > 1.0) {
    alert('Validation Error: Behavior Weight must be a number between 0.0 and 1.0 (No negative numbers)!');
    if (behInput) { behInput.focus(); behInput.classList.add('is-invalid'); }
    if (e && e.preventDefault) e.preventDefault();
    return false;
  }
  const sum = Math.round((simW + behW) * 1000) / 1000;
  if (Math.abs(sum - 1.0) > 0.001) {
    alert('Validation Error: The sum of Similarity Weight (' + simW + ') and Behavior Weight (' + behW + ') is ' + sum + '. It must equal 1.0 (e.g. 0.7 and 0.3)!');
    if (e && e.preventDefault) e.preventDefault();
    return false;
  }
  if (isNaN(minTh) || minTh < 0.0 || minTh > 1.0) {
    alert('Validation Error: Minimum Similarity Threshold must be a number between 0.0 and 1.0 (No negative numbers)!');
    if (minInput) { minInput.focus(); minInput.classList.add('is-invalid'); }
    if (e && e.preventDefault) e.preventDefault();
    return false;
  }
  if (isNaN(topK) || topK < 1 || topK > 50) {
    alert('Validation Error: Max Recommendations (Top K) must be an integer between 1 and 50!');
    if (topKInput) { topKInput.focus(); topKInput.classList.add('is-invalid'); }
    if (e && e.preventDefault) e.preventDefault();
    return false;
  }
  return true;
}

// Chart.js initialization function
function initAITypeChart(typeLabels, totalData, clickedData, purchasedData) {
  const chartCanvas = document.getElementById('aiTypeChart');
  if (!chartCanvas) return;
  const ctx = chartCanvas.getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: (typeLabels && typeLabels.length > 0) ? typeLabels : ['SIMILAR', 'PERSONALIZED', 'TRENDING', 'BEST_SELLER', 'COLD_START'],
      datasets: [
        {
          label: 'Total Recommendations',
          data: (totalData && totalData.length > 0) ? totalData : [1, 2, 0, 1, 1],
          backgroundColor: 'rgba(37, 99, 235, 0.75)',
          borderColor: '#2563eb',
          borderWidth: 1,
          borderRadius: 4
        },
        {
          label: 'Clicks',
          data: (clickedData && clickedData.length > 0) ? clickedData : [1, 1, 0, 1, 0],
          backgroundColor: 'rgba(2, 132, 199, 0.75)',
          borderColor: '#0284c7',
          borderWidth: 1,
          borderRadius: 4
        },
        {
          label: 'Purchases',
          data: (purchasedData && purchasedData.length > 0) ? purchasedData : [1, 1, 0, 0, 0],
          backgroundColor: 'rgba(15, 118, 110, 0.75)',
          borderColor: '#0f766e',
          borderWidth: 1,
          borderRadius: 4
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top',
          labels: { font: { weight: 'bold', size: 11 } }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: { precision: 0 }
        }
      }
    }
  });
}

// Client-side Date Range Validation & dd/mm/yyyy Synchronization
function formatToDMY(isoDate) {
  if (!isoDate || isoDate.indexOf('-') === -1) return '';
  const parts = isoDate.split('-');
  if (parts.length === 3) {
    return parts[2] + '/' + parts[1] + '/' + parts[0];
  }
  return isoDate;
}

function formatLocalDate(d) {
  var year = d.getFullYear();
  var month = String(d.getMonth() + 1).padStart(2, '0');
  var day = String(d.getDate()).padStart(2, '0');
  return year + '-' + month + '-' + day;
}

function setQuickDate(type) {
  var now = new Date();
  var todayStr = formatLocalDate(now);
  var startStr = todayStr;
  var endStr = todayStr;

  if (type === 'today') {
    startStr = todayStr;
    endStr = todayStr;
  } else if (type === '7days') {
    var d7 = new Date();
    d7.setDate(now.getDate() - 6);
    startStr = formatLocalDate(d7);
    endStr = todayStr;
  } else if (type === 'month') {
    var firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
    startStr = formatLocalDate(firstDay);
    endStr = todayStr;
  }

  var startInput = document.getElementById('startDate');
  var endInput = document.getElementById('endDate');
  var startDisplay = document.getElementById('startDateDisplay');
  var endDisplay = document.getElementById('endDateDisplay');

  if (startInput) startInput.value = startStr;
  if (endInput) endInput.value = endStr;
  if (startDisplay) startDisplay.value = formatToDMY(startStr);
  if (endDisplay) endDisplay.value = formatToDMY(endStr);

  var form = document.getElementById('filterForm');
  if (form) form.submit();
}

function validateAIDates() {
  const startInput = document.getElementById('startDate');
  const endInput = document.getElementById('endDate');
  const startVal = startInput ? startInput.value : '';
  const endVal = endInput ? endInput.value : '';
  const today = new Date().toISOString().split('T')[0];

  if (startVal && startVal > today) {
    alert('Validation Error: "From Date" cannot be in the future!');
    startInput.value = '';
    startInput.focus();
    return false;
  }

  if (endVal && endVal > today) {
    alert('Validation Error: "To Date" cannot be in the future!');
    endInput.value = '';
    endInput.focus();
    return false;
  }

  if (startVal && endVal && startVal > endVal) {
    alert('Validation Error: "From Date" cannot be later than "To Date"!');
    startInput.focus();
    return false;
  }

  return true;
}

document.addEventListener('DOMContentLoaded', function() {
  initThemeToggle();
  updateScoreSimulator();

  const filterForm = document.getElementById('filterForm');
  const startInput = document.getElementById('startDate');
  const endInput = document.getElementById('endDate');
  const startDisplay = document.getElementById('startDateDisplay');
  const endDisplay = document.getElementById('endDateDisplay');

  if (startInput && startDisplay) {
    startDisplay.value = formatToDMY(startInput.value);
    startInput.addEventListener('input', function() {
      startDisplay.value = formatToDMY(this.value);
    });
    startDisplay.addEventListener('click', function() {
      if (startInput.showPicker) {
        startInput.showPicker();
      } else {
        startInput.focus();
      }
    });
  }

  if (endInput && endDisplay) {
    endDisplay.value = formatToDMY(endInput.value);
    endInput.addEventListener('input', function() {
      endDisplay.value = formatToDMY(this.value);
    });
    endDisplay.addEventListener('click', function() {
      if (endInput.showPicker) {
        endInput.showPicker();
      } else {
        endInput.focus();
      }
    });
  }

  if (filterForm) {
    filterForm.addEventListener('submit', function(e) {
      if (!validateAIDates()) {
        e.preventDefault();
      }
    });
  }

  if (startInput) {
    startInput.addEventListener('change', function() {
      if (startDisplay) startDisplay.value = formatToDMY(this.value);
      if (this.value && endInput && endInput.value && this.value > endInput.value) {
        alert('Validation Error: "From Date" cannot be later than "To Date"!');
        this.value = '';
        if (startDisplay) startDisplay.value = '';
      }
    });
  }

  if (endInput) {
    endInput.addEventListener('change', function() {
      if (endDisplay) endDisplay.value = formatToDMY(this.value);
      if (this.value && startInput && startInput.value && this.value < startInput.value) {
        alert('Validation Error: "To Date" cannot be earlier than "From Date"!');
        this.value = '';
        if (endDisplay) endDisplay.value = '';
      }
    });
  }

  const minThresholdInput = document.getElementById('minSimilarityThresholdInput');
  if (minThresholdInput) {
    minThresholdInput.addEventListener('input', function() {
      const v = parseFloat(this.value);
      if (v < 0 || v > 1.0) {
        this.classList.add('is-invalid');
      } else {
        this.classList.remove('is-invalid');
      }
    });
  }

  const topKInput = document.getElementById('topKLimitInput');
  if (topKInput) {
    topKInput.addEventListener('input', function() {
      const v = parseInt(this.value);
      if (v < 1 || v > 50) {
        this.classList.add('is-invalid');
      } else {
        this.classList.remove('is-invalid');
      }
    });
  }
});


    document.addEventListener('DOMContentLoaded', function() {
      const typeLabels = [
        <c:forEach var="item" items="${byType}" varStatus="status">'${item.recommendationType}'${!status.last ? ',' : ''}</c:forEach>
      ];
      const totalData = [
        <c:forEach var="item" items="${byType}" varStatus="status">${item.totalCount}${!status.last ? ',' : ''}</c:forEach>
      ];
      const clickedData = [
        <c:forEach var="item" items="${byType}" varStatus="status">${item.clickedCount}${!status.last ? ',' : ''}</c:forEach>
      ];
      const purchasedData = [
        <c:forEach var="item" items="${byType}" varStatus="status">${item.purchasedCount}${!status.last ? ',' : ''}</c:forEach>
      ];
      initAITypeChart(typeLabels, totalData, clickedData, purchasedData);
    });
  </script>
</body>
</html>