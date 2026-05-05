package com.assessment.www.Service;

import com.assessment.www.po.Report;

import java.util.List;

// 举报业务
public interface ReportService {
    // 举报视频
    boolean reportVideo(Integer videoId, Integer reporterId, Integer reasonId, String reasonDetail);

    // 获取待处理的举报列表
    List<Report> getPendingReports(int page, int pageSize);

    // 获取所有举报列表
    List<Report> getAllReports(int page, int pageSize);

    // 获取举报总数
    int getTotalReportCount();

    // 处理举报
    boolean processReport(Integer reportId, Integer status);

    // 获取举报详情
    Report getReportById(Integer reportId);

    // 根据视频ID获取该视频的所有举报
    List<Report> getReportsByVideoId(Integer videoId);

    // 获取已处理的举报列表
    List<Report> getProcessedReports(int page, int pageSize);

    // 获取待处理的举报总数
    int getPendingReportCount();

    boolean checkReported(Integer userid, Integer reportId);
}