<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.History" %>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>观看历史 - LiBiLiBi</title>
    <style>
        :root { --blue:#00aeec; --line:#e3e5e7; --bg:#f6f7f8; --sub:#61666d; }
        * { box-sizing: border-box; }
        body { margin:0; font-family:"Segoe UI",sans-serif; background:var(--bg); color:#18191c; }
        .header { height:68px; background:#fff; border-bottom:1px solid var(--line); display:flex; align-items:center; justify-content:space-between; padding:0 24px; }
        .logo { color:var(--blue); text-decoration:none; font-size:24px; font-weight:800; }
        .nav a { text-decoration:none; color:var(--sub); margin-left:12px; font-size:14px; }
        .main { width:min(1100px,100%); margin:20px auto; padding:0 20px; }
        h1 { margin:0 0 14px; font-size:24px; }
        .list { display:flex; flex-direction:column; gap:12px; }
        .item { background:#fff; border-radius:10px; box-shadow:0 4px 14px rgba(0,0,0,.05); display:grid; grid-template-columns:220px 1fr; gap:14px; padding:12px; }
        .cover { width:100%; aspect-ratio:16/9; object-fit:cover; border-radius:8px; background:#eef1f4; cursor:pointer; }
        .title { margin:2px 0 8px; font-size:18px; cursor:pointer; }
        .title:hover { color:var(--blue); }
        .meta { color:#9499a0; font-size:13px; margin-bottom:6px; }
        .time { color:#61666d; font-size:13px; }
        .empty { text-align:center; background:#fff; border:1px dashed var(--line); border-radius:10px; padding:48px 20px; color:#9499a0; }
        @media (max-width:820px) { .main{padding:0 12px;} .header{padding:0 12px;} .item{grid-template-columns:1fr;} }
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
        <a href="${pageContext.request.contextPath}/video/myvideos">我的视频</a>
    </nav>
</header>

<main class="main">
    <h1>观看历史</h1>
    <%
        List<History> historyList = (List<History>) request.getAttribute("historyList");
        if (historyList != null && !historyList.isEmpty()) {
    %>
    <div class="list">
        <% for (History h : historyList) {
               Video v = h.getVideo();
               if (v == null) continue;
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
        <article class="item">
            <img class="cover" src="<%= coverUrl %>"
                 alt="cover"
                 onerror="this.src='${pageContext.request.contextPath}/static/images/default_cover.png'"
                 data-id="<%= v.getId() %>">
            <div>
                <h3 class="title" data-id="<%= v.getId() %>"><%= v.getTitle() %></h3>
                <div class="meta">播放 <%= v.getViewCount() != null ? v.getViewCount() : 0 %> | 点赞 <%= v.getLikeCount() != null ? v.getLikeCount() : 0 %> | 收藏 <%= v.getFavCount() != null ? v.getFavCount() : 0 %></div>
                <div class="time">观看时间：<%= h.getTimeView() != null ? h.getTimeView().toString() : "未知" %></div>
            </div>
        </article>
        <% } %>
    </div>
    <% } else { %>
    <div class="empty">暂无观看记录。</div>
    <% } %>
</main>

<script>
    function goDetail(id) {
        window.location.href = "${pageContext.request.contextPath}/video/detail?id=" + id;
    }

    document.querySelectorAll('.cover[data-id], .title[data-id]').forEach(function (node) {
        node.addEventListener('click', function () {
            goDetail(this.getAttribute('data-id'));
        });
    });
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
