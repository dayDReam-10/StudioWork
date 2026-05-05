package com.assessment.www.Service.ticket;

import com.assessment.www.dao.ticket.*;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ticket.Ticket;
import com.assessment.www.po.ticket.UserTicket;

import java.util.List;

public class TicketServiceImpl implements TicketService {
    private TicketDao ticketDao;
    private UserTicketDao userTicketDao;
    private OrderDao orderDao;

    public TicketServiceImpl() {
        this.ticketDao = new TicketDaoImpl();
        this.userTicketDao = new UserTicketDaoImpl();
        this.orderDao = new OrderDaoImpl();
    }

    @Override
    public List<Ticket> getTicketsByExhibitionId(int exhibitionId) {
        return ticketDao.getTicketsByExhibitionId(exhibitionId);
    }

    @Override
    public Ticket getTicketById(int id) {
        return ticketDao.getTicketById(id);
    }

    @Override
    public Ticket getTicketByorderId(int orderid) {
        return userTicketDao.getTicketByorderId(orderid);
    }

    @Override
    public boolean updateTicketStock(int ticketId, int quantity) {
        try {
            boolean result = ticketDao.updateTicketRemainingQuantity(ticketId, quantity);
            return result;
        } catch (Exception e) {
            throw new BaseException(500, "操作失败", e);
        }
    }

    @Override
    public List<UserTicket> getUserTickets(int userId) {
        return ticketDao.getUserTickets(userId);
    }

    @Override
    public boolean verifyTicket(int userTicketId) {
        try {
            ticketDao.updateUserTicketStatus(userTicketId, "1", "");
            return true;
        } catch (Exception e) {
            throw new BaseException(500, "操作失败", e);
        }
    }

    @Override
    public boolean verifyTicketByCode(String verifyCode, String orderId) {
        try {
            //UserTicket userTicket = ticketDao.getUserTicketByVerifyCode(verifyCode);
            UserTicket userTicket = ticketDao.getTicketByOrderId(Integer.valueOf(orderId));
            if (userTicket != null && userTicket.getStatus() != null && userTicket.getStatus().intValue() == 0) {
                ticketDao.updateUserTicketStatus(userTicket.getId(), "1", verifyCode);
                // orderDao.updateOrderStatus(Integer.valueOf(orderId), "verified", "");
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new BaseException(500, "操作失败", e);
        }
    }

    @Override
    public List<UserTicket> getVerifiedUserTickets(int userId) {
        return ticketDao.getVerifiedUserTickets(userId);
    }

    @Override
    public void decreaseTicketStock(int ticketId, int quantity) {
        try {
            // 检查库存是否足够
            Ticket ticket = ticketDao.getTicketById(ticketId);
            if (ticket == null) {
                throw new RuntimeException("票务不存在");
            }
            if (ticket.getRemainingQuantity() < quantity) {
                throw new RuntimeException("库存不足");
            }
            // 扣减库存
            ticketDao.decreaseRemainingQuantity(ticketId, quantity);
        } catch (Exception e) {
            throw new BaseException(500, "操作失败", e);
        }
    }
}