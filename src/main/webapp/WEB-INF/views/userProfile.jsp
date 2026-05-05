<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>${targetUser.username} 的个人主页</title>
    <style>
        .user-profile {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            display: flex;
            gap: 30px;
        }
        .profile-sidebar {
            flex: 0 0 300px;
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .profile-main {
            flex: 1;
        }
        .profile-avatar {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            margin-bottom: 20px;
            border: 4px solid #f0f0f0;
        }
        .profile-header {
            text-align: center;
            margin-bottom: 20px;
        }
        .profile-username {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .profile-stats {
            display: flex;
            justify-content: space-around;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 20px;
        }
        .stat-item {
            text-align: center;
            flex: 1 1 120px;
        }
        .stat-number {
            font-size: 20px;
            font-weight: bold;
            color: #1890ff;
        }
        .stat-label {
            font-size: 14px;
            color: #666;
        }
        .stat-link {
            flex: 1;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        .stat-link:hover .stat-number {
            color: #40a9ff;
        }
        .profile-signature {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
            font-style: italic;
        }
        .profile-actions {
            display: flex;
            gap: 10px;
            justify-content: center;
        }
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s;
        }
        .btn-primary {
            background-color: #1890ff;
            color: white;
        }
        .btn-primary:hover {
            background-color: #40a9ff;
        }
        .btn-secondary {
            background-color: #f0f0f0;
            color: #333;
        }
        .btn-secondary:hover {
            background-color: #e0e0e0;
        }
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
        }
        .video-card {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .video-card:hover {
            transform: translateY(-2px);
        }
        .video-thumbnail {
            width: 200px;
            height: 200px;
            object-fit: cover;
             background-size: contain;
             background-repeat: no-repeat;
        }
        .video-info {
            padding: 15px;
        }
        .video-title {
            font-weight: bold;
            margin-bottom: 5px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .video-meta {
            font-size: 12px;
            color: #666;
        }
        .section-title {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #1890ff;
        }
        .error-message {
            color: #ff4d4f;
            background: #fff2f0;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        .success-message {
            color: #52c41a;
            background: #f6ffed;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        .profile-tabs {
            display: flex;
            gap: 2px;
            margin-bottom: 20px;
            border-bottom: 2px solid #e8e8e8;
        }
        .profile-tab {
            padding: 12px 24px;
            border: none;
            background: transparent;
            cursor: pointer;
            font-size: 15px;
            color: #666;
            border-bottom: 2px solid transparent;
            margin-bottom: -2px;
            transition: all 0.2s;
        }
        .profile-tab:hover {
            color: #1890ff;
        }
        .profile-tab.active {
            color: #1890ff;
            border-bottom-color: #1890ff;
            font-weight: bold;
        }
        .tab-count {
            font-size: 12px;
            color: #999;
            margin-left: 4px;
        }
        .profile-tab.active .tab-count {
            color: #1890ff;
        }
        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
        }
        .empty-content {
            text-align: center;
            padding: 60px 20px;
            color: #999;
            font-size: 16px;
        }
    </style>
</head>
<body>
    <div class="user-profile">
        <!-- 左侧边栏 -->
        <div class="profile-sidebar">
            <div class="profile-header">
                <img src="${targetUser.avatarUrl != null ? targetUser.avatarUrl : '/static/images/default_avatar.png'}"
                     alt="${targetUser.username}" class="profile-avatar">
                <div class="profile-username">${targetUser.username}</div>
                <div class="profile-signature">${targetUser.signature}</div>
            </div>
            <div class="profile-stats">
                <a class="stat-link" href="${pageContext.request.contextPath}/user/followers?userId=${targetUser.id}">
                    <div class="stat-item">
                        <div class="stat-number">${targetUser.followerCount != null ? targetUser.followerCount : 0}</div>
                        <div class="stat-label">粉丝</div>
                    </div>
                </a>
                <a class="stat-link" href="${pageContext.request.contextPath}/user/following?userId=${targetUser.id}">
                    <div class="stat-item">
                        <div class="stat-number">${targetUser.followingCount != null ? targetUser.followingCount : 0}</div>
                        <div class="stat-label">关注</div>
                    </div>
                </a>
                <div class="stat-item">
                    <div class="stat-number">${videoCount}</div>
                    <div class="stat-label">作品</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">${totalViewCount}</div>
                    <div class="stat-label">总播放</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">${totalLikeCount}</div>
                    <div class="stat-label">总点赞</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">${targetUser.totalFavCount != null ? targetUser.totalFavCount : 0}</div>
                    <div class="stat-label">收藏</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">${targetUser.coinCount != null ? targetUser.coinCount : 0}</div>
                    <div class="stat-label">硬币</div>
                </div>
            </div>
            <c:if test="${!isOwnProfile}">
                <div class="profile-actions">
                    <c:if test="${isFollowing}">
                        <button class="btn btn-secondary" onclick="unfollowUser(${targetUser.id})">取消关注</button>
                    </c:if>
                    <c:if test="${!isFollowing}">
                        <button class="btn btn-primary" onclick="followUser(${targetUser.id})">关注</button>
                    </c:if>
                </div>
            </c:if>
            <c:if test="${isOwnProfile}">
                <div class="profile-actions">
                    <a href="${pageContext.request.contextPath}/user/profile" class="btn btn-secondary">编辑资料</a>
                </div>
            </c:if>
        </div>
        <!-- 主要内容区 -->
        <div class="profile-main">
            <!-- 标签页切换 -->
            <div class="profile-tabs">
                <button class="profile-tab active" onclick="switchTab('videos')">作品 <span class="tab-count">${videoCount}</span></button>
                <button class="profile-tab" onclick="switchTab('likes')">点赞 <span class="tab-count">${likedCount}</span></button>
                <button class="profile-tab" onclick="switchTab('favorites')">收藏 <span class="tab-count">${favoriteCount}</span></button>
            </div>
            <c:if test="${error != null}">
                <div class="error-message">${error}</div>
            </c:if>
            <c:if test="${success != null}">
                <div class="success-message">${success}</div>
            </c:if>

            <!-- 作品列表 -->
            <div id="tab-videos" class="tab-content active">
                <c:if test="${userVideos.size() > 0}">
                <div class="video-grid">
                    <c:forEach var="video" items="${userVideos}">
                        <div class="video-card">
                            <a href="${pageContext.request.contextPath}/video/detail?id=${video.id}">
                                <img src="${video.coverUrl != null ? video.coverUrl : '/static/images/default_cover.png'}"
                                     alt="${video.title}" class="video-thumbnail">
                            </a>
                            <div class="video-info">
                                <div class="video-title">
                                    <a href="${pageContext.request.contextPath}/video/detail?id=${video.id}">${video.title}</a>
                                </div>
                                <div class="video-meta">
                                    <span>${video.viewCount} 次播放</span> ·
                                    <span>${video.likeCount} 赞</span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                </c:if>
                <c:if test="${userVideos.size() == 0}">
                    <div class="empty-content">暂无作品</div>
                </c:if>
            </div>

            <!-- 点赞列表 -->
            <div id="tab-likes" class="tab-content">
                <c:if test="${likedVideos.size() > 0}">
                <div class="video-grid">
                    <c:forEach var="video" items="${likedVideos}">
                        <div class="video-card">
                            <a href="${pageContext.request.contextPath}/video/detail?id=${video.id}">
                                <img src="${video.coverUrl != null ? video.coverUrl : '/static/images/default_cover.png'}"
                                     alt="${video.title}" class="video-thumbnail">
                            </a>
                            <div class="video-info">
                                <div class="video-title">
                                    <a href="${pageContext.request.contextPath}/video/detail?id=${video.id}">${video.title}</a>
                                </div>
                                <div class="video-meta">
                                    <span>${video.viewCount} 次播放</span> ·
                                    <span>${video.likeCount} 赞</span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                </c:if>
                <c:if test="${likedVideos.size() == 0}">
                    <div class="empty-content">暂无点赞的视频</div>
                </c:if>
            </div>

            <!-- 收藏列表 -->
            <div id="tab-favorites" class="tab-content">
                <c:if test="${favoritedVideos.size() > 0}">
                <div class="video-grid">
                    <c:forEach var="video" items="${favoritedVideos}">
                        <div class="video-card">
                            <a href="${pageContext.request.contextPath}/video/detail?id=${video.id}">
                                <img src="${video.coverUrl != null ? video.coverUrl : '/static/images/default_cover.png'}"
                                     alt="${video.title}" class="video-thumbnail">
                            </a>
                            <div class="video-info">
                                <div class="video-title">
                                    <a href="${pageContext.request.contextPath}/video/detail?id=${video.id}">${video.title}</a>
                                </div>
                                <div class="video-meta">
                                    <span>${video.viewCount} 次播放</span> ·
                                    <span>${video.likeCount} 赞</span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                </c:if>
                <c:if test="${favoritedVideos.size() == 0}">
                    <div class="empty-content">暂无收藏的视频</div>
                </c:if>
            </div>
        </div>
    </div>
    <script>
        function switchTab(tabName) {
            document.querySelectorAll('.profile-tab').forEach(function(btn) { btn.classList.remove('active'); });
            document.querySelectorAll('.tab-content').forEach(function(content) { content.classList.remove('active'); });
            document.getElementById('tab-' + tabName).classList.add('active');
            event.target.classList.add('active');
        }
        function followUser(userId) {
            fetch('${pageContext.request.contextPath}/user/follow', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'targetUserId=' + userId
            }).then(response => {
                if (response.ok) {
                    location.reload();
                } else {
                    alert('关注失败，请重试');
                }
            }).catch(error => {
                console.error('Error:', error);
                alert('关注失败，请重试');
            });
        }
        function unfollowUser(userId) {
            if (confirm('确定要取消关注吗？')) {
                fetch('${pageContext.request.contextPath}/user/unfollow', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'targetUserId=' + userId
                }).then(response => {
                    if (response.ok) {
                        location.reload();
                    } else {
                        alert('取消关注失败，请重试');
                    }
                }).catch(error => {
                    console.error('Error:', error);
                    alert('取消关注失败，请重试');
                });
            }
        }
    </script>
</body>
</html>