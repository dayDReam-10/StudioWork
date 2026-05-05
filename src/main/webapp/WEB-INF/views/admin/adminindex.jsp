<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.assessment.www.po.Video" %>
<%@ page import="com.assessment.www.po.User" %>
<%@ page import="com.assessment.www.po.Report" %>
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
    <title>管理后台</title>
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
        .stats-grid {
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
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .stat-value {
            font-size: 36px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .stat-label {
            color: #666;
            font-size: 14px;
        }
        .stat-card.blue {
            border-left: 4px solid #00a1d6;
        }
        .stat-card.blue .stat-value {
            color: #00a1d6;
        }
        .stat-card.green {
            border-left: 4px solid #28a745;
        }
        .stat-card.green .stat-value {
            color: #28a745;
        }
        .stat-card.orange {
            border-left: 4px solid #ffc107;
        }
        .stat-card.orange .stat-value {
            color: #ffc107;
        }
        .stat-card.red {
            border-left: 4px solid #dc3545;
        }
        .stat-card.red .stat-value {
            color: #dc3545;
        }
        .stat-card.purple {
            border-left: 4px solid #6f42c1;
        }
        .stat-card.purple .stat-value {
            color: #6f42c1;
        }
        .stat-card.teal {
            border-left: 4px solid #20c997;
        }
        .stat-card.teal .stat-value {
            color: #20c997;
        }
        .pending-section {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-top: 30px;
        }
        .pending-title {
            font-size: 18px;
            margin-bottom: 20px;
            color: #333;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .pending-title::before {
            content: '';
            width: 4px;
            height: 20px;
            background-color: #00a1d6;
            border-radius: 2px;
        }
        .section-title {
            color: #333;
            margin-bottom: 20px;
            margin-top: 30px;
            font-size: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .section-title::before {
            content: '';
            width: 4px;
            height: 20px;
            background-color: #00a1d6;
            border-radius: 2px;
        }
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        .video-card {
            border: 1px solid #eee;
            border-radius: 8px;
            padding: 15px;
            transition: transform 0.3s;
        }
        .video-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .video-title {
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        .video-actions {
            display: flex;
            gap: 10px;
            margin-top: 10px;
        }
        .btn {
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        .btn-approve {
            background-color: #4ecdc4;
            color: white;
        }
        .btn-reject {
            background-color: #ff6b6b;
            color: white;
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
             <a href="/adminticket/exhibitions">漫展后台</a>
            <a href="/">返回首页</a>
            <a href="javascript:void(0);" onclick="logoutAndClearCache()">退出登录</a>
        </div>
    </div>
    <div class="main-container">
        <div class="sidebar">
            <ul class="sidebar-menu">
                <li><a href="/admin/adminindex" class="active">数据概览</a></li>
                <li><a href="/admin/users">用户管理</a></li>
                <li><a href="/admin/videos">视频管理</a></li>
                <li><a href="/admin/pending">待审核视频</a></li>
                <li><a href="/admin/banned">被封用户</a></li>
                <li><a href="/admin/reports">举报管理</a></li>
                <hr style="color:red"/>
                <li><a href="/adminticket/exhibitions">漫展管理</a></li>
                <li><a href="/adminticket/orders">订单管理</a></li>
                <li><a href="/adminticket/statistics">漫展数据统计</a></li>
                <li><a href="/adminticket/consultingUsers">当前咨询用户</a></li>
            </ul>
        </div>
        <div class="content">
            <h2>数据概览</h2>
            <div class="stats-grid">
                <!-- 用户统计 -->
                <div class="stat-card blue">
                    <div class="stat-value">${totalUsers}</div>
                    <div class="stat-label">用户总数</div>
                </div>
                <!-- 视频统计 -->
                <div class="stat-card blue">
                    <div class="stat-value">${totalVideos}</div>
                    <div class="stat-label">视频总数</div>
                </div>
                <div class="stat-card green">
                    <div class="stat-value">${approvedVideos}</div>
                    <div class="stat-label">已通过审核</div>
                </div>
                <div class="stat-card red">
                    <div class="stat-value">${pendingVideos.size()}</div>
                    <div class="stat-label">待审核视频</div>
                </div>
                <!-- 互动数据 -->
                <div class="stat-card purple">
                    <div class="stat-value">${totalViews}</div>
                    <div class="stat-label">总播放量</div>
                </div>
                <div class="stat-card orange">
                    <div class="stat-value">${totalLikes}</div>
                    <div class="stat-label">总点赞数</div>
                </div>
                <div class="stat-card teal">
                    <div class="stat-value">${totalFavorites}</div>
                    <div class="stat-label">总收藏数</div>
                </div>
                <div class="stat-card green">
                    <div class="stat-value">${totalComments}</div>
                    <div class="stat-label">总评论数</div>
                </div>
                <div class="stat-card orange">
                    <div class="stat-value">${totalCoins}</div>
                    <div class="stat-label">投币总数</div>
                </div>
            </div>
            <!-- 举报数据 -->
            <div class="stats-grid">
                <div class="stat-card red">
                    <div class="stat-value">${pendingReportCount}</div>
                    <div class="stat-label">待处理举报</div>
                </div>
                <div class="stat-card green">
                    <div class="stat-value">${( totalReports - pendingReportCount)}</div>
                    <div class="stat-label">已处理举报</div>
                </div>
                <div class="stat-card purple">
                    <div class="stat-value">${totalReports}</div>
                    <div class="stat-label">举报总数</div>
                </div>
            </div>
            <div class="section-title">待审核视频</div>
            <div class="pending-section">
                <h3 class="pending-title"></h3>
                <%
                    List<Video> pendingVideos = (List<Video>) request.getAttribute("pendingVideos");
                    if (pendingVideos != null && !pendingVideos.isEmpty()) {
                %>
                <div class="video-grid">
                    <%
                        for (Video video : pendingVideos) {
                    %>
                    <div class="video-card">
                        <div class="video-title"><%= video.getTitle() %></div>
                        <p>作者: <%= video.getAuthor() != null ? video.getAuthor().getUsername() : "未知" %></p>
                        <p>上传时间: <%= video.getTimeCreate() != null ? video.getTimeCreate().toString() : "未知" %></p>
                        <div class="video-actions">
                            <button class="btn btn-approve" onclick="approveVideo(<%= video.getId() %>)">通过</button>
                            <button class="btn btn-reject" onclick="rejectVideo(<%= video.getId() %>)">驳回</button>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
                <%
                    } else {
                %>
                <p>暂无待审核视频</p>
                <%
                    }
                %>
            </div>
            <div class="section-title">举报数据</div>
            <div class="pending-section">
                <%
                    List<Report> pendingReports = (List<Report>) request.getAttribute("pendingReports");
                    List<Report> processedReports = (List<Report>) request.getAttribute("processedReports");
                %>
                <h3 style="color: #dc3545; margin-bottom: 20px;">待处理举报</h3>
                <%
                    if (pendingReports != null && !pendingReports.isEmpty()) {
                %>
                    <div id="pendingReportsGrid" class="video-grid" style="grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));">
                    <%
                        for (Report report : pendingReports) {
                    %>
                    <div class="video-card" data-report-id="<%= report.getId() %>">
                        <div class="video-title">待处理举报 #<%= report.getId() %></div>
                        <p>举报对象: <%= report.getVideo() != null ? report.getVideo().getTitle() : "未知" %></p>
                        <p>举报人: <%= report.getReporter() != null ? report.getReporter().getUsername() : "未知" %></p>
                        <p>举报时间: <%= report.getTimeCreate() != null ? report.getTimeCreate().toString() : "未知" %></p>
                        <p>举报内容: <%= report.getReasonDetail() != null ? report.getReasonDetail().substring(0, Math.min(50, report.getReasonDetail().length())) + (report.getReasonDetail().length() > 50 ? "..." : "") : "无" %></p>
                        <div class="video-actions">
                            <button class="btn btn-approve" onclick="processReport(<%= report.getId() %>, '1')">通过</button>
                            <button class="btn btn-reject" onclick="processReport(<%= report.getId() %>, '2')">拒绝</button>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
                <%
                    } else {
                %>
                <p style="text-align: center; padding: 40px; color: #666;">暂无待处理举报</p>
                <%
                    }
                %>
                <div style="margin-top: 30px;">
                    <h3 style="color: #28a745; margin-bottom: 20px;">已处理举报</h3>
                    <%
                        if (processedReports != null && !processedReports.isEmpty()) {
                    %>
                    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 15px;">
                        <%
                            for (Report report : processedReports) {
                        %>
                        <div style="border: 1px solid #eee; border-radius: 8px; padding: 15px; background-color: #f8f9fa;">
                            <div style="font-weight: bold; margin-bottom: 10px;">已处理举报 #<%= report.getId() %></div>
                            <p>举报对象: <%= report.getVideo() != null ? report.getVideo().getTitle() : "未知" %></p>
                            <p>举报人: <%= report.getReporter() != null ? report.getReporter().getUsername() : "未知" %></p>
                            <p>处理时间: <%= report.getTimeCreate() != null ? report.getTimeCreate().toString() : "未知" %></p>
                            <p>处理状态:
                                <span style="color: <%= report.getStatus() == 1 ? "#28a745" : "#dc3545" %>;">
                                    <%= report.getStatus() == 1 ? "已通过" : "已拒绝" %>
                                </span>
                            </p>
                        </div>
                        <%
                            }
                        %>
                    </div>
                    <%
                        } else {
                    %>
                    <p style="text-align: center; padding: 40px; color: #666;">暂无已处理举报</p>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
    <script>
        //审批通过操作
        function approveVideo(videoId) {
            if (confirm('确定要通过这个视频吗？')) {
                fetch('/admin/approve?id='+videoId).then(response => response.text()).then(result => {
                        if (result === 'success') {
                            alert('审核通过');
                            // 移除已审核的视频卡片
                            debugger
                            const videoCard = event.target.closest('.video-card');
                            videoCard.style.transition = 'opacity 0.3s ease';
                            videoCard.style.opacity = '0';
                            setTimeout(() => {
                                videoCard.remove();
                                // 检查是否还有待审核视频
                                const remainingVideos = document.querySelectorAll('.video-card');
                                if (remainingVideos.length === 0) {
                                    document.querySelector('.video-grid').innerHTML = '<p style="text-align: center; padding: 40px; color: #666;">暂无待审核视频</p>';
                                }
                            }, 300);
                        } else {
                            alert('操作失败: ' + result);
                        }
                    }).catch(error => {
                        alert('操作失败: ' + error);
                    });
            }
        }
        function rejectVideo(videoId) {
            if (confirm('确定要驳回这个视频吗？')) {
                fetch('/admin/reject?id='+videoId).then(response => response.text()).then(result => {
                        if (result === 'success') {
                            alert('视频已驳回');
                            // 移除已驳回的视频卡片
                            const videoCard = event.target.closest('.video-card');
                            videoCard.style.transition = 'opacity 0.3s ease';
                            videoCard.style.opacity = '0';
                            setTimeout(() => {
                                videoCard.remove();
                                // 检查是否还有待审核视频
                                const remainingVideos = document.querySelectorAll('.video-card');
                                if (remainingVideos.length === 0) {
                                    document.querySelector('.video-grid').innerHTML = '<p style="text-align: center; padding: 40px; color: #666;">暂无待审核视频</p>';
                                }
                            }, 300);
                        } else {
                            alert('操作失败: ' + result);
                        }
                    }).catch(error => {
                        alert('操作失败: ' + error);
                    });
            }
        }
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
                        const reportCard = document.querySelector('#pendingReportsGrid .video-card[data-report-id="' + reportId + '"]');
                        if (reportCard) {
                            reportCard.style.transition = 'opacity 0.3s ease';
                            reportCard.style.opacity = '0';
                            setTimeout(() => {
                                reportCard.remove();
                                const remainingReports = document.querySelectorAll('#pendingReportsGrid .video-card[data-report-id]');
                                if (remainingReports.length === 0) {
                                    document.getElementById('pendingReportsGrid').innerHTML = '<p style="text-align: center; padding: 40px; color: #666;">暂无待处理举报</p>';
                                }
                            }, 300);
                        } else {
                            location.reload();
                        }
                    } else {
                        alert('操作失败: ' + (data.message || '未知错误'));
                    }
                }).catch(error => {
                    alert('操作失败: ' + error);
                });
            }
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
                          window.location.href = '/admin/logout';
                      }
    </script>
</body>
</html>