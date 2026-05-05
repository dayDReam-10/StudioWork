<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.assessment.www.po.Video" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>视频播放</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
        }
        .header {
            background-color: #00a1d6;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .nav-links {
            display: flex;
            gap: 20px;
        }
        .nav-links a {
            color: white;
            text-decoration: none;
            padding: 5px 10px;
        }
        .main-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .video-container {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .playback-tools {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            padding: 14px 20px;
            border-bottom: 1px solid #eef2f7;
            background: linear-gradient(135deg, #f8fbff 0%, #eef7ff 100%);
        }
        .playback-tools .label {
            font-size: 14px;
            font-weight: 700;
            color: #0f172a;
        }
        .playback-tools .hint {
            font-size: 12px;
            color: #64748b;
        }
        .speed-select {
            min-width: 96px;
            padding: 8px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            background: #ffffff;
            color: #0f172a;
            outline: none;
        }
        .speed-select:focus {
            border-color: #00a1d6;
            box-shadow: 0 0 0 3px rgba(0, 161, 214, 0.12);
        }
        .video-player {
            width: 100%;
            height: 500px;
            background-color: #000;
        }
        .video-info {
            padding: 20px;
        }
        .video-title {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 15px;
            color: #333;
        }
        .video-description {
            color: #666;
            line-height: 1.6;
            margin-bottom: 20px;
        }
        .video-meta {
            display: flex;
            gap: 30px;
            color: #666;
            margin-bottom: 20px;
        }
        .meta-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 20px;
        }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }
        .btn-like {
            background-color: #ff6b6b;
            color: white;
        }
        .btn-like:hover {
            background-color: #ff5252;
        }
        .btn-favorite {
            background-color: #4ecdc4;
            color: white;
        }
        .btn-favorite:hover {
            background-color: #3dbdb3;
        }
        .btn-back {
            background-color: #00a1d6;
            color: white;
        }
        .btn-back:hover {
            background-color: #0088b3;
        }
    </style>
