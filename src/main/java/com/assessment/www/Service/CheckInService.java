package com.assessment.www.Service;

import com.assessment.www.po.CheckIn;
import com.assessment.www.po.CheckInResult;

import java.util.List;

// 签到处理
public interface CheckInService {
    // 用户签到的处理信息
    boolean checkIn(Integer userId) throws Exception;

    //  用于获取用户今天是否已签到
    boolean hasCheckedInToday(Integer userId);

    // 用于获取用户签到记录
    List<CheckIn> getUserCheckIns(Integer userId, int page, int pageSize);

    //  用于获取用户总签到次数
    int getUserTotalCheckIns(Integer userId);

    CheckIn getUserTodayCheckIn(Integer userId);

    Integer getUserCoinCount(Integer userId) throws Exception;

    CheckInResult checkInWithResult(Integer userId) throws Exception;
}