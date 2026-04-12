<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="com.assessment.www.po.User" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LiBiLiBi - 首页</title>
    <style>
        :root {
            --brand-blue: #00aeec;
            --brand-pink: #fb7299;
            --text: #18191c;
            --sub: #61666d;
            --sub2: #9499a0;
            --line: #e3e5e7;
            --bg: #f6f7f8;
            --card: #ffffff;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            color: var(--text);
            background: var(--bg);
            position: relative;
            min-height: 100vh;
        }
        .bg-scene {
            position: fixed;
            inset: 0;
            z-index: 0;
            pointer-events: none;
            background-image:
                linear-gradient(130deg, rgba(9, 19, 31, 0.6), rgba(16, 26, 36, 0.34) 40%, rgba(251, 114, 153, 0.2) 100%),
                radial-gradient(circle at 12% 14%, rgba(0, 174, 236, 0.36), transparent 36%),
                radial-gradient(circle at 92% 84%, rgba(251, 114, 153, 0.28), transparent 38%),
                url('${pageContext.request.contextPath}/static/images/background/default.jpg');
            background-size: cover, cover, cover, cover;
            background-position: center;
            background-repeat: no-repeat;
            filter: saturate(1.08) contrast(1.02);
        }
        .bg-scene::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(to bottom, rgba(246, 247, 248, 0.1) 0%, rgba(246, 247, 248, 0.75) 62%, rgba(246, 247, 248, 0.92) 100%);
        }
        .header {
            height: 68px;
            background: #fff;
            border-bottom: 1px solid var(--line);
            position: sticky;
            top: 0;
            z-index: 100;
            display: flex;
            align-items: center;
            padding: 0 24px;
            gap: 20px;
        }
        .logo {
            color: var(--brand-blue);
            text-decoration: none;
            font-size: 25px;
            font-weight: 800;
            letter-spacing: 0.6px;
            white-space: nowrap;
        }
        .search {
            flex: 1;
            max-width: 560px;
            display: flex;
        }
        .search input {
            flex: 1;
            height: 40px;
            border: 1px solid var(--line);
            border-right: none;
            border-radius: 20px 0 0 20px;
            padding: 0 14px;
            outline: none;
            background: #f8fafc;
        }
        .search button {
            width: 92px;
            border: 1px solid var(--line);
            border-radius: 0 20px 20px 0;
            cursor: pointer;
            background: #fff;
        }
        .search button:hover { background: #f1f9fd; color: var(--brand-blue); }
        .nav {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: flex-end;
        }
        .nav a {
            color: var(--sub);
            text-decoration: none;
            font-size: 14px;
            padding: 7px 10px;
            border-radius: 7px;
            transition: 0.2s;
        }
        .nav a:hover { background: #edf9ff; color: var(--brand-blue); }
        .nav .upload {
            background: var(--brand-pink);
            color: #fff;
            padding: 8px 14px;
            border-radius: 8px;
            font-weight: 700;
        }
        .nav .upload:hover { background: #f95d89; color: #fff; }
        .main {
            width: min(1400px, 100%);
            margin: 22px auto 40px;
            padding: 0 24px;
            position: relative;
            z-index: 1;
        }
        .hero {
            background: linear-gradient(135deg, rgba(0,174,236,.12), rgba(251,114,153,.13));
            border: 1px solid rgba(0,174,236,.2);
            border-radius: 14px;
            padding: 18px;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            flex-wrap: wrap;
        }
        .hero h1 {
            margin: 0 0 6px;
            font-size: 24px;
            line-height: 1.2;
        }
        .hero p {
            margin: 0;
            color: var(--sub);
            font-size: 14px;
        }
        .hero-note {
            color: #0a6d95;
            font-weight: 600;
        }
        .hero-note strong {
            color: var(--brand-pink);
            font-size: 16px;
        }
        .hero-actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .hero-actions a {
            text-decoration: none;
            font-size: 13px;
            border-radius: 999px;
            padding: 8px 12px;
            border: 1px solid var(--line);
            background: #fff;
            color: var(--sub);
        }
        .hero-actions a.primary {
            background: var(--brand-blue);
            border-color: var(--brand-blue);
            color: #fff;
        }
        .headline {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 14px;
        }
        .headline h2 { margin: 0; font-size: 24px; }
        .headline a { color: var(--brand-blue); text-decoration: none; font-size: 14px; }
        .tools {
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            flex-wrap: wrap;
        }
        .chips { display: flex; gap: 8px; flex-wrap: wrap; }
        .chip {
            height: 30px;
            border-radius: 999px;
            border: 1px solid var(--line);
            background: #fff;
            color: var(--sub);
            padding: 0 12px;
            cursor: pointer;
            font-size: 12px;
        }
        .chip.active {
            color: #fff;
            border-color: var(--brand-blue);
            background: var(--brand-blue);
        }
        .tip-count {
            font-size: 13px;
            color: var(--sub2);
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
        }
        .card {
            text-decoration: none;
            color: inherit;
            background: var(--card);
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 24px rgba(0, 0, 0, 0.1);
        }
        .cover {
            width: 100%;
            aspect-ratio: 16 / 9;
            object-fit: cover;
            display: block;
            background: #eef1f4;
        }
        .info { padding: 10px 12px 14px; }
        .title {
            font-size: 15px;
            line-height: 1.45;
            min-height: 42px;
            display: -webkit-box;
            line-clamp: 2;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            margin-bottom: 8px;
        }
        .meta {
            color: var(--sub2);
            font-size: 13px;
            display: flex;
            justify-content: space-between;
            gap: 10px;
        }
        .empty {
            text-align: center;
            background: #fff;
            border: 1px dashed var(--line);
            border-radius: 10px;
            padding: 48px 20px;
            color: var(--sub2);
        }
        @media (max-width: 820px) {
            .header {
                height: auto;
                padding: 12px;
                flex-wrap: wrap;
            }
            .search { order: 3; width: 100%; max-width: none; }
            .nav { width: 100%; margin-left: 0; justify-content: flex-start; }
            .main { padding: 0 12px; }
        }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<%
    User user = (User) session.getAttribute("user");
    List<Video> videos = (List<Video>) request.getAttribute("videos");
    int recommendedCount = videos != null ? videos.size() : 0;
%>

<header class="header">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>

    <form class="search" action="${pageContext.request.contextPath}/video/search" method="get">
        <input type="text" name="keyword" placeholder="搜索你感兴趣的视频...">
        <button type="submit">搜索</button>
    </form>

    <nav class="nav">
        <a href="${pageContext.request.contextPath}/video/search">全部视频</a>
        <% if (user != null) { %>
        <a href="${pageContext.request.contextPath}/user/profile"><%= user.getUsername() %></a>
        <a href="${pageContext.request.contextPath}/video/upload" class="upload">投稿</a>
        <a href="${pageContext.request.contextPath}/user/logout">退出</a>
        <% if ("admin".equals(user.getRole())) { %>
        <a href="${pageContext.request.contextPath}/admin/adminindex">后台</a>
        <% } %>
        <% } else { %>
        <a href="${pageContext.request.contextPath}/user/login">登录</a>
        <a href="${pageContext.request.contextPath}/user/register">注册</a>
        <% } %>
    </nav>
</header>

<main class="main">
    <section class="hero">
        <div>
            <h1>欢迎来到 LiBiLiBi</h1>
            <p class="hero-note">今天为你准备了 <strong><%= recommendedCount %></strong> 个推荐视频，支持按播放/点赞快速重排。</p>
        </div>
        <div class="hero-actions">
            <a class="primary" href="${pageContext.request.contextPath}/video/search">进入视频区</a>
            <a href="${pageContext.request.contextPath}/video/upload">立即投稿</a>
        </div>
    </section>

    <div class="headline">
        <h2>推荐视频</h2>
        <a href="${pageContext.request.contextPath}/video/search">查看更多</a>
    </div>

    <div class="tools">
        <div class="chips" id="sortChips">
            <button class="chip active" type="button" data-sort="default">默认排序</button>
            <button class="chip" type="button" data-sort="view">按播放</button>
            <button class="chip" type="button" data-sort="like">按点赞</button>
            <button class="chip" type="button" data-sort="fav">按收藏</button>
        </div>
        <div class="tip-count">当前展示 <span id="visibleCount"><%= recommendedCount %></span> 条</div>
    </div>

    <% if (videos != null && !videos.isEmpty()) { %>
    <div class="grid">
        <% for (Video v : videos) {
               int views = v.getViewCount() != null ? v.getViewCount() : 0;
               int likes = v.getLikeCount() != null ? v.getLikeCount() : 0;
               int favs = v.getFavCount() != null ? v.getFavCount() : 0;
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
        <a class="card" data-view="<%= views %>" data-like="<%= likes %>" data-fav="<%= favs %>" href="${pageContext.request.contextPath}/video/detail?id=<%= v.getId() %>">
            <img class="cover" loading="lazy" decoding="async" src="<%= coverUrl %>"
                 alt="<%= v.getTitle() %>" onerror="this.src='${pageContext.request.contextPath}/static/images/default_cover.png'">
            <div class="info">
                <div class="title"><%= v.getTitle() %></div>
                <div class="meta">
                    <span>👁 <%= views %></span>
                    <span>👍 <%= likes %> · ⭐ <%= favs %></span>
                </div>
            </div>
        </a>
        <% } %>
    </div>
    <% } else { %>
    <div class="empty">暂时还没有视频，稍后回来看看吧。</div>
    <% } %>
</main>

<script>
    (function () {
        var grid = document.querySelector('.grid');
        var chips = document.querySelectorAll('#sortChips .chip');
        var countNode = document.getElementById('visibleCount');
        if (!grid || !chips.length) return;

        var originalCards = Array.prototype.slice.call(grid.querySelectorAll('.card'));
        if (countNode) countNode.textContent = String(originalCards.length);

        function getVal(card, key) {
            var v = parseInt(card.getAttribute('data-' + key), 10);
            return isNaN(v) ? 0 : v;
        }

        function render(cards) {
            var frag = document.createDocumentFragment();
            cards.forEach(function (c) { frag.appendChild(c); });
            grid.innerHTML = '';
            grid.appendChild(frag);
            if (countNode) countNode.textContent = String(cards.length);
        }

        chips.forEach(function (chip) {
            chip.addEventListener('click', function () {
                chips.forEach(function (c) { c.classList.remove('active'); });
                chip.classList.add('active');
                var type = chip.getAttribute('data-sort');
                var cards = originalCards.slice();
                if (type === 'view' || type === 'like' || type === 'fav') {
                    cards.sort(function (a, b) { return getVal(b, type) - getVal(a, type); });
                }
                render(cards);
            });
        });
    })();
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
