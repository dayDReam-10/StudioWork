package com.assessment.www.po.ticket;

import java.sql.Timestamp;

// 用户收藏漫展实体类
public class UserFavorite {
    private Integer id;
    private Integer userId;
    private Integer exhibitionId;
    private Timestamp createTime;

    // getter setter方法设置
    public UserFavorite() {
    }

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

    public Integer getExhibitionId() {
        return exhibitionId;
    }

    public void setExhibitionId(Integer exhibitionId) {
        this.exhibitionId = exhibitionId;
    }

    public Timestamp getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Timestamp createTime) {
        this.createTime = createTime;
    }
}