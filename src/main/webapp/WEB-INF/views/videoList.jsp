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
            --brand-blue: #00aeec;
            --brand-pink: #fb7299;
            --text: #18191c;
            --sub: #61666d;
            --sub2: #9499a0;
            --line: #e3e5e7;
            --bg: #f6f7f8;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            color: var(--text);
            background: var(--bg);
        }
        .header {
            height: 68px;
            background: #fff;
            border-bottom: 1px solid var(--line);
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 0 24px;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .logo {
            color: var(--brand-blue);
            text-decoration: none;
            font-size: 24px;
            font-weight: 800;
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
        }
        .search button {
            width: 90px;
            border: 1px solid var(--line);
            border-radius: 0 20px 20px 0;
            background: #fff;
            cursor: pointer;
        }
        .nav {
            margin-left: auto;
            display: flex;
            gap: 8px;
            align-items: center;
        }
        .nav a {
            text-decoration: none;
            color: var(--sub);
            font-size: 14px;
            padding: 7px 10px;
            border-radius: 7px;
        }
        .nav a:hover { background: #edf9ff; color: var(--brand-blue); }
        .nav .upload {
            background: var(--brand-pink);
            color: #fff;
            font-weight: 700;
        }
        .main {
            width: min(1400px, 100%);
            margin: 20px auto 40px;
            padding: 0 24px;
        }
        .result-tip {
            margin: 0 0 16px;
            color: var(--sub2);
            font-size: 14px;
        }
        .tools {
            margin: -4px 0 14px;
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
            color: var(--sub2);
            font-size: 13px;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
        }
        .card {
            text-decoration: none;
            color: inherit;
            background: #fff;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 22px rgba(0, 0, 0, 0.1);
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
            margin-bottom: 8px;
            overflow: hidden;
        }
        .meta {
            color: var(--sub2);
            font-size: 13px;
            display: flex;
            justify-content: space-between;
            gap: 10px;
        }
        .pager {
            margin-top: 26px;
            display: flex;
            gap: 8px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .pager a, .pager span {
            min-width: 34px;
            height: 34px;
            padding: 0 10px;
            border: 1px solid var(--line);
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            color: var(--sub);
            background: #fff;
            font-size: 14px;
        }
        .pager .active {
            background: var(--brand-blue);
            color: #fff;
            border-color: var(--brand-blue);
        }
        .empty {
            text-align: center;
            background: #fff;
            border: 1px dashed var(--line);
            border-radius: 10px;
            padding: 54px 20px;
            color: var(--sub2);
        }
        @media (max-width: 820px) {
            .header { height: auto; padding: 12px; flex-wrap: wrap; }
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
