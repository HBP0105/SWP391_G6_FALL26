<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<script>
    window.__contextPath = '${pageContext.request.contextPath}';
</script>
<script defer src="${pageContext.request.contextPath}/assets/js/session-status.js?v=20261114-1"></script>
<aside class="admin-sidebar" id="adminSidebar">
    <div class="sidebar-header">
        <a class="brand-mark" href="${pageContext.request.contextPath}/admin/revenue-report">
            <span class="brand-icon"><i class="bi bi-shield-lock-fill"></i></span>
            <span class="brand-copy">
                <span class="brand-title">Admin Portal</span>
                <span class="brand-subtitle">Headphone Analytics</span>
            </span>
        </a>
    </div>
    <nav class="sidebar-nav">
        <a class="nav-link ${fn:contains(pageContext.request.requestURI, '/revenue-report') ? 'active' : ''}"
           href="${pageContext.request.contextPath}/admin/revenue-report">
            <span class="nav-icon"><i class="bi bi-graph-up-arrow"></i></span>
            <span class="nav-text">Revenue Report</span>
        </a>
        <a class="nav-link ${fn:contains(pageContext.request.requestURI, '/ai-performance') ? 'active' : ''}"
           href="${pageContext.request.contextPath}/admin/ai-performance">
            <span class="nav-icon"><i class="bi bi-robot"></i></span>
            <span class="nav-text">AI Performance & Config</span>
        </a>
        <a class="nav-link ${fn:contains(pageContext.request.requestURI, '/behavior-pipeline') ? 'active' : ''}"
           href="${pageContext.request.contextPath}/admin/behavior-pipeline">
            <span class="nav-icon"><i class="bi bi-diagram-3"></i></span>
            <span class="nav-text">Behavior Pipeline</span>
        </a>
        <a class="nav-link ${fn:contains(pageContext.request.requestURI, '/audit-logs') ? 'active' : ''}"
           href="${pageContext.request.contextPath}/admin/audit-logs">
            <span class="nav-icon"><i class="bi bi-clock-history"></i></span>
            <span class="nav-text">Audit Logs</span>
        </a>
        <a class="nav-link ${fn:contains(pageContext.request.requestURI, '/users') || fn:contains(pageContext.request.requestURI, '/account-access') || fn:contains(pageContext.request.requestURI, 'user-management') ? 'active' : ''}"
           href="${pageContext.request.contextPath}/admin/users">
            <span class="nav-icon"><i class="bi bi-people-fill"></i></span>
            <span class="nav-text">User & Access Management</span>
        </a>
        <a class="nav-link ${fn:contains(pageContext.request.requestURI, '/categories') ? 'active' : ''}"
           href="${pageContext.request.contextPath}/admin/categories">
            <span class="nav-icon"><i class="bi bi-tags-fill"></i></span>
            <span class="nav-text">Categories</span>
        </a>
        <a class="nav-link ${fn:contains(pageContext.request.requestURI, '/brands') ? 'active' : ''}"
           href="${pageContext.request.contextPath}/admin/brands">
            <span class="nav-icon"><i class="bi bi-award-fill"></i></span>
            <span class="nav-text">Brands</span>
        </a>
        <a class="nav-link ${fn:contains(pageContext.request.requestURI, '/profile') ? 'active' : ''}"
           href="${pageContext.request.contextPath}/admin/profile">
            <span class="nav-icon"><i class="bi bi-person-badge-fill"></i></span>
            <span class="nav-text">My Profile</span>
        </a>
    </nav>
</aside>
