package com.assessment.www.Util.ticket;

import com.assessment.www.dao.ticket.ChatMessageDao;
import com.assessment.www.dao.ticket.ChatMessageDaoImpl;
import com.assessment.www.po.ticket.ChatMessage;
import com.assessment.www.po.ticket.Message;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;

//咨询WebSocket端点 处理用户咨询消息的实时通信
@ServerEndpoint("/websocket/consultation")
public class ConsultationWebSocketEndpoint {
    //在线session集合
    private static final Map<String, Session> sessions = new ConcurrentHashMap<>();
    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final ChatMessageDao chatMessageDao = new ChatMessageDaoImpl();
    //在线用户集合
    private static final Map<String, OnlineUserInfo> onlineUsers = new ConcurrentHashMap<>();

    // 在线用户信息
    public static class OnlineUserInfo {
        private String userId;
        private String username;
        private long lastActiveTime;
        private Session session;

        public OnlineUserInfo(String userId, String username, Session session) {
            this.userId = userId;
            this.username = username;
            this.lastActiveTime = System.currentTimeMillis();
            this.session = session;
        }

        public String getUserId() {
            return userId;
        }

        public String getUsername() {
            return username;
        }

        public long getLastActiveTime() {
            return lastActiveTime;
        }

        public void updateLastActiveTime() {
            this.lastActiveTime = System.currentTimeMillis();
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public boolean isSessionOpen() {
            return session != null && session.isOpen();
        }
    }

    //WebSocket连接建立时调用
    @OnOpen
    public void onOpen(Session session, EndpointConfig config) {
        String query = session.getQueryString();
        if (query != null) {
            String userId = extractQueryParam(query, "userId");
            String role = extractQueryParam(query, "role");
            if (userId != null) {
                session.getUserProperties().put("userId", userId);
            }
            if (role != null) {
                session.getUserProperties().put("role", role);
            }
            if ("user".equals(role) && userId != null) {
                String username = "用户" + userId;
                OnlineUserInfo info = new OnlineUserInfo(userId, username, session);
                onlineUsers.put(userId, info);
            }
        } else {
            System.out.println("咨询WebSocket连接建立 - ID: " + session.getId() + " (无参数)");
        }
        sessions.put(session.getId(), session);
    }

    // 从查询字符串提取参数值
    private String extractQueryParam(String queryString, String paramName) {
        String pattern = paramName + "=([^&]+)";
        Pattern p = Pattern.compile(pattern);
        Matcher m = p.matcher(queryString);
        if (m.find()) {
            return m.group(1);
        }
        return null;
    }

    //WebSocket连接关闭时调用
    @OnClose
    public void onClose(Session session) {
        String userId = (String) session.getUserProperties().get("userId");
        if (userId != null) {
            onlineUsers.remove(userId);
        }
        sessions.remove(session.getId());
    }

    //收到客户端消息时调用
    @OnMessage
    public void onMessage(String message, Session session) {
        try {
            // 记录收到的消息
            Message msg = objectMapper.readValue(message, Message.class);
            switch (msg.getType()) { // 根据消息类型进行相应处理
                case "user":
                    handleUserMessage(session, msg);
                    break;
                case "admin":
                    handleAdminMessage(session, msg);
                    break;
                case "history":
                    handleHistoryRequest(session, msg);
                    break;
                case "admin_identity":
                    break;
                default:
                    sendErrorMessage(session, "未知消息类型");
            }
        } catch (Exception e) {
            System.err.println("处理消息时发生错误: " + e.getMessage());
            sendErrorMessage(session, "消息处理失败");
        }
    }

    //WebSocket发生错误时调用
    @OnError
    public void onError(Session session, Throwable error) {
        String errMsg = error.getMessage();
        if (errMsg != null && (errMsg.contains("Software caused connection abort") || errMsg.contains("socket write error"))) {
            return;
        }
        System.err.println("WebSocket发生错误 - 会话ID: " + session.getId() + ", 错误信息: " + error.getMessage());
    }

    //向指定用户发送消息
    public static void sendToUser(String userId, Message message) {
        try {
            String jsonMessage = objectMapper.writeValueAsString(message);
            sessions.values().forEach(session -> {
                try {
                    if (session.isOpen()) {
                        String userIdInSession = (String) session.getUserProperties().get("userId");
                        if (userId != null && userId.equals(userIdInSession)) {
                            session.getBasicRemote().sendText(jsonMessage);
                        }
                    }
                } catch (IOException e) {
                    System.err.println("发送消息给用户失败: " + e.getMessage());
                }
            });
        } catch (Exception e) {
            System.err.println("JSON序列化失败: " + e.getMessage());
        }
    }

