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
    <title>我的视频</title>
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
        }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .page-title {
            font-size: 28px;
            color: #333;
            margin: 0;
        }
        .upload-btn {
            background-color: #ff6b6b;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            text-decoration: none;
            transition: background-color 0.3s;
        }
        .upload-btn:hover {
            background-color: #ff5252;
        }
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .video-card {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .video-card:hover {
            transform: translateY(-5px);
        }
        .video-cover {
            width: 100%;
            height: 200px;
            background-size: cover;
            background-position: center;
            cursor: pointer;
            position: relative;
        }
        .video-status {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        .status-approved {
            background-color: #d4edda;
            color: #155724;
        }
        .status-rejected {
            background-color: #f8d7da;
            color: #721c24;
        }
        .video-info {
            padding: 15px;
        }
        .video-title {
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 5px;
            cursor: pointer;
            color: #333;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .video-title:hover {
            color: #00a1d6;
        }
        .video-meta {
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
        }
        .video-actions {
            display: flex;
            gap: 10px;
            justify-content: space-between;
        }
        .btn {
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        .btn-play {
            background-color: #00a1d6;
            color: white;
            flex: 1;
        }
        .btn-play:hover {
            background-color: #0088b3;
        }
        .btn-delete {
            background-color: #ff6b6b;
            color: white;
        }
        .btn-delete:hover {
            background-color: #ff5252;
        }
        .btn-edit {
            background-color: #4ecdc4;
            color: white;
        }
        .btn-edit:hover {
            background-color: #3dbdb3;
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .empty-state h3 {
            color: #666;
            margin-bottom: 15px;
        }
        .empty-state p {
            color: #999;
            margin-bottom: 20px;
        }
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: none;
        }
        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: none;
        }
    </style>
</head>
<body>
    <div class="header">
        <a href="/" style="text-decoration: none; color: inherit;"><div style="font-size: 24px; font-weight: bold;">视频分享平台</div></a>
        <div class="nav-links">
            <a href="/">首页</a>
            <a href="/user/me">个人中心</a>
            <a href="/user/logout">退出登录</a>
        </div>
    </div>
    <div class="main-container">
        <div class="page-header">
            <h1 class="page-title">我的视频</h1>
            <a href="/video/upload" class="upload-btn">上传视频</a>
        </div>
        <!-- 错误信息 -->
        <div class="error-message" id="error-message">
            ${error}
        </div>
        <!-- 成功信息 -->
        <div class="success-message" id="success-message">
            ${success}
        </div>
        <%
            List<Video> videos = (List<Video>) request.getAttribute("videos");
            if (videos != null && !videos.isEmpty()) {
        %>
        <div class="video-grid">
            <%
                for (Video video : videos) {
                 pageContext.setAttribute("video", video);
            %>
            <div class="video-card">
                <div class="video-cover" style="background-size: contain;background-repeat: no-repeat;background-image: url('<%= video.getCoverUrl() != null && !video.getCoverUrl().isEmpty() ? video.getCoverUrl() : "/static/images/default_cover.png" %>')"
                     onclick="window.location.href='/video/detail?id=${video.id}'">
                    <div class="video-status ${video.status == 0 ? 'status-pending' : video.status == 1 ? 'status-approved' : 'status-rejected'}">
                       <%= video.getStatus() == 0 ? "待审核" : video.getStatus() == 1 ? "已通过" : "已拒绝" %>
                    </div>
                </div>
                <div class="video-info">
                    <div class="video-title" onclick="window.location.href='/video/detail?id=${video.id}'">
                        <%= video.getTitle() %>
                    </div>
                    <div class="video-meta">
                        播放: <%= video.getViewCount() %> |
                        点赞: <%= video.getLikeCount() %> |
                        收藏: <%= video.getFavCount() %>
                    </div>
                    <div class="video-actions">
                        <button class="btn btn-play" onclick="window.location.href='/video/detail?id=${video.id}'">
                            播放
                        </button>
                        <%
                            // 只有审核通过的视频才能编辑
                            if (video.getStatus() == 1) {
                        %>
                        <a style="display:none;" href="/video/update?id=${video.id}" class="btn btn-edit">编辑</a>
                        <%
                            }
                        %>
                        <button class="btn btn-delete" onclick="confirmDelete(${video.id})">删除</button>
                    </div>
                </div>
            </div>
            <%
                }
            %>
        </div>
        <%
            } else {
        %>
        <div class="empty-state">
            <h3>您还没有上传任何视频</h3>
            <p>点击"上传视频"按钮开始分享您的精彩内容</p>
            <a href="/video/upload" class="upload-btn">上传视频</a>
        </div>
        <%
            }
        %>
    </div>
    <script>
        // 显示消息
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            const error = urlParams.get('error');
            const success = urlParams.get('success');
            if (error) {
                document.getElementById('error-message').textContent = decodeURIComponent(error);
                document.getElementById('error-message').style.display = 'block';
            }
            if (success) {
                document.getElementById('success-message').textContent = decodeURIComponent(success);
                document.getElementById('success-message').style.display = 'block';
            }
        };
        // 删除视频确认
        function confirmDelete(videoId) {
            if (confirm('确定要删除这个视频吗？删除后将无法恢复！')) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = '/video/delete?id=' + videoId;
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>