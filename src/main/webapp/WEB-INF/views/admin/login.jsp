<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - LiBiLiBi</title>
    <style>
        :root { --blue:#00aeec; --pink:#fb7299; --line:#e3e5e7; --bg:#f5f7fa; --sub:#61666d; }
        * { box-sizing:border-box; }
        body {
            margin:0;
            min-height:100vh;
            display:flex;
            align-items:center;
            justify-content:center;
            background:
              radial-gradient(circle at 15% 10%, rgba(0,174,236,.15), transparent 30%),
              radial-gradient(circle at 85% 90%, rgba(251,114,153,.15), transparent 35%),
              var(--bg);
            font-family:"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif;
        }
        .card {
            width:min(420px, 92vw);
            background:#fff;
            border-radius:14px;
            box-shadow:0 16px 40px rgba(0,0,0,.1);
            overflow:hidden;
        }
        .hero {
            background:linear-gradient(90deg,var(--blue),#2ec8ff);
            color:#fff;
            padding:16px 20px;
            font-weight:700;
            letter-spacing:.5px;
        }
        .body { padding:22px; }
        h1 { margin:0 0 8px; font-size:24px; }
        .sub { color:var(--sub); font-size:13px; margin-bottom:14px; }
        .error {
            display:${not empty error ? 'block' : 'none'};
            background:#fff2f4;
            border:1px solid #ffd7e2;
            color:#d63b6f;
            padding:10px 12px;
            border-radius:8px;
            margin-bottom:12px;
            font-size:14px;
        }
        .field { margin-bottom:12px; }
        .field label { display:block; font-size:13px; color:var(--sub); margin-bottom:6px; }
        .field input {
            width:100%;
            height:42px;
            border:1px solid var(--line);
            border-radius:8px;
            padding:0 12px;
            outline:none;
            font-size:14px;
        }
        .field input:focus { border-color:var(--blue); box-shadow:0 0 0 3px rgba(0,174,236,.12); }
        .btn {
            width:100%;
            height:42px;
            border:none;
            border-radius:8px;
            background:linear-gradient(90deg,var(--blue),#2ec8ff);
            color:#fff;
            font-weight:700;
            cursor:pointer;
        }
        .links { margin-top:12px; text-align:center; font-size:13px; }
        .links a { color:var(--blue); text-decoration:none; margin:0 8px; }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<div class="card">
    <div class="hero">LiBiLiBi ADMIN</div>
    <div class="body">
        <h1>管理员登录</h1>
        <div class="sub">请输入管理员账号和密码</div>

        <div class="error">${error}</div>

        <form action="${pageContext.request.contextPath}/admin/login" method="post">
            <div class="field">
                <label for="username">用户名</label>
                <input id="username" name="username" type="text" required placeholder="admin">
            </div>
            <div class="field">
                <label for="password">密码</label>
                <input id="password" name="password" type="password" required placeholder="password">
            </div>
            <button class="btn" type="submit">登录后台</button>
        </form>

        <div class="links">
            <a href="${pageContext.request.contextPath}/">返回首页</a>
            <a href="${pageContext.request.contextPath}/user/login">用户登录</a>
        </div>
    </div>
</div>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
