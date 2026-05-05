package com.assessment.www.Service.ticket;

import com.assessment.www.po.ticket.ChatMessage;

import java.util.List;

//聊天接口信息
public interface ChatMessageService {
    //保存聊天消息
    boolean saveMessage(ChatMessage message);

    //获取用户聊天历史
    List<ChatMessage> getChatHistory(int userId);

    //获取当前咨询用户列表
    List<ChatMessage> getConsultingUsers();

    //保存用户咨询消息
    boolean saveUserMessage(int userId, String username, String content);

    //保存管理员回复消息
    boolean saveAdminMessage(int userId, String content);

    //获取指定用户的消息数量
    int getMessageCount(int userId);

    //获取未读消息数量
    int getUnreadCount(int userId);

    //清除用户聊天记录
    boolean clearChatHistory(int userId);

    //获取最近的咨询消息
    List<ChatMessage> getRecentMessages(int limit);

    //获取活跃用户列表
    List<ChatMessage> getActiveUsers(int hours);
}