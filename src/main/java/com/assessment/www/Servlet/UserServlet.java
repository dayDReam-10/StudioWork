package com.assessment.www.Servlet;

import com.assessment.www.Service.UserService;
import com.assessment.www.Service.UserServiceImpl;
import com.assessment.www.Service.VideoService;
import com.assessment.www.Service.VideoServiceImpl;
import com.assessment.www.exception.BaseException;
import com.assessment.www.Util.UserStatusWebSocketEndpoint;
import com.assessment.www.po.History;
import com.assessment.www.po.User;
import com.assessment.www.po.Video;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.io.BufferedReader;

//用户相关Servlet
@WebServlet("/user/*")
public class UserServlet extends HttpServlet {
    private UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        switch (pathInfo) {//针对不同路径GET请求处理不同方法
            case "/login":
                showLogin(request, response);
                break;
            case "/register":
                showRegister(request, response);
                break;
            case "/logout":
                logout(request, response);
                break;
            case "/profile":
                showProfile(request, response);
                break;
            case "/me":
                showMyProfile(request, response);
                break;
            case "/followers":
                showRelationList(request, response, true);
                break;
            case "/following":
                showRelationList(request, response, false);
                break;
            case "/history":
                showHistory(request, response);
                break;
            case "/":
                response.sendRedirect(request.getContextPath() + "/");
                break;
            default:
                int userId = Integer.parseInt(pathInfo.substring(1));
                showUserProfile(request, response, userId);
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
        switch (pathInfo) {//针对不同路径POST请求处理不同方法
            case "/login":
                login(request, response);
                break;
            case "/validateCachedLogin":
                validateCachedLogin(request, response);
                break;
            case "/register":
                register(request, response);
                break;
            case "/updateProfile":
                updateProfile(request, response);
                break;
            case "/updateAvatar":
                updateAvatar(request, response);
                break;
            case "/changePassword":
                changePassword(request, response);
                break;
            case "/ban":
                banUser(request, response);
                break;
            case "/unban":
                unbanUser(request, response);
                break;
            case "/follow":
                followUser(request, response);
                break;
            case "/unfollow":
                unfollowUser(request, response);
                break;
            default:
                response.sendError(404);
                break;
        }
    }

