<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String queryString = request.getQueryString();
    String target = request.getContextPath() + "/admin/users" + (queryString != null && !queryString.isBlank() ? "?" + queryString : "");
    response.sendRedirect(target);
%>
