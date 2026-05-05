<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.assessment.www.po.User" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    User admin = (User) session.getAttribute("user");
    String adminUsername = (admin != null && admin.getUsername() != null) ? admin.getUsername() : "管理员";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>漫展数据统计 - 管理后台</title>
    <style>
        body { margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5; }
        .header { background-color: #00a1d6; color: white; padding: 10px 20px; display: flex; justify-content: space-between; align-items: center; }
        .nav-links { display: flex; gap: 20px; }
        .nav-links a { color: white; text-decoration: none; padding: 5px 10px; }
        .main-container { max-width: 1400px; margin: 20px auto; padding: 0 20px; display: flex; gap: 20px; }
        .sidebar { width: 250px; background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); height: fit-content; }
        .sidebar-menu { list-style: none; padding: 0; }
        .sidebar-menu li { margin-bottom: 10px; }
        .sidebar-menu a { display: block; padding: 10px 15px; color: #333; text-decoration: none; border-radius: 4px; transition: background-color 0.3s; }
        .sidebar-menu a:hover, .sidebar-menu a.active { background-color: #00a1d6; color: white; }
        .content { flex: 1; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); text-align: center; transition: transform 0.3s; }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-value { font-size: 36px; font-weight: bold; margin-bottom: 10px; }
        .stat-label { color: #666; font-size: 14px; }
        .stat-card.blue { border-left: 4px solid #00a1d6; }
        .stat-card.blue .stat-value { color: #00a1d6; }
        .stat-card.green { border-left: 4px solid #28a745; }
        .stat-card.green .stat-value { color: #28a745; }
        .stat-card.orange { border-left: 4px solid #ffc107; }
        .stat-card.orange .stat-value { color: #ffc107; }
        .stat-card.red { border-left: 4px solid #dc3545; }
        .stat-card.red .stat-value { color: #dc3545; }
        .stat-card.purple { border-left: 4px solid #6f42c1; }
        .stat-card.purple .stat-value { color: #6f42c1; }
        .stat-card.teal { border-left: 4px solid #20c997; }
        .stat-card.teal .stat-value { color: #20c997; }
        .section-title { color: #333; margin-bottom: 20px; margin-top: 30px; font-size: 20px; display: flex; align-items: center; gap: 10px; }
        .section-title::before { content: ''; width: 4px; height: 20px; background-color: #00a1d6; border-radius: 2px; }
        .chart-container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-top: 20px; }
        .time-filter { display: flex; gap: 10px; margin-bottom: 20px; }
        .filter-btn { padding: 8px 20px; border: 1px solid #ddd; background: white; border-radius: 4px; cursor: pointer; transition: all 0.3s; }
        .filter-btn.active { background: #00a1d6; color: white; border-color: #00a1d6; }
        .btn-group { margin-top: 20px; display: flex; gap: 10px; }
        .btn { padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer; }
        .btn-primary { background: #00a1d6; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        .loading, .error { text-align: center; padding: 40px; color: #666; }
        .error { color: #dc3545; }
        .simple-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .simple-table th, .simple-table td { border: 1px solid #eee; padding: 8px 12px; text-align: center; }
        .simple-table th { background-color: #f8f9fa; font-weight: bold; }
        .status-list { list-style: none; padding: 0; margin: 0; }
        .status-list li { padding: 8px 0; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; }
        .status-list li:last-child { border-bottom: none; }
    </style>
</head>
<body>
    <div class="header">
        <div style="font-size: 24px; font-weight: bold;">管理后台</div>
        <div class="nav-links">
            <span class="welcome-admin">管理员: <%= adminUsername %></span>
            <a href="/adminticket/exhibitions">漫展后台</a>
            <a href="/">返回首页</a>
            <a href="/logout">退出登录</a>
        </div>
    </div>
    <div class="main-container">
        <div class="sidebar">
            <ul class="sidebar-menu">
                <li><a href="/admin/adminindex">数据概览</a></li>
                <li><a href="/admin/users">用户管理</a></li>
                <li><a href="/admin/videos">视频管理</a></li>
                <li><a href="/admin/pending">待审核视频</a></li>
                <li><a href="/admin/banned">被封用户</a></li>
                <li><a href="/admin/reports">举报管理</a></li>
                <hr style="margin: 15px 0; border-color: #eee;">
                <li><a href="/adminticket/exhibitions">漫展管理</a></li>
                <li><a href="/adminticket/orders">订单管理</a></li>
                <li><a href="/adminticket/statistics" class="active">漫展数据统计</a></li>
                <li><a href="/adminticket/consultingUsers">当前咨询用户</a></li>
            </ul>
        </div>
        <div class="content">
            <h2>漫展数据统计</h2>
            <!-- 统计卡片 -->
            <div class="stats-grid">
                <div class="stat-card blue">
                    <div class="stat-value" id="totalOrders">${totalOrders != null ? totalOrders : '--'}</div>
                    <div class="stat-label">总订单数</div>
                </div>
                <div class="stat-card green">
                    <div class="stat-value" id="totalSales">¥${totalSales != null ? totalSales : '0.00'}</div>
                    <div class="stat-label">总销售额</div>
                </div>
                <div class="stat-card purple">
                    <div class="stat-value" id="totalUsers">${totalUsers != null ? totalUsers : '--'}</div>
                    <div class="stat-label">总用户数</div>
                </div>
                <div class="stat-card teal">
                    <div class="stat-value" id="activeExhibitions">${activeExhibitions != null ? activeExhibitions : '--'}</div>
                    <div class="stat-label">活跃漫展</div>
                </div>
                <div class="stat-card orange">
                    <div class="stat-value" id="verifiedTickets">${verifiedTickets != null ? verifiedTickets : '--'}</div>
                    <div class="stat-label">已核销门票</div>
                </div>
                <div class="stat-card red">
                    <div class="stat-value" id="refundedTickets">${refundedTickets != null ? refundedTickets : '--'}</div>
                    <div class="stat-label">已退款门票</div>
                </div>
            </div>
            <!-- 时间筛选 -->
            <div class="time-filter">
                <button class="filter-btn" data-range="day">今日</button>
                <button class="filter-btn" data-range="week">本周</button>
                <button class="filter-btn" data-range="month">本月</button>
                <button class="filter-btn" data-range="year">本年</button>
            </div>
            <!-- 销售趋势（简化表格） -->
            <div class="chart-container">
                <div class="section-title">销售趋势</div>
                <div id="salesChart">
                    <div class="loading">加载数据中...</div>
                </div>
            </div>

            <div class="btn-group">
                <button class="btn btn-primary" id="refreshBtn">刷新数据</button>
            </div>
        </div>
    </div>
    <script>
        const contextPath = '${pageContext.request.contextPath}';
        let currentTimeRange = 'day';
        // 页面初始化数据
        let initialData = {
            totalOrders: parseInt('${totalOrders != null ? totalOrders : 0}'),
            totalSales: parseFloat('${totalSales != null ? totalSales : 0}'),
            totalUsers: parseInt('${totalUsers != null ? totalUsers : 0}'),
            activeExhibitions: parseInt('${activeExhibitions != null ? activeExhibitions : 0}'),
            verifiedTickets: parseInt('${verifiedTickets != null ? verifiedTickets : 0}'),
            refundedTickets: parseInt('${refundedTickets != null ? refundedTickets : 0}'),
            salesTrendData: ${salesTrendData != null ? salesTrendData : '[]'},
            orderStatusDistribution: {
                pending: parseInt('${pendingOrders != null ? pendingOrders : 0}'),
                paid: parseInt('${paidOrders != null ? paidOrders : 0}'),
                verified: parseInt('${verifiedOrders != null ? verifiedOrders : 0}'),
                cancelled: parseInt('${cancelledOrders != null ? cancelledOrders : 0}')
            }
        };

        // 解析销售数据
        function parseSalesData(rawData) {
            let salesData = rawData;
            if (typeof salesData === 'string') {
                try {
                    salesData = JSON.parse(salesData);
                } catch(e) {
                    console.error('解析销售趋势JSON失败', e);
                    salesData = [];
                }
            }
            if (!Array.isArray(salesData)) salesData = [];
            return salesData.map(item => {
                let count = (item[1] !== undefined && !isNaN(parseFloat(item[1]))) ? parseFloat(item[1]) : 0;
                let label = item[0] ? String(item[0]) : '';
                return [label, count];
            });
        }

        function renderSalesChart(salesData) {
            const container = document.getElementById('salesChart');
            if (!container) return;
            const validData = salesData;
            if (validData.length === 0) {
                container.innerHTML = '<div class="error">暂无销售趋势数据</div>';
                return;
            }
            let html = '<table class="simple-table">';
            html += '<thead><tr><th>时间</th><th>订单数/销售额</th></tr></thead><tbody>';
            for (let i = 0; i < validData.length; i++) {
            debugger
                html += '<tr><td>'+validData[i][0]+'</td><td>'+validData[i][1]+'/'+(validData[i][2]?validData[i][2]:"0")+'</td></tr>';
            }
            html += '</tbody></table>';
            container.innerHTML = html;
        }
        // 更新卡片数值
        function updateStatistics(statsData) {
            document.getElementById('totalOrders').innerText = statsData.totalOrders;
            document.getElementById('totalSales').innerText = '¥' + parseFloat(statsData.totalSales).toFixed(2);
            document.getElementById('totalUsers').innerText = statsData.totalUsers;
            document.getElementById('activeExhibitions').innerText = statsData.activeExhibitions;
            document.getElementById('verifiedTickets').innerText = statsData.verifiedTickets;
            document.getElementById('refundedTickets').innerText = statsData.refundedTickets;
        }

        // 异步加载统计数据
        function loadStatisticsData() {
            document.getElementById('salesChart').innerHTML = '<div class="loading">加载中...</div>';
            fetch(contextPath + '/adminticket/statistics?timeRange=' + currentTimeRange, {
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    updateStatistics(data.data);
                    renderSalesChart(data.data.salesTrendData);

                } else {
                    throw new Error(data.message);
                }
            }).catch(err => {
                console.error(err);
                document.getElementById('salesChart').innerHTML = '<div class="error">数据加载失败</div>';

            });
        }

        // 时间筛选
        function filterByTime(range) {
            currentTimeRange = range;
            document.querySelectorAll('.filter-btn').forEach(btn => {
                if (btn.getAttribute('data-range') === range) {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            });
            loadStatisticsData();
        }

        function resetFilter() {
            filterByTime('day');
        }

        // 使用初始数据渲染简单图表
        function initChartsWithInitialData() {
            renderSalesChart(initialData.salesTrendData);
        }

        document.addEventListener('DOMContentLoaded', function() {
            initChartsWithInitialData();
            document.querySelectorAll('.filter-btn').forEach(btn => {
                btn.addEventListener('click', function() {
                    filterByTime(this.getAttribute('data-range'));
                });
            });
            document.getElementById('refreshBtn').addEventListener('click', loadStatisticsData);
            const activeBtn = document.querySelector(`.filter-btn[data-range="${currentTimeRange}"]`);
            if (activeBtn) activeBtn.classList.add('active');
        });
    </script>
</body>
</html>