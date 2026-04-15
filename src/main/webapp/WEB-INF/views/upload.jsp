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
        :root {
            --ink: #1f2a37;
            --sub: #5f6b7a;
            --sub2: #8a94a3;
            --line: rgba(31, 42, 55, 0.1);
            --paper: rgba(255, 252, 246, 0.86);
            --panel: rgba(255, 255, 255, 0.9);
            --gold: #b18135;
            --teal: #2d6c8b;
            --danger: #c44762;
            --radius-xl: 24px;
            --radius-lg: 18px;
            --radius-md: 12px;
            --radius-pill: 999px;
            --shadow-soft: 0 10px 30px rgba(24, 36, 56, 0.08);
            --shadow-panel: 0 16px 34px rgba(16, 26, 40, 0.12);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: "HarmonyOS Sans SC", "MiSans", "PingFang SC", "Microsoft YaHei", sans-serif;
            color: var(--ink);
            background: transparent;
        }

        .header {
            width: min(1480px, calc(100% - 48px));
            height: 76px;
            margin: 16px auto 0;
            padding: 0 30px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            border-radius: 24px;
            background: var(--paper);
            border: 1px solid rgba(255, 255, 255, 0.72);
            backdrop-filter: blur(14px) saturate(130%);
            -webkit-backdrop-filter: blur(14px) saturate(130%);
            box-shadow: var(--shadow-soft);
            position: sticky;
            top: 12px;
            z-index: 100;
        }

        .logo {
            text-decoration: none;
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
            font-size: 30px;
            font-weight: 700;
            letter-spacing: 0.4px;
            background: linear-gradient(120deg, var(--gold) 0%, #c89d4f 45%, var(--teal) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .nav {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .nav a {
            color: var(--sub);
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            padding: 8px 12px;
            border-radius: var(--radius-pill);
            transition: all 0.2s ease;
        }

        .nav a:hover {
            color: var(--teal);
            background: rgba(45, 108, 139, 0.09);
        }

        .main {
            width: min(980px, calc(100% - 24px));
            margin: 28px auto 36px;
        }

        .card {
            background: var(--panel);
            border-radius: var(--radius-xl);
            border: 1px solid rgba(255, 255, 255, 0.84);
            box-shadow: var(--shadow-panel);
            padding: 24px;
        }

        h1 {
            margin: 0 0 18px;
            font-size: 30px;
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
        }

        .msg {
            border-radius: 10px;
            padding: 10px 12px;
            margin-bottom: 12px;
            font-size: 14px;
        }

        .msg.error {
            background: rgba(196, 71, 98, 0.1);
            border: 1px solid rgba(196, 71, 98, 0.28);
            color: var(--danger);
        }

        .msg.success {
            background: rgba(45, 108, 139, 0.12);
            border: 1px solid rgba(45, 108, 139, 0.26);
            color: var(--teal);
        }

        .field { margin-bottom: 14px; }

        .field label {
            display: block;
            margin-bottom: 6px;
            color: var(--sub);
            font-size: 13px;
            font-weight: 600;
        }

        .field input[type="text"],
        .field textarea,
        .field input[type="file"] {
            width: 100%;
            border: 1px solid var(--line);
            border-radius: var(--radius-md);
            padding: 10px 12px;
            outline: none;
            font-size: 14px;
            font-family: inherit;
            background: #fff;
            transition: all 0.2s ease;
        }

        .field textarea {
            min-height: 110px;
            resize: vertical;
        }

        .field input:focus,
        .field textarea:focus {
            border-color: rgba(45, 108, 139, 0.45);
            box-shadow: 0 0 0 4px rgba(45, 108, 139, 0.13);
        }

        .btn {
            width: 100%;
            height: 46px;
            border: none;
            border-radius: var(--radius-md);
            background: linear-gradient(120deg, var(--teal), #3a86a9);
            color: #fff;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 12px 22px rgba(45, 108, 139, 0.24);
        }

        .tip {
            margin-top: 10px;
            color: var(--sub2);
            font-size: 12px;
            line-height: 1.6;
        }

        @media (max-width: 980px) {
            .header {
                width: calc(100% - 28px);
                height: auto;
                padding: 14px 16px;
                flex-wrap: wrap;
                gap: 10px;
            }
        }
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
