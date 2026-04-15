<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${targetUser.username} 的主页 - LiBiLiBi</title>
    <style>
        <style>
            :root {
                --ink: #1d2838;
                --sub: #5e697a;
                --sub2: #909bad;
                --line: rgba(30, 43, 61, 0.1);
                --paper: rgba(255, 252, 246, 0.86);
                --panel: rgba(255, 255, 255, 0.9);
                --gold: #b18135;
                --teal: #2d6c8b;
                --teal-dark: #23566f;
                --danger: #c44762;
                --radius-xl: 26px;
                --radius-lg: 18px;
                --radius-md: 12px;
                --radius-pill: 999px;
                --shadow-soft: 0 10px 30px rgba(24, 36, 56, 0.08);
                --shadow-panel: 0 16px 34px rgba(16, 26, 40, 0.12);
                --shadow-hover: 0 18px 34px rgba(18, 28, 45, 0.14);
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
                min-height: 76px;
                margin: 16px auto 0;
                padding: 12px 30px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 16px;
                border-radius: 24px;
                background: var(--paper);
                border: 1px solid rgba(255, 255, 255, 0.72);
                backdrop-filter: blur(14px) saturate(130%);
                -webkit-backdrop-filter: blur(14px) saturate(130%);
                box-shadow: var(--shadow-soft);
                position: sticky;
                top: 12px;
                z-index: 100;
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
                white-space: nowrap;
            }

            .nav {
                display: flex;
                align-items: center;
                gap: 8px;
                flex-wrap: wrap;
                justify-content: flex-end;
            }

            .nav a {
                text-decoration: none;
                color: var(--sub);
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

            .main {
                width: min(1480px, calc(100% - 56px));
                margin: 28px auto 38px;
                display: grid;
                grid-template-columns: 330px minmax(0, 1fr);
                gap: 20px;
                align-items: start;
            }

            .card {
                background: var(--panel);
                border-radius: var(--radius-xl);
                border: 1px solid rgba(255, 255, 255, 0.84);
                box-shadow: var(--shadow-panel);
            }

            .profile-panel {
                position: -webkit-sticky;
                position: sticky;
                top: 102px;
                overflow: hidden;
            }

            .profile-banner {
                height: 108px;
                position: relative;
                background: linear-gradient(130deg, rgba(177, 129, 53, 0.22) 0%, rgba(45, 108, 139, 0.2) 100%);
                border-bottom: 1px solid rgba(31, 42, 55, 0.08);
            }

            .profile-banner::before {
                content: "";
                position: absolute;
                right: -50px;
                top: -40px;
                width: 150px;
                height: 150px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(255, 255, 255, 0.44) 0%, rgba(255, 255, 255, 0) 72%);
            }

            .profile-body {
                padding: 0 20px 20px;
            }

            .avatar-wrap {
                margin-top: -52px;
                text-align: center;
            }

            .avatar {
                width: 104px;
                height: 104px;
                border-radius: 50%;
                object-fit: cover;
                margin: 0 auto;
                display: block;
                background: #e9edf1;
                border: 4px solid rgba(255, 255, 255, 0.95);
                box-shadow: 0 12px 22px rgba(22, 35, 50, 0.2);
            }

            .name {
                text-align: center;
                font-size: 26px;
                font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
                margin: 12px 0 4px;
                line-height: 1.25;
            }

            .user-badge {
                margin: 0;
                text-align: center;
                font-size: 12px;
                letter-spacing: 0.8px;
                text-transform: uppercase;
                color: var(--teal);
                font-weight: 700;
            }

            .sign {
                text-align: center;
                color: var(--sub2);
                font-size: 13px;
                margin: 10px 0 16px;
                line-height: 1.6;
                min-height: 20px;
            }

            .stat-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 10px;
                margin-bottom: 14px;
            }

            .stat-item {
                text-align: center;
                background: rgba(45, 108, 139, 0.08);
                border: 1px solid rgba(45, 108, 139, 0.14);
                border-radius: 12px;
                padding: 10px 6px 8px;
            }

            .stat-item strong {
                display: block;
                color: var(--teal-dark);
                font-size: 20px;
                font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
            }

            .stat-item span {
                color: var(--sub2);
                font-size: 12px;
            }

            .btn {
                width: 100%;
                height: 40px;
                border: none;
                border-radius: var(--radius-md);
                cursor: pointer;
                font-weight: 700;
                transition: all 0.2s ease;
            }

            .btn.follow {
                color: #fff;
                background: linear-gradient(120deg, var(--teal), #3a86a9);
                box-shadow: 0 10px 20px rgba(45, 108, 139, 0.24);
            }

            .btn.follow:hover { transform: translateY(-1px); }

            .btn.unfollow {
                background: rgba(31, 42, 55, 0.08);
                color: var(--sub);
            }

            .btn.unfollow:hover { background: rgba(31, 42, 55, 0.12); }

            .profile-tip {
                margin: 12px 0 0;
                font-size: 12px;
                line-height: 1.6;
                color: var(--sub2);
                padding: 10px 12px;
                border-radius: 12px;
                background: rgba(255, 255, 255, 0.75);
                border: 1px solid var(--line);
            }

            .content {
                padding: 20px;
                min-height: 420px;
            }

            .videos-head {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 12px;
                margin-bottom: 14px;
                flex-wrap: wrap;
            }

            .title {
                margin: 0;
                font-size: 30px;
                font-family: "Noto Serif SC", "Source Han Serif SC", "STSong", serif;
            }

            .count-chip {
                color: var(--sub);
                font-size: 13px;
                font-weight: 700;
                border-radius: var(--radius-pill);
                padding: 8px 12px;
                border: 1px solid rgba(31, 42, 55, 0.1);
                background: rgba(255, 255, 255, 0.82);
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

            .video-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                gap: 18px;
            }

            .video-card {
                text-decoration: none;
                color: inherit;
                background: rgba(255, 255, 255, 0.86);
                border: 1px solid rgba(31, 42, 55, 0.08);
                border-radius: var(--radius-lg);
                overflow: hidden;
                box-shadow: 0 10px 24px rgba(20, 30, 44, 0.08);
                transition: transform 0.24s ease, box-shadow 0.24s ease;
                display: flex;
                flex-direction: column;
            }

            .video-card:hover {
                transform: translateY(-6px);
                box-shadow: var(--shadow-hover);
            }

            .cover {
                width: calc(100% - 16px);
                margin: 8px 8px 0;
                border-radius: 12px;
                aspect-ratio: 16 / 9;
                object-fit: cover;
                background: #eef1f4;
                transition: transform 0.3s ease;
            }

            .video-card:hover .cover { transform: scale(1.03); }

            .info { padding: 12px; }

            .vtitle {
                font-size: 15px;
                font-weight: 700;
                min-height: 42px;
                margin-bottom: 8px;
                line-height: 1.5;
                overflow: hidden;
                display: -webkit-box;
                -webkit-box-orient: vertical;
                -webkit-line-clamp: 2;
            }

            .meta {
                color: var(--sub2);
                font-size: 12px;
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }

            .meta span {
                background: rgba(45, 108, 139, 0.08);
                border-radius: var(--radius-pill);
                padding: 4px 8px;
                color: var(--sub);
            }

            .empty {
                text-align: center;
                color: var(--sub2);
                padding: 46px 12px;
                border: 1px dashed rgba(177, 129, 53, 0.3);
                border-radius: var(--radius-lg);
                background: rgba(255, 255, 255, 0.9);
                font-size: 14px;
            }

            .modal-mask {
                position: fixed;
                inset: 0;
                background: rgba(12, 19, 30, 0.45);
                display: none;
                align-items: center;
                justify-content: center;
                z-index: 1000;
                padding: 16px;
            }

            .modal-mask.show { display: flex; }

            .modal-card {
                width: min(380px, 100%);
                background: rgba(255, 255, 255, 0.96);
                border-radius: 14px;
                box-shadow: 0 20px 44px rgba(8, 14, 24, 0.24);
                padding: 16px;
                border: 1px solid rgba(255, 255, 255, 0.84);
            }

            .modal-title { margin: 0 0 8px; font-size: 18px; }
            .modal-msg { margin: 0 0 12px; color: var(--sub); font-size: 14px; line-height: 1.6; }
            .modal-actions { display: flex; justify-content: flex-end; gap: 8px; }

            .modal-btn {
                border: none;
                height: 34px;
                padding: 0 14px;
                border-radius: 8px;
                cursor: pointer;
                font-weight: 700;
            }

            .modal-btn.cancel { background: rgba(31, 42, 55, 0.08); color: var(--sub); }
            .modal-btn.ok { background: linear-gradient(120deg, var(--teal), #3a86a9); color: #fff; }

            .toast {
                position: fixed;
                left: 50%;
                bottom: 28px;
                transform: translateX(-50%) translateY(20px);
                padding: 10px 14px;
                background: rgba(24, 25, 28, 0.92);
                color: #fff;
                border-radius: 8px;
                font-size: 14px;
                opacity: 0;
                pointer-events: none;
                transition: all .2s ease;
                z-index: 1100;
            }

            .toast.show { opacity: 1; transform: translateX(-50%) translateY(0); }
            .toast.err { background: rgba(196, 71, 98, 0.95); }

            @media (max-width: 1040px) {
                .header {
                    width: calc(100% - 28px);
                    padding: 14px 16px;
                    flex-wrap: wrap;
                    gap: 10px;
                }

                .main {
                    width: calc(100% - 24px);
                    grid-template-columns: 1fr;
                    margin: 22px auto 30px;
                }

                .profile-panel {
                    position: static;
                    top: auto;
                }
            }

            @media (max-width: 700px) {
                .video-grid {
                    grid-template-columns: 1fr;
                }

                .title {
                    font-size: 26px;
                }
            }
        </style>
                position: static;
                top: auto;
            }
        }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<header class="header">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>
    <nav class="nav">
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/video/search">视频</a>
        <c:if test="${not empty sessionScope.user}">
            <a href="${pageContext.request.contextPath}/user/profile">个人中心</a>
        </c:if>
    </nav>
</header>

<main class="main">
    <aside class="card profile-panel">
        <div class="profile-banner"></div>
        <div class="profile-body">
            <div class="avatar-wrap">
                <img class="avatar" src="${not empty targetUser.avatarUrl ? targetUser.avatarUrl : pageContext.request.contextPath.concat('/static/images/avatar/default_avatar.png')}" alt="avatar">
            </div>
            <p class="name">${targetUser.username}</p>
            <p class="user-badge">创作者主页</p>
            <p class="sign">${not empty targetUser.signature ? targetUser.signature : '这个人很懒，什么都没写'}</p>

            <div class="stat-grid">
                <div class="stat-item"><strong>${targetUser.followerCount}</strong><span>粉丝</span></div>
                <div class="stat-item"><strong>${targetUser.followingCount}</strong><span>关注</span></div>
                <div class="stat-item"><strong>${fn:length(userVideos)}</strong><span>视频</span></div>
            </div>

            <c:if test="${!isOwnProfile}">
                <c:choose>
                    <c:when test="${isFollowing}">
                        <button class="btn unfollow" onclick="unfollowUser(${targetUser.id})">已关注，点此取消</button>
                    </c:when>
                    <c:otherwise>
                        <button class="btn follow" onclick="followUser(${targetUser.id})">关注 TA</button>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <c:if test="${isOwnProfile}">
                <button class="btn unfollow" onclick="location.href='${pageContext.request.contextPath}/user/profile'">编辑个人资料</button>
            </c:if>

            <p class="profile-tip">喜欢 TA 的内容就点个关注，后续更新会更容易看到。</p>
        </div>
    </aside>

    <section class="card content">
        <div class="videos-head">
            <h2 class="title">${targetUser.username} 的视频</h2>
            <span class="count-chip">共 ${fn:length(userVideos)} 条</span>
        </div>

        <c:if test="${param.error == '1'}">
            <div class="msg error">操作失败，请稍后重试。</div>
        </c:if>

        <c:if test="${empty userVideos}">
            <div class="empty">TA 还没有发布视频。</div>
        </c:if>

        <c:if test="${not empty userVideos}">
            <div class="video-grid">
                <c:forEach var="video" items="${userVideos}">
                    <c:set var="coverUrl" value="${video.coverUrl}" />
                    <c:choose>
                        <c:when test="${empty coverUrl}">
                            <c:set var="coverUrl" value="${pageContext.request.contextPath.concat('/static/images/default_cover.png')}" />
                        </c:when>
                        <c:when test="${fn:startsWith(coverUrl, 'http://') or fn:startsWith(coverUrl, 'https://') or fn:startsWith(coverUrl, 'data:')}">
                        </c:when>
                        <c:when test="${fn:startsWith(coverUrl, '/')}">
                            <c:set var="coverUrl" value="${pageContext.request.contextPath.concat(coverUrl)}" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="coverUrl" value="${pageContext.request.contextPath.concat('/').concat(coverUrl)}" />
                        </c:otherwise>
                    </c:choose>
                    <a class="video-card" href="${pageContext.request.contextPath}/video/detail?id=${video.id}">
                        <img class="cover" src="${coverUrl}" alt="cover" onerror="this.src='${pageContext.request.contextPath}/static/images/default_cover.png'">
                        <div class="info">
                            <div class="vtitle">${video.title}</div>
                            <div class="meta">
                                <span>播放 ${video.viewCount}</span>
                                <span>点赞 ${video.likeCount}</span>
                            </div>
                        </div>
                    </a>
                </c:forEach>
            </div>
        </c:if>
    </section>
</main>

<div id="uiModalMask" class="modal-mask" aria-hidden="true">
    <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="uiModalTitle">
        <h3 id="uiModalTitle" class="modal-title">请确认</h3>
        <p id="uiModalMsg" class="modal-msg"></p>
        <div class="modal-actions">
            <button id="uiModalCancel" class="modal-btn cancel" type="button">取消</button>
            <button id="uiModalOk" class="modal-btn ok" type="button">确定</button>
        </div>
    </div>
</div>
<div id="uiToast" class="toast"></div>

<script>
    var ui = (function () {
        var modalMask = document.getElementById("uiModalMask");
        var modalMsg = document.getElementById("uiModalMsg");
        var modalCancel = document.getElementById("uiModalCancel");
        var modalOk = document.getElementById("uiModalOk");
        var toast = document.getElementById("uiToast");
        var okHandler = null;
        var toastTimer = null;

        function closeModal() {
            modalMask.classList.remove("show");
            modalMask.setAttribute("aria-hidden", "true");
            okHandler = null;
        }

        modalOk.addEventListener("click", function () {
            if (okHandler) okHandler();
            closeModal();
        });
        modalCancel.addEventListener("click", closeModal);
        modalMask.addEventListener("click", function (e) {
            if (e.target === modalMask) closeModal();
        });

        return {
            confirm: function (message, onOk) {
                modalMsg.textContent = message;
                okHandler = onOk || null;
                modalMask.classList.add("show");
                modalMask.setAttribute("aria-hidden", "false");
            },
            toast: function (message, isErr) {
                toast.textContent = message || "操作完成";
                toast.classList.toggle("err", !!isErr);
                toast.classList.add("show");
                if (toastTimer) clearTimeout(toastTimer);
                toastTimer = setTimeout(function () {
                    toast.classList.remove("show");
                }, 1400);
            }
        };
    })();

    var followBusy = false;

    function sendFollowAction(path, userId) {
        if (followBusy) return;
        followBusy = true;
        fetch("${pageContext.request.contextPath}" + path, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "targetUserId=" + encodeURIComponent(userId)
        }).then(function (resp) {
            if (resp.redirected && resp.url) {
                window.location.href = resp.url;
                return;
            }
            location.reload();
        }).catch(function () {
            ui.toast("请求失败，请稍后重试", true);
            followBusy = false;
        });
    }

    function followUser(userId) {
        ui.toast("正在关注...");
        sendFollowAction("/user/follow", userId);
    }

    function unfollowUser(userId) {
        ui.confirm("确定取消关注该用户吗？", function () {
            ui.toast("正在取消关注...");
            sendFollowAction("/user/unfollow", userId);
        });
    }
</script>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
