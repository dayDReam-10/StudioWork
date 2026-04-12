package com.assessment.www.po;

import java.sql.Timestamp;

public class VideoCoin {
    private Integer id;
    private Integer userId;
    private Integer videoId;
    private Integer amount; // 投币数量(限制1-2个)
    private Timestamp timeCoin;
    private User user; // 关联的用户信息
    private Video video; // 关联的视频信息

    // 构造方法
    public VideoCoin() {}

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

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    public Timestamp getTimeCoin() {
        return timeCoin;
    }

    public void setTimeCoin(Timestamp timeCoin) {
        this.timeCoin = timeCoin;
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