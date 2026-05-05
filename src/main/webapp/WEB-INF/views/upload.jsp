<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>上传视频</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
        }
        .header {
            background-color: #00a1d6;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .nav-links {
            display: flex;
            gap: 20px;
        }
        .nav-links a {
            color: white;
            text-decoration: none;
            padding: 5px 10px;
        }
        .main-container {
            max-width: 800px;
            margin: 20px auto;
            padding: 0 20px;
        }
        .upload-container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .upload-title {
            font-size: 24px;
            margin-bottom: 30px;
            text-align: center;
        }
        .form-group {
            margin-bottom: 25px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: bold;
        }
        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .form-group textarea {
            min-height: 100px;
            resize: vertical;
        }
        .file-upload {
            border: 2px dashed #ddd;
            border-radius: 4px;
            padding: 40px;
            text-align: center;
            background-color: #f9f9f9;
            cursor: pointer;
            transition: border-color 0.3s;
        }
        .file-upload:hover {
            border-color: #00a1d6;
        }
        .file-upload input {
            #display: none;
        }
        .upload-btn {
            width: 100%;
            padding: 15px;
            background-color: #00a1d6;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 10px;
        }
        .upload-btn:hover {
            background-color: #0088b3;
        }
        .error-message {
            color: #ff6b6b;
            text-align: center;
            margin-bottom: 20px;
        }
        .success-message {
            color: #4ecdc4;
            text-align: center;
            margin-bottom: 20px;
        }
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        .back-link a {
            color: #00a1d6;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="header">
                <a href="/" style="text-decoration: none; color: inherit;"><div style="font-size: 24px; font-weight: bold;">视频分享平台</div></a>
        <div class="nav-links">
            <a href="/">首页</a>
            <a href="/user/me">个人中心</a>
            <a href="/user/logout">退出登录</a>
        </div>
    </div>
    <div class="main-container">
        <div class="upload-container">
            <h2 class="upload-title">上传视频</h2>
            <%-- 显示错误信息 --%>
            <%
                String error = request.getParameter("error");
                if (error != null) {
            %>
            <div class="error-message">
                <%= error %>
            </div>
            <%
                }
            %>
            <%-- 显示成功信息 --%>
            <%
                String success = request.getParameter("success");
                if (success != null) {
            %>
            <div class="success-message">
                <%= success %>
            </div>
            <%
                }
            %>
            <form action="/video/upload" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="videoFile">选择视频文件:</label>
                    <div class="file-upload">
                        <input type="file" id="videoFile" name="videoFile" accept="video/*" required>
                        <p>点击或拖拽文件到这里上传</p>
                        <small>支持MP4、AVI、MOV等格式</small>
                    </div>
                </div>
                <div class="form-group">
                    <label for="title">视频标题:</label>
                    <input type="text" id="title" name="title" required placeholder="请输入视频标题">
                </div>
                <div class="form-group">
                    <label for="description">视频简介:</label>
                    <textarea id="description" name="description" placeholder="请输入视频简介"></textarea>
                </div>
                <div class="form-group">
                    <label for="coverUrl">封面图片URL:</label>
                    <input type="text" id="coverUrl" name="coverUrl" placeholder="请输入封面图片URL" value="/static/images/default_cover.png">
                </div>
                <div class="form-group">
                    <label for="visibility">视频可见范围:</label>
                    <select id="visibility" name="visibility" required>
                        <option value="public">公开</option>
                        <option value="followers">粉丝可见</option>
                        <option value="mutual_follow">互关可见</option>
                        <option value="private">私密</option>
                    </select>
                </div>
                <button type="submit" class="upload-btn">上传视频</button>
            </form>
            <div class="back-link">
                <a href="/">返回首页</a>
            </div>
        </div>
    </div>
    <script>
        // 文件上传预览
        document.getElementById('videoFile').addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const fileUpload = document.querySelector('.file-upload p');
                fileUpload.textContent = `已选择: ${file.name}`;
            }
        });
        document.querySelector('form').addEventListener('submit', function(e) {
            const title = document.getElementById('title').value.trim();
            const videoFile = document.getElementById('videoFile').files[0];
            if (!title) {
                e.preventDefault();
                alert('请输入视频标题');
            }
            if (!videoFile) {
                e.preventDefault();
                alert('请选择视频文件');
            }
        });
    </script>
</body>
</html>