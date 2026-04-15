package com.assessment.www.Service;

import com.assessment.www.Util.utils;
import com.assessment.www.dao.*;
import com.assessment.www.constant.Constants;
import com.assessment.www.po.History;
import com.assessment.www.po.ScreenComment;
import com.assessment.www.po.Video;

import javax.servlet.ServletContext;
import java.io.File;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

//视频业务逻辑实现类
public class VideoServiceImpl implements VideoService {
    private VideoDao videoDao = new VideoDaoImpl();
    private ServletContext servletContext;

    public VideoServiceImpl() {
    }

    public VideoServiceImpl(ServletContext servletContext) {
        this.servletContext = servletContext;
    }

    @Override
    public boolean uploadVideo(Video video) {
        try {
            // 设置默认状态为待审核
            if (video.getStatus() == null) {
                video.setStatus(0);
            }
            if (video.getViewCount() == null) {
                video.setViewCount(0);
            }
            if (video.getLikeCount() == null) {
                video.setLikeCount(0);
            }
            if (video.getCoinCount() == null) {
                video.setCoinCount(0);
            }
            if (video.getFavCount() == null) {
                video.setFavCount(0);
            }
            if (video.getScreenCommentCount() == null) {
                video.setScreenCommentCount(0);
            }
            int result = videoDao.addVideo(video);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteVideo(int id, int userId) {
        try {
            // 先查询视频，检查是否是作者本人
            Video video = videoDao.getVideoById(id);
            if (video == null) {
                return false;
            }
            // 只有视频作者或管理员可以删除
            if (video.getAuthorId() != userId) {
                return false;
            }
            // 删除视频文件
            if (video.getVideoUrl() != null) {
                String videoPath = video.getVideoUrl();
                File videoFile = new File(videoPath);
                if (videoFile.exists()) {
                    videoFile.delete();
                }
            }
            return videoDao.deleteVideo(id) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateVideoBaseInfo(int id, String title, String coverUrl, String description, int userId) {
        try {
            // 先查询视频，检查是否是作者本人
            Video video = videoDao.getVideoById(id);
            if (video == null) {
                return false;
            }
            if (video.getAuthorId() != userId) {
                return false;
            }
            return videoDao.updateVideoBaseInfo(id, title, coverUrl, description) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Video getVideoDetail(int id) {
        try {
            return videoDao.getVideoById(id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Video> getUserVideos(int userId) {
        try {
            return videoDao.getVideosByAuthorId(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Video> getApprovedVideosByAuthorId(int userId) {
        try {
            return videoDao.getApprovedVideosByAuthorId(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Video> getAllVideos(int page, int pageSize) {
        try {
            List<Video> videos = videoDao.getAllVideos();
            int fromIndex = (page - 1) * pageSize;
            int toIndex = Math.min(fromIndex + pageSize, videos.size());
            if (fromIndex >= videos.size()) {
                return null;
            }
            return videos.subList(fromIndex, toIndex);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Video> getAllVideosIncludingPending() {
        try {
            return videoDao.getAllVideosIncludingPending();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public int getTotalVideoCount() {
        try {
            List<Video> allVideos = videoDao.getAllVideos();
            return allVideos.size();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public List<Video> searchVideos(String keyword, int page, int pageSize) {
        try {
            if (keyword == null || keyword.trim().isEmpty()) {
                return getAllVideos(page, pageSize);
            }
            List<Video> allVideos = videoDao.searchByKeyword(keyword);
            int fromIndex = (page - 1) * pageSize;
            int toIndex = Math.min(fromIndex + pageSize, allVideos.size());
            if (fromIndex >= allVideos.size()) {
                return null;
            }
            return allVideos.subList(fromIndex, toIndex);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public boolean approveVideo(int id) {
        try {
            return videoDao.updateVideoStatus(id, 1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean rejectVideo(int id) {
        try {
            return videoDao.updateVideoStatus(id, 2) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean playVideo(int id) {
        try {
            return videoDao.increaseViewCount(id) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean likeVideo(int userId, int videoId) {
        try {
            if (videoDao.isLiked(userId, videoId)) {
                return false;
            }
            return videoDao.updateLike(userId, videoId, 1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean unlikeVideo(int userId, int videoId) {
        try {
            if (!videoDao.isLiked(userId, videoId)) {
                return false;
            }
            return videoDao.updateLike(userId, videoId, 0) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean favoriteVideo(int userId, int videoId) {
        try {
            if (videoDao.isFaved(userId, videoId)) {
                return false;
            }
            return videoDao.updateFav(userId, videoId, 1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean unfavoriteVideo(int userId, int videoId) {
        try {
            if (!videoDao.isFaved(userId, videoId)) {
                return false;
            }
            return videoDao.updateFav(userId, videoId, 0) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean coinVideo(int userId, int videoId, int amount) {
        try {
            // 检查用户硬币是否足够
            UserDao userDao = new UserDaoImpl();
            int userCoins = userDao.getCoinCount(userId);
            if (userCoins < amount) {
                return false;
            }
            // 检查是否已经投过币
            if (videoDao.hasCoined(userId, videoId)) {
                return false; // 已经投过币，不能重复投币
            }
            // 使用事务确保数据一致性
            Connection conn = null;
            try {
                conn = utils.getConnection();
                conn.setAutoCommit(false);
                // 1. 扣除用户硬币
                int updateResult = userDao.changeCoin(userId, -amount);
                if (updateResult <= 0) {
                    conn.rollback();
                    return false;
                }
                // 2. 添加投币记录
                int coinResult = videoDao.addCoin(userId, videoId, amount);
                if (coinResult <= 0) {
                    conn.rollback();
                    return false;
                }
                // 3. 更新视频的投币数
                int videoResult = videoDao.updateVideoCoinCount(videoId, amount);
                if (videoResult <= 0) {
                    conn.rollback();
                    return false;
                }
                conn.commit();
                return true;
            } catch (Exception e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
                e.printStackTrace();
                return false;
            } finally {
                if (conn != null) {
                    try {
                        conn.setAutoCommit(true);
                        conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean sendComment(int videoId, int userId, String text, float time, Integer parentId) {
        return sendCommentAndGetId(videoId, userId, text, time, parentId) > 0;
    }

    @Override
    public int sendCommentAndGetId(int videoId, int userId, String text, float time, Integer parentId) {
        try {
            if (text == null || text.trim().isEmpty()) {
                System.out.println("内容为空");
                return 0;
            }
            if (text.length() > Constants.MAXCOMMENTLENGTH) {
                System.out.println("内容太长");
                return 0;
            }
            int commentId = videoDao.sendComment(videoId, userId, text.trim(), time, parentId);
            if (commentId > 0) {
                System.out.println("评论成功" + videoId + "用户id为" + userId);
            } else {
                System.out.println("评论失败" + videoId);
            }
            return commentId;
        } catch (Exception e) {
            System.err.println("发送评论失败" + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public boolean deleteComment(int commentId, int userId) {
        try {
            ScreenComment comment = videoDao.getCommentById(commentId);
            if (comment == null) {
                System.out.println("评论id不存在" + commentId);
                return false;
            }
            boolean isAdmin = isAdminUser(userId);
            if (!isAdmin && comment.getUserId() != userId) {
                Video video = videoDao.getVideoById(comment.getVideoId());
                if (video == null) {
                    System.out.println("视频id不存在" + commentId);
                    return false;
                }
                if (video.getAuthorId() != userId) {
                    System.out.println("用户id为" + userId + "没有登陆评论权限" + commentId);
                    return false;
                }
            }
            int result = videoDao.deleteComment(commentId);
            if (result > 0) {
                return true;
            } else {
                System.out.println("评论失败" + commentId);
                return false;
            }
        } catch (Exception e) {
            System.err.println("评论失败" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean saveHistory(int userId, int videoId) {
        try {
            return videoDao.saveHistory(userId, videoId) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<History> getUserHistory(int userId) {
        try {
            HistoryDao historyDao = new HistoryDaoImpl();
            return historyDao.findByUserId(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public boolean isLiked(int userId, int videoId) {
        try {
            return videoDao.isLiked(userId, videoId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean isFavorited(int userId, int videoId) {
        try {
            return videoDao.isFaved(userId, videoId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<Video> getUserFavoriteVideos(int userId, int page, int pageSize) {
        try {
            FavoriteDao favoriteDao = new FavoriteDaoImpl();
            return favoriteDao.getFavoritesByUserId(userId, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    @Override
    public int getUserFavoriteCount(int userId) {
        try {
            FavoriteDao favoriteDao = new FavoriteDaoImpl();
            return favoriteDao.countUserFavorites(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public List<Video> getUserLikedVideos(int userId, int page, int pageSize) {
        try {
            LikeDao likeDao = new LikeDaoImpl();
            return likeDao.getLikesByUserId(userId, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    @Override
    public int getUserLikeCount(int userId) {
        try {
            LikeDao likeDao = new LikeDaoImpl();
            return likeDao.countUserLikes(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public List<ScreenComment> getVideoComments(int videoId) {
        try {
            Video video = videoDao.getVideoById(videoId);
            if (video == null) {
                return new ArrayList<>();
            }
            List<ScreenComment> comments = videoDao.getCommentsByVideoId(videoId);
            if (comments == null) {
                return new ArrayList<>();
            }
            return comments;
        } catch (Exception e) {
            System.err.println("获取视频评论出错: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    @Override
    public boolean deleteVideoById(int id) {
        try {
            // 先查询视频，检查是否存在
            Video video = videoDao.getVideoById(id);
            if (video == null) {
                return false;
            }
            // 管理员可以删除任何视频
            return videoDao.deleteVideo(id) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean reportVideo(int videoId, Integer reporterId, String reasonDetail) {
        try {
            // 检查视频是否存在
            Video video = videoDao.getVideoById(videoId);
            if (video == null) {
                System.out.println("视屏不存在" + videoId);
                return false;
            }
            // 检查用户是否存在
            UserDao userDao = new UserDaoImpl();
            if (userDao.getUserById(reporterId) == null) {
                System.out.println("用户不存在" + reporterId);
                return false;
            }
            int result = videoDao.reportVideo(videoId, reporterId, reasonDetail);
            if (result > 0) {
                return true;
            } else {
                System.out.println("举报失败" + videoId);
                return false;
            }
        } catch (Exception e) {
            System.err.println("举报失败" + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteReply(int replyId, int userId) {
        try {
            ScreenCommentDao commentDao = new ScreenCommentDaoImpl();
            List<ScreenComment> allComments = commentDao.getCommentsByreplyId(replyId);      // 查询回复
            ScreenComment reply = null;
            int videoId = 0;
            for (ScreenComment c : allComments) {
                if (c.getId().equals(replyId)) {
                    reply = c;
                    videoId = c.getVideoId();
                    break;
                }
            }
            if (reply == null) {
                return false;
            }
            boolean isAdmin = isAdminUser(userId);
            //回复作者本人或视频作者可以删除
            if (!isAdmin && !reply.getUserId().equals(userId)) {
                // 如果不是回复作者，需要检查是否是视频作者
                Video video = videoDao.getVideoById(videoId);
                if (video == null || !video.getAuthorId().equals(userId)) {
                    return false;
                }
            }
            // 删除回复
            if (commentDao.deleteComment(replyId) > 0) {
                // 更新视频评论数
                updateVideoCommentCount(videoId);
                return true;
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteReply2(int reply2Id, int userId) {
        try {
            ScreenCommentDao commentDao = new ScreenCommentDaoImpl();
            List<ScreenComment> allComments = commentDao.getCommentsByreplyId(reply2Id);// 查询二级回复
            ScreenComment reply2 = null;
            int videoId = 0;
            for (ScreenComment c : allComments) {
                if (c.getId().equals(reply2Id)) {
                    reply2 = c;
                    videoId = c.getVideoId();
                    break;
                }
            }
            if (reply2 == null) {
                return false;
            }
            boolean isAdmin = isAdminUser(userId);
            if (!isAdmin && !reply2.getUserId().equals(userId)) {
                Video video = videoDao.getVideoById(videoId);
                if (video == null || !video.getAuthorId().equals(userId)) {
                    return false;
                }
            }
            if (commentDao.deleteComment(reply2Id) > 0) {
                // 更新视频评论数
                updateVideoCommentCount(videoId);
                return true;
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private boolean isAdminUser(int userId) {
        try {
            UserDao userDao = new UserDaoImpl();
            com.assessment.www.po.User user = userDao.getUserById(userId);
            return user != null && Constants.ROLEADMIN.equals(user.getRole());
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 更新视频评论数
    private void updateVideoCommentCount(int videoId) {
        try {
            ScreenCommentDao commentDao = new ScreenCommentDaoImpl();
            int commentCount = commentDao.getCommentsByVideoId(videoId).size();
            videoDao.updateVideoCounts(videoId, "comment", commentCount);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}