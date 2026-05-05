<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人中心</title>
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
            max-width: 1000px;
            margin: 20px auto;
            padding: 0 20px;
            display: flex;
            gap: 20px;
        }
        .profile-sidebar {
            flex: 1;
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .profile-content {
            flex: 2;
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background-color: #ddd;
            margin: 0 auto 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 48px;
            overflow: hidden;
        }
        .profile-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .profile-info {
            text-align: center;
            margin-bottom: 20px;
        }
        .profile-name {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .profile-stats {
            display: flex;
            justify-content: space-around;
            margin: 20px 0;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 4px;
        }
        .stat-item {
            text-align: center;
        }
        .stat-value {
            font-size: 20px;
            font-weight: bold;
            color: #00a1d6;
        }
        .stat-label {
            font-size: 14px;
            color: #666;
        }
        .stat-link {
            flex: 1;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        .stat-link:hover .stat-value {
            color: #0088b3;
        }
        .profile-menu {
            list-style: none;
            padding: 0;
        }
        .profile-menu li {
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }
        .profile-menu a {
            color: #333;
            text-decoration: none;
            display: block;
        }
        .profile-menu a:hover {
            color: #00a1d6;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #333;
            font-weight: bold;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .form-group textarea {
            min-height: 100px;
            resize: vertical;
        }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            margin-right: 10px;
        }
        .btn-primary {
            background-color: #00a1d6;
            color: white;
        }
        .btn-primary:hover {
            background-color: #0088b3;
        }
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        .btn-secondary:hover {
            background-color: #545b62;
        }
        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
        }
        .tab-menu {
            display: flex;
            margin-bottom: 20px;
            border-bottom: 1px solid #ddd;
        }
        .tab-item {
            padding: 10px 20px;
            cursor: pointer;
            border-bottom: 2px solid transparent;
        }
        .tab-item.active {
            border-bottom-color: #00a1d6;
            color: #00a1d6;
        }
        .error-message {
            color: #ff6b6b;
            margin-bottom: 10px;
        }
        .success-message {
            color: #4ecdc4;
            margin-bottom: 10px;
        }
        .welcome-user {
            color: white;
        }
        .coin-value {
            color: #ff6b6b !important;
            font-size: 24px !important;
            text-shadow: 1px 1px 2px rgba(255,107,107,0.3);
        }
        .quick-actions {
            margin-top: 20px;
            padding: 15px;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            border-radius: 8px;
            text-align: center;
        }
        .quick-actions a:hover {
            text-decoration: underline;
        }
        .profile-menu li:last-child {
            border-bottom: none;
        }
        .profile-menu li:last-child a {
            color: #ff6b6b;
            font-weight: bold;
        }
        .profile-menu li:last-child a:hover {
            color: #ff5252;
        }
        .checkin-section {
            transition: all 0.3s ease;
        }
        .checkin-section:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(245, 87, 108, 0.3);
        }
        #checkin-btn:disabled {
            background-color: #ccc !important;
            color: #999 !important;
            cursor: not-allowed !important;
        }
        .video-list {
            max-height: 600px;
            overflow-y: auto;
        }
        .video-item:hover {
            background: #f0f0f0;
            transition: background 0.3s ease;
        }
        .avatar-preview {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background-color: #f0f0f0;
            margin: 15px auto;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
            border: 2px solid #ddd;
        }
        .avatar-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .file-input-wrapper {
            position: relative;
            margin: 10px 0;
        }
        .file-input-wrapper input[type=file] {
            position: absolute;
            left: 0;
            top: 0;
            opacity: 0;
            width: 100%;
            height: 100%;
            cursor: pointer;
        }
        .custom-file-btn {
            display: inline-block;
            background-color: #00a1d6;
            color: white;
            padding: 8px 20px;
            border-radius: 4px;
            cursor: pointer;
        }
        @media (max-width: 768px) {
            .main-container {
                flex-direction: column;
            }
            .video-item {
                flex-direction: column !important;
            }
            .video-cover {
                margin-right: 0 !important;
                margin-bottom: 10px !important;
                width: 100% !important;
                height: 200px !important;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <a href="/" style="text-decoration: none; color: inherit;"><div style="font-size: 24px; font-weight: bold;">视频分享平台</div></a>
        <div class="nav-links">
            <a href="/">首页</a>
            <a href="/user/me">个人中心</a>
            <a href="/video/dynamic">动态</a>
            <a href="/ticket/index">漫展活动</a>
            <a href="/video/upload">上传视频</a>
            <%
                User currentUser = (User) session.getAttribute("user");
                if (currentUser != null && "admin".equals(currentUser.getRole())) {
            %>
                <a href="/admin/adminindex">管理后台</a>
            <%
                }
            %>
            <a href="/user/logout">退出登录</a>
        </div>
    </div>
    <div class="main-container">
        <div class="profile-sidebar">
            <div class="profile-avatar">
                <c:choose>
                    <c:when test="${not empty user.avatarUrl}">
                        <img src="${user.avatarUrl}" alt="头像">
                    </c:when>
                    <c:otherwise>
                        <%
                            User u = (User) request.getAttribute("user");
                            if (u != null && u.getUsername() != null && u.getUsername().length() > 0) {
                                out.print(u.getUsername().charAt(0));
                            }
                        %>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="profile-info">
                <h2 class="profile-name">${user.username}</h2>
                <p>等级: ${user.role == 'admin' ? '管理员' : '普通用户'}</p>
                <div class="checkin-section" style="margin-top: 15px; padding: 15px; background: linear-gradient(135deg, #9fadc7 0%, #ebf5ec 100%); border-radius: 8px; text-align: center;">
                    <h4 style="color: white; margin-bottom: 10px;">每日签到</h4>
                    <p id="checkin-status-text" style="color: white; margin-bottom: 10px;">点击签到获取硬币</p>
                    <button id="checkin-btn" onclick="performCheckIn()"
                            style="padding: 8px 20px; background-color: white; color: #f5576c; border: none; border-radius: 20px; cursor: pointer; font-weight: bold; font-size: 14px; transition: all 0.3s;">
                        立即签到
                    </button>
                </div>
            </div>
            <div class="profile-stats">
                <a class="stat-link" href="${pageContext.request.contextPath}/user/following?userId=${user.id}">
                    <div class="stat-item">
                        <div class="stat-value">${user.followingCount}</div>
                        <div class="stat-label">关注</div>
                    </div>
                </a>
                <a class="stat-link" href="${pageContext.request.contextPath}/user/followers?userId=${user.id}">
                    <div class="stat-item">
                        <div class="stat-value">${user.followerCount}</div>
                        <div class="stat-label">粉丝</div>
                    </div>
                </a>
                <div class="stat-item">
                    <div class="stat-value coin-value">${user.coinCount}</div>
                    <div class="stat-label">硬币</div>
                </div>
            </div>
            <ul class="profile-menu">
                <li><a href="#" onclick="showTab('basic', event)">基本资料</a></li>
                <li><a href="#" onclick="showTab('avatar', event)">修改头像</a></li>
                <li><a href="#" onclick="showTab('password', event)">修改密码</a></li>
                <li><a href="/video/myvideos">我的视频</a></li>
                <li><a href="/video/dynamic">关注动态</a></li>
                <li><a href="#" onclick="showTab('favorites', event)">我的收藏</a></li>
                <li><a href="/user/history">观看历史</a></li>
            </ul>
        </div>
        <div class="profile-content">
            <%-- 基本资料 --%>
            <div id="basic-tab" class="tab-content active">
                <h3>基本资料</h3>
                <%
                    String error = request.getParameter("error");
                    String success = request.getParameter("success");
                    if (error != null) {
                %>
                <div class="error-message">${error}</div>
                <%
                    }
                    if (success != null) {
                %>
                <div class="success-message">${success}</div>
                <%
                    }
                %>
                <form action="/user/updateProfile" method="post">
                    <div class="form-group">
                        <label for="username">用户名:</label>
                        <input type="text" id="username" name="username" value="${user.username}" readonly>
                    </div>
                    <div class="form-group">
                        <label for="gender">性别:</label>
                        <select id="gender" name="gender">
                            <option value="0" ${user.gender == 0 ? 'selected' : ''}>保密</option>
                            <option value="1" ${user.gender == 1 ? 'selected' : ''}>男</option>
                            <option value="2" ${user.gender == 2 ? 'selected' : ''}>女</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="signature">个人签名:</label>
                        <textarea id="signature" name="signature">${user.signature}</textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">保存修改</button>
                </form>
            </div>
            <%-- 修改头像（Base64 上传） --%>
            <div id="avatar-tab" class="tab-content">
                <h3>修改头像</h3>
                <div class="avatar-preview" id="avatarPreview">
                    <c:choose>
                        <c:when test="${not empty user.avatarUrl}">
                            <img id="previewImg" src="${user.avatarUrl}" alt="头像预览">
                        </c:when>
                        <c:otherwise>
                            <img id="previewImg" src="" alt="头像预览" style="display: none;">
                            <span id="noAvatarText" style="color: #999;">暂无头像</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="form-group">
                    <label>选择图片：</label>
                    <div class="file-input-wrapper">
                        <button type="button" class="custom-file-btn" onclick="document.getElementById('avatarFile').click()">选择图片</button>
                        <input type="file" id="avatarFile" accept="image/jpeg,image/png,image/gif" style="display: none;">
                        <span id="fileName" style="margin-left: 10px; color: #666;">未选择任何文件</span>
                    </div>
                    <p style="font-size: 12px; color: #999;">支持 JPG、PNG、GIF，大小不超过 2MB</p>
                </div>
                <button type="button" class="btn btn-primary" id="uploadAvatarBtn">保存头像</button>
                <div id="avatarMessage" style="margin-top: 10px;"></div>
            </div>
            <%-- 修改密码 --%>
            <div id="password-tab" class="tab-content">
                <h3>修改密码</h3>
                <form action="/user/changePassword" method="post">
                    <div class="form-group">
                        <label for="oldPassword">原密码:</label>
                        <input type="password" id="oldPassword" name="oldPassword" required>
                    </div>
                    <div class="form-group">
                        <label for="newPassword">新密码:</label>
                        <input type="password" id="newPassword" name="newPassword" required>
                    </div>
                    <div class="form-group">
                        <label for="confirmPassword">确认新密码:</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required>
                    </div>
                    <button type="submit" class="btn btn-primary">修改密码</button>
                    <button type="button" class="btn btn-secondary" onclick="location.href='/user/profile'">取消</button>
                </form>
            </div>
            <%-- 我的收藏 --%>
            <div id="favorites-tab" class="tab-content">
                <h3>我的收藏</h3>
                <div id="favorites-container">
                    <p>正在加载收藏的视频...</p>
                </div>
                <div id="favorites-pagination" style="text-align: center; margin-top: 20px;"></div>
            </div>
        </div>
    </div>
    <script>
        // ========== 头像 Base64 上传逻辑 ==========
        let selectedBase64 = null;
        const fileInput = document.getElementById('avatarFile');
        const previewImg = document.getElementById('previewImg');
        const noAvatarText = document.getElementById('noAvatarText');
        const fileNameSpan = document.getElementById('fileName');

        // 监听文件选择，转换为 Base64 并预览
        fileInput.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (!file) return;
            // 限制大小 2MB
            if (file.size > 2 * 1024 * 1024) {
                alert('图片大小不能超过 2MB');
                fileInput.value = '';
                fileNameSpan.textContent = '未选择任何文件';
                selectedBase64 = null;
                // 重置预览
                if (previewImg) {
                    previewImg.style.display = 'none';
                    if (noAvatarText) noAvatarText.style.display = 'inline';
                }
                return;
            }
            fileNameSpan.textContent = file.name;
            const reader = new FileReader();
            reader.onload = function(ev) {
                selectedBase64 = ev.target.result; // Base64 字符串
                // 显示预览
                if (previewImg) {
                    previewImg.src = selectedBase64;
                    previewImg.style.display = 'block';
                    if (noAvatarText) noAvatarText.style.display = 'none';
                }
            };
            reader.readAsDataURL(file);
        });

        // 保存头像：发送 Base64 到后端
        document.getElementById('uploadAvatarBtn').addEventListener('click', function() {
            if (!selectedBase64) {
                alert('请先选择图片');
                return;
            }
            const btn = this;
            const originalText = btn.textContent;
            btn.disabled = true;
            btn.textContent = '保存中...';
            const messageDiv = document.getElementById('avatarMessage');
            // 发送 POST 请求
            fetch('/user/updateAvatar', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'avatarUrl=' + encodeURIComponent(selectedBase64)
            }).then(response => response.json()).then(data => {
                if (data.success) {
                    messageDiv.innerHTML = '<div class="success-message">头像更新成功！</div>';
                    const sidebarAvatar = document.querySelector('.profile-avatar img');
                    if (sidebarAvatar) {
                        sidebarAvatar.src = selectedBase64;
                    } else {
                        const avatarDiv = document.querySelector('.profile-avatar');
                        avatarDiv.innerHTML = '<img src="' + selectedBase64 + '" alt="头像">';
                    }
                    setTimeout(() => {
                        location.reload();
                    }, 1500);
                } else {
                    messageDiv.innerHTML = '<div class="error-message">' + (data.message || '保存失败，请重试') + '</div>';
                }
            })
            .catch(error => {
                console.error('上传头像失败:', error);
                messageDiv.innerHTML = '<div class="error-message">网络错误，请重试</div>';
            })
            .finally(() => {
                btn.disabled = false;
                btn.textContent = originalText;
            });
        });

        let currentFavoritesPage = 1;
        // 检查用户今日签到状态
        function checkCheckInStatus() {
            fetch('${pageContext.request.contextPath}/client/checkin-status').then(response => response.json()).then(data => {
                    const btn = document.getElementById('checkin-btn');
                    const statusText = document.getElementById('checkin-status-text');
                    if (data.checkedIn) {
                        btn.disabled = true;
                        statusText.textContent = '今日已签到，明天再来吧！';
                        btn.textContent = '今日已签到';
                        btn.style.backgroundColor = '#ccc';
                        btn.style.cursor = 'not-allowed';
                    }
                }).catch(error => console.error('获取签到状态失败', error));
        }
        // 页面加载时检查签到状态
        window.addEventListener('load', function() {
            checkCheckInStatus();
            setInterval(checkCheckInStatus, 30000);
        });
        // 执行签到
        function performCheckIn() {
            const btn = document.getElementById('checkin-btn');
            const statusText = document.getElementById('checkin-status-text');
            if (btn.disabled) return;
            btn.disabled = true;
            btn.textContent = '签到中...';
            fetch('${pageContext.request.contextPath}/client/checkin', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            }).then(response => response.text()).then(result => {
                    if (result.includes('success=true')) {
                        statusText.textContent = '签到成功！获得硬币奖励！';
                        btn.textContent = '今日已签到';
                        btn.style.backgroundColor = '#ccc';
                        btn.style.cursor = 'not-allowed';
                        location.reload();
                    } else {
                        statusText.textContent = '今日已签到，明天再来吧！';
                        btn.textContent = '今日已签到';
                        btn.style.backgroundColor = '#ccc';
                        btn.style.cursor = 'not-allowed';
                    }
                     location.reload();
                }).catch(error => {
                    console.error('签到失败:', error);
                    statusText.textContent = '签到失败，请重试';
                    btn.disabled = false;
                    btn.textContent = '立即签到';
                });
        }
        // 密码修改验证
        const pwdForm = document.querySelector('form[action="/user/changePassword"]');
        if (pwdForm) {
            pwdForm.addEventListener('submit', function(e) {
                const newPassword = document.getElementById('newPassword').value;
                const confirmPassword = document.getElementById('confirmPassword').value;
                if (newPassword !== confirmPassword) {
                    e.preventDefault();
                    alert('两次输入的新密码不一致！');
                }
            });
        }
        // 显示收藏视频（请求数据）
        function showFavorites(page) {
            currentFavoritesPage = page;
            fetch('${pageContext.request.contextPath}/client/favorites?page=' + page)
                .then(response => response.json())
                .then(data => {
                    displayFavorites(data.videos, data.currentPage, data.totalPages);
                })
                .catch(error => {
                    console.error('获取收藏视频失败:', error);
                    document.getElementById('favorites-container').innerHTML = '<p style="color: red;">获取收藏视频失败，请刷新页面重试。</p>';
                });
        }
        // 显示收藏视频列表
        function displayFavorites(videos, currentPage, totalPages) {
            const container = document.getElementById('favorites-container');
            if (!videos || videos.length === 0) {
                container.innerHTML = '<p>您还没有收藏任何视频。</p>';
                document.getElementById('favorites-pagination').innerHTML = '';
                return;
            }
            let html = '<div class="video-list">';
            videos.forEach(video => {
                let description = video.description ? video.description.substring(0, 100) + '...' : '暂无描述';
                let coverUrl = video.coverUrl || '/static/images/default_cover.png';
                let viewCount = video.viewCount || 0;
                let likeCount = video.likeCount || 0;
                let coinCount = video.coinCount || 0;
                html += `
                    <div class="video-item" style="display: flex; margin-bottom: 20px; padding: 15px; background: #f9f9f9; border-radius: 8px;">
                        <div class="video-cover" style="flex: 0 0 200px; height: 150px; margin-right: 15px; overflow: hidden; border-radius: 4px;">
                            <img src="\${coverUrl}" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.src='/static/images/default_cover.png'">
                        </div>
                        <div class="video-info" style="flex: 1;">
                            <h4 style="margin: 0 0 10px 0; font-size: 18px;">
                                <a href="/video/detail?id=\${video.id}" style="color: #333; text-decoration: none;">\${video.title}</a>
                            </h4>
                            <p style="margin: 0 0 10px 0; color: #666; font-size: 14px;">\${description}</p>
                            <div style="display: flex; gap: 15px; font-size: 14px; color: #999;">
                                <span>👁 \${viewCount}</span>
                                <span>❤️ \${likeCount}</span>
                                <span>⭐ \${coinCount}</span>
                            </div>
                            <div style="margin-top: 10px;">
                                <button onclick="unfavoriteVideo(\${video.id})" style="padding: 5px 10px; background: #ff6b6b; color: white; border: none; border-radius: 4px; cursor: pointer;">取消收藏</button>
                            </div>
                        </div>
                    </div>
                `;
            });
            html += '</div>';
            container.innerHTML = html;
            // 生成分页
            const paginationDiv = document.getElementById('favorites-pagination');
            if (totalPages > 1) {
                let paginationHtml = '<div style="display: flex; justify-content: center; gap: 5px;">';
                if (currentPage > 1) {
                    paginationHtml += `<button onclick="showFavorites(\${currentPage - 1})" style="padding: 5px 10px; background: #00a1d6; color: white; border: none; border-radius: 4px; cursor: pointer;">上一页</button>`;
                }
                for (let i = 1; i <= totalPages; i++) {
                    if (i === currentPage) {
                        paginationHtml += `<span style="padding: 5px 10px; background: #f0f0f0; color: #333;">\${i}</span>`;
                    } else {
                        paginationHtml += `<button onclick="showFavorites(\${i})" style="padding: 5px 10px; background: #e0e0e0; color: #333; border: none; border-radius: 4px; cursor: pointer;">\${i}</button>`;
                    }
                }
                if (currentPage < totalPages) {
                    paginationHtml += `<button onclick="showFavorites(\${currentPage + 1})" style="padding: 5px 10px; background: #00a1d6; color: white; border: none; border-radius: 4px; cursor: pointer;">下一页</button>`;
                }
                paginationHtml += '</div>';
                paginationDiv.innerHTML = paginationHtml;
            } else {
                paginationDiv.innerHTML = '';
            }
        }
        // 取消收藏
        function unfavoriteVideo(videoId) {
            if (!confirm('确定要取消收藏这个视频吗？')) return;
            fetch('${pageContext.request.contextPath}/client/unfavorite', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'videoId=' + videoId
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showFavorites(currentFavoritesPage);
                    } else {
                        alert('取消收藏失败：' + (data.message || '未知错误'));
                    }
                })
                .catch(error => {
                    console.error('取消收藏失败:', error);
                    alert('取消收藏失败，请重试');
                });
        }
        // 切换标签页
        function showTab(tabName, clickEvent) {
            document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
            const targetTab = document.getElementById(tabName + '-tab');
            if (targetTab) targetTab.classList.add('active');
            document.querySelectorAll('.profile-menu a').forEach(item => {
                item.style.color = '#333';
                item.style.borderBottom = 'none';
            });
            if (clickEvent && clickEvent.currentTarget) {
                clickEvent.currentTarget.style.color = '#00a1d6';
                clickEvent.currentTarget.style.borderBottom = '2px solid #00a1d6';
            }
            if (tabName === 'favorites') {
                showFavorites(1);
            }
        }
    </script>
</body>
</html>