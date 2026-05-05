<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>确认订单 - 支付页面</title>
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
        .container {
            max-width: 600px;
            margin: 30px auto 20px auto;
            padding: 0 20px;
        }
        .payment-form {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px;
            background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .btn {
            padding: 10px 20px;
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
        .btn-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        .order-summary {
            margin-bottom: 20px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 4px;
        }
        .order-summary p {
            margin: 8px 0;
        }
        .total-price {
            font-size: 20px;
            color: #ff6b6b;
            font-weight: bold;
        }
        .main-content {
            padding-bottom: 40px;
        }
        .countdown-container {
            background: #fff3cd;
            border: 1px solid #ffeeba;
            border-radius: 4px;
            padding: 10px 15px;
            margin-bottom: 20px;
            text-align: center;
            font-size: 16px;
            color: #856404;
        }
        .countdown-timer {
            font-weight: bold;
            font-size: 20px;
            color: #d9534f;
            margin-left: 5px;
        }
    </style>
</head>
<body>
    <!-- 视频平台的头部-->
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
    <!-- 支付主体内容-->
    <div class="container">
        <div class="order-summary">
            <p><strong>订单号:</strong> ${orderId}</p>
            <p><strong>漫展名称:</strong> ${exhibitionName}</p>
            <p><strong>票种:</strong> ${ticketName}</p>
            <p><strong>购买数量:</strong> ${quantity}张</p>
            <p><strong>总金额:</strong> <span class="total-price">¥${totalAmount}</span></p>
        </div>
        <!-- 倒计时提示区域 -->
        <div class="countdown-container" id="countdownContainer">
            请在 <span id="countdownTimer" class="countdown-timer">30</span> 秒内完成支付，超时后将自动返回上一页。
        </div>
        <div class="payment-form">
            <div class="form-group">
                <label>支付方式:</label>
                <select id="paymentMethod">
                    <option value="wechat">微信支付</option>
                    <option value="alipay">支付宝</option>
                    <option value="bank">银行卡</option>
                    <option value="cash">现金</option>
                </select>
            </div>
            <div class="btn-group">
                <button class="btn btn-primary" id="confirmBtn" onclick="confirmPayment()">确认支付</button>
                <button class="btn btn-secondary" onclick="cancelPayment()">取消</button>
            </div>
        </div>
    </div>
    <script>
        // 搜索功能跳转到首页并传递搜索关键词
        function searchExhibitions() {
            const keyword = document.getElementById('searchInput').value.trim();
            if (keyword) {
                window.location.href = '/ticket/index?keyword=' + encodeURIComponent(keyword);
            } else {
                window.location.href = '/ticket/index';
            }
        }
        // 搜索框回车事件
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchExhibitions();
            }
        });
        let countdownSeconds = 30;
        let countdownInterval = null;
        let isPaid = false;
        // 更新页面上的倒计时数字
        function updateCountdownDisplay() {
            document.getElementById('countdownTimer').innerText = countdownSeconds;
        }
        // 倒计时结束后的处理：返回上一页
        function onCountdownEnd() {
            if (isPaid) return;
            if (countdownInterval) {
                clearInterval(countdownInterval);
                countdownInterval = null;
            }
            alert('支付超时，将自动返回上一页');
            window.history.back();
        }
        // 停止倒计时（支付成功或手动取消时调用）
        function stopCountdown() {
            if (countdownInterval) {
                clearInterval(countdownInterval);
                countdownInterval = null;
            }
        }
        // 开始倒计时
        function startCountdown() {
            if (countdownInterval) stopCountdown();
            updateCountdownDisplay();
            countdownInterval = setInterval(() => {
                if (isPaid) {
                    // 已支付，停止倒计时
                    stopCountdown();
                    return;
                }
                if (countdownSeconds <= 1) {
                    // 倒计时结束
                    stopCountdown();
                    onCountdownEnd();
                } else {
                    countdownSeconds--;
                    updateCountdownDisplay();
                }
            }, 1000);
        }
        // 确认支付
        function confirmPayment() {
            // 防止重复点击支付
            if (isPaid) {
                alert('订单已支付，请勿重复操作');
                return;
            }
            const paymentMethod = document.getElementById('paymentMethod').value;
            // 可在此处禁用按钮，避免重复提交
            const confirmBtn = document.getElementById('confirmBtn');
            confirmBtn.disabled = true;
            confirmBtn.innerText = '支付中...';
            $.post('/ticket/doPayment', {
                orderId: ${orderId},
                paymentMethod: paymentMethod
            }, function(response) {
                if (response.success) {
                    isPaid = true;          // 标记已支付
                    stopCountdown();        // 停止倒计时
                    alert('支付成功！');
                    sendPaymentNotification(${orderId});
                    window.location.href = '/ticket/myorders';
                } else {
                    alert(response.message || '支付失败，请重试');
                    // 恢复按钮状态，允许重新尝试支付
                    confirmBtn.disabled = false;
                    confirmBtn.innerText = '确认支付';
                }
            }).fail(function() {
                alert('支付请求失败，请检查网络后重试');
                confirmBtn.disabled = false;
                confirmBtn.innerText = '确认支付';
            });
        }
        // 发送支付成功通知的函数
        function sendPaymentNotification(orderId) {
            const username = '${sessionScope.user.username}';
            const userId = '${sessionScope.user.id}';
            const wsUrl = "ws://" + window.location.host + "/websocket/ticket";
            const ws = new WebSocket(wsUrl);
            ws.onopen = function() {
                const message = {
                    type: "PAYMENT_SUCCESS",
                    from: userId,
                    to: "admin",
                    content: "用户 " + username + " 的订单 " + orderId + " 支付成功"
                };
                ws.send(JSON.stringify(message));
                ws.close(); // 发送后立即关闭连接
            };
            ws.onerror = function(err) {
                console.error("WebSocket 通知发送失败", err);
            };
        }
        // 取消支付，返回上一页
        function cancelPayment() {
            if (confirm('确定要取消支付吗？')) {
                isPaid = true;
                stopCountdown();
                window.history.back();
            }
        }
        // 页面加载完成后启动倒计时
        $(document).ready(function() {
            startCountdown();
        });
    </script>
</body>
</html>