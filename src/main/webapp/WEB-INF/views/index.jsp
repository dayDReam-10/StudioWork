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
            --ink: #1f2a37;
            --sub: #5f6b7a;
            --sub2: #8a94a3;
            --line: rgba(31, 42, 55, 0.1);
            --paper: rgba(255, 252, 246, 0.86);
            --panel: rgba(255, 255, 255, 0.9);
            --gold: #b18135;
            --gold-strong: #946728;
            --teal: #2d6c8b;
            --teal-soft: #edf7fc;
            --radius-xl: 28px;
            --radius-lg: 20px;
            --radius-md: 12px;
            --radius-pill: 999px;
            --shadow-soft: 0 10px 30px rgba(24, 36, 56, 0.08);
            --shadow-panel: 0 16px 44px rgba(16, 26, 40, 0.12);
            --shadow-hover: 0 20px 46px rgba(18, 28, 45, 0.16);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: "HarmonyOS Sans SC", "MiSans", "PingFang SC", "Microsoft YaHei", sans-serif;
            color: var(--ink);
            background: transparent;
            min-height: 100vh;
            overflow-x: hidden;
        }

        .header {
            width: min(1480px, calc(100% - 48px));
            height: 76px;
            margin: 16px auto 0;
            padding: 0 30px;
            display: flex;
            align-items: center;
            gap: 26px;
            position: sticky;
            top: 12px;
            z-index: 100;
            border-radius: 24px;
            background: var(--paper);
            border: 1px solid rgba(255, 255, 255, 0.72);
            backdrop-filter: blur(14px) saturate(130%);
            -webkit-backdrop-filter: blur(14px) saturate(130%);
            box-shadow: var(--shadow-soft);
            animation: fade-slide-down 0.7s ease both;
        }

        .logo {
            text-decoration: none;
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
            font-size: 30px;
            font-weight: 700;
            letter-spacing: 0.4px;
            white-space: nowrap;
            background: linear-gradient(120deg, var(--gold) 0%, #c89d4f 45%, var(--teal) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            position: relative;
            transition: transform 0.25s ease;
        }

        .logo:hover { transform: translateY(-1px) scale(1.02); }

        .search {
            flex: 1;
            max-width: 560px;
            display: flex;
            align-items: center;
            background: #fff;
            border-radius: var(--radius-pill);
            border: 1px solid rgba(45, 108, 139, 0.15);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.8);
            transition: all 0.25s ease;
        }

        .search:focus-within {
            border-color: rgba(45, 108, 139, 0.45);
            box-shadow: 0 0 0 5px rgba(45, 108, 139, 0.13);
            transform: translateY(-1px);
        }

        .search input {
            flex: 1;
            height: 44px;
            border: none;
            outline: none;
            font-size: 14px;
            color: var(--ink);
            padding: 0 18px;
            background: transparent;
        }

        .search input::placeholder { color: #9ca4b1; }

        .search button {
            width: 84px;
            height: 36px;
            margin-right: 4px;
            border: none;
            border-radius: var(--radius-pill);
            background: linear-gradient(120deg, var(--teal) 0%, #3a86a9 100%);
            color: #fff;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.5px;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .search button:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 16px rgba(45, 108, 139, 0.24);
        }

        .nav {
            margin-left: auto;
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
            padding: 8px 14px;
            border-radius: var(--radius-pill);
            transition: all 0.2s ease;
        }

        .nav a:hover:not(.upload) {
            color: var(--teal);
            background: rgba(45, 108, 139, 0.09);
        }

        .nav .upload {
            color: #fff;
            font-weight: 700;
            background: linear-gradient(120deg, var(--gold) 0%, #c89d4f 100%);
            box-shadow: 0 10px 20px rgba(177, 129, 53, 0.3);
            padding: 9px 20px;
        }

        .nav .upload:hover {
            transform: translateY(-1px);
            box-shadow: 0 14px 24px rgba(177, 129, 53, 0.34);
        }

        .main {
            width: min(1480px, calc(100% - 56px));
            margin: 30px auto 80px;
            position: relative;
            z-index: 1;
        }

        .hero {
            display: grid;
            grid-template-columns: 1.2fr 0.8fr;
            gap: 20px;
            border-radius: var(--radius-xl);
            background: linear-gradient(132deg, rgba(255, 249, 236, 0.95) 0%, rgba(239, 248, 253, 0.95) 56%, rgba(255, 246, 238, 0.93) 100%);
            border: 1px solid rgba(255, 255, 255, 0.8);
            box-shadow: var(--shadow-panel);
            padding: 46px;
            position: relative;
            overflow: hidden;
            animation: fade-up 0.8s cubic-bezier(0.2, 0.9, 0.2, 1) both;
        }

        .hero::before {
            content: "";
            position: absolute;
            right: -90px;
            bottom: -120px;
            width: 360px;
            height: 360px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(177, 129, 53, 0.22) 0%, rgba(177, 129, 53, 0) 72%);
            pointer-events: none;
        }

        .hero-text {
            position: relative;
            z-index: 1;
            max-width: 720px;
        }

        .hero-kicker {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 1.2px;
            color: var(--gold-strong);
            text-transform: uppercase;
            margin-bottom: 14px;
            background: rgba(255, 255, 255, 0.78);
            border: 1px solid rgba(177, 129, 53, 0.2);
            padding: 6px 12px;
            border-radius: var(--radius-pill);
        }

        .hero-text h1 {
            margin: 0;
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
            font-size: clamp(34px, 4vw, 56px);
            font-weight: 700;
            line-height: 1.14;
            letter-spacing: 0.4px;
            color: #1f2a37;
        }

        .hero-text p {
            margin: 16px 0 22px;
            max-width: 640px;
            font-size: 16px;
            line-height: 1.75;
            color: var(--sub);
        }

        .hero-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }

        .hero-actions a {
            text-decoration: none;
            border-radius: var(--radius-pill);
            padding: 12px 24px;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 0.4px;
            transition: all 0.22s ease;
        }

        .hero-actions .primary {
            color: #fff;
            background: linear-gradient(120deg, var(--teal) 0%, #3a86a9 100%);
            box-shadow: 0 12px 22px rgba(45, 108, 139, 0.24);
        }

        .hero-actions .primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 28px rgba(45, 108, 139, 0.28);
        }

        .hero-actions .secondary {
            color: var(--gold-strong);
            border: 1px solid rgba(177, 129, 53, 0.34);
            background: rgba(255, 255, 255, 0.82);
        }

        .hero-actions .secondary:hover {
            transform: translateY(-2px);
            border-color: rgba(177, 129, 53, 0.58);
            background: #fff;
        }

        .hero-tags {
            margin-top: 18px;
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .hero-tags span {
            display: inline-flex;
            align-items: center;
            padding: 6px 12px;
            border-radius: var(--radius-pill);
            font-size: 12px;
            font-weight: 600;
            color: #3f4b5b;
            background: rgba(255, 255, 255, 0.72);
            border: 1px solid rgba(45, 108, 139, 0.14);
        }

        .hero-side {
            position: relative;
            z-index: 1;
            display: grid;
            gap: 12px;
            align-content: start;
        }

        .spot-card,
        .spot-meta {
            border-radius: var(--radius-lg);
            background: rgba(255, 255, 255, 0.86);
            border: 1px solid rgba(255, 255, 255, 0.86);
            box-shadow: 0 12px 24px rgba(16, 26, 40, 0.08);
            padding: 16px 18px;
        }

        .spot-card h3 {
            margin: 0;
            font-size: 14px;
            color: var(--teal);
            letter-spacing: 0.4px;
        }

        .spot-card p {
            margin: 8px 0 0;
            font-size: 13px;
            line-height: 1.7;
            color: var(--sub);
        }

        .spot-meta {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .spot-meta span {
            font-size: 12px;
            color: var(--sub2);
        }

        .spot-meta strong {
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
            font-size: 32px;
            color: var(--gold-strong);
            line-height: 1;
        }

        .headline {
            margin-top: 34px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            animation: fade-up 0.8s 0.15s ease both;
        }

        .headline h2 {
            margin: 0;
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
            font-size: 30px;
            font-weight: 700;
            letter-spacing: 0.3px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .headline h2::before {
            content: "";
            width: 8px;
            height: 30px;
            border-radius: 8px;
            background: linear-gradient(180deg, var(--gold) 0%, #d8b36d 100%);
        }

        .headline a {
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            color: var(--sub);
            padding: 7px 14px;
            border-radius: var(--radius-pill);
            border: 1px solid transparent;
            transition: all 0.2s ease;
        }

        .headline a:hover {
            color: var(--teal);
            border-color: rgba(45, 108, 139, 0.24);
            background: rgba(45, 108, 139, 0.06);
        }

        .tools {
            margin: 16px 0 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            flex-wrap: wrap;
            animation: fade-up 0.8s 0.22s ease both;
        }

        .chips {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            padding: 6px;
            border-radius: var(--radius-pill);
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(31, 42, 55, 0.08);
            box-shadow: 0 8px 20px rgba(20, 30, 44, 0.07);
        }

        .chip {
            border: none;
            border-radius: var(--radius-pill);
            height: 36px;
            padding: 0 18px;
            font-size: 13px;
            font-weight: 700;
            background: transparent;
            color: var(--sub);
            cursor: pointer;
            transition: all 0.18s ease;
        }

        .chip:hover {
            color: var(--teal);
            background: rgba(45, 108, 139, 0.08);
        }

        .chip.active {
            color: #fff;
            background: linear-gradient(120deg, var(--teal) 0%, #3a86a9 100%);
            box-shadow: 0 10px 16px rgba(45, 108, 139, 0.24);
        }

        .tip-count {
            font-size: 13px;
            font-weight: 600;
            color: var(--sub);
            padding: 10px 14px;
            border-radius: var(--radius-pill);
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(31, 42, 55, 0.08);
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 24px;
            perspective: 1400px;
        }

        .card {
            text-decoration: none;
            color: inherit;
            background: var(--panel);
            border: 1px solid rgba(255, 255, 255, 0.84);
            border-radius: var(--radius-lg);
            box-shadow: 0 10px 24px rgba(20, 30, 44, 0.08);
            display: flex;
            flex-direction: column;
            position: relative;
            overflow: hidden;
            transition: transform 0.26s ease, box-shadow 0.26s ease;
            opacity: 0;
            transform: translateY(18px);
            animation: card-rise 0.7s cubic-bezier(0.2, 0.9, 0.2, 1) forwards;
        }

        .card::before {
            content: "";
            position: absolute;
            inset: 0;
            pointer-events: none;
            background: linear-gradient(160deg, rgba(255, 255, 255, 0.45) 0%, rgba(255, 255, 255, 0) 36%);
        }

        .card:hover {
            transform: translateY(-8px);
            box-shadow: var(--shadow-hover);
        }

        .card:nth-child(2n) { animation-delay: 0.04s; }
        .card:nth-child(3n) { animation-delay: 0.08s; }
        .card:nth-child(4n) { animation-delay: 0.12s; }
        .card:nth-child(5n) { animation-delay: 0.16s; }
        .card:nth-child(6n) { animation-delay: 0.2s; }

        .cover-wrapper {
            position: relative;
            width: calc(100% - 16px);
            margin: 8px 8px 0;
            aspect-ratio: 16 / 9;
            border-radius: 14px;
            overflow: hidden;
            background: #eef2f5;
        }

        .cover {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            transition: transform 0.45s ease;
        }

        .card:hover .cover { transform: scale(1.06); }

        .cover-overlay {
            position: absolute;
            left: 8px;
            bottom: 8px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 5px 11px;
            border-radius: var(--radius-pill);
            background: rgba(255, 252, 245, 0.92);
            border: 1px solid rgba(177, 129, 53, 0.2);
            box-shadow: 0 8px 16px rgba(16, 26, 40, 0.12);
            color: #3f4b5b;
            font-size: 11px;
            font-weight: 700;
            backdrop-filter: blur(4px);
        }

        .cover-overlay span {
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .cover-overlay .icon {
            width: 12px;
            height: 12px;
            fill: currentColor;
            opacity: 0.76;
        }

        .info {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            gap: 10px;
            padding: 14px 16px 16px;
        }

        .title {
            margin: 0;
            font-size: 15px;
            font-weight: 700;
            line-height: 1.55;
            color: var(--ink);
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            transition: color 0.2s ease;
        }

        .card:hover .title { color: var(--teal); }

        .meta {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 12px;
            color: var(--sub);
        }

        .empty {
            border-radius: var(--radius-xl);
            padding: 90px 18px;
            text-align: center;
            font-size: 16px;
            color: var(--sub);
            background: rgba(255, 255, 255, 0.88);
            border: 1px dashed rgba(177, 129, 53, 0.3);
            box-shadow: 0 12px 28px rgba(20, 30, 44, 0.08);
        }

        @keyframes fade-slide-down {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes fade-up {
            from { opacity: 0; transform: translateY(14px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes card-rise {
            to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 1200px) {
            .header {
                width: calc(100% - 28px);
                height: auto;
                padding: 14px 16px;
                gap: 14px;
                flex-wrap: wrap;
            }

            .search {
                order: 3;
                width: 100%;
                max-width: none;
            }

            .hero {
                grid-template-columns: 1fr;
                padding: 36px 24px;
            }
        }

        @media (max-width: 760px) {
            .main { width: calc(100% - 24px); margin: 22px auto 60px; }

            .logo { font-size: 26px; }

            .headline h2 { font-size: 24px; }

            .hero-text h1 { font-size: 34px; }

            .hero-actions a {
                width: 100%;
                text-align: center;
                justify-content: center;
            }

            .grid { grid-template-columns: 1fr; }

            .chips {
                width: 100%;
                justify-content: space-between;
            }

            .chip { flex: 1; min-width: 0; }
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
        <a href="${pageContext.request.contextPath}/admin/adminindex">后台</a><% } %>
        <% } else { %>
        <a href="${pageContext.request.contextPath}/user/login">登录</a>
        <a href="${pageContext.request.contextPath}/user/register">注册</a><% } %>
    </nav>
</header>

<main class="main">
    <section class="hero">
        <div class="hero-text">
            <span class="hero-kicker">今天看点什么</span>
            <h1>好内容，慢慢看</h1>
            <p>不想被信息轰炸也没关系，这里给你准备了值得点开的新视频。看到喜欢的就收藏，想分享就投稿。</p>
        </div>
        <div class="hero-side">
            <div class="hero-actions">
                <a class="primary" href="${pageContext.request.contextPath}/video/search">随便逛逛</a>
                <a class="secondary" href="${pageContext.request.contextPath}/video/upload">上传视频</a>
            </div>
            <div class="hero-tags">
                <span>更新快一点</span>
                <span>内容更实在</span>
                <span>看完有收获</span>
            </div>
            <div class="spot-card">
                <h3>小提醒</h3>
                <p>可以先按播放、点赞或收藏排序，通常能更快找到你想看的。</p>
            </div>
            <div class="spot-meta">
                <span>当前推荐数</span>
                <strong><%= recommendedCount %></strong>
            </div>
        </div>
    </section>

    <div class="headline">
        <h2>推荐视频</h2>
        <a href="${pageContext.request.contextPath}/video/search">查看更多 ></a>
    </div>

    <div class="tools">
        <div class="chips" id="sortChips">
            <button class="chip active" type="button" data-sort="default">综合推荐</button>
            <button class="chip" type="button" data-sort="view">最多播放</button>
            <button class="chip" type="button" data-sort="like">最多点赞</button>
            <button class="chip" type="button" data-sort="fav">最多收藏</button>
        </div>
        <div class="tip-count">当前共 <span id="visibleCount"><%= recommendedCount %></span> 条推荐</div>
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
            <div class="cover-wrapper">
                <img class="cover" loading="lazy" decoding="async" src="<%= coverUrl %>"
                     alt="<%= v.getTitle() %>" onerror="this.src='${pageContext.request.contextPath}/static/images/default_cover.png'">
                <div class="cover-overlay">
                    <span><svg class="icon"><path d="M12 9a3 3 0 0 0-3-3 3 3 0 0 0-3 3 3 3 0 0 0 3 3 3 3 0 0 0 3-3m-3 5c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4"/></svg> <%= views %></span>
                    <span><svg class="icon"><path d="M1 21h4V9H1v12zm22-11c0-1.1-.9-2-2-2h-6.31l.95-4.57.03-.32c0-.41-.17-.79-.44-1.06L14.17 1 7.59 7.59C7.22 7.95 7 8.45 7 9v10c0 1.1.9 2 2 2h9c.83 0 1.54-.5 1.84-1.22l3.02-7.05v-.05c.09-.23.14-.47.14-.73v-1.95z"/></svg> <%= likes %></span>
                </div>
            </div>
            <div class="info">
                <div class="title"><%= v.getTitle() %></div>
                <div class="meta">
                    <span>UP主分享</span>
                    <span>⭐ <%= favs %></span>
                </div>
            </div>
        </a><% } %>
    </div>
    <% } else { %>
    <div class="empty">现在还没有推荐视频，稍后再来看看。</div>
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
    
</body>
</html>
