package com.assessment.www.Service.ticket;

import com.assessment.www.po.ticket.Order;
import com.assessment.www.po.ticket.OrderItem;

import java.util.List;

public interface OrderService {
    // 创建订单
    Order createOrder(int userId, int exhibitionId, List<OrderItem> orderItems);

    // 支付订单
    boolean payOrder(int orderId);

    // 取消订单
    boolean cancelOrder(int orderId);

    // 确认申请退款退款订单
    boolean refundOrder(int orderId);

    // 申请退款订单
    boolean refunddingOrder(int orderId);

    // 获取用户订单列表
    List<Order> getUserOrders(int userId, String status, int page, int pagesize);

    // 获取订单详情
    Order getOrderById(int orderId);

    // 获取所有订单（管理端）
    List<Order> getAllOrders();

    // 获取订单统计信息
    int getTotalOrderCount(int userid, String status);

    // 获取订单总金额
    double getTotalOrderAmount();

    // 生成核销码
    boolean generateVerifyCode(int orderItemId, String verifyCode);

    // 获取订单项
    OrderItem getOrderItemById(int orderItemId);

    int getUserTicketCountByTicket(Integer id, int ticketId);

    // 获取本月新增订单数
    int getNewOrdersCountThisMonth();

    // 获取本月销售额
    double getSalesAmountThisMonth();

    // 获取已核销门票数量
    int getVerifiedTicketCount();

    // 获取已退款门票数量
    int getRefundedTicketCount();

    boolean changeOrder(String orderId, String paymentMethod);

    //查询订单项目信息
    OrderItem getOrderItemsByOrderId(int orderId);

    // 获取订单状态分布
    int[] getOrderStatusDistribution();

    // 获取指定时间范围内的销售趋势数据
    List<Object[]> getSalesTrendData(String timeRange);

    // 根据漫展ID获取订单
    List<Order> getOrdersByExhibitionId(int exhibitionId);
}