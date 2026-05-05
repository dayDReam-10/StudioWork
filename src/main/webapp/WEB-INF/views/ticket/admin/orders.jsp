<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="com.assessment.www.po.User" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    User admin = (User) session.getAttribute("admin");
    String adminUsername = admin != null ? admin.getUsername() : "管理员";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>订单管理</title>
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Arial', 'Microsoft YaHei', sans-serif; background-color: #f5f5f5; color: #333; }
        .header { background-color: #00a1d6; color: white; padding: 12px 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .header a { text-decoration: none; color: inherit; }
        .logo { font-size: 24px; font-weight: bold; letter-spacing: 1px; }
        .search-container { display: flex; gap: 8px; align-items: center; flex: 1; max-width: 400px; }
        .search-input { padding: 8px 12px; border: none; border-radius: 20px; width: 100%; font-size: 14px; outline: none; }
        .search-btn { padding: 6px 16px; background-color: #ff6b6b; color: white; border: none; border-radius: 20px; cursor: pointer; }
        .nav-links { display: flex; gap: 20px; align-items: center; flex-wrap: wrap; }
        .nav-links a { color: white; text-decoration: none; padding: 6px 12px; border-radius: 4px; transition: background 0.3s; }
        .nav-links a:hover { background-color: rgba(255,255,255,0.2); }
        .upload-btn { background-color: #ff6b6b; padding: 6px 16px; border-radius: 20px !important; }
        .welcome-user { font-weight: bold; }
        .main-container { max-width: 1300px; margin: 30px auto; padding: 0 20px; display: flex; gap: 24px; }
        .profile-sidebar { width: 260px; flex-shrink: 0; background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); height: fit-content; position: sticky; top: 20px; }
        .profile-avatar { width: 80px; height: 80px; border-radius: 50%; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); margin: 0 auto 12px; display: flex; justify-content: center; align-items: center; font-size: 36px; font-weight: bold; color: white; }
        .profile-info { text-align: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid #eee; }
        .profile-name { font-size: 18px; font-weight: bold; margin-bottom: 6px; }
        .profile-menu { list-style: none; padding: 0; margin: 0; }
        .profile-menu li { margin-bottom: 8px; }
        .profile-menu a { display: block; padding: 10px 15px; color: #333; text-decoration: none; border-radius: 4px; transition: background-color 0.3s; }
        .profile-menu a:hover { background-color: #00a1d6; color: white; }
        .profile-menu .active-menu { background-color: #00a1d6; color: white; }
        .profile-content { flex: 1; background: white; border-radius: 8px; padding: 24px 28px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); min-height: 500px; }
        .filter-tabs { margin-bottom: 24px; display: flex; flex-wrap: wrap; gap: 10px; border-bottom: 1px solid #e9ecef; padding-bottom: 12px; }
        .filter-tab { padding: 8px 18px; border-radius: 30px; background: #f8f9fa; cursor: pointer; font-size: 14px; transition: all 0.2s; color: #495057; }
        .filter-tab.active { background: #00a1d6; color: white; box-shadow: 0 2px 6px rgba(0,161,214,0.3); }
        .orders-table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px; }
        .orders-table th, .orders-table td { border: 1px solid #dee2e6; padding: 12px 10px; text-align: left; vertical-align: middle; }
        .orders-table th { background-color: #f8f9fa; font-weight: 600; }
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
        .btn-danger { background: #dc3545; color: white; }
        .btn-info { background: #17a2b8; color: white; }
        .btn-success { background: #28a745; color: white; }
        .no-data { text-align: center; padding: 60px 20px; color: #999; font-size: 16px; }
        .pagination { margin-top: 30px; text-align: center; }
        .pagination a, .pagination button { display: inline-block; padding: 6px 12px; margin: 0 4px; border: 1px solid #dee2e6; background: white; color: #00a1d6; text-decoration: none; border-radius: 6px; cursor: pointer; }
        .pagination a.active, .pagination button.active { background: #00a1d6; color: white; border-color: #00a1d6; }
        .refresh-bar { display: flex; justify-content: flex-end; align-items: center; gap: 15px; margin-bottom: 15px; }
        .auto-refresh-toggle { display: flex; align-items: center; gap: 8px; font-size: 13px; }
        .toggle-switch { width: 40px; height: 20px; background: #ccc; border-radius: 20px; position: relative; cursor: pointer; transition: background 0.2s; }
        .toggle-switch.active { background: #00a1d6; }
        .toggle-switch::after { content: ""; width: 18px; height: 18px; background: white; border-radius: 50%; position: absolute; top: 1px; left: 1px; transition: transform 0.2s; }
        .toggle-switch.active::after { transform: translateX(20px); }
        .refresh-time { font-size: 12px; color: #666; }
        @media (max-width: 768px) { .main-container { flex-direction: column; } .profile-sidebar { width: 100%; } .orders-table th, .orders-table td { padding: 8px 6px; font-size: 12px; } .btn { padding: 4px 8px; } }
    </style>
</head>
<body>
<div class="header">
    <div style="font-size: 24px; font-weight: bold;">管理后台</div>
    <div class="nav-links">
        <span class="welcome-admin">管理员: <%= adminUsername %></span>
        <a href="/adminticket/exhibitions">漫展后台</a>
        <a href="/">返回首页</a>
        <a href="/admin/logout">退出登录</a>
    </div>
</div>
<div class="main-container">
    <!-- 左侧菜单 -->
    <div class="profile-sidebar">
        <ul class="profile-menu">
            <li><a href="/admin/adminindex" >数据概览</a></li>
            <li><a href="/admin/users">用户管理</a></li>
            <li><a href="/admin/videos">视频管理</a></li>
            <li><a href="/admin/pending">待审核视频</a></li>
            <li><a href="/admin/banned">被封用户</a></li>
            <li><a href="/admin/reports">举报管理</a></li>
            <hr style="color:red"/>
            <li><a href="/adminticket/exhibitions">漫展管理</a></li>
            <li><a href="/adminticket/orders" class="active-menu">订单管理</a></li>
            <li><a href="/adminticket/statistics">漫展数据统计</a></li>
            <li><a href="/adminticket/consultingUsers">当前咨询用户</a></li>
        </ul>
    </div>
    <div class="profile-content">
        <div id="ordersPanel">
            <!-- 筛选栏 -->
            <div class="filter-tabs">
                <span class="filter-tab ${param.status == null || param.status == 'all' ? 'active' : ''}" data-status="all">全部订单</span>
                <span class="filter-tab ${param.status == 'pending' ? 'active' : ''}" data-status="pending">待支付</span>
                <span class="filter-tab ${param.status == 'paid' ? 'active' : ''}" data-status="paid">已支付</span>
                <span class="filter-tab ${param.status == 'verified' ? 'active' : ''}" data-status="verified">已核销</span>
                <span class="filter-tab ${param.status == 'refunded' ? 'active' : ''}" data-status="refunded">已退票</span>
                <span class="filter-tab ${param.status == 'cancelled' ? 'active' : ''}" data-status="cancelled">已取消</span>
            </div>
            <!-- 自动刷新控制栏 -->
            <div class="refresh-bar">
                <div class="auto-refresh-toggle">
                    <span>自动刷新</span>
                    <div id="autoRefreshSwitch" class="toggle-switch active"></div>
                </div>
                <span id="refreshTimer" class="refresh-time"></span>
                <button id="manualRefreshBtn" class="btn btn-secondary">手动刷新</button>
            </div>
            <!-- 订单表格容器 -->
            <div id="ordersTableContainer">
                <c:choose>
                    <c:when test="${not empty orders}">
                        <table class="orders-table">
                            <thead>
                                <tr><th>订单号</th><th>漫展名称</th><th>票种</th><th>总金额</th><th>状态</th><th>创建时间</th><th>操作</th></tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${orders}" var="order">
                                    <tr data-order-id="${order.id}">
                                        <td>${order.id}</td>
                                        <td>${order.exhibitionName}</td>
                                        <td>${order.ticketName}</td>
                                        <td>¥${order.totalAmount}</td>
                                        <td><span class="status-badge status-${order.status.toLowerCase()}">
                                            <c:choose>
                                                <c:when test="${order.status == 'pending'}">待支付</c:when>
                                                <c:when test="${order.status == 'paid'}">已支付</c:when>
                                                <c:when test="${order.status == 'cancelled'}">已取消</c:when>
                                                <c:when test="${order.status == 'refunded'}">已退票</c:when>
                                                <c:when test="${order.status == 'verified'}">已核销</c:when>
                                                <c:when test="${order.status == 'refunding'}">已申请退票</c:when>
                                                <c:otherwise>${order.status}</c:otherwise>
                                            </c:choose>
                                        </span></td>
                                        <td>${order.createTime}</td>
                                        <td>
                                            <c:if test="${order.status == 'pending'}">
                                                <button class="btn btn-danger" data-order-id="${order.id}" data-action="cancel">取消订单</button>
                                                <button class="btn btn-primary" data-order-id="${order.id}" data-action="pay">支付订单</button>
                                            </c:if>
                                            <c:if test="${order.status == 'paid'}">
                                                <button class="btn btn-info" data-order-id="${order.id}" data-action="verify">核销门票</button>
                                                <button class="btn btn-primary" data-order-id="${order.id}" data-action="view">查看门票</button>
                                            </c:if>
                                            <c:if test="${order.status == 'paid'}">
                                                <button class="btn btn-secondary" data-order-id="${order.id}" data-action="refund">申请退票</button>
                                            </c:if>
                                            <c:if test="${order.status == 'refunding'}">
                                                <button class="btn btn-secondary" data-order-id="${order.id}" data-action="refundsure">确认退票</button>
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
                                <c:if test="${currentPage > 1}"><a href="#" data-page="${currentPage - 1}" class="page-link">上一页</a></c:if>
                                <c:forEach var="i" begin="1" end="${totalPages}">
                                    <c:choose>
                                        <c:when test="${i == currentPage}"><a href="#" data-page="${i}" class="page-link active">${i}</a></c:when>
                                        <c:otherwise><a href="#" data-page="${i}" class="page-link">${i}</a></c:otherwise>
                                    </c:choose>
                                </c:forEach>
                                <c:if test="${currentPage < totalPages}"><a href="#" data-page="${currentPage + 1}" class="page-link">下一页</a></c:if>
                            </div>
                        </c:if>
                    </c:when>
                    <c:otherwise><div class="no-data">暂无订单数据，去逛逛漫展吧～</div></c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>
<script>
    (function() {
        let currentStatus = '${param.status != null ? param.status : "all"}';
        let currentPage = parseInt('${empty currentPage ? 1 : currentPage}');
        let refreshInterval = null;
        let autoRefreshEnabled = true;
        const COUNTDOWN_INTERVAL_SEC = 10;
        let countdownRemaining = COUNTDOWN_INTERVAL_SEC;
        let timerCountdown = null;
        const $ordersContainer = $('#ordersTableContainer');
        const $autoRefreshSwitch = $('#autoRefreshSwitch');
        const $refreshTimer = $('#refreshTimer');
        const $manualRefreshBtn = $('#manualRefreshBtn');
        function getStatusParam() {
            return currentStatus === 'all' ? null : currentStatus;
        }
        function escapeHtml(str) {
            if (str === null || str === undefined) return '';
            str = String(str);
            return str.replace(/[&<>]/g, function(m) {
                if (m === '&') return '&amp;';
                if (m === '<') return '&lt;';
                if (m === '>') return '&gt;';
                return m;
            });
        }
        function loadOrders(keepPage = true) {
            let page = keepPage ? currentPage : 1;
            let url = '/adminticket/orders?format=json&page=' + page;
            let status = getStatusParam();
            if (status) url += '&status=' + status;
            $.get(url, function(resp) {
                if (resp.success) {
                    currentPage = resp.currentPage;
                    renderOrdersTable(resp.orders, resp.currentPage, resp.totalPages);
                } else {
                    console.error('加载订单失败:', resp.message);
                }
            }).fail(function() {
                console.error('请求订单接口失败');
            });
        }
        function renderOrdersTable(orders, curPage, totalPages) {
            if (!orders || orders.length === 0) {
                $ordersContainer.html('<div class="no-data">暂无订单数据，去逛逛漫展吧～</div>');
                return;
            }
            let html = '<table class="orders-table">' +
                '<thead><tr><th>订单号</th><th>漫展名称</th><th>票种</th><th>总金额</th><th>状态</th><th>创建时间</th><th>操作</th></tr></thead><tbody>';
            for (let i = 0; i < orders.length; i++) {
                const o = orders[i];
                let statusText = '', statusClass = '';
                switch (o.status) {
                    case 'pending': statusText = '待支付'; statusClass = 'pending'; break;
                    case 'paid': statusText = '已支付'; statusClass = 'paid'; break;
                    case 'cancelled': statusText = '已取消'; statusClass = 'cancelled'; break;
                    case 'refunded': statusText = '已退票'; statusClass = 'refunded'; break;
                    case 'verified': statusText = '已核销'; statusClass = 'verified'; break;
                    case 'refunding': statusText = '已申请退票'; statusClass = 'refunding'; break;
                    default: statusText = o.status; statusClass = 'pending';
                }
                html += '<tr data-order-id="' + o.id + '">' +
                    '<td>' + escapeHtml(o.id) + '</td>' +
                    '<td>' + escapeHtml(o.exhibitionName || '') + '</td>' +
                    '<td>' + escapeHtml(o.ticketName || '') + '</td>' +
                    '<td>¥' + parseFloat(o.totalAmount || 0).toFixed(2) + '</td>' +
                    '<td><span class="status-badge status-' + statusClass + '">' + statusText + '</span></td>' +
                    '<td>' + escapeHtml(o.createTime || '') + '</td>' +
                    '<td>';
                if (o.status === 'pending') {
                    html += '<button class="btn btn-danger" data-order-id="' + o.id + '" data-action="cancel">取消订单</button> ' +
                        '<button class="btn btn-primary" data-order-id="' + o.id + '" data-action="pay">支付订单</button>';
                } else if (o.status === 'paid') {
                    html += '<button class="btn btn-info" data-order-id="' + o.id + '" data-action="verify">核销门票</button> ' +
                        '<button class="btn btn-primary" data-order-id="' + o.id + '" data-action="view">查看门票</button>';
                }
                if (o.status === 'paid' || o.status === 'verified') {
                    html += ' <button class="btn btn-secondary" data-order-id="' + o.id + '" data-action="refund">申请退票</button>';
                }
                if (o.status === 'refunding') {
                    html += ' <button class="btn btn-secondary" data-order-id="' + o.id + '" data-action="refundsure">确认退票</button>';
                }
                html += '</td></tr>';
            }
            html += '</tbody></table>';
            // 分页
            if (totalPages > 1) {
                html += '<div class="pagination">';
                if (curPage > 1) html += '<a href="#" data-page="' + (curPage - 1) + '" class="page-link">上一页</a>';
                for (let i = 1; i <= totalPages; i++) {
                    if (i === curPage) html += '<a href="#" data-page="' + i + '" class="page-link active">' + i + '</a>';
                    else html += '<a href="#" data-page="' + i + '" class="page-link">' + i + '</a>';
                }
                if (curPage < totalPages) html += '<a href="#" data-page="' + (curPage + 1) + '" class="page-link">下一页</a>';
                html += '</div>';
            }
            $ordersContainer.html(html);
        }
        function refreshOrders() {
            loadOrders(true);
            resetCountdown();
        }
        function updateCountdownDisplay() {
            $refreshTimer.text();
        }
        function resetCountdown() {
            countdownRemaining = COUNTDOWN_INTERVAL_SEC;
            updateCountdownDisplay();
        }
        function startCountdownTicker() {
            if (timerCountdown) clearInterval(timerCountdown);
            resetCountdown();
            timerCountdown = setInterval(function() {
                if (!autoRefreshEnabled) return;
                countdownRemaining--;
                if (countdownRemaining <= 0) {
                    countdownRemaining = COUNTDOWN_INTERVAL_SEC;
                }
                updateCountdownDisplay();
            }, 1000);
        }
        function setAutoRefresh(enable) {
            autoRefreshEnabled = enable;
            if (enable) {
                if (refreshInterval) clearInterval(refreshInterval);
                refreshInterval = setInterval(function() {
                    refreshOrders();
                }, COUNTDOWN_INTERVAL_SEC * 1000);
                startCountdownTicker();
                $autoRefreshSwitch.addClass('active');
                $refreshTimer.text('');
            } else {
                if (refreshInterval) {
                    clearInterval(refreshInterval);
                    refreshInterval = null;
                }
                if (timerCountdown) {
                    clearInterval(timerCountdown);
                    timerCountdown = null;
                }
                $refreshTimer.text('自动刷新已关闭');
                $autoRefreshSwitch.removeClass('active');
            }
        }
        function bindOrderActions() {
            $ordersContainer.off('click', 'button').on('click', 'button', function(e) {
                const $btn = $(this);
                const orderId = $btn.data('order-id');
                const action = $btn.data('action');
                if (!orderId || !action) return;
                e.preventDefault();
                if (action === 'cancel') {
                    if (confirm('确定要取消订单吗？')) {
                        $.post('/ticket/cancal', { orderId: orderId }, function(r) {
                            alert(r.message);
                            if (r.success) refreshOrders();
                        }).fail(() => alert('操作失败'));
                    }
                } else if (action === 'pay') {
                    window.location.href = '/ticket/payment?orderId=' + orderId;
                } else if (action === 'verify') {
                    let code = prompt('请输入核销码：');
                    if (code) {
                        $.post('/adminticket/verifyticket', { verifyCode: code, orderId: orderId }, function(r) {
                            alert(r.message);
                            if (r.success) refreshOrders();
                        });
                    }
                } else if (action === 'view') {
                    alert('查看门票功能开发中');
                } else if (action === 'refund') {
                    if (confirm('确定要申请退票吗？')) {
                        $.post('/ticket/refundding', { orderId: orderId }, function(r) {
                            alert(r.message);
                            if (r.success) refreshOrders();
                        });
                    }
                } else if (action === 'refundsure') {
                    if (confirm('确定要确认退票吗？')) {
                        $.post('/ticket/refund', { orderId: orderId }, function(r) {
                            alert(r.message);
                            if (r.success) refreshOrders();
                        });
                    }
                }
            });
        }
        function bindPagination() {
            $ordersContainer.off('click', '.page-link').on('click', '.page-link', function(e) {
                e.preventDefault();
                const page = $(this).data('page');
                if (page && !isNaN(page)) {
                    currentPage = parseInt(page);
                    loadOrders(true);
                }
            });
        }
        function bindFilterTabs() {
            $('.filter-tab').off('click').on('click', function() {
                const status = $(this).data('status');
                if (status) {
                    currentStatus = status;
                    currentPage = 1;
                    loadOrders(true);
                    $('.filter-tab').removeClass('active');
                    $(this).addClass('active');
                }
            });
        }
        function bindManualRefresh() {
            $manualRefreshBtn.off('click').on('click', function() {
                refreshOrders();
            });
        }
        function bindToggleSwitch() {
            $autoRefreshSwitch.off('click').on('click', function() {
                setAutoRefresh(!autoRefreshEnabled);
            });
        }
        //初始化
        function init() {
            bindFilterTabs();
            bindManualRefresh();
            bindToggleSwitch();
            bindOrderActions();
            bindPagination();
            setAutoRefresh(true);
            $(window).on('beforeunload', function() {
                if (refreshInterval) clearInterval(refreshInterval);
                if (timerCountdown) clearInterval(timerCountdown);
            });
        }
        init();
    })();
</script>
</body>
</html>