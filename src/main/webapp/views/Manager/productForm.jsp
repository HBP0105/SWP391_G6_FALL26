<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${mode eq 'edit' ? 'Edit Product' : 'Add Product'} | Headphone Store</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/bootstrap.min.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/vendors/bootstrap-icons/bootstrap-icons.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/Admin_Manager/css/style.css">
    </head>
    <body>
        <div class="admin-shell">
            <main class="dashboard-content w-100">
                <div class="container-fluid px-3 px-lg-4 py-4">

                    <div class="page-heading">
                        <div class="page-heading-copy">
                            <span class="page-icon">
                                <i class="bi ${mode eq 'edit' ? 'bi-pencil-square' : 'bi-plus-circle'}"></i>
                            </span>
                            <div>
                                <p class="eyebrow mb-1">Manager</p>
                                <h1 class="h3 mb-1">
                                    ${mode eq 'edit' ? 'Edit Product' : 'Add Product'}
                                </h1>
                                <p class="text-muted mb-0">
                                    ${mode eq 'edit'
                                      ? 'Update the selected headphone product.'
                                      : 'Add a new headphone product.'}
                                </p>
                            </div>
                        </div>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">
                            ${error}
                        </div>
                    </c:if>

                    <section class="panel">
                        <div class="panel-header">
                            <div>
                                <h2 class="h5 mb-1 section-title">
                                    <i class="bi bi-box-seam"></i>
                                    <span>Product Information</span>
                                </h2>
                                <p class="text-muted mb-0">
                                    ${mode eq 'edit'
                                      ? 'Edit all product information below.'
                                      : 'Enter product information below.'}
                                </p>
                            </div>
                        </div>

                        <!-- ONE form is used for both Add and Edit -->
                        <form method="post"
                              enctype="multipart/form-data"
                              action="${pageContext.request.contextPath}/Manager/products">

                            <input type="hidden" name="action" value="${mode}">

                            <c:if test="${mode eq 'edit'}">
                                <input type="hidden" name="id" value="${product.productId}">
                            </c:if>

                            <input type="hidden" name="from" value="${from}">

                            <div class="row g-3">

                                <c:if test="${mode eq 'edit'}">
                                    <div class="col-md-6">
                                        <label class="form-label">Product ID</label>
                                        <input type="text"
                                               class="form-control"
                                               value="${product.productId}"
                                               readonly>
                                    </div>
                                </c:if>

                                <div class="${mode eq 'edit' ? 'col-md-6' : 'col-12'}">
                                    <label class="form-label">Product Name</label>
                                    <input type="text"
                                           name="name"
                                           class="form-control"
                                           value="${mode eq 'edit' ? product.productName : ''}"
                                           required>
                                </div>

                                <div class="col-12">
                                    <label class="form-label">Description</label>
                                    <textarea name="description"
                                              class="form-control"
                                              rows="4">${mode eq 'edit' ? product.description : ''}</textarea>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Category</label>
                                    <select name="categoryId" class="form-select" required>
                                        <option value="">Select category</option>
                                        <c:forEach var="category" items="${categories}">
                                            <option value="${category.categoryId}"
                                                    ${mode eq 'edit' && product.categoryId == category.categoryId ? 'selected' : ''}>
                                                ${category.categoryName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Brand</label>
                                    <select name="brandId" class="form-select" required>
                                        <option value="">Select brand</option>
                                        <c:forEach var="brand" items="${brands}">
                                            <option value="${brand.brandId}"
                                                    ${mode eq 'edit' && product.brandId == brand.brandId ? 'selected' : ''}>
                                                ${brand.brandName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Price</label>
                                    <input type="number"
                                           name="price"
                                           class="form-control"
                                           value="${mode eq 'edit' ? product.price : ''}"
                                           min="0"
                                           step="0.01"
                                           required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Stock Quantity</label>
                                    <input type="number"
                                           name="stock"
                                           class="form-control"
                                           value="${mode eq 'edit' ? product.stockQuantity : ''}"
                                           min="0"
                                           required>
                                </div>

                                <div class="col-12">
                                    <label class="form-label">
                                        ${mode eq 'edit' ? 'Replace Product Image' : 'Product Image'}
                                    </label>

                                    <c:if test="${mode eq 'edit' && not empty product.imageURL}">
                                        <div class="mb-2">
                                            <img src="${product.imageURL}"
                                                 alt="${product.productName}"
                                                 style="width:96px;height:96px;object-fit:cover;border-radius:8px;">
                                            <div class="form-text">
                                                Leave the file empty to keep the current image.
                                            </div>
                                        </div>
                                    </c:if>

                                    <input type="file"
                                           name="image"
                                           class="form-control"
                                           accept="image/*">
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Connection Type</label>
                                    <select name="connectionType" class="form-select">
                                        <option value="">Not Specified</option>
                                        <option value="WIRED"
                                                ${mode eq 'edit' && product.connectionType eq 'WIRED' ? 'selected' : ''}>
                                            Wired
                                        </option>
                                        <option value="WIRELESS"
                                                ${mode eq 'edit' && product.connectionType eq 'WIRELESS' ? 'selected' : ''}>
                                            Wireless
                                        </option>
                                        <option value="BLUETOOTH"
                                                ${mode eq 'edit' && product.connectionType eq 'BLUETOOTH' ? 'selected' : ''}>
                                            Bluetooth
                                        </option>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Driver Size (mm)</label>
                                    <input type="number"
                                           name="driverSize"
                                           class="form-control"
                                           value="${mode eq 'edit' && not empty product.driverSize ? product.driverSize : ''}"
                                           min="0"
                                           step="0.1">
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Battery Life (hours)</label>
                                    <input type="number"
                                           name="batteryLife"
                                           class="form-control"
                                           value="${mode eq 'edit' && not empty product.batteryLife ? product.batteryLife : ''}"
                                           min="0">
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Water Resistance</label>
                                    <select name="waterResistance" class="form-select">
                                        <option value="">Not Specified</option>
                                        <c:forEach var="water" items="${['IPX4','IPX5','IPX6','IPX7','IP54']}">
                                            <option value="${water}"
                                                    ${mode eq 'edit' && product.waterResistance eq water ? 'selected' : ''}>
                                                ${water}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Status</label>
                                    <select name="status" class="form-select" required>
                                        <option value="ACTIVE"
                                                ${mode ne 'edit' || product.status eq 'ACTIVE' ? 'selected' : ''}>
                                            Active
                                        </option>
                                        <option value="INACTIVE"
                                                ${mode eq 'edit' && product.status eq 'INACTIVE' ? 'selected' : ''}>
                                            Inactive
                                        </option>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label d-block">Noise Cancelling</label>
                                    <div class="form-check">
                                        <input class="form-check-input"
                                               type="checkbox"
                                               name="noiseCancelling"
                                               id="noiseCancelling"
                                               ${mode eq 'edit' && product.noiseCancelling ? 'checked' : ''}>
                                        <label class="form-check-label" for="noiseCancelling">
                                            Supported
                                        </label>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label d-block">Microphone</label>
                                    <div class="form-check">
                                        <input class="form-check-input"
                                               type="checkbox"
                                               name="microphone"
                                               id="microphone"
                                               ${mode eq 'edit' && product.microphone ? 'checked' : ''}>
                                        <label class="form-check-label" for="microphone">
                                            Included
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex justify-content-end gap-2 mt-4">
                                <c:choose>
                                    <c:when test="${from eq 'inventory'}">
                                        <a href="${pageContext.request.contextPath}/Manager/Inventory"
                                           class="btn btn-light">
                                            <i class="bi bi-arrow-left me-1"></i>
                                            Back to Inventory
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/Manager/products"
                                           class="btn btn-light">
                                            Cancel
                                        </a>
                                    </c:otherwise>
                                </c:choose>

                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-check2-circle me-1"></i>
                                    ${mode eq 'edit' ? 'Save Changes' : 'Add Product'}
                                </button>
                            </div>
                        </form>
                    </section>
                </div>
            </main>
        </div>

        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/Admin_Manager/js/main.js"></script>
    </body>
</html>
