package com.assessment.www.dao.ticket;

import com.assessment.www.po.ticket.Order;
import com.assessment.www.po.ticket.OrderItem;

import java.util.List;

// 订单DAO接口
public interface OrderDao {
    // 创建订单
    void createOrder(Order order);

    // 创建订单项
    void createOrderItem(OrderItem orderItem);

    // 获取用户订单
    List<Order> getUserOrders(Integer userId, String status, int page, int pagesize);

    // 获取订单详情
    Order getOrderById(Integer orderId);

    // 更新订单状态
    void updateOrderStatus(Integer orderId, String status, String payway);

    // 生成核销码
    void generateVerifyCode(Integer orderItemId, String verifyCode);

    // 获取订单项
    OrderItem getOrderItemById(Integer orderItemId);

    // 取消订单
    void cancelOrder(Integer orderId);

    // 退款订单
    void refundOrder(Integer orderId);

    // 获取所有订单
    List<Order> getAllOrders();

    // 获取订单统计信息
    int getTotalOrderCount(int userid, String status);

    // 获取订单总金额
    double getTotalOrderAmount();


    // 获取本月新增订单数
    int getNewOrdersCountThisMonth();

    // 获取本月销售额
    double getSalesAmountThisMonth();

    //查询用户票数
    int getUserTicketCountByTicket(int userId, int ticketId);
}