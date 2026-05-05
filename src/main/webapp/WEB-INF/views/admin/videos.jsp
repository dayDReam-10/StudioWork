<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.Video" %>
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
    <title>视频管理</title>
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
        .video-grid-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
        }
        .video-card {
            border: 1px solid #eee;
            border-radius: 8px;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
            background: white;
        }
        .video-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .video-cover {
            height: 50px;
            object-fit: cover;
            background-color: #f0f0f0;
            background-size: contain;
            background-repeat: no-repeat;
        }
        .video-info {
            padding: 15px;
        }
        .video-title {
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .video-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            font-size: 14px;
            color: #666;
        }
        .video-author {
            font-weight: 500;
        }
        .video-stats {
            display: flex;
            gap: 15px;
            font-size: 13px;
            color: #999;
            margin-bottom: 15px;
        }
        .video-status {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        .status-approved {
            background-color: #d1edff;
            color: #0c5460;
        }
        .status-rejected {
            background-color: #f8d7da;
            color: #721c24;
        }
        .video-actions {
            display: flex;
            gap: 10px;
        }
        .btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        .btn-delete {
            background-color: #dc3545;
            color: white;
        }
        .btn-delete:hover {
            background-color: #c82333;
        }
        .btn-view {
            background-color: #007bff;
            color: white;
        }
        .btn-view:hover {
            background-color: #0056b3;
        }
        .search-box {
            margin-bottom: 20px;
        }
        .search-box input {
            width: 100%;
            max-width: 300px;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .filter-box {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .filter-box select {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 30px;
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
                                                                                           <li><a href="/admin/users" >用户管理</a></li>
                                                                                           <li><a href="/admin/videos" class="active">视频管理</a></li>
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
            <h2>视频管理</h2>
            <div class="search-box">
                <input type="text" placeholder="搜索视频标题..." onkeyup="searchVideos(this.value)">
            </div>
            <div class="filter-box">
                <label>状态筛选：</label>
                <select onchange="filterByStatus(this.value)">
                    <option value="">全部</option>
                    <option value="0">待审核</option>
                    <option value="1">已通过</option>
                    <option value="2">已驳回</option>
                </select>
            </div>
            <div class="video-grid-container">
                <div class="video-grid">
                    <%
                        List<Video> videos = (List<Video>) request.getAttribute("videos");
                        if (videos != null && !videos.isEmpty()) {
                            for (Video video : videos) {
                              pageContext.setAttribute("video", video);
                    %>
                    <div class="video-card">
                       <img src='<%= video.getCoverUrl() != null ? video.getCoverUrl() : "/static/images/default_cover.png" %>'
                            alt="视频封面" class="video-cover">
                        <div class="video-info">
                            <span class="video-status <%= video.getStatus() == 0 ? "status-pending" : video.getStatus() == 1 ? "status-approved" : "status-rejected" %>">
                                <%= video.getStatus() == 0 ? "待审核" : video.getStatus() == 1 ? "已通过" : "已驳回" %>
                            </span>
                            <h3 class="video-title"><%= video.getTitle() != null ? video.getTitle() : "无标题" %></h3>
                            <div class="video-meta">
                                <span class="video-author">
                                    作者: <%= video.getAuthor() != null ? video.getAuthor().getUsername() : "未知" %>
                                </span>
                                <span>
                                    <%= video.getTimeCreate() != null ? video.getTimeCreate().toString().substring(0, 19) : "未知" %>
                                </span>
                            </div>
                            <div class="video-stats">
                                <span>播放: <%= video.getViewCount() != null ? video.getViewCount() : 0 %></span>
                                <span>点赞: <%= video.getLikeCount() != null ? video.getLikeCount() : 0 %></span>
                                <span>收藏: <%= video.getFavCount() != null ? video.getFavCount() : 0 %></span>
                            </div>
                            <div class="video-actions">
                                <button class="btn btn-view" onclick="viewVideo(<%= video.getId() %>)">查看</button>
                                <button class="btn btn-delete" onclick="deleteVideo(<%= video.getId() %>)">删除</button>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #666;">
                        暂无视频数据
                    </div>
                    <%
                        }
                    %>
                </div>
                <div class="pagination">
                    <%
                        int currentPage = (Integer) request.getAttribute("currentPage");
                        int totalPages = (Integer) request.getAttribute("totalPages");
                        // 上一页
                        if (currentPage > 1) {
                    %>
                    <a href="/admin/videos?page=<%= currentPage - 1 %>">上一页</a>
                    <%
                        }
                        // 页码
                        for (int i = 1; i <= totalPages; i++) {
                            if (i == currentPage) {
                    %>
                    <a href="/admin/videos?page=<%= i %>" class="active"><%= i %></a>
                    <%
                            } else {
                    %>
                    <a href="/admin/videos?page=<%= i %>"><%= i %></a>
                    <%
                            }
                        }
                        // 下一页
                        if (currentPage < totalPages) {
                    %>
                    <a href="/admin/videos?page=<%= currentPage + 1 %>">下一页</a>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
<script>
    // 删除视频
    function deleteVideo(videoId) {
        if (confirm('确定要删除这个视频吗？删除后不可恢复！')) {
            fetch('/admin/deleteVideo', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'id='+videoId
            }).then(response => response.text()).then(result => {
                if (result === 'success') {
                    alert('视频已删除');
                    location.reload();
                } else {
                    alert('删除失败: ' + result);
                }
            }).catch(error => {
                alert('删除失败: ' + error);
            });
        }
    }
    // 查看视频
    function viewVideo(videoId) {
        window.open('/video?id='+videoId, '_blank');
    }
    // 搜索视频
    function searchVideos(keyword) {
        if (keyword.length < 2) {
            window.location.href = '/admin/videos';
            return;
        }
        window.location.href = '/admin/videos?search=' + encodeURIComponent(keyword);
    }
    // 按状态筛选
    function filterByStatus(status) {
        window.location.href = '/admin/videos?status=' + encodeURIComponent(status);
    }
</script>
</body>
</html>