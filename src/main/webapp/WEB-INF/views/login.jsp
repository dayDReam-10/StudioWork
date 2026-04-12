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
    <title>登录 - LiBiLiBi</title>
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
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background:
                radial-gradient(circle at 18% 15%, rgba(0, 174, 236, 0.15), transparent 25%),
                radial-gradient(circle at 85% 80%, rgba(251, 114, 153, 0.18), transparent 30%),
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
            letter-spacing: 0.5px;
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
            width: 420px;
            background: var(--card);
            border-radius: 14px;
            box-shadow: 0 12px 36px rgba(0, 0, 0, 0.08);
            overflow: hidden;
        }
        .hero {
            height: 92px;
            background:
                linear-gradient(90deg, rgba(0, 174, 236, 0.95), rgba(55, 208, 255, 0.95));
            display: flex;
            align-items: flex-end;
            justify-content: center;
            color: #fff;
            font-size: 14px;
            padding-bottom: 12px;
            letter-spacing: 1px;
        }
        .content { padding: 28px 28px 24px; }
        h1 {
            margin: 0 0 20px;
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
        .msg-success {
            background: #ecfbff;
            border: 1px solid #bcefff;
            color: #0077a5;
            border-radius: 8px;
            padding: 10px 12px;
            margin-bottom: 14px;
            font-size: 14px;
        }
        .field { margin-bottom: 14px; }
        .field label {
            display: block;
            margin-bottom: 6px;
            color: var(--sub);
            font-size: 13px;
        }
        .field input {
            width: 100%;
            height: 44px;
            border: 1px solid var(--line);
            border-radius: 8px;
            padding: 0 12px;
            font-size: 14px;
            outline: none;
        }
        .field input:focus {
            border-color: var(--brand-blue);
            box-shadow: 0 0 0 3px rgba(0, 174, 236, 0.12);
        }
        .btn {
            width: 100%;
            height: 44px;
            border: none;
            border-radius: 8px;
            background: linear-gradient(90deg, var(--brand-blue), #22c7ff);
            color: #fff;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
        }
        .btn:hover { filter: brightness(0.97); }
        .links {
            margin-top: 14px;
            text-align: center;
            font-size: 14px;
            color: var(--sub);
        }
        .links a { color: var(--brand-blue); text-decoration: none; }
        .links a:hover { text-decoration: underline; }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<div class="topbar">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>
    <a href="${pageContext.request.contextPath}/admin/login">管理员登录</a>
</div>

<div class="wrap">
    <div class="card">
        <div class="hero">欢迎回来</div>
        <div class="content">
            <h1>密码登录</h1>

            <%
                String error = (String) request.getAttribute("error");
                String success = request.getParameter("success");
                if (error != null && !error.isEmpty()) {
            %>
            <div class="msg-error"><%= error %></div>
            <% } %>

            <% if ("1".equals(success)) { %>
            <div class="msg-success">注册成功，请登录。</div>
            <% } %>

            <form action="${pageContext.request.contextPath}/user/login" method="post">
                <div class="field">
                    <label for="username">用户名</label>
                    <input id="username" name="username" type="text" placeholder="请输入用户名" required>
                </div>
                <div class="field">
                    <label for="password">密码</label>
                    <input id="password" name="password" type="password" placeholder="请输入密码" required>
                </div>
                <button class="btn" type="submit">登 录</button>
            </form>

            <div class="links">
                还没有账号？<a href="${pageContext.request.contextPath}/user/register">立即注册</a>
            </div>
        </div>
    </div>
</div>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
