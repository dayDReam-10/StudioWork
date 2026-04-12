package com.assessment.www.dao;

import com.assessment.www.po.Report;

import java.util.List;

// 举报数据访问接口
public interface ReportDao {
    // 添加举报
    int addReport(Report report);

    // 获取待处理的举报列表
    List<Report> getPendingReports(int page, int pageSize);

    // 获取所有举报
    List<Report> getAllReports(int page, int pageSize);

    // 获取举报总数
    int getTotalReportCount();

    // 处理举报 4 admin
    boolean processReport(Integer reportId, Integer status);

    // 根据视频ID获取举报
    Report getReportById(Integer reportId);

    // 根据视频ID获取该视频的所有举报
    List<Report> getReportsByVideoId(Integer videoId);

    // 获取已处理的举报列表
    List<Report> getProcessedReports(int page, int pageSize);

    // 获取待处理的举报总数
    int getPendingReportCount();
    // 检查是否已举报
    public boolean checkReported(int userId, int videoId);
}