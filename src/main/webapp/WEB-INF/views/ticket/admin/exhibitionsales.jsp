<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.assessment.www.po.ticket.Exhibition" %>
<%@ page import="com.assessment.www.po.ticket.Order" %>
<%@ page import="com.assessment.www.po.ticket.Ticket" %>
<%@ page import="com.assessment.www.po.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
    <title>${exhibition.name} - 售票情况</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Arial', 'Microsoft YaHei', sans-serif; background-color: #f5f5f5; color: #333; }
        .header { background-color: #00a1d6; color: white; padding: 12px 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .header a { text-decoration: none; color: inherit; }
        .logo { font-size: 24px; font-weight: bold; letter-spacing: 1px; }
        .nav-links { display: flex; gap: 20px; align-items: center; flex-wrap: wrap; }
        .nav-links a { color: white; text-decoration: none; padding: 6px 12px; border-radius: 4px; transition: background 0.3s; }
        .nav-links a:hover { background-color: rgba(255,255,255,0.2); }
        .welcome-admin { font-weight: bold; }
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
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
        }
        .page-header h1 {
            margin: 0;
            color: #333;
            font-size: 24px;
        }
        .back-btn {
            background-color: #007bff;
            color: white;
            padding: 8px 16px;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }
        .back-btn:hover {
            background-color: #0056b3;
        }
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #00a1d6;
            margin-bottom: 5px;
        }
        .stat-label {
            color: #666;
            font-size: 16px;
        }
        .section {
            background: white;
            border-radius: 8px;
            padding: 20px 0 0 0;
            margin-bottom: 20px;
        }
        .section h2 {
            margin: 0 0 15px 0;
            color: #333;
            font-size: 20px;
            border-left: 4px solid #00a1d6;
            padding-left: 12px;
        }
        .ticket-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        .ticket-stat {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }
        .ticket-name {
            font-weight: bold;
            margin-bottom: 8px;
            color: #333;
            font-size: 16px;
        }
        .ticket-count {
            font-size: 28px;
            color: #00a1d6;
            font-weight: bold;
        }
        .ticket-amount {
            color: #28a745;
            font-weight: bold;
            margin-top: 6px;
            font-size: 14px;
        }
        .orders-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            font-size: 14px;
        }
        .orders-table th, .orders-table td {
            border: 1px solid #dee2e6;
            padding: 12px 10px;
            text-align: left;
            vertical-align: middle;
        }
        .orders-table th {
            background-color: #f8f9fa;
            font-weight: 600;
        }
        .orders-table tr:hover {
            background-color: #f8f9ff;
        }
        .status-badge {
            padding: 4px 10px;
            border-radius: 30px;
            color: white;
            display: inline-block;
            font-size: 12px;
            font-weight: bold;
            min-width: 64px;
            text-align: center;
        }
        .status-pending { background-color: #ffc107; }
        .status-paid { background-color: #28a745; }
        .status-cancelled { background-color: #dc3545; }
        .status-refunded { background-color: #6c757d; }
        .status-verified { background-color: #17a2b8; }
        .status-refunding { background-color: #d13e3e; }
        .no-data { text-align: center; padding: 60px 20px; color: #999; font-size: 16px; }
        @media (max-width: 768px) {
            .main-container { flex-direction: column; }
            .profile-sidebar { width: 100%; }
            .orders-table th, .orders-table td { padding: 8px 6px; font-size: 12px; }
        }
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
    <div class="profile-sidebar">
        <ul class="profile-menu">
            <li><a href="/admin/adminindex">数据概览</a></li>
            <li><a href="/admin/users">用户管理</a></li>
            <li><a href="/admin/videos">视频管理</a></li>
            <li><a href="/admin/pending">待审核视频</a></li>
            <li><a href="/admin/banned">被封用户</a></li>
            <li><a href="/admin/reports">举报管理</a></li>
            <hr style="margin: 10px 0; border-color: #e0e0e0;" />
            <li><a href="/adminticket/exhibitions" class="active-menu">漫展管理</a></li>
            <li><a href="/adminticket/orders">订单管理</a></li>
            <li><a href="/adminticket/statistics">漫展数据统计</a></li>
            <li><a href="/adminticket/consultingUsers">当前咨询用户</a></li>
        </ul>
    </div>
    <div class="profile-content">
        <div class="page-header">
            <h1>${exhibition.name} - 售票情况</h1>
            <a href="/adminticket/exhibitions" class="back-btn">返回漫展管理</a>
        </div>
        <!-- 统计数据卡片 -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-number">${totalOrders}</div>
                <div class="stat-label">总订单数</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${paidOrders}</div>
                <div class="stat-label">已支付订单</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${cancelledOrders}</div>
                <div class="stat-label">已取消订单</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="¥"/></div>
                <div class="stat-label">总收入</div>
            </div>
        </div>
        <!-- 票种销售情况 -->
        <div class="section">
            <h2>票种销售情况</h2>
            <div class="ticket-stats">
                <c:forEach items="${tickets}" var="ticket">
                    <div class="ticket-stat">
                        <div class="ticket-name">${ticket.name}</div>
                        <div class="ticket-count">${ticketSalesCount[ticket.id]}</div>
                        <div class="ticket-amount">
                            <fmt:formatNumber value="${ticketSalesAmount[ticket.id]}" type="currency" currencySymbol="¥"/>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
        <!-- 订单列表 -->
        <div class="section">
            <h2>订单列表</h2>
            <c:choose>
                <c:when test="${not empty orders}">
                    <table class="orders-table">
                        <thead>
                            <tr>
                                <th>订单号</th>
                                <th>用户名</th>
                                <th>订单金额</th>
                                <th>订单状态</th>
                                <th>创建时间</th>
                                <th>支付时间</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${orders}" var="order">
                                <tr>
                                    <td>${order.id}</td>
                                    <td>${order.userName}</td>
                                    <td><fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="¥"/></td>
                                    <td>
                                        <span class="status-badge status-${order.status.toLowerCase()}">
                                            <c:choose>
                                                <c:when test="${order.status == 'pending'}">待支付</c:when>
                                                <c:when test="${order.status == 'paid'}">已支付</c:when>
                                                <c:when test="${order.status == 'cancelled'}">已取消</c:when>
                                                <c:when test="${order.status == 'refunded'}">已退票</c:when>
                                                <c:when test="${order.status == 'verified'}">已核销</c:when>
                                                <c:when test="${order.status == 'refunding'}">已申请退票</c:when>
                                                <c:otherwise>${order.status}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>
                                    <td><fmt:formatDate value="${order.createTime}" pattern="yyyy-MM-dd HH:mm:ss"/></td>
                                    <td>
                                        <c:if test="${order.payTime != null}">
                                            <fmt:formatDate value="${order.payTime}" pattern="yyyy-MM-dd HH:mm:ss"/>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="no-data">暂无订单数据</div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
</body>
</html>