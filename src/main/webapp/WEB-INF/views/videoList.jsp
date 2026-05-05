<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.User" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>视频列表</title>
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
        .search-bar {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .search-input {
            flex: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .search-btn {
            padding: 10px 20px;
            background-color: #00a1d6;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-btn:hover {
            background-color: #0088b3;
        }
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        .video-card {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .video-card:hover {
            transform: translateY(-5px);
        }
        .video-cover {
            width: 100%;
            height: 200px;
            background-size: cover;
            background-position: center;
            cursor: pointer;
            position: relative;
        }
        .video-cover:hover {
            opacity: 0.9;
        }
        .video-duration {
            position: absolute;
            bottom: 5px;
            right: 5px;
            background: rgba(0, 0, 0, 0.7);
            color: white;
            padding: 2px 5px;
            border-radius: 3px;
            font-size: 12px;
        }
        .video-info {
            padding: 15px;
        }
        .video-title {
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 5px;
            cursor: pointer;
            color: #333;
        }
        .video-title:hover {
            color: #00a1d6;
        }
        .video-meta {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
        }
        .video-meta span {
            margin-right: 15px;
        }
        .video-author {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #333;
            text-decoration: none;
        }
        .video-author:hover {
            color: #00a1d6;
        }
        .author-avatar {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background-color: #ddd;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 30px;
        }
        .page-btn {
            padding: 8px 15px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            color: #333;
        }
        .page-btn:hover,
        .page-btn.active {
            background-color: #00a1d6;
            color: white;
            border-color: #00a1d6;
        }
        .upload-btn {
            background-color: #ff6b6b;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
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
                <a href="/">返回首页</a>
                <span class="welcome-user">欢迎, <%= currentUser.getUsername() %></span>
                <a href="/user/me">个人中心</a>
                <a href="/video/dynamic">动态</a>
                <a href="/ticket/index">漫展活动</a>
                <a href="/user/logout">退出登录</a>
                <a href="/video/upload" class="upload-btn">上传视频</a>
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
        <div class="search-bar">
            <input type="text" class="search-input" id="searchInput" value="${keyword}" placeholder="搜索视频...">
            <button class="search-btn" onclick="searchVideos()">搜索</button>
        </div>
        <div class="video-grid">
            <%-- 遍历视频列表 --%>
            <%
                List<Video> videos = (List<Video>) request.getAttribute("videos");
                if (videos != null) {
                    for (Video video : videos) {
                         pageContext.setAttribute("video", video);
            %>
            <div class="video-card">
                <div class="video-cover" style="background-repeat: no-repeat;background-size: contain;background-image: url('<%= video.getCoverUrl() != null && !video.getCoverUrl().isEmpty() ? video.getCoverUrl() : "/static/images/default_cover.png" %>')"
                     onclick="playVideo(${video.id})">
                    <div class="video-duration"></div>
                </div>
                <div class="video-info">
                    <div class="video-title" onclick="playVideo(${video.id})">${video.title}</div>
                    <div class="video-meta">
                        <span>👁️ ${video.viewCount}</span>
                        <span>👍 ${video.likeCount}</span>
                        <span>⭐ ${video.favCount}</span>
                    </div>
                    <a href="/user/${video.authorId}" class="video-author">
                        <img src="${video.author.avatarUrl != null && !video.author.avatarUrl.isEmpty() ? video.author.avatarUrl : "/static/images/default_avatar.png"}" alt="头像" class="author-avatar" onerror="this.src='/static/images/default_avatar.png'">
                        <span>${video.author.username}</span>
                    </a>
                </div>
            </div>
            <%
                    }
                } else {
            %>
            <p>暂无视频</p>
            <%
                }
            %>
        </div>
        <%-- 分页 --%>
        <%
            int currentPage = (Integer) request.getAttribute("currentPage");
            int totalPages = (Integer) request.getAttribute("totalPages");
            if (totalPages > 1) {
        %>
        <div class="pagination">
            <%-- 上一页 --%>
            <%
                if (currentPage > 1) {
            %>
            <a href="/video/search?page=<%= currentPage - 1 %>" class="page-btn">上一页</a>
            <%
                }
            %>
            <%-- 页码 - 只显示最多5个页码 --%>
            <%
                int startPage = Math.max(1, currentPage - 2);
                int endPage = Math.min(totalPages, currentPage + 2);
                if (startPage > 1) {
            %>
            <a href="/video/search?page=1" class="page-btn">1</a>
            <%
                    if (startPage > 2) {
            %>
            <span style="padding: 0 10px;">...</span>
            <%
                    }
                }
                for (int i = startPage; i <= endPage; i++) {
                    if (i == currentPage) {
            %>
            <span class="page-btn active"><%= i %></span>
            <%
                    } else {
            %>
            <a href="/video/search?page=<%= i %>" class="page-btn"><%= i %></a>
            <%
                    }
                }
                if (endPage < totalPages) {
                    if (endPage < totalPages - 1) {
            %>
            <span style="padding: 0 10px;">...</span>
            <%
                    }
            %>
            <a href="/video/search?page=<%= totalPages %>" class="page-btn"><%= totalPages %></a>
            <%
                }
            %>
            <%-- 下一页 --%>
            <%
                if (currentPage < totalPages) {
            %>
            <a href="/video/search?page=<%= currentPage + 1 %>" class="page-btn">下一页</a>
            <%
                }
            %>
        </div>
        <%
            }
        %>
    </div>
    <script>
         function playVideo(videoId) {
             window.location.href = '/video/detail?id=' + videoId;
         }
         function searchVideos() {
             const keyword = document.getElementById('searchInput').value.trim();
             if (keyword) {
                 window.location.href = '/video/search?keyword=' + encodeURIComponent(keyword);
             } else {
                 window.location.href = '/video/list';
             }
         }
         document.getElementById('searchInput').addEventListener('keypress', function(e) {
             if (e.key === 'Enter') {
                 searchVideos();
             }
         });
    </script>
</body>
</html>