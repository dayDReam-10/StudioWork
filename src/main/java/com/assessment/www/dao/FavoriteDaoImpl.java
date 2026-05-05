package com.assessment.www.dao;

import com.assessment.www.po.Video;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.assessment.www.Util.utils;

public class FavoriteDaoImpl implements FavoriteDao {
    @Override
    public int addFavorite(int userId, int videoId) throws Exception {
        String sql = "INSERT INTO favorites (user_id, video_id, create_time) VALUES (?, ?, ?)";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, videoId);
            pstmt.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            return pstmt.executeUpdate();
        }
    }

    @Override
    public int removeFavorite(int userId, int videoId) throws Exception {
        String sql = "DELETE FROM favorites WHERE user_id = ? AND video_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, videoId);
            return pstmt.executeUpdate();
        }
    }

    @Override
    public boolean isFavorited(int userId, int videoId) throws Exception {
        String sql = "SELECT COUNT(*) FROM favorites WHERE user_id = ? AND video_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, videoId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    @Override
    public List<Video> getFavoritesByUserId(int userId, int page, int pageSize) throws Exception {
        String sql = "SELECT v.* FROM videos v " +
                "INNER JOIN favorites f ON v.id = f.video_id " +
                "WHERE f.user_id = ? AND v.status = 1 " +
                "ORDER BY f.time_fav DESC " +
                "LIMIT ? OFFSET ?";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, pageSize);
            pstmt.setInt(3, (page - 1) * pageSize);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Video video = new Video();
                video.setId(rs.getInt("id"));
                video.setAuthorId(rs.getInt("author_id"));
                video.setTitle(rs.getString("title"));
                video.setVideoUrl(rs.getString("video_url"));
                video.setCoverUrl(rs.getString("cover_url"));
                video.setDescription(rs.getString("description"));
                video.setViewCount(rs.getInt("view_count"));
                video.setLikeCount(rs.getInt("like_count"));
                video.setCoinCount(rs.getInt("coin_count"));
                video.setTimeCreate(rs.getTimestamp("time_create"));
                video.setStatus(rs.getInt("status"));
                videos.add(video);
            }
        }
        return videos;
    }

    @Override
    public int countUserFavorites(int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM favorites f " +
                "INNER JOIN videos v ON f.video_id = v.id " +
                "WHERE f.user_id = ? AND v.status = 1";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
}