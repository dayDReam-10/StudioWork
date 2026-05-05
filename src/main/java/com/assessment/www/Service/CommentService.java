package com.assessment.www.Service;

import com.assessment.www.po.ScreenComment;

import java.util.List;
//评论处理信息
public interface CommentService {
    // 发送评论
    boolean sendComment(int videoId, int userId, String content, Float videoTime, Integer parentId);

    // 删除评论
    boolean deleteComment(int commentId, int userId);

    // 获取视频的所有评论
    List<ScreenComment> getVideoComments(int videoId);

    // 获取顶级评论
    List<ScreenComment> getTopLevelComments(int videoId);

    // 获取某个评论的回复
    List<ScreenComment> getRepliesByParentId(int parentId);

    // 获取评论总数
    int getCommentCount(int videoId);

    List<ScreenComment> buildCommentTree(List<ScreenComment> comments);
}