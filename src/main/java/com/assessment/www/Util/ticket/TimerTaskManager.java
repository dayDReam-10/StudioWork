package com.assessment.www.Util.ticket;

import com.assessment.www.Service.ticket.OrderService;
import com.assessment.www.Service.ticket.OrderServiceImpl;
import com.assessment.www.dao.ticket.ExhibitionDao;
import com.assessment.www.dao.ticket.ExhibitionDaoImpl;
import com.assessment.www.dao.ticket.OrderDao;
import com.assessment.www.dao.ticket.OrderDaoImpl;
import com.assessment.www.dao.ticket.UserTicketDao;
import com.assessment.www.dao.ticket.UserTicketDaoImpl;
import com.assessment.www.po.ticket.Exhibition;
import com.assessment.www.po.ticket.Order;
import com.assessment.www.po.ticket.UserTicket;

import java.util.Calendar;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

//定时任务管理器负责处理订单超时自动取消和门票超时未核销的业务逻辑
public class TimerTaskManager {
    // 订单超时时间：30分钟
    private static final long ORDER_TIMEOUT = 30 * 60 * 1000; // 30分钟
    private static final long AUTO_REFUND_TIMEOUT = 30L * 24 * 60 * 60 * 1000; // 30天
    private static TimerTaskManager instance;
    private OrderService orderService;
    private OrderDao orderDao;
    private ExhibitionDao exhibitionDao;
    private UserTicketDao userTicketDao;
    private Timer timer;
    private boolean orderTimeoutTaskStarted;
    private boolean exhibitionTimeoutTaskStarted;

    //单例模式获取实例
    public static synchronized TimerTaskManager getInstance() {
        if (instance == null) {
            instance = new TimerTaskManager();
        }
        return instance;
    }

    //私有构造方法
    private TimerTaskManager() {
        this.orderService = new OrderServiceImpl();
        this.orderDao = new OrderDaoImpl();
        this.exhibitionDao = new ExhibitionDaoImpl();
        this.userTicketDao = new UserTicketDaoImpl();
        this.timer = new Timer("TimerTaskManager-Timer", true);
    }

    //启动订单超时检查任务 每5分钟执行一次，检查所有未支付的订单
    public synchronized void startOrderTimeoutCheck() {
        if (orderTimeoutTaskStarted) {
            return;
        }
        orderTimeoutTaskStarted = true;
        TimerTask orderTask = new TimerTask() {
            @Override
            public void run() {
                checkUnpaidOrders();
                System.out.println("启动定时任务运行订单超时检查完成");
            }
        };
        timer.schedule(orderTask, 0, 5 * 60 * 1000); // 每5分钟检查一次
    }

    //启动门票过期检查任务 每天执行一次，检查所有已过期但未核销的门票
    public synchronized void startExhibitionTimeoutCheck() {
        if (exhibitionTimeoutTaskStarted) {
            return;
        }
        exhibitionTimeoutTaskStarted = true;
        TimerTask exhibitionTask = new TimerTask() {
            @Override
            public void run() {
                checkUnverifiedTickets();
            }
        };
        // 设置每天凌晨2点执行
        long oneDay = 24 * 60 * 60 * 1000;
        long delay = calculateNext2AM();
        timer.schedule(exhibitionTask, delay, oneDay);
    }

    //计算距离下一个凌晨2点的时间
    private long calculateNext2AM() {
        long now = System.currentTimeMillis();
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(now);
        calendar.set(Calendar.HOUR_OF_DAY, 2);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        if (calendar.getTimeInMillis() <= now) {
            calendar.add(Calendar.DAY_OF_MONTH, 1);
        }
        return calendar.getTimeInMillis() - now;
    }

