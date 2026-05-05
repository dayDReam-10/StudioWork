<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.assessment.www.po.User" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${targetUser.username} 的${relationTitle}</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background: #f5f7fb;
        }
        .header {
            background: linear-gradient(135deg, #00a1d6, #1890ff);
            color: #fff;
            padding: 12px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header a {
            color: #fff;
            text-decoration: none;
            margin-left: 16px;
        }
        .container {
            max-width: 1100px;
            margin: 24px auto;
            padding: 0 20px 32px;
        }
        .top-card {
            background: #fff;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            margin-bottom: 20px;
        }
        .title-row {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            align-items: center;
            flex-wrap: wrap;
        }
        .page-title {
            margin: 0;
            font-size: 28px;
            color: #1f2937;
        }
        .subtitle {
            margin-top: 8px;
            color: #6b7280;
        }
        .tab-bar {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            flex-wrap: wrap;
        }
        .tab-bar a {
            padding: 10px 16px;
            border-radius: 999px;
            text-decoration: none;
            color: #334155;
            background: #eef2f7;
        }
        .tab-bar a.active {
            background: #1890ff;
            color: #fff;
        }
        .user-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 16px;
        }
        .user-card {
            background: #fff;
            border-radius: 16px;
            padding: 18px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .user-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.10);
        }
        .user-card a.avatar-link {
            display: block;
            text-decoration: none;
            color: inherit;
        }
        .avatar {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            object-fit: cover;
            background: #e5e7eb;
            display: block;
        }
        .user-name {
            margin: 14px 0 6px;
            font-size: 18px;
            font-weight: 700;
            color: #111827;
        }
        .user-signature {
            color: #6b7280;
            font-size: 14px;
            line-height: 1.6;
            min-height: 42px;
        }
        .user-meta {
            display: flex;
            gap: 12px;
            margin-top: 14px;
            flex-wrap: wrap;
            color: #6b7280;
            font-size: 13px;
        }
        .user-actions {
            margin-top: 16px;
        }
        .btn {
            display: inline-block;
            padding: 8px 14px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 14px;
        }
        .btn-primary {
            background: #1890ff;
            color: #fff;
        }
        .empty-state {
            background: #fff;
            border-radius: 16px;
            padding: 48px 20px;
            text-align: center;
            color: #6b7280;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
        }
        @media (max-width: 640px) {
            .title-row {
                align-items: flex-start;
            }
            .page-title {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <a href="${pageContext.request.contextPath}/">首页</a>
            <a href="${pageContext.request.contextPath}/user/${targetUser.id}">个人主页</a>
        </div>
        <div>
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/user/me">我的资料</a>
                    <a href="${pageContext.request.contextPath}/user/logout">退出登录</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/user/login">登录</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <div class="container">
        <div class="top-card">
            <div class="title-row">
                <div>
                    <h1 class="page-title">${targetUser.username} 的${relationTitle}</h1>
                    <div class="subtitle">共 ${relationCount} 人</div>
                </div>
                <c:choose>
                    <c:when test="${isOwnProfile}">
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/user/profile">返回主页</a>
                    </c:when>
                    <c:otherwise>
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/user/${targetUser.id}">返回主页</a>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="tab-bar">
                <a class="${relationType == 'followers' ? 'active' : ''}" href="${pageContext.request.contextPath}/user/followers?userId=${targetUser.id}">粉丝</a>
                <a class="${relationType == 'following' ? 'active' : ''}" href="${pageContext.request.contextPath}/user/following?userId=${targetUser.id}">关注</a>
            </div>
        </div>

        <c:choose>
            <c:when test="${not empty relationUsers}">
                <div class="user-grid">
                    <c:forEach var="relationUser" items="${relationUsers}">
                        <div class="user-card">
                            <a class="avatar-link" href="${pageContext.request.contextPath}/user/${relationUser.id}">
                                <img class="avatar" src="${relationUser.avatarUrl != null ? relationUser.avatarUrl : '/static/images/default_avatar.png'}" alt="${relationUser.username}">
                            </a>
                            <div class="user-name">${relationUser.username}</div>
                            <div class="user-signature">${relationUser.signature}</div>
                            <div class="user-meta">
                                <span>关注 ${relationUser.followingCount}</span>
                                <span>粉丝 ${relationUser.followerCount}</span>
                            </div>
                            <div class="user-actions">
                                <a class="btn btn-primary" href="${pageContext.request.contextPath}/user/${relationUser.id}">查看主页</a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    暂无${relationTitle}
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>