    //向所有管理员发送消息
    public static void sendToAdmins(Message message) {
        try {
            String jsonMessage = objectMapper.writeValueAsString(message);
            sessions.values().forEach(session -> {
                try {
                    if (session.isOpen()) {
                        String role = (String) session.getUserProperties().get("role");
                        if ("admin".equals(role)) {
                            session.getBasicRemote().sendText(jsonMessage);
                        }
                    }
                } catch (IOException e) {
                    System.err.println("发送消息给管理员失败: " + e.getMessage());
                }
            });
        } catch (Exception e) {
            System.err.println("JSON序列化失败: " + e.getMessage());
        }
    }

    //向指定会话发送消息
    private void sendToSession(Session session, Message message) {
        try {
            String jsonMessage = objectMapper.writeValueAsString(message);
            session.getBasicRemote().sendText(jsonMessage);
        } catch (IOException e) {
            System.err.println("发送消息到会话失败: " + e.getMessage());
        }
    }

    //发送错误消息
    private void sendErrorMessage(Session session, String errorMessage) {
        try {
            Message error = new Message();
            error.setType("error");
            error.setContent(errorMessage);
            sendToSession(session, error);
        } catch (Exception e) {
            System.err.println("发送错误消息失败: " + e.getMessage());
        }
    }

    //处理用户发送的消息
    private void handleUserMessage(Session session, Message message) {
        try {
            String userId = (String) session.getUserProperties().get("userId");
            String role = (String) session.getUserProperties().get("role");
            // 设置用户ID和角色
            if (userId == null) {
                session.getUserProperties().put("userId", message.getFrom());
                userId = message.getFrom();
            }
            if (role == null) {
                session.getUserProperties().put("role", "user");
            }
            // 更新在线用户信息
            if (userId != null) {
                OnlineUserInfo info = onlineUsers.get(userId);
                if (info != null) {
                    info.updateLastActiveTime();
                    if (message.getUsername() != null && !message.getUsername().isEmpty()) {
                        info.setUsername(message.getUsername());
                    }
                }
            }
            // 保存用户消息到数据库
            boolean saved = saveUserMessageToDatabase(message);
            if (!saved) {
                sendErrorMessage(session, "消息保存失败");
                return;
            }
            // 创建要发送给管理员的回复消息
            Message adminMessage = new Message();
            adminMessage.setType("user");
            adminMessage.setFrom(userId);
            adminMessage.setTo("admin");
            adminMessage.setContent(message.getContent());
            adminMessage.setUsername(message.getUsername());
            adminMessage.setTimestamp(message.getTimestamp());
            sendToAdmins(adminMessage);
            // 向用户发送成功确认
            Message confirmMessage = new Message();
            confirmMessage.setType("confirm");
            confirmMessage.setContent("消息发送成功");
            sendToSession(session, confirmMessage);
        } catch (Exception e) {
            System.err.println("处理用户消息时发生错误: " + e.getMessage());
            sendErrorMessage(session, "消息处理失败");
        }
    }

    //处理管理员回复的消息
    private void handleAdminMessage(Session session, Message message) {
        try {
            String adminId = (String) session.getUserProperties().get("userId");
            String role = (String) session.getUserProperties().get("role");
            // 验证管理员身份
            if (!"admin".equals(role)) {
                sendErrorMessage(session, "权限不足");
                return;
            }
            if (adminId == null) {
                session.getUserProperties().put("userId", message.getFrom());
                adminId = message.getFrom();
            }
            // 保存管理员回复到数据库
            boolean saved = saveAdminMessageToDatabase(message);
            if (!saved) {
                sendErrorMessage(session, "回复保存失败");
                return;
            }
            // 发送回复给用户
            Message userMessage = new Message();
            userMessage.setType("admin");
            userMessage.setFrom(adminId);
            userMessage.setTo(message.getTo());
            userMessage.setContent(message.getContent());
            userMessage.setTimestamp(message.getTimestamp());
            sendToUser(message.getTo(), userMessage);
            // 向管理员发送成功确认
            Message confirmMessage = new Message();
            confirmMessage.setType("confirm");
            confirmMessage.setContent("回复发送成功");
            sendToSession(session, confirmMessage);
            // 通知其他管理员有人已回复
            Message notifyMessage = new Message();
            notifyMessage.setType("admin_replied");
            notifyMessage.setTo("admin");
            notifyMessage.setContent(message.getContent());
            sendToAdmins(notifyMessage);
        } catch (Exception e) {
            System.err.println("处理管理员回复时发生错误: " + e.getMessage());
            sendErrorMessage(session, "回复处理失败");
        }
    }

    //保存用户消息到数据库
    private boolean saveUserMessageToDatabase(Message message) {
        try {
            ChatMessage chatMessage = new ChatMessage();
            int userId = Integer.parseInt(message.getFrom());
            chatMessage.setUserId(userId);
            chatMessage.setUsername("用户" + userId);
            chatMessage.setContent(message.getContent());
            chatMessage.setSender("user");
            chatMessage.setTime(new Timestamp(message.getTimestamp()));
            chatMessage.setRead(false); // 用户消息默认未读
            if (message != null && message.getContent() != null && message.getContent() != "") {
                boolean saved = chatMessageDao.saveMessage(chatMessage);
                if (saved) {
                    return true;
                } else {
                    System.err.println("用户消息保存失败 - 用户ID: " + userId);
                    return false;
                }
            }
            return true;
        } catch (NumberFormatException e) {
            System.err.println("用户ID格式错误: " + message.getFrom());
            return false;
        } catch (Exception e) {
            System.err.println("保存用户消息到数据库时发生错误: " + e.getMessage());
            return false;
        }
    }

