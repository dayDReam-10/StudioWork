package com.assessment.www.Util;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

//字符编码
public class CharacterEncodingFilter implements Filter {
    private String encoding = "UTF-8";

    // 写了一个默认utf-8过滤器 利用的是tc会自动读取web.xml中的filter配置
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String encodingParam = filterConfig.getInitParameter("encoding");
        if (encodingParam != null) {
            encoding = encodingParam;
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // 再者 通过将请求在到达servlet之前 换编码为utf-8
        request.setCharacterEncoding(encoding);// 设置请求编码
        response.setCharacterEncoding(encoding);// 设置响应编码
        response.setContentType("text/html;charset=" + encoding);//请求头设置响应编码
        HttpServletRequest httpRequest = (HttpServletRequest) request;//换类型为http请求
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        chain.doFilter(httpRequest, httpResponse);// 转发请求
    }

    @Override
    public void destroy() {
    }
}   