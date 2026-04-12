package com.assessment.www.po;

import java.sql.Timestamp;

// 签到记录
public class CheckIn {
    private Integer id;
    private Integer userId;
    private Integer coinCount; // 签到获得的硬币数
    private Timestamp timeCreate;

    // 关联的用户信息
    private User user;

    public CheckIn() {}

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

    public Integer getCoinCount() {
        return coinCount;
    }

    public void setCoinCount(Integer coinCount) {
        this.coinCount = coinCount;
    }

    public Timestamp getTimeCreate() {
        return timeCreate;
    }

    public void setTimeCreate(Timestamp timeCreate) {
        this.timeCreate = timeCreate;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}