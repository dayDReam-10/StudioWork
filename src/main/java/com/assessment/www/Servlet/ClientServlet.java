package com.assessment.www.Servlet;

import com.assessment.www.Service.CheckInService;
import com.assessment.www.Service.CheckInServiceImpl;
import com.assessment.www.Service.VideoService;
import com.assessment.www.Service.VideoServiceImpl;
import com.assessment.www.Util.AuthUtil;
import com.assessment.www.dao.UserDao;
import com.assessment.www.dao.UserDaoImpl;
import com.assessment.www.po.User;
import com.assessment.www.constant.Constants;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/client/*")//修改其他进阶功能处理20260408
public class ClientServlet extends HttpServlet {
    private CheckInService checkInService = new CheckInServiceImpl();
    private VideoService videoService = new VideoServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.isLoggedIn(request)) {
            AuthUtil.redirectToLogin(request, response);
            return;
        }
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        User user = AuthUtil.getCurrentUser(request);
        switch (pathInfo) {
            case "/checkin":
                break;
            case "/profile":
                showProfile(request, response, user);
                break;
            case "/favorites":
                showFavorites(request, response, user);
                break;
            case "/favorite":
                favoriteVideo(request, response, user);
                break;
            case "/unfavorite":
                unfavoriteVideo(request, response, user);
                break;
            case "/checkin-history":
                showCheckInHistory(request, response, user);
                break;
            case "/search":
                searchVideos(request, response);
                break;
            case "/checkin-status":
                checkInStatus(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.isLoggedIn(request)) {
            response.sendError(401, "请登录");
            return;
        }
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(404, "错误请求");
            return;
        }
        User user = AuthUtil.getCurrentUser(request);
        switch (pathInfo) {
            case "/checkin":
                try {
                    performCheckIn(request, response, user);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case "/like":
                likeVideo(request, response, user);
                break;
            case "/unlike":
                unlikeVideo(request, response, user);
                break;
            case "/favorite":
                favoriteVideo(request, response, user);
                break;
            case "/unfavorite":
                unfavoriteVideo(request, response, user);
                break;
            case "/coin":
                coinVideo(request, response, user);
                break;
            case "/comment":
                addComment(request, response, user);
                break;
            case "/delete-comment":
                deleteComment(request, response, user);
                break;
            default:
                response.sendError(404, "请求不存在");
                break;
        }
    }

    // 签到功能
    private void performCheckIn(HttpServletRequest request, HttpServletResponse response, User user) throws Exception {
        com.assessment.www.po.CheckInResult result = checkInService.checkInWithResult(user.getId());
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (result.isSuccess()) {
            // 设置成功消息和获得的硬币数
            request.setAttribute("success", "true");
            request.setAttribute("coinReward", result.getCoinReward());
            response.getWriter().write("{\"success\": true, \"message\": \"success\", \"coinReward\": " + result.getCoinReward() + "}");
        } else {
            // 设置失败消息
            if (result.getMessage().contains("已经签到")) {
                request.setAttribute("error", "already");
                response.getWriter().write("{\"success\": false, \"message\": \"already\", \"error\": \"已签到\"}");
            } else {
                request.setAttribute("error", "other");
                response.getWriter().write("{\"success\": false, \"message\": \"other\", \"error\": \"错误\"}");
            }
        }
    }

    // 显示个人页面
    private void showProfile(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        // 获取用户发布的视频
        List<com.assessment.www.po.Video> userVideos = videoService.getUserVideos(user.getId());
        request.setAttribute("user", user);
        request.setAttribute("userVideos", userVideos);
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    // 显示收藏的视频
    private void showFavorites(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try {
            int page = 1;
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                try {
                    page = Integer.parseInt(pageStr);
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }
            List<com.assessment.www.po.Video> favoriteVideos = videoService.getUserFavoriteVideos(user.getId(), page, Constants.PAGESIZE);
            int totalFavorites = videoService.getUserFavoriteCount(user.getId());
            int totalPages = (int) Math.ceil((double) totalFavorites / Constants.PAGESIZE);
            // 构建JSON响应
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"videos\": [");
            for (int i = 0; i < favoriteVideos.size(); i++) {
                if (i > 0) {
                    json.append(",");
                }
                com.assessment.www.po.Video video = favoriteVideos.get(i);
                json.append("{");
                json.append("\"id\": ").append(video.getId()).append(",");
                json.append("\"title\": \"").append(video.getTitle() != null ? video.getTitle().replace("\"", "\\\"") : "").append("\",");
                json.append("\"coverUrl\": \"").append(video.getCoverUrl() != null ? video.getCoverUrl().replace("\"", "\\\"") : "").append("\",");
                json.append("\"description\": \"").append(video.getDescription() != null ? video.getDescription().replace("\"", "\\\"") : "").append("\",");
                json.append("\"viewCount\": ").append(video.getViewCount() != null ? video.getViewCount() : 0).append(",");
                json.append("\"likeCount\": ").append(video.getLikeCount() != null ? video.getLikeCount() : 0).append(",");
                json.append("\"coinCount\": ").append(video.getCoinCount() != null ? video.getCoinCount() : 0);
                json.append("}");
            }
            json.append("],");
            json.append("\"currentPage\": ").append(page).append(",");
            json.append("\"totalPages\": ").append(totalPages);
            json.append("}");
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\": \"获取收藏视频失败\"}");
        }
    }

    // 显示签到历史
    private void showCheckInHistory(HttpServletRequest request, HttpServletResponse response, User user) throws ServletException, IOException {
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        List<com.assessment.www.po.CheckIn> checkIns = checkInService.getUserCheckIns(user.getId(), page, Constants.PAGESIZE);
        int totalCheckIns = checkInService.getUserTotalCheckIns(user.getId());
        request.setAttribute("user", user);
        request.setAttribute("checkIns", checkIns);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalCheckIns", totalCheckIns);
        request.getRequestDispatcher("/WEB-INF/views/checkin-history.jsp").forward(request, response);
    }

    // 搜索视频
    private void searchVideos(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        int page = 1;
        if (keyword == null || keyword.trim().isEmpty()) {
            keyword = "";
        }
        String pageStr = request.getParameter("page");
        if (pageStr != null) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        List<com.assessment.www.po.Video> videos = videoService.searchVideos(keyword, page, Constants.PAGESIZE);
        int totalCount = videoService.getTotalVideoCount();
        request.setAttribute("keyword", keyword);
        request.setAttribute("videos", videos);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalCount", totalCount);
        request.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(request, response);
    }

    // 点赞视频
    private void likeVideo(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String videoIdStr = request.getParameter("videoId");
        if (videoIdStr == null) {
            response.sendError(404, "参数错误");
            return;
        }
        try {
            int videoId = Integer.parseInt(videoIdStr);
            boolean success = videoService.likeVideo(user.getId(), videoId);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": " + success + "}");
        } catch (NumberFormatException e) {
            response.sendError(404, "参数错误");
        }
    }

    // 取消点赞
    private void unlikeVideo(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String videoIdStr = request.getParameter("videoId");
        if (videoIdStr == null) {
            response.sendError(404, "参数传错误");
            return;
        }
        try {
            int videoId = Integer.parseInt(videoIdStr);
            boolean success = videoService.unlikeVideo(user.getId(), videoId);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": " + success + "}");
        } catch (NumberFormatException e) {
            response.sendError(404, "参数错误");
        }
    }

    // 收藏视频
    private void favoriteVideo(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String videoIdStr = request.getParameter("videoId");
        if (videoIdStr == null) {
            response.sendError(404, "参数错误");
            return;
        }
        try {
            int videoId = Integer.parseInt(videoIdStr);
            boolean success = videoService.favoriteVideo(user.getId(), videoId);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": " + success + "}");
        } catch (NumberFormatException e) {
            response.sendError(404, "参数错误");
        }
    }

    // 取消收藏
    private void unfavoriteVideo(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String videoIdStr = request.getParameter("videoId");
        if (videoIdStr == null) {
            response.sendError(404, "参数错误");
            return;
        }
        try {
            int videoId = Integer.parseInt(videoIdStr);
            boolean success = videoService.unfavoriteVideo(user.getId(), videoId);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": " + success + "}");
        } catch (NumberFormatException e) {
            response.sendError(404, "参数错误");
        }
    }

    // 添加评论
    private void addComment(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String videoIdStr = request.getParameter("videoId");
        String parenidstr = request.getParameter("parenid");
        String content = request.getParameter("content");
        String timeStr = request.getParameter("time");
        if (videoIdStr == null || content == null || content.trim().isEmpty()) {
            response.sendError(404, "参数错误");
            return;
        }
        try {
            int videoId = Integer.parseInt(videoIdStr);
            int parenid = Integer.parseInt(parenidstr);
            float time = timeStr != null ? Float.parseFloat(timeStr) : 0;
            boolean success = videoService.sendComment(videoId, user.getId(), content, time, parenid);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": " + success + "}");
        } catch (NumberFormatException e) {
            response.sendError(404, "添加评论报错");
        }
    }

    // 删除评论
    private void deleteComment(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String commentIdStr = request.getParameter("commentId");
        if (commentIdStr == null) {
            response.sendError(404, "id为空");
            return;
        }
        try {
            // 需要先获取评论ID对应的视频ID，然后删除
            // 这里简化处理，直接调用删除方法
            boolean success = videoService.deleteComment(Integer.parseInt(commentIdStr), user.getId());
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": " + success + "}");
        } catch (NumberFormatException e) {
            response.sendError(404, "ID为空");
        }
    }

    // 检查签到状态
    private void checkInStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        try {
            User user = AuthUtil.getCurrentUser(request);
            boolean hasCheckedIn = checkInService.hasCheckedInToday(user.getId());
            response.getWriter().write("{\"checkedIn\": " + hasCheckedIn + "}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"checkedIn\": false, \"error\": \"签到失败\"}");
        }
    }

    // 投币视频
    private void coinVideo(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String videoIdStr = request.getParameter("videoId");
        String amountStr = request.getParameter("amount");
        if (videoIdStr == null || amountStr == null) {
            response.sendError(404, "参数错误");
            return;
        }
        try {
            int videoId = Integer.parseInt(videoIdStr);
            int amount = Integer.parseInt(amountStr);
            boolean success = videoService.coinVideo(user.getId(), videoId, amount);
            response.setContentType("application/json");
            if (!success) {
                // 检查是否是硬币不足
                UserDao userDao = new UserDaoImpl();
                int userCoins = userDao.getCoinCount(user.getId());
                if (userCoins < amount) {
                    response.getWriter().write("{\"success\": false, \"error\": \"投币成功\"}");
                } else {
                    response.getWriter().write("{\"success\": false, \"error\": \"投币失败\"}");
                }
            } else {
                response.getWriter().write("{\"success\": true}");
            }
        } catch (NumberFormatException e) {
            response.sendError(404, "参数错误");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"error\": \"服务报错\"}");
        }
    }
}