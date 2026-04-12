package com.assessment.www.dao;

import com.assessment.www.po.History;

import java.util.List;


public interface HistoryDao {
    //添加历史记录
    int save(History history) throws Exception;

    //查询用户的历史记录
    List<History> findByUserId(Integer userId) throws Exception;

    //删除历史记录
    int delete(Integer id) throws Exception;

    //清空用户的历史记录
    int deleteByUserId(Integer userId) throws Exception;
}