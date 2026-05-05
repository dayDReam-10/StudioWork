package com.assessment.www.dao;

import com.assessment.www.po.Video;

import java.util.List;

// 收藏数据访问接口
public interface FavoriteDao {
    // 添加收藏
    int addFavorite(int userId, int videoId) throws Exception;

    // 取消收藏
    int removeFavorite(int userId, int videoId) throws Exception;

    // 检查是否已收藏
    boolean isFavorited(int userId, int videoId) throws Exception;

    // 获取用户收藏的视频列表
    List<Video> getFavoritesByUserId(int userId, int page, int pageSize) throws Exception;

    // 获取用户收藏总数
    int countUserFavorites(int userId) throws Exception;
}