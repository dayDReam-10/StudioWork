package com.assessment.www.Servlet;

import com.assessment.www.Service.*;
import com.assessment.www.Util.AuthUtil;
import com.assessment.www.constant.Constants;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ScreenComment;
import com.assessment.www.po.User;
import com.assessment.www.po.Video;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import javax.servlet.annotation.MultipartConfig;

//视频相关Servlet
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,   // 2MB 内存缓存
        maxFileSize = 1024 * 1024 * 500,       // 单个文件最大 500MB
        maxRequestSize = 1024 * 1024 * 500     // 整个请求最大 500MB
)
public class VideoServlet extends HttpServlet {
    private VideoService videoService;
    private UserService userService = new UserServiceImpl();
    private CommentService commentService = new CommentServiceImpl();
    private ReportService reportService = new ReportServiceImpl();

    @Override
    public void init() throws ServletException {
        videoService = new VideoServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        switch (pathInfo) {
            case "/list":
                showVideoList(request, response);
                break;
            case "/dynamic":
                showDynamicFeed(request, response);
                break;
            case "/upload":
                showUploadForm(request, response);
                break;
            case "/detail":
                showVideoDetail(request, response);
                break;
            case "/myvideos":
                showMyVideos(request, response);
                break;
            case "/search":
                searchVideos(request, response);
                break;
            case "/download":
                downloadVideo(request, response);
                break;
            default:
                throw new BaseException(404, "页面不存在");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.isLoggedIn(request)) {
            throw new BaseException(401, "请先登录");
        }
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            throw new BaseException(400, "错误请求");
        }
        User user = AuthUtil.getCurrentUser(request);
        switch (pathInfo) {
            case "/upload":
                uploadVideo(request, response);
                break;
            case "/play":
                playVideo(request, response);
                break;
            case "/like":
                likeVideo(request, response);
                break;
            case "/unlike":
                unlikeVideo(request, response);
                break;
            case "/favorite":
                favoriteVideo(request, response);
                break;
            case "/unfavorite":
                unfavoriteVideo(request, response);
                break;
            case "/coin":
                coinVideo(request, response);
                break;
            case "/comment":
                addComment(request, response);
                break;
            case "/deleteComment":
                deleteComment(request, response);
                break;
            case "/deleteReply":
                deleteReply(request, response);
                break;
            case "/deleteReply2":
                deleteReply2(request, response);
                break;
            case "/delete":
                deleteVideo(request, response);
                break;
            case "/update":
                updateVideo(request, response);
                break;
            case "/report":
                reportVideo(request, response, user);
                break;
            case "/download":
                downloadVideo(request, response);
                break;
            default:
                throw new BaseException(404, "接口不存在");
        }
    }

    //显示视频列表 - 返回JSON数据
    private void showVideoList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            page = 1;
        }
        User currentUser = AuthUtil.getCurrentUser(request);
        // 从数据库获取数据
        List<Video> videos = videoService.searchVideos(currentUser, keyword, page, 10);
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        int totalCount = hasKeyword ? videoService.getTotalVideoCount(currentUser) : videoService.getPublicVideoCount(currentUser);
        int totalPages = (int) Math.ceil((double) totalCount / 10);
        // 构建JSON响应
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"videos\":[");
        String contextPath = request.getContextPath();
        for (int i = 0; i < videos.size(); i++) {
            Video video = videos.get(i);
            json.append("{");
            json.append("\"id\":").append(video.getId()).append(",");
            json.append("\"title\":\"").append(escapeJson(video.getTitle())).append("\",");
            String coverUrl = video.getCoverUrl() != null ? video.getCoverUrl() : "";
            if (!coverUrl.startsWith("http") && !coverUrl.startsWith("/")) {
                coverUrl = contextPath + "/" + coverUrl;
            }
            json.append("\"coverUrl\":\"").append(escapeJson(coverUrl)).append("\",");
            json.append("\"viewCount\":").append(video.getViewCount()).append(",");
            json.append("\"likeCount\":").append(video.getLikeCount()).append(",");
            json.append("\"favCount\":").append(video.getFavCount()).append(",");
            json.append("\"authorId\":").append(video.getAuthorId()).append(",");
            String videoUrl = video.getVideoUrl() != null ? video.getVideoUrl() : "";
            if (!videoUrl.startsWith("http") && !videoUrl.startsWith("/")) {
                videoUrl = contextPath + "/" + videoUrl;
            }
            json.append("\"videoUrl\":\"").append(escapeJson(videoUrl)).append("\"");
            json.append("}");
            if (i < videos.size() - 1) {
                json.append(",");
            }
        }
        json.append("],");
        json.append("\"currentPage\":").append(page).append(",");
        json.append("\"totalPages\":").append(totalPages).append(",");
        json.append("\"totalCount\":").append(totalCount);
        json.append("}");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(json.toString());
    }

    //转义JSON字符串中的特殊字符
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("\t", "\\t");
    }

    //显示上传表单
    private void showUploadForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new BaseException(401, "请先登录");
        }
        request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
    }

    //显示视频详情
    private void showVideoDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int videoId = Integer.parseInt(request.getParameter("id"));
        Video video = videoService.getVideoDetail(videoId);
        if (video == null) {
            throw new BaseException(404, "视频不存在");
        }
        normalizeMediaPaths(video);
        // 检查视频文件是否存在
        try {
            String videoUrl = video.getVideoUrl();
            if (videoUrl != null && !videoUrl.trim().isEmpty()) {
                String pathForReal = videoUrl.startsWith("/") ? videoUrl : ("/" + videoUrl);
                String realPath = getServletContext().getRealPath(pathForReal);
                if (realPath == null) {
                    request.setAttribute("videoFileMissing", true);
                    request.setAttribute("videoFileMissingMessage", "无法解析视频文件的服务器路径");
                } else {
                    File vf = new File(realPath);
                    if (!vf.exists() || !vf.isFile()) {
                        request.setAttribute("videoFileMissing", true);
                        request.setAttribute("videoFileMissingMessage", "视频文件在服务器上未找到");
                    }
                }
            }
        } catch (Exception e) {
            request.setAttribute("videoFileMissing", true);
            request.setAttribute("videoFileMissingMessage", "检查视频文件存在时发生错误");
        }
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (!isVideoVisibleToCurrentUser(video, user)) {
            throw new BaseException(404, "视频不存在");
        }
        if (user != null) {
            videoService.saveHistory(user.getId(), videoId);
        }
        List<ScreenComment> topLevelComments = commentService.getVideoComments(videoId);
        for (ScreenComment screenComment : topLevelComments) {
            if (screenComment != null && screenComment.getUser() == null) {
                try {
                    screenComment.setUser(userService.getUserById(screenComment.getUserId()));
                } catch (Exception e) {
                }
            }
        }
        request.setAttribute("video", video);
        request.setAttribute("topLevelComments", topLevelComments);
        request.setAttribute("commentCount", commentService.getCommentCount(videoId));
        if (user != null) {
            request.setAttribute("hasLiked", videoService.isLiked(user.getId(), videoId));
            request.setAttribute("hasFavorited", videoService.isFavorited(user.getId(), videoId));
            boolean hasReported = reportService.checkReported(user.getId(), videoId);
            request.setAttribute("hasReported", hasReported);
        }
        request.getRequestDispatcher("/WEB-INF/views/videoDetail.jsp").forward(request, response);
    }

    //上传视频
    private void uploadVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new BaseException(401, "请先登录");
        }
        Part videoFile;
        try {
            videoFile = request.getPart("videoFile");
        } catch (Exception e) {
            throw new BaseException(500, "获取文件失败");
        }
        if (videoFile == null || videoFile.getSize() == 0) {
            request.setAttribute("error", "请选择有效的视频文件");
            request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
            return;
        }
        String fileName = getFileName(videoFile);
        String contentType = videoFile.getContentType();
        if (!contentType.startsWith("video/")) {
            request.setAttribute("error", "请上传视频文件");
            request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
            return;
        }
        long fileSize = videoFile.getSize();
        if (fileSize > 500 * 1024 * 1024) {
            request.setAttribute("error", "文件大小不能超过500MB");
            request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
            return;
        }
        String uploadPath = getServletContext().getRealPath("/static/videos");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        String fileExtension = fileName.substring(fileName.lastIndexOf("."));
        String newFileName = UUID.randomUUID().toString() + fileExtension;
        String filePath = uploadPath + File.separator + newFileName;
        try {
            videoFile.write(filePath);
        } catch (Exception e) {
            throw new BaseException(500, "文件保存失败");
        }
        Video video = new Video();
        video.setTitle(request.getParameter("title"));
        video.setDescription(request.getParameter("description"));
        video.setAuthorId(user.getId());
        video.setVideoUrl("/static/videos/" + newFileName);
        video.setTimeCreate(new java.sql.Timestamp(System.currentTimeMillis()));
        String coverUrl = request.getParameter("coverUrl");
        if (coverUrl != null && !coverUrl.trim().isEmpty()) {
            video.setCoverUrl(coverUrl);
        } else {
            video.setCoverUrl(Constants.DEFAULT_COVER);
        }
        String visibility = request.getParameter("visibility");
        if (visibility != null && !visibility.trim().isEmpty()) {
            video.setVisibility(visibility);
        } else {
            video.setVisibility("public");
        }
        if (!videoService.uploadVideo(video)) {
            new File(filePath).delete();
            throw new BaseException(500, "视频信息保存失败");
        }
        response.sendRedirect(request.getContextPath() + "/video/detail?id=" + video.getId());
    }

    //从Part中获取文件名
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
                // 去掉可能存在的引号
                if (fileName.startsWith("\"")) {
                    fileName = fileName.substring(1, fileName.length() - 1);
                }
                return fileName;
            }
        }
        return "";
    }

    //播放视频
    private void playVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int videoId = Integer.parseInt(request.getParameter("id"));
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Video video = videoService.getVideoDetail(videoId);
        if (video == null) {
            response.sendError(404);
            return;
        }
        normalizeMediaPaths(video);
        // 检查视频文件是否真实存在（如果是部署在本地文件系统）
        try {
            String videoUrl = video.getVideoUrl();
            if (videoUrl != null && !videoUrl.trim().isEmpty()) {
                String pathForReal = videoUrl.startsWith("/") ? videoUrl : ("/" + videoUrl);
                String realPath = getServletContext().getRealPath(pathForReal);
                if (realPath == null) {
                    request.setAttribute("videoFileMissing", true);
                    request.setAttribute("videoFileMissingMessage", "无法解析视频文件的服务器路径");
                } else {
                    File vf = new File(realPath);
                    if (!vf.exists() || !vf.isFile()) {
                        request.setAttribute("videoFileMissing", true);
                        request.setAttribute("videoFileMissingMessage", "视频文件在服务器上未找到: " + pathForReal);
                    }
                }
            }
        } catch (Exception e) {
            request.setAttribute("videoFileMissing", true);
            request.setAttribute("videoFileMissingMessage", "检查视频文件存在时发生错误");
        }
        if (!isVideoVisibleToCurrentUser(video, user)) {
            response.sendError(404);
            return;
        }
        // 增加播放量
        videoService.playVideo(videoId);
        request.setAttribute("video", video);
        // 如果文件缺失，将信息传到前端，便于展示友好提示
        request.getRequestDispatcher("/WEB-INF/views/player.jsp").forward(request, response);
    }

    //点赞视频
    private void likeVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("id"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (videoService.likeVideo(user.getId(), videoId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"点赞成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"点赞失败\"}");
        }
    }

    //取消点赞视频
    private void unlikeVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("id"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (videoService.unlikeVideo(user.getId(), videoId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"取消点赞成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"取消点赞失败\"}");
        }
    }

    //收藏视频
    private void favoriteVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("id"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (videoService.favoriteVideo(user.getId(), videoId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"收藏成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"收藏失败\"}");
        }
    }

    //取消收藏视频
    private void unfavoriteVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("id"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (videoService.unfavoriteVideo(user.getId(), videoId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"取消收藏成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"取消收藏失败\"}");
        }
    }

    //投币方法
    private void coinVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("id"));
        int amount = Integer.parseInt(request.getParameter("amount"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (amount < 1 || amount > 2) {
            response.getWriter().write("{\"success\":false,\"message\":\"投币数量必须在1-2之间\"}");
            return;
        }
        if (videoService.coinVideo(user.getId(), videoId, amount)) {
            response.getWriter().write("{\"success\":true,\"message\":\"投币成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"投币失败，硬币不足\"}");
        }
    }

    //添加
    private void addComment(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("videoId"));
        String content = request.getParameter("content");
        float time = 0;
        Integer parentId = null;
        if (request.getParameter("parentId") != null && !request.getParameter("parentId").isEmpty()) {
            parentId = Integer.parseInt(request.getParameter("parentId"));
        }
        // 处理照片上传
        String photoBase64 = request.getParameter("photo");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (photoBase64 != null && !photoBase64.isEmpty()) {
            if (videoService.sendComment(videoId, user.getId(), content, photoBase64, time, parentId)) {
                response.getWriter().write("{\"success\":true,\"message\":\"发送成功\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"发送失败\"}");
            }
        } else {
            if (videoService.sendComment(videoId, user.getId(), content, time, parentId)) {
                response.getWriter().write("{\"success\":true,\"message\":\"发送成功\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"发送失败\"}");
            }
        }
    }

    //删除评论
    private void deleteComment(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int commentId = Integer.parseInt(request.getParameter("commentId"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (videoService.deleteComment(commentId, user.getId())) {
            response.getWriter().write("{\"success\":true,\"message\":\"删除成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"删除失败\"}");
        }
    }

    //删除回复
    private void deleteReply(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int replyId = Integer.parseInt(request.getParameter("replyId"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (videoService.deleteReply(replyId, user.getId())) {
            response.getWriter().write("{\"success\":true,\"message\":\"删除成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"删除失败\"}");
        }
    }

    //删除二级回复
    private void deleteReply2(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int reply2Id = Integer.parseInt(request.getParameter("reply2Id"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (videoService.deleteReply2(reply2Id, user.getId())) {
            response.getWriter().write("{\"success\":true,\"message\":\"删除成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"删除失败\"}");
        }
    }

    //删除视频
    private void deleteVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("id"));
        if (videoService.deleteVideo(videoId, user.getId())) {
            response.sendRedirect(request.getContextPath() + "/video/myvideos?success=视频删除成功");
        } else {
            response.sendRedirect(request.getContextPath() + "/video/myvideos?error=视频删除失败");
        }
    }

    //更新视频
    private void updateVideo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"needLogin\":true,\"message\":\"请先登录\"}");
            return;
        }
        int videoId = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        String coverUrl = request.getParameter("coverUrl");
        String description = request.getParameter("description");
        if (videoService.updateVideoBaseInfo(videoId, title, coverUrl, description, user.getId())) {
            response.sendRedirect(request.getContextPath() + "/video/detail?id=" + videoId);
        } else {
            request.setAttribute("error", "更新失败");
            response.sendRedirect(request.getContextPath() + "/video/detail?id=" + videoId + "&error=1");
        }
    }

    //显示我的视频
    private void showMyVideos(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        List<Video> videos = videoService.getUserVideos(user.getId(), user);
        request.setAttribute("videos", videos);
        request.getRequestDispatcher("/WEB-INF/views/myVideos.jsp").forward(request, response);
    }

    //搜索视频
    private void searchVideos(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            page = 1;
        }
        if (keyword != null && keyword.trim().isEmpty()) {
            keyword = null;
        }
        // 获取当前登录用户
        User currentUser = AuthUtil.getCurrentUser(request);
        List<Video> videos = videoService.searchVideos(keyword, page, 10, currentUser);
        // 填充作者信息
        if (videos != null && videos.size() > 0) {
            for (Video video : videos) {
                try {
                    User author = userService.getUserInfo(video.getAuthorId());
                    video.setAuthor(author);
                } catch (Exception err) {
                    err.printStackTrace();
                }
            }
        } else {
            videos = new ArrayList<>();
        }
        // 获取总数（总数仍然使用原来的方法）
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        int totalCount = hasKeyword ? videoService.getTotalVideoCount(currentUser) : videoService.getPublicVideoCount(currentUser);
        int totalPages = (int) Math.ceil((double) totalCount / 10);
        request.setAttribute("videos", videos);
        request.setAttribute("keyword", keyword == null ? "" : keyword);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/WEB-INF/views/videoList.jsp").forward(request, response);
    }

    //动态页：关注用户发布的视频
    private void showDynamicFeed(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            page = 1;
        }
        int pageSize = 12;
        int totalCount = videoService.getFollowingVideoCount(user.getId(), user);
        List<Video> videos = videoService.getFollowingVideos(user.getId(), user, page, pageSize);
        int totalPages = totalCount == 0 ? 1 : (int) Math.ceil((double) totalCount / pageSize);
        request.setAttribute("videos", videos);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.getRequestDispatcher("/WEB-INF/views/dynamic.jsp").forward(request, response);
    }

    // 举报视频
    private void reportVideo(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String videoIdStr = request.getParameter("videoId");
        String reason = request.getParameter("reason");
        if (videoIdStr == null || reason == null) {
            response.sendError(404, "参数错误");
            return;
        }
        try {
            int videoId = Integer.parseInt(videoIdStr);
            boolean success = videoService.reportVideo(videoId, user.getId(), reason);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": " + success + "}");
        } catch (NumberFormatException e) {
            response.sendError(404, "举报失败");
        }
    }

    // 下载视频
    private void downloadVideo(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int videoId = Integer.parseInt(request.getParameter("id"));
        Video video = videoService.getVideoDetail(videoId);
        if (video == null) {
            response.sendError(404, "视频不存在");
            return;
        }
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (!isVideoVisibleToCurrentUser(video, user)) {
            response.sendError(404, "视频不存在");
            return;
        }
        // 获取视频文件路径
        String videoUrl = video.getVideoUrl();
        if (videoUrl == null || videoUrl.trim().isEmpty()) {
            response.sendError(404, "视频文件不存在");
            return;
        }
        File videoFile;
        if (videoUrl.startsWith("/")) {
            videoFile = new File(getServletContext().getRealPath(videoUrl));
        } else if (!videoUrl.startsWith("http")) {
            videoFile = new File(getServletContext().getRealPath("/static/videos/" + videoUrl));
        } else {
            response.sendError(404, "不支持下载外部URL视频");
            return;
        }
        // 检查文件是否存在
        if (!videoFile.exists() || !videoFile.isFile()) {
            response.sendError(404, "视频文件不存在");
            return;
        }
        try {
            // 获取文件名
            String fileName = video.getTitle() + videoUrl.substring(videoUrl.lastIndexOf("."));
            fileName = new String(fileName.getBytes("UTF-8"), "ISO-8859-1");
            // 设置响应头
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            response.setHeader("Content-Length", String.valueOf(videoFile.length()));
            // 读取文件并写入响应输出流
            try (InputStream in = new FileInputStream(videoFile);
                 ServletOutputStream out = response.getOutputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
                out.flush();
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "下载失败：" + e.getMessage());
        }
    }

    private boolean isVideoVisibleToCurrentUser(Video video, User user) {
        if (video == null) {
            return false;
        }
        try {
            List<Video> visibleVideos = videoService.getUserVideos(video.getAuthorId(), user);
            for (Video visibleVideo : visibleVideos) {
                if (visibleVideo != null && visibleVideo.getId() != null && visibleVideo.getId().equals(video.getId())) {
                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private void normalizeMediaPaths(Video video) {
        if (video == null) {
            return;
        }
        video.setVideoUrl(normalizeUrl(video.getVideoUrl(), "/static/videos/"));
        video.setCoverUrl(normalizeUrl(video.getCoverUrl(), "/static/images/"));
    }

    private String normalizeUrl(String value, String defaultPrefix) {
        if (value == null || value.trim().isEmpty()) {
            return value;
        }
        String trimmed = value.trim();
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            return trimmed;
        }
        // 已经是绝对路径（以 / 开头）
        if (trimmed.startsWith("/")) {
            return trimmed;
        }
        // defaultPrefix 形如 "/static/videos/" 或 "/static/images/"
        String prefixNoSlash = defaultPrefix.startsWith("/") ? defaultPrefix.substring(1) : defaultPrefix;
        // 如果 value 已经包含了类似 "static/videos/..."（但没有前导 /），则只加前导斜杠，避免重复前缀
        if (trimmed.startsWith(prefixNoSlash)) {
            return "/" + trimmed;
        }
        return defaultPrefix + trimmed;
    }
}