package com.assessment.www.dao;

import com.assessment.www.Util.utils;
import com.assessment.www.po.History;
import com.assessment.www.po.User;
import com.assessment.www.po.Video;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

//历史记录实现类
public class HistoryDaoImpl implements HistoryDao {
    @Override
    public int save(History history) throws Exception {//使用MySQL的ON DUPLICATE KEY UPDATE实现插入或更新
        String sql = "INSERT INTO history (user_id, video_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE time_view = CURRENT_TIMESTAMP";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, history.getUserId());
            pstmt.setInt(2, history.getVideoId());
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.print("保存历史记录失败");
            throw e;
        }
    }

    @Override
    public List<History> findByUserId(Integer userId) throws Exception {
        //LEFT JOIN 包含history表中的所有记录，只查当前登录用户
        String sql = "SELECT h.*, v.title, v.cover_url, v.author_id, u.username as author_name " +
                "FROM history h " +
                "LEFT JOIN videos v ON h.video_id = v.id " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE h.user_id = ? ORDER BY h.time_view DESC";
        List<History> histories = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {     
                while (rs.next()) {
                    histories.add(extractHistoryFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("查询历史记录失败");
            throw e;
        }
        return histories; 
    }

    @Override
    public int delete(Integer id) throws Exception {
        String sql = "DELETE FROM history WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.print("删除历史记录失败");
            throw e;
        }
    }

    @Override
    public int deleteByUserId(Integer userId) throws Exception {
        String sql = "DELETE FROM history WHERE user_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.print("清空历史记录失败");
            throw e;
        }
    }

    //从ResultSet中提取History对象
    private History extractHistoryFromResultSet(ResultSet rs) throws SQLException {
        History history = new History();
        history.setId(rs.getInt("id"));
        history.setUserId(rs.getInt("user_id"));
        history.setVideoId(rs.getInt("video_id"));
        history.setTimeView(rs.getTimestamp("time_view"));

        Video video = new Video();
        video.setId(history.getVideoId());
        video.setTitle(rs.getString("title"));
        video.setCoverUrl(rs.getString("cover_url"));
        video.setAuthorId(rs.getInt("author_id"));
        history.setVideo(video);

        User author = new User();   
        author.setId(video.getAuthorId());
        author.setUsername(rs.getString("author_name"));
        video.setAuthor(author);
        return history;
    }
}