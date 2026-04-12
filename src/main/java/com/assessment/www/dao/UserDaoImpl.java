package com.assessment.www.dao;

import com.assessment.www.constant.Constants;
import com.assessment.www.po.User;
import com.assessment.www.Util.utils;

import java.sql.*;
import java.util.List;
import java.util.ArrayList;

public class UserDaoImpl implements UserDao {
    // 重复代码给我快写烂了，问了高手知道用twr和抽离封装
    private User initUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setAvatarUrl(rs.getString("avatar_url"));
        user.setGender(rs.getInt("gender"));
        user.setSignature(rs.getString("signature"));
        user.setCoinCount(rs.getInt("coin_count"));
        user.setFollowingCount(rs.getInt("following_count"));
        user.setFollowerCount(rs.getInt("follower_count"));
        user.setTotalLikeCount(rs.getInt("total_like_count"));
        user.setTotalFavCount(rs.getInt("total_fav_count"));
        user.setRole(rs.getString("role"));
        user.setStatus(rs.getInt("status"));
        return user;
    }

    @Override
    public int register(User user) {
        // 使用 try-with-resources 自动关连接
        String sql = "INSERT INTO users (username, password, avatar_url, gender, signature, coin_count, following_count, follower_count, total_like_count, total_fav_count, role, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getAvatarUrl() != null ? user.getAvatarUrl() : Constants.DEFAULT_AVATAR);
            pstmt.setInt(4, user.getGender() != null ? user.getGender() : Constants.GENDERSECRET);
            pstmt.setString(5, user.getSignature() != null ? user.getSignature() : Constants.DEFAULT_SIGNSTR);
            pstmt.setInt(6, user.getCoinCount() != null ? user.getCoinCount() : 0);
            pstmt.setInt(7, user.getFollowingCount() != null ? user.getFollowingCount() : 0);
            pstmt.setInt(8, user.getFollowerCount() != null ? user.getFollowerCount() : 0);
            pstmt.setInt(9, user.getTotalLikeCount() != null ? user.getTotalLikeCount() : 0);
            pstmt.setInt(10, user.getTotalFavCount() != null ? user.getTotalFavCount() : 0);
            pstmt.setString(11, user.getRole() != null ? user.getRole() : Constants.ROLEUSER);
            pstmt.setInt(12, user.getStatus() != null ? user.getStatus() : Constants.STATUSNORMAL);
            int result = pstmt.executeUpdate();
            if (result > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    user.setId(rs.getInt(1));
                }
            }
            return result;
        } catch (SQLException e) {
            System.out.print("用户注册失败");
            return 0;
        }
    }

    @Override
    public User getUserByUsername(String username) {
        // 主要是登录的时候要用这个方法，其他时候基本上都是id，所以这个方法单独写了个sql
        String sql = "SELECT * FROM users WHERE username = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return initUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public User getUserById(int id) {
        // 关联查询
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return initUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public int updateBasicInfo(User user) {
        String sql = "UPDATE users SET gender = ?, signature = ? WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, user.getGender());
            ps.setString(2, user.getSignature());
            ps.setInt(3, user.getId());
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int updateAvatar(int id, String avatarUrl) {
        // 上传头像
        String sql = "UPDATE users SET avatar_url = ? WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, avatarUrl);
            ps.setInt(2, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int updatePassword(int id, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setInt(2, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 这里没用twr，是以为我这个语法糖刚学
    // 问了问某位神秘高手，是有个什么原因说是事务用twr不好理解，我也没听懂，就用手动了
    @Override
    public int follow(int myId, int targetId) {
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        PreparedStatement ps3 = null;
        try {
            conn = utils.getConnection();
            conn.setAutoCommit(false);
            ps1 = conn.prepareStatement("INSERT IGNORE INTO user_follows (user_id, follower_id) VALUES (?, ?)");//存在即忽略
            ps1.setInt(1, targetId);
            ps1.setInt(2, myId);
            ps1.executeUpdate();
            ps2 = conn.prepareStatement("UPDATE users SET following_count = following_count + 1 WHERE id = ?");
            ps2.setInt(1, myId);
            ps2.executeUpdate();
            ps3 = conn.prepareStatement("UPDATE users SET follower_count = follower_count + 1 WHERE id = ?");
            ps3.setInt(1, targetId);
            ps3.executeUpdate();
            conn.commit();
            return 1;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            } //双catch防回滚问题
            e.printStackTrace();
            return 0;
        } finally {//后开先关
            if (ps3 != null) {
                try {
                    ps3.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (ps2 != null) {
                try {
                    ps2.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (ps1 != null) {
                try {
                    ps1.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @Override
    public int unfollow(int myId, int targetId) {
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        PreparedStatement ps3 = null;
        try {
            conn = utils.getConnection();
            conn.setAutoCommit(false);
            ps1 = conn.prepareStatement("DELETE FROM user_follows WHERE user_id = ? AND follower_id = ?");
            ps1.setInt(1, targetId);
            ps1.setInt(2, myId);
            ps1.executeUpdate();
            ps2 = conn.prepareStatement("UPDATE users SET following_count = following_count - 1 WHERE id = ? AND following_count > 0");
            ps2.setInt(1, myId);
            ps2.executeUpdate();
            ps3 = conn.prepareStatement("UPDATE users SET follower_count = follower_count - 1 WHERE id = ? AND follower_count > 0");
            ps3.setInt(1, targetId);
            ps3.executeUpdate();
            conn.commit();
            return 1;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return 0;
        } finally {
            if (ps3 != null) {
                try {
                    ps3.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (ps2 != null) {
                try {
                    ps2.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (ps1 != null) {
                try {
                    ps1.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @Override
    public int changeCoin(int id, int amount) throws Exception {//service处理
        String sql = "UPDATE users SET coin_count = coin_count + ? WHERE id = ? AND (coin_count + ?) >= 0";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, amount);
            ps.setInt(2, id);
            ps.setInt(3, amount);
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw e;
        }
    }

    @Override
    public int banUser(int id) {
        String sql = "UPDATE users SET status = 0 WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0; 
    }

    @Override
    public int unbanUser(int id) {
        String sql = "UPDATE users SET status = 1 WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public boolean isFollowing(int myId, int targetId) {
        // 查询是否关注了targ
        String sql = "SELECT 1 FROM user_follows WHERE user_id = ? AND follower_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, targetId);
            ps.setInt(2, myId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public List<Integer> getFollowingIds(int userId) {
        // 查询粉丝和关注列表
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT user_id FROM user_follows WHERE follower_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("user_id"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ids;
    }

    @Override
    public List<Integer> getFollowerIds(int userId) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT follower_id FROM user_follows WHERE user_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("follower_id"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ids;
    }

    @Override
    public int getCoinCount(int id) {
        String sql = "SELECT coin_count FROM users WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("coin_count");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public List<User> getAllUsers(int offset, int limit) {
        // 分页查询
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY id LIMIT ?, ?";// start_point & how many
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(initUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int countAllUsers() {
        // 就是求个总人数，给上面分页用
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int updateRole(int id, String role) {
        // service检查，4.7做
        String sql = "UPDATE users SET role = ? WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
