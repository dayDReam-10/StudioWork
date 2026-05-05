package com.assessment.www.Service;

import com.assessment.www.Util.RedisUtil;
import com.assessment.www.Util.RedisJsonUtil;
import com.assessment.www.Util.utils;
import com.assessment.www.dao.*;
import com.assessment.www.constant.Constants;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.History;
import com.assessment.www.po.ScreenComment;
import com.assessment.www.po.User;
import com.assessment.www.po.Video;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.ServletContext;
import java.io.File;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

//视频业务逻辑实现类
public class VideoServiceImpl implements VideoService {
    private VideoDao videoDao = new VideoDaoImpl();
    private static final ObjectMapper objectMapper = new ObjectMapper();

    public VideoServiceImpl() {
    }

    @Override
    public boolean uploadVideo(Video video) {
        try {
            // 设置默认状态为已通过
            if (video.getStatus() == null) {
                video.setStatus(1);
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
            // 设置默认可见范围
            if (video.getVisibility() == null) {
                video.setVisibility("public");
            }
            int result = videoDao.addVideo(video);
            if (result > 0) {
                try {
                    RedisUtil.del("videos:count:total");
                } catch (Exception e) {
                }
            }
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public boolean updateVideoBaseInfo(int id, String title, String coverUrl, String description, int userId) {
        try {
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
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public List<Video> getUserVideos(int userId, User user) {
        try {
            return videoDao.getVideosByAuthorId(userId, user);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public List<Video> getApprovedVideosByAuthorId(int userId) {
        try {
            return videoDao.getApprovedVideosByAuthorId(userId);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public List<Video> getFollowingVideos(int userId, User user, int page, int pageSize) {
        try {
            return videoDao.getFollowingVideos(userId, user, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public int getFollowingVideoCount(int userId, User user) {
        try {
            return videoDao.getFollowingVideoCount(userId, user);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public Video getVideoDetail(int id) {
        try {
            return videoDao.getVideoById(id);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public List<Video> getAllVideos(User user, int page, int pageSize) {
        try {
            List<Video> videos = videoDao.getAllVideos(user);
            int fromIndex = (page - 1) * pageSize;
            int toIndex = Math.min(fromIndex + pageSize, videos.size());
            if (fromIndex >= videos.size()) {
                return null;
            }
            List<Video> result = videos.subList(fromIndex, toIndex);
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public List<Video> getAllVideosIncludingPending() {
        try {
            return videoDao.getAllVideosIncludingPending();
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public int getTotalVideoCount(User user) {
        try {
            String cacheKey = "videos:count:total";
            try {
                String cachedCount = RedisUtil.get(cacheKey);
                if (cachedCount != null) {
                    return Integer.parseInt(cachedCount);
                }
            } catch (Exception e) {
            }
            List<Video> allVideos = videoDao.getAllVideos(user);
            int count = allVideos.size();
            try {
                RedisUtil.setex(cacheKey, 300, String.valueOf(count));
            } catch (Exception e) {
            }
            return count;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public int getPublicVideoCount(User user) {
        try {
            return videoDao.getApprovedVisibleVideos(user).size();
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public List<Video> searchVideos(User user, String keyword, int page, int pageSize) {
        return searchVideos(keyword, page, pageSize, user); // 默认用户ID为0（未登录）
    }

    //搜索视频，支持根据用户可见范围过滤
    public List<Video> searchVideos(String keyword, int page, int pageSize, User user) {
        try {
            if (keyword == null || keyword.trim().isEmpty()) {
                // 如果没有关键词，主页和搜索页只展示已通过审核且对当前用户可见的视频
                return getVisibleApprovedVideos(user, page, pageSize);
            }
            List<Video> allVideos = videoDao.searchByKeyword(keyword, user);
            // 分页处理
            int fromIndex = (page - 1) * pageSize;
            int toIndex = Math.min(fromIndex + pageSize, allVideos.size());
            if (fromIndex >= allVideos.size()) {
                return new ArrayList<>();
            }

            return allVideos.subList(fromIndex, toIndex);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    private List<Video> getVisibleApprovedVideos(User user, int page, int pageSize) throws Exception {
        List<Video> videos = videoDao.getApprovedVisibleVideos(user);
        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, videos.size());
        if (fromIndex >= videos.size()) {
            return new ArrayList<>();
        }
        return videos.subList(fromIndex, toIndex);
    }


    @Override
    public boolean approveVideo(int id) {
        try {
            return videoDao.updateVideoStatus(id, 1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public boolean rejectVideo(int id) {
        try {
            return videoDao.updateVideoStatus(id, 2) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public boolean playVideo(int id) {
        try {
            return videoDao.increaseViewCount(id) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public boolean coinVideo(int userId, int videoId, int amount) {
        try {
            if (amount < Constants.MINCOINMOUNT || amount > Constants.MAXCOINMOUNT) {
                return false;
            }
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
            return videoDao.addCoin(userId, videoId, amount) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean sendComment(int videoId, int userId, String text, float time, Integer parentId) {
        try {
            if (text == null || text.trim().isEmpty()) {
                System.out.println("内容为空");
                return false;
            }
            if (text.length() > Constants.MAXCOMMENTLENGTH) {
                System.out.println("内容太长");
                return false;
            }
            int result = videoDao.sendComment(videoId, userId, text.trim(), time, parentId);
            if (result > 0) {
                System.out.println("评论成功" + videoId + "用户id为" + userId);
            } else {
                System.out.println("评论失败" + videoId);
            }
            return result > 0;
        } catch (Exception e) {
            System.err.println("发送评论失败" + e.getMessage());
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    public boolean sendComment(int videoId, int userId, String text, String photoBase64, float time, Integer parentId) {
        try {
            int result = videoDao.sendCommentWithPhoto(videoId, userId, text.trim(), photoBase64, time, parentId);
            if (result > 0) {
                System.out.println("带照片的评论成功" + videoId + "用户id为" + userId);
            } else {
                System.out.println("评论失败" + videoId);
            }
            return result > 0;
        } catch (Exception e) {
            System.err.println("发送评论失败" + e.getMessage());
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            if (comment.getUserId() != userId) {
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
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public boolean saveHistory(int userId, int videoId) {
        try {
            return videoDao.saveHistory(userId, videoId) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public List<History> getUserHistory(int userId) {
        try {
            HistoryDao historyDao = new HistoryDaoImpl();
            return historyDao.findByUserId(userId);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public boolean isLiked(int userId, int videoId) {
        try {
            return videoDao.isLiked(userId, videoId);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public boolean isFavorited(int userId, int videoId) {
        try {
            return videoDao.isFaved(userId, videoId);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public List<Video> getUserFavoriteVideos(int userId, int page, int pageSize) {
        try {
            FavoriteDao favoriteDao = new FavoriteDaoImpl();
            return favoriteDao.getFavoritesByUserId(userId, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public int getUserFavoriteCount(int userId) {
        try {
            FavoriteDao favoriteDao = new FavoriteDaoImpl();
            return favoriteDao.countUserFavorites(userId);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public List<Video> getUserLikedVideos(int userId, int page, int pageSize) {
        try {
            return videoDao.getLikedVideosByUserId(userId, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    @Override
    public int getUserLikedCount(int userId) {
        try {
            return videoDao.countUserLikes(userId);
        } catch (Exception e) {
            e.printStackTrace();
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            //回复作者本人或视频作者可以删除
            if (!reply.getUserId().equals(userId)) {
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
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            if (!reply2.getUserId().equals(userId)) {
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
            throw new BaseException(500, "操作失败" + e.getMessage());
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
            throw new BaseException(500, "操作失败" + e.getMessage());
        }
    }

    // 清除视频缓存
    private void clearVideoCache() {
        try {
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 解析视频列表JSON
    private List<Video> parseVideoListFromJson(String json) {
        try {
            return objectMapper.readValue(json, new TypeReference<List<Video>>() {
            });
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}