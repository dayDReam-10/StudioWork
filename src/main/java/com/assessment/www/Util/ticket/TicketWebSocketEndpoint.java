package com.assessment.www.Util.ticket;

import com.assessment.www.dao.ticket.TicketDao;
import com.assessment.www.dao.ticket.TicketDaoImpl;
import com.assessment.www.po.ticket.Message;
import com.assessment.www.po.ticket.Ticket;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;

@ServerEndpoint("/websocket/ticket")
public class TicketWebSocketEndpoint { // 售票通知票务实时订阅推送
    private static final Map<String, Session> sessions = new ConcurrentHashMap<>();
    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final TicketDao ticketDao = new TicketDaoImpl();
    // 订阅该漫展的SessionId集合
    private static final Map<String, Set<String>> exhibitionSubscribers = new ConcurrentHashMap<>();
    // 该会话订阅的漫展ID
    private static final Map<String, String> sessionSubscriptions = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session) {
        sessions.put(session.getId(), session);
    }

    @OnClose
    public void onClose(Session session) {
        String sessionId = session.getId();
        // 清理订阅关系
        String exhibitionId = sessionSubscriptions.remove(sessionId);
        if (exhibitionId != null) {
            Set<String> subs = exhibitionSubscribers.get(exhibitionId);
            if (subs != null) {
                subs.remove(sessionId);
                if (subs.isEmpty()) exhibitionSubscribers.remove(exhibitionId);
            }
        }
        sessions.remove(sessionId);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        try {
            Message msg = objectMapper.readValue(message, Message.class);
            switch (msg.getType()) {
                case "PAYMENT_SUCCESS":
                    handleJoin(session, msg);
                    break;
                case "VERIFY":
                    handleVerify(session, msg);
                    break;
                case "NEW_ORDER":
                    handleNewOrder(session, msg);
                    break;
                case "ORDER_CANCELLED":
                    handleOrderCancelled(session, msg);
                    break;
                // 订阅/取消订阅漫展
                case "subscribe":
                    handleSubscribe(session, msg);
                    break;
                case "unsubscribe":
                    handleUnsubscribe(session, msg);
                    break;
                default:
                    System.out.println("未知消息类型: " + msg.getType());
            }
        } catch (Exception e) {
            sendErrorMessage(session, "消息处理失败");
        }
    }

    @OnError
    public void onError(Session session, Throwable error) {
    }

    // 处理订阅漫展
    private void handleSubscribe(Session session, Message msg) {
        String exhibitionId = msg.getContent();//漫展ID放在 content 字段
        if (exhibitionId == null || exhibitionId.trim().isEmpty()) {
            sendErrorMessage(session, "漫展ID不能为空");
            return;
        }
        String sessionId = session.getId();
        // 存储订阅关系
        synchronized (exhibitionSubscribers) {
            String oldEx = sessionSubscriptions.get(sessionId);
            if (oldEx != null) {
                Set<String> oldSubs = exhibitionSubscribers.get(oldEx);
                if (oldSubs != null) oldSubs.remove(sessionId);
            }
            exhibitionSubscribers.computeIfAbsent(exhibitionId, k -> ConcurrentHashMap.newKeySet()).add(sessionId);
            sessionSubscriptions.put(sessionId, exhibitionId);
        }
        // 立即推送当前该漫展所有票种的剩余数量
        sendCurrentTickets(session, exhibitionId);
        Message confirm = new Message();
        confirm.setType("subscribe_confirm");
        confirm.setContent("订阅成功，已同步最新票务信息");
        sendToSession(session, confirm);
    }

    // 处理取消订阅
    private void handleUnsubscribe(Session session, Message msg) {
        String sessionId = session.getId();
        String exhibitionId = sessionSubscriptions.remove(sessionId);
        if (exhibitionId != null) {
            Set<String> subs = exhibitionSubscribers.get(exhibitionId);
            if (subs != null) {
                subs.remove(sessionId);
                if (subs.isEmpty()) exhibitionSubscribers.remove(exhibitionId);
            }
        }
        Message confirm = new Message();
        confirm.setType("unsubscribe_confirm");
        confirm.setContent("已取消订阅");
        sendToSession(session, confirm);
    }

    // 查询并推送当前票务信息（批量）
    private void sendCurrentTickets(Session session, String exhibitionId) {
        try {
            Integer exId = Integer.parseInt(exhibitionId);
            List<Ticket> tickets = ticketDao.getTicketsByExhibitionId(exId);
            List<Map<String, Object>> ticketList = new ArrayList<>();
            if (tickets != null) {
                for (Ticket t : tickets) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("ticketId", t.getId());
                    map.put("remainingQuantity", t.getRemainingQuantity());
                    ticketList.add(map);
                }
            }
            // 构建批量更新消息
            Map<String, Object> batch = new HashMap<>();
            batch.put("type", "ticketBatchUpdate");
            batch.put("exhibitionId", exhibitionId);
            batch.put("tickets", ticketList);
            String json = objectMapper.writeValueAsString(batch);
            session.getBasicRemote().sendText(json);
        } catch (Exception e) {
            System.err.println("获取票务信息失败: " + e.getMessage());
            if (session.isOpen()) {
                sendErrorMessage(session, "获取票务信息失败，请重试");
            }
        }
    }

    // 发送错误消息
    private void sendErrorMessage(Session session, String errorMsg) {
        try {
            Map<String, String> error = new HashMap<>();
            error.put("type", "error");
            error.put("content", errorMsg);
            session.getBasicRemote().sendText(objectMapper.writeValueAsString(error));
        } catch (IOException e) {
            System.err.println("发送错误消息失败: " + e.getMessage());
        }
    }

    // 发送消息给单个会话
    private void sendToSession(Session session, Message message) {
        try {
            String json = objectMapper.writeValueAsString(message);
            session.getBasicRemote().sendText(json);
        } catch (IOException e) {
            System.err.println("发送消息到会话失败: " + e.getMessage());
        }
    }

    // 广播消息给所有连接的客户端
    public static void broadcast(Message message) {
        try {
            String jsonMessage = objectMapper.writeValueAsString(message);
            sessions.values().forEach(session -> {
                try {
                    if (session.isOpen()) {
                        session.getBasicRemote().sendText(jsonMessage);
                    }
                } catch (IOException e) {
                }
            });
        } catch (Exception e) {
        }
    }

    // 发送消息给特定用户
    public static void sendToUser(String userId, Message message) {
        try {
            String jsonMessage = objectMapper.writeValueAsString(message);
            sessions.values().forEach(session -> {
                try {
                    if (session.isOpen()) {
                        String userIdInSession = (String) session.getUserProperties().get("userId");
                        if (userId.equals(userIdInSession)) {
                            session.getBasicRemote().sendText(jsonMessage);
                        }
                    }
                } catch (IOException e) {
                }
            });
        } catch (Exception e) {
        }
    }

    // 对外广播票种剩余数量更新
    public static void broadcastTicketUpdate(String exhibitionId, Integer ticketId, int newRemaining) {
        if (exhibitionId == null || ticketId == null) return;
        Set<String> sessionIds = exhibitionSubscribers.get(exhibitionId);
        if (sessionIds == null || sessionIds.isEmpty()) return;
        Map<String, Object> update = new HashMap<>();
        update.put("type", "ticketUpdate");
        update.put("ticketId", ticketId);
        update.put("remainingQuantity", newRemaining);
        String jsonMsg;
        try {
            jsonMsg = objectMapper.writeValueAsString(update);
        } catch (Exception e) {
            return;
        }
        for (String sid : sessionIds) {
            Session s = sessions.get(sid);
            if (s != null && s.isOpen()) {
                try {
                    s.getBasicRemote().sendText(jsonMsg);
                } catch (IOException e) {
                }
            }
        }
    }

    private void handleJoin(Session session, Message message) {
        String userId = message.getFrom();
        session.getUserProperties().put("userId", userId);
        Message response = new Message();
        response.setType("PAYMENT_SUCCESS");
        response.setContent("支付成功");
        response.setTo(userId);
        sendToUser(userId, response);
        System.out.println("支付成功通知");
    }

    private void handleVerify(Session session, Message message) {
        String userId = message.getFrom();
        String ticketCode = message.getContent();
        Message notification = new Message();
        notification.setType("VERIFY_REQUEST");
        notification.setContent("用户 " + userId + " 提交了核销请求，核销码: " + ticketCode);
        notification.setTo("admin");
        notification.setFrom("system");
        broadcast(notification);
    }

    private void handleNewOrder(Session session, Message message) {
        String userId = message.getFrom();
        String orderId = message.getContent();
        Message notification = new Message();
        notification.setType("NEW_ORDER");
        notification.setContent("用户 " + userId + " 创建了新订单，订单号: " + orderId);
        notification.setTo("admin");
        notification.setFrom("system");
        broadcast(notification);
    }

    private void handleOrderCancelled(Session session, Message message) {
        String userId = message.getFrom();
        String orderId = message.getContent();
        Message notification = new Message();
        notification.setType("ORDER_CANCELLED");
        notification.setContent("用户 " + userId + " 取消了订单，订单号: " + orderId);
        notification.setTo("admin");
        notification.setFrom("system");
        broadcast(notification);
    }
}