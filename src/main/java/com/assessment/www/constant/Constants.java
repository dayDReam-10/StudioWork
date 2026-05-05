package com.assessment.www.constant;

//常量类
public class Constants {
    // 用户角色
    public static final String ROLEUSER = "user";
    public static final String ROLEADMIN = "admin";
    // 用户状态
    public static final int STATUSNORMAL = 1;
    public static final int STATUSBAN = 0;
    // 视频状态
    public static final int VIDEOSTATUSPEN = 0; // 待审核
    public static final int VIDEOSTATUSAPP= 1; // 通过
    public static final int VIDEOSTATUSREJ= 2; // 驳回
    // 性别
    public static final int GENDERSECRET = 0; // 保密
    public static final int GENDERMALE = 1;   // 男
    public static final int GENDERFEMALE = 2; // 女
    // 分页相关
    public static final int PAGESIZE = 10; // 默认每页显示数量
    public static final int MAXPAGESIZE = 100; // 最大每页显示数量
    // 时间格式
    public static final String DATEFORMAT = "yyyy-MM-dd HH:mm:ss";
    // 默认值
    public static final String DEFAULT_AVATAR = "/static/images/default_avatar.png";
    public static final String DEFAULT_COVER = "/static/images/default_cover.png";
    public static final String DEFAULT_SIGNSTR = "这个人很懒，什么都没有留下";
    // 硬币相关
    public static final int MINCOINMOUNT = 1;
    public static final int MAXCOINMOUNT= 2;
    // 评论相关
    public static final int MAXCOMMENTLENGTH = 500;
    public static final int MAXCOMMENTSPERPAGE = 100;
}