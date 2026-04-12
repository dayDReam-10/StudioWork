<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="com.assessment.www.po.User" %>
<%@ page import="com.assessment.www.po.Report" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    User admin = (User) session.getAttribute("admin");
    if (admin == null || !"admin".equals(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/admin/login");
        return;
    }
    String adminUsername = admin.getUsername() != null ? admin.getUsername() : "管理员";
    List<Video> pendingVideos = (List<Video>) request.getAttribute("pendingVideos");
    List<Report> pendingReports = (List<Report>) request.getAttribute("pendingReports");
    List<Report> processedReports = (List<Report>) request.getAttribute("processedReports");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - LiBiLiBi</title>
    <style>
        :root { --blue:#00aeec; --pink:#fb7299; --line:#e3e5e7; --bg:#f6f7f8; --sub:#61666d; }
        * { box-sizing:border-box; }
        body { margin:0; background:var(--bg); color:#18191c; font-family:"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif; }
        .header {
            height:64px; background:#fff; border-bottom:1px solid var(--line);
            display:flex; align-items:center; justify-content:space-between; padding:0 20px; position:sticky; top:0; z-index:100;
        }
        .brand { color:var(--blue); font-size:22px; font-weight:800; text-decoration:none; }
        .topnav a { color:var(--sub); text-decoration:none; margin-left:12px; font-size:14px; }
        .layout { display:grid; grid-template-columns:240px 1fr; gap:16px; width:min(1380px,100%); margin:16px auto; padding:0 16px; }
        .side { background:#fff; border:1px solid var(--line); border-radius:10px; padding:10px; height:fit-content; }
        .side a { display:block; text-decoration:none; color:#333; padding:10px 12px; border-radius:8px; font-size:14px; margin-bottom:4px; }
        .side a.active,.side a:hover { background:#edf9ff; color:var(--blue); }
        .main { display:flex; flex-direction:column; gap:16px; }
        .panel { background:#fff; border:1px solid var(--line); border-radius:10px; padding:14px; }
        .panel h2 { margin:0 0 12px; font-size:20px; }
        .stats { display:grid; grid-template-columns:repeat(auto-fit,minmax(170px,1fr)); gap:12px; }
        .card { border:1px solid var(--line); border-radius:10px; padding:12px; }
        .card .v { font-size:28px; font-weight:800; color:var(--blue); }
        .card .k { color:#9499a0; font-size:13px; margin-top:4px; }
        .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:10px; }
        .item { border:1px solid var(--line); border-radius:10px; padding:10px; }
        .item .title { font-weight:700; margin-bottom:6px; }
        .meta { color:#666; font-size:13px; line-height:1.5; }
        .actions { margin-top:8px; display:flex; gap:8px; }
        .btn { border:none; border-radius:7px; height:32px; padding:0 10px; font-size:13px; cursor:pointer; color:#fff; }
        .btn.ok { background:#16a34a; }
        .btn.no { background:#ef4444; }
        .empty { color:#9499a0; font-size:14px; padding:8px 0; }
        @media (max-width:980px){ .layout{grid-template-columns:1fr;} }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<header class="header">
    <a class="brand" href="${pageContext.request.contextPath}/admin/adminindex">LiBiLiBi Admin</a>
    <nav class="topnav">
        <span>Hi, <%= adminUsername %></span>
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/user/logout">退出</a>
    </nav>
</header>

<div class="layout">
    <aside class="side">
        <a class="active" href="${pageContext.request.contextPath}/admin/adminindex">数据概览</a>
        <a href="${pageContext.request.contextPath}/admin/users">用户管理</a>
        <a href="${pageContext.request.contextPath}/admin/videos">视频管理</a>
        <a href="${pageContext.request.contextPath}/admin/pending">待审核视频</a>
        <a href="${pageContext.request.contextPath}/admin/banned">被封用户</a>
        <a href="${pageContext.request.contextPath}/admin/reports">举报管理</a>
    </aside>

    <main class="main">
        <section class="panel">
            <h2>平台数据</h2>
            <div class="stats">
                <div class="card"><div class="v">${totalUsers}</div><div class="k">用户总数</div></div>
                <div class="card"><div class="v">${totalVideos}</div><div class="k">视频总数</div></div>
                <div class="card"><div class="v">${approvedVideos}</div><div class="k">已通过审核</div></div>
                <div class="card"><div class="v">${pendingVideos != null ? pendingVideos.size() : 0}</div><div class="k">待审核视频</div></div>
                <div class="card"><div class="v">${totalViews}</div><div class="k">总播放</div></div>
                <div class="card"><div class="v">${totalLikes}</div><div class="k">总点赞</div></div>
                <div class="card"><div class="v">${totalFavorites}</div><div class="k">总收藏</div></div>
                <div class="card"><div class="v">${totalCoins}</div><div class="k">总投币</div></div>
                <div class="card"><div class="v">${totalComments}</div><div class="k">总评论</div></div>
                <div class="card"><div class="v">${pendingReportCount}</div><div class="k">待处理举报</div></div>
            </div>
        </section>

        <section class="panel">
            <h2>快速审核（视频）</h2>
            <% if (pendingVideos != null && !pendingVideos.isEmpty()) { %>
            <div class="grid">
                <% for (Video v : pendingVideos) { %>
                <div class="item">
                    <div class="title"><%= v.getTitle() != null ? v.getTitle() : "Untitled" %></div>
                    <div class="meta">ID: <%= v.getId() %><br>作者ID: <%= v.getAuthorId() != null ? v.getAuthorId() : 0 %><br>上传: <%= v.getTimeCreate() != null ? v.getTimeCreate().toString() : "Unknown" %></div>
                    <div class="actions">
                        <button class="btn ok" onclick="approveVideo(<%= v.getId() %>)">通过</button>
                        <button class="btn no" onclick="rejectVideo(<%= v.getId() %>)">驳回</button>
                    </div>
                </div>
                <% } %>
            </div>
            <% } else { %>
            <div class="empty">暂无待审核视频</div>
            <% } %>
        </section>

        <section class="panel">
            <h2>举报概览</h2>
            <div class="stats" style="margin-bottom:10px;">
                <div class="card"><div class="v">${pendingReports != null ? pendingReports.size() : 0}</div><div class="k">本页待处理举报</div></div>
                <div class="card"><div class="v">${processedReports != null ? processedReports.size() : 0}</div><div class="k">本页已处理举报</div></div>
                <div class="card"><div class="v">${totalReports}</div><div class="k">累计举报</div></div>
            </div>
            <a href="${pageContext.request.contextPath}/admin/reports" style="color:#00aeec;text-decoration:none;font-size:14px;">进入举报管理</a>
        </section>
    </main>
</div>

<script>
    function approveVideo(videoId) {
        if (!confirm("确定通过该视频？")) return;
        fetch("${pageContext.request.contextPath}/admin/approve?id=" + videoId)
            .then(function(r){ return r.text(); })
            .then(function(t){
                if (t === "success") location.reload();
                else alert("操作失败: " + t);
            })
            .catch(function(){ alert("请求失败"); });
    }
    function rejectVideo(videoId) {
        if (!confirm("确定驳回该视频？")) return;
        fetch("${pageContext.request.contextPath}/admin/reject?id=" + videoId)
            .then(function(r){ return r.text(); })
            .then(function(t){
                if (t === "success") location.reload();
                else alert("操作失败: " + t);
            })
            .catch(function(){ alert("请求失败"); });
    }
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