    //显示登录页面
    private void showLogin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }

    //显示注册页面
    private void showRegister(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    //处理登录
    private void login(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        User user;
        try {
            user = userService.login(username, password);
        } catch (Exception e) {
            throw new BaseException(500, "登录失败");
        }
        if (user != null) {
            // 检查用户是否被封禁
            if (user.getStatus() != 1) {
                request.setAttribute("error", "您的账户已被封禁，请联系管理员解封");
                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                return;
            }
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            // 如果是管理员，跳转到管理页面
            if ("admin".equals(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin/adminindex");
            } else {
                response.sendRedirect(request.getContextPath() + "/");
            }
        } else {
            request.setAttribute("error", "用户名或密码错误");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }

    //处理注册
    private void register(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        User user = new User();
        user.setUsername(request.getParameter("username"));
        user.setPassword(request.getParameter("password"));
        user.setGender(Integer.parseInt(request.getParameter("gender")));
        user.setSignature(request.getParameter("signature"));
        boolean success;
        try {
            success = userService.register(user);
        } catch (Exception e) {
            throw new BaseException(500, "注册失败");
        }
        if (success) {
            response.sendRedirect(request.getContextPath() + "/user/login?success=1");
        } else {
            request.setAttribute("error", "注册失败，用户名可能已存在");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
        }
    }

    //显示个人资料
    private void showMyProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new BaseException(401, "请先登录");
        }
        response.sendRedirect(request.getContextPath() + "/user/" + user.getId());
    }

    private void showProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new BaseException(401, "请先登录");
        }
        try {
            user = userService.getUserById(user.getId());
        } catch (Exception e) {
            throw new BaseException(500, "获取用户信息失败");
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    //更新个人资料
    private void updateProfile(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new BaseException(401, "请先登录");
        }
        user.setGender(Integer.parseInt(request.getParameter("gender")));
        user.setSignature(request.getParameter("signature"));
        boolean success;
        try {
            success = userService.updateProfile(user);
        } catch (Exception e) {
            throw new BaseException(500, "更新失败");
        }
        if (success) {
            session.setAttribute("user", user);
            request.setAttribute("success", "个人资料更新成功");
        } else {
            request.setAttribute("error", "更新失败");
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    //更新头像
    private void updateAvatar(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        // 设置响应类型为 JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (user == null) {
            response.setStatus(401); // 401
            response.getWriter().print("{\"success\": false, \"message\": \"请先登录\", \"needLogin\": true}");
            return;
        }
        String avatarUrl = request.getParameter("avatarUrl");
        boolean success;
        try {
            success = userService.updateAvatar(user.getId(), avatarUrl);
        } catch (Exception e) {
            response.setStatus(500);
            response.getWriter().print("{\"success\": false, \"message\": \"更新失败: " + escapeJson(e.getMessage()) + "\"}");
            return;
        }
        if (success) {
            user.setAvatarUrl(avatarUrl);
            session.setAttribute("user", user);
            response.getWriter().print("{\"success\": true, \"message\": \"头像更新成功\"}");
        } else {
            response.getWriter().print("{\"success\": false, \"message\": \"更新失败，请重试\"}");
        }
    }

    //修改密码
    private void changePassword(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new BaseException(401, "请先登录");
        }
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        boolean success;
        try {
            success = userService.changePassword(user.getId(), oldPassword, newPassword);
        } catch (Exception e) {
            throw new BaseException(500, "密码修改失败");
        }
        if (success) {
            request.setAttribute("success", "密码修改成功");
        } else {
            request.setAttribute("error", "旧密码错误");
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    //注销
    private void logout(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        session.invalidate();
        response.sendRedirect(request.getContextPath() + "/");
    }

    //验证缓存的登录信息
    private void validateCachedLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            // 读取请求体
            StringBuilder sb = new StringBuilder();
            String line;
            try (java.io.BufferedReader reader = request.getReader()) {
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            // 解析JSON
            String json = sb.toString();
            if (json == null || json.isEmpty()) {
                response.getWriter().write("{\"success\": false, \"message\": \"请求参数错误\"}");
                return;
            }
            String username = extractJsonField(json, "username");
            String encryptedPassword = extractJsonField(json, "encryptedPassword");
            if (username == null || encryptedPassword == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"用户名或密码为空\"}");
                return;
            }
            // 验证缓存的登录信息
            User user = userService.validateCachedLogin(username, encryptedPassword);
            if (user != null) {
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                response.getWriter().write("{\"success\": true, \"message\": \"自动登录成功\", \"username\": \"" + user.getUsername() + "\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"用户名或密码错误\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"系统错误，请稍后重试\"}");
        }
    }

    //简单的JSON字段提取方法
    private String extractJsonField(String json, String fieldName) {
        String pattern = "\"" + fieldName + "\":\\s*\"([^\"]+)\"";
        java.util.regex.Pattern p = java.util.regex.Pattern.compile(pattern);
        java.util.regex.Matcher m = p.matcher(json);
        if (m.find()) {
            return m.group(1);
        }
        return null;
    }

    //显示历史浏览
    private void showHistory(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new BaseException(401, "请先登录");
        }
        VideoService videoService = new VideoServiceImpl();
        List<com.assessment.www.po.History> historyList = videoService.getUserHistory(user.getId());
        for (History myhis : historyList) {
            try {
                User author = userService.getUserInfo(myhis.getUserId());
                myhis.setUser(author);
            } catch (Exception e) {
            }
            try {
                Video videoDetail = videoService.getVideoDetail(myhis.getVideoId());
                myhis.setVideo(videoDetail);
            } catch (Exception e) {
            }
        }
        request.setAttribute("historyList", historyList);
        request.getRequestDispatcher("/WEB-INF/views/history.jsp").forward(request, response);
    }

    //显示用户资料页面
    private void showUserProfile(HttpServletRequest request, HttpServletResponse response, int userId) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        User targetUser;
        try {
            targetUser = userService.getUserInfo(userId);
        } catch (Exception e) {
            throw new BaseException(500, "获取用户信息失败");
        }
        if (targetUser == null) {
            throw new BaseException(404, "用户不存在");
        }
        boolean isFollowing = false;
        if (currentUser != null) {
            try {
                isFollowing = userService.isFollowing(currentUser.getId(), userId);
            } catch (Exception e) {
            }
        }
        VideoService videoService = new VideoServiceImpl();
        List<Video> userVideos = videoService.getUserVideos(userId, currentUser);
        int totalViewCount = 0;
        int totalLikeCount = 0;
        if (userVideos != null) {
            for (Video video : userVideos) {
                if (video == null) {
                    continue;
                }
                totalViewCount += video.getViewCount() != null ? video.getViewCount() : 0;
                totalLikeCount += video.getLikeCount() != null ? video.getLikeCount() : 0;
            }
        }
        request.setAttribute("targetUser", targetUser);
        request.setAttribute("isFollowing", isFollowing);
        request.setAttribute("userVideos", userVideos);
        request.setAttribute("videoCount", userVideos != null ? userVideos.size() : 0);
        request.setAttribute("totalViewCount", totalViewCount);
        request.setAttribute("totalLikeCount", totalLikeCount);
        // 获取点赞和收藏的视频列表
        List<Video> likedVideos = videoService.getUserLikedVideos(userId, 1, 20);
        int likedCount = videoService.getUserLikedCount(userId);
        List<Video> favoritedVideos = videoService.getUserFavoriteVideos(userId, 1, 20);
        int favoriteCount = videoService.getUserFavoriteCount(userId);
        request.setAttribute("likedVideos", likedVideos);
        request.setAttribute("likedCount", likedCount);
        request.setAttribute("favoritedVideos", favoritedVideos);
        request.setAttribute("favoriteCount", favoriteCount);
        boolean isOwnProfile = (currentUser != null && currentUser.getId() == userId);
        request.setAttribute("isOwnProfile", isOwnProfile);
        request.getRequestDispatcher("/WEB-INF/views/userProfile.jsp").forward(request, response);
    }

    // 显示粉丝/关注列表
    private void showRelationList(HttpServletRequest request, HttpServletResponse response, boolean followers)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        int targetUserId;
        String userIdParam = request.getParameter("userId");
        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            if (currentUser == null) {
                throw new BaseException(401, "请先登录");
            }
            targetUserId = currentUser.getId();
        } else {
            try {
                targetUserId = Integer.parseInt(userIdParam);
            } catch (NumberFormatException e) {
                throw new BaseException(400, "参数错误");
            }
        }

        User targetUser;
        try {
            targetUser = userService.getUserById(targetUserId);
        } catch (Exception e) {
            throw new BaseException(500, "获取用户信息失败");
        }
        if (targetUser == null) {
            throw new BaseException(404, "用户不存在");
        }

        List<User> relationUsers;
        try {
            relationUsers = followers ? userService.getFollowerUsers(targetUserId) : userService.getFollowingUsers(targetUserId);
        } catch (Exception e) {
            throw new BaseException(500, followers ? "获取粉丝列表失败" : "获取关注列表失败");
        }

        request.setAttribute("targetUser", targetUser);
        request.setAttribute("relationUsers", relationUsers);
        request.setAttribute("relationType", followers ? "followers" : "following");
        request.setAttribute("relationTitle", followers ? "粉丝列表" : "关注列表");
        request.setAttribute("relationCount", relationUsers != null ? relationUsers.size() : 0);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("isOwnProfile", currentUser != null && currentUser.getId() == targetUserId);
        request.getRequestDispatcher("/WEB-INF/views/userRelations.jsp").forward(request, response);
    }

    //封禁用户
    private void banUser(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("user");
        if (admin == null || !"admin".equals(admin.getRole())) {
            throw new BaseException(403, "需要管理员权限");
        }
        int userId = Integer.parseInt(request.getParameter("userId"));
        boolean success;
        try {
            success = userService.banUser(userId);
        } catch (Exception e) {
            throw new BaseException(500, "操作失败");
        }
        if (!success) {
            throw new BaseException(400, "操作失败");
        }
        UserStatusWebSocketEndpoint.sendForceLogoutUser(String.valueOf(userId), "您的账户已被封禁，请重新登录");
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    //解封用户
    private void unbanUser(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("user");
        if (admin == null || !"admin".equals(admin.getRole())) {
            throw new BaseException(403, "需要管理员权限");
        }
        int userId = Integer.parseInt(request.getParameter("userId"));
        boolean success;
        try {
            success = userService.unbanUser(userId);
        } catch (Exception e) {
            throw new BaseException(500, "操作失败");
        }
        if (!success) {
            throw new BaseException(400, "操作失败");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    //关注用户
    private void followUser(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new BaseException(401, "请先登录");
        }
        int targetUserId = Integer.parseInt(request.getParameter("targetUserId"));
        boolean success;
        try {
            success = userService.followUser(user.getId(), targetUserId);
        } catch (Exception e) {
            throw new BaseException(500, "关注失败");
        }
        if (!success) {
            throw new BaseException(400, "关注失败");
        }
        response.sendRedirect(request.getContextPath() + "/user/" + targetUserId);
    }

    //取消关注用户
    private void unfollowUser(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new BaseException(401, "请先登录");
        }
        int targetUserId = Integer.parseInt(request.getParameter("targetUserId"));
        boolean success;
        try {
            success = userService.unfollowUser(user.getId(), targetUserId);
        } catch (Exception e) {
            throw new BaseException(500, "取消关注失败");
        }
        if (!success) {
            throw new BaseException(400, "取消关注失败");
        }
        response.sendRedirect(request.getContextPath() + "/user/" + targetUserId);
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}