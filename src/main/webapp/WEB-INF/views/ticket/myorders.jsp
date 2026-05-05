<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的订单 - 漫展演出售票系统</title>
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Arial', 'Microsoft YaHei', sans-serif; background-color: #f5f5f5; color: #333; }
        .header { background-color: #00a1d6; color: white; padding: 12px 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .header a { text-decoration: none; color: inherit; }
        .logo { font-size: 24px; font-weight: bold; letter-spacing: 1px; }
        .logo:hover { opacity: 0.9; }
        .search-container { display: flex; gap: 8px; align-items: center; flex: 1; max-width: 400px; }
        .search-input { padding: 8px 12px; border: none; border-radius: 20px; width: 100%; font-size: 14px; outline: none; transition: all 0.3s; }
        .search-input:focus { box-shadow: 0 0 0 2px rgba(255,255,255,0.5); }
        .search-btn {  white-space: nowrap;padding: 6px 16px; background-color: #ff6b6b; color: white; border: none; border-radius: 20px; cursor: pointer; font-size: 14px; transition: background 0.3s; }
        .search-btn:hover { background-color: #ff5252; }
        .nav-links { display: flex; gap: 20px; align-items: center; flex-wrap: wrap; }
        .nav-links a { color: white; text-decoration: none; padding: 6px 12px; border-radius: 4px; transition: background 0.3s; font-size: 14px; }
        .nav-links a:hover { background-color: rgba(255,255,255,0.2); }
        .upload-btn { background-color: #ff6b6b; padding: 6px 16px; border-radius: 20px !important; }
        .upload-btn:hover { background-color: #ff5252 !important; }
        .login-btn { border: 1px solid white; padding: 6px 16px; border-radius: 20px; }
        .welcome-user { font-weight: bold; margin-right: 5px; }
        .main-container { max-width: 1300px; margin: 30px auto; padding: 0 20px; display: flex; gap: 24px; }
        .profile-sidebar { flex: 1; min-width: 260px; background: white; border-radius: 12px; padding: 24px 20px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); height: fit-content; position: sticky; top: 20px; }
        .profile-avatar { width: 100px; height: 100px; border-radius: 50%; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); margin: 0 auto 16px; display: flex; justify-content: center; align-items: center; font-size: 42px; font-weight: bold; color: white; text-transform: uppercase; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .profile-info { text-align: center; margin-bottom: 20px; }
        .profile-name { font-size: 22px; font-weight: bold; margin-bottom: 6px; color: #222; }
        .profile-info p { color: #666; font-size: 14px; }
        .profile-stats { display: flex; justify-content: space-around; margin: 20px 0 24px; padding: 12px 0; background-color: #f9f9f9; border-radius: 12px; }
        .stat-item { text-align: center; flex: 1; }
        .stat-value { font-size: 20px; font-weight: bold; color: #00a1d6; }
        .stat-label { font-size: 12px; color: #777; margin-top: 4px; }
        .coin-value { color: #ff9800 !important; }
        .profile-menu { list-style: none; padding: 0; margin-top: 10px; }
        .profile-menu li { padding: 12px 0; border-bottom: 1px solid #eee; }
        .profile-menu li:last-child { border-bottom: none; }
        .profile-menu a { color: #444; text-decoration: none; display: block; font-size: 16px; transition: all 0.2s; padding: 4px 8px; border-radius: 6px; cursor: pointer; }
        .profile-menu a:hover { color: #00a1d6; background-color: #f0f7ff; transform: translateX(4px); }
        .profile-menu .active-menu { color: #00a1d6; background-color: #e6f4ff; font-weight: bold; border-left: 3px solid #00a1d6; }
        .profile-content { flex: 3; background: white; border-radius: 12px; padding: 24px 28px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); min-height: 500px; }
        .filter-tabs { margin-bottom: 24px; display: flex; flex-wrap: wrap; gap: 10px; border-bottom: 1px solid #e9ecef; padding-bottom: 12px; }
        .filter-tab { padding: 8px 18px; border-radius: 30px; background: #f8f9fa; cursor: pointer; font-size: 14px; transition: all 0.2s; color: #495057; }
        .filter-tab:hover { background: #e9ecef; }
        .filter-tab.active { background: #00a1d6; color: white; box-shadow: 0 2px 6px rgba(0,161,214,0.3); }
        .orders-table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px; }
        .orders-table th, .orders-table td { border: 1px solid #dee2e6; padding: 12px 10px; text-align: left; vertical-align: middle; }
        .orders-table th { background-color: #f8f9fa; font-weight: 600; color: #495057; }
        .orders-table tr:hover { background-color: #f8f9ff; }
        .status-badge { padding: 4px 10px; border-radius: 30px; color: white; display: inline-block; font-size: 12px; font-weight: bold; min-width: 64px; text-align: center; }
        .status-pending { background-color: #ffc107; }
        .status-paid { background-color: #28a745; }
        .status-cancelled { background-color: #dc3545; }
        .status-refunded { background-color: #6c757d; }
        .status-verified { background-color: #17a2b8; }
        .status-refunding { background-color: #d13e3e; }
        .btn { padding: 5px 12px; border: none; border-radius: 20px; cursor: pointer; font-size: 12px; margin: 3px; transition: all 0.2s; }
        .btn-primary { background: #007bff; color: white; }
        .btn-primary:hover { background: #0069d9; }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-secondary:hover { background: #5a6268; }
        .btn-danger { background: #dc3545; color: white; }
        .btn-danger:hover { background: #c82333; }
        .btn-info { background: #17a2b8; color: white; }
        .btn-info:hover { background: #138496; }
        .no-data { text-align: center; padding: 60px 20px; color: #999; font-size: 16px; }
        .pagination { margin-top: 30px; text-align: center; }
        .pagination a { display: inline-block; padding: 6px 12px; margin: 0 4px; border: 1px solid #dee2e6; background: white; color: #00a1d6; text-decoration: none; border-radius: 6px; transition: all 0.2s; }
        .pagination a.active { background: #00a1d6; color: white; border-color: #00a1d6; }
        .pagination a:hover:not(.active) { background: #e9ecef; }
        .favorites-list { display: flex; flex-direction: column; gap: 20px; }
        .favorite-item { display: flex; background: #fafbfc; border-radius: 12px; padding: 16px; transition: all 0.2s; border: 1px solid #edf2f7; }
        .favorite-item:hover { transform: translateY(-2px); box-shadow: 0 6px 14px rgba(0,0,0,0.05); border-color: #cbd5e0; }
        .favorite-cover { flex: 0 0 160px; height: 110px; border-radius: 8px; overflow: hidden; margin-right: 18px; background: #e2e8f0; }
        .favorite-cover img { width: 100%; height: 100%; object-fit: cover; }
        .favorite-info { flex: 1; }
        .favorite-info h4 { margin: 0 0 8px 0; font-size: 18px; }
        .favorite-info h4 a { color: #2d3748; text-decoration: none; }
        .favorite-info h4 a:hover { color: #00a1d6; }
        .favorite-info p { color: #718096; font-size: 14px; margin-bottom: 12px; }
        .unfavorite-btn { background: #ff6b6b; color: white; border: none; padding: 6px 16px; border-radius: 30px; cursor: pointer; font-size: 13px; transition: background 0.2s; }
        .unfavorite-btn:hover { background: #ff4757; }
        @media (max-width: 768px) {
            .main-container { flex-direction: column; }
            .profile-sidebar { position: static; width: 100%; }
            .orders-table th, .orders-table td { padding: 8px 6px; font-size: 12px; }
            .btn { padding: 4px 8px; font-size: 11px; }
            .favorite-item { flex-direction: column; }
            .favorite-cover { width: 100%; height: 180px; margin-bottom: 12px; }
        }
    </style>
</head>
<body>
<div class="header">
    <a href="/ticket/index" class="logo">漫展演出售票系统</a>
    <div class="search-container">
        <input type="text" class="search-input" id="searchInput" placeholder="搜索漫展/演出...">
        <button class="search-btn" id="searchBtn">搜索</button>
    </div>
    <div class="nav-links">
        <c:choose>
            <c:when test="${not empty sessionScope.user}">
                <span class="welcome-user">欢迎, ${sessionScope.user.username}</span>
                <a href="/user/me">个人中心</a>
                <a href="/ticket/index">漫展活动</a>
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
<div class="main-container">
    <div class="profile-sidebar">
        <div class="profile-avatar">
            <c:choose>
                <c:when test="${not empty sessionScope.user.avatarUrl}">
                    <img src="${sessionScope.user.avatarUrl}" style="width:100%;height:100%;border-radius:50%;object-fit:cover;">
                </c:when>
                <c:otherwise>
                    ${fn:substring(sessionScope.user.username, 0, 1)}
                </c:otherwise>
            </c:choose>
        </div>
        <div class="profile-info">
            <div class="profile-name">${sessionScope.user.username}</div>
            <p>身份: ${sessionScope.user.role == 'admin' ? '管理员' : '普通用户'}</p>
        </div>
        <ul class="profile-menu">
            <li><a href="javascript:void(0);" id="menuOrders" class="active-menu">📋 我的订单</a></li>
            <li><a href="javascript:void(0);" id="menuFavorites">⭐ 我的收藏</a></li>
        </ul>
    </div>
    <div class="profile-content">
        <div id="ordersPanel">
            <div class="filter-tabs">
                <span class="filter-tab ${param.status == null || param.status == 'all' ? 'active' : ''}" data-status="all">全部订单</span>
                <span class="filter-tab ${param.status == 'pending' ? 'active' : ''}" data-status="pending">待支付</span>
                <span class="filter-tab ${param.status == 'paid' ? 'active' : ''}" data-status="paid">已支付</span>
                <span class="filter-tab ${param.status == 'verified' ? 'active' : ''}" data-status="verified">已核销</span>
                <span class="filter-tab ${param.status == 'refunded' ? 'active' : ''}" data-status="refunded">已退票</span>
                <span class="filter-tab ${param.status == 'cancelled' ? 'active' : ''}" data-status="cancelled">已取消</span>
            </div>
            <c:choose>
                <c:when test="${not empty orders}">
                    <table class="orders-table">
                        <thead>
                            <tr><th>订单号</th><th>漫展名称</th><th>票种</th><th>总金额</th><th>状态</th><th>创建时间</th><th>操作</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${orders}" var="order">
                                <tr>
                                    <td>${order.id}</td>
                                    <td>${order.exhibitionName}</td>
                                    <td>${order.ticketName}</td>
                                    <td>¥${order.totalAmount}</td>
                                    <td><span class="status-badge status-${order.status.toLowerCase()}">
                                        <c:choose><c:when test="${order.status == 'pending'}">待支付</c:when>
                                        <c:when test="${order.status == 'paid'}">已支付</c:when>
                                        <c:when test="${order.status == 'cancelled'}">已取消</c:when>
                                        <c:when test="${order.status == 'refunded'}">已退票</c:when>
                                        <c:when test="${order.status == 'verified'}">已核销</c:when>
                                        <c:when test="${order.status == 'refunding'}">已申请退票</c:when>
                                        <c:otherwise>${order.status}</c:otherwise></c:choose>
                                    </span></td>
                                    <td>${order.createTime}</td>
                                    <td>
                                        <c:if test="${order.status == 'pending'}">
                                            <button class="btn btn-danger" data-order-id="${order.id}" data-action="cancel">取消订单</button>
                                            <button class="btn btn-primary" data-order-id="${order.id}" data-action="pay">支付订单</button>
                                        </c:if>
                                        <c:if test="${order.status == 'paid'}">
                                            <button class="btn btn-primary" data-order-id="${order.id}" data-action="view">查看门票</button>
                                        </c:if>
                                        <c:if test="${order.status == 'paid' || order.status == 'verified'}">
                                            <button class="btn btn-secondary" data-order-id="${order.id}" data-action="refund">申请退票</button>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    <c:set var="currentPage" value="${empty currentPage ? 1 : currentPage}" />
                    <c:set var="totalPages" value="${empty totalPages ? 1 : totalPages}" />
                    <c:if test="${totalPages > 1}">
                        <div class="pagination">
                            <c:if test="${currentPage > 1}"><a href="?page=${currentPage - 1}&status=${param.status}">上一页</a></c:if>
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <c:choose><c:when test="${i == currentPage}"><a href="?page=${i}&status=${param.status}" class="active">${i}</a></c:when>
                                <c:otherwise><a href="?page=${i}&status=${param.status}">${i}</a></c:otherwise></c:choose>
                            </c:forEach>
                            <c:if test="${currentPage < totalPages}"><a href="?page=${currentPage + 1}&status=${param.status}">下一页</a></c:if>
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise><div class="no-data">暂无订单数据，去逛逛漫展吧～</div></c:otherwise>
            </c:choose>
        </div>
        <div id="favoritesPanel" style="display: none;">
            <h3 style="margin-bottom: 20px;">⭐ 我的收藏</h3>
            <div id="favoritesContainer"><div class="no-data">加载中...</div></div>
            <div id="favoritesPagination" style="text-align: center; margin-top: 25px;"></div>
        </div>
    </div>
</div>
<script>
    (function() {
        // 全局函数挂载
        window.searchExhibitions = function() {
            var keyword = document.getElementById('searchInput').value.trim();
            window.location.href = keyword ? '/ticket/index?keyword=' + encodeURIComponent(keyword) : '/ticket/index';
        };
        window.filterOrders = function(status) {
            window.location.href = status === 'all' ? '/ticket/myorders' : '/ticket/myorders?status=' + status;
        };
        window.payOrder = function(orderId) { window.location.href = '/ticket/payment?orderId=' + orderId; };
        window.cancelOrder = function(orderId) {
            if (confirm('确定要取消订单吗？')) {
                $.post('/ticket/cancal', { orderId: orderId }, function(r) { alert(r.message); if(r.success) location.reload(); }).fail(function() { alert('操作失败'); });
            }
        };
        window.verifyTicket = function(orderId) {
            var code = prompt('请输入核销码：');
            if (code) {
                $.post('/adminticket/verifyticket', { verifyCode: code }, function(r) { alert(r.message); if(r.success) location.reload(); });
            }
        };
        window.viewTicket = function(orderId) { alert('查看门票详情成功'); };
        window.applyRefund = function(orderId) {
            if (confirm('确定要申请退票订单吗？')) {
                $.post('/ticket/refundding', { orderId: orderId }, function(r) { alert(r.message); if(r.success) location.reload(); });
            }
        };
        var currentFavPage = 1;
        var favoritesLoaded = false;
        function escapeHtml(str) { if (!str) return ''; return str.replace(/[&<>]/g, function(m) { if(m==='&') return '&amp;'; if(m==='<') return '&lt;'; if(m==='>') return '&gt;'; return m; }); }
        window.loadFavorites = function(page) {
            currentFavPage = page;
            var container = document.getElementById('favoritesContainer');
            container.innerHTML = '<div class="no-data">加载中...</div>';
            fetch('/ticket/getFavorites?page=' + page).then(function(res) {
                if (!res.ok) throw new Error('接口暂未开放');
                return res.json();
            }).then(function(data) {
                if (data.code === 200 && data.data) displayFavorites(data.data.list, data.data.currentPage, data.data.totalPages);
                else throw new Error(data.msg || '暂无收藏');
            }).catch(function(error) {
                console.warn('请求有问题', error);
            });
        };
        window.displayFavorites = function(videos, currentPage, totalPages) {
            var container = document.getElementById('favoritesContainer');
            if (!videos || videos.length === 0) {
                container.innerHTML = '<div class="no-data">暂无收藏，去活动页面点击 收藏吧～</div>';
                document.getElementById('favoritesPagination').innerHTML = '';
                return;
            }
            var html = '<div class="favorites-list">';
            for (var i = 0; i < videos.length; i++) {
                var item = videos[i];
                html += '<div class="favorite-item">' +
                    '<div class="favorite-cover"><img src="' + (item.coverImage || '/static/images/default_cover.png') + '" onerror="this.src=\'/static/images/default_cover.png\'"></div>' +
                    '<div class="favorite-info">' +
                    '<h4><a href="/ticket/detail?id=' + item.id + '">' + escapeHtml(item.title) + '</a></h4>' +
                    '<p>' + escapeHtml(item.description ? (item.description.length > 80 ? item.description.substring(0,80)+'...' : item.description) : '暂无简介') + '</p>' +
                    '<div style="display: flex; gap: 12px; font-size: 13px; color: #718096;">' +
                    '<span></span><span></span></div>' +
                    '<button class="unfavorite-btn" data-id="' + item.id + '">取消收藏</button></div></div>';
            }
            html += '</div>';
            container.innerHTML = html;
            // 绑定取消收藏事件
            var btns = document.querySelectorAll('.unfavorite-btn');
            for (var j = 0; j < btns.length; j++) {
                btns[j].addEventListener('click', function() { window.unfavoriteItem(this.getAttribute('data-id')); });
            }
            var paginationDiv = document.getElementById('favoritesPagination');
            if (totalPages > 1) {
                var pgHtml = '<div style="display: flex; justify-content: center; gap: 6px; margin-top: 20px;">';
                if (currentPage > 1) pgHtml += '<button class="btn btn-secondary" onclick="loadFavorites(' + (currentPage-1) + ')">上一页</button>';
                for (var i = 1; i <= totalPages; i++) {
                    pgHtml += '<button class="btn ' + (i === currentPage ? 'btn-primary' : 'btn-secondary') + '" onclick="loadFavorites(' + i + ')">' + i + '</button>';
                }
                if (currentPage < totalPages) pgHtml += '<button class="btn btn-secondary" onclick="loadFavorites(' + (currentPage+1) + ')">下一页</button>';
                pgHtml += '</div>';
                paginationDiv.innerHTML = pgHtml;
            } else {
                paginationDiv.innerHTML = '';
            }
        };
        window.unfavoriteItem = function(itemId) {
            if (!confirm('确定要取消收藏吗？')) return;
            fetch('/ticket/unfavorite', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: 'id=' + itemId })
                .then(function(res) { return res.json(); })
                .then(function(data) {
                    if (data.success) { alert('已取消收藏'); window.loadFavorites(currentFavPage); }
                    else alert('取消失败：' + (data.message || '未知错误'));
                }).catch(function() { alert('取消收藏'); window.loadFavorites(currentFavPage); });
        };
        // 菜单切换
        var menuOrders = document.getElementById('menuOrders');
        var menuFavorites = document.getElementById('menuFavorites');
        var ordersPanel = document.getElementById('ordersPanel');
        var favoritesPanel = document.getElementById('favoritesPanel');
        function setActiveMenu(active) {
            menuOrders.classList.remove('active-menu');
            menuFavorites.classList.remove('active-menu');
            if (active === 'orders') {
                menuOrders.classList.add('active-menu');
                ordersPanel.style.display = 'block';
                favoritesPanel.style.display = 'none';
            } else {
                menuFavorites.classList.add('active-menu');
                ordersPanel.style.display = 'none';
                favoritesPanel.style.display = 'block';
                if (!favoritesLoaded) { window.loadFavorites(1); favoritesLoaded = true; }
            }
        }
        if (menuOrders) menuOrders.addEventListener('click', function() { setActiveMenu('orders'); });
        if (menuFavorites) menuFavorites.addEventListener('click', function() { setActiveMenu('favorites'); });
        // 订单按钮事件委托
        document.querySelector('#ordersPanel').addEventListener('click', function(e) {
            var btn = e.target.closest('button');
            if (!btn) return;
            var orderId = btn.getAttribute('data-order-id');
            var action = btn.getAttribute('data-action');
            if (orderId && action) {
                e.preventDefault();
                if (action === 'pay') window.payOrder(orderId);
                else if (action === 'cancel') window.cancelOrder(orderId);
                else if (action === 'verify') window.verifyTicket(orderId);
                else if (action === 'view') window.viewTicket(orderId);
                else if (action === 'refund') window.applyRefund(orderId);
            }
        });
        // 筛选标签事件
        var tabs = document.querySelectorAll('.filter-tab');
        for (var k = 0; k < tabs.length; k++) {
            tabs[k].addEventListener('click', function() { window.filterOrders(this.getAttribute('data-status')); });
        }
        // 搜索按钮
        var searchBtn = document.getElementById('searchBtn');
        var searchInput = document.getElementById('searchInput');
        if (searchBtn) searchBtn.addEventListener('click', window.searchExhibitions);
        if (searchInput) searchInput.addEventListener('keypress', function(e) { if (e.key === 'Enter') window.searchExhibitions(); });
        // 初始化
        setActiveMenu('orders');
    })();
</script>
</body>
</html>