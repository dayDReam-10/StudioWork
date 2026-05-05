<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.History" %>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="com.assessment.www.po.User" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>观看历史</title>
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
        }
        .history-title {
            font-size: 24px;
            margin-bottom: 20px;
        }
        .history-list {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .history-item {
            display: flex;
            padding: 20px;
            border-bottom: 1px solid #eee;
            transition: background-color 0.3s;
        }
        .history-item:hover {
            background-color: #f9f9f9;
        }
        .history-item:last-child {
            border-bottom: none;
        }
        .history-cover {
            width: 200px;
            height: 120px;
            background-size: cover;
            background-position: center;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 20px;
            flex-shrink: 0;
        }
        .history-info {
            flex: 1;
        }
        .history-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
            cursor: pointer;
        }
        .history-title:hover {
            color: #00a1d6;
        }
        .history-meta {
            display: flex;
            gap: 20px;
            margin-bottom: 10px;
            color: #666;
            font-size: 14px;
        }
        .history-meta span {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .history-author {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
            color: #333;
        }
        .history-author:hover {
            color: #00a1d6;
        }
        .author-avatar {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background-color: #ddd;
        }
        .history-time {
            color: #999;
            font-size: 12px;
            margin-top: 10px;
        }
        .empty-history {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        .welcome-user {
            color: white;
        }
    </style>
</head>
<body>
    <div class="header">
        <a href="/" style="text-decoration: none; color: inherit;"><div style="font-size: 24px; font-weight: bold;">视频分享平台</div></a>
        <div class="nav-links">
            <%
                // 检查用户是否登录
                User currentUser = (User) session.getAttribute("user");
                if (currentUser != null) {
            %>
                <span class="welcome-user">欢迎, <%= currentUser.getUsername() %></span>
                <a href="/">首页</a>
                <a href="/user/me">个人中心</a>
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
        <h1 class="history-title">观看历史</h1>
        <%-- 历史记录列表 --%>
        <div class="history-list">
            <%
                List<History> historyList = (List<History>) request.getAttribute("historyList");
                if (historyList != null && !historyList.isEmpty()) {
                    for (History history : historyList) {
                        Video video = history.getVideo();
                        pageContext.setAttribute("video", video);
            %>
            <div class="history-item">
                <div class="history-cover" style="background-size: contain;background-repeat: no-repeat;background-image: url('<%= video.getCoverUrl() != null && !video.getCoverUrl().isEmpty() ? video.getCoverUrl() : "/static/images/default_cover.png" %>')"
                     onclick="playVideo(${video.id})"></div>
                <div class="history-info">
                    <div class="history-title" onclick="playVideo(${video.id})">${video.title}</div>
                    <div class="history-meta">
                        <span>👁️ ${video.viewCount}</span>
                        <span>👍 ${video.likeCount}</span>
                        <span>⭐ ${video.favCount}</span>
                    </div>
                    <a href="/user/${video.author.id}" class="history-author">
                        <img src="${video.author.avatarUrl != null && !video.author.avatarUrl.isEmpty() ? video.author.avatarUrl : '/static/images/default_avatar.png'}" alt="头像" class="author-avatar" onerror="this.src='/static/images/default_avatar.png'">
                        <span>${video.author.username}</span>
                    </a>
                    <div class="history-time">
                        观看时间: ${history.timeView}
                    </div>
                </div>
            </div>
            <%
                    }
                } else {
            %>
            <div class="empty-history">
                <h3>暂无观看记录</h3>
                <p>快去首页看看精彩视频吧！</p>
                <a href="/" style="color: #00a1d6; text-decoration: none;">返回首页</a>
            </div>
            <%
                }
            %>
        </div>
    </div>
    <script>
        function playVideo(videoId) {
            window.location.href = '/video/detail?id='+videoId;
        }
    </script>
</body>
</html>