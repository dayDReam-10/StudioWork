package com.assessment.www.Util;

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
        HttpSession session = request.getSession(false);// 获取当前会话，如果没有则返回null
        User user = session != null ? (User) session.getAttribute("user") : null;
        return user != null && user.getStatus() == Constants.STATUSNORMAL;
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
        //遍历所有评论并查找
        List<ScreenComment> comments = commentDao.getCommentsByVideoId(0);
        for (ScreenComment comment : comments) {
            if (comment.getId().equals(commentId) && comment.getUserId().equals(user.getId())) {
                return true;
            }
        }
        return false;
    }

    //用户登录
    public static void login(HttpServletRequest request, User user) {
        request.getSession().setAttribute("user", user);
    }

    //用户登出
    public static void logout(HttpServletRequest request) {
        request.getSession().invalidate();
    }

    //记载目前url，登陆后回返
    public static void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String requestUri = request.getRequestURI();
        String query = request.getQueryString();
        String backUrl = requestUri + (query != null ? "?" + query : "");
        response.sendRedirect(request.getContextPath() + "/user/login?back=" + java.net.URLEncoder.encode(backUrl, "UTF-8"));
    }
}