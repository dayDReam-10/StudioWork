package com.assessment.www.po;

import java.sql.Timestamp;
import java.util.List;

public class ScreenComment {
    //主键，视频id，用户id，评论内容，视频内时间点
    private Integer id;
    private Integer videoId;
    private Integer userId;
    private String content;
    private Float videoTime;
    private Timestamp timeCreate;
    private Video video; // 关联的视频信息
    private User user; // 关联的用户信息
    private Integer parentId; // 父评论ID，用于回复功能
    private List<ScreenComment> replies; // 回复列表，支持多级回复

    public ScreenComment() {
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getVideoId() {
        return videoId;
    }

    public void setVideoId(Integer videoId) {
        this.videoId = videoId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Float getVideoTime() {
        return videoTime;
    }

    public void setVideoTime(Float videoTime) {
        this.videoTime = videoTime;
    }

    public Timestamp getTimeCreate() {
        return timeCreate;
    }

    public void setTimeCreate(Timestamp timeCreate) {
        this.timeCreate = timeCreate;
    }

    public Video getVideo() {
        return video;
    }

    public void setVideo(Video video) {
        this.video = video;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public List<ScreenComment> getReplies() {
        return replies;
    }

    public void setReplies(List<ScreenComment> replies) {
        this.replies = replies;
    }
}
