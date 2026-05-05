package com.assessment.www.Util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

//数据库线程池设计类
public class ConnectionPool {
    private static final int INITIAL_POOL_SIZE = 5;
    private static final int MAX_POOL_SIZE = 20;
    private static final String DB_URL = "jdbc:mysql://127.0.0.1:3306/platform";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "1234";
    private static ConnectionPool instance;
    private BlockingQueue<Connection> connectionPool;//阻塞队列用于存放可用的数据库连接。

    private ConnectionPool() {
        connectionPool = new ArrayBlockingQueue<>(MAX_POOL_SIZE);
        initializeConnectionPool();
    }

    //初始化实例
    public static synchronized ConnectionPool getInstance() {
        if (instance == null) {
            instance = new ConnectionPool();
        }
        return instance;
    }

    //初始化连接池，创建 5 个连接并放入阻塞队列
    private void initializeConnectionPool() {
        try {
            for (int i = 0; i < INITIAL_POOL_SIZE; i++) {
                connectionPool.offer(createNewConnection());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private Connection createNewConnection() throws SQLException {
        System.out.println("mysql数据库连接信息为" + DB_URL);
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    //从连接池获取一个可用连接
    public Connection getConnection() throws SQLException {
        try {
            Connection connection = connectionPool.poll();
            if (connection == null) {
                if (connectionPool.size() < MAX_POOL_SIZE) {
                    connection = createNewConnection();
                } else {
                    connection = connectionPool.take();
                }
            }
            return connection;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new SQLException("获取数据库连接超时", e);
        }
    }

    // 释放连接，将连接重新放回阻塞队列供其他线程复用
    public void releaseConnection(Connection connection) {
        if (connection != null) {
            try {
                if (!connection.isClosed()) {
                    connectionPool.offer(connection);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    //关闭连接池，遍历队列中所有连接并关闭，最后清空队列
    public void shutdown() {
        for (Connection connection : connectionPool) {
            try {
                if (connection != null && !connection.isClosed()) {
                    connection.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        connectionPool.clear();
    }
}