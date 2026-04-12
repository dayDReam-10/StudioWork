package com.assessment.www.po;

import java.sql.Timestamp;

//实体类
//user
public class User {
    private Integer id;
    private Timestamp timeCreate;
    private String username;
    private String password;
    private String avatarUrl;
    private Integer gender;
    private String signature;
    private Integer coinCount;
    private Integer followingCount;
    private Integer followerCount;
    private Integer totalLikeCount;
    private Integer totalFavCount;
    private String role;
    private Integer status;

    //getter setter
    //666没框架我要写一万个构造
    public User() {

    }

    //不写带参构造 后续用set
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public Integer getGender() {//0 保密 2 女 1 男
        return gender;
    }

    public void setGender(Integer gender) {
        this.gender = gender;
    }

    public String getSignature() {
        return signature;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }

    public Integer getCoinCount() {
        return coinCount;
    }

    public void setCoinCount(Integer coinCount) {
        this.coinCount = coinCount;
    }

    public Integer getFollowingCount() {
        return followingCount;
    }

    public void setFollowingCount(Integer followingCount) {
        this.followingCount = followingCount;
    }

    public Integer getFollowerCount() {
        return followerCount;
    }

    public void setFollowerCount(Integer followerCount) {
        this.followerCount = followerCount;
    }

    //被
    public Integer getTotalLikeCount() {
        return totalLikeCount;
    }

    public void setTotalLikeCount(Integer totalLikeCount) {
        this.totalLikeCount = totalLikeCount;
    }

    public Integer getTotalFavCount() {
        return totalFavCount;
    }

    public void setTotalFavCount(Integer totalFavCount) {
        this.totalFavCount = totalFavCount;
    }

    public String getRole() {
        return role;
    }

    //用户开始就固定了，是否要setRole方法，还是在注册的时候就直接设置好，后续不允许修改
    public void setRole(String role) {
        this.role = role;
    }

    public Integer getStatus() {
        return status;
    }

    //用户状态，1正常，0封禁
    public void setStatus(Integer status) {
        this.status = status;
    }

    public Timestamp getTimeCreate() {
        return timeCreate;
    }

    public void setTimeCreate(Timestamp timeCreate) {
        this.timeCreate = timeCreate;
    }
}

