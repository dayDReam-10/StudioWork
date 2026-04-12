package com.assessment.www.Servlet;

import com.assessment.www.Service.UserService;
import com.assessment.www.Service.UserServiceImpl;
import com.assessment.www.Service.VideoService;
import com.assessment.www.Service.VideoServiceImpl;
import com.assessment.www.po.History;
import com.assessment.www.po.User;
import com.assessment.www.po.Video;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

//用户相关Servlet
@WebServlet("/user/*")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 8 * 1024 * 1024
)
public class UserServlet extends HttpServlet {
    private UserService userService = new UserServiceImpl();
    private VideoService videoService = new VideoServiceImpl();

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
            case "/history":
                showHistory(request, response);
                break;
            case "/favorites":
                showFavorites(request, response);
                break;
            case "/":
                response.sendRedirect(request.getContextPath() + "/");
                break;
            default:
                try {
                    int userId = Integer.parseInt(pathInfo.substring(1));
                    showUserProfile(request, response, userId);
                } catch (NumberFormatException e) {
                    response.sendError(404);
                } catch (Exception e) {
                    e.printStackTrace();
                }
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
                try {
                    login(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/register":
                try {
                    register(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/updateProfile":
                try {
                    updateProfile(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/updateAvatar":
                try {
                    updateAvatar(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/changePassword":
                try {
                    changePassword(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/ban":
                try {
                    banUser(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/unban":
                try {
                    unbanUser(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/follow":
                try {
                    followUser(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/unfollow":
                try {
                    unfollowUser(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
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
    private void login(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        User user = userService.login(username, password);
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
    private void register(HttpServletRequest request, HttpServletResponse response) throws Exception {
        User user = new User();
        user.setUsername(request.getParameter("username"));
        user.setPassword(request.getParameter("password"));
        user.setGender(Integer.parseInt(request.getParameter("gender")));
        user.setSignature(request.getParameter("signature"));
        if (userService.register(user)) {
            response.sendRedirect(request.getContextPath() + "/user/login?success=1");
        } else {
            request.setAttribute("error", "注册失败，用户名可能已存在");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
        }
    }

    //显示个人资料
    private void showProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        try {
            user = userService.getUserById(user.getId());
        } catch (Exception err) {
            err.printStackTrace();
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    //更新个人资料
    private void updateProfile(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        user.setGender(Integer.parseInt(request.getParameter("gender")));
        user.setSignature(request.getParameter("signature"));
        if (userService.updateProfile(user)) {
            session.setAttribute("user", user);
            request.setAttribute("success", "个人资料更新成功");
        } else {
            request.setAttribute("error", "更新失败");
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    //更新头像
    private void updateAvatar(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        String avatarUrl = null;
        String uploadedAvatarPath = null;
        try {
            String contentType = request.getContentType();
            Part avatarFile = null;
            if (contentType != null && contentType.toLowerCase().startsWith("multipart/")) {
                avatarFile = request.getPart("avatarFile");
            }

            // 优先使用上传文件
            if (avatarFile != null && avatarFile.getSize() > 0) {
                String avatarContentType = avatarFile.getContentType();
                if (avatarContentType == null || !avatarContentType.startsWith("image/")) {
                    request.setAttribute("error", "头像文件必须是图片格式");
                    request.setAttribute("user", userService.getUserById(user.getId()));
                    request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
                    return;
                }
                if (avatarFile.getSize() > 5 * 1024 * 1024) {
                    request.setAttribute("error", "头像图片不能超过5MB");
                    request.setAttribute("user", userService.getUserById(user.getId()));
                    request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
                    return;
                }

                String uploadPath = getServletContext().getRealPath("/static/images/avatar");
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String avatarFileName = UUID.randomUUID().toString()
                        + resolveImageExtension(getFileName(avatarFile), avatarContentType);
                uploadedAvatarPath = uploadPath + File.separator + avatarFileName;
                avatarFile.write(uploadedAvatarPath);
                avatarUrl = "/static/images/avatar/" + avatarFileName;
            } else {
                // 未上传文件时，支持链接方式（兼容旧流程）
                avatarUrl = request.getParameter("avatarUrl");
                if (avatarUrl != null) {
                    avatarUrl = avatarUrl.trim();
                }
                if (avatarUrl != null && !avatarUrl.isEmpty()
                        && !(avatarUrl.startsWith("http://") || avatarUrl.startsWith("https://") || avatarUrl.startsWith("/"))) {
                    avatarUrl = "/" + avatarUrl;
                }
            }

            if (avatarUrl == null || avatarUrl.isEmpty()) {
                request.setAttribute("error", "请上传头像图片，或填写头像链接");
                request.setAttribute("user", userService.getUserById(user.getId()));
                request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
                return;
            }

            if (userService.updateAvatar(user.getId(), avatarUrl)) {
                user.setAvatarUrl(avatarUrl);
                session.setAttribute("user", user);
                request.setAttribute("success", "头像更新成功");
            } else {
                if (uploadedAvatarPath != null) {
                    new File(uploadedAvatarPath).delete();
                }
                request.setAttribute("error", "更新失败");
            }
            request.setAttribute("user", userService.getUserById(user.getId()));
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
        } catch (Exception e) {
            if (uploadedAvatarPath != null) {
                new File(uploadedAvatarPath).delete();
            }
            request.setAttribute("error", "头像上传失败：" + e.getMessage());
            request.setAttribute("user", userService.getUserById(user.getId()));
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
        }
    }

    private String getFileName(Part part) {
        if (part == null) {
            return "";
        }
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null || contentDisp.isEmpty()) {
            return "";
        }
        for (String content : contentDisp.split(";")) {
            if (content.trim().startsWith("filename")) {
                String fileName = content.substring(content.indexOf("=") + 1).trim();
                if (fileName.startsWith("\"") && fileName.endsWith("\"") && fileName.length() > 1) {
                    fileName = fileName.substring(1, fileName.length() - 1);
                }
                return fileName;
            }
        }
        return "";
    }

    private String getFileExtension(String fileName, String defaultExt) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return defaultExt;
        }
        int dot = fileName.lastIndexOf('.');
        if (dot < 0 || dot == fileName.length() - 1) {
            return defaultExt;
        }
        String ext = fileName.substring(dot).toLowerCase();
        if (ext.length() > 10 || ext.contains("/") || ext.contains("\\")) {
            return defaultExt;
        }
        return ext;
    }

    private String resolveImageExtension(String fileName, String contentType) {
        String ext = getFileExtension(fileName, "");
        if (!ext.isEmpty() && isAllowedImageExtension(ext)) {
            return ext;
        }
        if ("image/png".equalsIgnoreCase(contentType)) return ".png";
        if ("image/gif".equalsIgnoreCase(contentType)) return ".gif";
        if ("image/webp".equalsIgnoreCase(contentType)) return ".webp";
        if ("image/jpeg".equalsIgnoreCase(contentType) || "image/jpg".equalsIgnoreCase(contentType)) return ".jpg";
        return ".jpg";
    }

    private boolean isAllowedImageExtension(String ext) {
        return ".png".equals(ext)
                || ".jpg".equals(ext)
                || ".jpeg".equals(ext)
                || ".gif".equals(ext)
            || ".webp".equals(ext);
    }

    //修改密码
    private void changePassword(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        if (userService.changePassword(user.getId(), oldPassword, newPassword)) {
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

    //显示历史浏览
    private void showHistory(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        List<com.assessment.www.po.History> historyList = videoService.getUserHistory(user.getId());
        for (History myhis : historyList) {
            try {
                User author = userService.getUserInfo(myhis.getUserId());
                myhis.setUser(author);
            } catch (Exception err) {
                err.printStackTrace();
            }
            try {
                Video videoDetail = videoService.getVideoDetail(myhis.getVideoId());
                myhis.setVideo(videoDetail);
            } catch (Exception err) {
                err.printStackTrace();
            }
        }
        request.setAttribute("historyList", historyList);
        request.getRequestDispatcher("/WEB-INF/views/history.jsp").forward(request, response);
    }

    // 显示我的收藏
    private void showFavorites(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) {
                page = 1;
            }
        } catch (NumberFormatException ignored) {
            page = 1;
        }

        int pageSize = 12;
        int totalCount = videoService.getUserFavoriteCount(user.getId());
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages <= 0) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
        }

        List<Video> favoriteVideos = videoService.getUserFavoriteVideos(user.getId(), page, pageSize);
        request.setAttribute("favoriteVideos", favoriteVideos);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/WEB-INF/views/favorites.jsp").forward(request, response);
    }

    //显示用户资料页面
    private void showUserProfile(HttpServletRequest request, HttpServletResponse response, int userId) throws Exception {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        User targetUser = userService.getUserInfo(userId);
        if (targetUser == null) {
            response.sendError(404, "用户不存在");
            return;
        }
        // 检查当前用户是否已关注该用户
        boolean isFollowing = false;
        if (currentUser != null) {
            isFollowing = userService.isFollowing(currentUser.getId(), userId);
        }
        // 获取用户视频列表
        VideoService videoService = new VideoServiceImpl();
        List<Video> userVideos = videoService.getUserVideos(userId);
        request.setAttribute("targetUser", targetUser);
        request.setAttribute("isFollowing", isFollowing);
        request.setAttribute("userVideos", userVideos);
        // 检查是否是用户自己的主页
        boolean isOwnProfile = (currentUser != null && currentUser.getId() == userId);
        request.setAttribute("isOwnProfile", isOwnProfile);
        request.getRequestDispatcher("/WEB-INF/views/userProfile.jsp").forward(request, response);
    }

    //封禁用户（管理员功能）
    private void banUser(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("user");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        int userId = Integer.parseInt(request.getParameter("userId"));
        if (userService.banUser(userId)) {
            request.setAttribute("success", "用户已封禁");
        } else {
            request.setAttribute("error", "操作失败");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    //解封用户（管理员功能）
    private void unbanUser(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("user");
        if (admin == null || !"admin".equals(admin.getRole())) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        int userId = Integer.parseInt(request.getParameter("userId"));
        if (userService.unbanUser(userId)) {
            request.setAttribute("success", "用户已解封");
        } else {
            request.setAttribute("error", "操作失败");
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    //关注用户
    private void followUser(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        int targetUserId = Integer.parseInt(request.getParameter("targetUserId"));
        if (userService.followUser(user.getId(), targetUserId)) {
            response.sendRedirect(request.getContextPath() + "/user/" + targetUserId);
        } else {
            request.setAttribute("error", "关注失败");
            response.sendRedirect(request.getContextPath() + "/user/" + targetUserId + "?error=1");
        }
    }

    //取消关注用户
    private void unfollowUser(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        int targetUserId = Integer.parseInt(request.getParameter("targetUserId"));
        if (userService.unfollowUser(user.getId(), targetUserId)) {
            response.sendRedirect(request.getContextPath() + "/user/" + targetUserId);
        } else {
            request.setAttribute("error", "取消关注失败");
            response.sendRedirect(request.getContextPath() + "/user/" + targetUserId + "?error=1");
        }
    }
}