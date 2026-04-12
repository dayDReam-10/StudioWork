<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="com.assessment.www.po.User" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    User admin = (User) session.getAttribute("admin");
    if (admin == null || !"admin".equals(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/admin/login");
        return;
    }
    List<Video> videos = (List<Video>) request.getAttribute("videos");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>视频管理 - LiBiLiBi Admin</title>
    <style>
        :root { --blue:#00aeec; --line:#e3e5e7; --bg:#f6f7f8; --sub:#61666d; }
        * { box-sizing:border-box; }
        body { margin:0; background:var(--bg); color:#18191c; font-family:"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif; }
        .header { height:64px; background:#fff; border-bottom:1px solid var(--line); display:flex; align-items:center; justify-content:space-between; padding:0 20px; }
        .brand { color:var(--blue); font-size:22px; font-weight:800; text-decoration:none; }
        .topnav a { color:var(--sub); text-decoration:none; margin-left:12px; font-size:14px; }
        .layout { display:grid; grid-template-columns:240px 1fr; gap:16px; width:min(1380px,100%); margin:16px auto; padding:0 16px; }
        .side { background:#fff; border:1px solid var(--line); border-radius:10px; padding:10px; height:fit-content; }
        .side a { display:block; text-decoration:none; color:#333; padding:10px 12px; border-radius:8px; font-size:14px; margin-bottom:4px; }
        .side a.active,.side a:hover { background:#edf9ff; color:var(--blue); }
        .panel { background:#fff; border:1px solid var(--line); border-radius:10px; padding:14px; }
        .toolbar { display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; }
        .toolbar h2 { margin:0; font-size:20px; }
        .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:10px; }
        .item { border:1px solid var(--line); border-radius:10px; overflow:hidden; background:#fff; }
        .cover { width:100%; aspect-ratio:16/9; object-fit:cover; background:#eef1f4; display:block; }
        .body { padding:10px; }
        .title { font-weight:700; margin-bottom:6px; min-height:38px; overflow:hidden; }
        .meta { color:#666; font-size:13px; line-height:1.5; }
        .st { display:inline-block; margin-top:6px; border-radius:999px; padding:3px 8px; font-size:12px; background:#eef1f4; }
        .st0 { background:#fff8e8; color:#a66900; }
        .st1 { background:#ecfbff; color:#0077a5; }
        .st2 { background:#fff2f4; color:#d63b6f; }
        .actions { margin-top:8px; display:flex; gap:8px; }
        .btn { border:none; border-radius:7px; height:30px; padding:0 10px; font-size:12px; cursor:pointer; color:#fff; }
        .view { background:#3b82f6; }
        .del { background:#ef4444; }
        .pager { margin-top:12px; display:flex; gap:6px; justify-content:center; flex-wrap:wrap; }
        .pager a,.pager span { min-width:30px; height:30px; border:1px solid var(--line); border-radius:7px; display:inline-flex; align-items:center; justify-content:center; text-decoration:none; color:#61666d; background:#fff; font-size:12px; padding:0 8px; }
        .pager .active { background:var(--blue); color:#fff; border-color:var(--blue); }
        @media (max-width:980px){ .layout{grid-template-columns:1fr;} }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<header class="header">
    <a class="brand" href="${pageContext.request.contextPath}/admin/adminindex">LiBiLiBi Admin</a>
    <nav class="topnav">
        <span>Hi, ${sessionScope.admin.username}</span>
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/user/logout">退出</a>
    </nav>
</header>

<div class="layout">
    <aside class="side">
        <a href="${pageContext.request.contextPath}/admin/adminindex">数据概览</a>
        <a href="${pageContext.request.contextPath}/admin/users">用户管理</a>
        <a class="active" href="${pageContext.request.contextPath}/admin/videos">视频管理</a>
        <a href="${pageContext.request.contextPath}/admin/pending">待审核视频</a>
        <a href="${pageContext.request.contextPath}/admin/banned">被封用户</a>
        <a href="${pageContext.request.contextPath}/admin/reports">举报管理</a>
    </aside>

    <main class="panel">
        <div class="toolbar"><h2>视频管理</h2></div>

        <% if (videos != null && !videos.isEmpty()) { %>
        <div class="grid">
            <% for (Video v : videos) {
                   int st = v.getStatus() != null ? v.getStatus() : 0;
                   String stText = st == 1 ? "已通过" : (st == 2 ? "已驳回" : "待审核");
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
            <div class="item">
                <img class="cover" src="<%= coverUrl %>"
                     alt="cover" onerror="this.src='${pageContext.request.contextPath}/static/images/default_cover.png'">
                <div class="body">
                    <div class="title"><%= v.getTitle() != null ? v.getTitle() : "Untitled" %></div>
                    <div class="meta">ID: <%= v.getId() %><br>作者ID: <%= v.getAuthorId() != null ? v.getAuthorId() : 0 %><br>播放: <%= v.getViewCount() != null ? v.getViewCount() : 0 %> · 点赞: <%= v.getLikeCount() != null ? v.getLikeCount() : 0 %> · 收藏: <%= v.getFavCount() != null ? v.getFavCount() : 0 %></div>
                    <span class="st st<%= st %>"><%= stText %></span>
                    <div class="actions">
                        <button class="btn view" onclick="viewVideo(<%= v.getId() %>)">查看</button>
                        <button class="btn del" onclick="deleteVideo(<%= v.getId() %>)">删除</button>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div style="color:#9499a0;">暂无视频</div>
        <% } %>

        <% if (totalPages > 1) { %>
        <div class="pager">
            <% if (currentPage > 1) { %>
            <a href="${pageContext.request.contextPath}/admin/videos?page=<%= currentPage - 1 %>">上一页</a>
            <% } %>
            <% for (int i = 1; i <= totalPages; i++) {
                   if (i == currentPage) { %>
            <span class="active"><%= i %></span>
            <%     } else { %>
            <a href="${pageContext.request.contextPath}/admin/videos?page=<%= i %>"><%= i %></a>
            <%     }
               } %>
            <% if (currentPage < totalPages) { %>
            <a href="${pageContext.request.contextPath}/admin/videos?page=<%= currentPage + 1 %>">下一页</a>
            <% } %>
        </div>
        <% } %>
    </main>
</div>

<script>
    function viewVideo(videoId) {
        window.open("${pageContext.request.contextPath}/video/detail?id=" + videoId, "_blank");
    }

    function deleteVideo(videoId) {
        if (!confirm("确定删除该视频？")) return;
        fetch("${pageContext.request.contextPath}/admin/deleteVideo", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "id=" + encodeURIComponent(videoId)
        }).then(function (r) { return r.text(); })
          .then(function (t) {
              if (t === "success") location.reload();
              else alert("删除失败: " + t);
          }).catch(function () { alert("请求失败"); });
    }
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
