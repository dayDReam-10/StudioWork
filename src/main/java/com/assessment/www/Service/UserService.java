package com.assessment.www.Service;

import com.assessment.www.po.User;

import java.util.List;

public interface UserService {
    // 注册：包含用户名重复检查逻辑
    boolean register(User user) throws Exception;

    // 登录：验证用户名密码，并检查是否被封禁
    User login(String username, String password) throws Exception;

    // 获取用户信息
    User getUserInfo(int id) throws Exception;

    // 修改基本资料（性别、签名）
    boolean updateProfile(User user) throws Exception;

    // 修改头像
    boolean updateAvatar(int id, String avatarUrl) throws Exception;

    // 修改密码（需要旧密码验证逻辑一般在Servlet或Service处理）
    boolean changePassword(int id, String oldPassword, String newPassword) throws Exception;

    // 关注/取关业务
    boolean followUser(int myId, int targetId) throws Exception;

    boolean unfollowUser(int myId, int targetId) throws Exception;

    boolean isFollowing(int myId, int targetId) throws Exception;

    // 资产操作：充值或消费硬币
    boolean modifyCoin(int id, int amount) throws Exception;

    // 管理员：封禁/解封
    boolean banUser(int id) throws Exception;

    boolean unbanUser(int id) throws Exception;

    // 管理员：永久删除用户
    boolean deleteUser(int id) throws Exception;

    // 管理员：获取用户列表（分页）
    List<User> getUserList(int page, int pageSize) throws Exception;

    // 根据ID获取用户
    User getUserById(Integer id) throws Exception;

    // 更新用户信息
    boolean updateUser(User user) throws Exception;

    int getTotalUserCount() throws Exception;
}
