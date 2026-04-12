<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.Video" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>播放页 - LiBiLiBi</title>
    <style>
        :root { --blue:#00aeec; --line:#e3e5e7; --bg:#f6f7f8; }
        * { box-sizing: border-box; }
        body { margin:0; font-family:"Segoe UI",sans-serif; background:var(--bg); color:#18191c; }
        .header { height:68px; background:#fff; border-bottom:1px solid var(--line); display:flex; align-items:center; justify-content:space-between; padding:0 24px; }
        .logo { color:var(--blue); text-decoration:none; font-size:24px; font-weight:800; }
        .nav a { text-decoration:none; color:#61666d; margin-left:12px; font-size:14px; }
        .main { width:min(1000px,100%); margin:20px auto; padding:0 20px; }
        .panel { background:#fff; border-radius:12px; box-shadow:0 6px 18px rgba(0,0,0,.05); padding:16px; }
        .player { width:100%; aspect-ratio:16/9; border-radius:10px; overflow:hidden; background:#000; margin-bottom:12px; }
        .player video { width:100%; height:100%; }
        .title { margin:0 0 8px; font-size:24px; }
        .meta { color:#9499a0; font-size:13px; }
        .tips { color:#61666d; font-size:14px; line-height:1.6; }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<%
    Video video = (Video) request.getAttribute("video");
%>
<header class="header">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>
    <nav class="nav">
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/video/search">视频</a>
        <a href="${pageContext.request.contextPath}/user/profile">个人中心</a>
    </nav>
</header>

<main class="main">
    <section class="panel">
        <% if (video != null) { %>
            <div class="player">
                <video controls autoplay>
                    <source src="<%= video.getVideoUrl() %>" type="video/mp4">
                </video>
            </div>
            <h1 class="title"><%= video.getTitle() %></h1>
            <div class="meta">播放 <%= video.getViewCount() != null ? video.getViewCount() : 0 %> | 点赞 <%= video.getLikeCount() != null ? video.getLikeCount() : 0 %> | 收藏 <%= video.getFavCount() != null ? video.getFavCount() : 0 %></div>
            <p class="tips" style="margin-top:12px;"><%= video.getDescription() != null ? video.getDescription() : "暂无简介。" %></p>
        <% } else { %>
            <h2>当前播放页未获取到视频对象。</h2>
            <p class="tips">请通过带 id 参数的视频详情路由进入：<a href="${pageContext.request.contextPath}/video/search" style="color:#00aeec;text-decoration:none;">打开视频列表</a>。</p>
        <% } %>
    </section>
</main>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
