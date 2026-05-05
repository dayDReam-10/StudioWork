<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.User" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    User admin = (User) session.getAttribute("admin");
    String adminUsername = admin != null ? admin.getUsername() : "管理员";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户管理</title>
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
        }
        .user-table th {
            background-color: #f8f9fa;
            font-weight: bold;
            color: #333;
        }
        .user-table tr:hover {
            background-color: #f8f9fa;
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-active {
            background-color: #d4edda;
            color: #155724;
        }
        .status-banned {
            background-color: #f8d7da;
            color: #721c24;
        }
        .role-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            background-color: #e2e3e5;
            color: #495057;
        }
        .btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
            margin-right: 5px;
        }
        .btn-toggle {
            background-color: #ffc107;
            color: #212529;
        }
        .btn-toggle:hover {
            background-color: #e0a800;
        }
        .btn-export {
            background-color: #28a745;
            color: white;
        }
        .btn-export:hover {
            background-color: #218838;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 20px;
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
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }
        .search-box {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .search-box input {
            flex: 1;
            max-width: 300px;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .export-btn {
            background-color: #28a745;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        .export-btn:hover {
            background-color: #218838;
        }
        .welcome-admin {
            color: white;
            font-weight: bold;
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
                        <li><a href="/admin/adminindex" >数据概览</a></li>
                                                                            <li><a href="/admin/users" class="active">用户管理</a></li>
                                                                            <li><a href="/admin/videos">视频管理</a></li>
                                                                            <li><a href="/admin/pending" >待审核视频</a></li>
                                                                            <li><a href="/admin/banned" >被封用户</a></li>
                                                                            <li><a href="/admin/reports" >举报管理</a></li>
                                                                            <hr style="color:red"/>
                                                                            <li><a href="/adminticket/exhibitions">漫展管理</a></li>
                                                                            <li><a href="/adminticket/orders">订单管理</a></li>
                                                                            <li><a href="/adminticket/statistics">漫展数据统计</a></li>
                        <li><a href="/adminticket/consultingUsers">当前咨询用户</a></li>
            </ul>
        </div>
        <div class="content">
            <h2>用户管理</h2>
            <div class="search-box">
                <input type="text" placeholder="搜索用户名..." onkeyup="searchUsers(this.value)">
                <button class="export-btn" onclick="exportUsers()">导出Excel</button>
            </div>
            <div class="user-table-container">
                <table class="user-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>头像</th>
                            <th>用户名</th>
                            <th>性别</th>
                            <th>硬币</th>
                            <th>关注</th>
                            <th>粉丝</th>
                            <th>获赞</th>
                            <th>收藏</th>
                            <th>角色</th>
                            <th>状态</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<User> users = (List<User>) request.getAttribute("users");
                            if (users != null && !users.isEmpty()) {
                                for (User user : users) {
                        %>
                        <tr>
                            <td><%= user.getId() %></td>
                          <td>
                              <img src='<%= user.getAvatarUrl() != null ? user.getAvatarUrl() : "/static/images/default_avatar.png" %>'
                                   alt="头像" class="user-avatar">
                          </td>
                            <td><%= user.getUsername() != null ? user.getUsername() : "未知" %></td>
                            <td>
                                <%= user.getGender() != null ? (user.getGender() == 1 ? "男" : user.getGender() == 2 ? "女" : "保密") : "未知" %>
                            </td>
                            <td><%= user.getCoinCount() != null ? user.getCoinCount() : 0 %></td>
                            <td><%= user.getFollowingCount() != null ? user.getFollowingCount() : 0 %></td>
                            <td><%= user.getFollowerCount() != null ? user.getFollowerCount() : 0 %></td>
                            <td><%= user.getTotalLikeCount() != null ? user.getTotalLikeCount() : 0 %></td>
                            <td><%= user.getTotalFavCount() != null ? user.getTotalFavCount() : 0 %></td>
                            <td>
                                <span class="role-badge">
                                    <%= user.getRole() != null ? user.getRole() : "user" %>
                                </span>
                            </td>
                            <td>
                                <span class="status-badge <%= user.getStatus() != null && user.getStatus() == 1 ? "status-active" : "status-banned" %>">
                                    <%= user.getStatus() != null && user.getStatus() == 1 ? "正常" : "封禁" %>
                                </span>
                            </td>
                            <td>
                                <button class="btn btn-toggle" onclick="toggleUserStatus(<%= user.getId() %>, '<%= user.getStatus() != null && user.getStatus() == 1 ? "ban" : "unban" %>')">
                                    <%= user.getStatus() != null && user.getStatus() == 1 ? "封禁" : "解封" %>
                                </button>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="12" style="text-align: center; padding: 40px; color: #666;">
                                暂无用户数据
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <div class="pagination">
                    <%
                        int currentPage = (Integer) request.getAttribute("currentPage");
                        int totalPages = (Integer) request.getAttribute("totalPages");
                        // 上一页
                        if (currentPage > 1) {
                    %>
                    <a href="/admin/users?page=<%= currentPage - 1 %>">上一页</a>
                    <%
                        }
                        // 页码
                        for (int i = 1; i <= totalPages; i++) {
                            if (i == currentPage) {
                    %>
                    <a href="/admin/users?page=<%= i %>" class="active"><%= i %></a>
                    <%
                            } else {
                    %>
                    <a href="/admin/users?page=<%= i %>"><%= i %></a>
                    <%
                            }
                        }
                        // 下一页
                        if (currentPage < totalPages) {
                    %>
                    <a href="/admin/users?page=<%= currentPage + 1 %>">下一页</a>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
   <script>
       // 切换用户状态
       function toggleUserStatus(userId, action) {
           const actionText = action === 'ban' ? '封禁' : '解封';
           fetch('/admin/toggleUserStatus', {
               method: 'POST',
               headers: {
                   'Content-Type': 'application/x-www-form-urlencoded',
               },
               body: 'userId='+userId
           }).then(response => response.text()).then(result => {
               if (result === 'success') {
                   alert(`${actionText}成功`);
                   location.reload();
               } else {
                   alert('操作失败: ' + result);
               }
           }).catch(error => {
               alert('操作失败: ' + error);
           });
       }
       // 搜索用户
       function searchUsers(keyword) {
           if (keyword.length < 2) {
               window.location.href = '/admin/users';
               return;
           }
           window.location.href = '/admin/users?search=' + encodeURIComponent(keyword);
       }
       // 导出用户数据
       function exportUsers() {
           window.location.href = '/admin/exportUser';
       }
   </script>
</body>
</html>