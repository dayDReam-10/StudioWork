package com.assessment.www.po;

import java.sql.Timestamp;

public class Video {
    private Integer id;
    private String title;
    private String videoUrl;
    private String coverUrl;
    private Integer authorId;
    private String description;
    private Integer viewCount;
    private Integer status; // 0-待审核, 1-通过, 2-驳回
    private Integer likeCount;
    private Integer coinCount;
    private Integer favCount;
    private Integer screenCommentCount;
    private Timestamp timeCreate;
    private User author; // 关联的作者信息

    // 构造方法
    public Video() {}

    // getter和setter方法
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public String getCoverUrl() {
        return coverUrl;
    }

    public void setCoverUrl(String coverUrl) {
        this.coverUrl = coverUrl;
    }

    public Integer getAuthorId() {
        return authorId;
    }

    public void setAuthorId(Integer authorId) {
        this.authorId = authorId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getViewCount() {
        return viewCount;
    }

    public void setViewCount(Integer viewCount) {
        this.viewCount = viewCount;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Integer getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(Integer likeCount) {
        this.likeCount = likeCount;
    }

    public Integer getCoinCount() {
        return coinCount;
    }

    public void setCoinCount(Integer coinCount) {
        this.coinCount = coinCount;
    }

    public Integer getFavCount() {
        return favCount;
    }

    public void setFavCount(Integer favCount) {
        this.favCount = favCount;
    }

    public Integer getScreenCommentCount() {
        return screenCommentCount;
    }

    public void setScreenCommentCount(Integer screenCommentCount) {
        this.screenCommentCount = screenCommentCount;
    }

    public Timestamp getTimeCreate() {
        return timeCreate;
    }

    public void setTimeCreate(Timestamp timeCreate) {
        this.timeCreate = timeCreate;
    }

    public User getAuthor() {
        return author;
    }

    public void setAuthor(User author) {
        this.author = author;
    }
}