    //保存管理员回复到数据库
    private boolean saveAdminMessageToDatabase(Message message) {
        try {
            ChatMessage chatMessage = new ChatMessage();
            int userId = Integer.parseInt(message.getTo());
            chatMessage.setUserId(userId);
            chatMessage.setUsername("管理员");
            chatMessage.setContent(message.getContent());
            chatMessage.setSender("admin");
            chatMessage.setTime(new Timestamp(message.getTimestamp()));
            chatMessage.setRead(false);
            boolean saved = chatMessageDao.saveMessage(chatMessage);
            if (saved) {
                return true;
            } else {
                System.err.println("管理员回复保存失败 - 目标用户ID: " + userId);
                return false;
            }
        } catch (NumberFormatException e) {
            System.err.println("目标用户ID格式错误: " + message.getTo());
            return false;
        } catch (Exception e) {
            System.err.println("保存管理员回复到数据库时发生错误: " + e.getMessage());
            return false;
        }
    }

    // 处理聊天历史请求
    private void handleHistoryRequest(Session session, Message message) {
        try {
            String userId = (String) session.getUserProperties().get("userId");
            if (userId == null) {
                sendErrorMessage(session, "请先登录");
                return;
            }
            int userIdInt = Integer.parseInt(userId);
            List<ChatMessage> history = chatMessageDao.getChatHistory(userIdInt);
            Message historyMessage = new Message();
            historyMessage.setType("history");
            historyMessage.setFrom("system");
            historyMessage.setTo(userId);
            historyMessage.setContent(objectMapper.writeValueAsString(history));
            historyMessage.setTimestamp(System.currentTimeMillis());
            sendToSession(session, historyMessage);
            System.out.println("已发送聊天历史给用户ID: " + userId + "，消息数: " + history.size());
        } catch (Exception e) {
            System.err.println("获取或发送聊天历史时发生错误: " + e.getMessage());
            sendErrorMessage(session, "获取聊天历史失败");
        }
    }


    //根据用户ID查找会话
    private Session findSessionByUserId(String userId) {
        for (Session session : sessions.values()) {
            String userIdInSession = (String) session.getUserProperties().get("userId");
            if (userId != null && userId.equals(userIdInSession)) {
                return session;
            }
        }
        return null;
    }

    //获取在线用户数量
    public static int getOnlineUserCount() {
        int count = 0;
        for (Session session : sessions.values()) {
            String role = (String) session.getUserProperties().get("role");
            if ("user".equals(role)) {
                count++;
            }
        }
        return count;
    }

    //获取在线管理员数量
    public static int getOnlineAdminCount() {
        int count = 0;
        for (Session session : sessions.values()) {
            String role = (String) session.getUserProperties().get("role");
            if ("admin".equals(role)) {
                count++;
            }
        }
        return count;
    }

    //获取当前会话数量
    public static int getSessionCount() {
        return sessions.size();
    }

    //定期清理无效会话
    public static void cleanupInvalidSessions() {
        sessions.entrySet().removeIf(entry -> {
            Session session = entry.getValue();
            if (!session.isOpen()) {
                return true;
            }
            return false;
        });
    }

    //发送系统广播消息
    public static void broadcastSystemMessage(String content) {
        Message systemMessage = new Message();
        systemMessage.setType("system");
        systemMessage.setFrom("system");
        systemMessage.setContent(content);
        systemMessage.setTimestamp(System.currentTimeMillis());
        sessions.values().forEach(session -> {
            try {
                if (session.isOpen()) {
                    String jsonMessage = objectMapper.writeValueAsString(systemMessage);
                    session.getBasicRemote().sendText(jsonMessage);
                }
            } catch (IOException e) {
                System.err.println("发送系统广播消息失败: " + e.getMessage());
            }
        });
    }

    //获取在线用户列表
    public static List<Map<String, Object>> getOnlineUsersList() {
        List<Map<String, Object>> list = new ArrayList<>();
        long now = System.currentTimeMillis();
        onlineUsers.values().removeIf(info -> !info.isSessionOpen());
        for (OnlineUserInfo info : onlineUsers.values()) {
            Map<String, Object> map = new HashMap<>();
            map.put("userId", info.getUserId());
            map.put("username", info.getUsername());
            map.put("isOnline", true);
            map.put("time", new Timestamp(info.getLastActiveTime()));
            list.add(map);
        }
        list.sort((a, b) -> {
            long t1 = ((Timestamp) a.get("time")).getTime();
            long t2 = ((Timestamp) b.get("time")).getTime();
            return Long.compare(t2, t1);
        });
        return list;
    }
}