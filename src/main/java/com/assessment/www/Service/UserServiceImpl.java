package com.assessment.www.Service;

import com.assessment.www.dao.UserDao;
import com.assessment.www.dao.UserDaoImpl;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.User;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

public class UserServiceImpl implements UserService {
    private final UserDao userDao = new UserDaoImpl();

    @Override
    public boolean register(User user) throws Exception {
        // 第一步：业务校验：用户名是否已存在？
        try {
            // 检查用户名是否已存在
            User existingUser = userDao.getUserByUsername(user.getUsername());
            if (existingUser != null) {
                return false;
            }
            // 设置默认值
            if (user.getRole() == null) {
                user.setRole("user");
            }
            if (user.getStatus() == null) {
                user.setStatus(1);
            }
            if (user.getGender() == null) {
                user.setGender(0);
            }
            if (user.getSignature() == null) {
                user.setSignature("这个人很懒，什么都没有留下");
            }
            if (user.getCoinCount() == null) {
                user.setCoinCount(0);
            }
            if (user.getFollowingCount() == null) {
                user.setFollowingCount(0);
            }
            if (user.getFollowerCount() == null) {
                user.setFollowerCount(0);
            }
            if (user.getTotalLikeCount() == null) {
                user.setTotalLikeCount(0);
            }
            if (user.getTotalFavCount() == null) {
                user.setTotalFavCount(0);
            }
            int result = userDao.register(user);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public User login(String username, String password) throws Exception {
        // 第一步：根据用户名查人
        User user = userDao.getUserByUsername(username);
        // 第二步：业务判定：账户是否存在、密码是否吻合、是否被封禁
        try {
            if (user == null) {
                // 用户不存在
                return null;
            }
            if (!user.getPassword().equals(password)) {
                // 密码错误
                return null;
            }
            if (user.getStatus() != 1) {
                // 用户被封禁，返回用户对象以便显示封禁信息
                return user;
            }
            // 登录成功
            return user;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "登陆失败" + e.getMessage());
        }
    }

    @Override
    public User getUserInfo(int id) throws Exception {
        try {
            return userDao.getUserById(id);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "获取失败" + e.getMessage());
        }
    }

    @Override
    public boolean updateProfile(User user) throws Exception {
        // 更新基本资料（性别、签名）
        try {
            return userDao.updateBasicInfo(user) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "更新失败" + e.getMessage());
        }
    }

    @Override
    public boolean updateAvatar(int id, String avatarUrl) throws Exception {
        try {
            return userDao.updateAvatar(id, avatarUrl) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public boolean changePassword(int id, String oldPassword, String newPassword) throws Exception {
        // 第一步：先验证旧密码是否正确（Service层的严谨性）
        try {
            // 验证旧密码
            User user = userDao.getUserById(id);
            if (user == null || !user.getPassword().equals(oldPassword)) {
                return false;
            }
            return userDao.updatePassword(id, newPassword) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public boolean followUser(int myId, int targetId) throws Exception {
        // 业务约束：不能关注自己
        try {
            // 检查是否已经关注
            if (userDao.isFollowing(myId, targetId)) {
                return false;
            }
            return userDao.follow(myId, targetId) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "关注失败" + e.getMessage());
        }
    }

    @Override
    public boolean unfollowUser(int myId, int targetId) throws Exception {
        try {
            return userDao.unfollow(myId, targetId) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public boolean isFollowing(int myId, int targetId) throws Exception {
        try {
            return userDao.isFollowing(myId, targetId);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public List<User> getFollowingUsers(int userId) throws Exception {
        try {
            List<Integer> followingIds = userDao.getFollowingIds(userId);
            List<User> users = new ArrayList<>();
            for (Integer followingId : followingIds) {
                User followingUser = userDao.getUserById(followingId);
                if (followingUser != null) {
                    users.add(followingUser);
                }
            }
            return users;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "获取关注列表失败" + e.getMessage());
        }
    }

    @Override
    public List<User> getFollowerUsers(int userId) throws Exception {
        try {
            List<Integer> followerIds = userDao.getFollowerIds(userId);
            List<User> users = new ArrayList<>();
            for (Integer followerId : followerIds) {
                User followerUser = userDao.getUserById(followerId);
                if (followerUser != null) {
                    users.add(followerUser);
                }
            }
            return users;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "获取粉丝列表失败" + e.getMessage());
        }
    }

    @Override
    public boolean modifyCoin(int id, int amount) throws Exception {
        try {
            return userDao.changeCoin(id, amount) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public boolean banUser(int id) throws Exception {
        try {
            return userDao.banUser(id) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public boolean unbanUser(int id) throws Exception {
        try {
            return userDao.unbanUser(id) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public boolean deleteUser(int id) throws Exception {
        try {
            // 先查询用户是否存在
            User user = userDao.getUserById(id);
            if (user == null) {
                return false;
            }
            // 管理员可以删除任何用户
            return userDao.deleteUser(id) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public List<User> getUserList(int page, int pageSize) throws Exception {
        // 分页计算：页码转为偏移量
        try {
            int offset = (page - 1) * pageSize;
            return userDao.getAllUsers(offset, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public int getTotalUserCount() throws Exception {
        try {
            return userDao.countAllUsers();
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public User getUserById(Integer id) throws Exception {
        try {
            return userDao.getUserById(id);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "修改失败" + e.getMessage());
        }
    }

    @Override
    public User validateCachedLogin(String username, String encryptedPassword) throws Exception {
        try {
            if (encryptedPassword != null && encryptedPassword.contains("|")) {
                String[] parts = encryptedPassword.split("\\|", 2);
                if (parts.length == 2) {
                    String storedUsername = parts[0];
                    String base64Password = parts[1];
                    // 验证用户名是否匹配
                    if (!username.equals(storedUsername)) {
                        return null;
                    }
                    String decryptedPassword = new String(java.util.Base64.getDecoder().decode(base64Password));
                    // 从数据库获取用户
                    User user = userDao.getUserByUsername(username);
                    if (user != null && user.getStatus() == com.assessment.www.constant.Constants.STATUSNORMAL && user.getPassword().equals(decryptedPassword)) {
                        return user;
                    }
                }
            }
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "验证失败" + e.getMessage());
        }
    }

    @Override
    public User validateAdminCachedLogin(String username, String encryptedPassword) throws Exception {
        // 如果用户名为空或加密密码为空，直接返回null
        if (username == null || username.trim().isEmpty() ||
                encryptedPassword == null || encryptedPassword.trim().isEmpty()) {
            return null;
        }
        // 使用UserService验证缓存的登录信息
        User user = this.validateCachedLogin(username, encryptedPassword);
        // 只返回管理员用户
        if (user != null && "admin".equals(user.getRole()) && user.getStatus() == 1) {
            return user;
        }
        return null;
    }

    @Override
    public String generateEncryptedPassword(String username, String password) {
        String encodedPassword = Base64.getEncoder().encodeToString(password.getBytes());
        return username + "|" + encodedPassword;
    }

    @Override
    public boolean updateUser(User user) throws Exception {
        try {
            return userDao.updateBasicInfo(user) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public int getNewUsersCountThisMonth() throws Exception {
        try {
            return userDao.getNewUsersCountThisMonth();
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }
}
