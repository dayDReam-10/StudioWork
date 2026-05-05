package com.assessment.www.dao;

import com.assessment.www.constant.Constants;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ScreenComment;
import com.assessment.www.po.User;
import com.assessment.www.po.Video;
import com.assessment.www.Util.utils;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VideoDaoImpl implements VideoDao {
    @Override
    public int addVideo(Video video) {
        String sql = "INSERT INTO videos (title, video_url, cover_url, author_id, description, view_count, status, like_count, coin_count, fav_count, screen_comment_count, visibility, time_create) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, video.getTitle());
            pstmt.setString(2, video.getVideoUrl());
            pstmt.setString(3, video.getCoverUrl() != null ? video.getCoverUrl() : Constants.DEFAULT_COVER);
            pstmt.setInt(4, video.getAuthorId());
            pstmt.setString(5, video.getDescription());
            pstmt.setInt(6, video.getViewCount() != null ? video.getViewCount() : 0);
            pstmt.setInt(7, video.getStatus() != null ? video.getStatus() : Constants.VIDEOSTATUSPEN);
            pstmt.setInt(8, video.getLikeCount() != null ? video.getLikeCount() : 0);
            pstmt.setInt(9, video.getCoinCount() != null ? video.getCoinCount() : 0);
            pstmt.setInt(10, video.getFavCount() != null ? video.getFavCount() : 0);
            pstmt.setInt(11, video.getScreenCommentCount() != null ? video.getScreenCommentCount() : 0);
            pstmt.setString(12, video.getVisibility() != null ? video.getVisibility() : "public");
            pstmt.setTimestamp(13, video.getTimeCreate());
            int result = pstmt.executeUpdate();
            if (result > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    video.setId(rs.getInt(1));
                }
            }
            return result;
        } catch (SQLException e) {
            System.out.print("发布视频失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
    }

    @Override
    public int deleteVideo(int id) {
        // 物理删除，真正从数据库里删掉。因为咱们表里配置了级联删除（ON DELETE CASCADE），只要这里真删了，属于它的弹幕、点赞、收藏、历史浏览记录就全被数据库自动清理得一干二净了！
        String sql = "DELETE FROM videos WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
    }

    @Override
    public int updateVideoBaseInfo(int id, String title, String coverUrl, String description) {
        // 修改视频基本信息（标题、封面、简介）
        String sql = "UPDATE videos SET title = ?, cover_url = ?, description = ? WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, coverUrl);
            ps.setString(3, description);
            ps.setInt(4, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
    }

    @Override
    public Video getVideoById(int id) {
        // 视频详情页得用，点进去看视频就查这个
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE v.id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractVideoFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.out.print("根据ID查询视频失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return null;
    }

    @Override
    public List<Video> getVideosByAuthorId(int authorId,User user) {
        // 个人主页投稿那块，把某位UP主发的视频全拉出来，不看删了的
        String visibilityCondition = "";
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE v.author_id = ? ";
        boolean isOwnerOrAdmin = user != null && (user.getId() == authorId || user.getId() == 1);
        if (!isOwnerOrAdmin) {
            sql += " and v.status = 1 ";
        }
        if (user != null) {
            visibilityCondition = buildVisibilityConditionForAuthor(authorId, user.getId());
            sql += " and " + visibilityCondition;
        } else {
            visibilityCondition = buildVisibilityConditionForAuthor(authorId, 0);
            sql += " and " + visibilityCondition;
        }
        sql+=" ORDER BY v.time_create DESC ";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, authorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(extractVideoFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("根据作者ID查询视频失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return videos;
    }

    @Override
    public List<Video> getApprovedVisibleVideos(User user) throws Exception {
        String visibilityCondition = "";
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE v.status = 1 ";
        if (user != null) {
            visibilityCondition = buildVisibilityCondition(user.getId());
            sql += "and " + visibilityCondition;
        } else {
            visibilityCondition = buildVisibilityCondition(0);
            sql += "and " + visibilityCondition;
        }
        sql += " ORDER BY v.time_create DESC ";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(extractVideoFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("获取已审核可见视频失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return videos;
    }

    @Override
    public List<Video> getAllVideos(User user) {  // 获取所有视频，包括待审核和已审核的
        String visibilityCondition = "";
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE 1=1  ";
        if (user != null) {
            visibilityCondition = buildVisibilityCondition(user.getId());
            sql += " and " + visibilityCondition;
        } else {
            visibilityCondition = buildVisibilityCondition(0);
            sql += " and " + visibilityCondition;
        }
        sql += " ORDER BY v.time_create DESC ";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(extractVideoFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("获取所有视频失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return videos;
    }

    @Override
    public List<Video> getAllVideosIncludingPending() throws Exception {
        // 获取所有视频，包括所有状态（待审核、已通过、已驳回）
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "ORDER BY v.time_create DESC";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(extractVideoFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("获取所有视频（包括待审核）失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return videos;
    }

    @Override
    public List<Video> searchByKeyword(String keyword, User user) throws Exception {
        return searchByKeyword(keyword, user != null ? user.getId() : 0); // 默认用户ID为0（未登录）
    }

    //根据关键词搜索视频，支持可见范围过滤
    public List<Video> searchByKeyword(String keyword, int currentUserId) throws Exception {
        // 根据视频可见范围构建查询条件
        String visibilityCondition = buildVisibilityCondition(currentUserId);
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE v.status = 1 AND " + visibilityCondition + " AND (v.title LIKE ? OR v.description LIKE ?) " +
                "ORDER BY v.time_create DESC";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String searchTerm = "%" + keyword + "%";
            pstmt.setString(1, searchTerm);
            pstmt.setString(2, searchTerm);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(extractVideoFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("根据关键词搜索视频失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return videos;
    }

    //构建视频可见范围的查询条件 当前用户ID，0表示未登录
    private String buildVisibilityCondition(int currentUserId) {
        if (currentUserId == 0) {  // 未登录用户只能看到公开视频
            return "v.visibility = 'public'";
        }
        // 检查是否是管理员
        boolean isAdmin = (currentUserId == 1);
        if (isAdmin) {  // 管理员可以看所有视频
            return "(v.visibility = 'public' OR v.visibility = 'private' OR v.visibility = 'followers' OR v.visibility = 'mutual_follow')";
        }
        // 普通用户使用用户可见条件
        return buildUserVisibilityCondition(currentUserId);
    }

    //为已登录用户构建可见条件 主要是(私密，粉丝可见，互关可见，公开等)范围
    private String buildUserVisibilityCondition(int currentUserId) {
        StringBuilder condition = new StringBuilder();
        condition.append("(v.visibility = 'public'");
        // 添加私密视频条件（只能看到自己的私密视频）
        condition.append(" OR (v.visibility = 'private' AND v.author_id = ").append(currentUserId).append(")");
        // 添加粉丝可见视频条件
        condition.append(" OR (v.visibility = 'followers' AND EXISTS (");
        condition.append("    SELECT 1 FROM user_follows uf ");
        condition.append("    WHERE uf.user_id = v.author_id AND uf.follower_id = ").append(currentUserId);
        condition.append("))");
        // 添加互相关注可见视频条件
        condition.append(" OR (v.visibility = 'mutual_follow' AND EXISTS (");
        condition.append("    SELECT 1 FROM user_follows uf1 ");
        condition.append("    WHERE uf1.user_id = v.author_id AND uf1.follower_id = ").append(currentUserId);
        condition.append(") AND EXISTS (");
        condition.append("    SELECT 1 FROM user_follows uf2 ");
        condition.append("    WHERE uf2.user_id = ").append(currentUserId);
        condition.append("    AND uf2.follower_id = v.author_id");
        condition.append("))");
        condition.append(")");
        return condition.toString();
    }

    private String buildVisibilityConditionForAuthor(int authorId, int currentUserId) {
        if (currentUserId == 1) {
            return "1=1";
        }
        // 未登录用户只能看到公开视频
        if (currentUserId == 0) {
            return "v.visibility = 'public'";
        }
        // 当前用户即为作者本人可以看到自己所有的视频（包括私密、粉丝可见等）
        if (currentUserId == authorId) {
            return "1=1";
        }
        // 普通用户查看他人主页只能看到符合可见性规则的视频
        StringBuilder condition = new StringBuilder();
        condition.append("(");
        condition.append("v.visibility = 'public'");
        // 粉丝可见当前用户关注了作者
        condition.append(" OR (v.visibility = 'followers' AND EXISTS (");
        condition.append("    SELECT 1 FROM user_follows uf ");
        condition.append("    WHERE uf.user_id = v.author_id AND uf.follower_id = ").append(currentUserId);
        condition.append("))");
        // 互关可见当前用户与作者互相关注
        condition.append(" OR (v.visibility = 'mutual_follow' AND EXISTS (");
        condition.append("    SELECT 1 FROM user_follows uf1 ");
        condition.append("    WHERE uf1.user_id = v.author_id AND uf1.follower_id = ").append(currentUserId);
        condition.append(") AND EXISTS (");
        condition.append("    SELECT 1 FROM user_follows uf2 ");
        condition.append("    WHERE uf2.user_id = ").append(currentUserId);
        condition.append("    AND uf2.follower_id = v.author_id");
        condition.append("))");
        condition.append(")");
        return condition.toString();
    }

    @Override
    public int updateVideoStatus(int id, int status) {
        // 改视频状态，比如审过了或者违规下架啥的
        String sql = "UPDATE videos SET status = ? WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
    }

    @Override
    public int updateVideoCounts(int id, String type, int count) {
        String sql;
        switch (type) {
            case "view":
                sql = "UPDATE videos SET view_count = view_count + ? WHERE id = ?";
                break;
            case "like":
                sql = "UPDATE videos SET like_count = like_count + ? WHERE id = ?";
                break;
            case "coin":
                sql = "UPDATE videos SET coin_count = coin_count + ? WHERE id = ?";
                break;
            case "fav":
                sql = "UPDATE videos SET fav_count = fav_count + ? WHERE id = ?";
                break;
            case "comment":
                sql = "UPDATE videos SET screen_comment_count = screen_comment_count + ? WHERE id = ?";
                break;
            default:
                throw new IllegalArgumentException("类型错误: " + type);
        }
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, count);
            pstmt.setInt(2, id);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.print("更新视频数量统计失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
    }

    @Override
    public int increaseViewCount(Integer id) throws Exception {
        String sql = "UPDATE videos SET view_count = view_count + 1 WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.print("增加播放量失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
    }

    @Override
    public int addCoin(int userId, int videoId, int amount) {
        // 投币，给UP主排面。先往明细表里塞记录（遇到重复投币就加数量），再更新视频主表的硬币数。
        if (amount <= 0) {
            return 0;
        }
        // 投币记录
        String sql1 = "INSERT INTO video_coins (user_id, video_id, amount) VALUES (?, ?, ?)";
        // 更新视频投币数
        String sql2 = "UPDATE videos SET coin_count = coin_count + ? WHERE id = ?";
        // 更新用户硬币数，避免扣成负数
        String sql3 = "UPDATE users SET coin_count = coin_count - ? WHERE id = ? AND coin_count >= ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt1 = conn.prepareStatement(sql1);
             PreparedStatement pstmt2 = conn.prepareStatement(sql2);
             PreparedStatement pstmt3 = conn.prepareStatement(sql3)) {
            conn.setAutoCommit(false);
            try {
                // 投币记录
                pstmt1.setInt(1, userId);
                pstmt1.setInt(2, videoId);
                pstmt1.setInt(3, amount);
                if (pstmt1.executeUpdate() <= 0) {
                    conn.rollback();
                    return 0;
                }
                // 更新视频投币数
                pstmt2.setInt(1, amount);
                pstmt2.setInt(2, videoId);
                if (pstmt2.executeUpdate() <= 0) {
                    conn.rollback();
                    return 0;
                }
                // 更新用户硬币数
                pstmt3.setInt(1, amount);
                pstmt3.setInt(2, userId);
                pstmt3.setInt(3, amount);
                if (pstmt3.executeUpdate() <= 0) {
                    conn.rollback();
                    return 0;
                }
                conn.commit();
                return 1;
            } catch (SQLException e) {
                conn.rollback();
                System.out.print("投币失败");
                throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int sendComment(int videoId, int userId, String text, float time, Integer parentId) throws Exception {
        // 发弹幕，不仅要塞进弹幕表，还得去主表把弹幕数+1，开了事务稳一点
        String insertSql = "INSERT INTO screen_comment (video_id, user_id, content, photo, video_time,time_create, parent_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String updateSql = "UPDATE videos SET screen_comment_count = screen_comment_count + ? WHERE id = ?";
        try (Connection conn = utils.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                ps.setInt(1, videoId);
                ps.setInt(2, userId);
                ps.setString(3, text);
                ps.setString(4, null);
                ps.setFloat(5, time);
                ps.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
                ps.setObject(7, parentId);
                int row = ps.executeUpdate();
                if (row > 0) {
                    updatePs.setInt(1, 1);
                    updatePs.setInt(2, videoId);
                    if (updatePs.executeUpdate() <= 0) {
                        conn.rollback();
                        return 0;
                    }
                    conn.commit();
                    return row;
                }
                conn.rollback();
                return 0;
            } catch (SQLException e) {
                conn.rollback();
                throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
            }
        }
    }

    // 带照片的评论方法
    public int sendCommentWithPhoto(int videoId, int userId, String text, String photoBase64, float time, Integer parentId) throws Exception {
        String insertSql = "INSERT INTO screen_comment (video_id, user_id, content, photo, video_time,time_create, parent_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String updateSql = "UPDATE videos SET screen_comment_count = screen_comment_count + ? WHERE id = ?";
        try (Connection conn = utils.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                ps.setInt(1, videoId);
                ps.setInt(2, userId);
                ps.setString(3, text);
                ps.setString(4, photoBase64);
                ps.setFloat(5, time);
                ps.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
                ps.setObject(7, parentId);
                int row = ps.executeUpdate();
                if (row > 0) {
                    updatePs.setInt(1, 1);
                    updatePs.setInt(2, videoId);
                    if (updatePs.executeUpdate() <= 0) {
                        conn.rollback();
                        return 0;
                    }
                    conn.commit();
                    return row;
                }
                conn.rollback();
                return 0;
            } catch (SQLException e) {
                conn.rollback();
                throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
            }
        }
    }

    @Override
    public ScreenComment getCommentById(int commentId) throws Exception {
        String sql = "SELECT sc.*, u.username as comment_user, v.title as video_title, v.author_id as video_author_id " +
                "FROM screen_comment sc " +
                "LEFT JOIN users u ON sc.user_id = u.id " +
                "LEFT JOIN videos v ON sc.video_id = v.id " +
                "WHERE sc.id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, commentId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractCommentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            System.out.print("获取评论详情失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return null;
    }

    @Override
    public int deleteComment(int commentId) throws Exception {
        // 删弹幕，这功能得有，不然乱发的没法管
        String sql1 = "SELECT video_id FROM screen_comment WHERE id = ?";
        String sql2 = "DELETE FROM screen_comment WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt1 = conn.prepareStatement(sql1);
             PreparedStatement pstmt2 = conn.prepareStatement(sql2)) {
            // 获取视频ID
            pstmt1.setInt(1, commentId);
            ResultSet rs = pstmt1.executeQuery();
            if (rs.next()) {
                int videoId = rs.getInt("video_id");
                // 删除评论
                pstmt2.setInt(1, commentId);
                int result = pstmt2.executeUpdate();
                // 更新弹幕数
                if (result > 0) {
                    updateVideoCounts(videoId, "comment", -1);
                }
                return result;
            }
            return 0;
        } catch (SQLException e) {
            System.out.print("删除评论失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
    }

    @Override
    public List<ScreenComment> getCommentsByVideoId(int videoId) {
        // 下弹幕包，播视频的时候得按时间顺序把弹幕一个个吐出来
        String sql = "SELECT sc.*, u.username as comment_user, v.author_id as video_author_id, v.title as video_title " +
                "FROM screen_comment sc " +
                "LEFT JOIN users u ON sc.user_id = u.id " +
                "LEFT JOIN videos v ON sc.video_id = v.id " +
                "WHERE sc.video_id = ? ORDER BY sc.video_time ASC";
        List<ScreenComment> comments = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, videoId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    comments.add(extractCommentFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.print("获取评论失败");
        }
        return comments;
    }

    @Override
    public int saveHistory(int userId, int videoId) {
        // 记录一下看过了，以后想翻看过的视频就查这个（已加 ON DUPLICATE KEY UPDATE 防止重复看报错，顺便更新浏览时间）
        String sql = "INSERT INTO history (user_id, video_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE time_view = CURRENT_TIMESTAMP";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, videoId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.print("保存历史记录失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
    }

    @Override
    public int updateLike(int userId, int videoId, int status) throws SQLException {
        // 点赞或取消，中间表改了还得去主表更计数，挺麻烦的也得开事务
        // status: 1 点赞, 0 取消点赞
        if (status == 1) {
            // 点赞
            String sql1 = "INSERT INTO likes (user_id, video_id) VALUES (?, ?)";
            String sql2 = "UPDATE videos SET like_count = like_count + 1 WHERE id = ?";
            String sql3 = "UPDATE users SET total_like_count = total_like_count + 1 WHERE id = ?";
            try (Connection conn = utils.getConnection();
                 PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                 PreparedStatement pstmt2 = conn.prepareStatement(sql2);
                 PreparedStatement pstmt3 = conn.prepareStatement(sql3)) {
                conn.setAutoCommit(false);
                try {
                    pstmt1.setInt(1, userId);
                    pstmt1.setInt(2, videoId);
                    pstmt1.executeUpdate();
                    pstmt2.setInt(1, videoId);
                    pstmt2.executeUpdate();
                    pstmt3.setInt(1, userId);
                    pstmt3.executeUpdate();
                    conn.commit();
                    return 1;
                } catch (SQLException e) {
                    conn.rollback();
                    throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
                } finally {
                    conn.setAutoCommit(true);
                }
            }
        } else {
            // 取消点赞
            String sql1 = "DELETE FROM likes WHERE user_id = ? AND video_id = ?";
            String sql2 = "UPDATE videos SET like_count = like_count - 1 WHERE id = ?";
            String sql3 = "UPDATE users SET total_like_count = total_like_count - 1 WHERE id = ?";
            try (Connection conn = utils.getConnection();
                 PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                 PreparedStatement pstmt2 = conn.prepareStatement(sql2);
                 PreparedStatement pstmt3 = conn.prepareStatement(sql3)) {
                conn.setAutoCommit(false);
                try {
                    pstmt1.setInt(1, userId);
                    pstmt1.setInt(2, videoId);
                    pstmt1.executeUpdate();
                    pstmt2.setInt(1, videoId);
                    pstmt2.executeUpdate();
                    pstmt3.setInt(1, userId);
                    pstmt3.executeUpdate();
                    conn.commit();
                    return 1;
                } catch (SQLException e) {
                    conn.rollback();
                    throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
                } finally {
                    conn.setAutoCommit(true);
                }
            }
        }
    }

    @Override
    public int updateFav(int userId, int videoId, int status) throws SQLException {
        // 收藏或取消，跟点赞逻辑差不多， status=1是收藏，0是取消
        if (status == 1) {
            // 收藏
            String sql1 = "INSERT INTO favorites (user_id, video_id) VALUES (?, ?)";
            String sql2 = "UPDATE videos SET fav_count = fav_count + 1 WHERE id = ?";
            String sql3 = "UPDATE users SET total_fav_count = total_fav_count + 1 WHERE id = ?";
            try (Connection conn = utils.getConnection();
                 PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                 PreparedStatement pstmt2 = conn.prepareStatement(sql2);
                 PreparedStatement pstmt3 = conn.prepareStatement(sql3)) {
                conn.setAutoCommit(false);
                try {
                    pstmt1.setInt(1, userId);
                    pstmt1.setInt(2, videoId);
                    pstmt1.executeUpdate();
                    pstmt2.setInt(1, videoId);
                    pstmt2.executeUpdate();
                    pstmt3.setInt(1, userId);
                    pstmt3.executeUpdate();
                    conn.commit();
                    return 1;
                } catch (SQLException e) {
                    conn.rollback();
                    throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
                } finally {
                    conn.setAutoCommit(true);
                }
            }
        } else {
            // 取消收藏
            String sql1 = "DELETE FROM favorites WHERE user_id = ? AND video_id = ?";
            String sql2 = "UPDATE videos SET fav_count = fav_count - 1 WHERE id = ?";
            String sql3 = "UPDATE users SET total_fav_count = total_fav_count - 1 WHERE id = ?";
            try (Connection conn = utils.getConnection();
                 PreparedStatement pstmt1 = conn.prepareStatement(sql1);
                 PreparedStatement pstmt2 = conn.prepareStatement(sql2);
                 PreparedStatement pstmt3 = conn.prepareStatement(sql3)) {
                conn.setAutoCommit(false);
                try {
                    pstmt1.setInt(1, userId);
                    pstmt1.setInt(2, videoId);
                    pstmt1.executeUpdate();
                    pstmt2.setInt(1, videoId);
                    pstmt2.executeUpdate();
                    pstmt3.setInt(1, userId);
                    pstmt3.executeUpdate();
                    conn.commit();
                    return 1;
                } catch (SQLException e) {
                    conn.rollback();
                    throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
                } finally {
                    conn.setAutoCommit(true);
                }
            }
        }
    }

    @Override
    public boolean isLiked(int userId, int videoId) {
        // 进页面得查一下用户点过赞没，点过了前端图标得亮
        String sql = "SELECT COUNT(*) FROM likes WHERE user_id = ? AND video_id = ?";
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
            System.out.print("检查点赞状态失败");
        }
        return false;
    }

    @Override
    public boolean isFaved(int userId, int videoId) {
        // 查查收藏没，逻辑跟点赞一样，亮不亮星星就看这个
        String sql = "SELECT COUNT(*) FROM favorites WHERE user_id = ? AND video_id = ?";
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
            System.out.print("检查收藏状态失败");
        }
        return false;
    }

    private Video initVideo(ResultSet rs) throws SQLException {
        // 抽出来的封装，把结果集里那些乱七八糟的字段全塞进Video对象里，省得每次都写一遍
        Video video = new Video();
        video.setId(rs.getInt("id"));
        video.setTitle(rs.getString("title"));
        video.setVideoUrl(rs.getString("video_url"));
        video.setCoverUrl(rs.getString("cover_url"));
        video.setAuthorId(rs.getInt("author_id"));
        video.setDescription(rs.getString("description"));
        video.setViewCount(rs.getInt("view_count"));
        video.setStatus(rs.getInt("status"));
        video.setLikeCount(rs.getInt("like_count"));
        video.setCoinCount(rs.getInt("coin_count"));
        video.setFavCount(rs.getInt("fav_count"));
        video.setScreenCommentCount(rs.getInt("screen_comment_count"));
        video.setTimeCreate(rs.getTimestamp("time_create"));
        return video;
    }

    //从ResultSet中提取Video对象
    private Video extractVideoFromResultSet(ResultSet rs) throws SQLException {
        Video video = new Video();
        video.setId(rs.getInt("id"));
        video.setTitle(rs.getString("title"));
        video.setVideoUrl(rs.getString("video_url"));
        video.setCoverUrl(rs.getString("cover_url"));
        video.setAuthorId(rs.getInt("author_id"));
        video.setDescription(rs.getString("description"));
        video.setViewCount(rs.getInt("view_count"));
        video.setStatus(rs.getInt("status"));
        video.setLikeCount(rs.getInt("like_count"));
        video.setCoinCount(rs.getInt("coin_count"));
        video.setFavCount(rs.getInt("fav_count"));
        video.setScreenCommentCount(rs.getInt("screen_comment_count"));
        video.setVisibility(rs.getString("visibility"));
        video.setTimeCreate(rs.getTimestamp("time_create"));
        // 设置作者信息
        if (rs.getString("author_name") != null) {
            User author = new User();
            author.setId(video.getAuthorId());
            author.setUsername(rs.getString("author_name"));
            author.setAvatarUrl(rs.getString("author_avatar"));
            video.setAuthor(author);
        }
        return video;
    }

    //从ResultSet中提取ScreenComment对象
    private ScreenComment extractCommentFromResultSet(ResultSet rs) throws SQLException {
        ScreenComment comment = new ScreenComment();
        comment.setId(rs.getInt("id"));
        comment.setVideoId(rs.getInt("video_id"));
        comment.setUserId(rs.getInt("user_id"));
        comment.setContent(rs.getString("content"));
        comment.setPhoto(rs.getString("photo"));
        comment.setVideoTime(rs.getFloat("video_time"));
        comment.setTimeCreate(rs.getTimestamp("time_create"));
        // 设置用户信息
        User user = new User();
        user.setId(comment.getUserId());
        user.setUsername(rs.getString("comment_user"));
        comment.setUser(user);
        // 设置视频信息
        Video video = new Video();
        video.setId(comment.getVideoId());
        video.setTitle(rs.getString("video_title"));
        video.setAuthorId(rs.getInt("video_author_id"));
        comment.setVideo(video);
        return comment;
    }

    //获取作者发布的已审核通过的视频
    public List<Video> getApprovedVideosByAuthorId(int authorId) throws Exception {
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE v.author_id = ? AND v.status = 1 ORDER BY v.time_create DESC";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, authorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(extractVideoFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("根据作者ID查询已审核视频失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return videos;
    }

    @Override
    public List<Video> getFollowingVideos(int userId, User user, int page, int pageSize) throws Exception {
        if (user == null) {
            return new ArrayList<>();
        }
        String visibilityCondition = buildVisibilityCondition(user.getId());
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "INNER JOIN user_follows uf ON uf.user_id = v.author_id " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE uf.follower_id = ? AND v.status = 1 AND " + visibilityCondition + " " +
                "ORDER BY v.time_create DESC LIMIT ? OFFSET ?";
        List<Video> videos = new ArrayList<>();
        int offset = Math.max(0, (page - 1) * pageSize);
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, pageSize);
            pstmt.setInt(3, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(extractVideoFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("获取关注动态失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return videos;
    }

    @Override
    public int getFollowingVideoCount(int userId, User user) throws Exception {
        if (user == null) {
            return 0;
        }
        String visibilityCondition = buildVisibilityCondition(user.getId());
        String sql = "SELECT COUNT(*) FROM videos v " +
                "INNER JOIN user_follows uf ON uf.user_id = v.author_id " +
                "WHERE uf.follower_id = ? AND v.status = 1 AND " + visibilityCondition;
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.out.print("获取关注动态总数失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public int reportVideo(int videoId, int userid, String reasonDetail) throws Exception {
        String sql = "INSERT INTO report (video_id,user_id, reason_detail, status, time_create) VALUES (?,?, ?, 0, CURRENT_TIMESTAMP)";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, videoId);
            pstmt.setInt(2, userid);
            pstmt.setString(3, reasonDetail);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.print("举报视频失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
    }

    @Override
    public boolean hasCoined(int userId, int videoId) throws Exception {
        String sql = "SELECT COUNT(*) FROM video_coins WHERE user_id = ? AND video_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, videoId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.out.print("检查投币状态失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return false;
    }

    @Override
    public int updateVideoCoinCount(int videoId, int amount) throws Exception {
        String sql = "UPDATE videos SET coin_count = coin_count + ? WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, amount);
            pstmt.setInt(2, videoId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.print("更新视频投币数失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
    }

    @Override
    public List<Video> getLikedVideosByUserId(int userId, int page, int pageSize) throws Exception {
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "INNER JOIN likes l ON v.id = l.video_id " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE l.user_id = ? AND v.status = 1 " +
                "ORDER BY l.time_like DESC " +
                "LIMIT ? OFFSET ?";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, pageSize);
            pstmt.setInt(3, (page - 1) * pageSize);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                videos.add(extractVideoFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.out.print("获取用户点赞视频失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return videos;
    }

    @Override
    public int countUserLikes(int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM likes l " +
                "INNER JOIN videos v ON l.video_id = v.id " +
                "WHERE l.user_id = ? AND v.status = 1";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.out.print("获取用户点赞总数失败");
            throw new BaseException(500, "查询操作失败" + e.getMessage(), e);
        }
        return 0;
    }
}
