<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.Report" %>
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
    List<Report> reports = (List<Report>) request.getAttribute("reports");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalReports = (Integer) request.getAttribute("totalReports");
    String search = (String) request.getAttribute("search");

    if (currentPage == null || currentPage < 1) currentPage = 1;
    if (totalReports == null || totalReports < 0) totalReports = 0;
    int totalPages = (int) Math.ceil(totalReports / 10.0);
    if (totalPages < 1) totalPages = 1;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>举报管理 - LiBiLiBi Admin</title>
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
        .toolbar { display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; gap:10px; flex-wrap:wrap; }
        .toolbar h2 { margin:0; font-size:20px; }
        .search { display:flex; gap:8px; }
        .search input { height:34px; border:1px solid var(--line); border-radius:7px; padding:0 10px; min-width:240px; }
        .search button { border:none; border-radius:7px; height:34px; padding:0 12px; color:#fff; background:var(--blue); cursor:pointer; }
        table { width:100%; border-collapse:collapse; font-size:13px; }
        th,td { border-bottom:1px solid #f1f2f3; padding:10px 8px; text-align:left; vertical-align:top; }
        th { background:#fafbfc; color:#61666d; }
        .video-link { color:#0077a5; text-decoration:none; }
        .status { display:inline-block; border-radius:999px; padding:2px 8px; font-size:12px; }
        .s0 { background:#fff8e8; color:#a66900; }
        .s1 { background:#ecfbff; color:#0077a5; }
        .s2 { background:#fff2f4; color:#d63b6f; }
        .ops { display:flex; gap:6px; }
        .btn { border:none; border-radius:6px; height:28px; padding:0 8px; font-size:12px; cursor:pointer; color:#fff; }
        .ok { background:#16a34a; }
        .no { background:#ef4444; }
        .pager { margin-top:12px; display:flex; gap:6px; justify-content:center; flex-wrap:wrap; }
        .pager a,.pager span { min-width:30px; height:30px; border:1px solid var(--line); border-radius:7px; display:inline-flex; align-items:center; justify-content:center; text-decoration:none; color:#61666d; background:#fff; font-size:12px; padding:0 8px; }
        .pager .active { background:var(--blue); color:#fff; border-color:var(--blue); }
        .empty { color:#9499a0; text-align:center; padding:30px 0; }
        @media (max-width:980px){ .layout{grid-template-columns:1fr;} .search input{min-width:180px;} }
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
        <a href="${pageContext.request.contextPath}/admin/videos">视频管理</a>
        <a href="${pageContext.request.contextPath}/admin/pending">待审核视频</a>
        <a href="${pageContext.request.contextPath}/admin/banned">被封用户</a>
        <a class="active" href="${pageContext.request.contextPath}/admin/reports">举报管理</a>
    </aside>

    <main class="panel">
        <div class="toolbar">
            <h2>举报管理</h2>
            <form class="search" method="get" action="${pageContext.request.contextPath}/admin/reports">
                <input type="text" name="search" placeholder="搜索视频标题/举报人/举报详情" value="<%= search != null ? search : "" %>">
                <button type="submit">搜索</button>
            </form>
        </div>

        <table>
            <thead>
            <tr>
                <th>ID</th><th>视频</th><th>举报人</th><th>举报说明</th><th>状态</th><th>时间</th><th>操作</th>
            </tr>
            </thead>
            <tbody>
            <% if (reports != null && !reports.isEmpty()) {
                   for (Report r : reports) {
                       Integer st = r.getStatus() != null ? r.getStatus() : 0;
                       String stText = st == 1 ? "已处理" : (st == 2 ? "已驳回" : "待处理");
                       Video v = r.getVideo();
                       User rp = r.getReporter();
            %>
            <tr>
                <td><%= r.getId() %></td>
                <td>
                    <% if (v != null) { %>
                    <a class="video-link" target="_blank" href="${pageContext.request.contextPath}/video/detail?id=<%= v.getId() %>"><%= v.getTitle() != null ? v.getTitle() : ("视频#" + v.getId()) %></a>
                    <% } else { %>
                    视频#<%= r.getVideoId() != null ? r.getVideoId() : 0 %>
                    <% } %>
                </td>
                <td><%= (rp != null && rp.getUsername() != null) ? rp.getUsername() : ("用户#" + (r.getUserId() != null ? r.getUserId() : 0)) %></td>
                <td><%= r.getReasonDetail() != null && !r.getReasonDetail().isEmpty() ? r.getReasonDetail() : "无说明" %></td>
                <td><span class="status s<%= st %>"><%= stText %></span></td>
                <td><%= r.getTimeCreate() != null ? r.getTimeCreate().toString() : "-" %></td>
                <td>
                    <% if (st == 0) { %>
                    <div class="ops">
                        <button class="btn ok" onclick="processReport(<%= r.getId() %>, 1)">标记处理</button>
                        <button class="btn no" onclick="processReport(<%= r.getId() %>, 2)">驳回举报</button>
                    </div>
                    <% } else { %>
                    <span style="color:#9499a0;">已完成</span>
                    <% } %>
                </td>
            </tr>
            <%   }
               } else { %>
            <tr><td class="empty" colspan="7">暂无举报记录</td></tr>
            <% } %>
            </tbody>
        </table>

        <% if (totalPages > 1) { %>
        <div class="pager">
            <% String searchSuffix = (search != null && !search.trim().isEmpty()) ? ("&search=" + search) : ""; %>
            <% if (currentPage > 1) { %>
            <a href="${pageContext.request.contextPath}/admin/reports?page=<%= currentPage - 1 %><%= searchSuffix %>">上一页</a>
            <% } %>
            <% for (int i = 1; i <= totalPages; i++) {
                   if (i == currentPage) { %>
            <span class="active"><%= i %></span>
            <%     } else { %>
            <a href="${pageContext.request.contextPath}/admin/reports?page=<%= i %><%= searchSuffix %>"><%= i %></a>
            <%     }
               } %>
            <% if (currentPage < totalPages) { %>
            <a href="${pageContext.request.contextPath}/admin/reports?page=<%= currentPage + 1 %><%= searchSuffix %>">下一页</a>
            <% } %>
        </div>
        <% } %>
    </main>
</div>

<script>
    function processReport(reportId, action) {
        var msg = action === 1 ? "确定标记为已处理？" : "确定驳回这条举报？";
        if (!confirm(msg)) return;
        fetch("${pageContext.request.contextPath}/admin/processReport", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "reportId=" + encodeURIComponent(reportId) + "&action=" + encodeURIComponent(action)
        }).then(function (r) { return r.text(); })
          .then(function (text) {
              try {
                  var data = JSON.parse(text);
                  if (data.success) location.reload();
                  else alert("操作失败");
              } catch (e) {
                  alert("响应异常: " + text);
              }
          }).catch(function () { alert("请求失败"); });
    }
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
