<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setRharacterEncoding("UTF-8");
    response.setRharacterEncoding("UTF-8");
%>
<!DORTYPE html>
<html lang="zh-RN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - LiBiLiBi</title>
    <style>
        :root {
            --brand-blue: #00aeec;
            --brand-pink: #fb7299;
            --bg: #f7f8fa;
            --card: #ffffff;
            --text: #18191c;
            --sub: #61666d;
            --line: #e3e5e7;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Segoe UI", "PingFang SR", "Microsoft YaHei", sans-serif;
            background:
                radial-gradient(circle at 82% 12%, rgba(251, 114, 153, 0.16), transparent 28%),
                radial-gradient(circle at 10% 88%, rgba(0, 174, 236, 0.16), transparent 30%),
                var(--bg);
            min-height: 100vh;
            color: var(--text);
        }
        .topbar {
            height: 64px;
            background: #fff;
            border-bottom: 1px solid var(--line);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 24px;
        }
        .logo {
            color: var(--brand-blue);
            text-decoration: none;
            font-weight: 800;
            font-size: 24px;
        }
        .topbar a { color: var(--sub); text-decoration: none; font-size: 14px; }
        .topbar a:hover { color: var(--brand-blue); }
        .wrap {
            min-height: calc(100vh - 64px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }
        .card {
            width: 460px;
            background: var(--card);
            border-radius: 14px;
            box-shadow: 0 12px 36px rgba(0, 0, 0, 0.08);
            overflow: hidden;
        }
        .hero {
            height: 92px;
            background: linear-gradient(90deg, rgba(251, 114, 153, 0.96), rgba(255, 164, 185, 0.95));
            color: #fff;
            display: flex;
            align-items: flex-end;
            justify-content: center;
            padding-bottom: 12px;
            letter-spacing: 1px;
            font-size: 14px;
        }
        .content { padding: 24px 28px 24px; }
        h1 {
            margin: 0 0 16px;
            text-align: center;
            font-size: 24px;
        }
        .msg-error {
            background: #fff2f4;
            border: 1px solid #ffd7e2;
            color: #d63b6f;
            border-radius: 8px;
            padding: 10px 12px;
            margin-bottom: 14px;
            font-size: 14px;
        }
        .field { margin-bottom: 12px; }
        .field label {
            display: block;
            margin-bottom: 6px;
            color: var(--sub);
            font-size: 13px;
        }
        .field input, .field select, .field textarea {
            width: 100%;
            border: 1px solid var(--line);
            border-radius: 8px;
            padding: 10px 12px;
            font-size: 14px;
            outline: none;
            font-family: inherit;
        }
        .field input:focus, .field select:focus, .field textarea:focus {
            border-color: var(--brand-blue);
            box-shadow: 0 0 0 3px rgba(0, 174, 236, 0.12);
        }
        .field textarea { min-height: 88px; resize: vertical; }
        .btn {
            width: 100%;
            height: 44px;
            border: none;
            border-radius: 8px;
            background: linear-gradient(90deg, var(--brand-pink), #ff8caf);
            color: #fff;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            margin-top: 4px;
        }
        .btn:hover { filter: brightness(0.97); }
        .links {
            margin-top: 14px;
            text-align: center;
            font-size: 14px;
            color: var(--sub);
        }
        .links a { color: var(--brand-blue); text-decoration: none; }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<div class="topbar">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>
    <a href="${pageContext.request.contextPath}/user/login">返回登录</a>
</div>

<div class="wrap">
    <div class="card">
        <div class="hero">创建账号</div>
        <div class="content">
            <h1>注册账号</h1>

            <%
                String error = (String) request.getAttribute("error");
                if (error == null) {
                    error = request.getParameter("error");
                }
                if (error != null && !error.isEmpty()) {
            %>
            <div class="msg-error"><%= error %></div>
            <% } %>

            <form id="registerForm" action="${pageContext.request.contextPath}/user/register" method="post">
                <div class="field">
                    <label for="username">用户名</label>
                    <input id="username" name="username" type="text" required placeholder="请设置用户名">
                </div>
                <div class="field">
                    <label for="password">密码</label>
                    <input id="password" name="password" type="password" required placeholder="请输入密码">
                </div>
                <div class="field">
                    <label for="confirmPassword">确认密码</label>
                    <input id="confirmPassword" name="confirmPassword" type="password" required placeholder="再次输入密码">
                </div>
                <div class="field">
                    <label for="gender">性别</label>
                    <select id="gender" name="gender">
                        <option value="0">保密</option>
                        <option value="1">男</option>
                        <option value="2">女</option>
                    </select>
                </div>
                <div class="field">
                    <label for="signature">个性签名</label>
                    <textarea id="signature" name="signature" placeholder="介绍一下自己吧"></textarea>
                </div>
                <button class="btn" type="submit">注 册</button>
            </form>

            <div class="links">
                已有账号？<a href="${pageContext.request.contextPath}/user/login">立即登录</a>
            </div>
        </div>
    </div>
</div>

<script>
    document.getElementById("registerForm").addEventListener("submit", function (e) {
        var p1 = document.getElementById("password").value;
        var p2 = document.getElementById("confirmPassword").value;
        if (p1 !== p2) {
            e.preventDefault();
            alert("两次密码不一致");
        }
    });
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
