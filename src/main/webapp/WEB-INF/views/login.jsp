<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
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
            width: 400px;
        }
        .login-title {
            text-align: center;
            margin-bottom: 30px;
            color: #333;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #666;
        }
        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .form-group input:focus {
            outline: none;
            border-color: #00a1d6;
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
        }
        .login-btn:hover {
            background-color: #0088b3;
        }
        .register-link {
            text-align: center;
            margin-top: 20px;
        }
        .register-link a {
            color: #00a1d6;
            text-decoration: none;
        }
        .error-message {
            color: #ff6b6b;
            text-align: center;
            margin-bottom: 20px;
        }
        .remember-me {
            margin-bottom: 20px;
        }
        .remember-me input {
            margin-right: 8px;
        }
        .loading {
            text-align: center;
            color: #666;
            margin-top: 10px;
            display: none;
        }
        .remember-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .remember-text {
            color: #666;
            font-size: 14px;
        }
        .forgot-password {
            color: #00a1d6;
            text-decoration: none;
            font-size: 14px;
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
    </style>
</head>
<body>
    <div class="login-container">
        <h2 class="login-title">用户登录</h2>
        <%-- 显示状态信息 --%>
        <div id="statusMessage" class="status-message"></div>
          <%-- 显示错误信息 --%>
          <%
              String error = (String) request.getAttribute("error");
              if (error != null && !error.isEmpty()) {
          %>
          <div class="error-message">
              <%= error %>
          </div>
          <%
              }
          %>
        <form id="loginForm" action="/user/login" method="post">
            <div class="form-group">
                <label for="username">用户名:</label>
                <input type="text" id="username" name="username" required placeholder="请输入用户名">
            </div>
            <div class="form-group">
                <label for="password">密码:</label>
                <input type="password" id="password" name="password" required placeholder="请输入密码">
            </div>
            <div class="remember-options">
                <div class="remember-me">
                    <input type="checkbox" id="rememberMe" name="rememberMe" value="true">
                    <label for="rememberMe">记住我（7天内自动登录）</label>
                </div>
            </div>
            <button type="submit" class="login-btn">登录</button>
        </form>
        <div class="loading">正在自动登录中...</div>
        <div class="register-link">
            还没有账号？<a href="/user/register">立即注册</a>
        </div>
        <div class="register-link">
            <a href="/admin/login">管理员登录</a>
        </div>
    </div>
    <script>
        // 页面加载时检查是否有缓存的登录信息
        document.addEventListener('DOMContentLoaded', function() {
            checkAutoLogin();
            // 监听记住我复选框
            document.getElementById('rememberMe').addEventListener('change', function() {
                if (this.checked) {
                    // 如果勾选了记住我，缓存当前用户信息
                    cacheLoginInfo();
                } else {
                    // 如果取消勾选，清除缓存
                    clearLoginCache();
                }
            });
        });
       //检查是否有缓存的登录信息，自动登录
        function checkAutoLogin() {
            const cachedUser = localStorage.getItem('cachedUsername');
            const rememberToken = localStorage.getItem('rememberToken');
            if (cachedUser && rememberToken) {
                showStatusMessage('正在自动登录...', 'success');
                document.querySelector('.loading').style.display = 'block';
                validateCachedLogin(cachedUser, rememberToken);
            }
        }
        //缓存登录信息
        function cacheLoginInfo() {
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            if (username && password) {
                const token = generateToken();
                const encryptedPassword = username + "|" + btoa(password);
                localStorage.setItem('cachedUsername', username);
                localStorage.setItem('cachedPassword', encryptedPassword);  // 新格式
                localStorage.setItem('rememberToken', token);
                localStorage.setItem('loginTime', new Date().getTime());
                localStorage.setItem('loginExpire', new Date().getTime() + 7 * 24 * 60 * 60 * 1000);
            }
        }
        //清除登录缓存
        function clearLoginCache() {
            localStorage.removeItem('cachedUsername');
            localStorage.removeItem('cachedPassword');
            localStorage.removeItem('rememberToken');
            localStorage.removeItem('loginTime');
            localStorage.removeItem('loginExpire');
        }
        //验证缓存的登录信息
        function validateCachedLogin(cachedUser, rememberToken) {
            const username = localStorage.getItem('cachedUsername');
            const encryptedPassword = localStorage.getItem('cachedPassword');
            const loginExpire = localStorage.getItem('loginExpire');
            // 检查是否过期
            if (loginExpire && new Date().getTime() > parseInt(loginExpire)) {
                clearLoginCache();
                showStatusMessage('登录信息已过期，请重新登录', 'error');
                document.querySelector('.loading').style.display = 'none';
                return;
            }
            // 发送验证请求
            fetch('/user/validateCachedLogin', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    username: username,
                    encryptedPassword: encryptedPassword,
                    rememberToken: rememberToken
                })
            }).then(response => response.json()).then(data => {
                if (data.success) {
                    // 自动登录成功，跳转到首页
                    showStatusMessage('自动登录成功！', 'success');
                    setTimeout(() => {
                        window.location.href = '/';
                    }, 1000);
                } else {
                    clearLoginCache();
                    showStatusMessage(data.message || '自动登录失败，请手动登录', 'error');
                    document.querySelector('.loading').style.display = 'none';
                }
            }).catch(error => {
                console.error('验证登录失败:', error);
                clearLoginCache();
                showStatusMessage('验证失败，请手动登录', 'error');
                document.querySelector('.loading').style.display = 'none';
            });
        }
        //生成简单的令牌
        function generateToken() {
            return btoa(Date.now() + Math.random().toString(36).substr(2, 9));
        }
        //显示状态信息
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

        document.getElementById('loginForm').addEventListener('submit', function(e) {
            const rememberMe = document.getElementById('rememberMe').checked;
            if (rememberMe) {
                // 记住我选项
                cacheLoginInfo();
                showStatusMessage('已选择记住我，7天内将自动登录', 'success');
            } else {
                // 不记住我，清除之前的缓存
                clearLoginCache();
                showStatusMessage('已清除登录缓存', 'success');
            }
        });
    </script>
</body>
</html>