package com.assessment.www.dao.ticket;

import com.assessment.www.po.ticket.Exhibition;
import com.assessment.www.po.ticket.Ticket;

import java.util.List;

// 漫展演出DAO接口
public interface ExhibitionDao {
    // 获取所有漫展演出
    List<Exhibition> getActiveExhibitions();

    // 根据类型筛选漫展演出
    List<Exhibition> getExhibitionsByType(String type);

    // 根据时间筛选漫展演出
    List<Exhibition> getExhibitionsByTime(String timeRange);

    // 同时根据类型和时间筛选漫展演出
    List<Exhibition> getExhibitionsByTypeAndTime(String type, String timeRange);

    // 获取漫展详情
    Exhibition getExhibitionById(Integer id);

    // 发布漫展演出
    void addExhibition(Exhibition exhibition);

    // 修改漫展演出
    void updateExhibition(Exhibition exhibition);

    // 删除漫展演出
    void deleteExhibition(Integer id);

    // 保存或者呢更新
    int saveOrupdate(Exhibition exhibition);

    // 获取漫展的售票情况
    int getTicketSalesCount(Integer exhibitionId);

    // 获取漫展的核销情况
    int getTicketVerifyCount(Integer exhibitionId);

    // 获取用户收藏的漫展
    List<Exhibition> getUserFavorites(Integer userId,int page,int pagesize);
    int getUserFavoritesCount(int userId);
    // 添加收藏
    void addFavorite(Integer userId, Integer exhibitionId);

    // 取消收藏
    void removeFavorite(Integer userId, Integer exhibitionId);

    // 检查是否已收藏
    boolean isFavorite(Integer userId, Integer exhibitionId);

    // 获取用户历史订单
    List<Exhibition> getUserExhibitionHistory(Integer userId);

    // 添加票务信息
    void addTicket(Ticket ticket);

    // 获取活跃漫展数量
    int getActiveExhibitionsCount();

    // 获取即将开始的漫展数量
    int getUpcomingExhibitionsCount();

    // 获取最近的漫展
    List<Exhibition> getRecentExhibitions(int limit);

    // 管理员相关方法
    List<Exhibition> getExhibitionsWithFilter(String search, String status, String type, int page, int pageSize);

    int getTotalExhibitionsCount();

    int getTotalExhibitionsCount(String search, String status, String type);

    void updateExhibitionStatus(Integer id, int status);

    //删除关联的票务信息
    void deleteExhibitiontickets(Integer id);

    //修改关联的票务信息
    void updateTicket(Ticket ticket);
}