package com.assessment.www.Util;

import com.assessment.www.Service.UserService;
import com.assessment.www.Service.UserServiceImpl;
import com.assessment.www.constant.Constants;
import com.assessment.www.po.User;

import javax.servlet.DispatcherType;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.WriteListener;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.Locale;

public class FractalThemeFilter implements Filter {
    private static final String THEME_VERSION = "20260504-glass-v8";
    private static final String THEME_CSS_PATH = "/static/css/fractal-theme.css?v=" + THEME_VERSION;
    private static final String THEME_JS_PATH = "/static/js/fractal-theme.js?v=" + THEME_VERSION;
    private static final UserService userService = new UserServiceImpl();

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        if (!(request instanceof HttpServletRequest) || !(response instanceof HttpServletResponse)) {
            chain.doFilter(request, response);
            return;
        }

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getRequestURI();
        // 跳过静态资源请求，避免缓冲视频、图片等二进制文件导致内存溢出和流媒体播放失败
        if (path != null && (path.startsWith(httpRequest.getContextPath() + "/static/")
                || path.contains("/static/")
                || path.endsWith(".mp4") || path.endsWith(".avi") || path.endsWith(".mov")
                || path.endsWith(".webm") || path.endsWith(".ogg")
                || path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".jpeg")
                || path.endsWith(".gif") || path.endsWith(".svg") || path.endsWith(".ico")
                || path.endsWith(".css") || path.endsWith(".js")
                || path.endsWith(".woff") || path.endsWith(".woff2") || path.endsWith(".ttf"))) {
            chain.doFilter(request, response);
            return;
        }

        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());

        CapturedResponseWrapper wrappedResponse = new CapturedResponseWrapper(httpResponse);

        chain.doFilter(request, wrappedResponse);

        String body = wrappedResponse.getCapturedBody();
        if (body == null) {
            return;
        }

        String normalized = body.trim().toLowerCase(Locale.ROOT);
        boolean looksLikeHtml = normalized.startsWith("<!doctype html")
                || normalized.startsWith("<html")
                || body.contains("<head")
                || body.contains("<body");

        if (looksLikeHtml && body.contains("</head>")) {
            StringBuilder injections = new StringBuilder();
            String contextPath = httpRequest.getContextPath();
            if (!body.contains("fractal-theme.css")) {
                injections.append("\n    <link rel=\"stylesheet\" href=\"")
                        .append(contextPath)
                        .append(THEME_CSS_PATH)
                        .append("\">");
            }
            if (!body.contains("window.__FR_USER__")) {
                injections.append(buildUserBootstrapScript(httpRequest));
            }
            if (!body.contains("fractal-theme.js")) {
                injections.append("\n    <script defer src=\"")
                        .append(contextPath)
                        .append(THEME_JS_PATH)
                        .append("\"></script>\n");
            }
            if (injections.length() > 0) {
                body = body.replaceFirst("(?i)</head>", injections + "</head>");
            }
        }

        Charset charset = Charset.forName(httpResponse.getCharacterEncoding() != null ? httpResponse.getCharacterEncoding() : StandardCharsets.UTF_8.name());
        byte[] output = body.getBytes(charset);
        httpResponse.setContentLength(output.length);
        httpResponse.getOutputStream().write(output);
        httpResponse.getOutputStream().flush();
    }

    @Override
    public void destroy() {
    }

    private String buildUserBootstrapScript(HttpServletRequest request) {
        String contextPath = escapeJs(request.getContextPath());
        HttpSession session = request.getSession(false);
        if (session == null) {
            return "\n    <script>window.__FR_USER__={loggedIn:false,role:'',userId:'',username:'',contextPath:'" + contextPath + "'};</script>\n";
        }

        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) {
            return "\n    <script>window.__FR_USER__={loggedIn:false,role:'',userId:'',username:'',contextPath:'" + contextPath + "'};</script>\n";
        }

        User bootstrapUser = sessionUser;
        boolean loggedIn = false;
        try {
            User refreshedUser = userService.getUserById(sessionUser.getId());
            if (refreshedUser != null) {
                bootstrapUser = refreshedUser;
                if (Constants.ROLEUSER.equals(refreshedUser.getRole()) && refreshedUser.getStatus() != null
                        && refreshedUser.getStatus() == Constants.STATUSNORMAL) {
                    loggedIn = true;
                    session.setAttribute("user", refreshedUser);
                } else if (Constants.ROLEUSER.equals(refreshedUser.getRole())) {
                    session.removeAttribute("user");
                }
            } else if (Constants.ROLEUSER.equals(sessionUser.getRole())) {
                session.removeAttribute("user");
            }
        } catch (Exception e) {
            loggedIn = Constants.ROLEUSER.equals(sessionUser.getRole())
                    && sessionUser.getStatus() != null
                    && sessionUser.getStatus() == Constants.STATUSNORMAL;
        }

        if (!loggedIn) {
            return "\n    <script>window.__FR_USER__={loggedIn:false,role:'',userId:'',username:'',contextPath:'" + contextPath + "'};</script>\n";
        }

        return "\n    <script>window.__FR_USER__={loggedIn:true,role:'" + escapeJs(bootstrapUser.getRole())
                + "',userId:'" + escapeJs(String.valueOf(bootstrapUser.getId()))
                + "',username:'" + escapeJs(bootstrapUser.getUsername())
                + "',contextPath:'" + contextPath + "'};</script>\n";
    }

    private String escapeJs(String value) {
        if (value == null) {
            return "";
        }
        StringBuilder escaped = new StringBuilder(value.length() + 16);
        for (int i = 0; i < value.length(); i++) {
            char ch = value.charAt(i);
            switch (ch) {
                case '\\':
                    escaped.append("\\\\");
                    break;
                case '\'':
                    escaped.append("\\'");
                    break;
                case '"':
                    escaped.append("\\\"");
                    break;
                case '\r':
                    break;
                case '\n':
                    escaped.append("\\n");
                    break;
                case '<':
                    escaped.append("\\x3C");
                    break;
                case '>':
                    escaped.append("\\x3E");
                    break;
                case '&':
                    escaped.append("\\x26");
                    break;
                case '\u2028':
                    escaped.append("\\u2028");
                    break;
                case '\u2029':
                    escaped.append("\\u2029");
                    break;
                default:
                    escaped.append(ch);
                    break;
            }
        }
        return escaped.toString();
    }

    private static class CapturedResponseWrapper extends HttpServletResponseWrapper {
        private final ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        private ServletOutputStream outputStream;
        private PrintWriter writer;

        CapturedResponseWrapper(HttpServletResponse response) {
            super(response);
        }

        @Override
        public ServletOutputStream getOutputStream() throws IOException {
            if (writer != null) {
                throw new IllegalStateException("getWriter() has already been called on this response.");
            }
            if (outputStream == null) {
                outputStream = new ServletOutputStream() {
                    @Override
                    public boolean isReady() {
                        return true;
                    }

                    @Override
                    public void setWriteListener(WriteListener writeListener) {
                    }

                    @Override
                    public void write(int b) {
                        buffer.write(b);
                    }
                };
            }
            return outputStream;
        }

        @Override
        public PrintWriter getWriter() throws IOException {
            if (outputStream != null) {
                throw new IllegalStateException("getOutputStream() has already been called on this response.");
            }
            if (writer == null) {
                writer = new PrintWriter(new OutputStreamWriter(buffer, getCharacterEncoding()), true);
            }
            return writer;
        }

        String getCapturedBody() throws IOException {
            if (writer != null) {
                writer.flush();
            }
            return buffer.toString(getCharacterEncoding());
        }
    }
}
