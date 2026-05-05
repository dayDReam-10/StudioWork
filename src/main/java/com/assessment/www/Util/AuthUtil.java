package com.assessment.www.Util;

import com.assessment.www.Service.UserService;
import com.assessment.www.po.User;
import com.assessment.www.po.ScreenComment;
import com.assessment.www.constant.Constants;
import com.assessment.www.Service.VideoService;
import com.assessment.www.dao.ScreenCommentDao;
import com.assessment.www.po.Video;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class AuthUtil {
    //检查用户是否已登录
    public static boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        return user != null && user.getStatus() == Constants.STATUSNORMAL;
    }

    //检查是否是管理员
    public static boolean isAdmin(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && Constants.ROLEADMIN.equals(user.getRole());
    }

    //获取当前登录用户
    public static User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (User) session.getAttribute("user") : null;
    }

    //检查用户是否有指定权限
    public static boolean hasPermission(HttpServletRequest request, String requiredRole) {
        User user = getCurrentUser(request);
        if (user == null) {
            return false;
        }
        // admin拥有所有权限
        if (Constants.ROLEADMIN.equals(user.getRole())) {
            return true;
        }
        return requiredRole != null && requiredRole.equals(user.getRole());
    }

    //检查用户是否是视频的作者
    public static boolean isVideoAuthor(HttpServletRequest request, Integer videoId, VideoService videoService) {
        User user = getCurrentUser(request);
        if (user == null) {
            return false;
        }
        Video video = videoService.getVideoDetail(videoId);
        return video != null && video.getAuthorId().equals(user.getId());
    }

    //检查用户是否是评论的作者
    public static boolean isCommentAuthor(HttpServletRequest request, Integer commentId, ScreenCommentDao commentDao) {
        User user = getCurrentUser(request);
        if (user == null) {
            return false;
        }
        // 获取所有评论并查找
        List<ScreenComment> comments = commentDao.getCommentsByVideoId(0);
        for (ScreenComment comment : comments) {
            if (comment.getId().equals(commentId) && comment.getUserId().equals(user.getId())) {
                return true;
            }
        }
        return false;
    }

    //刷新当前 Session 中的用户状态如果用户已被封禁或删除，则自动登出
    public static boolean refreshUserStatus(HttpServletRequest request, UserService userService) throws Exception {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) {
            return false;
        }
        User latestUser = userService.getUserById(sessionUser.getId());
        if (latestUser == null || latestUser.getStatus() != Constants.STATUSNORMAL) {
            logout(request);  // 用户不存在或被封禁，强制登出
            return false;
        }
        session.setAttribute("user", latestUser);
        return true;
    }

    //用户登录
    public static void login(HttpServletRequest request, User user) {
        request.getSession().setAttribute("user", user);
    }

    //用户登出
    public static void logout(HttpServletRequest request) {
        request.getSession().invalidate();
    }

    //重定向到登录页面，并添加返回URL
    public static void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String requestUri = request.getRequestURI();
        String query = request.getQueryString();
        String backUrl = requestUri + (query != null ? "?" + query : "");
        response.sendRedirect(request.getContextPath() + "/user/login");
    }
}