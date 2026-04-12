<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.User" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    User admin = (User) session.getAttribute("admin");
    if (admin == null || !"admin".equals(admin.getRole())) {
        response.sendRedirect(request.getContextPath() + "/admin/login");
        return;
    }
    List<User> users = (List<User>) request.getAttribute("users");
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
    <title>用户管理 - LiBiLiBi Admin</title>
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
        .btn { border:none; border-radius:8px; height:34px; padding:0 12px; cursor:pointer; color:#fff; background:#16a34a; font-size:13px; }
        table { width:100%; border-collapse:collapse; font-size:13px; }
        th,td { border-bottom:1px solid #f1f2f3; padding:10px 8px; text-align:left; vertical-align:middle; }
        th { background:#fafbfc; color:#61666d; }
        .role { padding:3px 8px; border-radius:999px; background:#eef1f4; font-size:12px; }
        .st-ok { color:#16a34a; font-weight:700; }
        .st-ban { color:#ef4444; font-weight:700; }
        .row-btn { border:none; border-radius:6px; height:28px; padding:0 10px; cursor:pointer; color:#fff; font-size:12px; }
        .ban { background:#f59e0b; }
        .unban { background:#16a34a; }
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
        <a class="active" href="${pageContext.request.contextPath}/admin/users">用户管理</a>
        <a href="${pageContext.request.contextPath}/admin/videos">视频管理</a>
        <a href="${pageContext.request.contextPath}/admin/pending">待审核视频</a>
        <a href="${pageContext.request.contextPath}/admin/banned">被封用户</a>
        <a href="${pageContext.request.contextPath}/admin/reports">举报管理</a>
    </aside>

    <main class="panel">
        <div class="toolbar">
            <h2>用户管理</h2>
            <button class="btn" onclick="exportUsers()">导出 CSV</button>
        </div>

        <table>
            <thead>
            <tr>
                <th>ID</th><th>用户名</th><th>性别</th><th>硬币</th><th>关注</th><th>粉丝</th><th>获赞</th><th>收藏</th><th>角色</th><th>状态</th><th>操作</th>
            </tr>
            </thead>
            <tbody>
            <% if (users != null && !users.isEmpty()) {
                   for (User u : users) {
                       int gender = u.getGender() != null ? u.getGender() : 0;
                       int status = u.getStatus() != null ? u.getStatus() : 0;
            %>
            <tr>
                <td><%= u.getId() %></td>
                <td><%= u.getUsername() != null ? u.getUsername() : "-" %></td>
                <td><%= gender == 1 ? "男" : (gender == 2 ? "女" : "保密") %></td>
                <td><%= u.getCoinCount() != null ? u.getCoinCount() : 0 %></td>
                <td><%= u.getFollowingCount() != null ? u.getFollowingCount() : 0 %></td>
                <td><%= u.getFollowerCount() != null ? u.getFollowerCount() : 0 %></td>
                <td><%= u.getTotalLikeCount() != null ? u.getTotalLikeCount() : 0 %></td>
                <td><%= u.getTotalFavCount() != null ? u.getTotalFavCount() : 0 %></td>
                <td><span class="role"><%= u.getRole() != null ? u.getRole() : "user" %></span></td>
                <td><span class="<%= status == 1 ? "st-ok" : "st-ban" %>"><%= status == 1 ? "正常" : "封禁" %></span></td>
                <td>
                    <% if (status == 1) { %>
                    <button class="row-btn ban" onclick="toggleUserStatus(<%= u.getId() %>)">封禁</button>
                    <% } else { %>
                    <button class="row-btn unban" onclick="toggleUserStatus(<%= u.getId() %>)">解封</button>
                    <% } %>
                </td>
            </tr>
            <%   }
               } else { %>
            <tr><td colspan="11" style="text-align:center;color:#9499a0;padding:30px 0;">暂无用户</td></tr>
            <% } %>
            </tbody>
        </table>

        <% if (totalPages > 1) { %>
        <div class="pager">
            <% if (currentPage > 1) { %>
            <a href="${pageContext.request.contextPath}/admin/users?page=<%= currentPage - 1 %>">上一页</a>
            <% } %>
            <% for (int i = 1; i <= totalPages; i++) {
                   if (i == currentPage) { %>
            <span class="active"><%= i %></span>
            <%     } else { %>
            <a href="${pageContext.request.contextPath}/admin/users?page=<%= i %>"><%= i %></a>
            <%     }
               } %>
            <% if (currentPage < totalPages) { %>
            <a href="${pageContext.request.contextPath}/admin/users?page=<%= currentPage + 1 %>">下一页</a>
            <% } %>
        </div>
        <% } %>
    </main>
</div>

<script>
    function toggleUserStatus(userId) {
        if (!confirm("确定切换该用户状态？")) return;
        fetch("${pageContext.request.contextPath}/admin/toggleUserStatus", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "userId=" + encodeURIComponent(userId)
        }).then(function (r) { return r.text(); })
          .then(function (t) {
              if (t === "success") location.reload();
              else alert("操作失败: " + t);
          }).catch(function () { alert("请求失败"); });
    }

    function exportUsers() {
        window.location.href = "${pageContext.request.contextPath}/admin/exportUser";
    }
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
