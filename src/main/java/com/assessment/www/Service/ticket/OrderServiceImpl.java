package com.assessment.www.Service.ticket;

import com.assessment.www.Util.ticket.TicketLock;
import com.assessment.www.Util.ticket.TicketWebSocketEndpoint;
import com.assessment.www.Util.utils;
import com.assessment.www.dao.ticket.OrderDao;
import com.assessment.www.dao.ticket.OrderDaoImpl;
import com.assessment.www.dao.ticket.TicketDao;
import com.assessment.www.dao.ticket.TicketDaoImpl;
import com.assessment.www.dao.ticket.UserTicketDao;
import com.assessment.www.dao.ticket.UserTicketDaoImpl;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ticket.Order;
import com.assessment.www.po.ticket.OrderItem;
import com.assessment.www.po.ticket.Ticket;
import com.assessment.www.po.ticket.UserTicket;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.locks.Lock;

public class OrderServiceImpl implements OrderService {
    private OrderDao orderDao;
    private TicketDao ticketDao;
    private UserTicketDao userTicketDao;

    public OrderServiceImpl() {
        this.orderDao = new OrderDaoImpl();
        this.ticketDao = new TicketDaoImpl();
        this.userTicketDao = new UserTicketDaoImpl();
    }

    @Override
    public Order createOrder(int userId, int exhibitionId, List<OrderItem> orderItems) {
        Connection conn = null;
        try {
            conn = utils.getConnection();
            conn.setAutoCommit(false);
            // 创建订单主记录
            Order order = new Order();
            order.setUserId(userId);
            order.setExhibitionId(exhibitionId);
            order.setStatus("pending");
            order.setCreateTime(new java.sql.Timestamp(System.currentTimeMillis()));
            double totalAmount = 0;
            for (OrderItem item : orderItems) {
                totalAmount += item.getPrice() * item.getQuantity();
            }
            order.setTotalAmount(totalAmount);
            orderDao.createOrder(order);
            // 对每个票项进行处理（加锁 + 一人一票校验 + 扣库存）
            for (OrderItem item : orderItems) {
                // 加锁保证库存安全
                Lock lock = TicketLock.getLock(item.getTicketId());
                lock.lock();
                try {
                    // 一人一票校验：检查用户已购买未取消/未退票的同种票数量
                    int alreadyBought = orderDao.getUserTicketCountByTicket(userId, item.getTicketId());
                    if (alreadyBought + item.getQuantity() > 1) { // 限制每人最多买1张
                        throw new BaseException(400, "每人限购1张，您已购买过该票种");
                    }
                    Ticket ticket = ticketDao.getTicketById(item.getTicketId());
                    int remaining = ticket.getRemainingQuantity() - item.getQuantity();
                    if (remaining < 0) {
                        throw new BaseException(400, "票务库存不足");
                    }
                    ticketDao.updateTicketRemainingQuantity(item.getTicketId(), remaining);
                    TicketWebSocketEndpoint.broadcastTicketUpdate(
                            String.valueOf(exhibitionId),
                            item.getTicketId(),
                            remaining
                    );
                } finally {
                    lock.unlock();
                }
                // 创建订单项（关联订单ID）
                item.setOrderId(order.getId());
                orderDao.createOrderItem(item);
                // 创建用户票务记录
                UserTicket userTicket = new UserTicket();
                userTicket.setUserId(userId);
                userTicket.setOrderId(order.getId());
                userTicket.setTicketId(item.getTicketId());
                userTicket.setStatus(0);
                userTicket.setExhibitionId(exhibitionId);
                userTicketDao.createUserTicket(userTicket);
            }
            conn.commit(); // 所有操作成功，提交事务
            return order;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback(); // 发生异常回滚事务
                } catch (SQLException ex) {
                    throw new BaseException(500, "回滚事务失败", ex);
                }
            }
            throw new BaseException(500, "创建订单失败: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                }
            }
        }
    }

    @Override
    public boolean payOrder(int orderId) {
        try {
            Order order = orderDao.getOrderById(orderId);
            if (order == null || !"pending".equals(order.getStatus())) {
                return false;
            }
            orderDao.updateOrderStatus(orderId, "paid", "");
            order.setPayTime(new java.sql.Timestamp(System.currentTimeMillis()));
            return true;
        } catch (Exception e) {
            throw new BaseException(500, "支付订单失败", e);
        }
    }

    @Override
    public boolean cancelOrder(int orderId) {
        Connection conn = null;
        try {
            conn = utils.getConnection();
            conn.setAutoCommit(false);
            //查询订单信息
            Order order = orderDao.getOrderById(orderId);
            if (order == null || !"pending".equals(order.getStatus())) {
                return false;
            }
            //获取该订单下的所有订单项
            OrderItem orderItems = orderDao.getOrderItemById(orderId);
            if (orderItems == null) {
                orderDao.updateOrderStatus(orderId, "cancelled", "");
                conn.commit();
                return true;
            }
            // 加锁，保证并发安全（与创建订单时的锁一致）
            Lock lock = TicketLock.getLock(orderItems.getTicketId());
            lock.lock();
            try {
                // 恢复票务库存
                Ticket ticket = ticketDao.getTicketById(orderItems.getTicketId());
                int newRemaining = ticket.getRemainingQuantity() + orderItems.getQuantity();
                ticketDao.updateTicketRemainingQuantity(orderItems.getTicketId(), newRemaining);
                // 发送 WebSocket 广播更新前端库存显示
                TicketWebSocketEndpoint.broadcastTicketUpdate(
                        String.valueOf(order.getExhibitionId()),
                        orderItems.getTicketId(),
                        newRemaining
                );
            } finally {
                lock.unlock();
            }
            // 更新用户票务记录状态为“已取消”
            UserTicket userTicket = userTicketDao.getUserTicketByorderid(orderItems.getOrderId());
            if (userTicket != null) {
                userTicketDao.updateUserTicketStatus(userTicket.getId(),"3");
            }
            // 更新订单状态为 cancelled
            orderDao.updateOrderStatus(orderId, "cancelled", "");
            order.setCancelTime(new java.sql.Timestamp(System.currentTimeMillis()));
            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    throw new BaseException(500, "回滚事务失败", ex);
                }
            }
            throw new BaseException(500, "取消订单失败: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                }
            }
        }
    }

    @Override
    public boolean refundOrder(int orderId) {
        Connection conn = null;
        try {
            conn = utils.getConnection();
            conn.setAutoCommit(false);
            //查询订单信息
            Order order = orderDao.getOrderById(orderId);
            if (order == null || !"refunding".equals(order.getStatus())) {
                return false;
            }
            //获取该订单下的所有订单项
            OrderItem orderItems = orderDao.getOrderItemById(orderId);
            if (orderItems == null) {
                orderDao.updateOrderStatus(orderId, "refunded", "");
                conn.commit();
                return true;
            }
            // 加锁，保证并发安全（与创建订单时的锁一致）
            Lock lock = TicketLock.getLock(orderItems.getTicketId());
            lock.lock();
            try {
                // 恢复票务库存
                Ticket ticket = ticketDao.getTicketById(orderItems.getTicketId());
                int newRemaining = ticket.getRemainingQuantity() + orderItems.getQuantity();
                ticketDao.updateTicketRemainingQuantity(orderItems.getTicketId(), newRemaining);
                // 发送 WebSocket 广播更新前端库存显示
                TicketWebSocketEndpoint.broadcastTicketUpdate(
                        String.valueOf(order.getExhibitionId()),
                        orderItems.getTicketId(),
                        newRemaining
                );
            } finally {
                lock.unlock();
            }
            UserTicket userTicket = userTicketDao.getUserTicketByorderid(orderItems.getOrderId());
            if (userTicket != null) {
                userTicketDao.updateUserTicketStatus(userTicket.getId(),"2");
            }
            // 更新订单状态为 refunded
            orderDao.updateOrderStatus(orderId, "refunded", "");
            order.setRefundTime(new java.sql.Timestamp(System.currentTimeMillis()));
            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    throw new BaseException(500, "回滚事务失败", ex);
                }
            }
            throw new BaseException(500, "退票订单失败: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                }
            }
        }
    }

    @Override
    public boolean refunddingOrder(int orderId) {
        try {
            Order order = orderDao.getOrderById(orderId);
            if (order == null || !"paid".equals(order.getStatus())) {
                return false;
            }
            orderDao.updateOrderStatus(orderId, "refunding", "");
            order.setRefundTime(new java.sql.Timestamp(System.currentTimeMillis()));
            return true;
        } catch (Exception e) {
            throw new BaseException(500, "退票订单失败", e);
        }
    }

    @Override
    public List<Order> getUserOrders(int userId, String status, int page, int pagesize) {
        return orderDao.getUserOrders(userId, status, page, pagesize);
    }

    @Override
    public Order getOrderById(int orderId) {
        return orderDao.getOrderById(orderId);
    }

    @Override
    public List<Order> getAllOrders() {
        return orderDao.getAllOrders();
    }

    @Override
    public int getTotalOrderCount(int userid, String status) {
        return orderDao.getTotalOrderCount(userid, status);
    }

    @Override
    public double getTotalOrderAmount() {
        return orderDao.getTotalOrderAmount();
    }

    @Override
    public boolean generateVerifyCode(int orderItemId, String verifyCode) {
        orderDao.generateVerifyCode(orderItemId, verifyCode);
        return true;
    }

    @Override
    public OrderItem getOrderItemById(int orderItemId) {
        return orderDao.getOrderItemById(orderItemId);
    }


    @Override
    public int getUserTicketCountByTicket(Integer id, int ticketId) {
        return orderDao.getUserTicketCountByTicket(id, ticketId);
    }

    @Override
    public int getNewOrdersCountThisMonth() {
        return orderDao.getNewOrdersCountThisMonth();
    }

    @Override
    public double getSalesAmountThisMonth() {
        return orderDao.getSalesAmountThisMonth();
    }

    @Override
    public int getVerifiedTicketCount() {
        String sql = "SELECT COUNT(*) as count FROM orders WHERE status = 'verified'";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            throw new BaseException(500, "获取已核销门票数量失败", e);
        }
        return 0;
    }

    @Override
    public int getRefundedTicketCount() {
        String sql = "SELECT COUNT(*) as count FROM orders WHERE status = 'refunded'";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            throw new BaseException(500, "获取已退款门票数量失败", e);
        }
        return 0;
    }

    @Override
    public boolean changeOrder(String orderId, String paymentMethod) {
        orderDao.updateOrderStatus(Integer.valueOf(orderId), "paid", paymentMethod);
        return true;
    }

    @Override
    public OrderItem getOrderItemsByOrderId(int orderId) {
        return orderDao.getOrderItemById(orderId);
    }

    @Override
    public int[] getOrderStatusDistribution() {
        int[] distribution = new int[4]; // [pending, paid, verified, cancelled]
        String orderSql = "SELECT status, COUNT(*) as cnt FROM orders WHERE status IN ('pending', 'paid') GROUP BY status";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(orderSql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("status");
                int cnt = rs.getInt("cnt");
                if ("pending".equals(status)) distribution[0] = cnt;
                else if ("paid".equals(status)) distribution[1] = cnt;
            }
        } catch (SQLException e) {
            throw new BaseException(500, "获取订单状态分布失败", e);
        }

        String verifiedSql = "SELECT COUNT(DISTINCT id) as cnt FROM orders WHERE status = 'verified'";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(verifiedSql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                distribution[2] = rs.getInt("cnt"); // verified
            }
        } catch (SQLException e) {
            throw new BaseException(500, "获取已核销订单数失败", e);
        }

         String cancelledSql = "SELECT COUNT(*) as cnt FROM orders WHERE status = 'cancelled'";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(cancelledSql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                distribution[3] = rs.getInt("cnt");
            }
        } catch (SQLException e) {
            throw new BaseException(500, "获取已取消订单数失败", e);
        }

        return distribution;
    }

    @Override
    public List<Object[]> getSalesTrendData(String timeRange) {
        String sql = "";
        switch (timeRange) {
            case "day":
                sql = "SELECT HOUR(create_time) as period, COUNT(*) as order_count, SUM(total_amount) as amount " +
                        "FROM orders WHERE DATE(create_time) = CURDATE() " +
                        "GROUP BY HOUR(create_time) ORDER BY period";
                break;
            case "week":
                sql = "SELECT DAYOFWEEK(create_time) - 1 as period, COUNT(*) as order_count, SUM(total_amount) as amount " +
                        "FROM orders WHERE WEEK(create_time) = WEEK(NOW()) " +
                        "GROUP BY DAYOFWEEK(create_time) - 1 ORDER BY period";
                break;
            case "month":
                sql = "SELECT DAY(create_time) as period, COUNT(*) as order_count, SUM(total_amount) as amount " +
                        "FROM orders WHERE MONTH(create_time) = MONTH(NOW()) AND YEAR(create_time) = YEAR(NOW()) " +
                        "GROUP BY DAY(create_time) ORDER BY period";
                break;
            case "year":
                sql = "SELECT MONTH(create_time) as period, COUNT(*) as order_count, SUM(total_amount) as amount " +
                        "FROM orders WHERE YEAR(create_time) = YEAR(NOW()) " +
                        "GROUP BY MONTH(create_time) ORDER BY period";
                break;
            default:
                sql = "SELECT CONCAT(LPAD(HOUR(create_time), 2, '0'), ':00') as period, " +
                        "COUNT(*) as order_count, SUM(total_amount) as amount " +
                        "FROM orders WHERE DATE(create_time) = CURDATE() " +
                        "GROUP BY HOUR(create_time) ORDER BY HOUR(create_time)";
        }
        List<Object[]> data = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                // 返回 [标签字符串, 订单数, 总金额]
                data.add(new Object[]{
                        rs.getString("period"),
                        rs.getInt("order_count"),
                        rs.getDouble("amount")
                });
            }
        } catch (SQLException e) {
            throw new BaseException(500, "获取销售趋势数据失败", e);
        }
        return data;
    }

    @Override
    public List<Order> getOrdersByExhibitionId(int exhibitionId) {
        String sql = "SELECT o.*,u.username FROM orders o INNER JOIN users u ON o.user_id = u.id WHERE o.exhibition_id = ?";
        List<Order> orders = new ArrayList<>();
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, exhibitionId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setId(rs.getInt("id"));
                    order.setUserId(rs.getInt("user_id"));
                    order.setExhibitionId(rs.getInt("exhibition_id"));
                    order.setStatus(rs.getString("status"));
                    order.setTotalAmount(rs.getDouble("total_amount"));
                    order.setCreateTime(rs.getTimestamp("create_time"));
                    order.setPayTime(rs.getTimestamp("pay_time"));
                    order.setCancelTime(rs.getTimestamp("cancel_time"));
                    order.setRefundTime(rs.getTimestamp("refund_time"));
                    order.setUserName(rs.getString("username"));
                    orders.add(order);
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "获取漫展订单失败", e);
        }
        return orders;
    }
}