package com.assessment.www.Servlet;

import com.assessment.www.Service.*;
import com.assessment.www.Util.AuthUtil;
import com.assessment.www.constant.Constants;
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
        videoService = new VideoServiceImpl(getServletContext());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        switch (pathInfo) {//针对不同路径GET请求处理不同方法
            case "/list":
                showVideoList(request, response);
                break;
            case "/upload":
                showUploadForm(request, response);
                break;
            case "/detail":
                try {
                    showVideoDetail(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                }
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
                response.sendError(404);
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
        switch (pathInfo) {//针对不同路径POST请求处理不同方法
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
                response.sendError(404);
                break;
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
        List<Video> videos = videoService.searchVideos(keyword, page, 10);
        int totalCount = videoService.getTotalVideoCount();
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
            String coverUrl = normalizeResourceUrl(video.getCoverUrl(), contextPath, Constants.DEFAULT_COVER);
            json.append("\"coverUrl\":\"").append(escapeJson(coverUrl)).append("\",");
            json.append("\"viewCount\":").append(video.getViewCount()).append(",");
            json.append("\"likeCount\":").append(video.getLikeCount()).append(",");
            json.append("\"favCount\":").append(video.getFavCount()).append(",");
            json.append("\"authorId\":").append(video.getAuthorId()).append(",");
            String videoUrl = normalizeResourceUrl(video.getVideoUrl(), contextPath, "");
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
        // 返回JSON格式数据
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(json.toString());
    }

    private String normalizeResourceUrl(String rawUrl, String contextPath, String fallbackUrl) {
        String url = rawUrl;
        if (url == null || url.trim().isEmpty()) {
            url = fallbackUrl;
        }
        if (url == null || url.trim().isEmpty()) {
            return "";
        }
        url = url.trim();
        if (url.startsWith("http://") || url.startsWith("https://") || url.startsWith("data:") || url.startsWith("//")) {
            return url;
        }
        if (url.startsWith("/")) {
            return contextPath + url;
        }
        return contextPath + "/" + url;
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
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
    }

    //显示视频详情
    private void showVideoDetail(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int videoId = Integer.parseInt(request.getParameter("id"));
        Video video = videoService.getVideoDetail(videoId);
        if (video == null) {
            response.sendError(404);
            return;
        }
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        // 保存观看历史
        if (user != null) {
            videoService.saveHistory(user.getId(), videoId);
        }
        // 获取评论并分离弹幕（有视频时间）与普通评论（无视频时间）
        List<ScreenComment> rawTopLevelComments = commentService.getVideoComments(videoId);
        List<ScreenComment> topLevelComments = new ArrayList<>();
        List<ScreenComment> danmuComments = new ArrayList<>();
        for (ScreenComment screenComment : rawTopLevelComments) {
            if (screenComment != null && screenComment.getUser() == null) {
                screenComment.setUser(userService.getUserById(screenComment.getUserId()));
            }
            if (screenComment == null) {
                continue;
            }
            Float videoTime = screenComment.getVideoTime();
            boolean isTopLevel = screenComment.getParentId() == null || screenComment.getParentId() == 0;
            boolean isDanmu = isTopLevel && videoTime != null && videoTime > 0.01f;
            if (isDanmu) {
                danmuComments.add(screenComment);
            } else {
                topLevelComments.add(screenComment);
            }
        }
        request.setAttribute("video", video);
        request.setAttribute("topLevelComments", topLevelComments);
        request.setAttribute("danmuComments", danmuComments);
        request.setAttribute("commentCount", topLevelComments.size());
        // 如果用户已登录，检查点赞和收藏、举报状态
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
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        String savedVideoPath = null;
        String savedCoverPath = null;
        try {
            // 获取上传的视频文件
            Part videoFile = request.getPart("videoFile");
            if (videoFile == null || videoFile.getSize() == 0) {
                request.setAttribute("error", "请选择有效的视频文件");
                request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
                return;
            }
            String fileName = getFileName(videoFile);
            // 验证文件类型
            String contentType = videoFile.getContentType();
            if (!contentType.startsWith("video/")) {
                request.setAttribute("error", "请上传视频文件");
                request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
                return;
            }
            // 验证文件大小（限制为500MB）
            long fileSize = videoFile.getSize();
            if (fileSize > 500 * 1024 * 1024) {
                request.setAttribute("error", "文件大小不能超过500MB");
                request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
                return;
            }
            // 创建上传目录
            String uploadPath = getServletContext().getRealPath("/static/videos");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            // 生成新的文件名
            String fileExtension = getFileExtension(fileName, ".mp4");
            String newFileName = UUID.randomUUID().toString() + fileExtension;
            String filePath = uploadPath + File.separator + newFileName;
            // 保存文件
            videoFile.write(filePath);
            savedVideoPath = filePath;
            // 创建视频对象
            Video video = new Video();
            video.setTitle(request.getParameter("title"));
            video.setDescription(request.getParameter("description"));
            video.setAuthorId(user.getId());
            video.setVideoUrl("/static/videos/" + newFileName);

            // 优先处理上传封面图片，其次使用封面链接，最后使用默认封面
            Part coverFile = request.getPart("coverFile");
            if (coverFile != null && coverFile.getSize() > 0) {
                String coverContentType = coverFile.getContentType();
                if (coverContentType == null || !coverContentType.startsWith("image/")) {
                    if (savedVideoPath != null) new File(savedVideoPath).delete();
                    request.setAttribute("error", "封面文件必须是图片格式");
                    request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
                    return;
                }
                if (coverFile.getSize() > 5 * 1024 * 1024) {
                    if (savedVideoPath != null) new File(savedVideoPath).delete();
                    request.setAttribute("error", "封面图片不能超过5MB");
                    request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
                    return;
                }
                String coverUploadPath = getServletContext().getRealPath("/static/images/covers");
                File coverDir = new File(coverUploadPath);
                if (!coverDir.exists()) {
                    coverDir.mkdirs();
                }
                String coverFileName = UUID.randomUUID().toString()
                        + resolveImageExtension(getFileName(coverFile), coverContentType);
                String coverPath = coverUploadPath + File.separator + coverFileName;
                coverFile.write(coverPath);
                savedCoverPath = coverPath;
                video.setCoverUrl("/static/images/covers/" + coverFileName);
            } else {
                String coverUrl = request.getParameter("coverUrl");
                if (coverUrl != null) {
                    coverUrl = coverUrl.trim();
                }
                if (coverUrl != null && !coverUrl.isEmpty()) {
                    if (!coverUrl.startsWith("http://") && !coverUrl.startsWith("https://") && !coverUrl.startsWith("/")) {
                        coverUrl = "/" + coverUrl;
                    }
                    video.setCoverUrl(coverUrl);
                } else {
                    video.setCoverUrl(Constants.DEFAULT_COVER);
                }
            }

            // 保存视频信息到数据库
            if (videoService.uploadVideo(video)) {
                response.sendRedirect(request.getContextPath() + "/video/detail?id=" + video.getId());
            } else {
                // 如果数据库保存失败，删除已上传的文件
                if (savedVideoPath != null) new File(savedVideoPath).delete();
                if (savedCoverPath != null) new File(savedCoverPath).delete();
                request.setAttribute("error", "视频信息保存失败");
                request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (savedVideoPath != null) new File(savedVideoPath).delete();
            if (savedCoverPath != null) new File(savedCoverPath).delete();
            request.setAttribute("error", "上传失败：" + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/upload.jsp").forward(request, response);
        }
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
        if (!ext.isEmpty()) {
            return ext;
        }
        if ("image/png".equalsIgnoreCase(contentType)) return ".png";
        if ("image/gif".equalsIgnoreCase(contentType)) return ".gif";
        if ("image/webp".equalsIgnoreCase(contentType)) return ".webp";
        if ("image/jpeg".equalsIgnoreCase(contentType) || "image/jpg".equalsIgnoreCase(contentType)) return ".jpg";
        return ".jpg";
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
        // 增加播放量
        videoService.playVideo(videoId);
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
        String timeStr = request.getParameter("time");
        if (timeStr != null && !timeStr.trim().isEmpty()) {
            try {
                time = Float.parseFloat(timeStr.trim());
                if (time < 0) {
                    time = 0;
                }
            } catch (NumberFormatException ignored) {
                time = 0;
            }
        }
        Integer parentId = null;
        if (request.getParameter("parentId") != null && !request.getParameter("parentId").isEmpty()) {
            parentId = Integer.parseInt(request.getParameter("parentId"));
        }
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (videoService.sendComment(videoId, user.getId(), content, time, parentId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"发送成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"发送失败\"}");
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
        List<Video> videos = videoService.getUserVideos(user.getId());
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
        List<Video> videos = videoService.searchVideos(keyword, page, 10);
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
        int totalCount = videoService.getTotalVideoCount();
        int totalPages = (int) Math.ceil((double) totalCount / 10);
        request.setAttribute("videos", videos);
        request.setAttribute("keyword", keyword == null ? "" : keyword);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/WEB-INF/views/videoList.jsp").forward(request, response);
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
}