    //检查超时未支付的订单并自动取消
    private void checkUnpaidOrders() {
        try {
            // 获取所有订单
            List<Order> allOrders = orderService.getAllOrders();
            for (Order order : allOrders) {
                if ("pending".equals(order.getStatus())) {
                    long timeDiff = System.currentTimeMillis() - order.getCreateTime().getTime();
                    if (timeDiff > ORDER_TIMEOUT) {
                        // 超过30分钟，自动取消订单
                        cancelUnpaidOrder(order);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //取消超时未支付的订单
    private void cancelUnpaidOrder(Order order) {
        try {
            // 更新订单状态为"cancelled"
            orderService.cancelOrder(order.getId());
            sendCancelNotification(order);
            processOrderCancellation(order);
        } catch (Exception e) {
            System.err.println("取消订单失败，订单ID: " + order.getId() + ", 错误: " + e.getMessage());
            e.printStackTrace();
        }
    }

    //发送订单取消通知
    private void sendCancelNotification(Order order) {
        System.out.println("订单取消通知已发送，用户ID: " + order.getUserId() +
                ", 订单ID: " + order.getId() +
                ", 展览名称: " + order.getExhibitionName());
    }

    //处理订单取消后的业务逻辑
    private void processOrderCancellation(Order order) {
        System.out.println("订单ID: " + order.getId() + " 已处理取消后的业务逻辑");
    }

    //检查超时未核销的门票
    private void checkUnverifiedTickets() {
        try {
            List<Order> paidOrders = orderService.getAllOrders();
            long now = System.currentTimeMillis();
            for (Order order : paidOrders) {
                if (order == null || !"paid".equals(order.getStatus())) {
                    continue;
                }
                UserTicket userTicket = userTicketDao.getUserTicketByorderid(order.getId());
                if (userTicket == null || userTicket.getId() == null || userTicket.getStatus() == null) {
                    continue;
                }
                Exhibition exhibition = exhibitionDao.getExhibitionById(order.getExhibitionId());
                if (exhibition == null || exhibition.getEndTime() == null) {
                    continue;
                }
                long endTime = exhibition.getEndTime().getTime();
                if (now <= endTime) {
                    continue;
                }

                // 第一次超过展览时间：标记为已失效、发送通知、发放补偿券
                if (userTicket.getStatus() == 0) {
                    markExpiredTicket(order, userTicket, exhibition);
                }

                // 超过展览结束 30 天：自动退款
                if (shouldAutoRefund(endTime, now)) {
                    processAutoRefund(order, exhibition);
                }
            }
        } catch (Exception e) {
            System.err.println("检查门票超时时发生错误: " + e.getMessage());
            e.printStackTrace();
        }
    }

    //发送门票过期通知
    private void sendExpiredNotification(Order order, Exhibition exhibition) {
        System.out.println("门票过期通知已发送，用户ID: " + order.getUserId() +
                ", 订单ID: " + order.getId() +
                ", 展览名称: " + exhibition.getName() +
                ", 展览结束时间: " + exhibition.getEndTime());
    }

    // 标记未核销门票已失效，并执行一次性后续业务
    private void markExpiredTicket(Order order, UserTicket userTicket, Exhibition exhibition) {
        try {
            sendExpiredNotification(order, exhibition);
            userTicketDao.updateUserTicketStatus(userTicket.getId(), "3");
            issueCompensationCoupon(order);
        } catch (Exception e) {
            System.err.println("标记过期门票失败，订单ID: " + order.getId() + ", 错误: " + e.getMessage());
            e.printStackTrace();
        }
    }

    //判断是否自动退款
    private boolean shouldAutoRefund(long exhibitionEndTime, long now) {
        return now - exhibitionEndTime > AUTO_REFUND_TIMEOUT;
    }

    //自动退款处理
    private void processAutoRefund(Order order, Exhibition exhibition) {
        try {
            String payway = order.getPayway() == null ? "" : order.getPayway();
            orderDao.updateOrderStatus(order.getId(), "refunding", payway);
            if (orderService.refundOrder(order.getId())) {
                System.out.println("门票自动退款已完成，用户ID: " + order.getUserId() +
                        ", 订单ID: " + order.getId() +
                        ", 展览名称: " + exhibition.getName());
            } else {
                System.out.println("门票自动退款未执行，订单状态不符合要求，订单ID: " + order.getId());
            }
        } catch (Exception e) {
            System.err.println("自动退款失败，订单ID: " + order.getId() + ", 错误: " + e.getMessage());
            e.printStackTrace();
        }
    }

    //发放补偿券
    private void issueCompensationCoupon(Order order) {
        System.out.println("已为用户ID: " + order.getUserId() +
                ", 订单ID: " + order.getId() +
                " 生成补偿券发放任务（后续可接入优惠券服务）。");
    }

    //启动所有定时任务
    public synchronized void startAllTasks() {
        startOrderTimeoutCheck();
        startExhibitionTimeoutCheck();
    }

    //关闭定时任务
    public synchronized void shutdown() {
        if (timer != null) {
            timer.cancel();
            timer.purge();
        }
        orderTimeoutTaskStarted = false;
        exhibitionTimeoutTaskStarted = false;
    }

    //单独启动订单超时任务
    public void scheduleOrderTimeoutTask() {
        startOrderTimeoutCheck();
    }

    //单独启动门票过期任务
    public void schedulePostEventTask() {
        startExhibitionTimeoutCheck();
    }
}