package com.assessment.www.dao.ticket;

import com.assessment.www.po.ticket.Ticket;
import com.assessment.www.po.ticket.UserTicket;

import java.util.List;

// 票务信息处理DAO接口
public interface TicketDao {
    // 根据漫展ID获取票务
    List<Ticket> getTicketsByExhibitionId(Integer exhibitionId);

    // 获取票务详情
    Ticket getTicketById(Integer id);

    // 更新票务剩余数量
    boolean updateTicketRemainingQuantity(Integer ticketId, Integer remainingQuantity);

    // 添加票务
    void addTicket(Ticket ticket);

    // 修改票务
    void updateTicket(Ticket ticket);

    // 扣减票务剩余数量
    boolean decreaseRemainingQuantity(Integer ticketId, Integer quantity);

    List<UserTicket> getUserTickets(int userId);

    void updateUserTicketStatus(int userTicketId, String used,String code);

    UserTicket getUserTicketByVerifyCode(String verifyCode);

    List<UserTicket> getVerifiedUserTickets(int userId);

    UserTicket getTicketByOrderId(Integer oid);
}