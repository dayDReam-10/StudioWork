package com.assessment.www.Service;

import com.assessment.www.po.Video;

import java.util.List;

//视频业务逻辑接口
public interface VideoService {
    // 发布视频
    boolean uploadVideo(Video video);

    // 删除视频
    boolean deleteVideo(int id, int userId);

    // 管理员删除视频（不需要用户ID）
    boolean deleteVideoById(int id);

    // 修改视频基本信息
    boolean updateVideoBaseInfo(int id, String title, String coverUrl, String description, int userId);

    // 获取视频详情
    Video getVideoDetail(int id);

    // 获取用户发布的视频列表
    List<Video> getUserVideos(int userId);

    // 获取用户发布的已审核通过的视频列表
    List<Video> getApprovedVideosByAuthorId(int userId);

    // 获取所有视频（分页）
    List<Video> getAllVideos(int page, int pageSize);

    // 获取所有视频（包括所有状态）
    List<Video> getAllVideosIncludingPending();

    // 获取视频总数
    int getTotalVideoCount();

    // 根据关键字搜索视频
    List<Video> searchVideos(String keyword, int page, int pageSize);

    // 管理员审核视频
    boolean approveVideo(int id);

    boolean rejectVideo(int id);

    // 播放视频（增加播放量）
    boolean playVideo(int id);

    // 点赞/取消点赞
    boolean likeVideo(int userId, int videoId);

    boolean unlikeVideo(int userId, int videoId);

    // 收藏/取消收藏
    boolean favoriteVideo(int userId, int videoId);

    boolean unfavoriteVideo(int userId, int videoId);

    // 投币
    boolean coinVideo(int userId, int videoId, int amount);

    // 发送弹幕
    boolean sendComment(int videoId, int userId, String text, float time, Integer parentId);

    // 发送评论并返回评论ID，失败返回0
    int sendCommentAndGetId(int videoId, int userId, String text, float time, Integer parentId);

    // 删除弹幕
    boolean deleteComment(int commentId, int userId);

    // 删除回复
    boolean deleteReply(int replyId, int userId);

    // 删除二级回复
    boolean deleteReply2(int reply2Id, int userId);

    // 保存观看历史
    boolean saveHistory(int userId, int videoId);

    // 获取用户观看历史
    List<com.assessment.www.po.History> getUserHistory(int userId);

    // 检查是否已点赞
    boolean isLiked(int userId, int videoId);

    // 检查是否已收藏
    boolean isFavorited(int userId, int videoId);

    // 获取用户收藏的视频
    List<Video> getUserFavoriteVideos(int userId, int page, int pageSize);

    // 获取用户收藏视频总数
    int getUserFavoriteCount(int userId);

    // 获取用户点赞的视频
    List<Video> getUserLikedVideos(int userId, int page, int pageSize);

    // 获取用户点赞视频总数
    int getUserLikeCount(int userId);

    // 获取视频弹幕
    List<com.assessment.www.po.ScreenComment> getVideoComments(int videoId);

    // 举报视频
    boolean reportVideo(int videoId, Integer userid, String reasonDetail);
}