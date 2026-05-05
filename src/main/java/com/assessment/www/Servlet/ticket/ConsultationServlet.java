package com.assessment.www.Servlet.ticket;

import com.assessment.www.Service.ticket.ChatMessageService;
import com.assessment.www.Service.ticket.ChatMessageServiceImpl;
import com.assessment.www.Util.utils;
import com.assessment.www.Util.ticket.ConsultationWebSocketEndpoint;
import com.assessment.www.po.ticket.ChatMessage;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;


@WebServlet("/ticket/consultation/*")//咨询管理Servlet 处理后台咨询管理相关功能
public class ConsultationServlet extends HttpServlet {
    private ChatMessageService chatMessageService;
    private ObjectMapper objectMapper;

    @Override
    public void init() throws ServletException {
        super.init();
        chatMessageService = new ChatMessageServiceImpl();
        objectMapper = new ObjectMapper();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                response.sendRedirect(request.getContextPath() + "/ticket/admin/consultingUsers.jsp");
                return;
            }
            switch (pathInfo) {
                case "/users":
                    getConsultingUsers(request, response);
                    break;
                case "/history":
                    getChatHistory(request, response);
                    break;
                default:
                    response.sendError(404, "不支持的请求路径");
            }
        } catch (Exception e) {
            handleResponseMsg(response, "处理请求时发生错误: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        try {
            switch (pathInfo) {
                case "/reply"://通过接口回复信息
                    sendReply(request, response);
                    break;
                case "/clear"://通过接口清楚回复信息
                    clearChatHistory(request, response);
                    break;
                default:
                    response.sendError(404, "不支持的请求路径");
            }
        } catch (Exception e) {
            handleResponseMsg(response, "处理请求时发生错误: " + e.getMessage());
        }
    }

    //获取咨询用户列表
    private void getConsultingUsers(HttpServletRequest request, HttpServletResponse response) throws IOException {
        List<Map<String, Object>> onlineUsers = ConsultationWebSocketEndpoint.getOnlineUsersList();
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", onlineUsers);
        result.put("count", onlineUsers.size());
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(objectMapper.writeValueAsString(result));
    }

    //获取聊天历史
    private void getChatHistory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String userIdStr = request.getParameter("userId");
        if (userIdStr == null || userIdStr.isEmpty()) {
            handleResponseMsg(response, "用户ID不能为空");
            return;
        }
        try {
            int userId = Integer.parseInt(userIdStr);
            List<ChatMessage> history = chatMessageService.getChatHistory(userId);
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("data", history);
            result.put("count", history.size());
            result.put("userId", userId);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(objectMapper.writeValueAsString(result));
        } catch (NumberFormatException e) {
            handleResponseMsg(response, "用户ID格式错误");
        }
    }

    //发送管理员回复
    private void sendReply(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String userIdStr = request.getParameter("userId");
        String content = request.getParameter("content");
        if (userIdStr == null || userIdStr.isEmpty()) {
            handleResponseMsg(response, "用户ID不能为空");
            return;
        }
        if (content == null || content.trim().isEmpty()) {
            handleResponseMsg(response, "回复内容不能为空");
            return;
        }
        try {
            int userId = Integer.parseInt(userIdStr);
            // 保存回复到数据库
            boolean saved = chatMessageService.saveAdminMessage(userId, content);
            if (saved) {
                com.assessment.www.po.ticket.Message message = new com.assessment.www.po.ticket.Message();
                message.setType("admin");
                message.setFrom("admin");
                message.setTo(String.valueOf(userId));
                message.setContent(content);
                ConsultationWebSocketEndpoint.sendToUser(String.valueOf(userId), message);
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "回复已发送");
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(objectMapper.writeValueAsString(result));
            } else {
                handleResponseMsg(response, "保存回复失败");
            }
        } catch (NumberFormatException e) {
            handleResponseMsg(response, "用户ID格式错误");
        }
    }

    //清除聊天记录
    private void clearChatHistory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String userIdStr = request.getParameter("userId");
        if (userIdStr == null || userIdStr.isEmpty()) {
            handleResponseMsg(response, "用户ID不能为空");
            return;
        }
        try {
            int userId = Integer.parseInt(userIdStr);
            boolean cleared = chatMessageService.clearChatHistory(userId);
            Map<String, Object> result = new HashMap<>();
            if (cleared) {
                result.put("success", true);
                result.put("message", "聊天记录已清除");
            } else {
                result.put("success", false);
                result.put("message", "清除聊天记录失败");
            }
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(objectMapper.writeValueAsString(result));
        } catch (NumberFormatException e) {
            handleResponseMsg(response, "用户ID格式错误");
        }
    }

    //统一错误处理
    private void handleResponseMsg(HttpServletResponse response, String message) throws IOException {
        Map<String, Object> result = new HashMap<>();
        result.put("success", false);
        result.put("message", message);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(500);
        response.getWriter().write(objectMapper.writeValueAsString(result));
    }
}