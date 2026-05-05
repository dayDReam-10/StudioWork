package com.assessment.www.exception;

import com.assessment.www.Service.UserServiceImpl;
import com.assessment.www.Util.AuthUtil;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter(urlPatterns = "/*")
public class ExceptionHandler implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        try {
            HttpServletRequest req = (HttpServletRequest) request;
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            String uri = req.getRequestURI();
            if (uri.startsWith("/user/login")||uri.startsWith("/")||uri.startsWith("/admin/login")||uri.startsWith("/user/register")) {
                chain.doFilter(request, response);
                return;
            }
            if (!AuthUtil.refreshUserStatus(req, new UserServiceImpl())) {
                AuthUtil.redirectToLogin(req, httpResponse);
                return;
            }
            chain.doFilter(request, response);
        } catch (BaseException e) {
            if (e.getCode() == 401) {
                HttpServletRequest httpRequest = (HttpServletRequest) request;
                HttpServletResponse httpResponse = (HttpServletResponse) response;
                handle401(httpRequest, httpResponse);
                return;
            }
            request.setAttribute("errorCode", e.getCode());
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        } catch (Exception e) {
            if (!response.isCommitted()) {
                request.setAttribute("errorCode", 500);
                request.setAttribute("error", "服务器内部错误");
                request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
            } else {
            }
        }
    }

    private void handle401(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String uri = request.getRequestURI();
        if (uri.contains("video")) {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().print("{\"code\":401,\"message\":\"请重新登录\"}");
        } else {
            String loginUrl = request.getContextPath() + "/user/login";
            String requestUri = request.getRequestURI();
            if (!requestUri.equals(request.getContextPath() + "/user/login")) {
                response.sendRedirect(loginUrl);
            } else {
            }
        }
    }

    @Override
    public void destroy() {
    }
}
