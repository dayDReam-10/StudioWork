package com.assessment.www.Util.ticket;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

//监听器启动任务
@WebListener
public class TimerTaskManagerListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        TimerTaskManager manager = TimerTaskManager.getInstance();
        manager.startAllTasks();        // 启动订单超时检查 + 展览结束后未核销检查
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        TimerTaskManager.getInstance().shutdown();
    }
}