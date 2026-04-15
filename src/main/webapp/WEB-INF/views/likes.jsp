<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的点赞 - LiBiLiBi</title>
    <style>
        :root { --blue:#00aeec; --pink:#fb7299; --line:#e3e5e7; --bg:#f6f7f8; --sub:#61666d; }
        * { box-sizing: border-box; }
        body { margin:0; font-family:"Segoe UI",sans-serif; color:#18191c; background:var(--bg); }
        .header { height:68px; background:#fff; border-bottom:1px solid var(--line); display:flex; align-items:center; justify-content:space-between; padding:0 24px; }
        .logo { color:var(--blue); text-decoration:none; font-size:24px; font-weight:800; }
        .nav a { text-decoration:none; color:var(--sub); margin-left:12px; font-size:14px; }
        .nav .upload { background:var(--pink); color:#fff; padding:8px 12px; border-radius:8px; font-weight:700; }
        .main { width:min(1200px,100%); margin:22px auto; padding:0 20px; }
        .top { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; }
        .top h1 { margin:0; font-size:24px; }
        .tip { color:#9499a0; font-size:13px; }
        .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:18px; }
        .card { background:#fff; border-radius:10px; overflow:hidden; box-shadow:0 4px 14px rgba(0,0,0,.05); }
        .cover { width:100%; aspect-ratio:16/9; object-fit:cover; background:#eef1f4; display:block; cursor:pointer; }
        .info { padding:10px 12px 12px; }
        .title { font-size:15px; margin-bottom:8px; min-height:40px; overflow:hidden; }
        .meta { color:#9499a0; font-size:13px; margin-bottom:10px; }
        .actions { display:flex; gap:8px; }
        .btn { flex:1; border:none; border-radius:8px; height:34px; cursor:pointer; color:#fff; font-size:13px; }
        .btn.play { background:var(--blue); }
        .btn.del { background:#ff6b6b; }
        .empty { text-align:center; background:#fff; border:1px dashed var(--line); border-radius:10px; padding:48px 20px; color:#9499a0; }
        .pager { margin-top:14px; display:flex; gap:6px; justify-content:center; flex-wrap:wrap; }
        .pager a,.pager span { min-width:30px; height:30px; border:1px solid var(--line); border-radius:7px; display:inline-flex; align-items:center; justify-content:center; text-decoration:none; color:#61666d; background:#fff; font-size:12px; padding:0 8px; }
        .pager .active { background:var(--blue); color:#fff; border-color:var(--blue); }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/libilibi-bg.css">
</head>
<body>
<div class="bg-scene" aria-hidden="true"></div>
<header class="header">
    <a class="logo" href="${pageContext.request.contextPath}/">LiBiLiBi</a>
    <nav class="nav">
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/user/profile">个人中心</a>
        <a href="${pageContext.request.contextPath}/video/upload" class="upload">上传</a>
    </nav>
</header>

<main class="main">
    <div class="top">
        <h1>我的点赞</h1>
        <div class="tip">可在此快速取消点赞</div>
    </div>

    <%
        List<Video> likedVideos = (List<Video>) request.getAttribute("likedVideos");
        Integer currentPage = (Integer) request.getAttribute("currentPage");
        Integer totalPages = (Integer) request.getAttribute("totalPages");
        if (currentPage == null) currentPage = 1;
        if (totalPages == null) totalPages = 1;

        if (likedVideos != null && !likedVideos.isEmpty()) {
    %>
    <div class="grid" id="likeGrid">
        <% for (Video v : likedVideos) {
               String coverUrl = v.getCoverUrl();
               if (coverUrl == null || coverUrl.trim().isEmpty()) {
                   coverUrl = request.getContextPath() + "/static/images/default_cover.png";
               } else if (!(coverUrl.startsWith("http://") || coverUrl.startsWith("https://") || coverUrl.startsWith("data:"))) {
                   if (coverUrl.startsWith("/")) {
                       coverUrl = request.getContextPath() + coverUrl;
                   } else {
                       coverUrl = request.getContextPath() + "/" + coverUrl;
                   }
               }
        %>
        <div class="card" id="like-<%= v.getId() %>">
            <img class="cover" src="<%= coverUrl %>"
                 alt="cover" onclick="goDetail(<%= v.getId() %>)"
                 onerror="this.src='${pageContext.request.contextPath}/static/images/default_cover.png'">
            <div class="info">
                <div class="title"><%= v.getTitle() %></div>
                <div class="meta">播放 <%= v.getViewCount() != null ? v.getViewCount() : 0 %> | 点赞 <%= v.getLikeCount() != null ? v.getLikeCount() : 0 %> | 收藏 <%= v.getFavCount() != null ? v.getFavCount() : 0 %></div>
                <div class="actions">
                    <button class="btn play" onclick="goDetail(<%= v.getId() %>)">查看</button>
                    <button class="btn del" onclick="unlike(<%= v.getId() %>)">取消点赞</button>
                </div>
            </div>
        </div>
        <% } %>
    </div>

    <% if (totalPages > 1) { %>
    <div class="pager">
        <% if (currentPage > 1) { %>
        <a href="${pageContext.request.contextPath}/user/likes?page=<%= currentPage - 1 %>">上一页</a>
        <% } %>
        <% for (int i = 1; i <= totalPages; i++) {
               if (i == currentPage) { %>
        <span class="active"><%= i %></span>
        <%     } else { %>
        <a href="${pageContext.request.contextPath}/user/likes?page=<%= i %>"><%= i %></a>
        <%     }
           } %>
        <% if (currentPage < totalPages) { %>
        <a href="${pageContext.request.contextPath}/user/likes?page=<%= currentPage + 1 %>">下一页</a>
        <% } %>
    </div>
    <% } %>

    <% } else { %>
    <div class="empty">你还没有点赞视频。去视频详情页点一下“点赞”吧。</div>
    <% } %>
</main>

<script>
    function goDetail(id) {
        window.location.href = "${pageContext.request.contextPath}/video/detail?id=" + id;
    }

    function unlike(videoId) {
        if (!confirm("确定取消点赞这个视频吗？")) return;
        fetch("${pageContext.request.contextPath}/video/unlike", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "id=" + encodeURIComponent(videoId)
        }).then(function (r) {
            if (r.status === 401) {
                location.href = "${pageContext.request.contextPath}/user/login";
                return null;
            }
            return r.json();
        }).then(function (d) {
            if (!d) return;
            if (d.success) {
                var card = document.getElementById("like-" + videoId);
                if (card) card.remove();
                if (!document.querySelector("#likeGrid .card")) {
                    location.reload();
                }
            } else {
                alert(d.message || "取消点赞失败");
            }
        }).catch(function () {
            alert("请求失败");
        });
    }
</script>
<script src="${pageContext.request.contextPath}/static/js/libilibi-bg-parallax.js"></script>
</body>
</html>
