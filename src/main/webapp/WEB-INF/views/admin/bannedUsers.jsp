<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.User" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    User admin = (User) session.getAttribute("admin");
    if (admin == null) {
        admin = (User) session.getAttribute("user");
    }
    String adminUsername = admin != null ? admin.getUsername() : "管理员";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>被封用户</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
        }
        .header {
            background-color: #00a1d6;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .nav-links {
            display: flex;
            gap: 20px;
        }
        .nav-links a {
            color: white;
            text-decoration: none;
            padding: 5px 10px;
        }
        .main-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
            display: flex;
            gap: 20px;
        }
        .sidebar {
            width: 250px;
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            height: fit-content;
        }
        .sidebar-menu {
            list-style: none;
            padding: 0;
        }
        .sidebar-menu li {
            margin-bottom: 10px;
        }
        .sidebar-menu a {
            display: block;
            padding: 10px 15px;
            color: #333;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }
        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background-color: #00a1d6;
            color: white;
        }
        .content {
            flex: 1;
        }
        .stats-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            text-align: center;
        }
        .stats-value {
            font-size: 48px;
            font-weight: bold;
            color: #dc3545;
            margin-bottom: 10px;
        }
        .stats-label {
            color: #666;
            font-size: 16px;
        }
        .user-table-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            overflow-x: auto;
        }
        .user-table {
            width: 100%;
            border-collapse: collapse;
        }
        .user-table th,
        .user-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
            vertical-align: top;
        }
        .user-table th {
            background-color: #f8f9fa;
            font-weight: bold;
            color: #333;
        }
        .user-table tr:hover {
            background-color: #f8f9fa;
        }
        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #dc3545;
        }
        .ban-reason {
            background-color: #f8d7da;
            color: #721c24;
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 14px;
            margin: 5px 0;
        }
        .user-stats {
            display: flex;
            gap: 14px;
            font-size: 14px;
            color: #666;
            margin-top: 10px;
            flex-wrap: wrap;
        }
        .user-stat {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
            margin-right: 5px;
        }
        .btn-unban {
            background-color: #28a745;
            color: white;
        }
        .btn-unban:hover {
            background-color: #218838;
        }
        .btn-delete {
            background-color: #dc3545;
            color: white;
        }
        .btn-delete:hover {
            background-color: #c82333;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 20px;
            flex-wrap: wrap;
        }
        .pagination a {
            padding: 8px 12px;
            text-decoration: none;
            border: 1px solid #ddd;
            border-radius: 4px;
            color: #333;
        }
        .pagination a.active {
            background-color: #00a1d6;
            color: white;
            border-color: #00a1d6;
        }
        .pagination a:hover:not(.active) {
            background-color: #f5f5f5;
        }
        .welcome-admin {
            color: white;
            font-weight: bold;
        }
        .no-users {
            text-align: center;
            padding: 60px;
            color: #666;
        }
        .no-users-icon {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
    </style>
</head>
<body>
    <div class="header">
        <div style="font-size: 24px; font-weight: bold;">管理后台</div>
        <div class="nav-links">
            <span class="welcome-admin">管理员: <%= adminUsername %></span>
            <a href="/">返回首页</a>
            <a href="/admin/logout">退出登录</a>
        </div>
    </div>
    <div class="main-container">
        <div class="sidebar">
            <ul class="sidebar-menu">
                <li><a href="/admin/adminindex">数据概览</a></li>
                <li><a href="/admin/users">用户管理</a></li>
                <li><a href="/admin/videos">视频管理</a></li>
                <li><a href="/admin/pending">待审核视频</a></li>
                <li><a href="/admin/banned" class="active">被封用户</a></li>
                <li><a href="/admin/reports">举报管理</a></li>
                <hr style="color:red"/>
                <li><a href="/adminticket/exhibitions">漫展管理</a></li>
                <li><a href="/adminticket/orders">订单管理</a></li>
                <li><a href="/adminticket/statistics">漫展数据统计</a></li>
                <li><a href="/adminticket/consultingUsers">当前咨询用户</a></li>
            </ul>
        </div>
        <div class="content">
            <h2>被封用户管理</h2>
            <div class="stats-card">
                <div class="stats-value">${totalCount != null ? totalCount : 0}</div>
                <div class="stats-label">被封用户总数</div>
            </div>
            <div class="user-table-container">
                <%
                    List<User> users = (List<User>) request.getAttribute("users");
                    if (users != null && !users.isEmpty()) {
                %>
                <table class="user-table">
                    <thead>
                        <tr>
                            <th>头像</th>
                            <th>用户信息</th>
                            <th>被封时间</th>
                            <th>账号信息</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (User user : users) {
                        %>
                        <tr>
                            <td>
                                <img src='<%= user.getAvatarUrl() != null ? user.getAvatarUrl() : "/static/images/default_avatar.png" %>'
                                     alt="头像" class="user-avatar">
                            </td>
                            <td>
                                <div style="font-weight: bold; margin-bottom: 5px;">
                                    <%= user.getUsername() != null ? user.getUsername() : "未知用户" %>
                                </div>
                                <div style="color: #666; font-size: 14px;">
                                    ID: <%= user.getId() %>
                                </div>
                                <div class="user-stats">
                                    <div class="user-stat">
                                        <span>关注:</span>
                                        <span><%= user.getFollowingCount() != null ? user.getFollowingCount() : 0 %></span>
                                    </div>
                                    <div class="user-stat">
                                        <span>粉丝:</span>
                                        <span><%= user.getFollowerCount() != null ? user.getFollowerCount() : 0 %></span>
                                    </div>
                                    <div class="user-stat">
                                        <span>获赞:</span>
                                        <span><%= user.getTotalLikeCount() != null ? user.getTotalLikeCount() : 0 %></span>
                                    </div>
                                    <div class="user-stat">
                                        <span>收藏:</span>
                                        <span><%= user.getTotalFavCount() != null ? user.getTotalFavCount() : 0 %></span>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="ban-reason">状态异常</div>
                                <div style="color: #666; font-size: 14px;">
                                    <%= user.getTimeCreate() != null ? user.getTimeCreate().toString() : "未知" %>
                                </div>
                            </td>
                            <td>
                                <div style="color: #dc3545; font-weight: bold;">
                                    状态码: <%= user.getStatus() != null ? user.getStatus() : 0 %>
                                </div>
                                <div style="color: #666; font-size: 13px; margin-top: 5px;">
                                    账号已被封禁
                                </div>
                            </td>
                            <td>
                                <form action="${pageContext.request.contextPath}/admin/unbanUser" method="post" style="display:inline;">
                                    <input type="hidden" name="userId" value="<%= user.getId() %>">
                                    <button class="btn btn-unban" type="submit">解封用户</button>
                                </form>
                                <button class="btn btn-delete" onclick="deleteUser(<%= user.getId() %>)">永久删除</button>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <%
                    } else {
                %>
                <div class="no-users">
                    <div class="no-users-icon">🚫</div>
                    <h3>暂无被封用户</h3>
                    <p>当前没有被封禁的账号</p>
                </div>
                <%
                    }
                    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
                    int currentPage = currentPageObj != null ? currentPageObj : 1;
                    int totalPages = totalPagesObj != null ? totalPagesObj : 1;
                %>
                <div class="pagination">
                    <%
                        if (currentPage > 1) {
                    %>
                    <a href="/admin/banned?page=<%= currentPage - 1 %>">上一页</a>
                    <%
                        }
                        for (int i = 1; i <= totalPages; i++) {
                            if (i == currentPage) {
                    %>
                    <a href="/admin/banned?page=<%= i %>" class="active"><%= i %></a>
                    <%
                            } else {
                    %>
                    <a href="/admin/banned?page=<%= i %>"><%= i %></a>
                    <%
                            }
                        }
                        if (currentPage < totalPages) {
                    %>
                    <a href="/admin/banned?page=<%= currentPage + 1 %>">下一页</a>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
    <script>
        function deleteUser(userId) {
            fetch('/admin/deleteUser', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'userId=' + userId
            }).then(response => response.text()).then(result => {
                if (result === 'success') {
                    alert('用户已永久删除');
                    location.reload();
                } else {
                    alert('删除失败: ' + result);
                }
            }).catch(error => {
                alert('删除失败: ' + error);
            });
        }
    </script>
</body>
</html>
