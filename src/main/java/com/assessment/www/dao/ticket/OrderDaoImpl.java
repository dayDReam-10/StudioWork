package com.assessment.www.dao.ticket;

import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ticket.Order;
import com.assessment.www.po.ticket.OrderItem;
import com.assessment.www.Util.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class OrderDaoImpl implements OrderDao {
    @Override
    public void createOrder(Order order) {
        String sql = "INSERT INTO orders (user_id, exhibition_id, total_amount, status, create_time) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setInt(1, order.getUserId());
            pstmt.setInt(2, order.getExhibitionId());
            pstmt.setDouble(3, order.getTotalAmount());
            pstmt.setString(4, order.getStatus());
            pstmt.setTimestamp(5, order.getCreateTime());
            pstmt.executeUpdate();
            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    order.setId(generatedKeys.getInt(1));
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
    }

    @Override
    public void createOrderItem(OrderItem orderItem) {
        String sql = "INSERT INTO order_item (order_id, ticket_id, quantity, price) VALUES (?, ?, ?, ?)";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, orderItem.getOrderId());
            pstmt.setInt(2, orderItem.getTicketId());
            pstmt.setInt(3, orderItem.getQuantity());
            pstmt.setDouble(4, orderItem.getPrice());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
    }

    @Override
    public List<Order> getUserOrders(Integer userId, String status, int page, int pagesize) {
        List<Order> orders = new ArrayList<>();
        int offset = (page - 1) * pagesize;
        String sql = "SELECT * FROM orders ";
        if (userId.intValue() > 0) {
            sql += " WHERE user_id = ?  ";
        } else {
            sql += " WHERE user_id != ?  ";
        }
        if (status != null && status != "") {
            sql += " and status='" + status + "' ";
        }
        sql += " ORDER BY create_time DESC ";
        if (offset >= 0) {
            sql += " LIMIT " + offset + "," + pagesize + " ";
        }
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setId(rs.getInt("id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setExhibitionId(rs.getInt("exhibition_id"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    order.setStatus(rs.getString("status"));
                    order.setCreateTime(rs.getTimestamp("create_time"));
                    order.setPayTime(rs.getTimestamp("pay_time"));
                    order.setCancelTime(rs.getTimestamp("cancel_time"));
                    order.setRefundTime(rs.getTimestamp("refund_time"));
                    orders.add(order);
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
        return orders;
    }

    @Override
    public Order getOrderById(Integer orderId) {
        Order order = null;
        String sql = "SELECT * FROM orders WHERE id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, orderId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    order = new Order();
                    order.setId(rs.getInt("id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setExhibitionId(rs.getInt("exhibition_id"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    order.setStatus(rs.getString("status"));
                    order.setCreateTime(rs.getTimestamp("create_time"));
                    order.setPayTime(rs.getTimestamp("pay_time"));
                    order.setCancelTime(rs.getTimestamp("cancel_time"));
                    order.setRefundTime(rs.getTimestamp("refund_time"));
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
        return order;
    }

    @Override
    public void updateOrderStatus(Integer orderId, String status, String payway) {
        String sql = "UPDATE orders SET status = ?,payway=?";
        if ("paid".equals(status)) {
            sql += ",pay_time=now() ";
        }else if ("refunded".equals(status)) {
            sql += ",refund_time=now() ";
        }
        sql += " WHERE id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setString(2, payway);
            pstmt.setInt(3, orderId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
    }


    @Override
    public void generateVerifyCode(Integer orderItemId, String verifyCode) {
        String sql = "UPDATE order_item SET verify_code = ? WHERE id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, verifyCode);
            pstmt.setInt(2, orderItemId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
    }

    @Override
    public OrderItem getOrderItemById(Integer orderItemId) {
        OrderItem orderItem = null;
        String sql = "SELECT * FROM order_item WHERE order_id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, orderItemId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    orderItem = new OrderItem();
                    orderItem.setId(rs.getInt("id"));
                    orderItem.setOrderId(rs.getInt("order_id"));
                    orderItem.setTicketId(rs.getInt("ticket_id"));
                    orderItem.setQuantity(rs.getInt("quantity"));
                    orderItem.setPrice(rs.getDouble("price"));
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
        return orderItem;
    }

    @Override
    public void cancelOrder(Integer orderId) {
        String sql = "UPDATE orders SET status = 'cancelled', cancel_time = ? WHERE id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            pstmt.setInt(2, orderId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
    }

    @Override
    public void refundOrder(Integer orderId) {
        String sql = "UPDATE orders SET status = 'refunded', refund_time = ? WHERE id = ?";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            pstmt.setInt(2, orderId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
    }

    @Override
    public List<Order> getAllOrders() {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM orders ORDER BY create_time DESC";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Order order = new Order();
                order.setId(rs.getInt("id"));
                order.setUserId(rs.getInt("user_id"));
                order.setExhibitionId(rs.getInt("exhibition_id"));
                order.setTotalAmount(rs.getDouble("total_amount"));
                order.setStatus(rs.getString("status"));
                order.setCreateTime(rs.getTimestamp("create_time"));
                order.setPayTime(rs.getTimestamp("pay_time"));
                order.setCancelTime(rs.getTimestamp("cancel_time"));
                order.setRefundTime(rs.getTimestamp("refund_time"));
                orders.add(order);
            }
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
        return orders;
    }

    @Override
    public int getTotalOrderCount(int userid, String status) {
        int count = 0;
        String sql = "SELECT COUNT(*) as total_count FROM orders ";
        if (userid > 0) {
            sql += " WHERE user_id = " + userid;
        } else {
            sql += " WHERE user_id != " + userid;
        }
        if (status != null && status != "") {
            sql += " and status='" + status + "' ";
        }
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt("total_count");
            }
        } catch (SQLException e) {
            throw new BaseException(500, "查询用户订单数失败", e);
        }
        return count;
    }

    @Override
    public double getTotalOrderAmount() {
        double amount = 0;
        String sql = "SELECT SUM(total_amount) as total_amount FROM orders";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                amount = rs.getDouble("total_amount");
            }
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
        return amount;
    }

    @Override
    public int getNewOrdersCountThisMonth() {
        int count = 0;
        String sql = "SELECT COUNT(*) as total_count FROM orders WHERE YEAR(create_time) = YEAR(NOW()) AND MONTH(create_time) = MONTH(NOW())";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt("total_count");
            }
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
        return count;
    }

    @Override
    public double getSalesAmountThisMonth() {
        double amount = 0;
        String sql = "SELECT SUM(total_amount) as total_amount FROM orders WHERE YEAR(create_time) = YEAR(NOW()) AND MONTH(create_time) = MONTH(NOW())";
        try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                amount = rs.getDouble("total_amount");
            }
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
        return amount;
    }

    @Override
    public int getUserTicketCountByTicket(int userId, int ticketId) {
        String sql = "SELECT COALESCE(SUM(oi.quantity), 0) FROM order_item oi " +
                "JOIN orders o ON oi.order_id = o.id " +
                "WHERE o.user_id = ? AND oi.ticket_id = ? " +
                "AND o.status IN ('pending', 'paid')";  // 只统计未取消/未退款的订单
        try (Connection conn = utils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, ticketId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new BaseException(500, "操作失败", e);
        }
        return 0;
    }
}