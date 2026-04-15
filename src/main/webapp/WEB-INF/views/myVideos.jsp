<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的视频 - LiBiLiBi</title>
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
            --shadow-hover: 0 18px 34px rgba(18, 28, 45, 0.14);
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
            text-decoration: none;
            color: var(--sub);
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

        .nav .upload {
            color: #fff;
            font-weight: 700;
            background: linear-gradient(120deg, var(--gold) 0%, #c89d4f 100%);
            box-shadow: 0 10px 20px rgba(177, 129, 53, 0.3);
            padding: 9px 16px;
        }

        .main {
            width: min(1480px, calc(100% - 56px));
            margin: 28px auto 36px;
        }

        .top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
        }

        .top h1 {
            margin: 0;
            font-size: 32px;
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

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 22px;
        }

        .card {
            background: var(--panel);
            border: 1px solid rgba(255, 255, 255, 0.84);
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-panel);
            transition: transform 0.26s ease, box-shadow 0.26s ease;
        }

        .card:hover {
            transform: translateY(-8px);
            box-shadow: var(--shadow-hover);
        }

        .cover {
            width: calc(100% - 16px);
            margin: 8px 8px 0;
            border-radius: 12px;
            aspect-ratio: 16 / 9;
            object-fit: cover;
            background: #eef1f4;
            display: block;
            cursor: pointer;
        }

        .info { padding: 12px 14px 14px; }

        .title {
            font-size: 15px;
            font-weight: 700;
            line-height: 1.5;
            margin-bottom: 8px;
            min-height: 42px;
            overflow: hidden;
        }

        .meta {
            color: var(--sub2);
            font-size: 12px;
            margin-bottom: 10px;
            line-height: 1.6;
        }

        .status {
            display: inline-block;
            font-size: 12px;
            border-radius: var(--radius-pill);
            padding: 4px 9px;
            margin-bottom: 10px;
            font-weight: 700;
        }

        .status.pending { background: rgba(177, 129, 53, 0.14); color: #8d6126; }
        .status.ok { background: rgba(45, 108, 139, 0.14); color: var(--teal); }
        .status.bad { background: rgba(196, 71, 98, 0.14); color: var(--danger); }

        .actions { display: flex; gap: 8px; }

        .btn {
            flex: 1;
            border: none;
            border-radius: var(--radius-md);
            height: 36px;
            cursor: pointer;
            color: #fff;
            font-size: 13px;
            font-weight: 700;
        }

        .btn.play { background: linear-gradient(120deg, var(--teal), #3a86a9); }
        .btn.del { background: linear-gradient(120deg, #c44762, #e06b84); }

        .empty {
            text-align: center;
            background: rgba(255, 255, 255, 0.9);
            border: 1px dashed rgba(177, 129, 53, 0.3);
            border-radius: var(--radius-lg);
            padding: 50px 20px;
            color: var(--sub2);
            box-shadow: var(--shadow-soft);
        }

        .empty a {
            color: var(--teal);
            text-decoration: none;
            font-weight: 700;
        }

        @media (max-width: 980px) {
            .header {
                width: calc(100% - 28px);
                height: auto;
                padding: 14px 16px;
                flex-wrap: wrap;
                gap: 10px;
            }

            .main {
                width: calc(100% - 24px);
                margin: 22px auto 30px;
            }
        }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<header class="header">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>
    <nav class="nav">
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/user/profile">个人中心</a>
        <a href="${pageContext.request.contextPath}/video/upload" class="upload">上传</a>
    </nav>
</header>

<main class="main">
    <div class="top">
        <h1>我的投稿视频</h1>
    </div>

    <%
        String err = request.getParameter("error");
        String succ = request.getParameter("success");
        if (err != null && !err.isEmpty()) {
    %>
    <div class="msg error"><%= err %></div>
    <% } %>
    <% if (succ != null && !succ.isEmpty()) { %>
    <div class="msg success"><%= succ %></div>
    <% } %>

    <%
        List<Video> videos = (List<Video>) request.getAttribute("videos");
        if (videos != null && !videos.isEmpty()) {
    %>
    <div class="grid">
        <% for (Video v : videos) {
               String statusClass = "pending";
               String statusText = "待审核";
               if (v.getStatus() != null && v.getStatus() == 1) {
                   statusClass = "ok";
                   statusText = "已通过";
               } else if (v.getStatus() != null && v.getStatus() == 2) {
                   statusClass = "bad";
                   statusText = "已驳回";
               }
               String coverUrl = v.getCoverUrl();
               if (coverUrl == null || coverUrl.trim().isEmpty()) {
                   coverUrl = request.getContextPath() + "/static/images/default_cover.png";
               } else if (!(coverUrl.startsWith("http://") || coverUrl.startsWith("https://") || coverUrl.startsWith("data:"))) {
                   if (coverUrl.startsWith("/")) {
                       coverUrl = request.getContextPath() + coverUrl;
                   } else {
                       coverUrl = request.getContextPath() + "/" + coverUrl;
                   }
               }
        %>
        <div class="card">
            <img class="cover" src="<%= coverUrl %>"
                 alt="cover" onclick="goDetail(<%= v.getId() %>)"
                 onerror="this.src='${pageContext.request.contextPath}/static/images/default_cover.png'">
            <div class="info">
                <div class="title"><%= v.getTitle() %></div>
                <div class="meta">播放 <%= v.getViewCount() != null ? v.getViewCount() : 0 %> | 点赞 <%= v.getLikeCount() != null ? v.getLikeCount() : 0 %> | 收藏 <%= v.getFavCount() != null ? v.getFavCount() : 0 %></div>
                <div class="status <%= statusClass %>"><%= statusText %></div>
                <div class="actions">
                    <button class="btn play" onclick="goDetail(<%= v.getId() %>)">查看</button>
                    <button class="btn del" onclick="delVideo(<%= v.getId() %>)">删除</button>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } else { %>
    <div class="empty">
        你还没有投稿视频。<br>
        <a href="${pageContext.request.contextPath}/video/upload">立即上传</a>
    </div>
    <% } %>
</main>

<script>
    function goDetail(id) {
        window.location.href = "${pageContext.request.contextPath}/video/detail?id=" + id;
    }
    function delVideo(id) {
        if (!confirm("确定删除这个视频吗？")) return;
        var form = document.createElement("form");
        form.method = "POST";
        form.action = "${pageContext.request.contextPath}/video/delete";
        var input = document.createElement("input");
        input.type = "hidden";
        input.name = "id";
        input.value = id;
        form.appendChild(input);
        document.body.appendChild(form);
        form.submit();
    }
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
