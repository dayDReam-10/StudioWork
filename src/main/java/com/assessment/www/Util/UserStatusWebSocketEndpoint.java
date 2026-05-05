package com.assessment.www.Util;

import com.assessment.www.Service.UserService;
import com.assessment.www.Service.UserServiceImpl;
import com.assessment.www.constant.Constants;
import com.assessment.www.po.User;
import com.assessment.www.po.ticket.Message;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.websocket.CloseReason;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ServerEndpoint("/websocket/user-status")
public class UserStatusWebSocketEndpoint {
    private static final Map<String, Set<Session>> userSessions = new ConcurrentHashMap<>();
    private static final Map<String, String> sessionUsers = new ConcurrentHashMap<>();
    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final UserService userService = new UserServiceImpl();

    @OnOpen
    public void onOpen(Session session) {
        String query = session.getQueryString();
        String userId = extractQueryParam(query, "userId");
        String role = extractQueryParam(query, "role");

        if (userId == null || userId.trim().isEmpty() || !Constants.ROLEUSER.equals(role)) {
            closeQuietly(session, CloseReason.CloseCodes.VIOLATED_POLICY, "非法的用户状态连接");
            return;
        }

        try {
            User latestUser = userService.getUserById(Integer.parseInt(userId));
            if (latestUser == null || latestUser.getStatus() == null || latestUser.getStatus() != Constants.STATUSNORMAL
                    || !Constants.ROLEUSER.equals(latestUser.getRole())) {
                sendForceLogoutToSession(session, userId, "您的账户已被封禁，请重新登录");
                closeQuietly(session, CloseReason.CloseCodes.VIOLATED_POLICY, "账户已被封禁");
                return;
            }

            session.getUserProperties().put("userId", userId);
            session.getUserProperties().put("role", role);
            userSessions.computeIfAbsent(userId, key -> ConcurrentHashMap.newKeySet()).add(session);
            sessionUsers.put(session.getId(), userId);
        } catch (Exception e) {
            closeQuietly(session, CloseReason.CloseCodes.UNEXPECTED_CONDITION, "用户状态连接初始化失败");
        }
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        // 用户状态通道只负责服务器推送，忽略客户端消息
    }

    @OnClose
    public void onClose(Session session) {
        cleanupSession(session);
    }

    @OnError
    public void onError(Session session, Throwable error) {
        if (session != null) {
            cleanupSession(session);
        }
    }

    public static void sendForceLogoutUser(String userId, String reason) {
        if (userId == null || userId.trim().isEmpty()) {
            return;
        }
        Message message = new Message();
        message.setType("force_logout");
        message.setFrom("system");
        message.setTo(userId);
        message.setContent(reason == null || reason.trim().isEmpty() ? "您的账户状态已变更，请重新登录" : reason);
        sendToUser(userId, message, true);
    }

    private void sendForceLogoutToSession(Session session, String userId, String reason) {
        if (session == null || !session.isOpen()) {
            return;
        }
        Message message = new Message();
        message.setType("force_logout");
        message.setFrom("system");
        message.setTo(userId);
        message.setContent(reason == null || reason.trim().isEmpty() ? "您的账户状态已变更，请重新登录" : reason);
        try {
            session.getBasicRemote().sendText(objectMapper.writeValueAsString(message));
        } catch (Exception e) {
        }
    }

    public static void sendToUser(String userId, Message message) {
        sendToUser(userId, message, false);
    }

    private static void sendToUser(String userId, Message message, boolean closeAfterSend) {
        if (userId == null || userId.trim().isEmpty() || message == null) {
            return;
        }
        Set<Session> sessions = userSessions.get(userId);
        if (sessions == null || sessions.isEmpty()) {
            return;
        }

        String jsonMessage;
        try {
            jsonMessage = objectMapper.writeValueAsString(message);
        } catch (Exception e) {
            return;
        }

        for (Session session : new ArrayList<>(sessions)) {
            if (session == null) {
                continue;
            }
            try {
                if (session.isOpen()) {
                    session.getBasicRemote().sendText(jsonMessage);
                }
            } catch (IOException e) {
                cleanupSession(session);
                continue;
            }
            if (closeAfterSend) {
                closeQuietly(session, CloseReason.CloseCodes.NORMAL_CLOSURE, "账户已被封禁");
            }
        }
    }

    private static void cleanupSession(Session session) {
        if (session == null) {
            return;
        }
        String userId = sessionUsers.remove(session.getId());
        if (userId != null) {
            Set<Session> sessions = userSessions.get(userId);
            if (sessions != null) {
                sessions.remove(session);
                if (sessions.isEmpty()) {
                    userSessions.remove(userId);
                }
            }
        }
    }

    private static void closeQuietly(Session session, CloseReason.CloseCodes closeCode, String reason) {
        if (session == null || !session.isOpen()) {
            return;
        }
        try {
            session.close(new CloseReason(closeCode, reason));
        } catch (IOException e) {
            cleanupSession(session);
        }
    }

    private String extractQueryParam(String queryString, String paramName) {
        if (queryString == null || queryString.isEmpty() || paramName == null || paramName.isEmpty()) {
            return null;
        }
        Pattern pattern = Pattern.compile(paramName + "=([^&]+)");
        Matcher matcher = pattern.matcher(queryString);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }
}