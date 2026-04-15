package com.assessment.www.dao;

import com.assessment.www.Util.utils;
import com.assessment.www.po.Video;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class LikeDaoImpl implements LikeDao {
    @Override
    public int addLike(int userId, int videoId) throws Exception {
        String sql = "INSERT INTO likes (user_id, video_id, time_like) VALUES (?, ?, ?)";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, videoId);
            pstmt.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            return pstmt.executeUpdate();
        }
    }

    @Override
    public int removeLike(int userId, int videoId) throws Exception {
        String sql = "DELETE FROM likes WHERE user_id = ? AND video_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, videoId);
            return pstmt.executeUpdate();
        }
    }

    @Override
    public boolean isLiked(int userId, int videoId) throws Exception {
        String sql = "SELECT COUNT(*) FROM likes WHERE user_id = ? AND video_id = ?";
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
    public List<Video> getLikesByUserId(int userId, int page, int pageSize) throws Exception {
        String sql = "SELECT v.* FROM videos v " +
                "INNER JOIN likes l ON v.id = l.video_id " +
                "WHERE l.user_id = ? AND v.status = 1 " +
                "ORDER BY l.time_like DESC " +
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
                video.setFavCount(rs.getInt("fav_count"));
                video.setTimeCreate(rs.getTimestamp("time_create"));
                video.setStatus(rs.getInt("status"));
                videos.add(video);
            }
        }
        return videos;
    }

    @Override
    public int countUserLikes(int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM likes l " +
                "INNER JOIN videos v ON l.video_id = v.id " +
                "WHERE l.user_id = ? AND v.status = 1";
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