</head>
<body>
    <div class="header">
                <a href="/" style="text-decoration: none; color: inherit;"><div style="font-size: 24px; font-weight: bold;">视频分享平台</div></a>
        <div class="nav-links">
            <a href="/">首页</a>
            <a href="/user/me">个人中心</a>
            <a href="/user/logout">退出登录</a>
        </div>
    </div>
    <div class="main-container">
        <div class="video-container">
            <%
                Video video = (Video) request.getAttribute("video");
                if (video != null) {
            %>
            <div class="playback-tools">
                <div>
                    <div class="label">播放设置</div>
                    <div class="hint">可随时切换倍速，设置会保存在本地</div>
                </div>
                <div>
                    <label for="playerSpeedSelect" style="font-size: 14px; color: #334155; font-weight: 600; margin-right: 8px;">倍速</label>
                    <select id="playerSpeedSelect" class="speed-select" onchange="changePlayerSpeed(this.value)">
                        <option value="0.75">0.75x</option>
                        <option value="1" selected>1x</option>
                        <option value="1.25">1.25x</option>
                        <option value="1.5">1.5x</option>
                        <option value="2">2x</option>
                    </select>
                </div>
            </div>
            <video id="playerVideo" class="video-player" controls playsinline>
                <%
                    String playerVideoUrl = video.getVideoUrl();
                    String playerVideoSrc;
                    if (playerVideoUrl != null && (playerVideoUrl.startsWith("http://") || playerVideoUrl.startsWith("https://") || playerVideoUrl.startsWith("/"))) {
                        playerVideoSrc = playerVideoUrl;
                    } else if (playerVideoUrl != null) {
                        playerVideoSrc = "/static/videos/" + playerVideoUrl;
                    } else {
                        playerVideoSrc = "";
                    }
                    String playerVideoType = "video/mp4";
                    if (playerVideoUrl != null) {
                        String lowerUrl = playerVideoUrl.toLowerCase();
                        if (lowerUrl.endsWith(".webm")) {
                            playerVideoType = "video/webm";
                        } else if (lowerUrl.endsWith(".ogg") || lowerUrl.endsWith(".ogv")) {
                            playerVideoType = "video/ogg";
                        } else if (lowerUrl.endsWith(".mov")) {
                            playerVideoType = "video/quicktime";
                        } else if (lowerUrl.endsWith(".avi")) {
                            playerVideoType = "video/x-msvideo";
                        } else if (lowerUrl.endsWith(".mkv")) {
                            playerVideoType = "video/x-matroska";
                        }
                    }
                %>
                <source src="<%= playerVideoSrc %>" type="<%= playerVideoType %>">
                您的浏览器不支持视频播放。
            </video>

            <%-- 如果服务器端检测到文件缺失，显示友好提示 --%>
            <%
                Boolean missing = request.getAttribute("videoFileMissing") != null ? (Boolean) request.getAttribute("videoFileMissing") : false;
                if (missing) {
                    String msg = request.getAttribute("videoFileMissingMessage") != null ? request.getAttribute("videoFileMissingMessage").toString() : "视频文件未找到";
            %>
            <div style="padding:12px;background:#ffecec;color:#900;border:1px solid #f5c6cb;border-radius:6px;margin:12px 20px;">提醒：<%= msg %></div>
            <%
                }
            %>
            <div class="video-info">
                <h1 class="video-title"><%= video.getTitle() %></h1>
                <p class="video-description"><%= video.getDescription() %></p>
                <div class="video-meta">
                    <div class="meta-item">
                        <span>播放量: <%= video.getViewCount() %></span>
                    </div>
                    <div class="meta-item">
                        <span>点赞: <%= video.getLikeCount() %></span>
                    </div>
                    <div class="meta-item">
                        <span>收藏: <%= video.getFavCount() %></span>
                    </div>
                </div>
                <div class="action-buttons">
                    <button class="btn btn-like" onclick="likeVideo(<%= video.getId() %>)">点赞</button>
                    <button class="btn btn-favorite" onclick="favoriteVideo(<%= video.getId() %>)">收藏</button>
                    <button class="btn btn-back" onclick="window.location.href='/'">返回首页</button>
                </div>
            </div>
            <%
                } else {
            %>
            <div style="text-align: center; padding: 50px;">
                <h2>视频不存在</h2>
                <p><a href="/">返回首页</a></p>
            </div>
            <%
                }
            %>
        </div>
    </div>
    <script>
        const playerPlaybackRateStorageKey = 'videoPlaybackRate';

        function restorePlayerSpeed() {
            const video = document.getElementById('playerVideo');
            const select = document.getElementById('playerSpeedSelect');
            if (!video || !select) {
                return;
            }
            const storedRate = parseFloat(localStorage.getItem(playerPlaybackRateStorageKey));
            const rate = [0.75, 1, 1.25, 1.5, 2].indexOf(storedRate) >= 0 ? storedRate : 1;
            video.playbackRate = rate;
            video.defaultPlaybackRate = rate;
            select.value = String(rate);
        }

        function changePlayerSpeed(rateValue) {
            const video = document.getElementById('playerVideo');
            const rate = parseFloat(rateValue) || 1;
            if (video) {
                video.playbackRate = rate;
                video.defaultPlaybackRate = rate;
            }
            localStorage.setItem(playerPlaybackRateStorageKey, String(rate));
        }

        restorePlayerSpeed();

        function likeVideo(videoId) {
            fetch('/video/like?id='+videoId, {
                method: 'POST'
            }).then(response => response.json()).then(data => {
                if (data.success) {
                    alert(data.message);
                    location.reload();
                } else {
                    alert(data.message);
                }
            });
        }
        function favoriteVideo(videoId) {
            fetch('/video/favorite?id='+videoId, {
                method: 'POST'
            }).then(response => response.json()).then(data => {
                if (data.success) {
                    alert(data.message);
                    location.reload();
                } else {
                    alert(data.message);
                }
            });
        }

        // 附加：监听 video 错误，记录详细信息并显示友好提示
        (function attachVideoErrorLogger() {
            var video = document.getElementById('playerVideo');
            if (!video) return;
            try {
                var src = video.currentSrc || (video.querySelector('source') && video.querySelector('source').src);
                console.log('playerVideo src=', src);
            } catch (e) {}
            video.addEventListener('error', function () {
                try {
                    var err = video.error;
                    console.error('Video playback error', err, 'networkState', video.networkState, 'readyState', video.readyState);
                    var msg = '视频加载失败，请检查视频格式（推荐 H.264 + AAC）或网络。错误码：' + (err ? err.code : 'unknown');
                    var notice = document.createElement('div');
                    notice.style.position = 'fixed';
                    notice.style.top = '10px';
                    notice.style.left = '50%';
                    notice.style.transform = 'translateX(-50%)';
                    notice.style.background = '#ffdddd';
                    notice.style.color = '#900';
                    notice.style.padding = '10px 14px';
                    notice.style.borderRadius = '6px';
                    notice.style.zIndex = 9999;
                    notice.textContent = msg;
                    document.body.appendChild(notice);
                } catch (e) { console.error(e); }
            });
        })();
    </script>
</body>
</html>