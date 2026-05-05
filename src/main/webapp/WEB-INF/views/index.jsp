<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="com.assessment.www.po.User" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>视频分享平台</title>
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
        .search-container {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .search-input {
            padding: 5px;
            border: none;
            border-radius: 4px;
            width: 200px;
        }
        .search-btn {
            padding: 5px 10px;
            background-color: #ff6b6b;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .main-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .page-title {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 30px;
        }
        .page-btn {
            padding: 8px 15px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            color: #333;
            transition: all 0.3s ease;
        }
        .page-btn:hover,
        .page-btn.active {
            background-color: #00a1d6;
            color: white;
            border-color: #00a1d6;
        }
        .video-card {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .video-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .video-cover {
            width: 100%;
            height: 200px;
            cursor: pointer;
            background-size: cover;
            background-size: contain;
            background-position: center;
            background-repeat: no-repeat;
            position: relative;
            overflow: hidden;
        }
        .video-cover:hover::after {
            content: '▶';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 48px;
            color: rgba(255, 255, 255, 0.8);
        }
        .video-info {
            padding: 15px;
        }
        .video-title {
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 5px;
            cursor: pointer;
            color: #333;
            line-height: 1.4;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        .video-title:hover {
            color: #00a1d6;
        }
        .video-meta {
            font-size: 14px;
            color: #666;
            display: flex;
            gap: 10px;
        }
        .upload-btn {
            background-color: #ff6b6b;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s ease;
        }
        .upload-btn:hover {
            background-color: #ff5252;
        }
        .login-btn {
            background-color: transparent;
            color: white;
            padding: 5px 15px;
            border: 1px solid white;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .login-btn:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        .welcome-user {
            color: white;
        }
        .refresh-btn {
            background-color: #b58989;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s ease;
        }
        .refresh-btn:hover {
            background-color: #a07070;
        }
        .loading {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        .loading-spinner {
            display: inline-block;
            width: 30px;
            height: 30px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #00a1d6;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 10px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .no-videos {
            text-align: center;
            color: #999;
            padding: 60px 20px;
            font-size: 18px;
        }
        .no-videos .icon {
            font-size: 64px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="header">
        <a href="/" style="text-decoration: none; color: inherit;"><div style="font-size: 24px; font-weight: bold;">视频分享平台</div></a>
        <div class="search-container">
            <input type="text" class="search-input" id="searchInput" placeholder="搜索视频..." autocomplete="off">
            <button class="search-btn" onclick="searchVideos()">搜索</button>
        </div>
        <div class="nav-links">
            <a href="/video/dynamic">动态</a>
            <%
                User user = (User) session.getAttribute("user");
                if (user != null) {
            %>
                <span class="welcome-user">欢迎, <%= user.getUsername() %></span>
                <a href="/user/me">个人中心</a>
                <a href="/ticket/index">漫展活动</a>
               <a href="javascript:void(0);" onclick="logoutAndClearCache()">退出登录</a>
                <a href="/video/upload" class="upload-btn">上传视频</a>
                <%
                    if ("admin".equals(user.getRole())) {
                %>
                    <a href="/admin/adminindex">管理后台</a>
                <%
                    }
                %>
            <%
                } else {
            %>
                <a href="/user/login" class="login-btn">登录</a>
                <a href="/user/register" class="login-btn">注册</a>
            <%
                }
            %>
        </div>
    </div>
    <div class="main-container">
        <div class="page-title">
            <h1>推荐视频</h1>
            <button class="refresh-btn" onclick="loadVideos()" title="刷新视频列表">
                <span id="refreshText">刷新</span>
                <span class="loading-spinner" id="refreshSpinner" style="display: none;"></span>
            </button>
        </div>
        <div class="video-grid" id="videoGrid">
            <!-- 视频列表将由JavaScript动态加载 -->
        </div>
        <div class="pagination" id="pagination">
            <!-- 分页将由JavaScript动态加载 -->
        </div>
    </div>
   <script>
       let currentPage = 1;
       let isLoading = false;
       // 页面加载时获取视频列表
       document.addEventListener('DOMContentLoaded', function() {
           loadVideos();
       });
       // 加载视频列表（带缓存）
       function loadVideos(page = 1) {
           if (isLoading) {
               return;
           }
           isLoading = true;
           currentPage = page;
           // 显示加载动画
           const videoGrid = document.getElementById('videoGrid');
           videoGrid.innerHTML = '<div class="loading"><div class="loading-spinner"></div><p>加载中...</p></div>';
           // 更新刷新按钮
           document.getElementById('refreshText').style.display = 'none';
           document.getElementById('refreshSpinner').style.display = 'inline-block';
           fetch('/video/list?page=' + page + '&_t=' + Date.now()).then(response => response.json()).then(data => {
                   displayVideos(data.videos, data.currentPage, data.totalPages);
                   // 隐藏加载动画
                   document.getElementById('refreshText').style.display = 'inline';
                   document.getElementById('refreshSpinner').style.display = 'none';
                   isLoading = false;
               }).catch(error => {
                   console.error('Error loading videos:', error);
                   videoGrid.innerHTML = '<div class="no-videos"><div class="icon">😔</div>加载失败，请稍后重试</div>';
                   document.getElementById('refreshText').style.display = 'inline';
                   document.getElementById('refreshSpinner').style.display = 'none';
                   isLoading = false;
               });
       }
       // 显示视频列表
       function displayVideos(videos, currentPage, totalPages) {
           const videoGrid = document.getElementById('videoGrid');
           videoGrid.innerHTML = '';
           if (videos && videos.length > 0) {
               videos.forEach(video => {
                   const videoCard = createVideoCard(video);
                   videoGrid.appendChild(videoCard);
               });
               displayPagination(currentPage, totalPages);
               // 添加滚动加载更多功能
               window.addEventListener('scroll', handleScroll);
           } else {
               videoGrid.innerHTML = '<div class="no-videos"><div class="icon">📺</div>暂无视频</div>';
               document.getElementById('pagination').innerHTML = '';
           }
       }
       // 创建视频卡片
       function createVideoCard(video) {
           const videoCard = document.createElement('div');
           videoCard.className = 'video-card';
           videoCard.style.opacity = '0';
           videoCard.style.transform = 'translateY(20px)';
           videoCard.innerHTML =
               '<div class="video-cover" style="background-image: url(\'' + (video.coverUrl || '/static/images/default_cover.png') + '\')" ' +
               'onclick="playVideo(' + video.id + ')"></div>' +
               '<div class="video-info">' +
                   '<div class="video-title" onclick="playVideo(' + video.id + ')">' + video.title + '</div>' +
                   '<div class="video-meta">' +
                       '<span>👁️ ' + formatNumber(video.viewCount) + '</span> | ' +
                       '<span>👍 ' + formatNumber(video.likeCount) + '</span> | ' +
                       '<span>⭐ ' + formatNumber(video.favCount) + '</span>' +
                   '</div>' +
               '</div>';
           // 添加淡入动画
           setTimeout(() => {
               videoCard.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
               videoCard.style.opacity = '1';
               videoCard.style.transform = 'translateY(0)';
           }, 100);
           return videoCard;
       }
       // 格式化数字
       function formatNumber(num) {
           if (num >= 10000) {
               return (num / 10000).toFixed(1) + 'w';
           } else if (num >= 1000) {
               return (num / 1000).toFixed(1) + 'k';
           }
           return num;
       }
       // 显示分页
       function displayPagination(currentPage, totalPages) {
           const pagination = document.getElementById('pagination');
           pagination.innerHTML = '';
           if (totalPages <= 1) {
               return;
           }
           // 上一页
           if (currentPage > 1) {
               createPaginationButton('上一页', () => loadVideos(currentPage - 1), pagination);
           }
           // 页码
           let startPage = Math.max(1, currentPage - 2);
           let endPage = Math.min(totalPages, currentPage + 2);
           if (startPage > 1) {
               createPaginationButton('1', () => loadVideos(1), pagination);
               if (startPage > 2) {
                   createPaginationEllipsis(pagination);
               }
           }
           for (let i = startPage; i <= endPage; i++) {
               createPaginationButton(i, () => loadVideos(i), pagination, i === currentPage);
           }
           if (endPage < totalPages) {
               if (endPage < totalPages - 1) {
                   createPaginationEllipsis(pagination);
               }
               createPaginationButton(totalPages, () => loadVideos(totalPages), pagination);
           }
           // 下一页
           if (currentPage < totalPages) {
               createPaginationButton('下一页', () => loadVideos(currentPage + 1), pagination);
           }
       }
       // 创建分页按钮
       function createPaginationButton(text, onclick, container, active = false) {
           if (active) {
               const span = document.createElement('span');
               span.className = 'page-btn active';
               span.textContent = text;
               container.appendChild(span);
           } else {
               const btn = document.createElement('a');
               btn.href = '#';
               btn.className = 'page-btn';
               btn.textContent = text;
               btn.onclick = function(e) {
                   e.preventDefault();
                   onclick();
               };
               container.appendChild(btn);
           }
       }
       function createPaginationEllipsis(container) {
           const dots = document.createElement('span');
           dots.textContent = '...';
           dots.style.padding = '0 10px';
           dots.style.color = '#999';
           container.appendChild(dots);
       }
       // 播放视频
       function playVideo(videoId) {
           window.location.href = '/video/detail?id=' + videoId;
       }
       // 搜索视频
       function searchVideos() {
           const keyword = document.getElementById('searchInput').value.trim();
           if (keyword) {
               window.location.href = '/video/search?keyword=' + encodeURIComponent(keyword);
           }
       }
       // 搜索框回车事件
       document.getElementById('searchInput').addEventListener('keypress', function(e) {
           if (e.key === 'Enter') {
               searchVideos();
           }
       });
       // 滚动加载更多
       function handleScroll() {
           const scrollHeight = document.documentElement.scrollHeight;
           const scrollTop = document.documentElement.scrollTop;
           const clientHeight = document.documentElement.clientHeight;
           if (scrollTop + clientHeight >= scrollHeight - 100) {
               window.removeEventListener('scroll', handleScroll);
               const nextBtn = document.querySelector('.pagination a:last-child');
               if (nextBtn && nextBtn.textContent === '下一页') {
                   nextBtn.click();
               }
           }
       }
       // 防止频繁点击刷新
       let refreshTimeout;
       function debounceRefresh() {
           clearTimeout(refreshTimeout);
           refreshTimeout = setTimeout(loadVideos, 300);
       }
              function clearLoginCache() {
                  localStorage.removeItem('cachedUsername');
                  localStorage.removeItem('cachedPassword');
                  localStorage.removeItem('rememberToken');
                  localStorage.removeItem('loginTime');
                  localStorage.removeItem('loginExpire');
                  localStorage.removeItem('adminUsername');
                  localStorage.removeItem('adminEncryptedPassword');
                  localStorage.removeItem('adminRememberToken');
                  localStorage.removeItem('adminLoginTime');
                  localStorage.removeItem('adminLoginExpire');
              }

              // 退出登录：先清除缓存，再跳转到后端logout地址
              function logoutAndClearCache() {
                  clearLoginCache();
                  window.location.href = '/user/logout';
              }
       // 页面标题动态更新
       let pageTitle = '视频分享平台';
       setInterval(() => {
           if (document.visibilityState === 'hidden') {
               pageTitle = '有新视频哦！';
           } else {
               pageTitle = '视频分享平台';
           }
           document.title = pageTitle;
       }, 1000);
   </script>
</body>
</html>