<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理员登录</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .login-container {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 400px;
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-header h1 {
            color: #00a1d6;
            margin: 0;
            font-size: 28px;
        }
        .login-header p {
            color: #666;
            margin-top: 10px;
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
        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            box-sizing: border-box;
        }
        .form-group input:focus {
            outline: none;
            border-color: #00a1d6;
        }
        .error-message {
            color: #ff4444;
            margin-bottom: 20px;
            padding: 10px;
            background-color: #ffeeee;
            border-radius: 4px;
            display: none;
        }
        .login-btn {
            width: 100%;
            padding: 12px;
            background-color: #00a1d6;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .login-btn:hover {
            background-color: #0090b8;
        }
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        .back-link a {
            color: #00a1d6;
            text-decoration: none;
        }
        .back-link a:hover {
            text-decoration: underline;
        }
        .remember-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .remember-me {
            display: flex;
            align-items: center;
        }
        .remember-me input {
            margin-right: 8px;
            width: auto;
        }
        .remember-me label {
            color: #666;
            font-size: 14px;
            font-weight: normal;
            margin-bottom: 0;
        }
        .status-message {
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
            display: none;
        }
        .status-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .status-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .loading {
            text-align: center;
            color: #666;
            margin-top: 10px;
            display: none;
        }
    </style>
</head>
<body>
<div class="login-container">
    <div class="login-header">
        <h1>管理员登录</h1>
        <p>请输入您的管理员账号和密码</p>
    </div>
    <%-- 状态信息展示区域 --%>
    <div id="statusMessage" class="status-message"></div>
    <div class="error-message" id="errorMessage">
        ${error}
    </div>
    <form id="loginForm" action="${pageContext.request.contextPath}/admin/login" method="post">
        <div class="form-group">
            <label for="username">用户名：</label>
            <input type="text" id="username" name="username" required placeholder="请输入用户名">
        </div>
        <div class="form-group">
            <label for="password">密码：</label>
            <input type="password" id="password" name="password" required placeholder="请输入密码">
        </div>
        <%-- 记住我选项区域 --%>
        <div class="remember-options">
            <div class="remember-me">
                <input type="checkbox" id="rememberMe" name="rememberMe" value="true">
                <label for="rememberMe">记住我（7天内自动登录）</label>
            </div>
        </div>
        <button type="submit" class="login-btn">登录</button>
    </form>
    <div class="loading" id="loadingDiv">正在自动登录中...</div>
    <c:if test="${not empty admin}">
        <div class="back-link">
            <a href="${pageContext.request.contextPath}/admin/logout">退出登录</a> |
            <a href="${pageContext.request.contextPath}/">返回首页</a>
        </div>
    </c:if>
    <c:if test="${empty admin}">
        <div class="back-link">
            <a href="${pageContext.request.contextPath}/">返回首页</a>
        </div>
    </c:if>
</div>
<script>
    // ---------- 缓存管理工具函数 ----------
    function generateToken() {
        return btoa(Date.now() + Math.random().toString(36).substr(2, 9));
    }
    // 缓存管理员登录信息（用户名、加密密码、令牌、过期时间）
    function cacheAdminInfo() {
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value.trim();
        if (username && password) {
            const token = generateToken();
            localStorage.setItem('adminUsername', username);
            localStorage.setItem('adminEncryptedPassword', btoa(password));
            localStorage.setItem('adminRememberToken', token);
            localStorage.setItem('adminLoginTime', new Date().getTime());
            // 7天后过期
            const expireTime = new Date().getTime() + 7 * 24 * 60 * 60 * 1000;
            localStorage.setItem('adminLoginExpire', expireTime);
        }
    }
    // 清除所有管理员登录缓存
    function clearAdminCache() {
        localStorage.removeItem('adminUsername');
        localStorage.removeItem('adminEncryptedPassword');
        localStorage.removeItem('adminRememberToken');
        localStorage.removeItem('adminLoginTime');
        localStorage.removeItem('adminLoginExpire');
    }
    // 显示状态消息（自动登录/手动登录过程中的提示）
    function showStatusMessage(message, type) {
        const statusDiv = document.getElementById('statusMessage');
        statusDiv.textContent = message;
        statusDiv.className = 'status-message status-' + type;
        statusDiv.style.display = 'block';
        // 3秒后自动隐藏
        setTimeout(() => {
            statusDiv.style.display = 'none';
        }, 3000);
    }
    // 校验缓存的登录信息，并尝试自动登录
    function validateCachedAdminLogin() {
        const adminUsername = localStorage.getItem('adminUsername');
        const encryptedPassword = localStorage.getItem('adminEncryptedPassword');
        const rememberToken = localStorage.getItem('adminRememberToken');
        const loginExpire = localStorage.getItem('adminLoginExpire');
        // 检查必要数据是否存在
        if (!adminUsername || !encryptedPassword || !rememberToken) {
            return false;
        }
        // 检查是否过期
        if (loginExpire && new Date().getTime() > parseInt(loginExpire)) {
            clearAdminCache();
            showStatusMessage('登录信息已过期，请重新登录', 'error');
            return false;
        }
        // 显示自动登录进度
        document.getElementById('loadingDiv').style.display = 'block';
        showStatusMessage('正在自动登录...', 'success');
        // 发送验证请求到后端专用接口
        fetch('${pageContext.request.contextPath}/admin/validateCachedLogin', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                username: adminUsername,
                encryptedPassword: encryptedPassword,
                rememberToken: rememberToken
            })
        }).then(response => response.json()).then(data => {
                document.getElementById('loadingDiv').style.display = 'none';
                if (data.success) {
                    showStatusMessage('自动登录成功！正在跳转...', 'success');
                    // 自动登录成功，跳转到后台管理首页
                    setTimeout(() => {
                        window.location.href = '${pageContext.request.contextPath}/admin/dashboard';
                    }, 1000);
                } else {
                    // 自动登录失败，清除缓存的无效信息
                    clearAdminCache();
                    showStatusMessage(data.message || '自动登录失败，请手动登录', 'error');
                }
            }).catch(error => {
                console.error('自动登录验证请求失败:', error);
                document.getElementById('loadingDiv').style.display = 'none';
                clearAdminCache();
                showStatusMessage('自动登录服务异常，请手动登录', 'error');
            });
        return true;
    }
    // 检查是否已有缓存信息，若有则尝试自动登录
    function checkAutoLogin() {
        const adminUsername = localStorage.getItem('adminUsername');
        const encryptedPassword = localStorage.getItem('adminEncryptedPassword');
        const rememberToken = localStorage.getItem('adminRememberToken');
        const loginExpire = localStorage.getItem('adminLoginExpire');
        if (adminUsername && encryptedPassword && rememberToken && loginExpire) {
            // 未过期才进行自动验证
            if (new Date().getTime() <= parseInt(loginExpire)) {
                validateCachedAdminLogin();
            } else {
                // 过期则清除缓存
                clearAdminCache();
            }
        }
    }
    // ---------- 页面事件绑定 ----------
    document.addEventListener('DOMContentLoaded', function() {
        // 检查是否自动登录
        checkAutoLogin();
        const rememberCheckbox = document.getElementById('rememberMe');
        if (rememberCheckbox) {
            rememberCheckbox.addEventListener('change', function() {
                if (this.checked) {
                    const username = document.getElementById('username').value.trim();
                    const password = document.getElementById('password').value.trim();
                    if (username && password) {
                        cacheAdminInfo();
                        showStatusMessage('已缓存登录信息，7天内将自动登录', 'success');
                    } else {
                        // 用户名或密码为空时即使勾选也不缓存，并提示
                        showStatusMessage('请先填写用户名和密码后再勾选“记住我”', 'error');
                        this.checked = false;
                    }
                } else {
                    clearAdminCache();
                    showStatusMessage('已清除登录缓存', 'success');
                }
            });
        }
        const loginForm = document.getElementById('loginForm');
        if (loginForm) {
            loginForm.addEventListener('submit', function(e) {
                const rememberMe = document.getElementById('rememberMe').checked;
                if (rememberMe) {
                    cacheAdminInfo();
                    showStatusMessage('已选择记住我，7天内将自动登录', 'success');
                } else {
                    clearAdminCache();
                    // showStatusMessage('已清除登录缓存', 'success');
                }
            });
        }
        const serverErrorMsg = document.getElementById('errorMessage');
        if (serverErrorMsg && serverErrorMsg.innerText.trim() !== '') {
            serverErrorMsg.style.display = 'block';
            // 3秒后自动隐藏服务器错误提示
            setTimeout(() => {
                serverErrorMsg.style.display = 'none';
            }, 5000);
        }
    });
</script>
</body>
</html>