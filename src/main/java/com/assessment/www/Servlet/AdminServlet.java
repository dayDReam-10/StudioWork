package com.assessment.www.Servlet;

import com.assessment.www.Service.*;
import com.assessment.www.Util.AuthUtil;
import com.assessment.www.Util.UserStatusWebSocketEndpoint;
import com.assessment.www.constant.Constants;
import com.assessment.www.po.Report;
import com.assessment.www.po.User;
import com.assessment.www.po.Video;
import org.json.JSONObject;

import javax.servlet.http.Cookie;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

// 管理员相关Servlet
public class AdminServlet extends HttpServlet {
    private UserService userService = new UserServiceImpl();
    private VideoService videoService = new VideoServiceImpl();
    private ReportService reportService = new ReportServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        User admin = AuthUtil.getCurrentUser(request);
        switch (pathInfo) {//针对不同路径GET请求处理不同方法
            case "/ticket":
                response.sendRedirect(request.getContextPath() + "/adminticket/exhibitions");
                break;
            case "/login":
                showAdminLogin(request, response);
                break;
            case "/approve":
                approveVideo(request, response);
                break;
            case "/reject":
                rejectVideo(request, response);
                break;
            case "/adminindex":
                try {
                    showAdminindex(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/users":
                try {
                    showUserManagement(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/videos":
                showVideoManagement(request, response);
                break;
            case "/pending":
                showPendingVideos(request, response);
                break;
            case "/banned":
                try {
                    showBannedUsers(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/processReport":
                processReport(request, response, admin);
                break;
            case "/exportUser":
                try {
                    exportUser(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/reports":
                try {
                    showReportsOverview(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/logout":
                adminLogout(request, response);
                break;
            default:
                response.sendError(404);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        User admin = AuthUtil.getCurrentUser(request);
        switch (pathInfo) {//针对不同路径POST请求处理不同方法
            case "/login":
                try {
                    adminLogin(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/approve":
                approveVideo(request, response);
                break;
            case "/reject":
                rejectVideo(request, response);
                break;
            case "/validateCachedLogin":
                validateCachedAdminLogin(request, response);
                break;
            case "/toggleUserStatus":
                try {
                    toggleUserStatus(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/unbanUser":
                try {
                    unbanUser(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/deleteVideo":
                deleteVideo(request, response);
                break;
            case "/deleteUser":
                try {
                    deleteUser(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/exportUser":
                try {
                    exportUser(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/processReport":
                processReport(request, response, admin);
                break;
            default:
                response.sendError(404);
                break;
        }
    }

    //管理员登出
    private void adminLogout(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 清除会话
        HttpSession session = request.getSession();
        session.invalidate();
        // 清除Cookie
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("adminUsername".equals(cookie.getName()) || "adminPassword".equals(cookie.getName())) {
                    cookie.setMaxAge(0);
                    cookie.setPath(request.getContextPath() + "/");
                    response.addCookie(cookie);
                }
            }
        }
        // 重定向到登录页面
        response.sendRedirect(request.getContextPath() + "/admin/login");
    }

    //显示管理员登录页面
    private void showAdminLogin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 检查是否有缓存的登录信息
        String cachedUsername = null;
        String cachedPassword = null;
        // 从Cookie中获取缓存的登录信息
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("adminUsername".equals(cookie.getName())) {
                    cachedUsername = cookie.getValue();
                } else if ("adminPassword".equals(cookie.getName())) {
                    cachedPassword = cookie.getValue();
                }
            }
        }
        // 如果有缓存的登录信息，尝试自动登录
        if (cachedUsername != null && cachedPassword != null && !cachedUsername.isEmpty() && !cachedPassword.isEmpty()) {
            try {
                User admin = userService.validateAdminCachedLogin(cachedUsername, cachedPassword);
                if (admin != null && "admin".equals(admin.getRole())) {
                    // 自动登录成功
                    HttpSession session = request.getSession();
                    session.setAttribute("admin", admin);
                    session.setAttribute("user", admin);
                    response.sendRedirect(request.getContextPath() + "/admin/adminindex");
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        // 没有缓存或自动登录失败，显示登录页面
        request.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(request, response);
    }

    //显示
    private void showreports(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(request, response);
    }

    //管理员登录
    private void adminLogin(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        User user = userService.login(username, password);
        if (user != null) {
            if (user.getStatus() != 1) {// 检查用户是否被封禁
                request.setAttribute("error", "您的管理员账户已被封禁，请联系超级管理员");
                request.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(request, response);
                return;
            }
            if ("admin".equals(user.getRole())) {// 检查是否是管理员
                HttpSession session = request.getSession();
                session.setAttribute("admin", user);
                session.setAttribute("user", user);
                String encryptedPassword = userService.generateEncryptedPassword(username, password);
                // 创建Cookie
                Cookie usernameCookie = new Cookie("adminUsername", username);
                usernameCookie.setMaxAge(60 * 60 * 24 * 7); // 7天
                usernameCookie.setPath(request.getContextPath() + "/");
                usernameCookie.setHttpOnly(true);
                Cookie passwordCookie = new Cookie("adminPassword", encryptedPassword);
                passwordCookie.setMaxAge(60 * 60 * 24 * 7); // 7天
                passwordCookie.setPath(request.getContextPath() + "/");
                passwordCookie.setHttpOnly(true);
                response.addCookie(usernameCookie);
                response.addCookie(passwordCookie);
                response.sendRedirect(request.getContextPath() + "/admin/adminindex");
                return;
            }
        }
        request.setAttribute("error", "管理员用户名或密码错误");
        request.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(request, response);
    }
    private void validateCachedAdminLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 设置请求编码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        // 读取 JSON 请求体
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String jsonBody = sb.toString();
        JSONObject json = new JSONObject(jsonBody);
        String username = json.optString("username");
        String encryptedPassword = json.optString("encryptedPassword");
        String rememberToken = json.optString("rememberToken");
        Map<String, Object> result = new HashMap<>();
        try {
            // 验证 token 是否存在且未过期
            if (rememberToken == null || rememberToken.isEmpty()) {
                result.put("success", false);
                result.put("message", "无效的自动登录令牌");
                response.getWriter().write(new JSONObject(result).toString());
                return;
            }

            // 验证用户凭据
            User admin = userService.validateAdminCachedLogin(username, encryptedPassword);
            if (admin != null && "admin".equals(admin.getRole())) {
                // 检查账户状态
                if (admin.getStatus() != 1) {
                    result.put("success", false);
                    result.put("message", "管理员账户已被封禁");
                    response.getWriter().write(new JSONObject(result).toString());
                    return;
                }
                // 创建会话
                HttpSession session = request.getSession();
                session.setAttribute("admin", admin);
                session.setAttribute("user", admin);
                result.put("success", true);
                result.put("message", "自动登录成功");
            } else {
                result.put("success", false);
                result.put("message", "用户名或密码错误");
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "服务器内部错误");
        }
        response.getWriter().write(new JSONObject(result).toString());
    }
    //显示管理面板
    private void showAdminindex(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        // 获取统计数据
        int totalUsers = userService.getTotalUserCount();
        int totalVideos = videoService.getTotalVideoCount(admin);
        // 获取待审核视频
        List<Video> allVideos = videoService.getAllVideosIncludingPending();
        List<Video> pendingVideos = new java.util.ArrayList<>();
        for (Video video : allVideos) {
            if (video.getStatus() == 0) {  // 状态为0表示待审核
                pendingVideos.add(video);
            }
        }
        long totalViews = 0L;
        long totalLikes = 0L;
        long totalCoins = 0L;
        long totalFavorites = 0L;
        long totalComments = 0L;
        int approvedVideos = 0;
        for (Video video : allVideos) {
            totalViews += video.getViewCount() != null ? video.getViewCount() : 0;
            totalLikes += video.getLikeCount() != null ? video.getLikeCount() : 0;
            totalCoins += video.getCoinCount() != null ? video.getCoinCount() : 0;
            totalFavorites += video.getFavCount() != null ? video.getFavCount() : 0;
            totalComments += video.getScreenCommentCount() != null ? video.getScreenCommentCount() : 0;
            if (video.getStatus() == 1) {  // 状态为1表示已通过审核
                approvedVideos++;
            }
        }
        List<Report> pendingReports = reportService.getPendingReports(1, 5);  // 获取前5条待处理举报
        List<Report> processedReports = reportService.getProcessedReports(1, 5);  // 获取前5条已处理举报
        int totalReports = reportService.getTotalReportCount();
        int pendingReportCount = 0;
        try {
            pendingReportCount = reportService.getPendingReportCount();
        } catch (Exception e) {
            pendingReportCount = 0;
        }
        // 设置属性
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalVideos", totalVideos);
        request.setAttribute("pendingVideos", pendingVideos);
        request.setAttribute("totalViews", totalViews);
        request.setAttribute("totalLikes", totalLikes);
        request.setAttribute("totalCoins", totalCoins);
        request.setAttribute("totalFavorites", totalFavorites);
        request.setAttribute("totalComments", totalComments);
        request.setAttribute("approvedVideos", approvedVideos);
        request.setAttribute("pendingReports", pendingReports);
        request.setAttribute("processedReports", processedReports);
        request.setAttribute("totalReports", totalReports);
        request.setAttribute("pendingReportCount", pendingReportCount);
        request.setAttribute("contextPath", request.getContextPath());
        request.getRequestDispatcher("/WEB-INF/views/admin/adminindex.jsp").forward(request, response);
    }

    //显示用户管理页面
    private void showUserManagement(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            page = 1;
        }
        List<User> users = userService.getUserList(page, 10);
        int totalCount = userService.getTotalUserCount();
        request.setAttribute("users", users);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", (int) Math.ceil((double) totalCount / 10));
        request.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(request, response);
    }

    //显示视频管理页面
    private void showVideoManagement(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            page = 1;
        }
        String status = request.getParameter("status");
        List<Video> videos = videoService.getAllVideos(admin, page, 10);
        List<Video> filteredVideos = new ArrayList<>();
        int totalCount = videoService.getTotalVideoCount(admin);
        if (status != null && status != "") {
            filteredVideos = videos.stream().filter(video -> video.getStatus() == Integer.valueOf(status).intValue())
                    .collect(Collectors.toList());
            videos = filteredVideos;
            totalCount = filteredVideos.size();
        }
        request.setAttribute("videos", videos);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", (int) Math.ceil((double) totalCount / 10));
        request.getRequestDispatcher("/WEB-INF/views/admin/videos.jsp").forward(request, response);
    }

    //显示待审核视频页面
    private void showPendingVideos(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        try {
            // 获取所有视频，然后筛选出待审核的视频
            List<Video> allVideos = videoService.getAllVideosIncludingPending();
            List<Video> pendingVideos = new java.util.ArrayList<>();
            for (Video video : allVideos) {
                if (video.getStatus() == 0) {  // 状态为0表示待审核
                    pendingVideos.add(video);
                }
            }
            request.setAttribute("pendingVideos", pendingVideos);
            request.getRequestDispatcher("/WEB-INF/views/admin/pendingVideos.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "获取待审核视频失败");
            request.getRequestDispatcher("/WEB-INF/views/admin/pendingVideos.jsp").forward(request, response);
        }
    }

    //显示被封禁用户页面
    private void showBannedUsers(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            page = 1;
        }
        int totalUsers = userService.getTotalUserCount();
        List<User> allUsers = totalUsers > 0 ? userService.getUserList(1, totalUsers) : new ArrayList<>();
        List<User> bannedUsers = new ArrayList<>();
        for (User user : allUsers) {
            if (user != null && user.getStatus() != null && user.getStatus() != 1) {
                bannedUsers.add(user);
            }
        }
        int totalCount = bannedUsers.size();
        int pageSize = 10;
        int totalPages = totalCount == 0 ? 1 : (int) Math.ceil((double) totalCount / pageSize);
        int fromIndex = Math.max(0, (page - 1) * pageSize);
        int toIndex = Math.min(fromIndex + pageSize, totalCount);
        List<User> users = fromIndex < totalCount ? bannedUsers.subList(fromIndex, toIndex) : new ArrayList<>();
        request.setAttribute("users", users);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/WEB-INF/views/admin/bannedUsers.jsp").forward(request, response);
    }

    //审核通过视频
    private void approveVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.setContentType("text/plain");
            response.getWriter().write("未登录或无权限");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("id"));
        if (videoService.approveVideo(videoId)) {
            response.setContentType("text/plain");
            response.getWriter().write("success");
        } else {
            response.setContentType("text/plain");
            response.getWriter().write("审核失败");
        }
    }

    //驳回视频
    private void rejectVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.setContentType("text/plain");
            response.getWriter().write("未登录或无权限");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("id"));
        if (videoService.rejectVideo(videoId)) {
            response.setContentType("text/plain");
            response.getWriter().write("success");
        } else {
            response.setContentType("text/plain");
            response.getWriter().write("操作失败");
        }
    }

    //切换用户状态（封禁/解封）
    private void toggleUserStatus(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.setContentType("text/plain");
            response.getWriter().write("未登录或无权限");
            return;
        }
        int userId = Integer.parseInt(request.getParameter("userId"));
        User user = userService.getUserInfo(userId);
        if (user != null) {
            if (user.getStatus() == 1) {
                boolean banned = userService.banUser(userId);
                if (!banned) {
                    response.setContentType("text/plain");
                    response.getWriter().write("操作失败");
                    return;
                }
                UserStatusWebSocketEndpoint.sendForceLogoutUser(String.valueOf(userId), "您的账户已被封禁，请重新登录");
                response.setContentType("text/plain");
                response.getWriter().write("success");
            } else {
                userService.unbanUser(userId);
                response.setContentType("text/plain");
                response.getWriter().write("success");
            }
        } else {
            response.setContentType("text/plain");
            response.getWriter().write("用户不存在");
        }
    }

    //解封用户（被封用户页面专用）
    private void unbanUser(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.setContentType("text/plain");
            response.getWriter().write("未登录或无权限");
            return;
        }
        int userId = Integer.parseInt(request.getParameter("userId"));
        if (userService.unbanUser(userId)) {
            response.sendRedirect(request.getContextPath() + "/admin/banned");
        } else {
            response.setContentType("text/plain");
            response.getWriter().write("解封失败");
        }
    }

    //删除视频
    private void deleteVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.setContentType("text/plain");
            response.getWriter().write("未登录或无权限");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("id"));
        if (videoService.deleteVideoById(videoId)) {
            response.setContentType("text/plain");
            response.getWriter().write("success");
        } else {
            response.setContentType("text/plain");
            response.getWriter().write("删除失败");
        }
    }

    //删除用户
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("admin");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.setContentType("text/plain");
            response.getWriter().write("未登录或无权限");
            return;
        }
        int userId = Integer.parseInt(request.getParameter("userId"));
        if (userService.deleteUser(userId)) {
            response.setContentType("text/plain");
            response.getWriter().write("success");
        } else {
            response.setContentType("text/plain");
            response.getWriter().write("删除失败");
        }
    }

    private void exportUser(HttpServletRequest request, HttpServletResponse response) throws Exception {
        try {
            List<User> users = userService.getUserList(1, 10000);
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"users_" + new SimpleDateFormat("yyyyMMdd").format(new Date()) + ".csv\"");
            PrintWriter writer = response.getWriter();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            // 写入标题行
            writer.println("ID,用户名,性别,签名,硬币数,关注数,粉丝数,总点赞数,总收藏数,角色,状态");
            // 写入用户数据
            for (User user : users) {
                writer.printf("%d,%s,%d,%s,%d,%d,%d,%d,%d,%s,%d%n",
                        user.getId(),
                        user.getUsername(),
                        user.getGender(),
                        user.getSignature() != null ? user.getSignature().replace("\"", "\"\"") : "",
                        user.getCoinCount(),
                        user.getFollowingCount(),
                        user.getFollowerCount(),
                        user.getTotalLikeCount(),
                        user.getTotalFavCount(),
                        user.getRole(),
                        user.getStatus()
                );
            }
            writer.flush();
            writer.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "服务器报错");
        }
    }

    //举报操作信息的处理
    // 处理举报
    private void processReport(HttpServletRequest request, HttpServletResponse response, User admin) throws IOException {
        String reportIdStr = request.getParameter("reportId");
        String action = request.getParameter("action");
        if (reportIdStr == null || action == null) {
            response.sendError(400, "参数错误");
            return;
        }
        try {
            int reportId = Integer.parseInt(reportIdStr);
            boolean success = reportService.processReport(reportId, Integer.valueOf(action));
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": " + success + "}");
        } catch (NumberFormatException e) {
            response.sendError(400, "为空");
        }
    }

    // 显示举报概览页面
    private void showReportsOverview(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        String search = request.getParameter("search");
        List<Report> reports = reportService.getAllReports(page, Constants.PAGESIZE);
        int totalReports = reportService.getTotalReportCount();
        // 搜索条件
        if (search != null && !search.trim().isEmpty()) {
            List<Report> filteredReports = new ArrayList<>();
            for (Report report : reports) {
                boolean match = false;
                // 检查视频标题
                if (report.getVideo() != null && report.getVideo().getTitle() != null) {
                    if (report.getVideo().getTitle().contains(search)) {
                        match = true;
                    }
                }
                // 检查举报人
                if (!match && report.getReporter() != null && report.getReporter().getUsername() != null) {
                    if (report.getReporter().getUsername().contains(search)) {
                        match = true;
                    }
                }
                // 检查举报详情
                if (!match && report.getReasonDetail() != null) {
                    if (report.getReasonDetail().contains(search)) {
                        match = true;
                    }
                }
                if (match) {
                    filteredReports.add(report);
                }
            }
            reports = filteredReports;
        }
        for (Report report : reports) {
            if (report != null && report.getUserId() != null) {
                User userBy = userService.getUserById(report.getUserId());
                report.setReporter(userBy);
            }
            if (report != null && report.getVideoId() != null) {
                Video video = videoService.getVideoDetail(report.getVideoId());
                report.setVideo(video);
            }
        }
        request.setAttribute("reports", reports);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalReports", totalReports);
        request.setAttribute("totalPages", totalReports);
        request.setAttribute("search", search);
        request.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(request, response);
    }
}