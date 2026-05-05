<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.Report" %>
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
    <title>举报管理</title>
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
        .report-table-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            overflow-x: auto;
        }
        .report-table {
            width: 100%;
            border-collapse: collapse;
        }
        .report-table th,
        .report-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        .report-table th {
            background-color: #f8f9fa;
            font-weight: bold;
            color: #333;
        }
        .report-table tr:hover {
            background-color: #f8f9fa;
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        .status-processed {
            background-color: #d4edda;
            color: #155724;
        }
        .status-rejected {
            background-color: #f8d7da;
            color: #721c24;
        }
        .type-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            background-color: #e2e3e5;
            color: #495057;
        }
        .btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
            margin-right: 5px;
        }
        .btn-approve {
            background-color: #28a745;
            color: white;
        }
        .btn-approve:hover {
            background-color: #218838;
        }
        .btn-reject {
            background-color: #dc3545;
            color: white;
        }
        .btn-reject:hover {
            background-color: #c82333;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 20px;
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
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }
        .search-box {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .search-box input {
            flex: 1;
            max-width: 300px;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .search-box select {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
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
                                                             <li><a href="/admin/users">用户管理</a></li>
                                                             <li><a href="/admin/videos">视频管理</a></li>
                                                             <li><a href="/admin/pending" >待审核视频</a></li>
                                                             <li><a href="/admin/banned" >被封用户</a></li>
                                                             <li><a href="/admin/reports" class="active">举报管理</a></li>
                                                             <hr style="color:red"/>
                                                             <li><a href="/adminticket/exhibitions">漫展管理</a></li>
                                                             <li><a href="/adminticket/orders">订单管理</a></li>
                                                             <li><a href="/adminticket/statistics">漫展数据统计</a></li>
                <li><a href="/adminticket/consultingUsers">当前咨询用户</a></li>
            </ul>
        </div>
        <div class="content">
            <h2>举报管理</h2>
            <div class="report-table-container">
                <table class="report-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>举报人</th>
                             <th>举报视频标题</th>
                            <th>举报内容</th>
                            <th>举报时间</th>
                            <th>状态</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Report> reports = (List<Report>) request.getAttribute("reports");
                            if (reports != null && !reports.isEmpty()) {
                                for (Report report : reports) {
                        %>
                        <tr data-report-id="<%= report.getId() %>">
                            <td><%= report.getId() %></td>
                            <td>
                                <img src='<%= report.getReporter() != null ? report.getReporter().getAvatarUrl() : "/static/images/default_avatar.png" %>'
                                     alt="举报人头像" class="user-avatar">
                                <%= report.getReporter() != null ? report.getReporter().getUsername() : "未知" %>
                            </td>
                            <td>
                                 <%= report.getVideo() != null ? report.getVideo().getTitle() : "未知" %>
                            </td>
                            <td><%= report.getReasonDetail() != null ? report.getReasonDetail().substring(0, Math.min(50, report.getReasonDetail().length())) + (report.getReasonDetail().length() > 50 ? "..." : "") : "无" %></td>
                            <td><%= report.getTimeCreate() != null ? report.getTimeCreate().toString() : "未知" %></td>
                            <td>
                                <span class="status-badge <%=
                                    report.getStatus() != null && report.getStatus() == 0 ? "status-pending" :
                                    report.getStatus() != null && report.getStatus() == 1 ? "status-processed" :
                                    "status-rejected" %>">
                                    <%= report.getStatus() != null && report.getStatus() == 0 ? "待处理" :
                                       report.getStatus() != null && report.getStatus() == 1 ? "已处理" :
                                       "已拒绝" %>
                                </span>
                            </td>
                            <td class="report-actions">
                                <%
                                    if (report.getStatus() != null && report.getStatus() == 0) {
                                %>
                                <button class="btn btn-approve" onclick="processReport(<%= report.getId() %>, '1')">通过</button>
                                <button class="btn btn-reject" onclick="processReport(<%= report.getId() %>, '2')">拒绝</button>
                                <%
                                    } else if (report.getStatus() != null && report.getStatus() == 1) {
                                %>
                                <span style="color: #666;">已处理</span>
                                <%
                                    } else if (report.getStatus() != null && report.getStatus() == 2) {
                                %>
                                <span style="color: #666;">已拒绝</span>
                                <%
                                    } else {
                                %>
                                <span style="color: #666;">无操作</span>
                                <%
                                    }
                                %>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 40px; color: #666;">
                                暂无举报数据
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <div class="pagination">
                    <%
                        int currentPage = (Integer) request.getAttribute("currentPage");
                        int totalPages = (Integer) request.getAttribute("totalPages");
                        // 上一页
                        if (currentPage > 1) {
                    %>
                    <a href="/admin/reports?page=<%= currentPage - 1 %>">上一页</a>
                    <%
                        }
                        // 页码
                        for (int i = 1; i <= totalPages; i++) {
                            if (i == currentPage) {
                    %>
                    <a href="/admin/reports?page=<%= i %>" class="active"><%= i %></a>
                    <%
                            } else {
                    %>
                    <a href="/admin/reports?page=<%= i %>"><%= i %></a>
                    <%
                            }
                        }
                        // 下一页
                        if (currentPage < totalPages) {
                    %>
                    <a href="/admin/reports?page=<%= currentPage + 1 %>">下一页</a>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
   <script>
       // 处理举报
       function processReport(reportId, action) {
           const actionText = action === '1' ? '通过' : '拒绝';
           if (confirm(`确定要${actionText}这个举报吗？`)) {
               fetch('/admin/processReport', {
                   method: 'POST',
                   headers: {
                       'Content-Type': 'application/x-www-form-urlencoded',
                   },
                   body: 'reportId='+reportId+'&action='+action
               }).then(response => response.json()).then(data => {
                   if (data.success) {
                       alert(actionText+'成功');
                       const reportRow = document.querySelector('tr[data-report-id="' + reportId + '"]');
                       if (reportRow) {
                           const statusCell = reportRow.querySelector('.status-badge');
                           if (statusCell) {
                               statusCell.className = 'status-badge ' + (action === '1' ? 'status-processed' : 'status-rejected');
                               statusCell.textContent = action === '1' ? '已处理' : '已拒绝';
                           }
                           const actionCell = reportRow.querySelector('.report-actions');
                           if (actionCell) {
                               actionCell.innerHTML = '<span style="color: #666;">' + (action === '1' ? '已处理' : '已拒绝') + '</span>';
                           }
                       }
                   } else {
                       alert('操作失败: ' + (data.message || '未知错误'));
                   }
               }).catch(error => {
                   alert('操作失败: ' + error);
               });
           }
       }
       // 搜索举报
       function searchReports(keyword, type) {
           if (keyword.length < 2 && type !== 'reporter' && type !== 'reported') {
               window.location.href = '/admin/reports';
               return;
           }
           debugger
           let url = '/admin/reports?';
           const params = new URLSearchParams();
           if (keyword.length >= 2) {
               params.append(type + 'Search', keyword);
           }
           // 获取URL中的其他参数
           const urlParams = new URLSearchParams(window.location.search);
           const searchParam = urlParams.get('search');
           const typeParam = urlParams.get('type');
           const statusParam = urlParams.get('status');
           const pageParam = urlParams.get('page');
           if (searchParam) params.append('search', searchParam);
           if (typeParam) params.append('type', typeParam);
           if (statusParam) params.append('status', statusParam);
           if (pageParam) params.append('page', pageParam);
           window.location.href = url + params.toString();
       }
       // 按类型筛选
       function filterByType(type) {
           window.location.href = '/admin/reports?type=' + type;
       }
       // 按状态筛选
       function filterByStatus(status) {
           window.location.href = '/admin/reports?status=' + status;
       }
   </script>
</body>
</html>