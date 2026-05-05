<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>${exhibition.name} - 漫展详情</title>
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
    <style>
        body { margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5; }
        .header { background-color: #00a1d6; color: white; padding: 10px 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; }
        .header a { text-decoration: none; color: inherit; }
        .logo { font-size: 24px; font-weight: bold; }
        .nav-links { display: flex; gap: 20px; align-items: center; flex-wrap: wrap; }
        .search-container { display: flex; gap: 10px; align-items: center; }
        .search-input { padding: 5px; border: none; border-radius: 4px; width: 200px; }
        .search-btn { padding: 5px 10px; background-color: #ff6b6b; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .upload-btn { background-color: #ff6b6b; color: white; padding: 5px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; text-decoration: none; display: inline-block; }
        .login-btn { background-color: transparent; color: white; padding: 5px 15px; border: 1px solid white; border-radius: 4px; cursor: pointer; text-decoration: none; }
        .welcome-user { color: white; }
        .main-container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }
        .exhibition-detail { display: flex; gap: 30px; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .exhibition-image { flex: 1; }
        .exhibition-image img { width: 100%; border-radius: 8px; }
        .exhibition-info { flex: 1; }
        .exhibition-title { font-size: 24px; font-weight: bold; margin-bottom: 20px; }
        .tickets-section { margin-top: 30px; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .tickets-title { font-size: 20px; font-weight: bold; margin-bottom: 15px; }
        .tickets-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 15px; }
        .ticket-card { border: 1px solid #ddd; border-radius: 8px; padding: 15px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); background: white; transition: transform 0.2s; }
        .ticket-card:hover { transform: translateY(-3px); }
        .ticket-name { font-size: 16px; font-weight: bold; margin-bottom: 10px; }
        .ticket-info p { margin: 5px 0; }
        .ticket-actions { margin-top: 15px; }
        .btn { padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer; }
        .btn-primary { background: #007bff; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-danger { background: #dc3545; color: white; }
        .sold-out { background-color: #f8f9fa; opacity: 0.6; pointer-events: none; }
        .sold-out .btn-primary { background: #6c757d; cursor: not-allowed; }
        .consultation-message-item { margin-bottom: 12px; padding: 8px 12px; border-radius: 8px; max-width: 85%; word-wrap: break-word; }
        .consultation-message-user { background-color: #007bff; color: white; margin-left: auto; text-align: right; }
        .consultation-message-admin { background-color: #e9ecef; color: #333; margin-right: auto; }
        .consultation-message-time { font-size: 11px; opacity: 0.7; margin-top: 4px; }
        @media (max-width: 768px) { .exhibition-detail { flex-direction: column; } }
    </style>
</head>
<body>
    <div class="header">
        <a href="/ticket/index" class="logo">漫展演出售票系统</a>
        <div class="search-container">
            <input type="text" class="search-input" id="searchInput" placeholder="搜索漫展/演出...">
            <button class="search-btn" onclick="searchExhibitions()">搜索</button>
        </div>
        <div class="nav-links">
            <c:choose>
                <c:when test="${not empty user}">
                    <span class="welcome-user">欢迎, ${user.username}</span>
                    <a href="/user/me">个人中心</a>
                    <a href="/ticket/index">漫展活动</a>
                    <a href="/ticket/myorders" class="upload-btn">我的订单</a>
                    <a href="/user/logout">退出登录</a>
                    <c:if test="${'admin' == user.role}">
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
        <div class="exhibition-detail">
            <div class="exhibition-image">
                <img src="${exhibition.coverImage}" alt="${exhibition.name}">
            </div>
            <div class="exhibition-info">
                <div class="exhibition-title">${exhibition.name}</div>
                <div class="exhibition-info">
                    <p><strong>类型:</strong> ${exhibition.type}</p>
                    <p><strong>时间:</strong> <fmt:formatDate value="${exhibition.startTime}" pattern="yyyy-MM-dd HH:mm"/> - <fmt:formatDate value="${exhibition.endTime}" pattern="yyyy-MM-dd HH:mm"/></p>
                    <p><strong>地点:</strong> ${exhibition.address}</p>
                    <p><strong>联系电话:</strong> ${exhibition.contactPhone}</p>
                    <p><strong>描述:</strong> ${exhibition.description}</p>
                </div>
                <div class="exhibition-actions">
                   <c:if test="${user != null}">
                       <c:choose>
                           <c:when test="${isFavorited}">
                               <button class="btn btn-danger" onclick="unfavoriteExhibition(${exhibition.id})">取消收藏</button>
                           </c:when>
                           <c:otherwise>
                               <button class="btn btn-secondary" onclick="favoriteExhibition(${exhibition.id})">收藏</button>
                           </c:otherwise>
                       </c:choose>
                       <button class="btn btn-info" onclick="openConsultation()">在线咨询</button>
                   </c:if>
                </div>
            </div>
        </div>
        <div class="tickets-section">
            <div class="tickets-title">票务信息</div>
            <div class="tickets-grid">
                <c:forEach items="${tickets}" var="ticket">
                    <div class="ticket-card <c:if test="${ticket.remainingQuantity <= 0 || ticket.status != 'available'}">sold-out</c:if>" data-ticket-id="${ticket.id}">
                        <div class="ticket-name">${ticket.name}</div>
                        <div class="ticket-info">
                            <p><strong>价格:</strong> ¥<fmt:formatNumber value="${ticket.price}" pattern="#.##" type="currency"/></p>
                            <p><strong>剩余数量:</strong> ${ticket.remainingQuantity}</p>
                            <p><strong>类型:</strong> ${ticket.type}</p>
                            <p><strong>描述:</strong> ${ticket.description}</p>
                        </div>
                        <div class="ticket-actions">
                            <c:if test="${ticket.remainingQuantity > 0 && ticket.status == 'available'}">
                                <button class="btn btn-primary" onclick="checkLoginAndBuy(${ticket.id}, ${ticket.remainingQuantity}, ${ticket.price})">购买</button>
                            </c:if>
                            <c:if test="${ticket.remainingQuantity <= 0 || ticket.status != 'available'}">
                                <button class="btn btn-secondary" disabled>已售罄</button>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
    <!-- 购买数量弹窗 -->
    <div id="quantityModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000;">
        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 8px; min-width: 350px;">
            <h3>选择购买数量</h3>
            <div style="margin: 20px 0;">
                <label>数量：</label>
                <input type="number" id="quantityInput" value="1" min="1" max="10" style="width: 80px;" oninput="updateTotalPrice()">
                <div style="margin-top: 10px;">
                    <p style="color: #666; font-size: 14px;">剩余数量：<span id="remainingCount">-</span></p>
                    <p style="color: #666; font-size: 14px;">单价：¥<span id="unitPrice">-</span></p>
                    <p style="color: #2196F3; font-size: 16px; font-weight: bold;">总价：¥<span id="totalPrice">0.00</span></p>
                </div>
                <div style="margin-top: 10px; font-size: 12px; color: #999;">
                    <p>• 购买后请在30分钟内完成支付</p>
                </div>
            </div>
            <div style="text-align: right;">
                <button class="btn btn-secondary" onclick="closeModal()">取消</button>
                <button class="btn btn-primary" onclick="confirmPurchase()">确认购买</button>
            </div>
        </div>
    </div>
    <!-- 咨询对话框 -->
    <div id="consultationModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000;">
        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; border-radius: 8px; width: 500px; max-width: 90%; display: flex; flex-direction: column; box-shadow: 0 4px 20px rgba(0,0,0,0.3);">
            <div style="display: flex; justify-content: space-between; align-items: center; padding: 15px 20px; border-bottom: 1px solid #eee; background-color: #00a1d6; color: white; border-radius: 8px 8px 0 0;">
                <h3 style="margin: 0;">在线咨询</h3>
                <button onclick="closeConsultation()" style="background: none; border: none; color: white; font-size: 24px; cursor: pointer;">&times;</button>
            </div>
            <div id="consultationMessages" style="height: 350px; overflow-y: auto; padding: 15px; background: #f9f9f9; display: flex; flex-direction: column;">
                <div style="text-align: center; color: #666; padding: 20px;">加载消息中...</div>
            </div>
            <div style="display: flex; gap: 10px; padding: 15px; border-top: 1px solid #eee; background: white;">
                <input type="text" id="consultationMessageInput" maxlength="500" placeholder="请输入您的问题..." style="flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 4px; outline: none;">
                <button class="btn btn-primary" onclick="sendConsultationMessage()" style="background-color: #00a1d6;">发送</button>
            </div>
        </div>
    </div>
    <script>
        var isLoggedIn = ${not empty user};
        let selectedTicketId = null;
        let selectedRemaining = 0;
        let selectedPrice = 0;
        let purchasing = false;
        // 漫展ID（用于票务订阅）
        let exhibitionId = ${exhibition.id};
        // ========== 搜索功能 ==========
        function searchExhibitions() {
            const keyword = document.getElementById('searchInput').value.trim();
            if (keyword) {
                window.location.href = '/ticket/index?keyword=' + encodeURIComponent(keyword);
            } else {
                window.location.href = '/ticket/index';
            }
        }
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') searchExhibitions();
        });
        // ========== 登录检查 ==========
        function requireLogin() {
            if (!isLoggedIn) {
                alert('请先登录后再操作');
                window.location.href = '/user/login';
                return false;
            }
            return true;
        }
        // ========== 购买相关 ==========
        function checkLoginAndBuy(ticketId, remaining, price) {
            if (!requireLogin()) return;
            showQuantityPicker(ticketId, remaining, price);
        }
        function showQuantityPicker(ticketId, remaining, price) {
            selectedTicketId = ticketId;
            selectedRemaining = remaining;
            selectedPrice = price;
            document.getElementById('quantityModal').style.display = 'block';
            document.getElementById('quantityInput').value = 1;
            document.getElementById('remainingCount').textContent = remaining;
            document.getElementById('unitPrice').textContent = price.toFixed(2);
            updateTotalPrice();
        }
        function closeModal() {
            document.getElementById('quantityModal').style.display = 'none';
            selectedTicketId = null;
            selectedRemaining = 0;
            selectedPrice = 0;
        }
        function updateTotalPrice() {
            const quantity = parseInt(document.getElementById('quantityInput').value) || 0;
            const maxQuantity = Math.min(selectedRemaining, 10);
            if (quantity > maxQuantity) {
                document.getElementById('quantityInput').value = maxQuantity;
            }
            const totalPrice = (document.getElementById('quantityInput').value || 0) * selectedPrice;
            document.getElementById('totalPrice').textContent = totalPrice.toFixed(2);
        }
        function confirmPurchase() {
            if (purchasing) return;
            const quantity = parseInt(document.getElementById('quantityInput').value);
            if (quantity > 0) {
                purchasing = true;
                buyTicket(selectedTicketId, quantity, selectedPrice);
                closeModal();
                setTimeout(() => { purchasing = false; }, 3000);
            }
        }
        function buyTicket(ticketId, quantity, price) {
            quantity = parseInt(quantity) || 1;
            if (quantity <= 0) {
                alert('请选择有效的购买数量');
                return;
            }
            var unitPrice = parseFloat(price);
            if (isNaN(unitPrice)) {
                alert('价格无效');
                return;
            }
            $('.btn-primary').prop('disabled', true).text('处理中...');
            var totalPrice = quantity * unitPrice;
            var confirmMsg = '确认购买吗？\n数量：' + quantity + '张\n总价：¥' + totalPrice.toFixed(2);
            if (confirm(confirmMsg)) {
                $.post('/ticket/purchase',
                    {
                        ticketId: ticketId,
                        quantity: quantity,
                        exhibitionId: exhibitionId
                    },
                    function(response) {
                        if (response.success) {
                            alert(response.message + '\n总价：¥' + response.totalPrice.toFixed(2));
                            window.location.href = '/ticket/payment?orderId=' + response.orderId;
                        } else {
                            $('.btn-primary').prop('disabled', false).text('购买');
                            alert(response.message);
                        }
                    }
                ).fail(function() {
                    alert('操作失败，请重试');
                    $('.btn-primary').prop('disabled', false).text('购买');
                });
            }
        }
        //收藏/取消收藏
        function favoriteExhibition(exhibitionId) {
            $.post('/ticket/favorite', { id: exhibitionId }, function(response) {
                if (response.success) {
                    alert(response.message);
                    var btn = $('.exhibition-actions .btn-danger, .exhibition-actions .btn-secondary').first();
                    btn.removeClass('btn-secondary').addClass('btn-danger').text('取消收藏');
                    btn.attr('onclick', 'unfavoriteExhibition(' + exhibitionId + ')');
                } else {
                    alert(response.message);
                }
            }).fail(function() {
                alert('操作失败，请重试');
            });
        }
        function unfavoriteExhibition(exhibitionId) {
            $.post('/ticket/unfavorite', { id: exhibitionId }, function(response) {
                if (response.success) {
                    alert(response.message);
                    var btn = $('.exhibition-actions .btn-danger, .exhibition-actions .btn-secondary').first();
                    btn.removeClass('btn-danger').addClass('btn-secondary').text('收藏');
                    btn.attr('onclick', 'favoriteExhibition(' + exhibitionId + ')');
                } else {
                    alert(response.message);
                }
            }).fail(function() {
                alert('操作失败，请重试');
            });
        }
        //票务实时更新功能
        let ticketWebSocket = null;
        let ticketSubscribed = false;
        function initTicketWebSocket() {
            if (!isLoggedIn) return; // 未登录不建立票务连接
            const wsUrl = "ws://" + window.location.host + "${pageContext.request.contextPath}/websocket/ticket";
            ticketWebSocket = new WebSocket(wsUrl);
            ticketWebSocket.onopen = function() {
                console.log("票务WebSocket连接已建立");
                // 订阅当前漫展
                if (!ticketSubscribed) {
                    ticketWebSocket.send(JSON.stringify({
                        type: "subscribe",
                        content: String(exhibitionId)
                    }));
                    ticketSubscribed = true;
                }
            };
            ticketWebSocket.onmessage = function(event) {
                const message = JSON.parse(event.data);
                if (message.type === "ticketBatchUpdate") {
                    // 批量更新所有票种
                    console.log("收到批量票务更新", message.tickets);
                    batchUpdateTickets(message.tickets);
                } else if (message.type === "ticketUpdate") {
                    // 单个票种实时更新
                    console.log("收到实时票务更新", message.ticketId, message.remainingQuantity);
                    updateTicketRemaining(message.ticketId, message.remainingQuantity);
                } else if (message.type === "subscribe_confirm") {
                    console.log("票务订阅确认:", message.content);
                }
            };
            ticketWebSocket.onerror = function(error) {
                console.error("票务WebSocket错误:", error);
            };
            ticketWebSocket.onclose = function() {
                console.log("票务WebSocket连接已关闭");
                ticketSubscribed = false;
                setTimeout(function() {
                    if (ticketWebSocket === null || ticketWebSocket.readyState === WebSocket.CLOSED) {
                        initTicketWebSocket();
                    }
                }, 5000);
            };
        }
        // 更新单个票种显示
        function updateTicketRemaining(ticketId, newRemaining) {
            var $card = $('.ticket-card').filter(function() {
                return $(this).data('ticket-id') == ticketId;
            });
            if ($card.length === 0) return;
            $card.find('.ticket-info p:contains("剩余数量")').html('<strong>剩余数量:</strong> ' + newRemaining);
            var $buyBtn = $card.find('.btn-primary');
            if (newRemaining <= 0) {
                $card.addClass('sold-out');
                if ($buyBtn.length) {
                    $buyBtn.prop('disabled', true).text('已售罄');
                } else {
                    $card.find('.btn-secondary').prop('disabled', true).text('已售罄');
                }
            } else {
                $card.removeClass('sold-out');
                if ($buyBtn.length) {
                    $buyBtn.prop('disabled', false).text('购买');
                }
            }
            $card.data('remaining', newRemaining);
        }
        // 批量更新
        function batchUpdateTickets(ticketsData) {
            if (!ticketsData || ticketsData.length === 0) return;
            for (var i = 0; i < ticketsData.length; i++) {
                updateTicketRemaining(ticketsData[i].ticketId, ticketsData[i].remainingQuantity);
            }
        }
        // ========== 在线咨询功能（点击按钮后才建立连接） ==========
        let consultationWebSocket = null;
        let currentUserId = ${user != null ? user.id : 0};
        let currentUsername = '${user != null ? user.username : ""}';
        let consultationExhibitionId = ${exhibition.id};
        function openConsultation() {
            if (!requireLogin()) return;
            if (consultationWebSocket && consultationWebSocket.readyState === WebSocket.OPEN) {
                document.getElementById('consultationModal').style.display = 'flex';
                return;
            }
            document.getElementById('consultationModal').style.display = 'flex';
            loadChatHistory();
            initConsultationWebSocket();
        }
        function closeConsultation() {
            document.getElementById('consultationModal').style.display = 'none';
            if (consultationWebSocket) {
                consultationWebSocket.close();
                consultationWebSocket = null;
            }
        }
        function loadChatHistory() {
            const container = document.getElementById('consultationMessages');
            container.innerHTML = '<div style="text-align: center; color: #666; padding: 20px;">加载历史消息中...</div>';
            fetch('/ticket/consultation/history?userId=' + currentUserId)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        renderChatMessages(data.data);
                    } else {
                        container.innerHTML = '<div style="text-align: center; color: #dc3545; padding: 20px;">加载历史消息失败</div>';
                    }
                })
                .catch(err => {
                    container.innerHTML = '<div style="text-align: center; color: #dc3545; padding: 20px;">网络错误，加载失败</div>';
                });
        }
        function renderChatMessages(messages) {
            const container = document.getElementById('consultationMessages');
            if (!container) return;
            if (!messages || messages.length === 0) {
                container.innerHTML = '<div style="text-align: center; color: #666; padding: 20px;">暂无消息，请开始咨询</div>';
                return;
            }
            let html = '';
            for (let i = 0; i < messages.length; i++) {
                var msg = messages[i];
                var isUser = msg.sender === 'user';
                var alignClass = isUser ? 'consultation-message-user' : 'consultation-message-admin';
                var senderName = isUser ? (currentUsername || '我') : '管理员';
                var timeStr = msg.formattedTime || msg.time || '';
                html += '<div class="consultation-message-item ' + alignClass + '" style="max-width: 80%;">' +
                        '<div><strong>' + escapeHtml(senderName) + '</strong>: ' + escapeHtml(msg.content) + '</div>' +
                        '<div class="consultation-message-time">' + escapeHtml(timeStr) + '</div>' +
                        '</div>';
            }
            container.innerHTML = html;
            container.scrollTop = container.scrollHeight;
        }
        function initConsultationWebSocket() {
            var wsUrl = "ws://" + window.location.host + "${pageContext.request.contextPath}/websocket/consultation?userId=" + currentUserId + "&role=user";
            consultationWebSocket = new WebSocket(wsUrl);
            consultationWebSocket.onopen = function() {
                console.log("咨询WebSocket连接已建立");
                var userInfo = {
                    type: 'user',
                    from: currentUserId,
                    exhibitionId: consultationExhibitionId,
                    userId: currentUserId,
                    username: currentUsername
                };
                consultationWebSocket.send(JSON.stringify(userInfo));
            };
            consultationWebSocket.onmessage = function(event) {
                var message = JSON.parse(event.data);
                if (message.type === 'admin') {
                    appendMessage({
                        sender: 'admin',
                        content: message.content,
                        formattedTime: new Date().toLocaleTimeString()
                    });
                } else if (message.type === 'system') {
                    console.log("系统消息:", message.content);
                }
            };
            consultationWebSocket.onerror = function(error) {
                console.error("咨询WebSocket错误:", error);
            };
            consultationWebSocket.onclose = function() {
                console.log("咨询WebSocket连接已关闭");
            };
        }
        function appendMessage(msg) {
            var container = document.getElementById('consultationMessages');
            if (!container) return;
            var isUser = msg.sender === 'user';
            var alignClass = isUser ? 'consultation-message-user' : 'consultation-message-admin';
            var senderName = isUser ? (currentUsername || '我') : '管理员';
            var timeStr = msg.formattedTime || new Date().toLocaleTimeString();
            var messageDiv = document.createElement('div');
            messageDiv.className = 'consultation-message-item ' + alignClass;
            messageDiv.style.maxWidth = '80%';
            messageDiv.innerHTML = '<div><strong>' + escapeHtml(senderName) + '</strong>: ' + escapeHtml(msg.content) + '</div>' +
                                   '<div class="consultation-message-time">' + escapeHtml(timeStr) + '</div>';
            container.appendChild(messageDiv);
            container.scrollTop = container.scrollHeight;
        }
        function sendConsultationMessage() {
            var input = document.getElementById('consultationMessageInput');
            var content = input.value.trim();
            if (!content) {
                alert('请输入消息内容');
                return;
            }
            if (!consultationWebSocket || consultationWebSocket.readyState !== WebSocket.OPEN) {
                alert('连接未建立，请稍后再试');
                return;
            }
            var messageData = {
                type: 'user',
                from: currentUserId,
                to: 'admin',
                content: content,
                exhibitionId: consultationExhibitionId,
                userId: currentUserId,
                username: currentUsername
            };
            consultationWebSocket.send(JSON.stringify(messageData));
            appendMessage({
                sender: 'user',
                content: content,
                formattedTime: new Date().toLocaleTimeString()
            });
            input.value = '';
        }
        function escapeHtml(str) {
            if (!str) return '';
            return str.replace(/[&<>]/g, function(m) {
                if (m === '&') return '&amp;';
                if (m === '<') return '&lt;';
                if (m === '>') return '&gt;';
                return m;
            });
        }
        // 页面加载完成后启动票务WebSocket，并绑定咨询发送回车事件
        $(document).ready(function() {
            initTicketWebSocket();
            $('#consultationMessageInput').on('keypress', function(e) {
                if (e.key === 'Enter') sendConsultationMessage();
            });
        });
    </script>
</body>
</html>