package com.assessment.www.dao;

import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ScreenComment;
import com.assessment.www.Util.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ScreenCommentDaoImpl implements ScreenCommentDao {
    @Override
    public int addComment(ScreenComment comment) {
        String sql = "INSERT INTO screen_comment (video_id, user_id, content, video_time, parent_id) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, comment.getVideoId());
            ps.setInt(2, comment.getUserId());
            ps.setString(3, comment.getContent());
            ps.setFloat(4, comment.getVideoTime());
            ps.setObject(5, comment.getParentId());
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw new BaseException(500, "查询操作失败"+e.getMessage(),e);
        }
    }

    @Override
    public int deleteComment(int id) {
        String sql = "DELETE FROM screen_comment WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw new BaseException(500, "查询操作失败"+e.getMessage(),e);
        }
    }

    @Override
    public List<ScreenComment> getCommentsByVideoId(int videoId) {
        String sql = "SELECT * FROM screen_comment WHERE video_id = ? ORDER BY video_time ASC";
        List<ScreenComment> list = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, videoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ScreenComment sc = new ScreenComment();
                    sc.setId(rs.getInt("id"));
                    sc.setVideoId(rs.getInt("video_id"));
                    sc.setUserId(rs.getInt("user_id"));
                    sc.setContent(rs.getString("content"));
                    sc.setPhoto(rs.getString("photo"));
                    sc.setTimeCreate(rs.getTimestamp("time_create"));
                    Integer parentId = rs.getInt("parent_id");
                    sc.setParentId(rs.wasNull() ? null : parentId);
                    list.add(sc);
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "查询操作失败"+e.getMessage(),e);
        }
        return list;
    }

    @Override
    public List<ScreenComment> getCommentsByreplyId(int replyId) {
        String sql = "SELECT * FROM screen_comment WHERE ID = ?  or parent_id=? ORDER BY video_time ASC";
        List<ScreenComment> list = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, replyId);
            ps.setInt(2, replyId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ScreenComment sc = new ScreenComment();
                    sc.setId(rs.getInt("id"));
                    sc.setVideoId(rs.getInt("video_id"));
                    sc.setUserId(rs.getInt("user_id"));
                    sc.setContent(rs.getString("content"));
                    sc.setTimeCreate(rs.getTimestamp("time_create"));
                    Integer parentId = rs.getInt("parent_id");
                    sc.setParentId(rs.wasNull() ? null : parentId);
                    list.add(sc);
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "查询操作失败"+e.getMessage(),e);
        }
        return list;
    }
}
