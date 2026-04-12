package com.assessment.www.dao;

import com.assessment.www.constant.Constants;
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
        String sql = "INSERT INTO videos (title, video_url, cover_url, author_id, description, view_count, status, like_count, coin_count, fav_count, screen_comment_count, time_create) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
            pstmt.setTimestamp(12, video.getTimeCreate());
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
            return 0;
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
        }
        return 0;
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
        }
        return 0;
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
                    return initVideo(rs);
                }
            }
        } catch (SQLException e) {
            System.out.print("根据ID查询视频失败");
        }
        return null;
    }

    @Override
    public List<Video> getVideosByAuthorId(int authorId) {
        // 个人主页投稿那块，把某位UP主发的视频全拉出来，不看删了的
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE v.author_id = ? ORDER BY v.time_create DESC";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, authorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(initVideo(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("根据作者ID查询视频失败");
        }
        return videos;
    }

    @Override
    public List<Video> getAllVideos() {
        // 获取前台公开视频，仅包含审核通过的视频
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "LEFT JOIN users u ON v.author_id = u.id " +
            "WHERE v.status = 1 " +
                "ORDER BY v.time_create DESC";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(initVideo(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("获取所有视频失败");
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
                    videos.add(initVideo(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("获取所有视频（包括待审核）失败");
            throw e;
        }
        return videos;
    }

    @Override
    public List<Video> searchByKeyword(String keyword) throws Exception {
        String sql = "SELECT v.*, u.username as author_name, u.avatar_url as author_avatar " +
                "FROM videos v " +
                "LEFT JOIN users u ON v.author_id = u.id " +
                "WHERE v.status = 1 AND (v.title LIKE ? OR v.description LIKE ?) " +  // 只查询审核通过的视频
                "ORDER BY v.time_create DESC";
        List<Video> videos = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String searchTerm = "%" + keyword + "%";
            pstmt.setString(1, searchTerm);
            pstmt.setString(2, searchTerm);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    videos.add(initVideo(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("根据关键词搜索视频失败");
            throw e;
        }
        return videos;
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
        }
        return 0;
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
            return 0;
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
            throw e;
        }
    }

    @Override
    public int addCoin(int userId, int videoId, int amount) {
        // 投币，给UP主排面。先往明细表里塞记录（遇到重复投币就加数量），再更新视频主表的硬币数。
        // 投币记录
        String sql1 = "INSERT INTO video_coins (user_id, video_id, amount) VALUES (?, ?, ?)";
        // 更新视频投币数
        String sql2 = "UPDATE videos SET coin_count = coin_count + ? WHERE id = ?";
        // 更新用户硬币数
        String sql3 = "UPDATE users SET coin_count = coin_count - ? WHERE id = ?";
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
                pstmt1.executeUpdate();
                // 更新视频投币数
                pstmt2.setInt(1, amount);
                pstmt2.setInt(2, videoId);
                pstmt2.executeUpdate();
                // 更新用户硬币数
                pstmt3.setInt(1, amount);
                pstmt3.setInt(2, userId);
                pstmt3.executeUpdate();
                conn.commit();
                return 1;
            } catch (SQLException e) {
                conn.rollback();
                System.out.print("投币失败");
                throw e;
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
        String sql = "INSERT INTO screen_comment (video_id, user_id, content, video_time,time_create, parent_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = utils.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, videoId);
                ps.setInt(2, userId);
                ps.setString(3, text);
                ps.setFloat(4, time);
                ps.setDate(5, new java.sql.Date(System.currentTimeMillis()));
                ps.setObject(6, parentId);
                int row = ps.executeUpdate();
                if (row > 0) {
                    updateVideoCounts(videoId, "comment", 1);
                    conn.commit();
                    return row;
                }
                conn.rollback();
                return 0;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
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
                    return initComment(rs);
                }
            }
        } catch (SQLException e) {
            System.out.print("获取评论详情失败");
            throw e;
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
            throw e;
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
                    comments.add(initComment(rs));
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
            return 0;
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
                    throw e;
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
                    throw e;
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
                    throw e;
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
                    throw e;
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

    //从ResultSet中提取Video对象
    private Video initVideo(ResultSet rs) throws SQLException {
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
    private ScreenComment initComment(ResultSet rs) throws SQLException {
        ScreenComment comment = new ScreenComment();
        comment.setId(rs.getInt("id"));
        comment.setVideoId(rs.getInt("video_id"));
        comment.setUserId(rs.getInt("user_id"));
        comment.setContent(rs.getString("content"));
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
                    videos.add(initVideo(rs));
                }
            }
        } catch (SQLException e) {
            System.out.print("根据作者ID查询已审核视频失败");
            throw e;
        }
        return videos;
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
            throw e;
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
            throw e;
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
            throw e;
        }
    }
}
