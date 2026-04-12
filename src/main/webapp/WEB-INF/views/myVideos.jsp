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
        :root { --blue:#00aeec; --pink:#fb7299; --line:#e3e5e7; --bg:#f6f7f8; --sub:#61666d; }
        * { box-sizing: border-box; }
        body { margin:0; font-family:"Segoe UI",sans-serif; color:#18191c; background:var(--bg); }
        .header { height:68px; background:#fff; border-bottom:1px solid var(--line); display:flex; align-items:center; justify-content:space-between; padding:0 24px; }
        .logo { color:var(--blue); text-decoration:none; font-size:24px; font-weight:800; }
        .nav a { text-decoration:none; color:var(--sub); margin-left:12px; font-size:14px; }
        .nav .upload { background:var(--pink); color:#fff; padding:8px 12px; border-radius:8px; font-weight:700; }
        .main { width:min(1200px,100%); margin:22px auto; padding:0 20px; }
        .top { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; }
        .top h1 { margin:0; font-size:24px; }
        .msg { border-radius:8px; padding:10px 12px; margin-bottom:12px; font-size:14px; }
        .msg.error { background:#fff2f4; border:1px solid #ffd7e2; color:#d63b6f; }
        .msg.success { background:#ecfbff; border:1px solid #bcefff; color:#0077a5; }
        .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:18px; }
        .card { background:#fff; border-radius:10px; overflow:hidden; box-shadow:0 4px 14px rgba(0,0,0,.05); }
        .cover { width:100%; aspect-ratio:16/9; object-fit:cover; background:#eef1f4; display:block; cursor:pointer; }
        .info { padding:10px 12px 12px; }
        .title { font-size:15px; margin-bottom:8px; min-height:40px; overflow:hidden; }
        .meta { color:#9499a0; font-size:13px; margin-bottom:10px; }
        .status { display:inline-block; font-size:12px; border-radius:999px; padding:4px 8px; margin-bottom:10px; }
        .status.pending { background:#fff8e8; color:#a66900; }
        .status.ok { background:#ecfbff; color:#0077a5; }
        .status.bad { background:#fff2f4; color:#d63b6f; }
        .actions { display:flex; gap:8px; }
        .btn { flex:1; border:none; border-radius:8px; height:34px; cursor:pointer; color:#fff; font-size:13px; }
        .btn.play { background:var(--blue); }
        .btn.del { background:#ff6b6b; }
        .empty { text-align:center; background:#fff; border:1px dashed var(--line); border-radius:10px; padding:48px 20px; color:#9499a0; }
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
        <a href="${pageContext.request.contextPath}/video/upload" style="color:#00aeec;text-decoration:none;">立即上传</a>
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
