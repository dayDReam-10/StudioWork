package com.assessment.www.dao;

import com.assessment.www.po.Video;

import java.util.List;

public interface LikeDao {
    // 添加点赞
    int addLike(int userId, int videoId) throws Exception;

    // 取消点赞
    int removeLike(int userId, int videoId) throws Exception;

    // 检查是否已点赞
    boolean isLiked(int userId, int videoId) throws Exception;

    // 获取用户点赞的视频列表
    List<Video> getLikesByUserId(int userId, int page, int pageSize) throws Exception;

    // 获取用户点赞总数
    int countUserLikes(int userId) throws Exception;
}
