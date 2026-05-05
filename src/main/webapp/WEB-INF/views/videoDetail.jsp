<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="com.assessment.www.po.ScreenComment" %>
<%@ page import="com.assessment.www.po.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>视频详情</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
        }
        .header {
            background-color: #00a1d6;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .nav-links {
            display: flex;
            gap: 20px;
        }
        .nav-links a {
            color: white;
            text-decoration: none;
            padding: 5px 10px;
        }
        .main-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
            display: flex;
            gap: 20px;
        }
        .video-section {
            flex: 2;
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .video-player-shell {
            margin-bottom: 20px;
        }
        .player-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 12px;
            padding: 12px 14px;
            border-radius: 12px;
            background: linear-gradient(135deg, #f8fbff 0%, #eef7ff 100%);
            border: 1px solid rgba(0, 161, 214, 0.12);
        }
        .player-toolbar-left {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .player-toolbar-title {
            font-size: 14px;
            font-weight: 700;
            color: #0f172a;
        }
        .player-toolbar-note {
            font-size: 12px;
            color: #64748b;
        }
        .player-toolbar-right {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .danmaku-input {
            min-width: 180px;
            padding: 8px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            background: #ffffff;
            color: #0f172a;
            outline: none;
        }
        .danmaku-input:focus {
            border-color: #00a1d6;
            box-shadow: 0 0 0 3px rgba(0, 161, 214, 0.12);
        }
        .speed-label {
            font-size: 13px;
            color: #334155;
            font-weight: 600;
        }
        .speed-select {
            min-width: 96px;
            padding: 8px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            background: #ffffff;
            color: #0f172a;
            outline: none;
        }
        .speed-select:focus {
            border-color: #00a1d6;
            box-shadow: 0 0 0 3px rgba(0, 161, 214, 0.12);
        }
        .player-toggle {
            padding: 8px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            background: #ffffff;
            color: #334155;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .player-toggle.active {
            background: #00a1d6;
            color: #ffffff;
            border-color: #00a1d6;
        }
        .video-player {
            width: 100%;
            height: 400px;
            background-color: #000;
            margin-bottom: 20px;
            position: relative;
            overflow: hidden;
            border-radius: 12px;
        }
        .video-player video {
            width: 100%;
            height: 100%;
            object-fit: contain;
            display: block;
            background: #000;
        }
        .danmaku-layer {
            position: absolute;
            inset: 0;
            overflow: hidden;
            pointer-events: none;
            z-index: 3;
        }
        .danmaku-item {
            position: absolute;
            right: -40%;
            white-space: nowrap;
            max-width: 60%;
            overflow: hidden;
            text-overflow: ellipsis;
            padding: 6px 14px;
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.58);
            color: #fff;
            font-size: 14px;
            line-height: 1.35;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
            animation-name: danmaku-fly;
            animation-timing-function: linear;
            animation-fill-mode: forwards;
        }
        @keyframes danmaku-fly {
            from {
                transform: translateX(0);
            }
            to {
                transform: translateX(-160%);
            }
        }
        .video-info {
            margin-bottom: 20px;
        }
        .video-title {
            font-size: 24px;
            margin-bottom: 10px;
        }
        .video-description {
            color: #666;
            line-height: 1.6;
        }
        .video-stats {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            padding: 10px;
            background-color: #f9f9f9;
            border-radius: 4px;
        }
        .stat-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .sidebar {
            flex: 1;
        }
        .video-meta {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .video-author {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 15px;
            cursor: pointer;
        }
        .author-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background-color: #ddd;
        }
        .author-name {
            font-weight: bold;
        }
        .action-buttons {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
        }
        .action-btn {
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        .like-btn {
            background-color: #ff6b6b;
            color: white;
        }
        .like-btn.liked {
            background-color: #ff9999;
        }
        .coin-btn {
            background-color: #ffd93d;
            color: #333;
        }
        .favorite-btn {
            background-color: #4ecdc4;
            color: white;
        }
        .favorite-btn.favorited {
            background-color: #7dd3c0;
        }
        .report-btn {
            background-color: #999;
            color: white;
        }
        .report-btn.reported {
            background-color: #4a90e2;
        }
        .comment-section {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .comment-input-area {
            margin-bottom: 10px;
        }
        .comment-input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            resize: vertical;
            min-height: 40px;
            box-sizing: border-box;
        }
        .comment-actions-bar {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 10px;
            margin-top: 8px;
        }
        /* 小巧的照片上传按钮样式 */
        .photo-upload {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background-color: #f0f0f0;
            cursor: pointer;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            transition: all 0.2s;
            border: 1px solid #e0e0e0;
            overflow: hidden;
        }
        .photo-upload:hover {
            background-color: #e0e0e0;
        }
        .photo-placeholder {
            font-size: 20px;
            line-height: 1;
            text-align: center;
        }
        .photo-upload.has-photo {
            background-color: transparent;
            border: 1px solid #00a1d6;
        }
        .photo-upload.has-photo img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
        }
        .photo-upload .remove-photo {
            display: none;
            position: absolute;
            top: -5px;
            right: -5px;
            background-color: #ff6b6b;
            color: white;
            border-radius: 50%;
            width: 18px;
            height: 18px;
            font-size: 12px;
            line-height: 18px;
            text-align: center;
            cursor: pointer;
            z-index: 2;
        }
        .photo-upload.has-photo .remove-photo {
            display: block;
        }
        .send-comment-btn {
            padding: 8px 20px;
            background-color: #00a1d6;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        .send-comment-btn:hover {
            background-color: #008bb5;
        }
        .comments-list {
            margin-top: 20px;
        }
        .comment-item {
            padding: 15px;
            border-bottom: 1px solid #eee;
            margin-bottom: 10px;
            background-color: #fafafa;
            border-radius: 4px;
        }
        .comment-top {
            background-color: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            margin-bottom: 15px;
        }
        .comment-nested {
            margin-left: 30px;
            border-left: 3px solid #00a1d6;
        }
        .comment-user {
            font-weight: bold;
            margin-bottom: 8px;
            color: #333;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .comment-content {
            margin-bottom: 8px;
            line-height: 1.5;
        }
        .comment-photo {
            margin-top: 10px;
            max-width: 300px;
            border-radius: 4px;
            cursor: pointer;
        }
        .comment-photo img {
            max-width: 100%;
            border-radius: 4px;
            width:50px;
            height:50px;
        }
        .comment-time {
            font-size: 12px;
            color: #999;
            margin-bottom: 8px;
        }
        .comment-time.clickable-time {
            cursor: pointer;
            transition: color 0.2s ease;
        }
        .comment-time.clickable-time:hover {
            color: #00a1d6;
            text-decoration: underline;
        }
        .comment-actions {
            margin-top: 8px;
        }
        .reply-btn {
            padding: 4px 10px;
            background-color: #f0f0f0;
            border: 1px solid #ddd;
            border-radius: 3px;
            cursor: pointer;
            font-size: 12px;
            margin-right: 10px;
            transition: background-color 0.2s;
        }
        .reply-btn:hover {
            background-color: #e0e0e0;
        }
        .delete-btn {
            background-color: #dc3545;
            color: white;
            margin-right: 10px;
        }
        .delete-btn:hover {
            background-color: #c82333;
        }
        .reply-input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-top: 10px;
            display: none;
        }
        .reply-submit {
            padding: 6px 15px;
            background-color: #00a1d6;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            margin-top: 8px;
            font-size: 12px;
        }
        .reply-cancel {
            padding: 6px 15px;
            background-color: #999;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            margin-left: 10px;
            margin-top: 8px;
            font-size: 12px;
        }
        .welcome-user {
            color: white;
        }
        .comment-level-indicator {
            display: inline-block;
            width: 16px;
            height: 16px;
            background-color: #00a1d6;
            color: white;
            border-radius: 50%;
            text-align: center;
            line-height: 16px;
            font-size: 10px;
        }
        .download-btn {
            background-color: #28a745;
            color: white;
        }
        .download-btn:hover {
            background-color: #218838;
        }
        .download-btn:disabled {
            background-color: #6c757d;
            cursor: not-allowed;
        }
        .report-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            z-index: 1000;
        }
        .report-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            padding: 20px;
            border-radius: 8px;
            width: 400px;
            max-width: 90%;
        }
        .report-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 15px;
            text-align: center;
        }
        .report-reason {
            margin-bottom: 15px;
        }
        .reason-btn {
            display: block;
            width: 100%;
            padding: 10px;
            margin-bottom: 8px;
            border: 1px solid #ddd;
            background: white;
            text-align: left;
            cursor: pointer;
            border-radius: 4px;
        }
        .reason-btn:hover {
            background-color: #f0f0f0;
        }
        .reason-btn.selected {
            background-color: #00a1d6;
            color: white;
            border-color: #00a1d6;
        }
        .cancel-report-btn {
            padding: 8px 20px;
            background-color: #999;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 10px;
        }
        .submit-report-btn {
            padding: 8px 20px;
            background-color: #ff6b6b;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .coin-amount-group {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-bottom: 16px;
        }
        .coin-amount-btn {
            padding: 10px 18px;
            border: 1px solid #d1d5db;
            background: #ffffff;
            color: #374151;
            border-radius: 8px;
            cursor: pointer;
            min-width: 96px;
        }
        .coin-amount-btn:hover {
            background-color: #f8fafc;
        }
        .coin-amount-btn.selected {
            background-color: #00a1d6;
            color: white;
            border-color: #00a1d6;
        }
        .coin-modal-actions {
            text-align: center;
        }
        .video-stats .download-btn {
            margin-left: auto;
        }
    </style>
