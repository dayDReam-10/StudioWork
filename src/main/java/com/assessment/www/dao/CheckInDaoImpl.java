package com.assessment.www.dao;

import com.assessment.www.exception.BaseException;
import com.assessment.www.po.CheckIn;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.assessment.www.Util.utils;

public class CheckInDaoImpl implements CheckInDao {
    @Override
    public int addCheckIn(CheckIn checkIn) {
        String sql = "INSERT INTO checkin (user_id, coin_count, time_create) VALUES (?, ?, ?)";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, checkIn.getUserId());
            pstmt.setInt(2, checkIn.getCoinCount());
            pstmt.setTimestamp(3, checkIn.getTimeCreate());
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new BaseException(500, "查询操作失败"+e.getMessage());
        }
    }

    @Override
    public boolean hasCheckedInToday(Integer userId) {
        // 使用更精确的时间比较，避免时区问题
        String sql = "SELECT COUNT(*) FROM checkin WHERE user_id = ? AND time_create >= CURDATE() AND time_create < DATE_ADD(CURDATE(), INTERVAL 1 DAY)";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new BaseException(500, "查询操作失败"+e.getMessage());
        }
        return false;
    }

    @Override
    public List<CheckIn> getUserCheckIns(Integer userId, int page, int pageSize) {
        String sql = "SELECT * FROM checkin WHERE user_id = ? ORDER BY time_create DESC LIMIT ? OFFSET ?";
        List<CheckIn> checkIns = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, pageSize);
            pstmt.setInt(3, (page - 1) * pageSize);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                CheckIn checkIn = new CheckIn();
                checkIn.setId(rs.getInt("id"));
                checkIn.setUserId(rs.getInt("user_id"));
                checkIn.setCoinCount(rs.getInt("coin_count"));
                checkIn.setTimeCreate(rs.getTimestamp("time_create"));
                checkIns.add(checkIn);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new BaseException(500, "查询操作失败"+e.getMessage());
        }
        return checkIns;
    }

    @Override
    public int getUserTotalCheckIns(Integer userId) {
        String sql = "SELECT COUNT(*) FROM checkin WHERE user_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new BaseException(500, "查询操作失败"+e.getMessage());
        }
        return 0;
    }

    @Override
    public CheckIn getUserTodayCheckIn(Integer userId) {
        String sql = "SELECT * FROM checkin WHERE user_id = ? AND time_create >= CURDATE() AND time_create < DATE_ADD(CURDATE(), INTERVAL 1 DAY) ORDER BY time_create DESC LIMIT 1";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                CheckIn checkIn = new CheckIn();
                checkIn.setId(rs.getInt("id"));
                checkIn.setUserId(rs.getInt("user_id"));
                checkIn.setCoinCount(rs.getInt("coin_count"));
                checkIn.setTimeCreate(rs.getTimestamp("time_create"));
                return checkIn;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new BaseException(500, "查询操作失败"+e.getMessage());
        }
        return null;
    }
}