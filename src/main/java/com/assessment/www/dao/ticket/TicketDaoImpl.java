package com.assessment.www.dao.ticket;

import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ticket.Ticket;
import com.assessment.www.Util.utils;
import com.assessment.www.po.ticket.UserTicket;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TicketDaoImpl implements TicketDao {
    @Override
    public List<Ticket> getTicketsByExhibitionId(Integer exhibitionId) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM tickets WHERE exhibition_id = ? ORDER BY type, price";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, exhibitionId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Ticket ticket = new Ticket();
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
                    tickets.add(ticket);
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return tickets;
    }

    @Override
    public Ticket getTicketById(Integer id) {
        Ticket ticket = null;
        String sql = "SELECT * FROM tickets WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
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

    @Override
    public boolean updateTicketRemainingQuantity(Integer ticketId, Integer remainingQuantity) {
        String sql = "UPDATE tickets SET remaining_quantity = ? WHERE id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, remainingQuantity);
            pstmt.setInt(2, ticketId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return true;
    }

    @Override
    public void addTicket(Ticket ticket) {
        String sql = "INSERT INTO tickets (exhibition_id, name, price, total_quantity, remaining_quantity, type, description, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, ticket.getExhibitionId());
            pstmt.setString(2, ticket.getName());
            pstmt.setDouble(3, ticket.getPrice());
            pstmt.setInt(4, ticket.getTotalQuantity());
            pstmt.setInt(5, ticket.getRemainingQuantity());
            pstmt.setString(6, ticket.getType());
            pstmt.setString(7, ticket.getDescription());
            pstmt.setString(8, ticket.getStatus());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public void updateTicket(Ticket ticket) {
        String sql = "UPDATE tickets SET name = ?, price = ?, total_quantity = ?, remaining_quantity = ?, type = ?, description = ?, status = ? WHERE id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, ticket.getName());
            pstmt.setDouble(2, ticket.getPrice());
            pstmt.setInt(3, ticket.getTotalQuantity());
            pstmt.setInt(4, ticket.getRemainingQuantity());
            pstmt.setString(5, ticket.getType());
            pstmt.setString(6, ticket.getDescription());
            pstmt.setString(7, ticket.getStatus());
            pstmt.setInt(8, ticket.getId());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public boolean decreaseRemainingQuantity(Integer ticketId, Integer quantity) {
        String sql = "UPDATE tickets SET remaining_quantity = remaining_quantity - ? WHERE id = ? AND remaining_quantity >= ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, quantity);
            pstmt.setInt(2, ticketId);
            pstmt.setInt(3, quantity);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new BaseException(500, "扣减库存失败", e);
        }
    }

    @Override
    public List<UserTicket> getUserTickets(int userId) {
        return null;
    }

    @Override
    public void updateUserTicketStatus(int userTicketId, String used,String code) {
        int status=Integer.valueOf(used).intValue();
        String sql = "UPDATE user_ticket SET status = ?,use_time=now(),verify_code=? WHERE id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, status);
            pstmt.setString(2, code);
            pstmt.setInt(3, userTicketId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
           throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public UserTicket getUserTicketByVerifyCode(String verifyCode) {
        return null;
    }

    @Override
    public List<UserTicket> getVerifiedUserTickets(int userId) {
        return null;
    }

    @Override
    public UserTicket getTicketByOrderId(Integer oid) {
        UserTicket ticket = null;
        String sql = "SELECT * FROM user_ticket WHERE order_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, oid);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    ticket = new UserTicket();
                    ticket.setId(rs.getInt("id"));
                    ticket.setExhibitionId(rs.getInt("exhibition_id"));
                    ticket.setUserId(rs.getInt("user_id"));
                    ticket.setOrderId(rs.getInt("order_id"));
                    ticket.setTicketId(rs.getInt("ticket_id"));
                    ticket.setStatus(rs.getInt("status"));
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return ticket;
    }
}