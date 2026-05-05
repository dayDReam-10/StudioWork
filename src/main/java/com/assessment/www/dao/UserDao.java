package com.assessment.www.dao;

import com.assessment.www.po.User;

import java.util.List;

public interface UserDao {
    // 登录，注册，写签名，改头像，改性别，改密码，改签名，关注人，收藏，点赞，取消关注，取消收藏，取消点赞，看历史浏览，退出登录，发布视频，删除视频，查看收藏，
    // 投币，举报，评论，删评论
    int register(User user);

    User getUserByUsername(String username) throws Exception;

    // 找人
    User getUserById(int id) throws Exception;

    // 获取信息，查询关联信息
    int updateBasicInfo(User user) throws Exception;

    int updateAvatar(int id, String avatarUrl) throws Exception;

    int updatePassword(int id, String newPassword) throws Exception;

    int deleteUser(int id) throws Exception;// 管理员

    int banUser(int id) throws Exception;//管理员

    int unbanUser(int id) throws Exception;//管理员

    int follow(int myId, int targetId) throws Exception;

    int unfollow(int myId, int targetId) throws Exception;

    boolean isFollowing(int myId, int targetId) throws Exception;

    //是否关注
    List<Integer> getFollowingIds(int userId) throws Exception;

    //该用户关注了谁
    List<Integer> getFollowerIds(int userId) throws Exception;

    //粉丝
    int changeCoin(int id, int amount) throws Exception;//操作硬币

    int getCoinCount(int id) throws Exception;

    //分页查询
    List<User> getAllUsers(int offset, int limit) throws Exception;

    int countAllUsers() throws Exception;//计数

    int updateRole(int id, String role) throws Exception;

    int getNewUsersCountThisMonth() throws Exception;
}