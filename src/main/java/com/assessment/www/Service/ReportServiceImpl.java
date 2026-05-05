package com.assessment.www.Service;

import com.assessment.www.dao.ReportDao;
import com.assessment.www.dao.ReportDaoImpl;
import com.assessment.www.po.Report;

import java.util.List;

public class ReportServiceImpl implements ReportService {
    private ReportDao reportDao = new ReportDaoImpl();

    @Override
    public boolean reportVideo(Integer videoId, Integer reporterId, Integer reasonId, String reasonDetail) {
        Report report = new Report();
        report.setVideoId(videoId);
        report.setUserId(reporterId);
        report.setReasonDetail(reasonDetail);
        report.setStatus(0);
        report.setTimeCreate(new java.sql.Timestamp(System.currentTimeMillis()));
        return reportDao.addReport(report) > 0;
    }

    @Override
    public List<Report> getPendingReports(int page, int pageSize) {
        return reportDao.getPendingReports(page, pageSize);
    }

    @Override
    public List<Report> getAllReports(int page, int pageSize) {
        return reportDao.getAllReports(page, pageSize);
    }

    @Override
    public int getTotalReportCount() {
        return reportDao.getTotalReportCount();
    }

    @Override
    public boolean processReport(Integer reportId, Integer status) {
        return reportDao.processReport(reportId, status);
    }

    @Override
    public Report getReportById(Integer reportId) {
        return reportDao.getReportById(reportId);
    }

    @Override
    public List<Report> getReportsByVideoId(Integer videoId) {
        return reportDao.getReportsByVideoId(videoId);
    }

    @Override
    public List<Report> getProcessedReports(int page, int pageSize) {
        return reportDao.getProcessedReports(page, pageSize);
    }

    @Override
    public int getPendingReportCount() {
        return reportDao.getPendingReportCount();
    }

    @Override
    public boolean checkReported(Integer userid, Integer reportId) {
        return reportDao.checkReported(userid, reportId);
    }
}