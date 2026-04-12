package com.assessment.www.Service;

import com.assessment.www.dao.CheckInDao;
import com.assessment.www.dao.CheckInDaoImpl;
import com.assessment.www.dao.UserDao;
import com.assessment.www.dao.UserDaoImpl;
import com.assessment.www.po.CheckIn;
import com.assessment.www.po.CheckInResult;
import com.assessment.www.po.User;
import com.assessment.www.constant.Constants;

import java.util.List;

//签到处理方法累
public class CheckInServiceImpl implements CheckInService {
    private CheckInDao checkInDao = new CheckInDaoImpl();
    private UserDao userDao = new UserDaoImpl();

    @Override
    public boolean checkIn(Integer userId) throws Exception {
        // 使用带结果的签到方法
        CheckInResult result = checkInWithResult(userId);
        return result.isSuccess();
    }

    @Override
    public boolean hasCheckedInToday(Integer userId) {
        return checkInDao.hasCheckedInToday(userId);
    }

    @Override
    public List<CheckIn> getUserCheckIns(Integer userId, int page, int pageSize) {
        return checkInDao.getUserCheckIns(userId, page, pageSize);
    }

    @Override
    public int getUserTotalCheckIns(Integer userId) {
        return checkInDao.getUserTotalCheckIns(userId);
    }

    @Override
    public CheckIn getUserTodayCheckIn(Integer userId) {
        return checkInDao.getUserTodayCheckIn(userId);
    }

    @Override
    public Integer getUserCoinCount(Integer userId) throws Exception {
        UserService userService = new UserServiceImpl();
        User user = userService.getUserById(userId);
        return user != null ? user.getCoinCount() : 0;
    }

    // 直接从数据库获取最新硬币数
    public int getLatestCoinCount(int userId) {
        String sql = "SELECT coin_count FROM users WHERE id = ?";
        try (java.sql.Connection conn = com.assessment.www.Util.utils.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            java.sql.ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("coin_count");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public CheckInResult checkInWithResult(Integer userId) throws Exception {
        // 首先检查今天是否已经签到
        if (hasCheckedInToday(userId)) {
            return new CheckInResult(false, "今天已经签到过了", null, null);
        }
        int coinReward = Constants.MINCOINMOUNT;
        CheckIn checkin = new CheckIn();
        boolean success = false;
        checkin.setUserId(userId);
        checkin.setCoinCount(coinReward);
        checkin.setTimeCreate(new java.sql.Timestamp(System.currentTimeMillis()));
        // 添加签到记录
        int addResult = checkInDao.addCheckIn(checkin);
        if (addResult <= 0) {
            return new CheckInResult(false, "签到失败，请重试", null, null);
        }
        // 更新用户硬币数
        int updateResult = userDao.changeCoin(userId, coinReward);
        success = updateResult > 0;
        if (success) {
            return new CheckInResult(true, "签到成功！", coinReward, checkin);
        } else {
            return new CheckInResult(false, "签到失败，请重试", null, null);
        }
    }
}