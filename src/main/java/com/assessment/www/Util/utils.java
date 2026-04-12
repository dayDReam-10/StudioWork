package com.assessment.www.Util;

import com.alibaba.druid.pool.DruidDataSource;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

//新版不用加驱动来着，好像DriverManager会自动加载
public class utils {
    // 后续可以改成连接池
    // 连接池
    private static DruidDataSource ds = new DruidDataSource();

    // 初始化连接池
    static {
        ds.setUrl("jdbc:mysql://localhost:3306/platform?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT%2B8");
        // 字符编码设置为utf8，防止中文乱码
        ds.setUsername("root");
        ds.setPassword("1234");
        ds.setInitialSize(2);
        ds.setMaxActive(5);
        ds.setMaxWait(3000);// 3s
    }

    public static Connection getConnection() throws SQLException {
        return ds.getConnection();
    }

    //先写关闭再写开
    public static void close(ResultSet rs, Statement stmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
