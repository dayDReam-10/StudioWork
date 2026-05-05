<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.assessment.www.po.User" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    User admin = (User) session.getAttribute("user");
    String adminUsername = (admin != null && admin.getUsername() != null) ? admin.getUsername() : "管理员";
    String adminId = (admin != null) ? String.valueOf(admin.getId()) : "0";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>当前咨询用户 - 管理后台</title>
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
            max-width: 1400px;
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
        .section-title {
            color: #333;
            margin-bottom: 20px;
            margin-top: 30px;
            font-size: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .section-title::before {
            content: '';
            width: 4px;
            height: 20px;
            background-color: #00a1d6;
            border-radius: 2px;
        }
        .users-list {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            padding: 20px;
        }
        .user-item {
            display: flex;
            align-items: center;
            padding: 15px;
            border-bottom: 1px solid #eee;
            transition: background-color 0.3s;
            cursor: pointer;
        }
        .user-item:hover {
            background-color: #f8f9fa;
        }
        .user-item:last-child {
            border-bottom: none;
        }
        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background-color: #00a1d6;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            margin-right: 15px;
        }
        .user-info {
            flex: 1;
        }
        .user-name-row {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .user-name {
            font-weight: bold;
            font-size: 16px;
        }
        .user-preview {
            margin-top: 4px;
            font-size: 12px;
            color: #00a1d6;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .message-badge {
            min-width: 20px;
            height: 20px;
            padding: 0 6px;
            border-radius: 999px;
            background: #dc3545;
            color: #fff;
            font-size: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .user-time {
            color: #666;
            font-size: 12px;
            margin-top: 4px;
        }
        .user-status {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            background-color: #e9ecef;
            color: #495057;
        }
        .user-status.online {
            background-color: #28a745;
            color: white;
        }
        .user-status.offline {
            background-color: #6c757d;
            color: white;
        }
        .chat-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            z-index: 1000;
        }
        .chat-container {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 600px;
            height: 500px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            display: flex;
            flex-direction: column;
        }
        .chat-header {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: #00a1d6;
            color: white;
            border-radius: 8px 8px 0 0;
        }
        .chat-title {
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .close-btn {
            background: none;
            border: none;
            color: white;
            font-size: 20px;
            cursor: pointer;
        }
        .chat-body {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        .message {
            max-width: 70%;
            padding: 10px 15px;
            border-radius: 18px;
            word-wrap: break-word;
        }
        .message.self {
            background-color: #00a1d6;
            color: white;
            align-self: flex-end;
        }
        .message.other {
            background-color: #e9ecef;
            color: #333;
            align-self: flex-start;
        }
        .message-time {
            font-size: 11px;
            color: #666;
            margin-top: 5px;
            text-align: right;
        }
        .message.self .message-time {
            color: rgba(255,255,255,0.85);
        }
        .message.other .message-time {
            text-align: left;
        }
        .chat-input {
            padding: 15px;
            border-top: 1px solid #eee;
            display: flex;
            gap: 10px;
        }
        .chat-input input {
            flex: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            outline: none;
        }
        .chat-input button {
            padding: 10px 20px;
            background-color: #00a1d6;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .loading, .error {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        .error {
            color: #dc3545;
        }
        .btn-group {
            margin-top: 20px;
            display: flex;
            gap: 10px;
        }
        .btn {
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .btn-primary {
            background: #00a1d6;
            color: white;
        }
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
    </style>
</head>
<body>
    <div class="header">
        <div style="font-size: 24px; font-weight: bold;">管理后台</div>
        <div class="nav-links">
            <span class="welcome-admin">管理员: <%= adminUsername %></span>
            <a href="${pageContext.request.contextPath}/adminticket/exhibitions">漫展后台</a>
            <a href="${pageContext.request.contextPath}/">返回首页</a>
            <a href="${pageContext.request.contextPath}/logout">退出登录</a>
        </div>
    </div>
    <div class="main-container">
        <div class="sidebar">
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/admin/adminindex">数据概览</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/users">用户管理</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/videos">视频管理</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/pending">待审核视频</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/banned">被封用户</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/reports">举报管理</a></li>
                <hr style="margin: 15px 0; border-color: #eee;">
                <li><a href="${pageContext.request.contextPath}/adminticket/exhibitions">漫展管理</a></li>
                <li><a href="${pageContext.request.contextPath}/adminticket/orders">订单管理</a></li>
                <li><a href="${pageContext.request.contextPath}/adminticket/statistics">漫展数据统计</a></li>
                <li><a href="${pageContext.request.contextPath}/adminticket/consultingUsers" class="active">当前咨询用户</a></li>
            </ul>
        </div>
        <div class="content">
            <div class="btn-group">
                <button class="btn btn-primary" id="refreshBtn">刷新列表</button>
            </div>
            <h2>当前咨询用户</h2>
            <div class="users-list" id="usersList">
                <div class="loading">加载中...</div>
            </div>
        </div>
    </div>
    <!-- 聊天对话框 -->
    <div class="chat-modal" id="chatModal">
        <div class="chat-container">
            <div class="chat-header">
                <div class="chat-title">
                    <span id="chatUserAvatar">咨询人:</span>
                    <span id="chatUserName">用户名称</span>
                </div>
                <button class="close-btn" id="closeChat">&times;</button>
            </div>
            <div class="chat-body" id="chatBody">
                <!-- 消息将在这里动态添加 -->
            </div>
            <div class="chat-input">
                <input type="text" id="messageInput" placeholder="输入消息..."  maxlength="500"/>
                <button id="sendBtn">发送</button>
            </div>
        </div>
    </div>
    <script>
        const contextPath = '${pageContext.request.contextPath}';
        let currentUserId = null;
        let currentUserName = '';
        let adminWebSocket = null;
        const adminId = '<%= adminId %>';
        const userNameCache = {};
        const userMessagePreview = {};
        const userUnreadCount = {};
        // ========== WebSocket 连接（管理员身份） ==========
        function initAdminWebSocket() {
            const wsUrl = "ws://" + window.location.host + contextPath + "/websocket/consultation?userId=" + adminId + "&role=admin";
            adminWebSocket = new WebSocket(wsUrl);
            adminWebSocket.onopen = function() {
                console.log("管理员WebSocket连接已建立");
                var identityMsg = {
                    type: "admin_identity",
                    from: adminId,
                    role: "admin"
                };
                adminWebSocket.send(JSON.stringify(identityMsg));
            };
            adminWebSocket.onmessage = function(event) {
                var message = JSON.parse(event.data);
                console.log("收到WebSocket消息:", message);
                // 处理不同类型的消息
                if (message.type === "user") {
                    // 用户发来的新消息
                    onUserMessageReceived(message);
                } else if (message.type === "confirm") {
                    console.log("回复确认:", message.content);
                } else if (message.type === "error") {
                    console.error("WebSocket错误:", message.content);
                    alert("错误：" + message.content);
                }
            };
            adminWebSocket.onclose = function() {
                console.log("管理员WebSocket连接已关闭，5秒后重连...");
                setTimeout(initAdminWebSocket, 5000);
            };
            adminWebSocket.onerror = function(error) {
                console.error("WebSocket错误:", error);
            };
        }
        // 收到用户消息时的处理
        function onUserMessageReceived(message) {
            if (!message || !message.from) {
                return;
            }
            if (message.username) {
                userNameCache[message.from] = message.username;
            }
            if (message.content) {
                userMessagePreview[message.from] = message.content;
            }
            if (currentUserId && message.from === currentUserId) {
                userUnreadCount[message.from] = 0;
                appendMessageToChat({
                    sender: "user",
                    content: message.content,
                    time: new Date().toLocaleTimeString()
                });
            } else {
                userUnreadCount[message.from] = (userUnreadCount[message.from] || 0) + 1;
                loadUsersList();
                if (!currentUserId) {
                    userUnreadCount[message.from] = 0;
                    openChat(message.from, userNameCache[message.from] || message.username || ('用户' + message.from));
                }
            }
        }
        // 将消息追加到聊天窗口
        function appendMessageToChat(msg) {
            const chatBody = document.getElementById('chatBody');
            if (!chatBody) return;
            const errorfirst = document.getElementById('errorfirst');
            if (errorfirst){
             document.getElementById('errorfirst').style.display = 'none';
            }
            const messageDiv = document.createElement('div');
            const isSelf = (msg.sender === 'admin');
            messageDiv.className = 'message ' + (isSelf ? 'self' : 'other');
            const timeStr = msg.time || new Date().toLocaleTimeString();
            messageDiv.innerHTML = '<div>' + escapeHtml(msg.content) + '</div>' +
                                   '<div class="message-time">' + escapeHtml(timeStr) + '</div>';
            chatBody.appendChild(messageDiv);
            chatBody.scrollTop = chatBody.scrollHeight;
        }

        function escapeHtml(str) {
            if (!str) return '';
            return str.replace(/[&<>]/g, function(m) {
                if (m === '&') return '&amp;';
                if (m === '<') return '&lt;';
                if (m === '>') return '&gt;';
                return m;
            });
        }
        // ========== 用户列表加载==========
        function loadUsersList() {
            document.getElementById('usersList').innerHTML = '<div class="loading">加载中...</div>';
            fetch(contextPath + '/ticket/consultation/users', {
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            }).then(response => response.json()).then(data => {
                if (data.success) {
                    renderUsersList(data.data);
                } else {
                    throw new Error(data.message || '加载失败');
                }
            }).catch(err => {
                console.error(err);
                document.getElementById('usersList').innerHTML = '<div class="error">加载失败：' + err.message + '</div>';
            });
        }
        function renderUsersList(users) {
            const usersList = document.getElementById('usersList');
            if (!users || users.length === 0) {
                usersList.innerHTML = '<div class="error">暂无咨询用户</div>';
                return;
            }
            let html = '';
            for (var i = 0; i < users.length; i++) {
                var user = users[i];
                var displayName = user.username || userNameCache[user.userId] || ('用户' + user.userId);
                var avatarText = displayName ? displayName.charAt(0).toUpperCase() : 'U';
                var lastTime = user.time ? new Date(user.time).toLocaleString() : '未知';
                var onlineClass = (user.isOnline ? 'online' : 'offline');
                var onlineText = (user.isOnline ? '在线' : '离线');
                var preview = userMessagePreview[user.userId] || '';
                var previewText = preview ? (preview.length > 48 ? preview.substring(0, 48) + '...' : preview) : '';
                var unreadCount = userUnreadCount[user.userId] || 0;
                html += '<div class="user-item" data-user-id="' + user.userId + '" data-user-name="' + escapeHtml(displayName) + '">' +
                        '<div class="user-avatar">' + escapeHtml(avatarText) + '</div>' +
                        '<div class="user-info">' +
                            '<div class="user-name-row">' +
                                '<div class="user-name">' + escapeHtml(displayName) + '</div>' +
                                (unreadCount > 0 ? '<span class="message-badge">' + unreadCount + '</span>' : '') +
                            '</div>' +
                            (previewText ? '<div class="user-preview">最新消息：' + escapeHtml(previewText) + '</div>' : '') +
                            '<div class="user-time">最后咨询时间：' + escapeHtml(lastTime) + '</div>' +
                        '</div>' +
                        '<div class="user-status ' + onlineClass + '">' + onlineText + '</div>' +
                        '</div>';
            }
            usersList.innerHTML = html;
            // 绑定点击事件
            var items = document.querySelectorAll('.user-item');
            for (var j = 0; j < items.length; j++) {
                items[j].addEventListener('click', function() {
                    var userId = this.getAttribute('data-user-id');
                    var userName = this.getAttribute('data-user-name');
                    openChat(userId, userName);
                });
            }
        }
        // ========== 聊天历史加载==========
        function loadChatHistory() {
            const chatBody = document.getElementById('chatBody');
            chatBody.innerHTML = '<div class="loading">加载消息中...</div>';
            fetch(contextPath + '/ticket/consultation/history?userId=' + currentUserId, {
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            }).then(response => response.json()).then(data => {
                if (data.success) {
                    renderChatMessages(data.data);
                } else {
                    throw new Error(data.message || '加载失败');
                }
            }).catch(err => {
                console.error(err);
                chatBody.innerHTML = '<div class="error">加载消息失败：' + err.message + '</div>';
            });
        }
        function renderChatMessages(messages) {
            const chatBody = document.getElementById('chatBody');
            chatBody.innerHTML = '';
            if (!messages || messages.length === 0) {
                chatBody.innerHTML = '<div class="error" id="errorfirst">暂无聊天记录</div>';
                return;
            }
            for (var i = 0; i < messages.length; i++) {
                var msg = messages[i];
                var isSelf = (msg.sender === 'admin');
                var messageDiv = document.createElement('div');
                messageDiv.className = 'message ' + (isSelf ? 'self' : 'other');
                var timeStr = msg.formattedTime || (msg.time ? new Date(msg.time).toLocaleTimeString() : '');
                messageDiv.innerHTML = '<div>' + escapeHtml(msg.content) + '</div>' +
                                       '<div class="message-time">' + escapeHtml(timeStr) + '</div>';
                chatBody.appendChild(messageDiv);
            }
            chatBody.scrollTop = chatBody.scrollHeight;
        }
        //打开聊天窗口
        function openChat(userId, userName) {
            currentUserId = userId;
            currentUserName = userName;
            userUnreadCount[userId] = 0;
            document.getElementById('chatUserName').textContent = userName;
            document.getElementById('chatModal').style.display = 'block';
            loadChatHistory();
        }
        function closeChat() {
            document.getElementById('chatModal').style.display = 'none';
            currentUserId = null;
            currentUserName = '';
            document.getElementById('chatBody').innerHTML = '';
        }
        //发送回复通过 WebSocket
        function sendReply() {
            var input = document.getElementById('messageInput');
            var content = input.value.trim();
            if (!content || !currentUserId) return;
            if (!adminWebSocket || adminWebSocket.readyState !== WebSocket.OPEN) {
                alert("WebSocket连接未就绪，请稍后再试");
                return;
            }
            var replyMsg = {
                type: "admin",
                from: adminId,
                to: currentUserId,
                content: content,
                timestamp: Date.now()
            };
            adminWebSocket.send(JSON.stringify(replyMsg));
            appendMessageToChat({
                sender: "admin",
                content: content,
                time: new Date().toLocaleTimeString()
            });
            input.value = '';
        }
        // ========== 页面初始化 ==========
        document.addEventListener('DOMContentLoaded', function() {
            initAdminWebSocket();      // 建立WebSocket连接
            loadUsersList();           // 加载用户列表
            document.getElementById('refreshBtn').addEventListener('click', loadUsersList);
            document.getElementById('closeChat').addEventListener('click', closeChat);
            document.getElementById('sendBtn').addEventListener('click', sendReply);
            document.getElementById('messageInput').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') sendReply();
            });
        });
    </script>
</body>
</html>