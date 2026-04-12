package com.assessment.www.dao;

import com.assessment.www.po.Video;
import com.assessment.www.po.ScreenComment;

import java.util.List;

public interface VideoDao {
    // 发布视频，删除视频，查看收藏，投币，点赞，取消点赞，收藏，取消收藏，评论，删评论
    int addVideo(Video video) throws Exception;

    int deleteVideo(int id) throws Exception;

    int updateVideoBaseInfo(int id, String title, String coverUrl, String description) throws Exception;//基本上传

    //详情获取
    Video getVideoById(int id) throws Exception;

    //扯video的数据
    List<Video> getVideosByAuthorId(int authorId) throws Exception;

    // 获取作者发布的已审核通过的视频
    List<Video> getApprovedVideosByAuthorId(int authorId) throws Exception;

    // 个人视频
    List<Video> getAllVideos() throws Exception;

    // 获取所有视频（包括所有状态）
    List<Video> getAllVideosIncludingPending() throws Exception;

    List<Video> searchByKeyword(String keyword) throws Exception;

    //首页，刷新没写
    int updateVideoStatus(int id, int status) throws Exception;//0->1 0->2

    int updateVideoCounts(int id, String type, int count) throws Exception;//控制type来改东西

    int increaseViewCount(Integer id) throws Exception;

    int addCoin(int userId, int videoId, int amount) throws Exception;

    // 检查是否已经投币
    boolean hasCoined(int userId, int videoId) throws Exception;

    // 更新视频投币总数
    int updateVideoCoinCount(int videoId, int amount) throws Exception;

    int sendComment(int videoId, int userId, String text, float time, Integer parentId) throws Exception;

    int deleteComment(int commentId) throws Exception;

    ScreenComment getCommentById(int commentId) throws Exception; // 获取单个评论信息

    int saveHistory(int userId, int videoId) throws Exception;//历史记录

    int updateLike(int userId, int videoId, int status) throws Exception;//点赞

    int updateFav(int userId, int videoId, int status) throws Exception;

    boolean isLiked(int userId, int videoId) throws Exception;//我是否点过赞

    boolean isFaved(int userId, int videoId) throws Exception;

    // 获取评论
    List<ScreenComment> getCommentsByVideoId(int videoId) throws Exception;

    // 举报视频
    int reportVideo(int videoId, int userid, String reasonDetail) throws Exception;
}
