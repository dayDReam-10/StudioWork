package com.assessment.www.po;

import java.sql.Timestamp;

public class UserFollow {
    private Integer id;
    private Integer userId; // 被关注者(大V)的ID
    private Integer followerId; // 关注者(粉丝)的ID
    private Timestamp timeFollow;
    private User user; // 关联的被关注者信息
    private User follower; // 关联的粉丝信息

    // 构造方法
    public UserFollow() {}

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

    public Integer getFollowerId() {
        return followerId;
    }

    public void setFollowerId(Integer followerId) {
        this.followerId = followerId;
    }

    public Timestamp getTimeFollow() {
        return timeFollow;
    }

    public void setTimeFollow(Timestamp timeFollow) {
        this.timeFollow = timeFollow;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public User getFollower() {
        return follower;
    }

    public void setFollower(User follower) {
        this.follower = follower;
    }
}