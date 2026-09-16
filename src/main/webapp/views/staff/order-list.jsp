<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Staff - Quản Lý Đơn Hàng | Headphone Store</title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Custom stlylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />

    <style>
        .filter-box {
            background: #FBFBFC;
            border: 1px solid #E4E6EB;
            border-radius: 4px;
            padding: 15px;
            margin-bottom: 20px;
        }
        .order-table th {
            background-color: #1E1F29;
            color: #FFFFFF;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
        }
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .status-pending { background-color: #f0ad4e; color: #fff; }
        .status-confirmed { background-color: #5bc0de; color: #fff; }
        .status-shipping { background-color: #337ab7; color: #fff; }
        .status-delivered { background-color: #5cb85c; color: #fff; }
        .status-cancelled { background-color: #d9534f; color: #fff; }
        
        .price-text {
            color: #D10024;
            font-weight: 700;
        }

        .stat-card-box {
            background: #FFFFFF;
            border: 1px solid #E4E6EB;
            border-radius: 6px;
            padding: 15px 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.03);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .stat-card-box .stat-num {
            font-size: 24px;
            font-weight: 700;
            margin-top: 5px;
        }
        .stat-card-box .stat-label {
            font-size: 11px;
            text-transform: uppercase;
            color: #8D99AE;
            font-weight: 600;
            letter-spacing: 0.5px;
        }
        .stat-card-box.pending { border-left: 4px solid #f0ad4e; }
        .stat-card-box.confirmed { border-left: 4px solid #5bc0de; }
        .stat-card-box.shipping { border-left: 4px solid #337ab7; }
        .stat-card-box.delivered { border-left: 4px solid #5cb85c; }
        
        .stat-card-box.pending .stat-num { color: #f0ad4e; }
        .stat-card-box.confirmed .stat-num { color: #5bc0de; }
        .stat-card-box.shipping .stat-num { color: #337ab7; }
        .stat-card-box.delivered .stat-num { color: #5cb85c; }

        .btn-quick-action {
            display: inline-block;
            margin-right: 4px;
            padding: 5px 10px;
            font-size: 11px;
            font-weight: bold;
            border-radius: 3px;
            border: none;
            color: white;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-quick-action:hover { opacity: 0.85; transform: translateY(-1px); }
        .btn-quick-confirm { background-color: #5bc0de; }
        .btn-quick-shipping { background-color: #337ab7; }
        .btn-quick-deliver { background-color: #5cb85c; }
        .btn-quick-cancel { background-color: #d9534f; }
    </style>
</head>
<body>
    <!-- HEADER -->
    <header>
        <!-- TOP HEADER -->
        <div id="top-header">
            <div class="container">
                <ul class="header-links pull-left">
                    <li><a href="#"><i class="fa fa-phone"></i> +021-95-51-84</a></li>
                    <li><a href="#"><i class="fa fa-envelope-o"></i> staff@headphonestore.com</a></li>
                    <li><a href="#"><i class="fa fa-user-circle"></i> Staff Portal</a></li>
                </ul>
                <ul class="header-links pull-right">
                    <li><a href="${pageContext.request.contextPath}/home"><i class="fa fa-sign-out"></i> Back to Store</a></li>
                </ul>
            </div>
        </div>
        <!-- /TOP HEADER -->

        <!-- MAIN HEADER -->
        <div id="header">
            <div class="container">
                <div class="row">
                    <!-- LOGO -->
                    <div class="col-md-3">
                        <div class="header-logo">
                            <a href="${pageContext.request.contextPath}/home" class="logo">
                                <img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="Headphone Store Logo">
                            </a>
                        </div>
                    </div>
                    <!-- /LOGO -->

                    <div class="col-md-9 text-right" style="padding-top: 15px;">
                        <h4 style="color: #FFF; margin: 0;"><i class="fa fa-tasks"></i> STAFF DASHBOARD</h4>
                        <small style="color: #B9BABC;">Order Management & Processing System</small>
                    </div>
                </div>
            </div>
        </div>
        <!-- /MAIN HEADER -->
    </header>
    <!-- /HEADER -->

    <!-- NAVIGATION -->
    <nav id="navigation">
        <div class="container">
            <div id="responsive-nav">
                <ul class="main-nav nav navbar-nav">
                    <li class="active"><a href="${pageContext.request.contextPath}/staff/orders"><i class="fa fa-list-alt"></i> Order List</a></li>
                    <li><a href="#"><i class="fa fa-archive"></i> Inventory Management</a></li>
                    <li><a href="#"><i class="fa fa-tags"></i> Vouchers</a></li>
                    <li><a href="${pageContext.request.contextPath}/home"><i class="fa fa-shopping-cart"></i> Customer View</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <!-- /NAVIGATION -->

    <!-- BREADCRUMB -->
    <div id="breadcrumb" class="section">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <ul class="breadcrumb-tree">
                        <li><a href="${pageContext.request.contextPath}/home">Home</a></li>
                        <li><a href="#">Staff Portal</a></li>
                        <li class="active">Order Management</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <!-- /BREADCRUMB -->

    <!-- MAIN SECTION -->
    <div class="section" style="padding-top: 0;">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <div class="section-title">
                        <h3 class="title">Danh Sách Đơn Hàng Chờ Xử Lý (Staff)</h3>
                    </div>

                    <!-- Stat Summary Cards -->
                    <div class="row">
                        <div class="col-md-3 col-xs-6">
                            <div class="stat-card-box pending">
                                <div>
                                    <div class="stat-label">Chờ Xác Nhận</div>
                                    <div class="stat-num">${pendingCount != null ? pendingCount : 0}</div>
                                </div>
                                <i class="fa fa-clock-o fa-2x" style="color: #f0ad4e;"></i>
                            </div>
                        </div>
                        <div class="col-md-3 col-xs-6">
                            <div class="stat-card-box confirmed">
                                <div>
                                    <div class="stat-label">Đã Xác Nhận</div>
                                    <div class="stat-num">${confirmedCount != null ? confirmedCount : 0}</div>
                                </div>
                                <i class="fa fa-check-square-o fa-2x" style="color: #5bc0de;"></i>
                            </div>
                        </div>
                        <div class="col-md-3 col-xs-6">
                            <div class="stat-card-box shipping">
                                <div>
                                    <div class="stat-label">Đang Vận Chuyển</div>
                                    <div class="stat-num">${shippingCount != null ? shippingCount : 0}</div>
                                </div>
                                <i class="fa fa-truck fa-2x" style="color: #337ab7;"></i>
                            </div>
                        </div>
                        <div class="col-md-3 col-xs-6">
                            <div class="stat-card-box delivered">
                                <div>
                                    <div class="stat-label">Đã Hoàn Tất</div>
                                    <div class="stat-num">${deliveredCount != null ? deliveredCount : 0}</div>
                                </div>
                                <i class="fa fa-check-circle fa-2x" style="color: #5cb85c;"></i>
                            </div>
                        </div>
                    </div>

                    <!-- Alert Notification -->
                    <c:if test="${not empty sessionScope.msgSuccess}">
                        <div class="alert alert-success alert-dismissible" role="alert" style="margin-bottom: 20px;">
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                            <i class="fa fa-check-circle"></i> <strong>Thành công!</strong> Đã cập nhật đơn hàng <strong>#ORD-${sessionScope.msgSuccessOrderId}</strong> sang trạng thái: <strong>${sessionScope.msgSuccessStatus}</strong>
                        </div>
                        <% 
                            session.removeAttribute("msgSuccess"); 
                            session.removeAttribute("msgSuccessOrderId"); 
                            session.removeAttribute("msgSuccessStatus"); 
                        %>
                    </c:if>

                    <!-- Filter Box -->
                    <div class="filter-box">
                        <div class="row">
                            <form method="get" action="${pageContext.request.contextPath}/staff/orders" id="filterForm">
                                <div class="col-md-4">
                                    <label>Lọc theo trạng thái:</label>
                                    <select name="status" class="input-select input" style="width: 100%;" onchange="document.getElementById('filterForm').submit()">
                                        <option value="ALL" ${selectedStatus == 'ALL' || empty selectedStatus ? 'selected' : ''}>-- Tất cả trạng thái --</option>
                                        <option value="PENDING" ${selectedStatus == 'PENDING' ? 'selected' : ''}>Chờ xác nhận (PENDING)</option>
                                        <option value="CONFIRMED" ${selectedStatus == 'CONFIRMED' ? 'selected' : ''}>Đã xác nhận (CONFIRMED)</option>
                                        <option value="SHIPPING" ${selectedStatus == 'SHIPPING' ? 'selected' : ''}>Đang vận chuyển (SHIPPING)</option>
                                        <option value="DELIVERED" ${selectedStatus == 'DELIVERED' ? 'selected' : ''}>Đã giao hàng (DELIVERED)</option>
                                        <option value="CANCELLED" ${selectedStatus == 'CANCELLED' ? 'selected' : ''}>Đã hủy (CANCELLED)</option>
                                    </select>
                                </div>
                                <div class="col-md-5">
                                    <label>Tìm kiếm nhanh:</label>
                                    <input type="text" id="searchInput" class="input" placeholder="Nhập Mã đơn, Tên người nhận hoặc Số điện thoại...">
                                </div>
                                <div class="col-md-3 text-right" style="padding-top: 24px;">
                                    <button type="button" onclick="window.location.reload();" class="primary-btn" style="padding: 10px 20px;">
                                        <i class="fa fa-refresh"></i> Tải lại
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- Orders Table -->
                    <div class="table-responsive">
                        <table class="table table-striped table-bordered order-table" id="ordersTable">
                            <thead>
                                <tr>
                                    <th class="text-center">Mã Đơn</th>
                                    <th>Khách Hàng / Người Nhận</th>
                                    <th>Số Điện Thoại</th>
                                    <th>Địa Chỉ Giao Hàng</th>
                                    <th class="text-right">Tổng Tiền</th>
                                    <th>Ngày Đặt</th>
                                    <th class="text-center">Trạng Thái</th>
                                    <th class="text-center">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="o" items="${orders}">
                                    <tr>
                                        <td class="text-center"><b>#ORD-${o.orderID}</b></td>
                                        <td>
                                            <b>${o.shippingName}</b>
                                        </td>
                                        <td><i class="fa fa-phone text-muted"></i> ${o.shippingPhone}</td>
                                        <td><i class="fa fa-map-marker text-danger"></i> ${o.shippingAddress}</td>
                                        <td class="text-right price-text">${o.formattedTotalAmount} VNĐ</td>
                                        <td><small><i class="fa fa-calendar"></i> ${o.formattedOrderDate}</small></td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${o.orderStatus == 'PENDING'}">
                                                    <span class="status-badge status-pending"><i class="fa fa-clock-o"></i> Chờ xử lý</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus == 'CONFIRMED'}">
                                                    <span class="status-badge status-confirmed"><i class="fa fa-check"></i> Đã xác nhận</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus == 'SHIPPING'}">
                                                    <span class="status-badge status-shipping"><i class="fa fa-truck"></i> Đang giao</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus == 'DELIVERED'}">
                                                    <span class="status-badge status-delivered"><i class="fa fa-check-circle"></i> Đã giao</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-cancelled"><i class="fa fa-times"></i> Đã hủy</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center" style="white-space: nowrap;">
                                            <c:choose>
                                                <c:when test="${o.orderStatus == 'PENDING'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/staff/orders" style="display:inline;">
                                                        <input type="hidden" name="action" value="updateStatus">
                                                        <input type="hidden" name="orderId" value="${o.orderID}">
                                                        <input type="hidden" name="newStatus" value="CONFIRMED">
                                                        <button type="submit" class="btn-quick-action btn-quick-confirm" title="Xác nhận đơn ngay">
                                                            <i class="fa fa-check"></i> Xác nhận
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/staff/orders" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn HỦY đơn hàng #ORD-${o.orderID} không?');">
                                                        <input type="hidden" name="action" value="updateStatus">
                                                        <input type="hidden" name="orderId" value="${o.orderID}">
                                                        <input type="hidden" name="newStatus" value="CANCELLED">
                                                        <button type="submit" class="btn-quick-action btn-quick-cancel" title="Hủy đơn hàng này">
                                                            <i class="fa fa-times"></i> Hủy
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${o.orderStatus == 'CONFIRMED'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/staff/orders" style="display:inline;">
                                                        <input type="hidden" name="action" value="updateStatus">
                                                        <input type="hidden" name="orderId" value="${o.orderID}">
                                                        <input type="hidden" name="newStatus" value="SHIPPING">
                                                        <button type="submit" class="btn-quick-action btn-quick-shipping" title="Chuyển sang giao hàng">
                                                            <i class="fa fa-truck"></i> Giao hàng
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/staff/orders" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn HỦY đơn hàng #ORD-${o.orderID} không?');">
                                                        <input type="hidden" name="action" value="updateStatus">
                                                        <input type="hidden" name="orderId" value="${o.orderID}">
                                                        <input type="hidden" name="newStatus" value="CANCELLED">
                                                        <button type="submit" class="btn-quick-action btn-quick-cancel" title="Hủy đơn hàng này">
                                                            <i class="fa fa-times"></i> Hủy
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${o.orderStatus == 'SHIPPING'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/staff/orders" style="display:inline;">
                                                        <input type="hidden" name="action" value="updateStatus">
                                                        <input type="hidden" name="orderId" value="${o.orderID}">
                                                        <input type="hidden" name="newStatus" value="DELIVERED">
                                                        <button type="submit" class="btn-quick-action btn-quick-deliver" title="Hoàn tất đơn hàng">
                                                            <i class="fa fa-check-circle"></i> Hoàn tất
                                                        </button>
                                                    </form>
                                                </c:when>
                                            </c:choose>

                                            <a href="${pageContext.request.contextPath}/staff/order-detail?id=${o.orderID}" class="primary-btn" style="padding: 5px 10px; font-size: 11px;">
                                                <i class="fa fa-eye"></i> Chi tiết
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty orders}">
                                    <tr>
                                        <td colspan="8" class="text-center" style="padding: 30px 0; color: #8D99AE;">
                                            <i class="fa fa-folder-open-o fa-2x"></i>
                                            <p style="margin-top: 10px;">Chưa có đơn hàng nào trong hệ thống!</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                </div>
            </div>
        </div>
    </div>
    <!-- /MAIN SECTION -->

    <!-- FOOTER -->
    <footer id="footer">
        <div class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-3 col-xs-6">
                        <div class="footer">
                            <h3 class="footer-title">About Us</h3>
                            <p>Headphone Store - Trang quản trị và xử lý đơn hàng dành cho Nhân viên.</p>
                            <ul class="footer-links">
                                <li><a href="#"><i class="fa fa-map-marker"></i>1734 Stonecoal Road</a></li>
                                <li><a href="#"><i class="fa fa-phone"></i>+021-95-51-84</a></li>
                                <li><a href="#"><i class="fa fa-envelope-o"></i>staff@headphonestore.com</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="bottom-footer" class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12 text-center">
                        <span class="copyright">
                            Copyright &copy;<script>document.write(new Date().getFullYear());</script> All rights reserved | Headphone Store System
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </footer>
    <!-- /FOOTER -->

    <!-- jQuery Plugins -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    
    <!-- Real-time Table Filter -->
    <script>
        document.getElementById('searchInput').addEventListener('keyup', function() {
            var filter = this.value.toLowerCase();
            var rows = document.querySelectorAll('#ordersTable tbody tr');
            rows.forEach(function(row) {
                var text = row.innerText.toLowerCase();
                row.style.display = text.indexOf(filter) > -1 ? '' : 'none';
            });
        });
    </script>
</body>
</html>