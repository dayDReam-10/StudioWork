package com.assessment.www.po.ticket;

import java.sql.Timestamp;

//咨询信息保存发送
public class ChatMessage {
    private int id;
    private int userId;
    private String username;
    private String content;
    private String sender;
    private Timestamp time;
    private boolean isRead;

    public ChatMessage() {
    }

    public ChatMessage(int id, int userId, String username, String content, String sender, Timestamp time) {
        this.id = id;
        this.userId = userId;
        this.username = username;
        this.content = content;
        this.sender = sender;
        this.time = time;
        this.isRead = false;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public Timestamp getTime() {
        return time;
    }

    public void setTime(Timestamp time) {
        this.time = time;
    }

    public String getFormattedTime() {
        return time != null ? time.toString().substring(11, 16) : "";
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }
}