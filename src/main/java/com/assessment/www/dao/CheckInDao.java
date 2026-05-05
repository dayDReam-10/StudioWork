package com.assessment.www.dao;

import com.assessment.www.po.CheckIn;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

// 签到数据访问接口
public interface CheckInDao {
    // 添加签到记录
    int addCheckIn(CheckIn checkIn);

    // 检查用户今天是否已签到
    boolean hasCheckedInToday(Integer userId);

    // 获取用户签到记录
    List<CheckIn> getUserCheckIns(Integer userId, int page, int pageSize);

    // 获取用户总签到次数
    int getUserTotalCheckIns(Integer userId);

    // 获取用户今日签到记录
    CheckIn getUserTodayCheckIn(Integer userId);
}