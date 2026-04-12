package com.assessment.www.po;

// 签到结果封装
public class CheckInResult {
    private boolean success;
    private String message;
    private Integer coinReward;
    private CheckIn checkInRecord;

    public CheckInResult() {
    }

    public CheckInResult(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public CheckInResult(boolean success, String message, Integer coinReward, CheckIn checkInRecord) {
        this.success = success;
        this.message = message;
        this.coinReward = coinReward;
        this.checkInRecord = checkInRecord;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Integer getCoinReward() {
        return coinReward;
    }

    public void setCoinReward(Integer coinReward) {
        this.coinReward = coinReward;
    }

    public CheckIn getCheckInRecord() {
        return checkInRecord;
    }

    public void setCheckInRecord(CheckIn checkInRecord) {
        this.checkInRecord = checkInRecord;
    }
}