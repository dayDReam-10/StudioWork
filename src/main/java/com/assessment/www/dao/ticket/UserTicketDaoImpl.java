package com.assessment.www.dao.ticket;

import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ticket.Ticket;
import com.assessment.www.po.ticket.UserTicket;
import com.assessment.www.Util.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserTicketDaoImpl implements UserTicketDao {
    @Override
    public void createUserTicket(UserTicket userTicket) {
        String sql = "INSERT INTO user_ticket (user_id, order_id, ticket_id, status, use_time, verify_code, exhibition_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setInt(1, userTicket.getUserId());
            pstmt.setInt(2, userTicket.getOrderId());
            pstmt.setInt(3, userTicket.getTicketId());
            pstmt.setInt(4, userTicket.getStatus());
            pstmt.setTimestamp(5, userTicket.getUseTime());
            pstmt.setString(6, userTicket.getVerifyCode());
            pstmt.setInt(7, userTicket.getExhibitionId());
            pstmt.executeUpdate();
            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    userTicket.setId(generatedKeys.getInt(1));
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "添加用户售票信息失败", e);
        }
    }

    @Override
    public List<UserTicket> getUserTickets(Integer userId) {
        List<UserTicket> userTickets = new ArrayList<>();
        String sql = "SELECT * FROM user_ticket WHERE user_id = ? ORDER BY create_time DESC";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    UserTicket userTicket = new UserTicket();
                    userTicket.setId(rs.getInt("id"));
                    userTicket.setUserId(rs.getInt("user_id"));
                    userTicket.setOrderId(rs.getInt("order_id"));
                    userTicket.setTicketId(rs.getInt("ticket_id"));
                    userTicket.setStatus(rs.getInt("status"));
                    userTicket.setUseTime(rs.getTimestamp("use_time"));
                    userTicket.setVerifyCode(rs.getString("verify_code"));
                    userTicket.setExhibitionId(rs.getInt("exhibition_id"));
                    userTickets.add(userTicket);
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return userTickets;
    }

    @Override
    public void updateUserTicketStatus(Integer userTicketId, String status) {
        String sql = "UPDATE user_ticket SET status = ? WHERE id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, userTicketId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public UserTicket getUserTicketByVerifyCode(String verifyCode) {
        UserTicket userTicket = null;
        String sql = "SELECT * FROM user_ticket WHERE verify_code = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, verifyCode);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    userTicket = new UserTicket();
                    userTicket.setId(rs.getInt("id"));
                    userTicket.setUserId(rs.getInt("user_id"));
                    userTicket.setOrderId(rs.getInt("order_id"));
                    userTicket.setTicketId(rs.getInt("ticket_id"));
                    userTicket.setStatus(rs.getInt("status"));
                    userTicket.setUseTime(rs.getTimestamp("use_time"));
                    userTicket.setVerifyCode(rs.getString("verify_code"));
                    userTicket.setExhibitionId(rs.getInt("exhibition_id"));
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return userTicket;
    }

    @Override
    public UserTicket getUserTicketById(Integer id) {
        UserTicket userTicket = null;
        String sql = "SELECT * FROM user_ticket WHERE id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    userTicket = new UserTicket();
                    userTicket.setId(rs.getInt("id"));
                    userTicket.setUserId(rs.getInt("user_id"));
                    userTicket.setOrderId(rs.getInt("order_id"));
                    userTicket.setTicketId(rs.getInt("ticket_id"));
                    userTicket.setStatus(rs.getInt("status"));
                    userTicket.setUseTime(rs.getTimestamp("use_time"));
                    userTicket.setVerifyCode(rs.getString("verify_code"));
                    userTicket.setExhibitionId(rs.getInt("exhibition_id"));
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return userTicket;
    }

    @Override
    public List<UserTicket> getVerifiedUserTickets(Integer userId) {
        List<UserTicket> userTickets = new ArrayList<>();
        String sql = "SELECT * FROM user_ticket WHERE user_id = ? AND status = 1 ORDER BY use_time DESC";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    UserTicket userTicket = new UserTicket();
                    userTicket.setId(rs.getInt("id"));
                    userTicket.setUserId(rs.getInt("user_id"));
                    userTicket.setOrderId(rs.getInt("order_id"));
                    userTicket.setTicketId(rs.getInt("ticket_id"));
                    userTicket.setStatus(rs.getInt("status"));
                    userTicket.setUseTime(rs.getTimestamp("use_time"));
                    userTicket.setVerifyCode(rs.getString("verify_code"));
                    userTicket.setExhibitionId(rs.getInt("exhibition_id"));
                    userTickets.add(userTicket);
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return userTickets;
    }

    @Override
    public UserTicket getUserTicketByorderid(int orderid) {
       UserTicket userTicket = new UserTicket();
        String sql = "SELECT * FROM user_ticket WHERE order_id = ? ORDER BY use_time DESC";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, orderid);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    userTicket.setId(rs.getInt("id"));
                    userTicket.setUserId(rs.getInt("user_id"));
                    userTicket.setOrderId(rs.getInt("order_id"));
                    userTicket.setTicketId(rs.getInt("ticket_id"));
                    userTicket.setStatus(rs.getInt("status"));
                    userTicket.setUseTime(rs.getTimestamp("use_time"));
                    userTicket.setVerifyCode(rs.getString("verify_code"));
                    userTicket.setExhibitionId(rs.getInt("exhibition_id"));
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return userTicket;
    }

    @Override
    public Ticket getTicketByorderId(Integer orderid) {
        Ticket ticket = null;
        String sql = "select * from tickets where id=(SELECT ticket_id FROM user_ticket WHERE order_id = ?)";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, orderid);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    ticket = new Ticket();
                    ticket.setId(rs.getInt("id"));
                    ticket.setExhibitionId(rs.getInt("exhibition_id"));
                    ticket.setName(rs.getString("name"));
                    ticket.setPrice(rs.getDouble("price"));
                    ticket.setTotalQuantity(rs.getInt("total_quantity"));
                    ticket.setRemainingQuantity(rs.getInt("remaining_quantity"));
                    ticket.setType(rs.getString("type"));
                    ticket.setDescription(rs.getString("description"));
                    ticket.setStatus(rs.getString("status"));
                    ticket.setCreateTime(rs.getTimestamp("create_time"));
                    ticket.setUpdateTime(rs.getTimestamp("update_time"));
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return ticket;
    }
}