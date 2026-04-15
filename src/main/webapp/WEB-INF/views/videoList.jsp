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
    <title>视频列表 - LiBiLiBi</title>
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
            --radius-xl: 24px;
            --radius-lg: 18px;
            --radius-md: 12px;
            --radius-pill: 999px;
            --shadow-soft: 0 10px 30px rgba(24, 36, 56, 0.08);
            --shadow-panel: 0 12px 28px rgba(16, 26, 40, 0.1);
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
            gap: 22px;
            position: sticky;
            top: 12px;
            z-index: 100;
            border-radius: 24px;
            background: var(--paper);
            border: 1px solid rgba(255, 255, 255, 0.72);
            backdrop-filter: blur(14px) saturate(130%);
            -webkit-backdrop-filter: blur(14px) saturate(130%);
            box-shadow: var(--shadow-soft);
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
            padding: 0 18px;
            background: transparent;
            font-size: 14px;
            color: var(--ink);
        }

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
            gap: 8px;
            align-items: center;
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
            padding: 9px 18px;
        }

        .main {
            width: min(1480px, calc(100% - 56px));
            margin: 30px auto 50px;
        }

        .result-tip {
            margin: 0 0 16px;
            color: var(--sub2);
            font-size: 14px;
            font-weight: 600;
        }

        .tools {
            margin: 0 0 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            flex-wrap: wrap;
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
            height: 36px;
            border: none;
            border-radius: var(--radius-pill);
            background: transparent;
            color: var(--sub);
            padding: 0 16px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 700;
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
            color: var(--sub);
            font-size: 13px;
            font-weight: 600;
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(31, 42, 55, 0.08);
            border-radius: var(--radius-pill);
            padding: 10px 14px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 24px;
        }

        .card {
            text-decoration: none;
            color: inherit;
            background: var(--panel);
            border-radius: var(--radius-lg);
            border: 1px solid rgba(255, 255, 255, 0.84);
            box-shadow: var(--shadow-panel);
            overflow: hidden;
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
            display: block;
            background: #eef1f4;
        }

        .info { padding: 12px 14px 16px; }

        .title {
            font-size: 15px;
            font-weight: 700;
            line-height: 1.5;
            min-height: 44px;
            margin-bottom: 10px;
            color: var(--ink);
            display: -webkit-box;
            -webkit-box-orient: vertical;
            -webkit-line-clamp: 2;
            overflow: hidden;
        }

        .meta {
            color: var(--sub);
            font-size: 12px;
            display: flex;
            justify-content: space-between;
            gap: 10px;
        }

        .meta span {
            background: rgba(45, 108, 139, 0.08);
            border-radius: 999px;
            padding: 4px 8px;
        }

        .pager {
            margin-top: 28px;
            display: flex;
            gap: 8px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .pager a,
        .pager span {
            min-width: 36px;
            height: 36px;
            padding: 0 11px;
            border: 1px solid rgba(31, 42, 55, 0.12);
            border-radius: 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            color: var(--sub);
            background: rgba(255, 255, 255, 0.9);
            font-size: 14px;
        }

        .pager a:hover {
            border-color: rgba(45, 108, 139, 0.36);
            color: var(--teal);
        }

        .pager .active {
            background: linear-gradient(120deg, var(--teal) 0%, #3a86a9 100%);
            color: #fff;
            border-color: transparent;
        }

        .empty {
            text-align: center;
            background: rgba(255, 255, 255, 0.9);
            border: 1px dashed rgba(177, 129, 53, 0.3);
            border-radius: var(--radius-lg);
            padding: 58px 20px;
            color: var(--sub2);
            box-shadow: var(--shadow-soft);
        }

        @media (max-width: 1180px) {
            .header {
                width: calc(100% - 28px);
                height: auto;
                padding: 14px 16px;
                flex-wrap: wrap;
                gap: 12px;
            }

            .search {
                order: 3;
                width: 100%;
                max-width: none;
            }

            .main {
                width: calc(100% - 24px);
                margin: 20px auto 38px;
            }
        }

        @media (max-width: 760px) {
            .grid { grid-template-columns: 1fr; }
            .chips { width: 100%; }
            .chip { flex: 1; }
        }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<%
    User user = (User) session.getAttribute("user");
    List<Video> videos = (List<Video>) request.getAttribute("videos");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    String keyword = (String) request.getAttribute("keyword");
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
    if (keyword == null) keyword = "";
%>

<header class="header">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>

    <form class="search" action="${pageContext.request.contextPath}/video/search" method="get">
        <input type="text" name="keyword" value="<%= keyword %>" placeholder="搜索视频、UP主...">
        <button type="submit">搜索</button>
    </form>

    <nav class="nav">
        <a href="${pageContext.request.contextPath}/">首页</a>
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
    <p class="result-tip">
        <% if (keyword.trim().isEmpty()) { %>
        全部视频
        <% } else { %>
        关键词“<%= keyword %>”的搜索结果
        <% } %>
    </p>

    <div class="tools">
        <div class="chips" id="sortChips">
            <button class="chip active" type="button" data-sort="default">默认排序</button>
            <button class="chip" type="button" data-sort="view">按播放</button>
            <button class="chip" type="button" data-sort="like">按点赞</button>
            <button class="chip" type="button" data-sort="fav">按收藏</button>
        </div>
        <div class="tip-count">当前页 <span id="visibleCount"><%= (videos != null) ? videos.size() : 0 %></span> 条结果</div>
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

    <% if (totalPages > 1) { %>
    <div class="pager">
        <% if (currentPage > 1) { %>
        <a href="${pageContext.request.contextPath}/video/search?keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&page=<%= currentPage - 1 %>">上一页</a>
        <% } %>

        <% for (int i = 1; i <= totalPages; i++) {
               if (i == currentPage) { %>
        <span class="active"><%= i %></span>
        <%     } else { %>
        <a href="${pageContext.request.contextPath}/video/search?keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&page=<%= i %>"><%= i %></a>
        <%     }
           } %>

        <% if (currentPage < totalPages) { %>
        <a href="${pageContext.request.contextPath}/video/search?keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&page=<%= currentPage + 1 %>">下一页</a>
        <% } %>
    </div>
    <% } %>

    <% } else { %>
    <div class="empty">没有找到相关视频。</div>
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
