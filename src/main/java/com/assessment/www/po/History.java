package com.assessment.www.po;

import java.sql.Timestamp;

public class History {
    private Integer id;
    private Integer userId;
    private Integer videoId;
    private Timestamp timeView;
    private User user; // 关联的用户信息
    private Video video; // 关联的视频信息

    // 构造方法
    public History() {}

    // getter和setter方法
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getVideoId() {
        return videoId;
    }

    public void setVideoId(Integer videoId) {
        this.videoId = videoId;
    }

    public Timestamp getTimeView() {
        return timeView;
    }

    public void setTimeView(Timestamp timeView) {
        this.timeView = timeView;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Video getVideo() {
        return video;
    }

    public void setVideo(Video video) {
        this.video = video;
    }
}