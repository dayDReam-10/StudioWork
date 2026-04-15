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
        :root {
            --ink: #1f2a37;
            --sub: #5f6b7a;
            --sub2: #8a94a3;
            --line: rgba(31, 42, 55, 0.1);
            --paper: rgba(255, 252, 246, 0.86);
            --panel: rgba(255, 255, 255, 0.9);
            --gold: #b18135;
            --teal: #2d6c8b;
            --danger: #c44762;
            --radius-xl: 24px;
            --radius-lg: 18px;
            --radius-md: 12px;
            --radius-pill: 999px;
            --shadow-soft: 0 10px 30px rgba(24, 36, 56, 0.08);
            --shadow-panel: 0 16px 34px rgba(16, 26, 40, 0.12);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: "HarmonyOS Sans SC", "MiSans", "PingFang SC", "Microsoft YaHei", sans-serif;
            color: var(--ink);
            background: transparent;
        }

        .header {
            width: min(1480px, calc(100% - 48px));
            height: 76px;
            margin: 16px auto 0;
            padding: 0 30px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            position: sticky;
            top: 12px;
            z-index: 100;
            border-radius: 24px;
            background: var(--paper);
            border: 1px solid rgba(255, 255, 255, 0.72);
            backdrop-filter: blur(14px) saturate(130%);
            -webkit-backdrop-filter: blur(14px) saturate(130%);
            box-shadow: var(--shadow-soft);
        }

        .logo {
            text-decoration: none;
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
            font-size: 30px;
            font-weight: 700;
            letter-spacing: 0.4px;
            background: linear-gradient(120deg, var(--gold) 0%, #c89d4f 45%, var(--teal) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .nav {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .nav a {
            color: var(--sub);
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            padding: 8px 12px;
            border-radius: var(--radius-pill);
            transition: all 0.2s ease;
        }

        .nav a:hover {
            color: var(--teal);
            background: rgba(45, 108, 139, 0.09);
        }

        .nav .upload {
            color: #fff;
            font-weight: 700;
            background: linear-gradient(120deg, var(--gold) 0%, #c89d4f 100%);
            box-shadow: 0 10px 20px rgba(177, 129, 53, 0.3);
            padding: 9px 16px;
        }

        .wrap {
            width: min(1480px, calc(100% - 56px));
            margin: 28px auto 40px;
            display: grid;
            grid-template-columns: 300px minmax(0, 1fr);
            gap: 18px;
            align-items: start;
        }

        .card {
            background: var(--panel);
            border-radius: var(--radius-xl);
            border: 1px solid rgba(255, 255, 255, 0.84);
            box-shadow: var(--shadow-panel);
        }

        .left {
            padding: 0;
            height: fit-content;
            position: fixed;
            top: 104px;
            left: max(28px, calc((100vw - 1480px) / 2));
            width: 300px;
            max-height: calc(100vh - 120px);
            overflow: auto;
            align-self: start;
            z-index: 20;
        }

        .profile-cover {
            height: 96px;
            background: linear-gradient(130deg, rgba(177, 129, 53, 0.2) 0%, rgba(45, 108, 139, 0.18) 100%);
            border-bottom: 1px solid rgba(31, 42, 55, 0.08);
            position: relative;
        }

        .profile-cover::after {
            content: "";
            position: absolute;
            right: -40px;
            top: -35px;
            width: 130px;
            height: 130px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.45) 0%, rgba(255, 255, 255, 0) 70%);
        }

        .profile-body {
            padding: 0 20px 20px;
        }

        .avatar {
            width: 96px;
            height: 96px;
            border-radius: 50%;
            margin: -48px auto 0;
            display: block;
            object-fit: cover;
            background: #e9edf1;
            border: 4px solid rgba(255, 255, 255, 0.92);
            box-shadow: 0 10px 18px rgba(17, 31, 49, 0.18);
        }

        .name {
            margin: 12px 0 2px;
            text-align: center;
            font-size: 22px;
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
        }

        .role-tag {
            margin: 0;
            text-align: center;
            font-size: 12px;
            color: var(--teal);
            font-weight: 700;
            letter-spacing: 0.6px;
            text-transform: uppercase;
        }

        .sign {
            margin: 8px 0 0;
            text-align: center;
            color: var(--sub2);
            font-size: 13px;
            min-height: 20px;
            line-height: 1.6;
        }

        .stat {
            margin-top: 16px;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            text-align: center;
        }

        .stat div {
            background: rgba(45, 108, 139, 0.08);
            border: 1px solid rgba(45, 108, 139, 0.12);
            border-radius: 12px;
            padding: 10px 6px 8px;
        }

        .stat strong {
            display: block;
            color: var(--teal);
            font-size: 20px;
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
        }

        .stat span { color: var(--sub2); font-size: 12px; }

        .menu {
            margin-top: 16px;
            border-top: 1px solid var(--line);
            padding-top: 12px;
        }

        .menu-title {
            margin: 0 0 8px;
            font-size: 12px;
            color: var(--sub2);
            letter-spacing: 0.8px;
            text-transform: uppercase;
            font-weight: 700;
        }

        .menu a {
            display: flex;
            align-items: center;
            justify-content: space-between;
            text-decoration: none;
            color: var(--sub);
            border-radius: 10px;
            padding: 10px 10px;
            margin-bottom: 6px;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.2s ease;
        }

        .menu-left {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            min-width: 0;
        }

        .menu-icon {
            width: 28px;
            height: 28px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 700;
            color: var(--teal);
            background: rgba(45, 108, 139, 0.12);
            border: 1px solid rgba(45, 108, 139, 0.16);
            flex: 0 0 auto;
        }

        .menu-text {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .menu-arrow {
            color: var(--sub2);
            font-size: 12px;
        }

        .menu a:hover {
            background: rgba(45, 108, 139, 0.09);
            color: var(--teal);
        }

        .right {
            grid-column: 2;
            padding: 22px;
        }

        .title {
            margin: 0 0 18px;
            font-size: 28px;
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
        }

        .msg {
            border-radius: 10px;
            padding: 10px 12px;
            margin-bottom: 12px;
            font-size: 14px;
        }

        .msg.error {
            background: rgba(196, 71, 98, 0.1);
            border: 1px solid rgba(196, 71, 98, 0.28);
            color: var(--danger);
        }

        .msg.success {
            background: rgba(45, 108, 139, 0.12);
            border: 1px solid rgba(45, 108, 139, 0.26);
            color: var(--teal);
        }

        .block {
            border: 1px solid var(--line);
            border-radius: var(--radius-lg);
            background: rgba(255, 255, 255, 0.76);
            padding: 14px;
            margin-bottom: 12px;
        }

        .block h3 {
            margin: 0 0 12px;
            font-size: 18px;
            font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
        }

        .field { margin-bottom: 10px; }

        .field label {
            display: block;
            margin-bottom: 6px;
            color: var(--sub);
            font-size: 13px;
            font-weight: 600;
        }

        .field input,
        .field select,
        .field textarea {
            width: 100%;
            border: 1px solid var(--line);
            border-radius: var(--radius-md);
            padding: 10px 12px;
            font-size: 14px;
            font-family: inherit;
            outline: none;
            background: #fff;
            transition: all 0.2s ease;
        }

        .field textarea {
            min-height: 96px;
            resize: vertical;
        }

        .field input:focus,
        .field select:focus,
        .field textarea:focus {
            border-color: rgba(45, 108, 139, 0.45);
            box-shadow: 0 0 0 4px rgba(45, 108, 139, 0.13);
        }

        .btn {
            height: 40px;
            padding: 0 16px;
            border: none;
            border-radius: var(--radius-md);
            cursor: pointer;
            color: #fff;
            background: linear-gradient(120deg, var(--teal), #3a86a9);
            font-weight: 700;
        }

        .btn.pink {
            background: linear-gradient(120deg, var(--gold), #c89d4f);
        }

        @media (max-width: 980px) {
            .header {
                width: calc(100% - 28px);
                height: auto;
                padding: 14px 16px;
                flex-wrap: wrap;
                gap: 10px;
            }

            .wrap {
                width: calc(100% - 24px);
                grid-template-columns: 1fr;
                margin: 22px auto 32px;
            }

            .left {
                position: static;
                top: auto;
                left: auto;
                width: auto;
                max-height: none;
                overflow: visible;
                z-index: auto;
            }

            .right {
                grid-column: auto;
            }

            .profile-cover {
                height: 74px;
            }

            .avatar {
                width: 82px;
                height: 82px;
                margin-top: -40px;
            }

            .name {
                font-size: 20px;
            }
        }
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
        <div class="profile-cover"></div>
        <div class="profile-body">
            <img class="avatar" src="<%= user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty() ? user.getAvatarUrl() : (request.getContextPath() + "/static/images/avatar/default_avatar.png") %>" alt="avatar">
            <p class="name"><%= user.getUsername() %></p>
            <p class="role-tag"><%= user.getRole() != null ? user.getRole() : "user" %></p>
            <p class="sign"><%= user.getSignature() != null ? user.getSignature() : "这个人很懒，什么都没写" %></p>

            <div class="stat">
                <div><strong><%= user.getFollowingCount() != null ? user.getFollowingCount() : 0 %></strong><span>关注</span></div>
                <div><strong><%= user.getFollowerCount() != null ? user.getFollowerCount() : 0 %></strong><span>粉丝</span></div>
                <div><strong><%= user.getCoinCount() != null ? user.getCoinCount() : 0 %></strong><span>硬币</span></div>
            </div>

            <div class="menu">
                <p class="menu-title">快捷入口</p>
                <a href="${pageContext.request.contextPath}/video/myvideos">
                    <span class="menu-left"><span class="menu-icon">MV</span><span class="menu-text">我的投稿</span></span>
                    <span class="menu-arrow">&gt;</span>
                </a>
                <a href="${pageContext.request.contextPath}/user/favorites">
                    <span class="menu-left"><span class="menu-icon">FV</span><span class="menu-text">我的收藏</span></span>
                    <span class="menu-arrow">&gt;</span>
                </a>
                <a href="${pageContext.request.contextPath}/user/likes">
                    <span class="menu-left"><span class="menu-icon">LK</span><span class="menu-text">我的点赞</span></span>
                    <span class="menu-arrow">&gt;</span>
                </a>
                <a href="${pageContext.request.contextPath}/user/history">
                    <span class="menu-left"><span class="menu-icon">HS</span><span class="menu-text">观看历史</span></span>
                    <span class="menu-arrow">&gt;</span>
                </a>
                <a href="#" id="checkinBtn">
                    <span class="menu-left"><span class="menu-icon">CI</span><span class="menu-text">每日签到</span></span>
                    <span class="menu-arrow">&gt;</span>
                </a>
                <a href="${pageContext.request.contextPath}/video/search">
                    <span class="menu-left"><span class="menu-icon">EX</span><span class="menu-text">浏览视频</span></span>
                    <span class="menu-arrow">&gt;</span>
                </a>
            </div>
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
