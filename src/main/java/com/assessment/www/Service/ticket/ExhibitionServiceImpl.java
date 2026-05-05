package com.assessment.www.Service.ticket;

import com.assessment.www.dao.ticket.ExhibitionDao;
import com.assessment.www.dao.ticket.ExhibitionDaoImpl;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ticket.Exhibition;
import com.assessment.www.po.ticket.Ticket;

import java.util.List;

public class ExhibitionServiceImpl implements ExhibitionService {
    private ExhibitionDao exhibitionDao;

    public ExhibitionServiceImpl() {
        this.exhibitionDao = new ExhibitionDaoImpl();
    }

    @Override
    public List<Exhibition> getExhibitions(String type, String timeRange) {
        if (type != null && !type.equals("all") && timeRange != null && !timeRange.equals("all")) {
            // 同时按类型和时间筛选
            return exhibitionDao.getExhibitionsByTypeAndTime(type, timeRange);
        } else if (type != null && !type.equals("all")) {
            return exhibitionDao.getExhibitionsByType(type);
        } else if (timeRange != null && !timeRange.equals("all")) {
            return exhibitionDao.getExhibitionsByTime(timeRange);
        } else {
            return exhibitionDao.getActiveExhibitions();
        }
    }

    @Override
    public Exhibition getExhibitionById(int id) {
        return exhibitionDao.getExhibitionById(id);
    }

    @Override
    public boolean publishExhibition(Exhibition exhibition) {
        try {
            exhibitionDao.addExhibition(exhibition);
            return true;
        } catch (Exception e) {
            throw new BaseException(500, "发布失败", e);
        }
    }

    @Override
    public boolean updateExhibition(Exhibition exhibition) {
        try {
            exhibitionDao.updateExhibition(exhibition);
            return true;
        } catch (Exception e) {
            throw new BaseException(500, "修改失败", e);
        }
    }

    @Override
    public boolean deleteExhibition(int id) {
        try {
            exhibitionDao.deleteExhibition(id);
            return true;
        } catch (Exception e) {
            throw new BaseException(500, "删除失败", e);
        }
    }

    @Override
    public int getUserFavoritesCount(int userId) {
        return exhibitionDao.getUserFavoritesCount(userId);
    }

    @Override
    public List<Exhibition> getUserFavorites(int userId,int page,int pagesize) {
        return exhibitionDao.getUserFavorites(userId,page,pagesize);
    }

    @Override
    public boolean addFavorite(int userId, int exhibitionId) {
        try {
            exhibitionDao.addFavorite(userId, exhibitionId);
            return true;
        } catch (Exception e) {
            throw e;
        }
    }

    @Override
    public boolean removeFavorite(int userId, int exhibitionId) {
        try {
            exhibitionDao.removeFavorite(userId, exhibitionId);
            return true;
        } catch (Exception e) {
            throw e;
        }
    }

    @Override
    public boolean isFavorite(int userId, int exhibitionId) {
        return exhibitionDao.isFavorite(userId, exhibitionId);
    }

    @Override
    public List<Exhibition> getUserExhibitionHistory(int userId) {
        return exhibitionDao.getUserExhibitionHistory(userId);
    }

    @Override
    public int getTicketSalesCount(int exhibitionId) {
        return exhibitionDao.getTicketSalesCount(exhibitionId);
    }

    @Override
    public int getTicketVerifyCount(int exhibitionId) {
        return exhibitionDao.getTicketVerifyCount(exhibitionId);
    }

    @Override
    public int saveOrupdate(Exhibition exhibition) {
        return exhibitionDao.saveOrupdate(exhibition);
    }

    @Override
    public int publishExhibitionWithTickets(Exhibition exhibition, List<Ticket> tickets) {
        try {
            // 先保存展览信息，获取展览ID
            int i = exhibitionDao.saveOrupdate(exhibition);
            // 有票务信息保存票务信息
            if (exhibition.getId() == null) {
                exhibition.setId(i);
            }
            if (tickets != null && !tickets.isEmpty()) {
                ExhibitionDaoImpl exhibitionDaoImpl = (ExhibitionDaoImpl) exhibitionDao;
                for (Ticket ticket : tickets) {
                    if (ticket.getId() != null) {
                        exhibitionDaoImpl.updateTicket(ticket);
                    } else {
                        if (exhibition.getId() != null) {
                            ticket.setExhibitionId(exhibition.getId());
                            exhibitionDaoImpl.addTicket(ticket);
                        }
                    }
                }
            }
            return exhibition.getId();
        } catch (Exception e) {
            throw new BaseException(500, "更新票务数据失败" + e.getMessage(), e);
        }
    }

    @Override
    public int getActiveExhibitionsCount() {
        return exhibitionDao.getActiveExhibitionsCount();
    }

    @Override
    public int getUpcomingExhibitionsCount() {
        return exhibitionDao.getUpcomingExhibitionsCount();
    }

    @Override
    public List<Exhibition> getRecentExhibitions(int limit) {
        return exhibitionDao.getRecentExhibitions(limit);
    }

    @Override
    public List<Exhibition> getExhibitionsWithFilter(String search, String status, String type, int page, int pageSize) {
        return exhibitionDao.getExhibitionsWithFilter(search, status, type, page, pageSize);
    }

    @Override
    public int getTotalExhibitionsCount() {
        return exhibitionDao.getTotalExhibitionsCount();
    }

    @Override
    public int getTotalExhibitionsCount(String search, String status, String type) {
        return exhibitionDao.getTotalExhibitionsCount(search, status, type);
    }

    @Override
    public void updateExhibitionStatus(int id, int status) {
        exhibitionDao.updateExhibitionStatus(id, status);
    }

    @Override
    public boolean saveExhibition(Exhibition exhibition) {
        try {
            if (exhibition.getId() > 0) {
                exhibitionDao.updateExhibition(exhibition);// 更新
            } else {
                exhibitionDao.addExhibition(exhibition); // 新增
            }
            return true;
        } catch (Exception e) {
            throw e;
        }
    }
}