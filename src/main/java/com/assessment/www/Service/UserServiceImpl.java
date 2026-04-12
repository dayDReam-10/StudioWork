package com.assessment.www.Service;

import com.assessment.www.dao.UserDao;
import com.assessment.www.dao.UserDaoImpl;
import com.assessment.www.po.User;

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
            return null;
        }
    }

    @Override
    public User getUserInfo(int id) throws Exception {
        try {
            return userDao.getUserById(id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public boolean updateProfile(User user) throws Exception {
        // 更新基本资料（性别、签名）
        try {
            return userDao.updateBasicInfo(user) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateAvatar(int id, String avatarUrl) throws Exception {
        try {
            return userDao.updateAvatar(id, avatarUrl) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
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
            return false;
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
            return false;
        }
    }

    @Override
    public boolean unfollowUser(int myId, int targetId) throws Exception {
        try {
            return userDao.unfollow(myId, targetId) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean isFollowing(int myId, int targetId) throws Exception {
        try {
            return userDao.isFollowing(myId, targetId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean modifyCoin(int id, int amount) throws Exception {
        try {
            return userDao.changeCoin(id, amount) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean banUser(int id) throws Exception {
        try {
            return userDao.banUser(id) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean unbanUser(int id) throws Exception {
        try {
            return userDao.unbanUser(id) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
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
            // 注意：实际应用中可能需要级联删除用户相关的数据（视频、评论、收藏等）
            return userDao.deleteUser(id) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
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
            return null;
        }
    }

    @Override
    public int getTotalUserCount() throws Exception {
        try {
            return userDao.countAllUsers();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public User getUserById(Integer id) throws Exception {
        try {
            return userDao.getUserById(id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public boolean updateUser(User user) throws Exception {
        try {
            return userDao.updateBasicInfo(user) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
