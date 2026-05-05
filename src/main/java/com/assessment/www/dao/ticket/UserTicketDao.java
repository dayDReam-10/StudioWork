package com.assessment.www.dao.ticket;

import com.assessment.www.po.ticket.Ticket;
import com.assessment.www.po.ticket.UserTicket;

import java.util.List;

// 用户票务信息处理DAO接口
public interface UserTicketDao {
    // 创建用户票务记录
    void createUserTicket(UserTicket userTicket);

    // 获取用户票务列表
    List<UserTicket> getUserTickets(Integer userId);

    // 更新用户票务状态
    void updateUserTicketStatus(Integer userTicketId, String status);

    // 通过验证码获取用户票务
    UserTicket getUserTicketByVerifyCode(String verifyCode);

    // 获取用户票务详情
    UserTicket getUserTicketById(Integer id);

    // 获取用户核销过的票务
    List<UserTicket> getVerifiedUserTickets(Integer userId);

    UserTicket getUserTicketByorderid(int orderid);

    Ticket getTicketByorderId(Integer orderid);
}