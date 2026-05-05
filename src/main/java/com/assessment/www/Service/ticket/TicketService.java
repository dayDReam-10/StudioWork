package com.assessment.www.Service.ticket;

import com.assessment.www.po.ticket.Ticket;
import com.assessment.www.po.ticket.UserTicket;

import java.util.List;

public interface TicketService {
    List<Ticket> getTicketsByExhibitionId(int exhibitionId);

    Ticket getTicketById(int id);

    Ticket getTicketByorderId(int orderid);

    boolean updateTicketStock(int ticketId, int quantity);

    // 获取用户票务记录
    List<UserTicket> getUserTickets(int userId);

    // 核销票务
    boolean verifyTicket(int userTicketId);

    // 通过验证码核销
    boolean verifyTicketByCode(String verifyCode,String orderId);

    // 获取用户核销历史
    List<UserTicket> getVerifiedUserTickets(int userId);

    void decreaseTicketStock(int ticketId, int quantity);
}