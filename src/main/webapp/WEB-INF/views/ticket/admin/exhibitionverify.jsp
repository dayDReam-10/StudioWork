<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.assessment.www.po.ticket.Exhibition" %>
<%@ page import="com.assessment.www.po.ticket.Order" %>
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
    <title>${exhibition.name} - 核销情况</title>
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
        .verify-rate {
            background: #e3f2fd;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 20px;
        }
        .verify-rate .number {
            font-size: 48px;
            font-weight: bold;
            color: #1976d2;
            margin-bottom: 5px;
        }
        .verify-rate .label {
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
        .verify-details-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            font-size: 14px;
        }
        .verify-details-table th, .verify-details-table td {
            border: 1px solid #dee2e6;
            padding: 12px 10px;
            text-align: left;
            vertical-align: middle;
        }
        .verify-details-table th {
            background-color: #f8f9fa;
            font-weight: 600;
        }
        .verify-details-table tr:hover {
            background-color: #f8f9ff;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 30px;
            font-size: 12px;
            font-weight: bold;
            min-width: 70px;
            text-align: center;
        }
        .status-verified {
            background-color: #d4edda;
            color: #155724;
        }
        .status-unverified {
            background-color: #fff3cd;
            color: #856404;
        }
        .verify-code {
            font-family: monospace;
            background: #f8f9fa;
            padding: 4px 8px;
            border-radius: 4px;
            border: 1px solid #dee2e6;
            font-size: 13px;
        }
        .action-buttons {
            display: flex;
            gap: 10px;
        }
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary {
            background-color: #007bff;
            color: white;
        }
        .btn-primary:hover {
            background-color: #0056b3;
        }
        .btn-info {
            background-color: #17a2b8;
            color: white;
        }
        .btn-info:hover {
            background-color: #138496;
        }
        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #999;
            font-size: 16px;
        }
        @media (max-width: 768px) {
            .main-container { flex-direction: column; }
            .profile-sidebar { width: 100%; }
            .verify-details-table th, .verify-details-table td { padding: 8px 6px; font-size: 12px; }
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
            <h1>${exhibition.name} - 核销情况</h1>
            <a href="/adminticket/exhibitions" class="back-btn">返回漫展管理</a>
        </div>
        <!-- 统计数据 -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-number">${totalTickets}</div>
                <div class="stat-label">总票数</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${verifiedTickets}</div>
                <div class="stat-label">已核销</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${unverifiedTickets}</div>
                <div class="stat-label">未核销</div>
            </div>
        </div>
        <!-- 核销率 -->
        <div class="verify-rate">
            <div class="number">${verifyRate}%</div>
            <div class="label">核销率</div>
        </div>
        <!-- 核销详情 -->
        <div class="section">
            <h2>核销详情</h2>
            <c:if test="${empty orderVerifyDetails}">
                <div class="no-data">暂无核销数据</div>
            </c:if>
            <c:if test="${not empty orderVerifyDetails}">
                <table class="verify-details-table">
                    <thead>
                        <tr>
                            <th>订单号</th>
                            <th>用户名</th>
                            <th>票种名称</th>
                            <th>数量</th>
                            <th>金额</th>
                            <th>核销码</th>
                            <th>核销状态</th>
                            <th>创建时间</th>
                            <th>核销时间</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${orderVerifyDetails}" var="order">
                            <tr>
                                <td>${order.id}</td>
                                <td>${order.userName}</td>
                                <td>${order.ticketName}</td>
                                <td>${order.quantity}</td>
                                <td><fmt:formatNumber value="${order.totalPrice}" type="currency" currencySymbol="¥"/></td>
                                <td>
                                    <c:if test="${not empty order.verifyCode}">
                                        <span class="verify-code">${order.verifyCode}</span>
                                    </c:if>
                                </td>
                                <td>
                                    <span class="status-badge status-${order.verifyStatus == 1 ? 'verified' : 'unverified'}">
                                        <c:choose>
                                            <c:when test="${order.verifyStatus == 0}">已退票</c:when>
                                            <c:when test="${order.verifyStatus == 1}">已核销</c:when>
                                            <c:otherwise>无</c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>
                                <td><fmt:formatDate value="${order.createTime}" pattern="yyyy-MM-dd HH:mm:ss"/></td>
                                <td>
                                    <c:if test="${not empty order.verifyTime}">
                                        <fmt:formatDate value="${order.verifyTime}" pattern="yyyy-MM-dd HH:mm:ss"/>
                                    </c:if>
                                 </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:if>
        </div>
    </div>
</div>
</body>
</html>