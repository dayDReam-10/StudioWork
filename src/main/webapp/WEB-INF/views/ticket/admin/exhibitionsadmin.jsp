<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.ticket.Exhibition" %>
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
    <title>漫展管理</title>
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
            display: flex;
            gap: 20px;
        }
        .sidebar {
            width: 250px;
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            height: fit-content;
        }
        .sidebar-menu {
            list-style: none;
            padding: 0;
        }
        .sidebar-menu li {
            margin-bottom: 10px;
        }
        .sidebar-menu a {
            display: block;
            padding: 10px 15px;
            color: #333;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }
        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background-color: #00a1d6;
            color: white;
        }
        .content {
            flex: 1;
        }
        .page-header {
            margin-bottom: 30px;
        }
        .page-header h1 {
            margin: 0;
            color: #333;
            font-size: 28px;
        }
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            text-align: center;
        }
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #00a1d6;
            margin-bottom: 5px;
        }
        .stat-label {
            color: #666;
            font-size: 14px;
        }
        .btn-add {
            background-color: #28a745;
            color: white;
            text-decoration: none;
            padding: 10px 20px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: inline-block;
            transition: background-color 0.3s;
        }
        .btn-add:hover {
            background-color: #218838;
        }
        .filter-box {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
        }
        .filter-box input,
        .filter-box select {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .exhibition-grid-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .exhibition-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
        }
        .exhibition-card {
            border: 1px solid #eee;
            border-radius: 8px;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
            background: white;
        }
        .exhibition-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .exhibition-cover {
            height: 200px;
            width: 100%;
            object-fit: cover;
            background-color: #f0f0f0;
        }
        .exhibition-info {
            padding: 15px;
        }
        .exhibition-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        .exhibition-type {
            display: inline-block;
            padding: 4px 8px;
            background-color: #e3f2fd;
            color: #1976d2;
            border-radius: 4px;
            font-size: 12px;
            margin-bottom: 10px;
        }
        .exhibition-meta {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-bottom: 10px;
            font-size: 14px;
            color: #666;
        }
        .exhibition-meta span {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .exhibition-description {
            color: #666;
            font-size: 14px;
            line-height: 1.5;
            margin-bottom: 15px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .exhibition-status {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .status-active {
            background-color: #d4edda;
            color: #155724;
        }
        .status-ended {
            background-color: #f8d7da;
            color: #721c24;
        }
        .status-upcoming {
            background-color: #d1ecf1;
            color: #0c5460;
        }
        .status-cancelled {
            background-color: #e2e3e5;
            color: #383d41;
        }
        .btn-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
            flex: 1;
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
        .btn-warning {
            background-color: #ffc107;
            color: #212529;
        }
        .btn-warning:hover {
            background-color: #e0a800;
        }
        .btn-danger {
            background-color: #dc3545;
            color: white;
        }
        .btn-danger:hover {
            background-color: #c82333;
        }
        .btn-success {
            background-color: #28a745;
            color: white;
        }
        .btn-success:hover {
            background-color: #218838;
        }
        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 10px;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 30px;
        }
        .pagination a {
            padding: 8px 12px;
            text-decoration: none;
            border: 1px solid #ddd;
            border-radius: 4px;
            color: #333;
        }
        .pagination a.active {
            background-color: #00a1d6;
            color: white;
            border-color: #00a1d6;
        }
        .pagination a:hover:not(.active) {
            background-color: #f5f5f5;
        }
        .welcome-admin {
            color: white;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="header">
        <div style="font-size: 24px; font-weight: bold;">管理后台</div>
        <div class="nav-links">
            <span class="welcome-admin">管理员: <%= adminUsername %></span>
            <a href="/">返回首页</a>
            <a href="/admin/logout">退出登录</a>
        </div>
    </div>
    <div class="main-container">
        <div class="sidebar">
            <ul class="sidebar-menu">
                  <li><a href="/admin/adminindex" >数据概览</a></li>
                  <li><a href="/admin/users" >用户管理</a></li>
                  <li><a href="/admin/videos" >视频管理</a></li>
                  <li><a href="/admin/pending" >待审核视频</a></li>
                  <li><a href="/admin/banned" >被封用户</a></li>
                  <li><a href="/admin/reports" >举报管理</a></li>
                  <hr style="color:red"/>
                  <li><a href="/adminticket/exhibitions" class="active">漫展管理</a></li>
                  <li><a href="/adminticket/orders">订单管理</a></li>
                  <li><a href="/adminticket/statistics">漫展数据统计</a></li>
                  <li><a href="/adminticket/consultingUsers">当前咨询用户</a></li>
            </ul>
        </div>
        <div class="content">
            <div class="page-header">
                <h1>漫展管理</h1>
            </div>
            <!-- 统计数据 -->
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-number">${totalExhibitions}</div>
                    <div class="stat-label">总漫展数</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">${activeExhibitions}</div>
                    <div class="stat-label">进行中</div>
                </div>
            </div>
            <a href="/adminticket/add" class="btn-add">添加新漫展</a>
            <div class="filter-box">
                <input type="text" placeholder="搜索漫展名称..." onkeyup="searchExhibitions(this.value)">
                <select onchange="filterByStatus(this.value)">
                    <option value="">全部状态</option>
                    <option value=1>进行中</option>
                    <option value=3>已结束</option>
                    <option value=2>已取消</option>
                </select>
                <select onchange="filterByType(this.value)">
                    <option value="">全部类型</option>
                    <option value="动漫展">动漫展</option>
                    <option value="游戏展">游戏展</option>
                    <option value="同人展">同人展</option>
                    <option value="漫展">漫展</option>
                    <option value="其他">其他</option>
                </select>
            </div>
            <div class="exhibition-grid-container">
                <div class="exhibition-grid">
                    <c:if test="${not empty exhibitions}">
                        <c:forEach items="${exhibitions}" var="exhibition">
                            <div class="exhibition-card">
                                <img src="${exhibition.coverImage != null ? exhibition.coverImage : '/images/default-exhibition.jpg'}"
                                     alt="漫展封面" class="exhibition-cover">
                                <div class="exhibition-info">
                                    <span class="exhibition-status status-${exhibition.status}">
                                        <c:choose>
                                            <c:when test="${exhibition.status == 1}">进行中</c:when>
                                            <c:when test="${exhibition.status == 3}">已结束</c:when>
                                            <c:when test="${exhibition.status == 2}">已取消</c:when>
                                            <c:otherwise>草稿</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <h3 class="exhibition-title">${exhibition.name}</h3>
                                    <span class="exhibition-type">${exhibition.type}</span>
                                    <div class="exhibition-meta">
                                        <span>📍 ${exhibition.address}</span>
                                        <span>📞 ${exhibition.contactPhone}</span>
                                        <span>🕐 <fmt:formatDate value="${exhibition.startTime}" pattern="yyyy-MM-dd HH:mm"/></span>
                                        <span>⏰ <fmt:formatDate value="${exhibition.endTime}" pattern="yyyy-MM-dd HH:mm"/></span>
                                    </div>
                                    <p class="exhibition-description">${exhibition.description}</p>
                                    <div class="btn-actions">
                                        <button class="btn btn-primary" onclick="viewExhibition(${exhibition.id})">查看详情</button>
                                        <button class="btn btn-info" onclick="editExhibition(${exhibition.id})">编辑</button>
                                    </div>
                                    <div class="action-buttons">
                                        <button class="btn btn-success" onclick="viewSales(${exhibition.id})">售票情况</button>
                                        <button class="btn btn-warning" onclick="viewVerify(${exhibition.id})">核销情况</button>
                                        <button class="btn btn-warning" onclick="endExhibition(${exhibition.id})"
                                                <c:if test="${exhibition.status == 3}">disabled</c:if>>
                                            <c:choose>
                                                <c:when test="${exhibition.status == 3}">已结束</c:when>
                                                <c:otherwise>结束</c:otherwise>
                                            </c:choose>
                                        </button>
                                        <button class="btn btn-danger" onclick="deleteExhibition(${exhibition.id})">删除</button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:if>
                    <c:if test="${empty exhibitions}">
                        <div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #666;">
                            暂无漫展数据
                        </div>
                    </c:if>
                </div>
                <div class="pagination">
                    <c:if test="${currentPage > 1}">
                        <a href="/adminticket/exhibitions?page=${currentPage - 1}">上一页</a>
                    </c:if>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <a href="/adminticket/exhibitions?page=${i}" class="active">${i}</a>
                            </c:when>
                            <c:otherwise>
                                <a href="/adminticket/exhibitions?page=${i}">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <a href="/adminticket/exhibitions?page=${currentPage + 1}">下一页</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
<script>
    // 查看漫展详情
    function viewExhibition(exhibitionId) {
        window.open('/ticket/exhibition-details?id=' + exhibitionId, '_blank');
    }
    // 编辑漫展
    function editExhibition(exhibitionId) {
        window.location.href = '/adminticket/exhibitions/edit?id=' + exhibitionId;
    }
    // 激活漫展
    function activateExhibition(exhibitionId) {
        if (confirm('确定要激活这个漫展吗？')) {
            fetch('/adminticket/activateExhibition', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'id=' + exhibitionId
            }).then(response => response.text()).then(result => {
                if (result === 'success') {
                    alert('漫展已激活');
                    location.reload();
                } else {
                    alert('操作失败: ' + result);
                }
            }).catch(error => {
                alert('操作失败: ' + error);
            });
        }
    }
    // 结束漫展
    function endExhibition(exhibitionId) {
        if (confirm('确定要结束这个漫展吗？结束后将不能再售票。')) {
            fetch('/adminticket/endExhibition', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'id=' + exhibitionId
            }).then(response => response.text()).then(result => {
                if (result === 'success') {
                    alert('漫展已结束');
                    location.reload();
                } else {
                    alert('操作失败: ' + result);
                }
            }).catch(error => {
                alert('操作失败: ' + error);
            });
        }
    }
    // 删除漫展
    function deleteExhibition(exhibitionId) {
        if (confirm('确定要删除这个漫展吗？删除后不可恢复！')) {
            fetch('/adminticket/deleteExhibition', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'id=' + exhibitionId
            }).then(response => response.json()).then(data => {
              if (data.success) {
                              alert('漫展已删除');
                              location.reload();
              } else {
                              alert('删除失败: ' + (data.message || '未知错误'));
             }
            }).catch(error => {
                alert('删除失败: ' + error);
            });
        }
    }
    // 搜索漫展
    function searchExhibitions(keyword) {
        if (keyword.length < 2) {
            window.location.href = '/adminticket/exhibitions';
            return;
        }
        window.location.href = '/adminticket/exhibitions?search=' + encodeURIComponent(keyword);
    }
    // 按状态筛选
    function filterByStatus(status) {
        window.location.href = '/adminticket/exhibitions?status=' + encodeURIComponent(status);
    }
    // 按类型筛选
    function filterByType(type) {
        window.location.href = '/adminticket/exhibitions?type=' + encodeURIComponent(type);
    }
    // 查看售票情况
    function viewSales(exhibitionId) {
        window.location.href = '/adminticket/exhibition-sales?id=' + exhibitionId;
    }
    // 查看核销情况
    function viewVerify(exhibitionId) {
        window.location.href = '/adminticket/exhibition-verify?id=' + exhibitionId;
    }
</script>
</body>
</html>