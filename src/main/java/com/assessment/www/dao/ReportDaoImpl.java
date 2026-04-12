package com.assessment.www.dao;

import com.assessment.www.Util.utils;
import com.assessment.www.po.Report;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportDaoImpl implements ReportDao {
    @Override
    public int addReport(Report report) {
        String sql = "INSERT INTO report (video_id, user_id, reason_detail, status, time_create) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, report.getVideoId());
            pstmt.setInt(2, report.getUserId());
            pstmt.setString(3, report.getReasonDetail());
            pstmt.setInt(4, report.getStatus());
            pstmt.setTimestamp(5, report.getTimeCreate());
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public List<Report> getPendingReports(int page, int pageSize) {
        String sql = "SELECT * FROM report WHERE status = 0 ORDER BY time_create DESC LIMIT ? OFFSET ?";
        List<Report> reports = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, pageSize);
            pstmt.setInt(2, (page - 1) * pageSize);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                reports.add(mapRowToReport(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reports;
    }

    @Override
    public List<Report> getAllReports(int page, int pageSize) {
        String sql = "SELECT * FROM report ORDER BY time_create DESC LIMIT ? OFFSET ?";
        List<Report> reports = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, pageSize);
            pstmt.setInt(2, (page - 1) * pageSize);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                reports.add(mapRowToReport(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reports;
    }

    @Override
    public int getTotalReportCount() {
        String sql = "SELECT COUNT(*) FROM report";
        try (Connection conn = utils.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public boolean processReport(Integer reportId,Integer status) {
        String sql = "UPDATE report SET status = ?  WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, status);
            pstmt.setInt(2, reportId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Report getReportById(Integer reportId) {
        String sql = "SELECT * FROM report WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, reportId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return mapRowToReport(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Report> getReportsByVideoId(Integer videoId) {
        String sql = "SELECT * FROM report WHERE video_id = ? ORDER BY time_create DESC";
        List<Report> reports = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, videoId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                reports.add(mapRowToReport(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reports;
    }

    @Override
    public List<Report> getProcessedReports(int page, int pageSize) {
        String sql = "SELECT * FROM report WHERE status != 0 ORDER BY time_create DESC LIMIT ? OFFSET ?";
        List<Report> reports = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, pageSize);
            pstmt.setInt(2, (page - 1) * pageSize);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                reports.add(mapRowToReport(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reports;
    }

    @Override
    public int getPendingReportCount() {
        String sql = "SELECT COUNT(*) FROM report WHERE status = 0";
        try (Connection conn = utils.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    @Override
    public boolean checkReported(int userId, int videoId) {
        // 检查用户是否已经举报过该视频，防止重复举报
        String sql = "SELECT COUNT(*) FROM report WHERE user_id = ? AND video_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, videoId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.out.print("检查举报状态失败");
        }
        return false;
    }
    // 辅助方法：将ResultSet映射到Report对象
    private Report mapRowToReport(ResultSet rs) throws SQLException {
        Report report = new Report();
        report.setId(rs.getInt("id"));
        report.setVideoId(rs.getInt("video_id"));
        report.setUserId(rs.getInt("user_id"));
        report.setReasonDetail(rs.getString("reason_detail"));
        report.setStatus(rs.getInt("status"));
        report.setTimeCreate(rs.getTimestamp("time_create"));
        return report;
    }
}