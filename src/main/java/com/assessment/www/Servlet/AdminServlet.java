package com.assessment.www.Servlet;

import com.assessment.www.Service.*;
import com.assessment.www.Util.AuthUtil;
import com.assessment.www.constant.Constants;
import com.assessment.www.po.Report;
import com.assessment.www.po.User;
import com.assessment.www.po.Video;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

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
            case "/toggleUserStatus":
                try {
                    toggleUserStatus(request, response);
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

    //显示管理员登录页面
    private void showAdminLogin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
                response.sendRedirect(request.getContextPath() + "/admin/adminindex");
                return;
            }
        }
        request.setAttribute("error", "管理员用户名或密码错误");
        request.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(request, response);
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
        int totalVideos = videoService.getTotalVideoCount();
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
        try {
            List<Video> allVideos = videoService.getAllVideosIncludingPending();
            int totalCount = allVideos == null ? 0 : allVideos.size();
            int pageSize = 10;
            int fromIndex = (page - 1) * pageSize;
            int toIndex = Math.min(fromIndex + pageSize, totalCount);
            List<Video> videos;
            if (allVideos == null || fromIndex >= totalCount) {
                videos = new ArrayList<>();
            } else {
                videos = allVideos.subList(fromIndex, toIndex);
            }
            request.setAttribute("videos", videos);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", (int) Math.ceil((double) totalCount / pageSize));
            request.getRequestDispatcher("/WEB-INF/views/admin/videos.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("videos", new ArrayList<Video>());
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", 1);
            request.getRequestDispatcher("/WEB-INF/views/admin/videos.jsp").forward(request, response);
        }
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
            // 获取全量视频后筛选出待审核的视频
            List<Video> allVideos = videoService.getAllVideosIncludingPending();
            List<Video> pendingVideos = new java.util.ArrayList<>();
            if (allVideos != null) {
                for (Video video : allVideos) {
                    if (video.getStatus() == 0) {  // 状态为0表示待审核
                        pendingVideos.add(video);
                    }
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
        List<User> users = userService.getUserList(page, 10);
        users.removeIf(u -> u.getStatus() == 1);
        int totalCount = (int) users.stream().count();
        int totalPages = (int) Math.ceil((double) totalCount / 10);
        request.setAttribute("users", users);
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
                userService.banUser(userId);
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