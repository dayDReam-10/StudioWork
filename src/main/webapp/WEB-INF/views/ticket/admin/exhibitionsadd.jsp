<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
<%@ page import="com.assessment.www.po.User" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>漫展发布/编辑 - 管理后台</title>
    <style>
        body { margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5; }
        .header { background-color: #00a1d6; color: white; padding: 10px 20px; display: flex; justify-content: space-between; align-items: center; }
        .nav-links { display: flex; gap: 20px; }
        .nav-links a { color: white; text-decoration: none; padding: 5px 10px; }
        .main-container { max-width: 1400px; margin: 20px auto; padding: 0 20px; display: flex; gap: 20px; }
        .sidebar { width: 250px; background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); height: fit-content; }
        .sidebar-menu { list-style: none; padding: 0; }
        .sidebar-menu li { margin-bottom: 10px; }
        .sidebar-menu a { display: block; padding: 10px 15px; color: #333; text-decoration: none; border-radius: 4px; transition: background-color 0.3s; }
        .sidebar-menu a:hover, .sidebar-menu a.active { background-color: #00a1d6; color: white; }
        .content { flex: 1; }
        .form-container { background: white; border-radius: 8px; padding: 30px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; color: #333; }
        .form-group input, .form-group textarea, .form-group select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; box-sizing: border-box; }
        .form-group textarea { height: 120px; resize: vertical; }
        .cover-upload { border: 2px dashed #ddd; border-radius: 4px; padding: 20px; text-align: center; cursor: pointer; transition: border-color 0.3s; }
        .cover-upload:hover { border-color: #00a1d6; }
        .cover-upload.has-image { border-style: solid; border-color: #00a1d6; }
        .cover-preview { max-width: 200px; max-height: 150px; margin: 10px auto; display: none; }
        .cover-preview img { width: 100%; height: 100%; object-fit: cover; border-radius: 4px; }
        .section-divider { margin: 30px 0; padding-bottom: 20px; border-bottom: 1px solid #e0e0e0; }
        .section-title { color: #333; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #00a1d6; display: inline-block; }
        .ticket-section { background: #f9f9f9; border-radius: 8px; padding: 20px; margin-bottom: 20px; }
        .ticket-item { background: white; border: 1px solid #ddd; border-radius: 4px; padding: 15px; margin-bottom: 15px; }
        .ticket-controls { display: flex; gap: 10px; margin-top: 10px; }
        .btn-add-ticket { background-color: #28a745; color: white; }
        .btn-add {
             background-color: #28a745;
             color: white;
             text-decoration: none;
             padding: 10px 20px;
             border-radius: 4px;
             margin-bottom: 20px;
             display: inline-block;
             transition: background-color 0.3s;
         }
        .btn-add:hover {background-color: #218838;}
        .btn-remove-ticket { background-color: #dc3545; color: white; }
        .form-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 30px; }
        .btn { padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; text-decoration: none; display: inline-block; }
        .btn-primary { background-color: #00a1d6; color: white; }
        .btn-secondary { background-color: #6c757d; color: white; }
        .btn-warning { background-color: #ffc107; color: #212529; }
        .btn-danger { background-color: #dc3545; color: white; }
        .alert { padding: 10px 15px; margin-bottom: 20px; border-radius: 4px; display: none; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .loading { display: none; text-align: center; margin: 10px 0; }
        .welcome-admin { color: white; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <div style="font-size: 24px; font-weight: bold;">管理后台</div>
        <div class="nav-links">
            <%
                User user = (User) session.getAttribute("user");
                String adminUsername = (user != null) ? user.getUsername() : "管理员";
            %>
            <span class="welcome-admin">管理员: <%= adminUsername %></span>
            <a href="/">返回首页</a>
            <a href="/admin/logout">退出登录</a>
        </div>
    </div>
    <div class="main-container">
        <div class="sidebar">
            <ul class="sidebar-menu">
                          <li><a href="/admin/adminindex" >数据概览</a></li>
                          <li><a href="/admin/users" >用户管理</a></li>
                           <li><a href="/admin/videos" >视频管理</a></li>
                          <li><a href="/admin/pending" >待审核视频</a></li>
                          <li><a href="/admin/banned" >被封用户</a></li>
                          <li><a href="/admin/reports" >举报管理</a></li>
                          <hr style="color:red"/>
                          <li><a href="/adminticket/exhibitions" class="active">漫展管理</a></li>
                          <li><a href="/adminticket/orders">订单管理</a></li>
                          <li><a href="/adminticket/statistics">漫展数据统计</a></li>
                          <li><a href="/adminticket/consultingUsers">当前咨询用户</a></li>
            </ul>
        </div>
        <div class="content">
            <div class="form-container">
                <a href="/adminticket/exhibitions" class="btn-add">返回</a>
                <h2 id="pageTitle">发布漫展</h2>
                <div id="alertMessage" class="alert"></div>
                <div id="loading" class="loading">
                    <img src="/images/loading.gif" alt="加载中..." width="50"> 处理中...
                </div>
                <form id="exhibitionForm" method="post" enctype="multipart/form-data">
                    <input type="hidden" id="exhibitionId" name="id">
                    <div class="form-group">
                        <label for="name">漫展名称 *</label>
                        <input type="text" id="name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="type">活动类型 *</label>
                        <select id="type" name="type" required>
                            <option value="">请选择活动类型</option>
                            <option value="漫展">漫展</option>
                            <option value="演出">演出</option>
                            <option value="比赛">比赛</option>
                            <option value="本地生活">本地生活</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="coverImage">漫展封面 *</label>
                        <div class="cover-upload" id="coverUpload" onclick="document.getElementById('coverImage').click()">
                            <div id="uploadText">点击上传封面图片</div>
                            <img id="coverPreview" class="cover-preview">
                            <div id="coverFileName" style="margin-top: 10px; color: #666;"></div>
                        </div>
                        <input type="file" id="coverImage" name="coverImage" accept="image/*" style="display: none;">
                        <input type="hidden" id="coverImageUrl" name="coverImage">
                    </div>
                    <div class="form-group">
                        <label for="description">活动描述 *</label>
                        <textarea id="description" name="description" placeholder="请详细描述活动内容、特色等信息..." required></textarea>
                    </div>
                    <div class="form-group">
                        <label for="address">活动地址 *</label>
                        <input type="text" id="address" name="address" required>
                    </div>
                    <div class="form-group">
                        <label for="contactPhone">联系电话 *</label>
                        <input type="tel" id="contactPhone" name="contactPhone" required>
                    </div>
                    <div class="form-group">
                        <label for="startTime">开始时间 *</label>
                        <input type="datetime-local" id="startTime" name="startTime" required>
                    </div>
                    <div class="form-group">
                        <label for="endTime">结束时间 *</label>
                        <input type="datetime-local" id="endTime" name="endTime" required>
                    </div>
                    <!-- 票务信息部分 -->
                    <div class="section-divider">
                        <h3 class="section-title">票务信息设置</h3>
                        <div class="ticket-section">
                            <div class="form-group" style="display:none;">
                                <label for="ticketType">售票类型</label>
                                <select id="ticketType" name="ticketType">
                                    <option value="普通票">普通票</option>
                                    <option value="学生票">学生票</option>
                                    <option value="VIP票">VIP票</option>
                                    <option value="儿童票">儿童票</option>
                                </select>
                            </div>
                            <div id="ticketItems">
                                <!-- 动态添加票种 -->
                            </div>
                            <div class="form-actions" style="margin-top: 15px;">
                                <button type="button" class="btn btn-add-ticket" onclick="addTicketItem()">+ 添加票价类型</button>
                            </div>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="button" class="btn btn-warning" id="autoSaveBtn">自动保存草稿</button>
                        <button type="button" class="btn btn-secondary" onclick="window.location.href='/adminticket/exhibitions'">取消</button>
                        <button type="submit" class="btn btn-primary">发布漫展</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <script>
        function showMessage(message, type) {
            const alertDiv = document.getElementById('alertMessage');
            alertDiv.textContent = message;
            alertDiv.className = 'alert alert-' + type;
            alertDiv.style.display = 'block';
            setTimeout(() => { alertDiv.style.display = 'none'; }, 3000);
        }
        function showLoading(show) {
            document.getElementById('loading').style.display = show ? 'block' : 'none';
        }
      function formatDateTime(dateTimeValue) {
          if (!dateTimeValue) return '';
          let date;
          // 时间戳（数字）
          if (typeof dateTimeValue === 'number') {
              date = new Date(dateTimeValue);
          }
          // 字符串格式
          else if (typeof dateTimeValue === 'string') {
              date = new Date(dateTimeValue);
              if (isNaN(date.getTime())) {
                  // 兼容 "yyyy-MM-dd HH:mm:ss" 格式
                  const match = dateTimeValue.match(/^(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}):\d{2}/);
                  if (match) {
                      return match[1] + 'T' + match[2];
                  }
                  return '';
              }
          } else {
              return '';
          }
          if (isNaN(date.getTime())) return '';
          const year = date.getFullYear();
          const month = String(date.getMonth() + 1).padStart(2, '0');
          const day = String(date.getDate()).padStart(2, '0');
          const hours = String(date.getHours()).padStart(2, '0');
          const minutes = String(date.getMinutes()).padStart(2, '0');
          return `${year}-${month}-${day}T${hours}:${minutes}`;
      }
        function showCoverPreview(src) {
            if (!src) return;
            const coverUpload = document.getElementById('coverUpload');
            const coverPreview = document.getElementById('coverPreview');
            const uploadText = document.getElementById('uploadText');
            coverUpload.classList.add('has-image');
            let imgSrc = src;
            if (!imgSrc.startsWith('data:image') && !imgSrc.startsWith('http')) {
                imgSrc = 'data:image/jpeg;base64,' + imgSrc;
            }
            coverPreview.src = imgSrc;
            coverPreview.style.display = 'block';
            uploadText.style.display = 'none';
            document.getElementById('coverImageUrl').value = src;
        }
        function fillForm(exhibition) {
            document.getElementById('exhibitionId').value = exhibition.id || '';
            document.getElementById('name').value = exhibition.name || '';
            document.getElementById('type').value = exhibition.type || '';
            document.getElementById('description').value = exhibition.description || '';
            document.getElementById('address').value = exhibition.address || '';
            document.getElementById('contactPhone').value = exhibition.contactPhone || '';
            if (exhibition.startTime) document.getElementById('startTime').value = formatDateTime(exhibition.startTime);
            if (exhibition.endTime) document.getElementById('endTime').value = formatDateTime(exhibition.endTime);
            if (exhibition.coverImage) showCoverPreview(exhibition.coverImage);
        }
        function getTicketData() {
            const ticketItems = document.querySelectorAll('.ticket-item');
            const tickets = [];
            ticketItems.forEach(item => {
                const id = item.querySelector('.ticket-id').value;
                const type = item.querySelector('.ticket-type').value;
                const price = item.querySelector('.ticket-price').value;
                const total = item.querySelector('.ticket-total-quantity').value;
                const limit = item.querySelector('.ticket-limit-quantity').value;
                const description = item.querySelector('.ticket-description').value;
                if (price && total) {
                    tickets.push({
                        id: id || undefined,
                        type: type,
                        price: parseFloat(price),
                        totalQuantity: parseInt(total),
                        limitQuantity: parseInt(limit) || 1,
                        description: description || '',
                        remainingQuantity: parseInt(total)
                    });
                }
            });
            return tickets;
        }
        function getFormData() {
            const coverPreview = document.getElementById('coverPreview');
            const coverImage = coverPreview.src && coverPreview.style.display !== 'none' ? coverPreview.src : '';
            return {
                id: document.getElementById('exhibitionId').value,
                name: document.getElementById('name').value,
                type: document.getElementById('type').value,
                description: document.getElementById('description').value,
                address: document.getElementById('address').value,
                contactPhone: document.getElementById('contactPhone').value,
                startTime: document.getElementById('startTime').value,
                endTime: document.getElementById('endTime').value,
                coverImage: coverImage,
                tickets: getTicketData()
            };
        }
        function updateRemoveButtons() {
            const ticketItems = document.querySelectorAll('.ticket-item');
            const removeButtons = document.querySelectorAll('.btn-remove-ticket');
            removeButtons.forEach((btn, index) => {
                btn.style.display = ticketItems.length > 1 ? 'block' : 'none';
            });
        }
        function updateTicketTypes() {
            const ticketTypeNames = ['普通票', 'VIP票', '学生票', '儿童票'];
            const ticketItems = document.querySelectorAll('.ticket-item');
            ticketItems.forEach((item, index) => {
                const typeInput = item.querySelector('.ticket-type');
                if (typeInput) {
                    typeInput.value = index < ticketTypeNames.length ? ticketTypeNames[index] : '其他票种';
                }
                const typeText = item.querySelector('.ticket-type-text');
                if (typeText) {
                    typeText.textContent = typeInput.value;
                }
            });
        }
        function removeTicketItem(button) {
            const ticketItems = document.querySelectorAll('.ticket-item');
            if (ticketItems.length > 1) {
                button.closest('.ticket-item').remove();
                updateRemoveButtons();
                updateTicketTypes();
            } else {
                showMessage('至少保留一种票价类型', 'danger');
            }
        }
        function addTicketItem() {
            const ticketTypes = ['普通票', 'VIP票', '学生票', '儿童票'];
            const ticketNames = ['普通票', 'VIP票', '学生票', '儿童票'];
            const ticketItems = document.querySelectorAll('.ticket-item');
            if (ticketItems.length >= ticketTypes.length) {
                showMessage('最多添加4种票价类型', 'danger');
                return;
            }
            const container = document.getElementById('ticketItems');
            const newItem = document.createElement('div');
            newItem.className = 'ticket-item';
            const typeIndex = ticketItems.length;
            const ticketType = ticketTypes[typeIndex];
            const ticketName = ticketNames[typeIndex];
            newItem.innerHTML = `
                <div class="form-group">
                    <label>票价类型 <span class="ticket-type-text">${ticketName}</span></label>
                    <input type="hidden" class="ticket-type" value="${ticketType}">
                    <input type="hidden" class="ticket-id" value="">   <!-- 新增票种没有ID -->
                </div>
                <div class="form-group">
                    <label>票价（元）</label>
                    <input type="number" class="ticket-price" min="0" step="0.01" placeholder="0.00" required>
                </div>
                <div class="form-group">
                    <label>总票数</label>
                    <input type="number" class="ticket-total-quantity" min="1" required>
                </div>
                <div class="form-group">
                    <label>剩余数量</label>
                    <input type="number" class="ticket-limit-quantity" min="1" required>
                </div>
                <div class="form-group">
                    <label>票务描述</label>
                    <input type="text" class="ticket-description" placeholder="请输入票务说明">
                </div>
                <div class="ticket-controls">
                    <button type="button" class="btn btn-danger btn-remove-ticket" onclick="removeTicketItem(this)">删除</button>
                </div>
            `;
            container.appendChild(newItem);
            updateRemoveButtons();
            updateTicketTypes();
        }
        function addTicketItemWithData(ticket, index) {
            const ticketTypes = ['普通票', 'VIP票', '学生票', '儿童票'];
            const ticketNames = ['普通票', 'VIP票', '学生票', '儿童票'];
            const container = document.getElementById('ticketItems');
            const newItem = document.createElement('div');
            newItem.className = 'ticket-item';
            let typeName = ticket.type;
            let typeValue = ticket.type;
            if (index < ticketTypes.length) {
                typeName = ticketNames[index];
                typeValue = ticketTypes[index];
            }
            const ticketId = ticket.id || ticket.ticketId || '';
            newItem.innerHTML = `
                <div class="form-group">
                    <label>票价类型 <span class="ticket-type-text">${typeName}</span></label>
                    <input type="hidden" class="ticket-type" value="${typeValue}">
                    <input type="hidden" class="ticket-id" value="${ticketId}">
                </div>
                <div class="form-group">
                    <label>票价（元）</label>
                    <input type="number" class="ticket-price" min="0" step="0.01" placeholder="0.00" value="${ticket.price}" required>
                </div>
                <div class="form-group">
                    <label>总票数</label>
                    <input type="number" class="ticket-total-quantity" min="1" value="${ticket.totalQuantity}" required>
                </div>
                <div class="form-group">
                    <label>剩余数量</label>
                    <input type="number" class="ticket-limit-quantity" min="1" value="${ticket.limitQuantity || 1}" required>
                </div>
                <div class="form-group">
                    <label>票务描述</label>
                    <input type="text" class="ticket-description" placeholder="请输入票务说明" value="${ticket.description || ''}">
                </div>
                <div class="ticket-controls">
                    <button type="button" class="btn btn-danger btn-remove-ticket" onclick="removeTicketItem(this)">删除</button>
                </div>
            `;
            container.appendChild(newItem);
        }
        // 自动保存相关
        function autoSaveDraft() {
            const formData = getFormData();
            formData.status = 0;
            showLoading(true);
            formData.tickets = getTicketData();
            fetch('/adminticket/exhibitions/save-draft', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData)
            }).then(response => response.json()).then(data => {
                showLoading(false);
                if (data.success) {
                    localStorage.setItem('exhibitionDraftId', data.id);
                    document.getElementById('exhibitionId').value = data.id || '';
                    showMessage('草稿已自动保存', 'success');
                } else {
                    showMessage('保存失败：' + data.message, 'danger');
                }
            }).catch(error => {
                showLoading(false);
                showMessage('保存失败，请重试', 'danger');
            });
        }
        function setupAutoSave() {
            let autoSaveTimer;
            const autoSaveBtn = document.getElementById('autoSaveBtn');
            const inputs = document.querySelectorAll('#exhibitionForm input, #exhibitionForm textarea, #exhibitionForm select');
            inputs.forEach(input => {
                input.addEventListener('input', function() {
                    clearTimeout(autoSaveTimer);
                    autoSaveTimer = setTimeout(autoSaveDraft, 3000);
                });
            });
            autoSaveBtn.addEventListener('click', autoSaveDraft);
        }
        function setupCoverUpload() {
            const coverInput = document.getElementById('coverImage');
            const coverFileName = document.getElementById('coverFileName');
            coverInput.addEventListener('change', function(e) {
                const file = e.target.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function(e) { showCoverPreview(e.target.result); };
                    reader.readAsDataURL(file);
                    coverFileName.textContent = file.name;
                }
            });
        }
        function setupForm() {
            const form = document.getElementById('exhibitionForm');
            let isSubmitting = false;
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                if (isSubmitting) return;
                isSubmitting = true;
                const startTime = new Date(document.getElementById('startTime').value);
                const endTime = new Date(document.getElementById('endTime').value);
                if (startTime >= endTime) {
                    showMessage('结束时间必须晚于开始时间', 'danger');
                    isSubmitting = false;
                    return;
                }
                const ticketItems = document.querySelectorAll('.ticket-item');
                let hasValidTicket = false;
                for (let item of ticketItems) {
                    const price = item.querySelector('.ticket-price').value;
                    const total = item.querySelector('.ticket-total-quantity').value;
                    const limit = item.querySelector('.ticket-limit-quantity').value;
                    if (price && total && limit) {
                        if (parseInt(limit) > parseInt(total)) {
                            showMessage('剩余数量不能大于总票数', 'danger');
                            isSubmitting = false;
                            return;
                        }
                        hasValidTicket = true;
                    }
                }
                if (!hasValidTicket) {
                    showMessage('请至少设置一种有效的票价信息', 'danger');
                    isSubmitting = false;
                    return;
                }
                const formData = getFormData();
                formData.status = 1;
                showLoading(true);
                const formDataObj = new FormData();
                formDataObj.append('id', document.getElementById('exhibitionId').value);
                formDataObj.append('name', document.getElementById('name').value);
                formDataObj.append('type', document.getElementById('type').value);
                formDataObj.append('description', document.getElementById('description').value);
                formDataObj.append('address', document.getElementById('address').value);
                formDataObj.append('contactPhone', document.getElementById('contactPhone').value);
                formDataObj.append('startTime', document.getElementById('startTime').value);
                formDataObj.append('endTime', document.getElementById('endTime').value);
                const coverFile = document.getElementById('coverImage').files[0];
                if (coverFile) {
                    const coverPreview = document.getElementById('coverPreview');
                    const coverImage = coverPreview.src && coverPreview.style.display !== 'none' ? coverPreview.src : '';
                    formDataObj.append('coverImage', coverImage);
                } else {
                    const existingCover = document.getElementById('coverImageUrl').value;
                    if (existingCover) formDataObj.append('coverImage', existingCover);
                }
                formData.tickets.forEach((ticket, idx) => {
                                   formDataObj.append(`tickets[${idx}][id]`, ticket.id || '');
                                   formDataObj.append(`tickets[${idx}][type]`, ticket.type);
                                   formDataObj.append(`tickets[${idx}][price]`, ticket.price);
                                   formDataObj.append(`tickets[${idx}][totalQuantity]`, ticket.totalQuantity);
                                   formDataObj.append(`tickets[${idx}][limitQuantity]`, ticket.limitQuantity);
                                   formDataObj.append(`tickets[${idx}][description]`, ticket.description);
                });
                fetch('/adminticket/exhibitions/save', { method: 'POST', body: formDataObj }).then(response => response.json()).then(data => {
                        showLoading(false);
                        if (data.success) {
                            showMessage('发布成功！', 'success');
                            setTimeout(() => { window.location.href = '/adminticket/exhibitions'; }, 1500);
                        } else {
                            showMessage('发布失败：' + data.message, 'danger');
                            isSubmitting = false;
                        }
                    }).catch(err => {
                        showLoading(false);
                        showMessage('网络错误，请重试', 'danger');
                        isSubmitting = false;
                    });
            });
        }
        function loadDraft() {
            const draftId = localStorage.getItem('exhibitionDraftId');
            if (draftId) {
                fetch('/adminticket/exhibitions/draft?id=' + draftId).then(response => response.json()).then(data => {
                        if (data.success) {
                            fillForm(data.exhibition);
                            showMessage('已恢复上次编辑的草稿', 'success');
                        }
                    }).catch(err => console.error('加载草稿失败', err));
            }
        }
        function setupTicketType() {
            const ticketTypeSelect = document.getElementById('ticketType');
            ticketTypeSelect.addEventListener('change', function() {
                const ticketItems = document.querySelectorAll('.ticket-item');
                if (this.value === 'public') {
                    ticketItems.forEach(item => item.style.display = 'block');
                } else {
                    ticketItems.forEach((item, index) => { item.style.display = index === 0 ? 'block' : 'none'; });
                }
            });
        }
        document.addEventListener('DOMContentLoaded', function() {
            const backendExhibition = <%= request.getAttribute("exhibition") != null ? "true" : "false" %>;
            if (backendExhibition) {
                try {
                    const exhibition = <%= new ObjectMapper().writeValueAsString(request.getAttribute("exhibition")) %>;
                    if (exhibition && exhibition.id) {
                        document.getElementById('pageTitle').innerText = '编辑漫展';
                        fillForm(exhibition);
                        const container = document.getElementById('ticketItems');
                        container.innerHTML = '';
                        if (exhibition.tickets && exhibition.tickets.length > 0) {
                            exhibition.tickets.forEach((ticket, idx) => {
                                addTicketItemWithData(ticket, idx);
                            });
                        } else {
                            addTicketItem();
                        }
                        updateRemoveButtons();
                        updateTicketTypes();
                        showMessage('已加载漫展数据，可进行编辑', 'success');
                        setupAutoSave();
                        setupCoverUpload();
                        setupForm();
                        setupTicketType();
                        return;
                    }
                } catch(e) { console.error('解析后端数据失败', e); }
            }
            loadDraft();
            setupAutoSave();
            setupCoverUpload();
            setupForm();
            setupTicketType();
            updateTicketTypes();
            const urlParams = new URLSearchParams(window.location.search);
            const exhibitionId = urlParams.get('id');
            if (exhibitionId && !isNaN(parseInt(exhibitionId))) {
                fetch('/adminticket/exhibition-detail?json=1&id=' + exhibitionId).then(response => response.json()).then(data => {
                        if (data.success) {
                            fillForm(data.exhibition);
                            const container = document.getElementById('ticketItems');
                            container.innerHTML = '';
                            if (data.exhibition.tickets && data.exhibition.tickets.length > 0) {
                                data.exhibition.tickets.forEach((ticket, idx) => addTicketItemWithData(ticket, idx));
                            } else {
                                addTicketItem();
                            }
                            updateRemoveButtons();
                            updateTicketTypes();
                            showMessage('已加载漫展数据', 'success');
                        }
                    }).catch(err => console.error('加载失败', err));
            }
        });
    </script>
</body>
</html>