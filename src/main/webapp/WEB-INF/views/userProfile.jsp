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
        :root { --blue:#00aeec; --pink:#fb7299; --line:#e3e5e7; --bg:#f6f7f8; --sub:#61666d; }
        * { box-sizing: border-box; }
        body { margin:0; font-family:"Segoe UI",sans-serif; color:#18191c; background:var(--bg); }
        .header { height:68px; background:#fff; border-bottom:1px solid var(--line); display:flex; align-items:center; justify-content:space-between; padding:0 24px; }
        .logo { color:var(--blue); text-decoration:none; font-size:24px; font-weight:800; }
        .nav a { text-decoration:none; color:var(--sub); margin-left:12px; font-size:14px; }
        .main { width:min(1200px,100%); margin:20px auto; padding:0 20px; display:grid; grid-template-columns:300px 1fr; gap:18px; }
        .card { background:#fff; border-radius:12px; box-shadow:0 6px 18px rgba(0,0,0,.05); }
        .side { padding:18px; height:fit-content; }
        .avatar { width:100px; height:100px; border-radius:50%; object-fit:cover; margin:0 auto; display:block; background:#e9edf1; }
        .name { text-align:center; font-size:22px; font-weight:700; margin:10px 0 4px; }
        .sign { text-align:center; color:#9499a0; font-size:13px; margin:0 0 14px; }
        .stat { display:grid; grid-template-columns:repeat(3,1fr); text-align:center; gap:8px; margin-bottom:14px; }
        .stat strong { display:block; color:var(--blue); font-size:18px; }
        .stat span { color:#9499a0; font-size:12px; }
        .btn { width:100%; height:40px; border:none; border-radius:8px; cursor:pointer; font-weight:700; }
        .btn.follow { background:var(--pink); color:#fff; }
        .btn.unfollow { background:#eef1f4; color:#333; }
        .content { padding:18px; }
        .title { margin:0 0 12px; font-size:22px; }
        .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(240px,1fr)); gap:16px; }
        .video { text-decoration:none; color:inherit; background:#fff; border:1px solid var(--line); border-radius:10px; overflow:hidden; }
        .cover { width:100%; aspect-ratio:16/9; object-fit:cover; background:#eef1f4; }
        .info { padding:10px 12px; }
        .vtitle { font-size:15px; min-height:40px; margin-bottom:8px; overflow:hidden; }
        .meta { color:#9499a0; font-size:13px; }
        .empty { text-align:center; color:#9499a0; padding:40px 10px; border:1px dashed var(--line); border-radius:10px; background:#fff; }
        .msg { border-radius:8px; padding:10px 12px; margin-bottom:12px; font-size:14px; }
        .msg.error { background:#fff2f4; border:1px solid #ffd7e2; color:#d63b6f; }
        .modal-mask {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.45);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            padding: 16px;
        }
        .modal-mask.show { display: flex; }
        .modal-card {
            width: min(380px, 100%);
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 12px 36px rgba(0, 0, 0, 0.2);
            padding: 16px;
        }
        .modal-title { margin: 0 0 8px; font-size: 18px; }
        .modal-msg { margin: 0 0 12px; color: #61666d; font-size: 14px; line-height: 1.6; }
        .modal-actions { display: flex; justify-content: flex-end; gap: 8px; }
        .modal-btn {
            border: none;
            height: 34px;
            padding: 0 14px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 700;
        }
        .modal-btn.cancel { background:#eef1f4; color:#333; }
        .modal-btn.ok { background:var(--blue); color:#fff; }
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
        .toast.err { background: rgba(214, 59, 111, 0.95); }
        @media (max-width:900px) { .main{grid-template-columns:1fr; padding:0 12px;} .header{padding:0 12px;} }
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
    <aside class="card side">
        <img class="avatar" src="${not empty targetUser.avatarUrl ? targetUser.avatarUrl : pageContext.request.contextPath.concat('/static/images/avatar/default_avatar.png')}" alt="avatar">
        <p class="name">${targetUser.username}</p>
        <p class="sign">${not empty targetUser.signature ? targetUser.signature : '这个人很懒，什么都没写'}</p>

        <div class="stat">
            <div><strong>${targetUser.followerCount}</strong><span>粉丝</span></div>
            <div><strong>${targetUser.followingCount}</strong><span>关注</span></div>
            <div><strong>${userVideos.size()}</strong><span>视频</span></div>
        </div>

        <c:if test="${!isOwnProfile}">
            <c:choose>
                <c:when test="${isFollowing}">
                    <button class="btn unfollow" onclick="unfollowUser(${targetUser.id})">取消关注</button>
                </c:when>
                <c:otherwise>
                    <button class="btn follow" onclick="followUser(${targetUser.id})">关注</button>
                </c:otherwise>
            </c:choose>
        </c:if>

        <c:if test="${isOwnProfile}">
            <button class="btn unfollow" onclick="location.href='${pageContext.request.contextPath}/user/profile'">编辑资料</button>
        </c:if>
    </aside>

    <section class="card content">
        <h2 class="title">视频</h2>

        <c:if test="${param.error == '1'}">
            <div class="msg error">操作失败，请稍后重试。</div>
        </c:if>

        <c:if test="${empty userVideos}">
            <div class="empty">TA 还没有发布视频。</div>
        </c:if>

        <c:if test="${not empty userVideos}">
            <div class="grid">
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
                    <a class="video" href="${pageContext.request.contextPath}/video/detail?id=${video.id}">
                        <img class="cover" src="${coverUrl}" alt="cover" onerror="this.src='${pageContext.request.contextPath}/static/images/default_cover.png'">
                        <div class="info">
                            <div class="vtitle">${video.title}</div>
                            <div class="meta">播放 ${video.viewCount} | 点赞 ${video.likeCount}</div>
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
