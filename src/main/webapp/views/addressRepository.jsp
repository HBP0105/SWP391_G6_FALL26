<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Address Repository - Headphone Store</title>

    <!-- Google font -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,500,700" rel="stylesheet">

    <!-- Bootstrap -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" />

    <!-- Font Awesome Icon -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/font-awesome.min.css">

    <!-- Main Stylesheet -->
    <link type="text/css" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css" />

    <style>
        .address-box {
            background: #fff;
            border: 1px solid #E4E7ED;
            border-radius: 4px;
            padding: 20px;
            margin-bottom: 15px;
        }
        .address-box.default-address {
            border-left: 3px solid #D10024;
        }
        .default-tag {
            display: inline-block;
            border: 1px solid #D10024;
            color: #D10024;
            font-size: 11px;
            font-weight: 600;
            padding: 1px 6px;
            margin-left: 8px;
        }
    </style>
</head>
<body>
    <!-- HEADER -->
    <header>
        <div id="top-header">
            <div class="container">
                <%@ page import="com.swp391.model.Customer" %>
                <%@ page import="com.swp391.model.Staff" %>
                <%
                    Object currentUser = session.getAttribute("customer");
                    if (currentUser == null) {
                        currentUser = session.getAttribute("user");
                    }
                    String displayPhone = "";
                    String displayEmail = "";
                    String displayName = "";
                    if (currentUser instanceof Customer) {
                        Customer c = (Customer) currentUser;
                        displayPhone = c.getPhone() != null ? c.getPhone() : "";
                        displayEmail = c.getEmail() != null ? c.getEmail() : "";
                        displayName = c.getFullName() != null ? c.getFullName() : "";
                    } else if (currentUser instanceof Staff) {
                        Staff s = (Staff) currentUser;
                        displayPhone = s.getPhone() != null ? s.getPhone() : "";
                        displayEmail = s.getEmail() != null ? s.getEmail() : "";
                        displayName = s.getFullName() != null ? s.getFullName() : "";
                    }
                %>
                <ul class="header-links pull-left">
                    <% if (!displayPhone.isEmpty()) { %>
                    <li><a href="#"><i class="fa fa-phone"></i> <%= displayPhone %></a></li>
                    <% } %>
                    <% if (!displayEmail.isEmpty()) { %>
                    <li><a href="#"><i class="fa fa-envelope-o"></i> <%= displayEmail %></a></li>
                    <% } %>
                </ul>
                <ul class="header-links pull-right">
                    <% if (currentUser == null) { %>
                    <li>
                        <a href="${pageContext.request.contextPath}/login">
                            <i class="fa fa-user-o"></i> My Account
                        </a>
                    </li>
                    <% } else { %>
                    <li>
                        <a href="${pageContext.request.contextPath}/profile">
                            <i class="fa fa-user"></i> <%= displayName %>
                        </a>
                    </li>
                    <% } %>
                </ul>
            </div>
        </div>

        <div id="header">
            <div class="container">
                <div class="row">
                    <div class="col-md-3">
                        <div class="header-logo">
                            <a href="${pageContext.request.contextPath}/home" class="logo">
                                <img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="Logo">
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </header>
    <!-- /HEADER -->

    <!-- NAVIGATION -->
    <nav id="navigation">
        <div class="container">
            <div id="responsive-nav">
                <ul class="main-nav nav navbar-nav">
                    <li><a href="${pageContext.request.contextPath}/home">Home</a></li>
                    <li><a href="${pageContext.request.contextPath}/my-orders">My Order</a></li>
                    <li class="active"><a href="${pageContext.request.contextPath}/addresses">Address Repository</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart">Cart</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <!-- /NAVIGATION -->

    <!-- ADDRESS REPOSITORY SECTION -->
    <div class="section" style="padding-top: 30px; padding-bottom: 60px;">
        <div class="container">
            <div class="row">
                <!-- Cột Trái: Form Thêm Địa Chỉ Mới -->
                <div class="col-md-5">
                    <div class="address-box">
                        <h4 style="margin-top: 0; margin-bottom: 20px;">Add New Address</h4>
                        <form action="${pageContext.request.contextPath}/addresses" method="POST">
                            <input type="hidden" name="action" value="add">
                            <div class="form-group">
                                <label>Receiver Name *</label>
                                <input type="text" class="form-control" name="receiverName" value="${sessionScope.customer.fullName}" required>
                            </div>
                            <div class="form-group">
                                <label>Receiver Phone *</label>
                                <input type="text" class="form-control" name="receiverPhone" value="${sessionScope.customer.phone}" required>
                            </div>
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>Province/City *</label>
                                        <input type="text" class="form-control" name="province" placeholder="Province" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>District *</label>
                                        <input type="text" class="form-control" name="district" placeholder="District" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>Ward *</label>
                                        <input type="text" class="form-control" name="ward" placeholder="Ward" required>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Address Line *</label>
                                <input type="text" class="form-control" name="addressLine" placeholder="Street name, house number" required>
                            </div>
                            <div class="checkbox" style="margin-bottom: 15px;">
                                <label>
                                    <input type="checkbox" name="isDefault" value="true"> Set as Default address
                                </label>
                            </div>
                            <button type="submit" class="primary-btn" style="width: 100%; border: none; border-radius: 4px;">
                                Save Address
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Cột Phải: Danh Sách Địa Chỉ Trong Kho -->
                <div class="col-md-7">
                    <h4 style="margin-top: 0; margin-bottom: 20px;">My Address Repository (${fn:length(requestScope.addresses)})</h4>

                    <c:if test="${empty requestScope.addresses}">
                        <div class="address-box text-center" style="padding: 40px 20px;">
                            <p class="text-muted" style="margin: 0;">You have no saved addresses in your repository yet.</p>
                        </div>
                    </c:if>

                    <c:forEach items="${requestScope.addresses}" var="addr">
                        <div class="address-box ${addr.isDefault ? 'default-address' : ''}">
                            <div class="row">
                                <div class="col-sm-8">
                                    <div style="margin-bottom: 6px;">
                                        <strong>${fn:escapeXml(addr.receiverName)}</strong>
                                        <span style="color: #999; margin: 0 6px;">|</span>
                                        <span>${fn:escapeXml(addr.receiverPhone)}</span>
                                        <c:if test="${addr.isDefault}">
                                            <span class="default-tag">Default</span>
                                        </c:if>
                                    </div>
                                    <p style="margin: 0; color: #555; font-size: 13px;">
                                        ${fn:escapeXml(addr.addressLine)}, ${fn:escapeXml(addr.ward)}, ${fn:escapeXml(addr.district)}, ${fn:escapeXml(addr.province)}
                                    </p>
                                </div>

                                <div class="col-sm-4 text-right">
                                    <div style="margin-bottom: 6px;">
                                        <button type="button" class="btn btn-default btn-xs"
                                                data-id="${addr.addressId}"
                                                data-name="${fn:escapeXml(addr.receiverName)}"
                                                data-phone="${fn:escapeXml(addr.receiverPhone)}"
                                                data-province="${fn:escapeXml(addr.province)}"
                                                data-district="${fn:escapeXml(addr.district)}"
                                                data-ward="${fn:escapeXml(addr.ward)}"
                                                data-line="${fn:escapeXml(addr.addressLine)}"
                                                data-default="${addr.isDefault}"
                                                onclick="openEditAddressModal(this)">
                                            Edit
                                        </button>
                                        <button type="button" class="btn btn-danger btn-xs"
                                                onclick="openDeleteAddressModal('${addr.addressId}')">
                                            Delete
                                        </button>
                                    </div>

                                    <c:if test="${!addr.isDefault}">
                                        <form action="${pageContext.request.contextPath}/addresses" method="POST" style="margin: 0;">
                                            <input type="hidden" name="action" value="setDefault">
                                            <input type="hidden" name="addressId" value="${addr.addressId}">
                                            <button type="submit" class="btn btn-default btn-xs">
                                                Set as Default
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </div>
    <!-- /ADDRESS REPOSITORY SECTION -->

    <!-- MODAL SỬA ĐỊA CHỈ -->
    <div id="editAddressModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/addresses" method="POST">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Edit Address</h4>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="addressId" id="edit_addressId">
                        <div class="form-group">
                            <label>Receiver Name *</label>
                            <input type="text" class="form-control" name="receiverName" id="edit_receiverName" required>
                        </div>
                        <div class="form-group">
                            <label>Receiver Phone *</label>
                            <input type="text" class="form-control" name="receiverPhone" id="edit_receiverPhone" required>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Province/City *</label>
                                    <input type="text" class="form-control" name="province" id="edit_province" required>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>District *</label>
                                    <input type="text" class="form-control" name="district" id="edit_district" required>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Ward *</label>
                                    <input type="text" class="form-control" name="ward" id="edit_ward" required>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Address Line *</label>
                            <input type="text" class="form-control" name="addressLine" id="edit_addressLine" required>
                        </div>
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" name="isDefault" id="edit_isDefault" value="true"> Set as Default address
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-danger">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- MODAL XÁC NHẬN XÓA ĐỊA CHỈ -->
    <div id="deleteAddressModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-sm" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Delete Address</h4>
                </div>
                <form action="${pageContext.request.contextPath}/addresses" method="POST" style="margin: 0;">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="addressId" id="delete_addressId">
                        <p style="margin: 0;">Are you sure you want to delete this address?</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">No</button>
                        <button type="submit" class="btn btn-danger">Yes, Delete</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- FOOTER -->
    <footer id="footer">
        <div class="section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12 text-center">
                        <p class="text-muted">© 2026 Headphone Store. All rights reserved.</p>
                    </div>
                </div>
            </div>
        </div>
    </footer>

    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script>
        function openEditAddressModal(btn) {
            document.getElementById('edit_addressId').value = btn.getAttribute('data-id');
            document.getElementById('edit_receiverName').value = btn.getAttribute('data-name');
            document.getElementById('edit_receiverPhone').value = btn.getAttribute('data-phone');
            document.getElementById('edit_province').value = btn.getAttribute('data-province');
            document.getElementById('edit_district').value = btn.getAttribute('data-district');
            document.getElementById('edit_ward').value = btn.getAttribute('data-ward');
            document.getElementById('edit_addressLine').value = btn.getAttribute('data-line');
            document.getElementById('edit_isDefault').checked = (btn.getAttribute('data-default') === 'true');
            $('#editAddressModal').modal('show');
        }

        function openDeleteAddressModal(addressId) {
            document.getElementById('delete_addressId').value = addressId;
            $('#deleteAddressModal').modal('show');
        }
    </script>
</body>
</html>
