package com.assessment.www.dao;

import com.assessment.www.po.ScreenComment;

import java.util.List;

public interface ScreenCommentDao {
    int addComment(ScreenComment comment);//添加评论

    int deleteComment(int id);//删除评轮

    List<ScreenComment> getCommentsByVideoId(int videoId);//获取视屏评轮

    List<ScreenComment> getCommentsByreplyId(int replyId);//获取当前视屏评轮和子级
}
