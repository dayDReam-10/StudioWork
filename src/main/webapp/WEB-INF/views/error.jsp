<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>错误</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .error-box {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 90%;
        }
        .error-num {
            font-size: 80px;
            color: #e74c3c;
            font-weight: bold;
            margin: 0;
        }
        .error-text {
            font-size: 20px;
            color: #333;
            margin: 20px 0;
        }
        .back-link {
            display: inline-block;
            padding: 12px 30px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 10px;
        }
        .back-link:hover {
            background: #2980b9;
        }
    </style>
</head>
<body>
    <div class="error-box">
        <p class="error-num">
            <%= request.getAttribute("errorCode") != null ? request.getAttribute("errorCode") : "500" %>
        </p>
        <p class="error-text">
            <%= request.getAttribute("error") != null ? request.getAttribute("error") : "服务器内部错误" %>
        </p>
        <a href="${pageContext.request.contextPath}/" class="back-link">返回首页</a>
    </div>
</body>
</html>
