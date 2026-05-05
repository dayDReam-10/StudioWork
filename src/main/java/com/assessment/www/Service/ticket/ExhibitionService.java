package com.assessment.www.Service.ticket;

import com.assessment.www.po.ticket.Exhibition;
import com.assessment.www.po.ticket.Ticket;

import java.util.List;

public interface ExhibitionService {
    List<Exhibition> getExhibitions(String type, String timeRange);
    Exhibition getExhibitionById(int id);
    boolean publishExhibition(Exhibition exhibition);
    boolean updateExhibition(Exhibition exhibition);
    boolean deleteExhibition(int id);
    // 用户收藏功能
    List<Exhibition> getUserFavorites(int userId, int page, int pagesize);
    // 用户收藏总数
    int getUserFavoritesCount(int userId);
    boolean addFavorite(int userId, int exhibitionId);
    boolean removeFavorite(int userId, int exhibitionId);
    boolean isFavorite(int userId, int exhibitionId);
    // 用户历史订单
    List<Exhibition> getUserExhibitionHistory(int userId);
    // 获取售票和核销统计
    int getTicketSalesCount(int exhibitionId);
    int getTicketVerifyCount(int exhibitionId);
    int saveOrupdate(Exhibition exhibition);
    // 发布漫展并添加票务信息
    int publishExhibitionWithTickets(Exhibition exhibition, List<Ticket> tickets);
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
    //修改漫展活动状态
    void updateExhibitionStatus(int id, int status);
    boolean saveExhibition(Exhibition exhibition);
}