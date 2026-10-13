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
    .ai-card-icon {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.5rem;
    }
    .bg-ai-primary { background: rgba(37, 99, 235, 0.12); color: #2563eb; }
    .bg-ai-success { background: rgba(15, 118, 110, 0.12); color: #0f766e; }
    .bg-ai-warning { background: rgba(217, 119, 6, 0.12); color: #d97706; }
    .bg-ai-purple { background: rgba(147, 51, 234, 0.12); color: #9333ea; }
    .bg-ai-info { background: rgba(2, 132, 199, 0.12); color: #0284c7; }
    .chart-container {
      position: relative;
      height: 320px;
      width: 100%;
    }
    .progress-bar-custom {
      height: 8px;
      border-radius: 4px;
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
        <a class="nav-link" href="${pageContext.request.contextPath}/staff/orders">
          <span class="nav-icon"><i class="bi bi-table"></i></span>
          <span class="nav-text">Order Management</span>
        </a>
        <a class="nav-link" href="${pageContext.request.contextPath}/home">
          <span class="nav-icon"><i class="bi bi-shop"></i></span>
          <span class="nav-text">Customer Store</span>
        </a>
      </nav>
    </aside>

    <!-- MAIN CONTENT AREA -->
    <div class="admin-main">
      <!-- TOP NAVBAR -->
      <nav class="navbar admin-navbar navbar-expand bg-white border-bottom shadow-sm">
        <div class="container-fluid px-3">
          <span class="navbar-text fw-bold text-dark fs-6">
            <i class="bi bi-sliders text-primary me-2"></i>Báo cáo Hiệu suất & Cấu hình Hệ thống AI
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
            <i class="bi bi-exclamation-triangle-fill me-2"></i><strong>Lỗi: </strong><c:out value="${not empty msgError ? msgError : sessionScope.msgError}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
          </div>
        </c:if>

        <c:if test="${not empty msgSuccess || not empty sessionScope.msgSuccess}">
          <div class="alert alert-success alert-dismissible fade show shadow-sm mb-3" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i><strong>Thành công: </strong><c:out value="${not empty msgSuccess ? msgSuccess : sessionScope.msgSuccess}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
          </div>
        </c:if>

        <!-- PAGE HEADING & FILTER FORM -->
        <div class="panel mb-4">
          <form method="get" action="${pageContext.request.contextPath}/admin/ai-performance" class="row g-3 align-items-end">
            <div class="col-12 col-md-3">
              <label class="form-label fw-semibold text-muted small"><i class="bi bi-calendar-event me-1"></i>Từ Ngày (From Date)</label>
              <input type="date" class="form-control form-control-sm" name="startDate" value="${selectedStartDate}">
            </div>
            <div class="col-12 col-md-3">
              <label class="form-label fw-semibold text-muted small"><i class="bi bi-calendar-check me-1"></i>Đến Ngày (To Date)</label>
              <input type="date" class="form-control form-control-sm" name="endDate" value="${selectedEndDate}">
            </div>
            <div class="col-12 col-md-3">
              <label class="form-label fw-semibold text-muted small"><i class="bi bi-funnel me-1"></i>Loại AI Recommendation</label>
              <select class="form-select form-select-sm" name="type">
                <option value="ALL" ${selectedType == 'ALL' ? 'selected' : ''}>Tất cả các loại (All Types)</option>
                <option value="SIMILAR" ${selectedType == 'SIMILAR' ? 'selected' : ''}>SIMILAR (Tương tự sản phẩm)</option>
                <option value="PERSONALIZED" ${selectedType == 'PERSONALIZED' ? 'selected' : ''}>PERSONALIZED (Cá nhân hóa)</option>
                <option value="TRENDING" ${selectedType == 'TRENDING' ? 'selected' : ''}>TRENDING (Xu hướng)</option>
                <option value="BEST_SELLER" ${selectedType == 'BEST_SELLER' ? 'selected' : ''}>BEST_SELLER (Bán chạy)</option>
                <option value="COLD_START" ${selectedType == 'COLD_START' ? 'selected' : ''}>COLD_START (Khách mới/Khách ẩn danh)</option>
              </select>
            </div>
            <div class="col-12 col-md-3 d-flex gap-2">
              <button type="submit" class="btn btn-primary btn-sm flex-fill fw-bold">
                <i class="bi bi-search me-1"></i>Lọc dữ liệu
              </button>
              <a href="${pageContext.request.contextPath}/admin/ai-performance" class="btn btn-outline-secondary btn-sm" title="Làm mới">
                <i class="bi bi-arrow-clockwise"></i>
              </a>
              <a href="${pageContext.request.contextPath}/admin/ai-performance?action=export&startDate=${selectedStartDate}&endDate=${selectedEndDate}&type=${selectedType}" 
                 class="btn btn-success btn-sm fw-bold" title="Xuất báo cáo CSV Excel">
                <i class="bi bi-file-earmark-excel me-1"></i>Export CSV
              </a>
            </div>
          </form>
        </div>

        <!-- KPI METRIC CARDS ROW (5 COLUMNS) -->
        <div class="row row-cols-1 row-cols-sm-2 row-cols-xl-5 g-3 mb-4">
          <!-- Card 1: Total Recommendations -->
          <div class="col">
            <div class="metric-card metric-primary">
              <div class="metric-top">
                <span class="metric-label">Tổng Gợi ý AI</span>
                <div class="metric-icon"><i class="bi bi-cpu"></i></div>
              </div>
              <div class="metric-value">
                <fmt:formatNumber value="${summary.totalRecommendations}" type="number" />
              </div>
              <div class="small text-muted mt-2">
                <i class="bi bi-info-circle me-1"></i>Lượt gợi ý đã phát hành
              </div>
            </div>
          </div>

          <!-- Card 2: Click-Through Rate (CTR) -->
          <div class="col">
            <div class="metric-card metric-info">
              <div class="metric-top">
                <span class="metric-label">Tỷ lệ Click (CTR)</span>
                <div class="metric-icon"><i class="bi bi-cursor"></i></div>
              </div>
              <div class="metric-value text-info">
                ${summary.ctrRate}%
              </div>
              <div class="small text-muted mt-2">
                <i class="bi bi-hand-index-thumb me-1"></i>${summary.totalClicked} lượt Click
              </div>
            </div>
          </div>

          <!-- Card 3: Conversion Rate -->
          <div class="col">
            <div class="metric-card metric-success">
              <div class="metric-top">
                <span class="metric-label">Tỷ lệ Chuyển đổi</span>
                <div class="metric-icon"><i class="bi bi-bag-check"></i></div>
              </div>
              <div class="metric-value text-success">
                ${summary.conversionRate}%
              </div>
              <div class="small text-muted mt-2">
                <i class="bi bi-cart-check me-1"></i>${summary.totalPurchased} lượt Mua hàng
              </div>
            </div>
          </div>

          <!-- Card 4: Avg Similarity Score -->
          <div class="col">
            <div class="metric-card metric-warning">
              <div class="metric-top">
                <span class="metric-label">Điểm Tương đồng (Avg)</span>
                <div class="metric-icon"><i class="bi bi-diagram-3"></i></div>
              </div>
              <div class="metric-value text-warning">
                ${summary.avgSimilarityScore}
              </div>
              <div class="small text-muted mt-2">
                <i class="bi bi-sliders me-1"></i>Mức tương đồng sản phẩm
              </div>
            </div>
          </div>

          <!-- Card 5: Avg Final Score -->
          <div class="col">
            <div class="metric-card metric-danger">
              <div class="metric-top">
                <span class="metric-label">Điểm Tin cậy Tổng</span>
                <div class="metric-icon"><i class="bi bi-stars"></i></div>
              </div>
              <div class="metric-value text-danger">
                ${summary.avgFinalScore}
              </div>
              <div class="small text-muted mt-2">
                <i class="bi bi-graph-up me-1"></i>Final Recommendation Score
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
                <h6 class="fw-bold m-0"><i class="bi bi-bar-chart-steps text-primary me-2"></i>Phân bố Hiệu suất theo Thuật toán Gợi ý AI</h6>
                <span class="badge bg-primary-subtle text-primary fw-bold">By Recommendation Type</span>
              </div>
              <div class="chart-container">
                <canvas id="aiTypeChart"></canvas>
              </div>
            </div>
          </div>

          <!-- AI MODEL CONFIGURATION FORM (Cấu hình AI) -->
          <div class="col-12 col-xl-5">
            <div class="panel h-100">
              <div class="panel-header">
                <h6 class="fw-bold m-0 text-primary"><i class="bi bi-sliders2-vertical me-2"></i>Cấu hình Trọng số Thuật toán AI</h6>
                <span class="badge bg-success-subtle text-success fw-bold">Active Engine</span>
              </div>
              
              <form method="post" action="${pageContext.request.contextPath}/admin/ai-performance">
                <input type="hidden" name="action" value="updateConfig">
                
                <div class="config-box mb-3">
                  <div class="row g-2 mb-3">
                    <div class="col-6">
                      <label class="form-label small fw-bold text-muted mb-1">Trọng số Tương đồng ($w_{sim}$)</label>
                      <input type="number" step="0.05" min="0" max="1" class="form-control form-control-sm fw-bold text-primary" 
                             id="simWeightInput" name="similarityWeight" value="${aiConfig.similarityWeight}" oninput="updateScoreSimulator()">
                    </div>
                    <div class="col-6">
                      <label class="form-label small fw-bold text-muted mb-1">Trọng số Hành vi ($w_{beh}$)</label>
                      <input type="number" step="0.05" min="0" max="1" class="form-control form-control-sm fw-bold text-teal" 
                             id="behWeightInput" name="behaviorWeight" value="${aiConfig.behaviorWeight}" oninput="updateScoreSimulator()">
                    </div>
                  </div>

                  <div class="mb-3">
                    <label class="form-label small fw-bold text-muted mb-1">Ngưỡng Tương đồng Tối thiểu ($S_{min}$)</label>
                    <input type="number" step="0.05" min="0" max="1" class="form-control form-control-sm" 
                           name="minSimilarityThreshold" value="${aiConfig.minSimilarityThreshold}">
                    <div class="form-text extra-small text-muted">Lọc bỏ gợi ý có độ tương đồng dưới ngưỡng này.</div>
                  </div>

                  <div class="row g-2 mb-3">
                    <div class="col-6">
                      <label class="form-label small fw-bold text-muted mb-1">Số lượng Gợi ý (Top K)</label>
                      <input type="number" min="1" max="50" class="form-control form-control-sm" 
                             name="topKLimit" value="${aiConfig.topKLimit}">
                    </div>
                    <div class="col-6">
                      <label class="form-label small fw-bold text-muted mb-1">Thuật toán Cold Start</label>
                      <select class="form-select form-select-sm" name="fallbackStrategy">
                        <option value="COLD_START" ${aiConfig.fallbackStrategy == 'COLD_START' ? 'selected' : ''}>COLD_START (Phổ biến)</option>
                        <option value="BEST_SELLER" ${aiConfig.fallbackStrategy == 'BEST_SELLER' ? 'selected' : ''}>BEST_SELLER (Bán chạy)</option>
                      </select>
                    </div>
                  </div>
                </div>

                <!-- Score Simulator Preview -->
                <div class="simulator-box mb-3">
                  <div class="d-flex align-items-center justify-content-between mb-2">
                    <span class="small fw-bold text-dark"><i class="bi bi-calculator me-1"></i>Mô phỏng Điểm Final Score:</span>
                    <span class="badge bg-primary" id="simScoreResult">0.875</span>
                  </div>
                  <div class="extra-small text-muted">
                    $$\text{FinalScore} = (w_{sim} \times 0.90) + (w_{beh} \times 0.85)$$
                  </div>
                </div>

                <button type="submit" class="btn btn-primary btn-sm w-100 fw-bold shadow-sm">
                  <i class="bi bi-floppy-fill me-1"></i>Lưu Cấu hình & Cập nhật AI Engine
                </button>
              </form>
            </div>
          </div>
        </div>

        <!-- TOP RECOMMENDED PRODUCTS TABLE -->
        <div class="panel mb-4">
          <div class="panel-header">
            <h6 class="fw-bold m-0"><i class="bi bi-trophy-fill text-warning me-2"></i>Top Sản phẩm được AI Gợi ý nhiều nhất</h6>
            <span class="badge bg-secondary-subtle text-secondary fw-bold">Performance Matrix</span>
          </div>

          <div class="table-responsive">
            <table class="table table-hover align-middle table-orders mb-0">
              <thead class="table-light">
                <tr>
                  <th style="width: 50px;">ID</th>
                  <th>Tên Sản Phẩm</th>
                  <th>Danh Mục</th>
                  <th>Thương Hiệu</th>
                  <th class="text-end">Đơn Giá (VND)</th>
                  <th class="text-center">Số Lượt Gợi Ý</th>
                  <th class="text-center">Lượt Click</th>
                  <th class="text-center">Lượt Mua</th>
                  <th class="text-center">Tỷ Lệ CTR</th>
                  <th class="text-center">Tỷ Lệ Chuyển Đổi</th>
                  <th class="text-end">Score Trung Bình</th>
                </tr>
              </thead>
              <tbody>
                <c:choose>
                  <c:when test="${empty topProducts}">
                    <tr>
                      <td colspan="11" class="text-center text-muted py-4">Chưa có dữ liệu gợi ý sản phẩm trong khoảng thời gian này.</td>
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
                          <fmt:formatNumber value="${p.price}" type="number" />
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

        <!-- RECENT AI RECOMMENDATION LOGS & AUDIT LOGS ROW -->
        <div class="row g-3">
          <!-- RECENT RECOMMENDATIONS -->
          <div class="col-12 col-xl-8">
            <div class="panel">
              <div class="panel-header">
                <h6 class="fw-bold m-0"><i class="bi bi-journal-text text-primary me-2"></i>Nhật ký Gợi ý AI gần đây (Real-time AI Pipeline Logs)</h6>
                <span class="badge bg-info-subtle text-info fw-bold">Recent Logs</span>
              </div>
              <div class="table-responsive" style="max-height: 380px; overflow-y: auto;">
                <table class="table table-sm table-hover align-middle mb-0" style="font-size: 0.78rem;">
                  <thead class="table-light sticky-top">
                    <tr>
                      <th>Rec ID</th>
                      <th>Khách Hàng / Session</th>
                      <th>Sản Phẩm</th>
                      <th>Loại Gợi Ý</th>
                      <th class="text-center">Similarity</th>
                      <th class="text-center">Behavior</th>
                      <th class="text-center">Final Score</th>
                      <th class="text-center">Trạng Thái</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:choose>
                      <c:when test="${empty recentLogs}">
                        <tr>
                          <td colspan="8" class="text-center text-muted py-3">Chưa có nhật ký gợi ý nào.</td>
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
                            <td class="fw-bold text-dark" style="max-width: 160px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${item.productName}">
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
                                <span class="badge bg-info text-white" title="Customer Clicked"><i class="bi bi-cursor-fill"></i> Click</span>
                              </c:if>
                              <c:if test="${rec.purchased}">
                                <span class="badge bg-success text-white" title="Customer Purchased"><i class="bi bi-bag-check-fill"></i> Mua</span>
                              </c:if>
                              <c:if test="${!rec.clicked && !rec.purchased}">
                                <span class="badge bg-light text-muted border">Hiển thị</span>
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

          <!-- AI CONFIG AUDIT LOGS -->
          <div class="col-12 col-xl-4">
            <div class="panel">
              <div class="panel-header">
                <h6 class="fw-bold m-0"><i class="bi bi-shield-check text-success me-2"></i>Lịch sử Đổi Cấu hình (Audit Log)</h6>
                <span class="badge bg-success-subtle text-success fw-bold">Config Trace</span>
              </div>
              <div class="table-responsive" style="max-height: 380px; overflow-y: auto;">
                <table class="table table-sm align-middle mb-0" style="font-size: 0.75rem;">
                  <thead class="table-light sticky-top">
                    <tr>
                      <th>Hành Động</th>
                      <th>Quản Trị Viên</th>
                      <th>Chi Tiết Thay Đổi</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:choose>
                      <c:when test="${empty auditLogs}">
                        <tr>
                          <td colspan="3" class="text-center text-muted py-3">Chưa có lịch sử thay đổi cấu hình.</td>
                        </tr>
                      </c:when>
                      <c:otherwise>
                        <c:forEach var="log" items="${auditLogs}">
                          <tr>
                            <td>
                              <span class="badge bg-dark text-white">${log.action}</span>
                            </td>
                            <td class="fw-semibold text-dark">${log.userName}</td>
                            <td>
                              <div class="extra-small text-success fw-bold">${log.newData}</div>
                              <div class="extra-small text-muted" style="font-size: 0.68rem;">${log.createdAt}</div>
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
    </div>
  </div>

  <!-- Bootstrap 5 JS Bundle -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Chart.js & Theme Switcher Script -->
  <script>
    // Theme Toggle Script
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

    // Score Simulator Script
    function updateScoreSimulator() {
      const simW = parseFloat(document.getElementById('simWeightInput').value) || 0.5;
      const behW = parseFloat(document.getElementById('behWeightInput').value) || 0.5;
      const score = (simW * 0.90) + (behW * 0.85);
      document.getElementById('simScoreResult').innerText = score.toFixed(4);
    }
    updateScoreSimulator();

    // Chart.js - AI Recommendation Type Breakdown Chart
    const typeLabels = [
      <c:forEach var="item" items="${byType}" varStatus="status">
        '${item.recommendationType}'${!status.last ? ',' : ''}
      </c:forEach>
    ];

    const totalData = [
      <c:forEach var="item" items="${byType}" varStatus="status">
        ${item.totalCount}${!status.last ? ',' : ''}
      </c:forEach>
    ];

    const clickedData = [
      <c:forEach var="item" items="${byType}" varStatus="status">
        ${item.clickedCount}${!status.last ? ',' : ''}
      </c:forEach>
    ];

    const purchasedData = [
      <c:forEach var="item" items="${byType}" varStatus="status">
        ${item.purchasedCount}${!status.last ? ',' : ''}
      </c:forEach>
    ];

    const ctx = document.getElementById('aiTypeChart').getContext('2d');
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: typeLabels.length > 0 ? typeLabels : ['SIMILAR', 'PERSONALIZED', 'TRENDING', 'BEST_SELLER', 'COLD_START'],
        datasets: [
          {
            label: 'Tổng Gợi Ý',
            data: totalData.length > 0 ? totalData : [1, 2, 0, 1, 1],
            backgroundColor: 'rgba(37, 99, 235, 0.75)',
            borderColor: '#2563eb',
            borderWidth: 1,
            borderRadius: 4
          },
          {
            label: 'Lượt Click',
            data: clickedData.length > 0 ? clickedData : [1, 1, 0, 1, 0],
            backgroundColor: 'rgba(2, 132, 199, 0.75)',
            borderColor: '#0284c7',
            borderWidth: 1,
            borderRadius: 4
          },
          {
            label: 'Lượt Mua',
            data: purchasedData.length > 0 ? purchasedData : [1, 1, 0, 0, 0],
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
  </script>
</body>
</html>
