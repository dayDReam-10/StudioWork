package com.assessment.www.dao.ticket;

import com.assessment.www.po.ticket.ChatMessage;

import java.util.List;

public interface ChatMessageDao {
    //保存聊天消息
    boolean saveMessage(ChatMessage message);

    //获取用户聊天历史
    List<ChatMessage> getChatHistory(int userId);

    //获取当前咨询用户列表
    List<ChatMessage> getConsultingUsers();
}