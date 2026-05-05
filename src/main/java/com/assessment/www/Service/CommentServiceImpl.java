package com.assessment.www.Service;

import com.assessment.www.dao.ScreenCommentDao;
import com.assessment.www.dao.ScreenCommentDaoImpl;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ScreenComment;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class CommentServiceImpl implements CommentService {
    private ScreenCommentDao commentDao = new ScreenCommentDaoImpl();

    @Override
    public boolean sendComment(int videoId, int userId, String content, Float videoTime, Integer parentId) {
        try {
            ScreenComment comment = new ScreenComment();
            comment.setVideoId(videoId);
            comment.setUserId(userId);
            comment.setContent(content);
            comment.setVideoTime(videoTime);
            comment.setTimeCreate(new Timestamp(System.currentTimeMillis()));
            comment.setParentId(parentId);
            int result = commentDao.addComment(comment);
            if (result > 0) {
                updateVideoCommentCount(videoId); // 更新视频评论数
                return true;
            }
            return false;
        } catch (Exception e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public boolean deleteComment(int commentId, int userId) {
        try {
            // 检查用户是否有权限删除评论
            List<ScreenComment> allComments = commentDao.getCommentsByVideoId(0);
            ScreenComment comment = null;
            int videoId = 0;
            for (ScreenComment c : allComments) {
                if (c.getId().equals(commentId)) {
                    comment = c;
                    videoId = c.getVideoId();
                    break;
                }
            }
            if (comment == null) {
                return false;
            }
            if (!comment.getUserId().equals(userId)) {
                com.assessment.www.dao.VideoDao videoDao = new com.assessment.www.dao.VideoDaoImpl();
                com.assessment.www.po.Video video = videoDao.getVideoById(comment.getVideoId());
                if (video == null || !video.getAuthorId().equals(userId)) {
                    return false;
                }
            }
            // 删除评论及其所有回复
            if (commentDao.deleteComment(commentId) > 0) {
                // 更新视频评论数
                updateVideoCommentCount(videoId);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public List<ScreenComment> getVideoComments(int videoId) {
        try {
            List<ScreenComment> allComments = commentDao.getCommentsByVideoId(videoId);
            return buildCommentTree(allComments);
        } catch (Exception e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public List<ScreenComment> getTopLevelComments(int videoId) {
        try {
            List<ScreenComment> allComments = commentDao.getCommentsByVideoId(videoId);
            return allComments.stream().filter(comment -> comment.getParentId() == null || comment.getParentId() == 0).collect(Collectors.toList());
        } catch (Exception e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public List<ScreenComment> getRepliesByParentId(int parentId) {
        try {
            List<ScreenComment> allComments = commentDao.getCommentsByVideoId(0); // 获取所有评论
            return allComments.stream().filter(comment -> parentId == (comment.getParentId().intValue())).collect(Collectors.toList());
        } catch (Exception e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public int getCommentCount(int videoId) {
        try {
            return commentDao.getCommentsByVideoId(videoId).size();
        } catch (Exception e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    //构建评论树形结构
    public List<ScreenComment> buildCommentTree(List<ScreenComment> comments) {
        List<ScreenComment> topLevelComments = new ArrayList<>();
        // 找出顶级评论
        for (ScreenComment comment : comments) {
            if (comment.getParentId() == null || comment.getParentId() == 0) {
                topLevelComments.add(comment);
            }
        }
        for (ScreenComment topLevelComment : topLevelComments) {
            topLevelComment.setReplies(findReplies(topLevelComment.getId(), comments));
        }
        return topLevelComments;
    }

    //查找某个评论的所有回复
    private List<ScreenComment> findReplies(int parentId, List<ScreenComment> comments) {
        List<ScreenComment> replies = new ArrayList<>();
        for (ScreenComment comment : comments) {
            if (comment.getParentId() != null && parentId == comment.getParentId()) {
                replies.add(comment);
                comment.setReplies(findReplies(comment.getId(), comments));     // 递归查找回复的回复
            }
        }
        return replies;
    }

    //更新视频评论数
    private void updateVideoCommentCount(int videoId) {
        try {
            com.assessment.www.dao.VideoDao videoDao = new com.assessment.www.dao.VideoDaoImpl();
            int commentCount = commentDao.getCommentsByVideoId(videoId).size();
            videoDao.updateVideoCounts(videoId, "comment", commentCount);
        } catch (Exception e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }
}