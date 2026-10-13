/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebFilter("/*")
public class RoleFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        try {
            chain.doFilter(req, res);

            // x? lý 404
            if (response.getStatus() == 404 && !response.isCommitted()) {
                handle404(request, response);
            }

        } catch (Exception e) {
            if (!response.isCommitted()) {
                handle500(request, response);
            }
        }
    }

    private void handle404(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uri = request.getRequestURI();
        String context = request.getContextPath();

        if (uri.startsWith(context + "/Manager")) {
            request.getRequestDispatcher("/views/Manager/404.jsp").forward(request, response);
        } else if (uri.startsWith(context + "/Admin")) {
            request.getRequestDispatcher("/views/Admin/404.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/views/Customer/404.jsp").forward(request, response);
        }
    }

    private void handle500(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uri = request.getRequestURI();
        String context = request.getContextPath();

        if (uri.startsWith(context + "/Manager")) {
            request.getRequestDispatcher("/views/Manager/500.jsp").forward(request, response);
        } else if (uri.startsWith(context + "/Admin")) {
            request.getRequestDispatcher("/views/Admin/500.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/views/Customer/500.jsp").forward(request, response);
        }
    }
}