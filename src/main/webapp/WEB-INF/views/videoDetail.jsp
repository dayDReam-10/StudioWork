<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="com.assessment.www.po.ScreenComment" %>
<%@ page import="com.assessment.www.po.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>视频详情 - LiBiLiBi</title>
    <style>
        :root { --blue:#00aeec; --pink:#fb7299; --line:#e3e5e7; --bg:#f6f7f8; --sub:#61666d; }
        * { box-sizing: border-box; }
        body { margin:0; font-family:"Segoe UI",sans-serif; color:#18191c; background:var(--bg); }
        .header { height:68px; background:#fff; border-bottom:1px solid var(--line); display:flex; align-items:center; justify-content:space-between; padding:0 24px; position:sticky; top:0; z-index:100; }
        .logo { color:var(--blue); text-decoration:none; font-size:24px; font-weight:800; }
        .nav a { text-decoration:none; color:var(--sub); margin-left:12px; font-size:14px; }
        .nav .upload { background:var(--pink); color:#fff; padding:8px 12px; border-radius:8px; font-weight:700; }
        .main { width:min(1300px,100%); margin:20px auto; padding:0 20px; display:grid; grid-template-columns:1fr 340px; gap:18px; }
        .panel { background:#fff; border-radius:12px; box-shadow:0 6px 18px rgba(0,0,0,.05); }
        .video-panel { padding:16px; }
        .player { width:100%; aspect-ratio:16/9; border-radius:10px; background:#000; overflow:hidden; margin-bottom:14px; position:relative; }
        .player video { width:100%; height:100%; position:relative; z-index:1; }
        .danmu-layer { position:absolute; inset:0; pointer-events:none; overflow:hidden; z-index:2; }
        .danmu-item {
            position:absolute;
            left:0;
            white-space:nowrap;
            color:#fff;
            font-size:18px;
            font-weight:700;
            text-shadow:0 1px 2px rgba(0,0,0,.8), 0 0 4px rgba(0,0,0,.6);
            will-change: transform;
        }
        @keyframes danmu-move {
            from { transform:translateX(0); }
            to { transform:translateX(calc(-1 * var(--danmu-distance, 1200px))); }
        }
        .title { margin:0 0 8px; font-size:24px; }
        .desc { margin:0 0 10px; color:#61666d; line-height:1.6; white-space:pre-wrap; }
        .stats { display:flex; gap:14px; color:#9499a0; font-size:13px; margin-bottom:12px; flex-wrap:wrap; }
        .actions { display:flex; gap:8px; flex-wrap:wrap; }
        .btn { border:none; border-radius:8px; height:36px; padding:0 14px; cursor:pointer; font-weight:700; }
        .btn.blue { background:#ecfbff; color:#0077a5; }
        .btn.pink { background:#fff2f4; color:#d63b6f; }
        .btn.gray { background:#eef1f4; color:#333; }
        .btn.green { background:#eaf9ef; color:#207f49; }
        .danmu-input { display:flex; gap:8px; margin-top:12px; }
        .danmu-input input { flex:1; height:40px; border:1px solid var(--line); border-radius:8px; padding:0 10px; outline:none; }
        .danmu-input button { width:110px; border:none; border-radius:8px; background:#ff7a45; color:#fff; font-weight:700; cursor:pointer; }
        .danmu-tip { color:#9499a0; font-size:12px; margin-top:6px; }

        .side { padding:16px; }
        .author { display:flex; align-items:center; gap:10px; margin-bottom:12px; }
        .avatar { width:46px; height:46px; border-radius:50%; object-fit:cover; background:#e9edf1; }
        .author-name { font-size:16px; font-weight:700; margin:0; }
        .author-sub { font-size:12px; color:#9499a0; }
        .follow { width:100%; height:36px; border:none; border-radius:8px; background:var(--blue); color:#fff; font-weight:700; cursor:pointer; margin-bottom:12px; }
        .side-box { border:1px solid var(--line); border-radius:10px; padding:10px; color:#61666d; font-size:13px; }

        .comment-panel { margin-top:14px; padding:16px; }
        .comment-title { margin:0 0 10px; font-size:18px; }
        .comment-input { display:flex; gap:8px; margin-bottom:12px; }
        .comment-input input { flex:1; height:40px; border:1px solid var(--line); border-radius:8px; padding:0 10px; outline:none; }
        .comment-input button { width:110px; border:none; border-radius:8px; background:var(--blue); color:#fff; font-weight:700; cursor:pointer; }
        .comment-item { border-top:1px solid #f1f2f3; padding:12px 0; }
        .comment-user { font-size:14px; font-weight:700; margin-bottom:4px; }
        .comment-text { font-size:14px; line-height:1.6; margin-bottom:6px; white-space:pre-wrap; }
        .comment-time { font-size:12px; color:#9499a0; }
        .comment-actions { margin-top:6px; }
        .comment-actions button { border:none; border-radius:6px; background:#eef1f4; padding:4px 8px; font-size:12px; cursor:pointer; margin-right:6px; }
        .empty { color:#9499a0; font-size:14px; padding:16px 0; }
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
            width: min(420px, 100%);
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 12px 36px rgba(0, 0, 0, 0.2);
            padding: 16px;
        }
        .modal-title { margin: 0 0 8px; font-size: 18px; }
        .modal-msg { margin: 0 0 12px; color: #61666d; font-size: 14px; line-height: 1.6; white-space: pre-wrap; }
        .modal-input {
            width: 100%;
            height: 38px;
            border: 1px solid var(--line);
            border-radius: 8px;
            padding: 0 10px;
            outline: none;
            margin-bottom: 12px;
            font-size: 14px;
        }
        .modal-input:focus {
            border-color: var(--blue);
            box-shadow: 0 0 0 3px rgba(0, 174, 236, 0.12);
        }
        .modal-actions { display: flex; justify-content: flex-end; gap: 8px; }
        .modal-btn {
            border: none;
            height: 34px;
            padding: 0 14px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 700;
        }
        .modal-btn.cancel { background: #eef1f4; color: #333; }
        .modal-btn.ok { background: var(--blue); color: #fff; }
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
        .toast.show {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }
        .toast.err { background: rgba(214, 59, 111, 0.95); }
        @media (max-width:980px) {
            .main { grid-template-columns:1fr; padding:0 12px; }
            .header { padding:0 12px; }
        }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<%
    User currentUser = (User) session.getAttribute("user");
    Video video = (Video) request.getAttribute("video");
    Boolean hasLikedObj = (Boolean) request.getAttribute("hasLiked");
    Boolean hasFavoritedObj = (Boolean) request.getAttribute("hasFavorited");
    Boolean hasReportedObj = (Boolean) request.getAttribute("hasReported");
    boolean hasLiked = hasLikedObj != null && hasLikedObj;
    boolean hasFavorited = hasFavoritedObj != null && hasFavoritedObj;
    boolean hasReported = hasReportedObj != null && hasReportedObj;
    Integer commentCount = (Integer) request.getAttribute("commentCount");
    if (commentCount == null) commentCount = 0;
    List<ScreenComment> comments = (List<ScreenComment>) request.getAttribute("topLevelComments");
    List<ScreenComment> danmuComments = (List<ScreenComment>) request.getAttribute("danmuComments");
%>
<header class="header">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>
    <nav class="nav">
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/video/search">视频</a>
        <% if (currentUser != null) { %>
            <a href="${pageContext.request.contextPath}/user/profile"><%= currentUser.getUsername() %></a>
            <a href="${pageContext.request.contextPath}/video/upload" class="upload">上传</a>
            <a href="${pageContext.request.contextPath}/user/logout">退出登录</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/user/login">登录</a>
            <a href="${pageContext.request.contextPath}/user/register">注册</a>
        <% } %>
    </nav>
</header>

<% if (video == null) { %>
<main class="main">
    <section class="panel video-panel">
        <h2>视频不存在。</h2>
        <a href="${pageContext.request.contextPath}/" style="color:#00aeec;text-decoration:none;">返回首页</a>
    </section>
</main>
<% } else { %>
<main class="main">
    <section>
        <article class="panel video-panel">
            <div class="player">
                <video id="videoPlayer" controls autoplay>
                    <source src="<%= video.getVideoUrl() %>" type="video/mp4">
                </video>
                <div id="danmuLayer" class="danmu-layer" aria-hidden="true"></div>
            </div>
            <h1 class="title"><%= video.getTitle() %></h1>
            <p class="desc"><%= video.getDescription() != null ? video.getDescription() : "暂无简介" %></p>
            <div class="stats">
                <span>播放 <%= video.getViewCount() != null ? video.getViewCount() : 0 %></span>
                <span>点赞 <%= video.getLikeCount() != null ? video.getLikeCount() : 0 %></span>
                <span>硬币 <%= video.getCoinCount() != null ? video.getCoinCount() : 0 %></span>
                <span>收藏 <%= video.getFavCount() != null ? video.getFavCount() : 0 %></span>
            </div>
            <div class="actions">
                <button class="btn blue" onclick="toggleLike(<%= video.getId() %>, <%= hasLiked %>)"><%= hasLiked ? "取消点赞" : "点赞" %></button>
                <button class="btn pink" onclick="toggleFav(<%= video.getId() %>, <%= hasFavorited %>)"><%= hasFavorited ? "取消收藏" : "收藏" %></button>
                <button class="btn gray" onclick="coinVideo(<%= video.getId() %>)">投币</button>
                <button class="btn gray" onclick="downloadVideo(<%= video.getId() %>)">下载</button>
                <% if (!hasReported) { %>
                    <button class="btn green" onclick="reportVideo(<%= video.getId() %>)">举报</button>
                <% } else { %>
                    <button class="btn green" disabled>已举报</button>
                <% } %>
            </div>

            <% if (currentUser != null) { %>
            <div class="danmu-input">
                <input id="danmuInput" type="text" maxlength="300" placeholder="发一条弹幕（记录当前播放时间）...">
                <button onclick="sendDanmu(<%= video.getId() %>)">发弹幕</button>
            </div>
            <div class="danmu-tip">按视频当前进度发送，支持回车快捷发送。</div>
            <% } else { %>
            <div class="danmu-tip">登录后可发送弹幕。</div>
            <% } %>
        </article>

        <section class="panel comment-panel">
            <h2 class="comment-title">弹幕与评论（<%= commentCount %>）</h2>
            <% if (currentUser != null) { %>
            <div class="comment-input">
                <input id="commentInput" type="text" maxlength="300" placeholder="写下你的评论...">
                <button onclick="sendComment(<%= video.getId() %>)">发送</button>
            </div>
            <% } else { %>
            <div class="empty">请登录后评论。</div>
            <% } %>

            <%
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                if (comments != null && !comments.isEmpty()) {
                    for (ScreenComment c : comments) {
                        String userName = (c.getUser() != null && c.getUser().getUsername() != null) ? c.getUser().getUsername() : ("用户#" + c.getUserId());
            %>
            <div class="comment-item" id="comment-<%= c.getId() %>">
                <div class="comment-user"><%= userName %></div>
                <div class="comment-text"><%= c.getContent() %></div>
                <div class="comment-time"><%= c.getTimeCreate() != null ? sdf.format(c.getTimeCreate()) : "未知" %></div>
                <% if (currentUser != null) { %>
                <div class="comment-actions">
                    <button onclick="replyTo(<%= c.getId() %>)">回复</button>
                    <button onclick="deleteComment(<%= c.getId() %>)">删除</button>
                </div>
                <% } %>
            </div>
            <%      }
                } else {
            %>
            <div class="empty">暂无评论。</div>
            <% } %>
        </section>
    </section>

    <aside class="panel side">
        <div class="author">
            <img class="avatar" src="<%= (video.getAuthor() != null && video.getAuthor().getAvatarUrl() != null) ? video.getAuthor().getAvatarUrl() : (request.getContextPath() + "/static/images/avatar/default_avatar.png") %>" alt="avatar">
            <div>
                <p class="author-name"><%= (video.getAuthor() != null && video.getAuthor().getUsername() != null) ? video.getAuthor().getUsername() : "UP主" %></p>
                <div class="author-sub">UP 主 ID：<%= video.getAuthorId() %></div>
            </div>
        </div>
        <% if (video.getAuthorId() != null) { %>
            <button class="follow" onclick="location.href='${pageContext.request.contextPath}/user/<%= video.getAuthorId() %>'">访问主页</button>
        <% } %>
        <div class="side-box">
            如发现该视频违规，请及时举报。<br>
            欢迎通过点赞、收藏、投币支持创作者。
        </div>
    </aside>
</main>

<div id="uiModalMask" class="modal-mask" aria-hidden="true">
    <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="uiModalTitle">
        <h3 id="uiModalTitle" class="modal-title">提示</h3>
        <p id="uiModalMsg" class="modal-msg"></p>
        <input id="uiModalInput" class="modal-input" type="text" style="display:none;">
        <div class="modal-actions">
            <button id="uiModalCancel" class="modal-btn cancel" type="button">取消</button>
            <button id="uiModalOk" class="modal-btn ok" type="button">确定</button>
        </div>
    </div>
</div>
<div id="uiToast" class="toast"></div>

<script>
    var danmuItems = [
        <%
            if (danmuComments != null) {
                boolean firstDanmu = true;
                for (ScreenComment danmu : danmuComments) {
                    if (danmu == null || danmu.getContent() == null) continue;
                    String danmuText = danmu.getContent().trim();
                    Float danmuTime = danmu.getVideoTime();
                    if (danmuText.isEmpty() || danmuTime == null || danmuTime <= 0.01f) continue;
                    danmuText = danmuText
                            .replace("\\", "\\\\")
                            .replace("\"", "\\\"")
                            .replace("\r", "")
                            .replace("\n", "\\n")
                            .replace("</", "<\\/");
                    if (!firstDanmu) {
                        out.print(",");
                    }
                    firstDanmu = false;
        %>
        { id: <%= danmu.getId() %>, time: <%= String.format(java.util.Locale.US, "%.2f", danmuTime) %>, text: "<%= danmuText %>" }
        <%
                }
            }
        %>
    ];
    danmuItems.sort(function (a, b) { return a.time - b.time; });

    var danmuVideo = null;
    var danmuLayer = null;
    var danmuTimer = null;
    var danmuEmitted = {};
    var danmuLaneCursor = 0;

    function getDanmuTop() {
        if (!danmuLayer) return 10;
        var laneHeight = 30;
        var laneCount = Math.max(1, Math.floor((danmuLayer.clientHeight - 16) / laneHeight));
        var lane = danmuLaneCursor % laneCount;
        danmuLaneCursor++;
        return 8 + lane * laneHeight;
    }

    function renderDanmuItem(item) {
        if (!danmuLayer || !item || !item.text) return;
        var node = document.createElement("span");
        node.className = "danmu-item";
        node.textContent = item.text;
        node.style.top = getDanmuTop() + "px";

        var layerWidth = danmuLayer.clientWidth || danmuLayer.offsetWidth || 0;
        node.style.left = layerWidth + "px";
        danmuLayer.appendChild(node);

        // 6秒完整穿过：从容器右外到左外
        var travelDistance = layerWidth + node.offsetWidth + 24;
        node.style.setProperty("--danmu-distance", travelDistance + "px");
        node.style.animation = "danmu-move 6s linear forwards";

        node.addEventListener("animationend", function () {
            if (node.parentNode) {
                node.parentNode.removeChild(node);
            }
        });
    }

    function clearDanmuLayer() {
        if (!danmuLayer) return;
        while (danmuLayer.firstChild) {
            danmuLayer.removeChild(danmuLayer.firstChild);
        }
    }

    function resetDanmuStateByTime(currentTime) {
        danmuEmitted = {};
        for (var i = 0; i < danmuItems.length; i++) {
            if (danmuItems[i].time < currentTime - 0.2) {
                danmuEmitted[danmuItems[i].id] = true;
            }
        }
    }

    function tickDanmu() {
        if (!danmuVideo || !danmuLayer || danmuVideo.paused) return;
        var current = danmuVideo.currentTime || 0;
        for (var i = 0; i < danmuItems.length; i++) {
            var item = danmuItems[i];
            if (!danmuEmitted[item.id] && item.time <= current + 0.2) {
                danmuEmitted[item.id] = true;
                renderDanmuItem(item);
            }
        }
    }

    function startDanmuLoop() {
        if (danmuTimer) return;
        danmuTimer = setInterval(tickDanmu, 120);
    }

    function stopDanmuLoop() {
        if (!danmuTimer) return;
        clearInterval(danmuTimer);
        danmuTimer = null;
    }

    function initDanmuSystem() {
        danmuVideo = document.getElementById("videoPlayer");
        danmuLayer = document.getElementById("danmuLayer");
        if (!danmuVideo || !danmuLayer) return;

        resetDanmuStateByTime(danmuVideo.currentTime || 0);

        danmuVideo.addEventListener("play", startDanmuLoop);
        danmuVideo.addEventListener("pause", stopDanmuLoop);
        danmuVideo.addEventListener("ended", stopDanmuLoop);
        danmuVideo.addEventListener("seeking", function () {
            clearDanmuLayer();
            resetDanmuStateByTime(danmuVideo.currentTime || 0);
        });
        danmuVideo.addEventListener("seeked", tickDanmu);

        if (!danmuVideo.paused) {
            startDanmuLoop();
        }
    }

    var ui = (function () {
        var modalMask = document.getElementById("uiModalMask");
        var modalTitle = document.getElementById("uiModalTitle");
        var modalMsg = document.getElementById("uiModalMsg");
        var modalInput = document.getElementById("uiModalInput");
        var modalCancel = document.getElementById("uiModalCancel");
        var modalOk = document.getElementById("uiModalOk");
        var toast = document.getElementById("uiToast");

        var okHandler = null;
        var cancelHandler = null;
        var toastTimer = null;

        function closeModal() {
            modalMask.classList.remove("show");
            modalMask.setAttribute("aria-hidden", "true");
            modalInput.style.display = "none";
            modalInput.value = "";
            okHandler = null;
            cancelHandler = null;
        }

        function openModal(options) {
            modalTitle.textContent = options.title || "提示";
            modalMsg.textContent = options.message || "";
            modalOk.textContent = options.okText || "确定";
            modalCancel.textContent = options.cancelText || "取消";

            if (options.input) {
                modalInput.style.display = "block";
                modalInput.placeholder = options.placeholder || "";
                modalInput.value = options.defaultValue || "";
                setTimeout(function () { modalInput.focus(); }, 0);
            } else {
                modalInput.style.display = "none";
            }

            okHandler = options.onOk || null;
            cancelHandler = options.onCancel || null;

            modalMask.classList.add("show");
            modalMask.setAttribute("aria-hidden", "false");
        }

        function showToast(message, isError) {
            toast.textContent = message || "操作完成";
            toast.classList.toggle("err", !!isError);
            toast.classList.add("show");
            if (toastTimer) clearTimeout(toastTimer);
            toastTimer = setTimeout(function () {
                toast.classList.remove("show");
            }, 1500);
        }

        modalOk.addEventListener("click", function () {
            if (!okHandler) {
                closeModal();
                return;
            }
            var value = modalInput.style.display === "none" ? null : modalInput.value.trim();
            var result = okHandler(value);
            if (result !== false) closeModal();
        });

        modalCancel.addEventListener("click", function () {
            if (cancelHandler) cancelHandler();
            closeModal();
        });

        modalMask.addEventListener("click", function (e) {
            if (e.target === modalMask) closeModal();
        });

        return {
            confirm: function (message, onOk, title) {
                openModal({ title: title || "请确认", message: message, onOk: onOk });
            },
            input: function (options) {
                openModal({
                    title: options.title || "请输入",
                    message: options.message || "",
                    input: true,
                    placeholder: options.placeholder || "",
                    defaultValue: options.defaultValue || "",
                    okText: options.okText || "提交",
                    onOk: function (value) {
                        return options.onOk ? options.onOk(value) : true;
                    }
                });
            },
            toast: showToast
        };
    })();

    function postForm(url, dataObj) {
        var body = Object.keys(dataObj).map(function (k) {
            return encodeURIComponent(k) + "=" + encodeURIComponent(dataObj[k]);
        }).join("&");
        return fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: body
        }).then(function (r) {
            if (r.status === 401) {
                return { success: false, needLogin: true, message: "请先登录" };
            }
            return r.json();
        });
    }

    function ensureLogin(data) {
        if (data && data.needLogin) {
            location.href = "${pageContext.request.contextPath}/user/login";
            return false;
        }
        return true;
    }

    function toggleLike(videoId, liked) {
        postForm("${pageContext.request.contextPath}/video/" + (liked ? "unlike" : "like"), { id: videoId })
            .then(function (d) {
                if (!ensureLogin(d)) return;
                ui.toast(d.message || (d.success ? "操作成功" : "操作失败"), !d.success);
                if (d.success) setTimeout(function () { location.reload(); }, 300);
            }).catch(function () { ui.toast("请求失败", true); });
    }

    function toggleFav(videoId, favorited) {
        postForm("${pageContext.request.contextPath}/video/" + (favorited ? "unfavorite" : "favorite"), { id: videoId })
            .then(function (d) {
                if (!ensureLogin(d)) return;
                ui.toast(d.message || (d.success ? "操作成功" : "操作失败"), !d.success);
                if (d.success) setTimeout(function () { location.reload(); }, 300);
            }).catch(function () { ui.toast("请求失败", true); });
    }

    function coinVideo(videoId) {
        ui.input({
            title: "投币",
            message: "请输入投币数量（1 或 2）",
            defaultValue: "1",
            placeholder: "1 或 2",
            okText: "确认投币",
            onOk: function (amount) {
                if (amount !== "1" && amount !== "2") {
                    ui.toast("投币数量只能是 1 或 2", true);
                    return false;
                }
                postForm("${pageContext.request.contextPath}/video/coin", { id: videoId, amount: amount })
                    .then(function (d) {
                        if (!ensureLogin(d)) return;
                        ui.toast(d.message || (d.success ? "操作成功" : "操作失败"), !d.success);
                        if (d.success) setTimeout(function () { location.reload(); }, 300);
                    }).catch(function () { ui.toast("请求失败", true); });
                return true;
            }
        });
    }

    function reportVideo(videoId) {
        ui.input({
            title: "举报视频",
            message: "请输入举报理由",
            defaultValue: "疑似违规内容",
            placeholder: "请输入举报说明",
            okText: "提交举报",
            onOk: function (reason) {
                if (!reason) {
                    ui.toast("举报理由不能为空", true);
                    return false;
                }
                postForm("${pageContext.request.contextPath}/video/report", { videoId: videoId, reason: reason })
                    .then(function (d) {
                        if (!ensureLogin(d)) return;
                        ui.toast(d.success ? "举报成功" : "举报失败", !d.success);
                        if (d.success) setTimeout(function () { location.reload(); }, 300);
                    }).catch(function () { ui.toast("请求失败", true); });
                return true;
            }
        });
    }

    function downloadVideo(videoId) {
        window.location.href = "${pageContext.request.contextPath}/video/download?id=" + videoId;
    }

    function sendDanmu(videoId) {
        var input = document.getElementById("danmuInput");
        if (!input) return;
        var content = input.value.trim();
        if (!content) {
            ui.toast("弹幕内容不能为空", true);
            return;
        }
        var video = document.getElementById("videoPlayer");
        var time = 0;
        if (video && !isNaN(video.currentTime)) {
            time = Math.max(0, video.currentTime);
        }
        postForm("${pageContext.request.contextPath}/video/comment", {
            videoId: videoId,
            content: content,
            parentId: "",
            time: time.toFixed(2)
        }).then(function (d) {
            if (!ensureLogin(d)) return;
            ui.toast(d.message || (d.success ? "弹幕发送成功" : "弹幕发送失败"), !d.success);
            if (d.success) {
                var newDanmu = { id: Date.now(), time: time, text: content };
                danmuItems.push(newDanmu);
                danmuItems.sort(function (a, b) { return a.time - b.time; });
                danmuEmitted[newDanmu.id] = true;
                renderDanmuItem(newDanmu);
                input.value = "";
            }
        }).catch(function () { ui.toast("请求失败", true); });
    }

    function sendComment(videoId) {
        var input = document.getElementById("commentInput");
        if (!input) return;
        var content = input.value.trim();
        if (!content) {
            ui.toast("评论内容不能为空", true);
            return;
        }
        postForm("${pageContext.request.contextPath}/video/comment", { videoId: videoId, content: content, parentId: 0 })
            .then(function (d) {
                if (!ensureLogin(d)) return;
                ui.toast(d.message || (d.success ? "操作成功" : "操作失败"), !d.success);
                if (d.success) setTimeout(function () { location.reload(); }, 300);
            }).catch(function () { ui.toast("请求失败", true); });
    }

    (function () {
        initDanmuSystem();
        var danmuInput = document.getElementById("danmuInput");
        if (!danmuInput) return;
        danmuInput.addEventListener("keydown", function (e) {
            if (e.key === "Enter") {
                e.preventDefault();
                sendDanmu(<%= video.getId() %>);
            }
        });
    })();

    function replyTo(commentId) {
        ui.input({
            title: "回复评论",
            message: "请输入回复内容",
            placeholder: "回复内容",
            okText: "发送回复",
            onOk: function (content) {
                if (!content) {
                    ui.toast("回复内容不能为空", true);
                    return false;
                }
                postForm("${pageContext.request.contextPath}/video/comment", { videoId: <%= video.getId() %>, content: content, parentId: commentId })
                    .then(function (d) {
                        if (!ensureLogin(d)) return;
                        ui.toast(d.message || (d.success ? "操作成功" : "操作失败"), !d.success);
                        if (d.success) setTimeout(function () { location.reload(); }, 300);
                    }).catch(function () { ui.toast("请求失败", true); });
                return true;
            }
        });
    }

    function deleteComment(commentId) {
        ui.confirm("确定删除这条评论吗？", function () {
            postForm("${pageContext.request.contextPath}/video/deleteComment", { commentId: commentId })
                .then(function (d) {
                    if (!ensureLogin(d)) return;
                    ui.toast(d.message || (d.success ? "删除成功" : "删除失败"), !d.success);
                    if (d.success) {
                        var row = document.getElementById("comment-" + commentId);
                        if (row) row.remove();
                    }
                }).catch(function () { ui.toast("请求失败", true); });
        }, "删除确认");
    }
</script>
<% } %>
    <script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
