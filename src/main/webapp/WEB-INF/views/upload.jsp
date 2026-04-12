<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.User" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>上传视频 - LiBiLiBi</title>
    <style>
        :root { --blue:#00aeec; --pink:#fb7299; --line:#e3e5e7; --bg:#f6f7f8; --sub:#61666d; }
        * { box-sizing: border-box; }
        body { margin:0; font-family:"Segoe UI",sans-serif; background:var(--bg); color:#18191c; }
        .header { height:68px; background:#fff; border-bottom:1px solid var(--line); display:flex; align-items:center; justify-content:space-between; padding:0 24px; }
        .logo { color:var(--blue); text-decoration:none; font-size:24px; font-weight:800; }
        .nav a { color:var(--sub); text-decoration:none; margin-left:12px; font-size:14px; }
        .nav a:hover { color:var(--blue); }
        .main { width:min(900px,100%); margin:26px auto; padding:0 20px; }
        .card { background:#fff; border-radius:12px; padding:24px; box-shadow:0 8px 24px rgba(0,0,0,.06); }
        h1 { margin:0 0 18px; font-size:24px; }
        .msg { border-radius:8px; padding:10px 12px; margin-bottom:12px; font-size:14px; }
        .msg.error { background:#fff2f4; border:1px solid #ffd7e2; color:#d63b6f; }
        .msg.success { background:#ecfbff; border:1px solid #bcefff; color:#0077a5; }
        .field { margin-bottom:14px; }
        .field label { display:block; margin-bottom:6px; color:var(--sub); font-size:13px; }
        .field input[type="text"], .field textarea, .field input[type="file"] {
            width:100%; border:1px solid var(--line); border-radius:8px; padding:10px 12px; outline:none; font-size:14px; font-family:inherit;
        }
        .field textarea { min-height:110px; resize:vertical; }
        .field input:focus, .field textarea:focus { border-color:var(--blue); box-shadow:0 0 0 3px rgba(0,174,236,.12); }
        .btn { width:100%; height:46px; border:none; border-radius:10px; background:linear-gradient(90deg,var(--blue),#22c7ff); color:#fff; font-size:15px; font-weight:700; cursor:pointer; }
        .tip { margin-top:10px; color:#9499a0; font-size:12px; }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/user/login");
        return;
    }
%>
<header class="header">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>
    <nav class="nav">
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/user/profile">个人中心</a>
        <a href="${pageContext.request.contextPath}/video/myvideos">我的视频</a>
    </nav>
</header>

<main class="main">
    <section class="card">
        <h1>上传视频</h1>

        <%
            String err = (String) request.getAttribute("error");
            String succ = request.getParameter("success");
            if (err == null) err = request.getParameter("error");
            if (err != null && !err.isEmpty()) {
        %>
        <div class="msg error"><%= err %></div>
        <% } %>
        <% if (succ != null && !succ.isEmpty()) { %>
        <div class="msg success"><%= succ %></div>
        <% } %>

        <form id="uploadForm" action="${pageContext.request.contextPath}/video/upload" method="post" enctype="multipart/form-data">
            <div class="field">
                <label for="title">标题</label>
                <input id="title" name="title" type="text" required placeholder="请输入视频标题">
            </div>

            <div class="field">
                <label for="description">简介</label>
                <textarea id="description" name="description" placeholder="介绍一下你的视频内容"></textarea>
            </div>

            <div class="field">
                <label for="videoFile">视频文件</label>
                <input id="videoFile" name="videoFile" type="file" accept="video/*" required>
            </div>

            <div class="field">
                <label for="coverFile">封面图片（可选）</label>
                <input id="coverFile" name="coverFile" type="file" accept="image/*">
                <div class="tip">支持 JPG/PNG/WEBP/GIF，大小不超过 5MB。</div>
            </div>

            <div class="field">
                <label for="coverUrl">封面链接（可选，未上传图片时生效）</label>
                <input id="coverUrl" name="coverUrl" type="text" placeholder="例如：https://example.com/cover.jpg 或 /static/images/default_cover.png">
            </div>

            <button class="btn" type="submit">开始上传</button>
            <div class="tip">上传成功后会跳转到视频详情页。</div>
        </form>
    </section>
</main>

<script>
    document.getElementById("uploadForm").addEventListener("submit", function (e) {
        var title = document.getElementById("title").value.trim();
        var videoFile = document.getElementById("videoFile").files[0];
        var coverFile = document.getElementById("coverFile").files[0];
        if (!title) { e.preventDefault(); alert("请输入标题"); return; }
        if (!videoFile) { e.preventDefault(); alert("请选择视频文件"); return; }
        if (coverFile) {
            if (!coverFile.type || coverFile.type.indexOf("image/") !== 0) {
                e.preventDefault();
                alert("封面文件必须是图片格式");
                return;
            }
            if (coverFile.size > 5 * 1024 * 1024) {
                e.preventDefault();
                alert("封面图片不能超过 5MB");
            }
        }
    });
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
