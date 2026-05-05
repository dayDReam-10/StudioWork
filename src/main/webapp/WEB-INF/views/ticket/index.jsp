<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>漫展演出售票系统</title>
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
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
            flex-wrap: wrap;
        }
        .header a {
            text-decoration: none;
            color: inherit;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
        }
        .nav-links {
            display: flex;
            gap: 20px;
            align-items: center;
            flex-wrap: wrap;
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
        .upload-btn {
            background-color: #ff6b6b;
            color: white;
            padding: 5px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
        }
        .login-btn {
            background-color: transparent;
            color: white;
            padding: 5px 15px;
            border: 1px solid white;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }
        .welcome-user {
            color: white;
        }
        .main-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .filters {
            margin-bottom: 20px;
        }
        .filter-btn {
            padding: 8px 15px;
            margin-right: 10px;
            border: 1px solid #ddd;
            background: #f8f8f8;
            cursor: pointer;
            border-radius: 4px;
        }
        .filter-btn.active {
            background: #007bff;
            color: white;
        }
        .exhibitions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        .exhibition-card {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            background: white;
            transition: transform 0.3s;
        }
        .exhibition-card:hover {
            transform: translateY(-5px);
        }
        .exhibition-card img {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-radius: 4px;
            margin-bottom: 15px;
        }
        .exhibition-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .exhibition-info {
            margin-bottom: 10px;
        }
        .exhibition-info p {
            margin: 5px 0;
        }
        .exhibition-actions {
            margin-top: 15px;
        }
        .btn {
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .btn-primary {
            background: #007bff;
            color: white;
        }
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        .no-data {
            text-align: center;
            color: #999;
            padding: 40px;
            grid-column: 1 / -1;
        }
    </style>
</head>
<body>
    <!-- 视频平台的头部 -->
    <div class="header">
        <a href="/ticket/index" class="logo">漫展演出售票系统</a>
        <div class="search-container">
            <input type="text" class="search-input" id="searchInput" placeholder="搜索漫展/演出...">
            <button class="search-btn" onclick="searchExhibitions()">搜索</button>
        </div>
        <div class="nav-links">
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <span class="welcome-user">欢迎, ${sessionScope.user.username}</span>
                    <a href="/user/me">个人中心</a>
                    <a href="/">视频中心</a>
                    <a href="/ticket/myorders" class="upload-btn">我的订单</a>
                    <a href="/user/logout">退出登录</a>
                    <c:if test="${'admin' == sessionScope.user.role}">
                        <a href="/adminticket/exhibitions">管理后台</a>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <a href="/user/login" class="login-btn">登录</a>
                    <a href="/user/register">注册</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <!-- 主体内容区域 -->
    <div class="main-container">
        <div class="filters">
            <button class="filter-btn active" onclick="filterExhibitions('all')">全部</button>
            <button class="filter-btn" onclick="filterExhibitions('漫展')">漫展</button>
            <button class="filter-btn" onclick="filterExhibitions('演出')">演出</button>
            <button class="filter-btn" onclick="filterExhibitions('比赛')">比赛</button>
            <button class="filter-btn" onclick="filterExhibitions('本地生活')">本地生活</button>
            <button class="filter-btn" onclick="filterByTime('all')">全部时间</button>
            <button class="filter-btn" onclick="filterByTime('week')">本周</button>
            <button class="filter-btn" onclick="filterByTime('month')">本月</button>
        </div>
        <div class="exhibitions-grid" id="exhibitionsGrid">
            <c:forEach items="${exhibitions}" var="exhibition">
                <div class="exhibition-card" data-title="${exhibition.name}" data-type="${exhibition.type}">
                    <img src="${exhibition.coverImage}" alt="${exhibition.name}">
                    <div class="exhibition-title">${exhibition.name}</div>
                    <div class="exhibition-info">
                        <p><strong>类型:</strong> ${exhibition.type}</p>
                        <p><strong>时间:</strong> ${exhibition.startTime} - ${exhibition.endTime}</p>
                        <p><strong>地点:</strong> ${exhibition.address}</p>
                        <p><strong>价格:</strong> <b style="color:red;">¥${exhibition.ticketprice}</b></p>
                    </div>
                    <div class="exhibition-actions">
                        <button class="btn btn-primary" onclick="viewDetails(${exhibition.id})">查看详情</button>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty exhibitions}">
                <div class="no-data">暂无漫展/演出信息</div>
            </c:if>
        </div>
    </div>
    <script>
        function searchExhibitions() {
            const keyword = document.getElementById('searchInput').value.trim().toLowerCase();
            const cards = document.querySelectorAll('.exhibition-card');
            let hasVisible = false;
            cards.forEach(card => {
                const title = card.getAttribute('data-title').toLowerCase();
                const type = card.getAttribute('data-type').toLowerCase();
                if (keyword === '' || title.includes(keyword) || type.includes(keyword)) {
                    card.style.display = '';
                    hasVisible = true;
                } else {
                    card.style.display = 'none';
                }
            });
            const grid = document.getElementById('exhibitionsGrid');
            let noDataMsg = document.getElementById('searchNoDataMsg');
            if (!hasVisible && keyword !== '') {
                if (!noDataMsg) {
                    noDataMsg = document.createElement('div');
                    noDataMsg.id = 'searchNoDataMsg';
                    noDataMsg.className = 'no-data';
                    noDataMsg.textContent = '没有找到与“' + keyword + '”相关的漫展/演出';
                    grid.appendChild(noDataMsg);
                } else {
                    noDataMsg.style.display = '';
                    noDataMsg.textContent = '没有找到与“' + keyword + '”相关的漫展/演出';
                }
            } else if (noDataMsg) {
                noDataMsg.style.display = 'none';
            }
        }
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchExhibitions();
            }
        });
        function filterExhibitions(type) {
            window.location.href = '/ticket/index?type=' + type;
        }
        function filterByTime(timeRange) {
            window.location.href = '/ticket/index?timeRange=' + timeRange;
        }
        function viewDetails(exhibitionId) {
            window.location.href = '/ticket/exhibition-details?id=' + exhibitionId;
        }
        function favoriteExhibition(exhibitionId) {
            $.post('/ticket/favorite', { id: exhibitionId }, function(response) {
                if (response.success) {
                    alert(response.message);
                    location.reload();
                } else {
                    alert(response.message);
                }
            }).fail(function() {
                alert('操作失败，请重试');
            });
        }
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const typeParam = urlParams.get('type');
            if (typeParam) {
                document.querySelectorAll('.filter-btn').forEach(btn => {
                    btn.classList.remove('active');
                    if (btn.textContent === (typeParam === 'all' ? '全部' :
                        (typeParam === '漫展' ? '漫展' :
                         (typeParam === '演出' ? '演出' :
                          (typeParam === '比赛' ? '比赛' :
                           (typeParam === '本地生活' ? '本地生活' : '')))))) {
                        btn.classList.add('active');
                    }
                });
            }
        });
    </script>
</body>
</html>