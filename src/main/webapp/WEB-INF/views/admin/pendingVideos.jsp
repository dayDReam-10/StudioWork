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
    <title>待审核视频</title>
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
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        .video-card {
            border: 1px solid #eee;
            border-radius: 8px;
            padding: 15px;
            background: white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .video-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .video-title {
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        .video-info {
            color: #666;
            font-size: 14px;
            margin-bottom: 8px;
        }
        .video-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }
        .btn {
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        .btn-approve {
            background-color: #4ecdc4;
            color: white;
        }
        .btn-approve:hover {
            background-color: #45b7b8;
        }
        .btn-reject {
            background-color: #ff6b6b;
            color: white;
        }
        .btn-reject:hover {
            background-color: #ff5252;
        }
        .welcome-admin {
            color: white;
            font-weight: bold;
        }
        .no-videos {
            text-align: center;
            padding: 40px;
            color: #666;
            font-size: 16px;
        }
        .back-to-dashboard {
            margin-bottom: 20px;
        }
        .back-to-dashboard a {
            display: inline-block;
            padding: 8px 16px;
            background-color: #00a1d6;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }
        .back-to-dashboard a:hover {
            background-color: #0084a6;
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
                                              <li><a href="/admin/users">用户管理</a></li>
                                              <li><a href="/admin/videos">视频管理</a></li>
                                              <li><a href="/admin/pending" class="active">待审核视频</a></li>
                                              <li><a href="/admin/banned" >被封用户</a></li>
                                              <li><a href="/admin/reports">举报管理</a></li>
                                              <hr style="color:red"/>
                                              <li><a href="/adminticket/exhibitions">漫展管理</a></li>
                                              <li><a href="/adminticket/orders">订单管理</a></li>
                                              <li><a href="/adminticket/statistics">漫展数据统计</a></li>
                                              <li><a href="/adminticket/consultingUsers">当前咨询用户</a></li>
            </ul>
        </div>
        <div class="content">
            <div class="back-to-dashboard">
                <a href="/admin/adminindex">← 返回数据概览</a>
            </div>
            <h2>待审核视频</h2>
            <%
                List<Video> pendingVideos = (List<Video>) request.getAttribute("pendingVideos");
                if (pendingVideos != null && !pendingVideos.isEmpty()) {
            %>
            <div class="video-grid">
                <%
                    for (Video video : pendingVideos) {
                %>
                <div class="video-card">
                    <div class="video-title"><%= video.getTitle() %></div>
                    <p class="video-info">作者: <%= video.getAuthor() != null ? video.getAuthor().getUsername() : "未知" %></p>
                    <p class="video-info">上传时间: <%= video.getTimeCreate() != null ? video.getTimeCreate().toString() : "未知" %></p>
                    <p class="video-info">视频ID: <%= video.getId() %></p>
                    <% if (video.getDescription() != null && !video.getDescription().isEmpty()) { %>
                    <p class="video-info">简介: <%= video.getDescription() %></p>
                    <% } %>
                    <div class="video-actions">
                        <button class="btn btn-approve" onclick="approveVideo(event, <%= video.getId() %>)">通过</button>
                        <button class="btn btn-reject" onclick="rejectVideo(event, <%= video.getId() %>)">驳回</button>
                    </div>
                </div>
                <%
                    }
                %>
            </div>
            <%
                } else {
            %>
            <div class="no-videos">
                <p>暂无待审核视频</p>
            </div>
            <%
                }
            %>
        </div>
    </div>
    <script>
        function approveVideo(event, videoId) {
            if (confirm('确定要通过这个视频吗？'+videoId)) {
                fetch('/admin/approve?id='+videoId).then(response => response.text()).then(result => {
                        if (result === 'success') {
                            alert('审核通过');
                            // 移除已审核的视频卡片
                            const videoCard = event.target.closest('.video-card');
                            videoCard.style.transition = 'opacity 0.3s ease';
                            videoCard.style.opacity = '0';
                            setTimeout(() => {
                                videoCard.remove();
                                // 检查是否还有待审核视频
                                const remainingVideos = document.querySelectorAll('.video-card');
                                if (remainingVideos.length === 0) {
                                    document.querySelector('.video-grid').innerHTML = '<div class="no-videos"><p>暂无待审核视频</p></div>';
                                }
                            }, 300);
                        } else {
                            alert('操作失败: ' + result);
                        }
                    }).catch(error => {
                        alert('操作失败: ' + error);
                    });
            }
        }
        function rejectVideo(event, videoId) {
            if (confirm('确定要驳回这个视频吗？')) {
                fetch('/admin/reject?id='+videoId).then(response => response.text()).then(result => {
                        if (result === 'success') {
                            alert('视频已驳回');
                            // 移除已驳回的视频卡片
                            const videoCard = event.target.closest('.video-card');
                            videoCard.style.transition = 'opacity 0.3s ease';
                            videoCard.style.opacity = '0';
                            setTimeout(() => {
                                videoCard.remove();
                                // 检查是否还有待审核视频
                                const remainingVideos = document.querySelectorAll('.video-card');
                                if (remainingVideos.length === 0) {
                                    document.querySelector('.video-grid').innerHTML = '<div class="no-videos"><p>暂无待审核视频</p></div>';
                                }
                            }, 300);
                        } else {
                            alert('操作失败: ' + result);
                        }
                    }).catch(error => {
                        alert('操作失败: ' + error);
                    });
            }
        }
    </script>
</body>
</html>