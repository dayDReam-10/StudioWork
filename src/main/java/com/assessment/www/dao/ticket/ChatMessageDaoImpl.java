package com.assessment.www.dao.ticket;

import com.assessment.www.Util.utils;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ticket.ChatMessage;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatMessageDaoImpl implements ChatMessageDao {
    @Override
    public boolean saveMessage(ChatMessage message) {
        String sql = "INSERT INTO chat_messages (user_id, username, content, sender, time) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = utils.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, message.getUserId());
            stmt.setString(2, message.getUsername());
            stmt.setString(3, message.getContent());
            stmt.setString(4, message.getSender());
            stmt.setTimestamp(5, message.getTime());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
    }

    @Override
    public List<ChatMessage> getChatHistory(int userId) {
        String sql = "SELECT * FROM chat_messages WHERE user_id = ? ORDER BY time ASC";
        List<ChatMessage> messages = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
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
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
        return messages;
    }

    @Override
    public List<ChatMessage> getConsultingUsers() {
        String sql = "SELECT DISTINCT user_id, username, MAX(time) as last_time FROM chat_messages GROUP BY user_id, username ORDER BY last_time DESC LIMIT 10";
        List<ChatMessage> users = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                ChatMessage user = new ChatMessage();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setTime(rs.getTimestamp("last_time"));
                users.add(user);
            }
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
        return users;
    }
}