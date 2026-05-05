<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="com.assessment.www.po.User" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>关注动态</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #f5f7fb;
        }
        .header {
            background-color: #00a1d6;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }
        .nav-links {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            align-items: center;
        }
        .nav-links a {
            color: white;
            text-decoration: none;
            padding: 5px 10px;
        }
        .nav-links a.active {
            background: rgba(255,255,255,0.18);
            border-radius: 6px;
        }
        .welcome-user {
            color: white;
        }
        .main-container {
            max-width: 1280px;
            margin: 24px auto;
            padding: 0 20px 28px;
        }
        .page-hero {
            background: linear-gradient(135deg, #ffffff 0%, #eef7ff 100%);
            border: 1px solid rgba(0, 161, 214, 0.12);
            border-radius: 18px;
            padding: 22px 24px;
            margin-bottom: 20px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.06);
        }
        .page-title {
            margin: 0 0 8px 0;
            font-size: 30px;
            color: #0f172a;
        }
        .page-desc {
            margin: 0;
            color: #64748b;
            line-height: 1.6;
        }
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 18px;
        }
        .video-card {
            background: white;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.08);
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }
        .video-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 14px 30px rgba(15, 23, 42, 0.12);
        }
        .video-cover {
            width: 100%;
            aspect-ratio: 16 / 9;
            background-size: contain;
            background-repeat: no-repeat;
            background-position: center;
            background-color: #0f172a;
            cursor: pointer;
        }
        .video-info {
            padding: 14px 15px 16px;
        }
        .video-title {
            margin: 0 0 8px 0;
            font-size: 16px;
            font-weight: bold;
            color: #1f2937;
            cursor: pointer;
            line-height: 1.4;
            min-height: 44px;
        }
        .video-title:hover {
            color: #00a1d6;
        }
        .video-meta {
            font-size: 13px;
            color: #64748b;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 10px;
        }
        .video-author {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            color: #334155;
        }
        .author-avatar {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            object-fit: cover;
            background: #e2e8f0;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 28px;
            flex-wrap: wrap;
        }
        .page-btn {
            padding: 8px 14px;
            border: 1px solid #dbe3ee;
            background: white;
            border-radius: 999px;
            cursor: pointer;
            text-decoration: none;
            color: #334155;
        }
        .page-btn:hover,
        .page-btn.active {
            background-color: #00a1d6;
            color: white;
            border-color: #00a1d6;
        }
        .empty-state {
            background: white;
            border-radius: 18px;
            padding: 64px 24px;
            text-align: center;
            color: #64748b;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.08);
        }
        .empty-state h3 {
            margin: 0 0 10px 0;
            color: #0f172a;
            font-size: 22px;
        }
        .empty-state p {
            margin: 0 0 20px 0;
        }
        .empty-state a {
            color: #00a1d6;
            text-decoration: none;
        }
        @media (max-width: 768px) {
            .page-title {
                font-size: 24px;
            }
            .video-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <a href="${pageContext.request.contextPath}/" style="text-decoration: none; color: inherit;"><div style="font-size: 24px; font-weight: bold;">视频分享平台</div></a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/">首页</a>
            <a href="${pageContext.request.contextPath}/video/dynamic" class="active">动态</a>
            <%
                User currentUser = (User) session.getAttribute("user");
                if (currentUser != null) {
            %>
                <span class="welcome-user">欢迎, <%= currentUser.getUsername() %></span>
                <a href="${pageContext.request.contextPath}/user/me">个人中心</a>
                <a href="${pageContext.request.contextPath}/ticket/index">漫展活动</a>
                <a href="${pageContext.request.contextPath}/video/upload">上传视频</a>
                <a href="${pageContext.request.contextPath}/user/logout">退出登录</a>
                <%
                    if ("admin".equals(currentUser.getRole())) {
                %>
                    <a href="${pageContext.request.contextPath}/admin/adminindex">管理后台</a>
                <%
                    }
                %>
            <%
                } else {
            %>
                <a href="${pageContext.request.contextPath}/user/login">登录</a>
                <a href="${pageContext.request.contextPath}/user/register">注册</a>
            <%
                }
            %>
        </div>
    </div>
    <div class="main-container">
        <div class="page-hero">
            <h1 class="page-title">关注动态</h1>
            <p class="page-desc">这里展示你关注的用户最近发布的视频，按发布时间倒序排列。</p>
        </div>

        <%
            List<Video> videos = (List<Video>) request.getAttribute("videos");
            Integer currentPageObj = (Integer) request.getAttribute("currentPage");
            Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
            int currentPage = currentPageObj != null ? currentPageObj : 1;
            int totalPages = totalPagesObj != null ? totalPagesObj : 1;
            if (videos != null && !videos.isEmpty()) {
        %>
        <div class="video-grid">
            <%
                for (Video video : videos) {
                    pageContext.setAttribute("video", video);
            %>
            <div class="video-card">
                <div class="video-cover" style="background-image: url('<%= video.getCoverUrl() != null ? video.getCoverUrl() : "/static/images/default_cover.png" %>')" onclick="playVideo(${video.id})"></div>
                <div class="video-info">
                    <div class="video-title" onclick="playVideo(${video.id})">${video.title}</div>
                    <div class="video-meta">
                        <span>👁️ ${video.viewCount}</span>
                        <span>👍 ${video.likeCount}</span>
                        <span>⭐ ${video.favCount}</span>
                    </div>
                    <a class="video-author" href="${pageContext.request.contextPath}/user/${video.authorId}">
                        <img src="${video.author != null && video.author.avatarUrl != null ? video.author.avatarUrl : '/static/images/default_avatar.png'}" alt="头像" class="author-avatar">
                        <span>${video.author != null ? video.author.username : '未知用户'}</span>
                    </a>
                </div>
            </div>
            <%
                }
            %>
        </div>
        <div class="pagination">
            <%
                if (currentPage > 1) {
            %>
            <a class="page-btn" href="${pageContext.request.contextPath}/video/dynamic?page=<%= currentPage - 1 %>">上一页</a>
            <%
                }
                for (int i = 1; i <= totalPages; i++) {
                    if (i == currentPage) {
            %>
            <a class="page-btn active" href="${pageContext.request.contextPath}/video/dynamic?page=<%= i %>"><%= i %></a>
            <%
                    } else {
            %>
            <a class="page-btn" href="${pageContext.request.contextPath}/video/dynamic?page=<%= i %>"><%= i %></a>
            <%
                    }
                }
                if (currentPage < totalPages) {
            %>
            <a class="page-btn" href="${pageContext.request.contextPath}/video/dynamic?page=<%= currentPage + 1 %>">下一页</a>
            <%
                }
            %>
        </div>
        <%
            } else {
        %>
        <div class="empty-state">
            <h3>这里还是空的</h3>
            <p>你关注的人还没有发布视频，或者当前内容不对你可见。</p>
            <a href="${pageContext.request.contextPath}/">去首页看看</a>
        </div>
        <%
            }
        %>
    </div>
    <script>
        function playVideo(videoId) {
            window.location.href = '${pageContext.request.contextPath}/video/detail?id=' + videoId;
        }
    </script>
</body>
</html>
