package com.assessment.www.Service.ticket;

import com.assessment.www.dao.ticket.ChatMessageDao;
import com.assessment.www.dao.ticket.ChatMessageDaoImpl;
import com.assessment.www.po.ticket.ChatMessage;
import com.assessment.www.Util.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ChatMessageServiceImpl implements ChatMessageService {
    private ChatMessageDao chatMessageDao;

    public ChatMessageServiceImpl() {
        this.chatMessageDao = new ChatMessageDaoImpl();
    }

    @Override
    public boolean saveMessage(ChatMessage message) {
        return chatMessageDao.saveMessage(message);
    }

    @Override
    public List<ChatMessage> getChatHistory(int userId) {
        return chatMessageDao.getChatHistory(userId);
    }

    @Override
    public List<ChatMessage> getConsultingUsers() {
        return chatMessageDao.getConsultingUsers();
    }

    //保存用户咨询消息
    public boolean saveUserMessage(int userId, String username, String content) {
        ChatMessage message = new ChatMessage();
        message.setUserId(userId);
        message.setUsername(username);
        message.setContent(content);
        message.setSender("user");
        message.setTime(new java.sql.Timestamp(System.currentTimeMillis()));
        return chatMessageDao.saveMessage(message);
    }

    //保存管理员回复消息
    public boolean saveAdminMessage(int userId, String content) {
        ChatMessage message = new ChatMessage();
        message.setUserId(userId);
        message.setUsername("管理员");
        message.setContent(content);
        message.setSender("admin");
        message.setTime(new java.sql.Timestamp(System.currentTimeMillis()));
        return chatMessageDao.saveMessage(message);
    }

    //获取指定用户的消息数量
    public int getMessageCount(int userId) {
        List<ChatMessage> messages = chatMessageDao.getChatHistory(userId);
        return messages.size();
    }

    //获取未读消息数量
    public int getUnreadCount(int userId) {
        String sql = "SELECT COUNT(*) as count FROM chat_messages WHERE user_id = ? AND sender = 'admin'";
        try (Connection conn = utils.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    //清除用户聊天记录
    public boolean clearChatHistory(int userId) {
        try (Connection conn = utils.getConnection();
             PreparedStatement stmt = conn.prepareStatement("DELETE FROM chat_messages WHERE user_id = ?")) {
            stmt.setInt(1, userId);
            int result = stmt.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    //获取最近的咨询消息
    public List<ChatMessage> getRecentMessages(int limit) {
        String sql = "SELECT * FROM chat_messages ORDER BY time DESC LIMIT ?";
        List<ChatMessage> messages = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ChatMessage message = new ChatMessage();
                    message.setId(rs.getInt("id"));
                    message.setUserId(rs.getInt("user_id"));
                    message.setUsername(rs.getString("username"));
                    message.setContent(rs.getString("content"));
                    message.setSender(rs.getString("sender"));
                    message.setTime(rs.getTimestamp("time"));
                    messages.add(message);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return messages;
    }

    //获取活跃用户列表
    public List<ChatMessage> getActiveUsers(int hours) {
        String sql = "SELECT DISTINCT user_id, username, MAX(time) as last_time " +
                "FROM chat_messages " +
                "WHERE time >= DATE_SUB(NOW(), INTERVAL ? HOUR) " +
                "GROUP BY user_id, username " +
                "ORDER BY last_time DESC";
        List<ChatMessage> users = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, hours);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ChatMessage user = new ChatMessage();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setTime(rs.getTimestamp("last_time"));
                    users.add(user);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
}