</head>
<body>
    <div class="header">
        <a href="/" style="text-decoration: none; color: inherit;"><div style="font-size: 24px; font-weight: bold;">视频分享平台</div></a>
        <div class="nav-links">
            <%
                User currentUser = (User) session.getAttribute("user");
                Video video = (Video) request.getAttribute("video");
                boolean hasLiked = false;
                boolean hasFavorited = false;
                boolean hasReported = false;
                if (currentUser != null) {
                    String liked = request.getAttribute("hasLiked") != null ? request.getAttribute("hasLiked").toString() : "false";
                    String favorited = request.getAttribute("hasFavorited") != null ? request.getAttribute("hasFavorited").toString() : "false";
                    String reported = request.getAttribute("hasReported") != null ? request.getAttribute("hasReported").toString() : "false";
                    if ("true".equals(liked)) {
                        hasLiked = true;
                    }
                    if ("true".equals(favorited)) {
                        hasFavorited = true;
                    }
                    if ("true".equals(reported)) {
                        hasReported = true;
                    }
            %>
                <a href="/">返回首页</a>
                <span class="welcome-user">欢迎, <%= currentUser.getUsername() %></span>
                <a href="/user/me">个人中心</a>
                <a href="/video/dynamic">动态</a>
                <a href="/ticket/index">漫展活动</a>
                <a href="/user/logout">退出登录</a>
                <a href="/video/upload">上传视频</a>
                <%
                    if ("admin".equals(currentUser.getRole())) {
                %>
                    <a href="/admin/adminindex">管理后台</a>
                <%
                    }
                %>
            <%
                } else {
            %>
                <a href="/user/login">登录</a>
                <a href="/user/register">注册</a>
            <%
                }
            %>
        </div>
    </div>
    <div class="main-container">
        <div class="video-section">
            <div class="video-player-shell">
                <div class="player-toolbar">
                    <div class="player-toolbar-left">
                        <div class="player-toolbar-title">播放增强</div>
                        <div class="player-toolbar-note">倍速、弹幕显示会保存在本地</div>
                    </div>
                    <div class="player-toolbar-right">
                        <label class="speed-label" for="playbackSpeedSelect">倍速</label>
                        <select id="playbackSpeedSelect" class="speed-select" onchange="changePlaybackSpeed(this.value)">
                            <option value="0.75">0.75x</option>
                            <option value="1" selected>1x</option>
                            <option value="1.25">1.25x</option>
                            <option value="1.5">1.5x</option>
                            <option value="2">2x</option>
                        </select>
                        <input type="text" id="danmakuInput" class="danmaku-input" placeholder="发一条弹幕..." maxlength="80" onkeydown="handleDanmakuKeydown(event)">
                        <button type="button" class="player-toggle active" id="danmakuToggleBtn" onclick="toggleDanmaku()">弹幕开</button>
                        <button type="button" class="player-toggle active" onclick="sendDanmaku()">发送</button>
                    </div>
                </div>
                <div class="video-player">
                    <video id="mainVideo" controls width="100%" height="400" playsinline>
                        <%
                            String mainVideoUrl = video.getVideoUrl();
                            String mainVideoSrc;
                            if (mainVideoUrl != null && (mainVideoUrl.startsWith("http://") || mainVideoUrl.startsWith("https://") || mainVideoUrl.startsWith("/"))) {
                                mainVideoSrc = mainVideoUrl;
                            } else if (mainVideoUrl != null) {
                                mainVideoSrc = "/static/videos/" + mainVideoUrl;
                            } else {
                                mainVideoSrc = "";
                            }
                            String mainVideoType = "video/mp4";
                            if (mainVideoUrl != null) {
                                String lowerUrl = mainVideoUrl.toLowerCase();
                                if (lowerUrl.endsWith(".webm")) {
                                    mainVideoType = "video/webm";
                                } else if (lowerUrl.endsWith(".ogg") || lowerUrl.endsWith(".ogv")) {
                                    mainVideoType = "video/ogg";
                                } else if (lowerUrl.endsWith(".mov")) {
                                    mainVideoType = "video/quicktime";
                                } else if (lowerUrl.endsWith(".avi")) {
                                    mainVideoType = "video/x-msvideo";
                                } else if (lowerUrl.endsWith(".mkv")) {
                                    mainVideoType = "video/x-matroska";
                                }
                            }
                        %>
                        <source src="<%= mainVideoSrc %>" type="<%= mainVideoType %>">
                        您的浏览器不支持视频播放
                    </video>
                    <div class="danmaku-layer" id="danmakuLayer"></div>
                </div>
                <%-- 服务器端若检测到视频文件缺失，显示提示 --%>
                <%
                    Boolean missing = request.getAttribute("videoFileMissing") != null ? (Boolean) request.getAttribute("videoFileMissing") : false;
                    if (missing) {
                        String msg = request.getAttribute("videoFileMissingMessage") != null ? request.getAttribute("videoFileMissingMessage").toString() : "视频文件未找到";
                %>
                <div style="padding:12px;background:#ffecec;color:#900;border:1px solid #f5c6cb;border-radius:6px;margin:12px 0;">提醒：<%= msg %></div>
                <%
                    }
                %>
            </div>
            <div class="video-info">
                <h1 class="video-title">${video.title}</h1>
                <p class="video-description">${video.description}</p>
            </div>
            <div class="video-stats">
                <div class="stat-item">
                    <span>👁️</span>
                    <span>${video.viewCount}</span>
                </div>
                <div class="stat-item">
                    <span>👍</span>
                    <span>${video.likeCount}</span>
                </div>
                <div class="stat-item">
                    <span>💰</span>
                    <span>${video.coinCount}</span>
                </div>
                <div class="stat-item">
                    <span>⭐</span>
                    <span>${video.favCount}</span>
                </div>
                 <button class="action-btn download-btn" onclick="downloadVideo(${video.id})" title="下载视频">
                       下载
                 </button>
            </div>
        </div>
        <div class="sidebar">
            <div class="video-meta">
                <div class="video-author" onclick="goprofile(${video.author.id})">
                    <img src="${video.author.avatarUrl != null && !video.author.avatarUrl.isEmpty() ? video.author.avatarUrl : '/static/images/default_avatar.png'}" alt="头像" class="author-avatar" onerror="this.src='/static/images/default_avatar.png'">
                    <div>
                        <div class="author-name">${video.author.username}</div>
                        <a href="/user/${video.author.id}">关注</a>
                    </div>
                </div>
                <div class="action-buttons">
                    <button class='action-btn like-btn <%= hasLiked ? "liked" : "" %>'
                            onclick="toggleLike(${video.id})"
                            title="<%= hasLiked ? "您已点赞过这个视频" : "点赞支持" %>">
                        <%= hasLiked ? "已点赞" : "点赞" %>
                    </button>
                    <button class="action-btn coin-btn"
                            onclick="showCoinModal(${video.id})"
                            title="投币支持创作者">
                        投币
                    </button>
                    <button class="action-btn favorite-btn <%= hasFavorited ? "favorited" : "" %>"
                            onclick="toggleFavorite(${video.id})"
                            title="<%= hasFavorited ? "您已收藏这个视频" : "收藏视频" %>">
                        <%= hasFavorited ? "已收藏" : "收藏" %>
                    </button>
                    <%
                    if (hasReported) {
                %>
                    <button class="action-btn report-btn reported"
                            disabled
                            title="您已举报过这个视频">
                        已举报
                    </button>
                <%
                    } else {
                %>
                    <button class="action-btn report-btn"
                            onclick="showReportModal(${video.id})"
                            title="举报违规内容">
                        举报
                    </button>
                <%
                    }
                %>
                </div>
            </div>
            <div class="comment-section">
                <h3>评论 (${commentCount})</h3>
                <%
                    if (currentUser != null) {
                %>
                <div class="comment-input-area">
                    <textarea class="comment-input" id="commentInput" placeholder="发送评论..."></textarea>
                    <div class="comment-actions-bar">
                        <!-- 小巧的照片上传按钮 -->
                        <div class="photo-upload" id="photoUploadBox" onclick="document.getElementById('photoInput').click()">
                            <div class="photo-placeholder">📷</div>
                            <div class="remove-photo" onclick="event.stopPropagation(); removePhoto()">✕</div>
                        </div>
                        <button class="send-comment-btn" onclick="sendComment()">发送评论</button>
                    </div>
                    <input type="file" id="photoInput" name="photoInput" accept="image/*" style="display: none;">
                </div>
                <%
                    }
                %>
                <div class="comments-list" id="commentsList">
                    <%
                        List<ScreenComment> topLevelComments = (List<ScreenComment>) request.getAttribute("topLevelComments");
                        if (topLevelComments != null && !topLevelComments.isEmpty()) {
                            for (ScreenComment comment : topLevelComments) {
                               pageContext.setAttribute("comment", comment);
                    %>
                    <div class="comment-item comment-top" id="comment-<%= comment.getId() %>" data-video-time="<%= comment.getVideoTime() != null ? comment.getVideoTime() : 0 %>">
                        <div class="comment-user">
                            <span class="comment-level-indicator">1</span>
                            ${comment.user.username}
                        </div>
                        <div class="comment-content">${comment.content}</div>
                        <%
                            if (comment.getPhoto() != null && !comment.getPhoto().isEmpty()) {
                        %>
                        <div class="comment-photo">
                            <img src="${comment.photo}" alt="评论照片" onclick="showPhotoModal('${comment.photo}')">
                        </div>
                        <%
                            }
                        %>
                       <div class="comment-time clickable-time" title="点击跳转到该时间点" onclick="jumpToVideoTime(<%= comment.getVideoTime() != null ? comment.getVideoTime() : 0 %>)">
                           时间:
                           <%
                               java.util.Date timeCreate = comment.getTimeCreate();
                               if (timeCreate != null) {
                                   out.print(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(timeCreate));
                               } else {
                                   out.print("未知时间");
                               }
                           %>
                       </div>
                        <%
                            if (currentUser != null) {
                                boolean canDelete = false;
                                String deleteClass = "display: none;";
                                String deleteText = "";
                                if (currentUser.getId() != null && currentUser.getId().equals(comment.getUserId())) {
                                    canDelete = true;
                                    deleteClass = "";
                                    deleteText = "删除评论";
                                }
                                else if (currentUser.getId() != null && currentUser.getId().equals(video.getAuthor().getId())) {
                                    canDelete = true;
                                    deleteClass = "";
                                    deleteText = "删除评论";
                                }
                        %>
                        <div class="comment-actions">
                           <button class="reply-btn delete-btn" id="delete-comment-<%= comment.getId() %>"
                                   style="<%= deleteClass %>"
                                   onclick="confirmDeleteComment(<%= comment.getId() %>, '<%= comment.getContent().length() > 20 ? comment.getContent().substring(0, 20) + "..." : comment.getContent() %>')">
                               <%= deleteText %>
                           </button>
                           <button class="reply-btn" onclick="showReplyForm(<%= comment.getId() %>, <%= comment.getId() %>)">回复</button>
                        </div>
                        <div id="reply-form-<%= comment.getId() %>" class="reply-input" style="display: none;">
                            <textarea id="replyInput-<%= comment.getId() %>" placeholder="回复 @${comment.user.username}..." style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;min-height:60px;"></textarea>
                            <div style="margin-top: 8px;">
                                <button class="reply-submit" onclick="sendReply(<%= comment.getId() %>)">发送</button>
                                <button class="reply-cancel" onclick="cancelReply(<%= comment.getId() %>)">取消</button>
                            </div>
                        </div>
                        <%
                            }
                        %>
                        <%
                            if (comment.getReplies() != null && !comment.getReplies().isEmpty()) {
                                for (ScreenComment reply : comment.getReplies()) {
                                    pageContext.setAttribute("reply", reply);
                        %>
                        <div class="comment-item comment-nested" id="reply-<%= reply.getId() %>" data-video-time="<%= reply.getVideoTime() != null ? reply.getVideoTime() : 0 %>">
                            <div class="comment-user">
                                <span class="comment-level-indicator">2</span>
                                ${reply.user.username}
                                <span style="color: #666; font-size: 11px;"> 回复 @${comment.user.username}</span>
                            </div>
                            <div class="comment-content">${reply.content}</div>
                            <%
                                if (reply.getPhoto() != null && !reply.getPhoto().isEmpty()) {
                            %>
                            <div class="comment-photo">
                                <img src="data:image/jpeg;base64,${reply.photo}" alt="评论照片" onclick="showPhotoModal('data:image/jpeg;base64,${reply.photo}')">
                            </div>
                            <%
                                }
                            %>
                            <div class="comment-time clickable-time" title="点击跳转到该时间点" onclick="jumpToVideoTime(<%= reply.getVideoTime() != null ? reply.getVideoTime() : 0 %>)">
                                时间:
                                <%
                                    java.util.Date reltimeCreate = reply.getTimeCreate();
                                    if (reltimeCreate != null) {
                                        out.print(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(reltimeCreate));
                                    } else {
                                        out.print("未知时间");
                                    }
                                %>
                            </div>
                            <%
                                if (currentUser != null) {
                                    boolean canDeleteReply = false;
                                    String deleteClassReply = "display: none;";
                                    String deleteTextReply = "";
                                    if (currentUser.getId() != null && currentUser.getId().equals(reply.getUserId())) {
                                        canDeleteReply = true;
                                        deleteClassReply = "";
                                        deleteTextReply = "删除回复";
                                    }
                                    else if (currentUser.getId() != null && currentUser.getId().equals(video.getAuthor().getId())) {
                                        canDeleteReply = true;
                                        deleteClassReply = "";
                                        deleteTextReply = "删除回复";
                                    }
                            %>
                            <div class="comment-actions">
                                <button class="reply-btn delete-btn" id="delete-reply-<%= reply.getId() %>"
                                        style="<%= deleteClassReply %>"
                                        onclick="confirmDeleteReply(<%= reply.getId() %>, '<%= reply.getContent().length() > 20 ? reply.getContent().substring(0, 20) + "..." : reply.getContent() %>')">
                                    <%= deleteTextReply %>
                                </button>
                                <button class="reply-btn" onclick="showReplyForm(<%= comment.getId() %>, <%= reply.getId() %>)">回复</button>
                            </div>
                            <div id="reply-form-<%= reply.getId() %>" class="reply-input" style="display: none;">
                                <textarea id="replyInput-<%= reply.getId() %>" placeholder="回复 @${reply.user.username}..." style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;min-height:60px;"></textarea>
                                <div style="margin-top: 8px;">
                                    <button class="reply-submit" onclick="sendReply(<%= reply.getId() %>)">发送</button>
                                    <button class="reply-cancel" onclick="cancelReply(<%= reply.getId() %>)">取消</button>
                                </div>
                            </div>
                            <%
                                }
                            %>
                        </div>
                          <%
                                                                                    if (reply!=null&&reply.getReplies() != null && !reply.getReplies().isEmpty()) {
                                                                                        for (ScreenComment reply2 : reply.getReplies()) {
                                                                                            pageContext.setAttribute("reply2", reply2);
                                                                                %>
                                                                                <div class="comment-item comment-nested" id="reply-<%= reply2.getId() %>" data-video-time="<%= reply2.getVideoTime() != null ? reply2.getVideoTime() : 0 %>">
                                                                                    <div class="comment-user">
                                                                                        <span class="comment-level-indicator">2</span>
                                                                                        ${reply2.user.username}
                                                                                        <span style="color: #666; font-size: 11px;"> 回复 @${reply.user.username}</span>
                                                                                    </div>
                                                                                    <div class="comment-content">${reply2.content}</div>
                                                                                    <%
                                                                                        if (reply2.getPhoto() != null && !reply2.getPhoto().isEmpty()) {
                                                                                    %>
                                                                                    <div class="comment-photo">
                                                                                        <img src="data:image/jpeg;base64,${reply2.photo}" alt="评论照片" onclick="showPhotoModal('data:image/jpeg;base64,${reply2.photo}')">
                                                                                    </div>
                                                                                    <%
                                                                                        }
                                                                                    %>
                                                                                    <div class="comment-time clickable-time" title="点击跳转到该时间点" onclick="jumpToVideoTime(<%= reply2.getVideoTime() != null ? reply2.getVideoTime() : 0 %>)">
                                                                                        时间:
                                                                                        <%
                                                                                            java.util.Date reltimeCreate2 = reply2.getTimeCreate();
                                                                                            if (reltimeCreate2 != null) {
                                                                                                out.print(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(reltimeCreate2));
                                                                                            } else {
                                                                                                out.print("未知时间");
                                                                                            }
                                                                                        %>
                                                                                    </div>
                                                                                    <%
                                                                                        if (currentUser != null) {
                                                                                            boolean canDeleteReply2 = false;
                                                                                            String deleteClassReply2 = "display: none;";
                                                                                            String deleteTextReply2 = "";
                                                                                            if (currentUser.getId() != null && currentUser.getId().equals(reply2.getUserId())) {
                                                                                                canDeleteReply2 = true;
                                                                                                deleteClassReply2 = "";
                                                                                                deleteTextReply2 = "删除回复";
                                                                                            }
                                                                                            else if (currentUser.getId() != null && currentUser.getId().equals(video.getAuthor().getId())) {
                                                                                                canDeleteReply2 = true;
                                                                                                deleteClassReply2 = "";
                                                                                                deleteTextReply2 = "删除回复";
                                                                                            }
                                                                                    %>
                                                                                    <div class="comment-actions">
                                                                                        <button class="reply-btn delete-btn" id="delete-reply2-<%= reply2.getId() %>"
                                                                                                style="<%= deleteClassReply2 %>"
                                                                                                onclick="confirmDeleteReply2(<%= reply2.getId() %>, '<%= reply2.getContent().length() > 20 ? reply2.getContent().substring(0, 20) + "..." : reply2.getContent() %>')">
                                                                                            <%= deleteTextReply2 %>
                                                                                        </button>
                                                                                        <button class="reply-btn" onclick="showReplyForm(<%= reply2.getId() %>, <%= reply2.getId() %>)">回复</button>
                                                                                    </div>
                                                                                    <div id="reply-form-<%= reply2.getId() %>" class="reply-input" style="display: none;">
                                                                                        <textarea id="replyInput-<%= reply2.getId() %>" placeholder="回复 @${reply2.user.username}..." style="width:100%;padding:8px;border:1px solid #ddd;border-radius:4px;min-height:60px;"></textarea>
                                                                                        <div style="margin-top: 8px;">
                                                                                            <button class="reply-submit" onclick="sendReply(<%= reply2.getId() %>)">发送</button>
                                                                                            <button class="reply-cancel" onclick="cancelReply(<%= reply2.getId() %>)">取消</button>
                                                                                        </div>
                                                                                    </div>
                                                                                    <%
                                                                                        }
                                                                                    %>
                                                                                </div>
                                                                                <%
                                                                                        }
                                                                                    }
                                                                                %>
                        <%
                                }
                            }
                        %>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <div style="text-align: center; color: #999; padding: 20px;">
                        暂无评论，快来评论一下吧！
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
    <!-- 举报模态框 -->
    <div id="reportModal" class="report-modal">
        <div class="report-content">
            <div class="report-title">举报视频</div>
            <div class="report-reason">
                <div class="reason-btn" onclick="selectReason(this, '违规内容')">违规内容</div>
                <div class="reason-btn" onclick="selectReason(this, '色情低俗')">色情低俗</div>
                <div class="reason-btn" onclick="selectReason(this, '暴力血腥')">暴力血腥</div>
                <div class="reason-btn" onclick="selectReason(this, '抄袭盗用')">抄袭盗用</div>
                <div class="reason-btn" onclick="selectReason(this, '广告营销')">广告营销</div>
                <div class="reason-btn" onclick="selectReason(this, '其他原因')">其他原因</div>
            </div>
            <div style="text-align: center;">
                <button class="cancel-report-btn" onclick="cancelReport()">取消</button>
                <button class="submit-report-btn" onclick="submitReport()">提交举报</button>
            </div>
        </div>
    </div>
    <!-- 投币模态框 -->
    <div id="coinModal" class="report-modal coin-modal">
        <div class="report-content" style="width: 360px; max-width: 90%;">
            <div class="report-title">投币支持</div>
            <div class="coin-amount-group">
                <button type="button" class="coin-amount-btn selected" data-coin="1" onclick="selectCoinAmount(1)">1 枚</button>
                <button type="button" class="coin-amount-btn" data-coin="2" onclick="selectCoinAmount(2)">2 枚</button>
            </div>
            <div class="coin-modal-actions">
                <button type="button" class="cancel-report-btn coin-cancel-btn" onclick="closeCoinModal()">取消</button>
                <button type="button" class="submit-report-btn coin-submit-btn" onclick="submitCoin()">确定投币</button>
            </div>
        </div>
    </div>
    <!-- 照片查看模态框 -->
    <div id="photoModal" class="report-modal" onclick="closePhotoModal()">
        <div class="report-content" style="width: auto; max-width: 90%; padding: 10px;" onclick="event.stopPropagation()">
            <img id="modalPhoto" src="" alt="照片" style="max-width: 100%; max-height: 80vh; border-radius: 4px;">
        </div>
    </div>
    <script>
            // 记录 video src 并监听错误，便于排查播放问题
            (function () {
                var v = document.getElementById('mainVideo');
                if (!v) return;
                try {
                    var src = v.currentSrc || (v.querySelector('source') && v.querySelector('source').src);
                    console.log('mainVideo src=', src);
                } catch (e) {}
                v.addEventListener('error', function () {
                    try {
                        var err = v.error;
                        console.error('Video playback error', err, 'networkState', v.networkState, 'readyState', v.readyState);
                        var msg = '视频加载失败，请检查视频文件格式或网络连接。错误码：' + (err ? err.code : 'unknown');
                        var notice = document.createElement('div');
                        notice.style.position = 'fixed';
                        notice.style.top = '10px';
                        notice.style.left = '50%';
                        notice.style.transform = 'translateX(-50%)';
                        notice.style.background = '#ffdddd';
                        notice.style.color = '#900';
                        notice.style.padding = '10px 14px';
                        notice.style.borderRadius = '6px';
                        notice.style.zIndex = 9999;
                        notice.textContent = msg;
                        document.body.appendChild(notice);
                    } catch (e) { console.error(e); }
                });
            })();
        let isCommenting = false;
        let isReplying = {};
        let selectedPhoto = null;
        let currentCoinVideoId = null;
        let selectedCoinAmount = 1;
        const playbackRateStorageKey = 'videoDetailPlaybackRate';
        const danmakuEnabledStorageKey = 'videoDetailDanmakuEnabled';
        let danmakuSources = [];
        let danmakuCursor = 0;
        let danmakuEnabled = true;
        let danmakuLaneCount = 0;
        let danmakuSeq = 0;

        function initVideoEnhancements() {
            const video = document.getElementById('mainVideo');
            const danmakuLayer = document.getElementById('danmakuLayer');
            if (!video || !danmakuLayer) {
                return;
            }

            restorePlaybackRate();
            restoreDanmakuState();
            collectDanmakuSources();
            refreshDanmakuCursor(video.currentTime || 0);
            updateDanmakuToggleButton();

            video.addEventListener('loadedmetadata', function () {
                restorePlaybackRate();
                refreshDanmakuCursor(video.currentTime || 0);
            });
            video.addEventListener('play', function () {
                refreshDanmakuCursor(video.currentTime || 0);
            });
            video.addEventListener('timeupdate', function () {
                renderDanmakuByTime(video.currentTime || 0);
            });
            video.addEventListener('seeked', function () {
                clearDanmaku();
                refreshDanmakuCursor(video.currentTime || 0);
            });
        }

        function restorePlaybackRate() {
            const video = document.getElementById('mainVideo');
            const select = document.getElementById('playbackSpeedSelect');
            if (!video || !select) {
                return;
            }
            const storedRate = parseFloat(localStorage.getItem(playbackRateStorageKey));
            const rate = [0.75, 1, 1.25, 1.5, 2].indexOf(storedRate) >= 0 ? storedRate : 1;
            video.playbackRate = rate;
            video.defaultPlaybackRate = rate;
            select.value = String(rate);
        }

        function changePlaybackSpeed(rateValue) {
            const video = document.getElementById('mainVideo');
            const rate = parseFloat(rateValue) || 1;
            if (video) {
                video.playbackRate = rate;
                video.defaultPlaybackRate = rate;
            }
            localStorage.setItem(playbackRateStorageKey, String(rate));
        }

        function restoreDanmakuState() {
            const stored = localStorage.getItem(danmakuEnabledStorageKey);
            danmakuEnabled = stored === null ? true : stored === '1';
            const layer = document.getElementById('danmakuLayer');
            if (layer) {
                layer.style.display = danmakuEnabled ? 'block' : 'none';
            }
        }

        function updateDanmakuToggleButton() {
            const btn = document.getElementById('danmakuToggleBtn');
            if (!btn) {
                return;
            }
            btn.textContent = danmakuEnabled ? '弹幕开' : '弹幕关';
            btn.classList.toggle('active', danmakuEnabled);
        }

        function toggleDanmaku() {
            danmakuEnabled = !danmakuEnabled;
            localStorage.setItem(danmakuEnabledStorageKey, danmakuEnabled ? '1' : '0');
            const layer = document.getElementById('danmakuLayer');
            if (layer) {
                layer.style.display = danmakuEnabled ? 'block' : 'none';
            }
            if (!danmakuEnabled) {
                clearDanmaku();
            }
            updateDanmakuToggleButton();
        }

        function clearDanmaku() {
            const layer = document.getElementById('danmakuLayer');
            if (layer) {
                layer.innerHTML = '';
            }
        }

        function handleDanmakuKeydown(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                sendDanmaku();
            }
        }

        function sendDanmaku() {
            const input = document.getElementById('danmakuInput');
            const content = input ? input.value.trim() : '';
            const videoElement = document.getElementById('mainVideo');
            const videoTime = videoElement ? videoElement.currentTime : 0;
            if (!content) {
                alert('请输入弹幕内容');
                return;
            }

            fetch('/video/comment', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'videoId=${video.id}&content=' + encodeURIComponent(content) + '&time=' + encodeURIComponent(videoTime) + '&parentId=0'
            }).then(response => {
                if (response.status === 401) {
                    alert('请先登录');
                    window.location.href = '/user/login';
                    throw new Error('请登录');
                }
                return response.json();
            }).then(data => {
                if (data.needLogin) {
                    window.location.href = '/user/login';
                } else if (data.success) {
                    if (input) {
                        input.value = '';
                    }
                    clearDanmaku();
                    alert(data.message || '弹幕发送成功');
                    loadComments();
                } else {
                    alert(data.message || '弹幕发送失败');
                }
            }).catch(error => {
                if (String(error).indexOf('请登录') === -1) {
                    alert('弹幕发送失败，请稍后再试');
                }
            });
        }

        function collectDanmakuSources() {
            danmakuSources = [];
            document.querySelectorAll('.comment-top[data-video-time]').forEach(function (element) {
                const rawTime = parseFloat(element.getAttribute('data-video-time'));
                const contentNode = element.querySelector('.comment-content');
                const text = contentNode ? contentNode.textContent.trim() : '';
                if (!text || isNaN(rawTime)) {
                    return;
                }
                danmakuSources.push({
                    id: element.id || ('danmaku-' + danmakuSeq++),
                    time: rawTime,
                    text: text
                });
            });
            danmakuSources.sort(function (a, b) {
                return a.time - b.time;
            });
        }

        function refreshDanmakuCursor(currentTime) {
            let index = 0;
            while (index < danmakuSources.length && danmakuSources[index].time < currentTime - 0.15) {
                index++;
            }
            danmakuCursor = index;
            danmakuLaneCount = 0;
        }

        function renderDanmakuByTime(currentTime) {
            if (!danmakuEnabled || !danmakuSources.length) {
                return;
            }
            while (danmakuCursor < danmakuSources.length && danmakuSources[danmakuCursor].time <= currentTime + 0.2) {
                spawnDanmaku(danmakuSources[danmakuCursor]);
                danmakuCursor++;
            }
        }

        function spawnDanmaku(source) {
            const layer = document.getElementById('danmakuLayer');
            const video = document.getElementById('mainVideo');
            if (!layer || !video || !danmakuEnabled) {
                return;
            }

            const danmaku = document.createElement('div');
            danmaku.className = 'danmaku-item';
            danmaku.textContent = source.text;

            const laneHeight = 42;
            const laneCount = Math.max(4, Math.floor((layer.clientHeight || 400) / laneHeight));
            const lane = Math.abs((source.id || '').toString().length + danmakuLaneCount) % laneCount;
            danmakuLaneCount = (danmakuLaneCount + 1) % laneCount;

            const baseDuration = Math.max(7, Math.min(12, 7 + source.text.length * 0.08));
            const rate = video.playbackRate || 1;
            danmaku.style.top = (12 + lane * laneHeight) + 'px';
            danmaku.style.animationDuration = Math.max(4, baseDuration / rate) + 's';

            layer.appendChild(danmaku);
            const removeDelay = Math.max(4, baseDuration / rate) * 1000 + 250;
            window.setTimeout(function () {
                if (danmaku.parentNode) {
                    danmaku.parentNode.removeChild(danmaku);
                }
            }, removeDelay);
        }

        function jumpToVideoTime(seconds) {
            const video = document.getElementById('mainVideo');
            if (!video || isNaN(seconds)) {
                return;
            }
            const nextTime = Math.max(0, Number(seconds) || 0);
            video.currentTime = nextTime;
            refreshDanmakuCursor(nextTime);
            clearDanmaku();
        }

        function showActionNotice(message, type, afterAction, delayMs) {
            if (window.ftNotify) {
                window.ftNotify(message, {
                    type: type || 'info',
                    title: type === 'success' ? '成功' : type === 'error' ? '失败' : '提示',
                    duration: type === 'error' ? 3800 : 2800
                });
            } else {
                window.alert(message);
            }

            if (typeof afterAction === 'function') {
                window.setTimeout(afterAction, typeof delayMs === 'number' ? delayMs : 1200);
            }
        }

        function refreshCoinAmountButtons() {
            document.querySelectorAll('#coinModal .coin-amount-btn').forEach(function (btn) {
                const amount = Number(btn.getAttribute('data-coin'));
                const selected = amount === selectedCoinAmount;
                btn.classList.toggle('selected', selected);
                btn.style.setProperty('background-color', selected ? '#00a1d6' : '#ffffff', 'important');
                btn.style.setProperty('color', selected ? '#ffffff' : '#374151', 'important');
                btn.style.setProperty('border-color', selected ? '#00a1d6' : '#d1d5db', 'important');
            });

            const submitBtn = document.querySelector('#coinModal .coin-submit-btn');
            if (submitBtn) {
                submitBtn.style.setProperty('background-color', '#ff6b6b', 'important');
                submitBtn.style.setProperty('color', '#ffffff', 'important');
                submitBtn.style.setProperty('border-color', '#ff6b6b', 'important');
            }

            const cancelBtn = document.querySelector('#coinModal .coin-cancel-btn');
            if (cancelBtn) {
                cancelBtn.style.setProperty('background-color', '#999999', 'important');
                cancelBtn.style.setProperty('color', '#ffffff', 'important');
                cancelBtn.style.setProperty('border-color', '#999999', 'important');
            }
        }

        function selectCoinAmount(amount) {
            selectedCoinAmount = amount;
            refreshCoinAmountButtons();
        }

        function showCoinModal(videoId) {
            currentCoinVideoId = videoId;
            selectedCoinAmount = 1;
            const modal = document.getElementById('coinModal');
            if (modal) {
                modal.style.display = 'block';
                refreshCoinAmountButtons();
            }
        }

        function closeCoinModal() {
            const modal = document.getElementById('coinModal');
            if (modal) {
                modal.style.display = 'none';
            }
            currentCoinVideoId = null;
            selectedCoinAmount = 1;
        }

        function submitCoin() {
            if (!currentCoinVideoId) {
                return;
            }
            fetch('/video/coin', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'id=' + currentCoinVideoId + '&amount=' + selectedCoinAmount
            }).then(response => {
                if (response.status === 401) {
                    showActionNotice('请先登录', 'warning', function () {
                        window.location.href = '/user/login';
                    });
                    throw new Error('请登录');
                }
                return response.json();
            }).then(data => {
                if (data.needLogin) {
                    showActionNotice('请先登录', 'warning', function () {
                        window.location.href = '/user/login';
                    });
                } else if (data.success) {
                    closeCoinModal();
                    showActionNotice(data.message || '投币成功！', 'success', function () {
                        location.reload();
                    });
                } else {
                    showActionNotice(data.message || '投币失败', 'error');
                }
            }).catch(error => {
                if (String(error).indexOf('请登录') === -1) {
                    showActionNotice('投币失败，请稍后再试', 'error');
                }
            });
        }
        // 处理照片上传（2MB限制）
        document.getElementById('photoInput').addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                if (file.size > 2 * 1024 * 1024) {
                    alert('照片大小不能超过2MB');
                    return;
                }
                const reader = new FileReader();
                reader.onload = function(event) {
                    selectedPhoto = event.target.result;
                    const photoUploadBox = document.getElementById('photoUploadBox');
                    photoUploadBox.classList.add('has-photo');
                    // 显示图片预览和删除按钮
                    photoUploadBox.innerHTML = '<img src="' + selectedPhoto + '"><div class="remove-photo" onclick="event.stopPropagation(); removePhoto()">✕</div>';
                };
                reader.readAsDataURL(file);
            }
        });
        // 移除照片
        function removePhoto() {
            selectedPhoto = null;
            document.getElementById('photoInput').value = '';
            const photoUploadBox = document.getElementById('photoUploadBox');
            photoUploadBox.classList.remove('has-photo');
            // 恢复为相机图标，不带删除按钮
            photoUploadBox.innerHTML = '<div class="photo-placeholder">📷</div><div class="remove-photo" onclick="event.stopPropagation(); removePhoto()">✕</div>';
        }
        // 发送评论
        function sendComment() {
            if (isCommenting) {
                alert('请稍后再试，评论正在处理中...');
                return;
            }
            const commentInput = document.getElementById('commentInput');
            const content = commentInput.value.trim();
            const videoElement = document.getElementById('mainVideo') || document.querySelector('video');
            const videoTime = videoElement ? videoElement.currentTime : 0;
            if (!content && !selectedPhoto) {
                alert('请输入评论内容或上传照片');
                return;
            }
            isCommenting = true;
            const sendBtn = document.querySelector('.send-comment-btn');
            const originalText = sendBtn.textContent;
            sendBtn.textContent = '发送中...';
            sendBtn.disabled = true;
            const formData = new FormData();
            formData.append('videoId', '${video.id}');
            formData.append('content', content || '');
            formData.append('time', videoTime);
            formData.append('parentId', '0');
            if (selectedPhoto) {
                formData.append('photo', selectedPhoto);
            }
            fetch('/video/comment', {
                method: 'POST',
                body: formData
            }).then(response => {
                if (response.status === 401) {
                    alert('请先登录');
                    window.location.href = '/user/login';
                    throw new Error('请登录');
                }
                return response.json();
            }).then(data => {
                if (data.needLogin) {
                    window.location.href = '/user/login';
                } else if (data.success) {
                    commentInput.value = '';
                    removePhoto();
                    alert(data.message);
                    loadComments();
                } else {
                    alert(data.message);
                }
            }).catch(error => {
                console.error('发送评论失败:', error);
            }).finally(() => {
                isCommenting = false;
                sendBtn.textContent = originalText;
                sendBtn.disabled = false;
            });
        }
        // 点赞功能
        function toggleLike(videoId) {
            const btn = event.target;
            if (btn.disabled) return;
            btn.disabled = true;
            if (btn.classList.contains('liked')) {
                fetch('/video/unlike', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'id=' + videoId
                }).then(response => {
                    if (response.status === 401) {
                        btn.disabled = false;
                        showActionNotice('请先登录', 'warning', function () {
                            window.location.href = '/user/login';
                        });
                        throw new Error('请登录');
                    }
                    return response.json();
                }).then(data => {
                    if (data.needLogin) {
                        showActionNotice('请先登录', 'warning', function () {
                            window.location.href = '/user/login';
                        });
                    } else if (data.success) {
                        btn.classList.remove('liked');
                        btn.textContent = '点赞';
                        btn.disabled = false;
                        showActionNotice(data.message || '取消点赞成功', 'success', function () {
                            location.reload();
                        });
                    } else {
                        btn.disabled = false;
                        showActionNotice(data.message || '点赞失败', 'error');
                    }
                }).catch(error => {
                    btn.disabled = false;
                });
            } else {
                fetch('/video/like', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'id=' + videoId
                }).then(response => {
                    if (response.status === 401) {
                        btn.disabled = false;
                        showActionNotice('请先登录', 'warning', function () {
                            window.location.href = '/user/login';
                        });
                        throw new Error('请登录');
                    }
                    return response.json();
                }).then(data => {
                    if (data.needLogin) {
                        showActionNotice('请先登录', 'warning', function () {
                            window.location.href = '/user/login';
                        });
                    } else if (data.success) {
                        btn.classList.add('liked');
                        btn.textContent = '已点赞';
                        btn.disabled = false;
                        showActionNotice(data.message || '点赞成功', 'success', function () {
                            location.reload();
                        });
                    } else {
                        btn.disabled = false;
                        showActionNotice(data.message || '点赞失败', 'error');
                    }
                }).catch(error => {
                    btn.disabled = false;
                });
            }
        }
        // 收藏功能
        function toggleFavorite(videoId) {
            const btn = event.target;
            if (btn.disabled) return;
            btn.disabled = true;
            if (btn.classList.contains('favorited')) {
                fetch('/video/unfavorite', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'id=' + videoId
                }).then(response => {
                    if (response.status === 401) {
                        btn.disabled = false;
                        showActionNotice('请先登录', 'warning', function () {
                            window.location.href = '/user/login';
                        });
                        throw new Error('请登录');
                    }
                    return response.json();
                }).then(data => {
                    if (data.needLogin) {
                        showActionNotice('请先登录', 'warning', function () {
                            window.location.href = '/user/login';
                        });
                    } else if (data.success) {
                        btn.classList.remove('favorited');
                        btn.textContent = '收藏';
                        btn.disabled = false;
                        showActionNotice(data.message || '取消收藏成功', 'success', function () {
                            location.reload();
                        });
                    } else {
                        btn.disabled = false;
                        showActionNotice(data.message || '收藏失败', 'error');
                    }
                }).catch(error => {
                    btn.disabled = false;
                });
            } else {
                fetch('/video/favorite', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'id=' + videoId
                }).then(response => {
                    if (response.status === 401) {
                        btn.disabled = false;
                        showActionNotice('请先登录', 'warning', function () {
                            window.location.href = '/user/login';
                        });
                        throw new Error('请登录');
                    }
                    return response.json();
                }).then(data => {
                    if (data.needLogin) {
                        showActionNotice('请先登录', 'warning', function () {
                            window.location.href = '/user/login';
                        });
                    } else if (data.success) {
                        btn.classList.add('favorited');
                        btn.textContent = '已收藏';
                        btn.disabled = false;
                        showActionNotice(data.message || '收藏成功', 'success', function () {
                            location.reload();
                        });
                    } else {
                        btn.disabled = false;
                        showActionNotice(data.message || '收藏失败', 'error');
                    }
                }).catch(error => {
                    btn.disabled = false;
                    showActionNotice('收藏失败', 'error');
                });
            }
        }
        // 下载功能
        function downloadVideo(videoId) {
            const btn = event.target;
            if (btn.disabled) return;
            btn.disabled = true;
            btn.textContent = '下载中...';
            const form = document.createElement('form');
            form.method = 'GET';
            form.action = '/video/download';
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'id';
            idInput.value = videoId;
            form.appendChild(idInput);
            document.body.appendChild(form);
            form.submit();
            setTimeout(() => {
                document.body.removeChild(form);
                btn.disabled = false;
                btn.textContent = '下载';
            }, 100);
        }
        // 显示回复表单
        function showReplyForm(parentId, replyId) {
            if (replyId === undefined) {
                replyId = parentId;
            }
            document.querySelectorAll('.reply-input').forEach(form => {
                form.style.display = 'none';
            });
            const replyForm = document.getElementById('reply-form-' + replyId);
            if (replyForm) {
                replyForm.style.display = 'block';
                const replyInput = document.getElementById('replyInput-' + replyId);
                if (replyInput) replyInput.focus();
            }
        }
        // 隐藏回复表单
        function cancelReply(replyId) {
            const replyForm = document.getElementById('reply-form-' + replyId);
            if (replyForm) replyForm.style.display = 'none';
        }
        // 发送回复
        function sendReply(replyId) {
            if (isReplying[replyId]) {
                alert('请稍后再试，回复正在处理中...');
                return;
            }
            const replyInput = document.getElementById('replyInput-' + replyId);
            const content = replyInput.value.trim();
            if (!content) {
                alert('请输入回复内容');
                return;
            }
            isReplying[replyId] = true;
            const submitBtn = document.querySelector('#reply-form-' + replyId + ' .reply-submit');
            const originalText = submitBtn.textContent;
            submitBtn.textContent = '发送中...';
            submitBtn.disabled = true;
            fetch('/video/comment', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'videoId=${video.id}&content=' + encodeURIComponent(content) + '&parentId=' + replyId
            }).then(response => response.json()).then(data => {
                if (data.needLogin) {
                    window.location.href = '/user/login';
                } else if (data.success) {
                    replyInput.value = '';
                    cancelReply(replyId);
                    alert(data.message);
                    loadComments();
                } else {
                    alert(data.message);
                }
            }).finally(() => {
                isReplying[replyId] = false;
                submitBtn.textContent = originalText;
                submitBtn.disabled = false;
            });
        }
        // 加载评论
        function loadComments() {
            location.reload();
        }
        // 删除评论
        function deleteComment(commentId) {
            fetch('/video/deleteComment', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'commentId=' + commentId
            }).then(response => response.json()).then(data => {
                if (data.needLogin) {
                    window.location.href = '/user/login';
                } else if (data.success) {
                    alert('评论删除成功！');
                    const commentElement = document.getElementById('comment-' + commentId);
                    if (commentElement) commentElement.remove();
                    updateCommentCount();
                } else {
                    alert('删除失败：' + data.message);
                }
            }).catch(error => {
                alert('删除失败：' + error);
            });
        }
        // 确认删除评论
        function confirmDeleteComment(commentId, commentContent) {
            const commentPreview = commentContent.length > 20 ? commentContent.substring(0, 20) + "..." : commentContent;
            if (confirm(`确定要删除这条评论吗？\n内容预览：${commentPreview}`)) {
                deleteComment(commentId);
            }
        }
        // 删除回复
        function deleteReply(replyId) {
            fetch('/video/deleteReply', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'replyId=' + replyId
            }).then(response => response.json()).then(data => {
                if (data.needLogin) {
                    window.location.href = '/user/login';
                } else if (data.success) {
                    alert('回复删除成功！');
                    const replyElement = document.getElementById('reply-' + replyId);
                    if (replyElement) replyElement.remove();
                    updateCommentCount();
                } else {
                    alert('删除失败：' + data.message);
                }
            }).catch(error => {
                alert('删除失败：' + error);
            });
        }
        // 确认删除回复
        function confirmDeleteReply(replyId, replyContent) {
            const replyPreview = replyContent.length > 20 ? replyContent.substring(0, 20) + "..." : replyContent;
            if (confirm(`确定要删除这条回复吗？\n内容预览：${replyPreview}`)) {
                deleteReply(replyId);
            }
        }
        // 删除二级回复
        function deleteReply2(reply2Id) {
            fetch('/video/deleteReply2', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'reply2Id=' + reply2Id
            }).then(response => response.json()).then(data => {
                if (data.needLogin) {
                    window.location.href = '/user/login';
                } else if (data.success) {
                    alert('回复删除成功！');
                    const reply2Element = document.getElementById('reply-' + reply2Id);
                    if (reply2Element) reply2Element.remove();
                    updateCommentCount();
                } else {
                    alert('删除失败：' + data.message);
                }
            }).catch(error => {
                alert('删除失败：' + error);
            });
        }
        // 确认删除二级回复
        function confirmDeleteReply2(reply2Id, reply2Content) {
            const reply2Preview = reply2Content.length > 20 ? reply2Content.substring(0, 20) + "..." : reply2Content;
            if (confirm(`确定要删除这条回复吗？\n内容预览：${reply2Preview}`)) {
                deleteReply2(reply2Id);
            }
        }
        // 更新评论数量
        function updateCommentCount() {
            const commentItems = document.querySelectorAll('.comment-item').length;
            const commentCountElement = document.querySelector('.comment-section h3');
            if (commentCountElement) {
                const match = commentCountElement.textContent.match(/\((\d+)\)/);
                if (match) {
                    const currentCount = parseInt(match[1]);
                    const newCount = currentCount - 1;
                    commentCountElement.textContent = commentCountElement.textContent.replace(/\(\d+\)/, `(${newCount})`);
                }
            }
        }
        // 举报功能
        let selectedReason = null;
        function selectReason(element, reason) {
            document.querySelectorAll('.reason-btn').forEach(btn => btn.classList.remove('selected'));
            element.classList.add('selected');
            selectedReason = reason;
        }
        function showReportModal(videoId) {
            selectedReason = null;
            document.getElementById('reportModal').style.display = 'block';
            document.querySelectorAll('.reason-btn').forEach(btn => btn.classList.remove('selected'));
        }
        function cancelReport() {
            document.getElementById('reportModal').style.display = 'none';
            selectedReason = null;
        }
        function submitReport() {
            if (!selectedReason) {
                alert('请选择举报原因');
                return;
            }
            const videoId = ${video.id};
            fetch('/video/report', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'videoId=' + videoId + '&reason=' + encodeURIComponent(selectedReason)
            }).then(response => {
                if (response.status === 401) {
                    alert('请先登录');
                    window.location.href = '/user/login';
                    throw new Error('请登录');
                }
                return response.json();
            }).then(data => {
                if (data.needLogin) {
                    window.location.href = '/user/login';
                } else if (data.success) {
                    alert("举报成功");
                    document.querySelectorAll('.report-btn:not(.reported)').forEach(btn => {
                        btn.classList.add('reported');
                        btn.disabled = true;
                        btn.textContent = '已举报';
                    });
                    cancelReport();
                } else {
                    alert('请先登录');
                    window.location.href = '/user/login';
                }
            }).catch(error => {
                alert('请先登录');
                window.location.href = '/user/login';
            });
        }
        window.onclick = function(event) {
            const modal = document.getElementById('reportModal');
            if (event.target == modal) cancelReport();
            const coinModal = document.getElementById('coinModal');
            if (event.target == coinModal) closeCoinModal();
        }
        function goprofile(authid) {
             window.location.href = '/user/'+authid;
        }
        // 照片查看模态框
        function showPhotoModal(photoSrc) {
            document.getElementById('modalPhoto').src = photoSrc;
            document.getElementById('photoModal').style.display = 'block';
        }
        function closePhotoModal() {
            document.getElementById('photoModal').style.display = 'none';
        }
        initVideoEnhancements();
    </script>
</body>
</html>