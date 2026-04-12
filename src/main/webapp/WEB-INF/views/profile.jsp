<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.User" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人中心 - LiBiLiBi</title>
    <style>
        :root { --blue:#00aeec; --pink:#fb7299; --line:#e3e5e7; --bg:#f6f7f8; --sub:#61666d; }
        * { box-sizing: border-box; }
        body { margin:0; font-family:"Segoe UI",sans-serif; background:var(--bg); color:#18191c; }
        .header { height:68px; background:#fff; border-bottom:1px solid var(--line); display:flex; align-items:center; justify-content:space-between; padding:0 24px; position:sticky; top:0; z-index:100; }
        .logo { color:var(--blue); text-decoration:none; font-size:24px; font-weight:800; }
        .nav a { color:var(--sub); text-decoration:none; margin-left:12px; font-size:14px; }
        .nav .upload { background:var(--pink); color:#fff; padding:8px 12px; border-radius:8px; font-weight:700; }
        .wrap { width:min(1200px,100%); margin:22px auto; padding:0 20px; display:grid; grid-template-columns:300px 1fr; gap:18px; }
        .card { background:#fff; border-radius:12px; box-shadow:0 6px 18px rgba(0,0,0,.05); }
        .left { padding:18px; height:fit-content; }
        .avatar { width:84px; height:84px; border-radius:50%; margin:0 auto; display:block; object-fit:cover; background:#e9edf1; }
        .name { margin:10px 0 4px; text-align:center; font-size:20px; font-weight:700; }
        .sign { margin:0; text-align:center; color:#9499a0; font-size:13px; min-height:20px; }
        .stat { margin-top:14px; display:grid; grid-template-columns:repeat(3,1fr); gap:8px; text-align:center; }
        .stat strong { display:block; color:var(--blue); font-size:18px; }
        .stat span { color:#9499a0; font-size:12px; }
        .menu { margin-top:14px; border-top:1px solid var(--line); padding-top:10px; }
        .menu a { display:block; text-decoration:none; color:var(--sub); border-radius:8px; padding:10px; margin-bottom:6px; font-size:14px; }
        .menu a:hover { background:#edf9ff; color:var(--blue); }
        .right { padding:20px; }
        .title { margin:0 0 16px; font-size:22px; }
        .msg { border-radius:8px; padding:10px 12px; margin-bottom:12px; font-size:14px; }
        .msg.error { background:#fff2f4; border:1px solid #ffd7e2; color:#d63b6f; }
        .msg.success { background:#ecfbff; border:1px solid #bcefff; color:#0077a5; }
        .block { border:1px solid var(--line); border-radius:10px; padding:14px; margin-bottom:12px; }
        .block h3 { margin:0 0 12px; font-size:16px; }
        .field { margin-bottom:10px; }
        .field label { display:block; margin-bottom:6px; color:var(--sub); font-size:13px; }
        .field input,.field select,.field textarea { width:100%; border:1px solid var(--line); border-radius:8px; padding:10px 12px; font-size:14px; font-family:inherit; outline:none; }
        .field textarea { min-height:90px; resize:vertical; }
        .field input:focus,.field select:focus,.field textarea:focus { border-color:var(--blue); box-shadow:0 0 0 3px rgba(0,174,236,.12); }
        .btn { height:40px; padding:0 16px; border:none; border-radius:8px; cursor:pointer; color:#fff; background:var(--blue); font-weight:700; }
        .btn.pink { background:var(--pink); }
        @media (max-width:900px) { .wrap{grid-template-columns:1fr; padding:0 12px;} .header{padding:0 12px;} }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/user/login");
        return;
    }
%>
<header class="header">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>
    <nav class="nav">
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/video/myvideos">我的视频</a>
        <a href="${pageContext.request.contextPath}/video/upload" class="upload">上传</a>
        <% if ("admin".equals(user.getRole())) { %>
        <a href="${pageContext.request.contextPath}/admin/adminindex">管理后台</a>
        <% } %>
        <a href="${pageContext.request.contextPath}/user/logout">退出登录</a>
    </nav>
</header>

<main class="wrap">
    <aside class="card left">
        <img class="avatar" src="<%= user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty() ? user.getAvatarUrl() : (request.getContextPath() + "/static/images/avatar/default_avatar.png") %>" alt="avatar">
        <p class="name"><%= user.getUsername() %></p>
        <p class="sign"><%= user.getSignature() != null ? user.getSignature() : "这个人很懒，什么都没写" %></p>

        <div class="stat">
            <div><strong><%= user.getFollowingCount() != null ? user.getFollowingCount() : 0 %></strong><span>关注</span></div>
            <div><strong><%= user.getFollowerCount() != null ? user.getFollowerCount() : 0 %></strong><span>粉丝</span></div>
            <div><strong><%= user.getCoinCount() != null ? user.getCoinCount() : 0 %></strong><span>硬币</span></div>
        </div>

        <div class="menu">
            <a href="${pageContext.request.contextPath}/video/myvideos">我的投稿</a>
            <a href="${pageContext.request.contextPath}/user/favorites">我的收藏</a>
            <a href="${pageContext.request.contextPath}/user/history">观看历史</a>
            <a href="#" id="checkinBtn">每日签到</a>
            <a href="${pageContext.request.contextPath}/video/search">浏览视频</a>
        </div>
    </aside>

    <section class="card right">
        <h2 class="title">个人设置</h2>

        <%
            String err = (String) request.getAttribute("error");
            String succ = (String) request.getAttribute("success");
            if (err == null) err = request.getParameter("error");
            if (succ == null) succ = request.getParameter("success");
            if (err != null && !err.isEmpty()) {
        %>
        <div class="msg error"><%= err %></div>
        <% } %>
        <% if (succ != null && !succ.isEmpty()) { %>
        <div class="msg success"><%= succ %></div>
        <% } %>

        <div class="block">
            <h3>基础信息</h3>
            <form action="${pageContext.request.contextPath}/user/updateProfile" method="post">
                <div class="field">
                    <label>用户名</label>
                    <input type="text" value="<%= user.getUsername() %>" readonly>
                </div>
                <div class="field">
                    <label for="gender">性别</label>
                    <select id="gender" name="gender">
                        <option value="0" <%= user.getGender() != null && user.getGender() == 0 ? "selected" : "" %>>保密</option>
                        <option value="1" <%= user.getGender() != null && user.getGender() == 1 ? "selected" : "" %>>男</option>
                        <option value="2" <%= user.getGender() != null && user.getGender() == 2 ? "selected" : "" %>>女</option>
                    </select>
                </div>
                <div class="field">
                    <label for="signature">个性签名</label>
                    <textarea id="signature" name="signature"><%= user.getSignature() != null ? user.getSignature() : "" %></textarea>
                </div>
                <button class="btn" type="submit">保存资料</button>
            </form>
        </div>

        <div class="block">
            <h3>头像设置</h3>
            <form action="${pageContext.request.contextPath}/user/updateAvatar" method="post" enctype="multipart/form-data">
                <div class="field">
                    <label for="avatarFile">上传头像图片（推荐）</label>
                    <input id="avatarFile" name="avatarFile" type="file" accept="image/*">
                </div>
                <div class="field">
                    <label for="avatarUrl">头像链接（可选）</label>
                    <input id="avatarUrl" name="avatarUrl" type="text" value="<%= user.getAvatarUrl() != null ? user.getAvatarUrl() : "" %>">
                </div>
                <button class="btn pink" type="submit">更新头像</button>
            </form>
        </div>

        <div class="block">
            <h3>修改密码</h3>
            <form id="pwdForm" action="${pageContext.request.contextPath}/user/changePassword" method="post">
                <div class="field">
                    <label for="oldPassword">旧密码</label>
                    <input id="oldPassword" name="oldPassword" type="password" required>
                </div>
                <div class="field">
                    <label for="newPassword">新密码</label>
                    <input id="newPassword" name="newPassword" type="password" required>
                </div>
                <div class="field">
                    <label for="confirmPassword">确认新密码</label>
                    <input id="confirmPassword" type="password" required>
                </div>
                <button class="btn" type="submit">修改密码</button>
            </form>
        </div>
    </section>
</main>

<script>
    document.getElementById("pwdForm").addEventListener("submit", function (e) {
        var p1 = document.getElementById("newPassword").value;
        var p2 = document.getElementById("confirmPassword").value;
        if (p1 !== p2) {
            e.preventDefault();
            alert("两次密码不一致");
        }
    });

    document.getElementById("checkinBtn").addEventListener("click", function (e) {
        e.preventDefault();
        fetch("${pageContext.request.contextPath}/client/checkin", { method: "POST" })
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.success) {
                    alert("签到成功，获得 " + d.coinReward + " 枚硬币");
                    location.reload();
                } else {
                    alert(d.error || "签到失败或今日已签到");
                }
            })
            .catch(function () { alert("签到请求失败"); });
    });
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
