package com.assessment.www.Servlet.ticket;

import com.assessment.www.Service.ticket.*;
import com.assessment.www.Service.UserService;
import com.assessment.www.Service.UserServiceImpl;
import com.assessment.www.Util.AuthUtil;
import com.assessment.www.dao.ticket.UserTicketDao;
import com.assessment.www.dao.ticket.UserTicketDaoImpl;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.User;
import com.assessment.www.po.ticket.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet("/adminticket/*")
@MultipartConfig
public class AdminTicketServlet extends HttpServlet {//新增售票后台功能处理接口
    private ExhibitionService exhibitionService;
    private TicketService ticketService;
    private OrderService orderService;
    private UserService userService;
    private UserTicketDao userTicketDao;

    @Override
    public void init() {
        exhibitionService = new ExhibitionServiceImpl();
        ticketService = new TicketServiceImpl();
        orderService = new OrderServiceImpl();
        userService = new UserServiceImpl();
        userTicketDao = new UserTicketDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.isAdmin(request)) {
            throw new BaseException(403, "权限不足");
        }
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }
        switch (pathInfo) {
            case "/exhibitions":
                showAdminExhibitions(request, response);
                break;
            case "/add":
                showAddForm(request, response);
                break;
            case "/exhibitions/edit":
                showEditForm(request, response);
                break;
            case "/exhibitions/draft":
                getDraft(request, response);
                break;
            case "/orders":
                showOrderManagement(request, response);
                break;
            case "/order-details":
                showOrderDetails(request, response);
                break;
            case "/verify":
                showVerifyPage(request, response);
                break;
            case "/statistics":
                showStatistics(request, response);
                break;
            case "/consultingUsers":
                showConsultingUsers(request, response);
                break;
            case "/getConsultingUsers":
                getConsultingUsers(request, response);
                break;
            case "/chatHistory":
                getChatHistory(request, response);
                break;
            case "/exhibition-sales":
                showExhibitionSales(request, response);
                break;
            case "/exhibition-verify":
                showExhibitionVerify(request, response);
                break;
            default:
                throw new BaseException(404, "页面不存在");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.isAdmin(request)) {
            throw new BaseException(403, "权限不足");
        }
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            throw new BaseException(400, "错误请求");
        }
        switch (pathInfo) {
            case "/exhibitions/save-draft":
                saveDraft(request, response);
                break;
            case "/exhibitions/save":
                publishExhibitionWithTickets(request, response);
                break;
            case "/verifyticket":
                verifyTicket(request, response);
                break;
            case "/endExhibition":
                endExhibition(request, response);
                break;
            case "/deleteExhibition":
                deleteExhibition(request, response);
                break;
            case "/sendMessage":
                sendMessage(request, response);
                break;
            case "/getExhibitionSales":
                getExhibitionSales(request, response);
                break;
            case "/getExhibitionVerify":
                getExhibitionVerify(request, response);
                break;
            default:
                throw new BaseException(404, "接口不存在");
        }
    }

    // 显示添加漫展表单
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/ticket/admin/exhibitionsadd.jsp").forward(request, response);
    }

    // 显示订单管理页面
    private void showOrderManagement(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
        }
        String status = request.getParameter("status");
        String format = request.getParameter("format");
        int pageSize = 5;
        List<Order> orders = orderService.getUserOrders(0, status, page, pageSize);
        // 填充漫展名称和票种名称
        for (Order order : orders) {
            Exhibition exhibition = exhibitionService.getExhibitionById(order.getExhibitionId());
            if (exhibition != null) order.setExhibitionName(exhibition.getName());
            Ticket ticket = ticketService.getTicketByorderId(order.getId());
            if (ticket != null) order.setTicketName(ticket.getName());
        }
        int totalCount = orderService.getTotalOrderCount(0, status);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        // 如果是 JSON 请求，返回 JSON 数据
        if ("json".equals(format)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            Map<String, Object> jsonResult = new HashMap<>();
            jsonResult.put("success", true);
            jsonResult.put("currentPage", page);
            jsonResult.put("totalPages", totalPages);
            jsonResult.put("orders", orders);
            ObjectMapper mapper = new ObjectMapper();
            mapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
            mapper.setDateFormat(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"));
            response.getWriter().write(mapper.writeValueAsString(jsonResult));
            return;
        }
        // 正常页面请求
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/WEB-INF/views/ticket/admin/orders.jsp").forward(request, response);
    }

    // 显示核验页面
    private void showVerifyPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/ticket/admin/verify.jsp").forward(request, response);
    }

    // 显示统计页面
    private void showStatistics(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String acceptHeader = request.getHeader("Accept");
        boolean wantsJson = acceptHeader != null && acceptHeader.contains("application/json");
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            wantsJson = true;
        }
        String timeRange = request.getParameter("timeRange");
        if (timeRange == null) timeRange = "day";
        Map<String, Object> statsData = getStatisticsData(timeRange);
        if (wantsJson) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("data", statsData);
            ObjectMapper mapper = new ObjectMapper();
            response.getWriter().write(mapper.writeValueAsString(result));
        } else {
            List<Object[]> salesList = (List<Object[]>) statsData.get("salesTrendData");
            ObjectMapper mapper = new ObjectMapper();
            String salesTrendJson = mapper.writeValueAsString(salesList);
            request.setAttribute("totalOrders", statsData.get("totalOrders"));
            request.setAttribute("totalSales", statsData.get("totalSales"));
            request.setAttribute("totalUsers", statsData.get("totalUsers"));
            request.setAttribute("activeExhibitions", statsData.get("activeExhibitions"));
            request.setAttribute("verifiedTickets", statsData.get("verifiedTickets"));
            request.setAttribute("refundedTickets", statsData.get("refundedTickets"));
            request.setAttribute("pendingOrders", statsData.get("pendingOrders"));
            request.setAttribute("paidOrders", statsData.get("paidOrders"));
            request.setAttribute("verifiedOrders", statsData.get("verifiedOrders"));
            request.setAttribute("cancelledOrders", statsData.get("cancelledOrders"));
            request.setAttribute("salesTrendData", salesTrendJson);   // JSON 字符串
            request.setAttribute("currentTimeRange", timeRange);
            request.getRequestDispatcher("/WEB-INF/views/ticket/admin/statistics.jsp").forward(request, response);
        }
    }

    private Map<String, Object> getStatisticsData(String timeRange) {
        Map<String, Object> data = new HashMap<>();
        try {
            int totalOrders = orderService.getTotalOrderCount(-1, null);
            double totalSales = orderService.getTotalOrderAmount();
            int totalUsers = userService.getTotalUserCount();
            int activeExhibitions = exhibitionService.getActiveExhibitionsCount();
            int verifiedTickets = orderService.getVerifiedTicketCount();
            int refundedTickets = orderService.getRefundedTicketCount();
            int[] statusDistribution = orderService.getOrderStatusDistribution();
            int pendingOrders = statusDistribution[0];
            int paidOrders = statusDistribution[1];
            int verifiedOrders = statusDistribution[2];
            int cancelledOrders = statusDistribution[3];
            List<Object[]> rawSalesData = orderService.getSalesTrendData(timeRange);
            data.put("salesTrendData", rawSalesData);
            data.put("totalOrders", totalOrders);
            data.put("totalSales", String.format("%.2f", totalSales));
            data.put("totalUsers", totalUsers);
            data.put("activeExhibitions", activeExhibitions);
            data.put("verifiedTickets", verifiedTickets);
            data.put("refundedTickets", refundedTickets);
            data.put("pendingOrders", pendingOrders);
            data.put("paidOrders", paidOrders);
            data.put("verifiedOrders", verifiedOrders);
            data.put("cancelledOrders", cancelledOrders);
            Map<String, Integer> statusMap = new HashMap<>();
            statusMap.put("pending", pendingOrders);
            statusMap.put("paid", paidOrders);
            statusMap.put("verified", verifiedOrders);
            statusMap.put("cancelled", cancelledOrders);
            data.put("orderStatusDistribution", statusMap);
        } catch (Exception e) {
            e.printStackTrace();
            // 提供默认空数据
            data.put("totalOrders", 0);
            data.put("totalSales", "0.00");
            data.put("totalUsers", 0);
            data.put("activeExhibitions", 0);
            data.put("verifiedTickets", 0);
            data.put("refundedTickets", 0);
            data.put("pendingOrders", 0);
            data.put("paidOrders", 0);
            data.put("verifiedOrders", 0);
            data.put("cancelledOrders", 0);
            data.put("salesTrendData", new ArrayList<>());
            data.put("orderStatusDistribution", new HashMap<>());
        }
        return data;
    }

    // 显示订单详情
    private void showOrderDetails(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int orderId = Integer.parseInt(request.getParameter("id"));
        Order order = orderService.getOrderById(orderId);
        if (order == null) {
            throw new BaseException(404, "订单不存在");
        }
        request.setAttribute("order", order);
        request.getRequestDispatcher("/WEB-INF/views/ticket/admin/order-details.jsp").forward(request, response);
    }

    // 发布漫展并添加票务信息
    private void publishExhibitionWithTickets(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        try {
            request.getParts();
            // 获取展览基本信息
            Exhibition exhibition = parseExhibitionFromRequest(request);
            exhibition.setStatus(1);
            exhibition.setCreateTime(new Timestamp(System.currentTimeMillis()));
            exhibition.setUpdateTime(new Timestamp(System.currentTimeMillis()));
            // 处理封面图片
            Part coverPart = null;
            if (coverPart != null && coverPart.getSize() > 0) {
            } else {
                String existingCover = request.getParameter("coverImage");
                if (existingCover != null && !existingCover.isEmpty()) {
                    exhibition.setCoverImage(existingCover);
                }
            }
            // 解析票务信息
            List<Ticket> tickets = parseTicketsFromMultipart(request, exhibition.getName());
            // 保存
            int exhibitionId = exhibitionService.publishExhibitionWithTickets(exhibition, tickets);
            response.setContentType("application/json");
            response.getWriter().write(String.format("{\"success\":true,\"message\":\"发布成功\",\"exhibitionId\":%d}", exhibitionId));
        } catch (Exception e) {
            response.setContentType("application/json");
            response.getWriter().write(String.format("{\"success\":false,\"message\":\"发布失败：%s\"}", e.getMessage()));
        }
    }


    // 获取草稿
    private void getDraft(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String draftId = request.getParameter("id");
        if (draftId == null || draftId.isEmpty()) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"草稿ID不存在\"}");
            return;
        }
        try {
            Exhibition draft = exhibitionService.getExhibitionById(Integer.parseInt(draftId));
            if (draft != null && "draft".equals(draft.getStatus())) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(String.format(
                        "{\"success\":true,\"exhibition\":{\"id\":%d,\"name\":\"%s\",\"type\":\"%s\",\"description\":\"%s\",\"address\":\"%s\",\"contactPhone\":\"%s\",\"startTime\":\"%s\",\"endTime\":\"%s\",\"coverImage\":\"%s\"}}",
                        draft.getId(),
                        draft.getName(),
                        draft.getType(),
                        draft.getDescription() != null ? draft.getDescription().replace("\"", "\\\"") : "",
                        draft.getAddress(),
                        draft.getContactPhone(),
                        draft.getStartTime(),
                        draft.getEndTime(),
                        draft.getCoverImage() != null ? draft.getCoverImage().replace("\"", "\\\"") : ""
                ));
            } else {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"草稿不存在\"}");
            }
        } catch (Exception e) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"获取草稿失败\"}");
        }
    }

    // 保存草稿
    private void saveDraft(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                sb.append(line);
            }
            if (sb.length() == 0) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"message\":\"请求体为空，保存草稿失败\"}");
                return;
            }
            ObjectMapper objectMapper = new ObjectMapper();
            String json = sb.toString();
            Exhibition exhibition = objectMapper.readValue(json, Exhibition.class);
            exhibition.setStatus(0);
            if (exhibition.getId() != null) {
                exhibition.setUpdateTime(new Timestamp(System.currentTimeMillis()));
                exhibitionService.updateExhibition(exhibition);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(String.format("{\"success\":true,\"message\":\"草稿保存成功\",\"id\":%d}", exhibition.getId()));
            } else {
                exhibition.setCreateTime(new Timestamp(System.currentTimeMillis()));
                exhibition.setUpdateTime(new Timestamp(System.currentTimeMillis()));
                int id = exhibitionService.saveOrupdate(exhibition);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(String.format("{\"success\":true,\"message\":\"草稿保存成功\",\"id\":%d}", id));
            }
        } catch (Exception e) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"保存草稿失败\"}");
        }
    }

    // 删除漫展
    private void deleteExhibition(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        if (exhibitionService.deleteExhibition(id)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":true,\"message\":\"删除成功\"}");
        } else {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"删除失败\"}");
        }
    }


    // 核验票务
    private void verifyTicket(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String verifyCode = request.getParameter("verifyCode");
        String orderId = request.getParameter("orderId");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (ticketService.verifyTicketByCode(verifyCode, orderId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"核验成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"核验失败或票已使用\"}");
        }
    }

    // 解析展览信息
    private Exhibition parseExhibitionFromRequest(HttpServletRequest request) {
        Exhibition exhibition = new Exhibition();
        exhibition.setId(getIntParam(request, "id"));
        exhibition.setName(request.getParameter("name"));
        exhibition.setType(request.getParameter("type"));
        exhibition.setDescription(request.getParameter("description"));
        exhibition.setAddress(request.getParameter("address"));
        exhibition.setContactPhone(request.getParameter("contactPhone"));
        exhibition.setCoverImage(request.getParameter("coverImage"));
        exhibition.setStatus(Integer.valueOf(request.getParameter("status") != null ? request.getParameter("status") : "0"));
        String startTimeStr = request.getParameter("startTime");
        if (startTimeStr != null && !startTimeStr.isEmpty()) {
            String formatted = startTimeStr.replace('T', ' ') + ":00";
            exhibition.setStartTime(Timestamp.valueOf(formatted));
        }
        String endTimeStr = request.getParameter("endTime");
        if (endTimeStr != null && !endTimeStr.isEmpty()) {
            String formatted = endTimeStr.replace('T', ' ') + ":00";
            exhibition.setEndTime(Timestamp.valueOf(formatted));
        }
        return exhibition;
    }

    // 从 form 参数中解析票务列表
    private List<Ticket> parseTicketsFromMultipart(HttpServletRequest request, String exhibitionName) {
        Map<Integer, Ticket> ticketMap = new HashMap<>();
        Pattern pattern = Pattern.compile("tickets\\[(\\d+)\\]\\[([a-zA-Z]+)\\]");
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            Matcher matcher = pattern.matcher(paramName);
            if (matcher.matches()) {
                int idx = Integer.parseInt(matcher.group(1));
                String field = matcher.group(2);
                String value = request.getParameter(paramName);
                Ticket ticket = ticketMap.computeIfAbsent(idx, k -> new Ticket());
                switch (field) {
                    case "id":
                        if (value != null && !value.isEmpty()) {
                            ticket.setId(Integer.parseInt(value));
                        }
                        break;
                    case "type":
                        ticket.setType(value);
                        ticket.setName(exhibitionName + " - " + value);
                        break;
                    case "price":
                        ticket.setPrice(Double.parseDouble(value));
                        break;
                    case "totalQuantity":
                        int qty = Integer.parseInt(value);
                        ticket.setTotalQuantity(qty);
                        ticket.setRemainingQuantity(qty);
                        break;
                    case "limitQuantity":
                        ticket.setRemainingQuantity(Integer.parseInt(value));
                        break;
                    case "description":
                        ticket.setDescription(value);
                        break;
                }
            }
        }
        List<Ticket> tickets = new ArrayList<>(ticketMap.values());
        // 统一设置时间和状态
        for (Ticket ticket : tickets) {
            if (ticket.getId() == null) { // 新增票种
                ticket.setCreateTime(new Timestamp(System.currentTimeMillis()));
            }
            ticket.setUpdateTime(new Timestamp(System.currentTimeMillis()));
            ticket.setStatus("available");
        }
        return tickets;
    }

    private Integer getIntParam(HttpServletRequest request, String name) {
        String val = request.getParameter(name);
        return (val != null && !val.isEmpty()) ? Integer.parseInt(val) : null;
    }

    // 显示管理员漫展列表页面
    private void showAdminExhibitions(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        try {
            // 获取分页和筛选参数
            int page = 1;
            int pageSize = 12;
            String search = request.getParameter("search");
            String status = request.getParameter("status");
            String type = request.getParameter("type");
            // 处理页码参数
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
            // 获取漫展列表
            List<Exhibition> exhibitions = exhibitionService.getExhibitionsWithFilter(search, status, type, page, pageSize);
            request.setAttribute("exhibitions", exhibitions);
            // 获取总数，计算总页数
            int totalExhibitions = exhibitionService.getTotalExhibitionsCount(search, status, type);
            int totalPages = (int) Math.ceil((double) totalExhibitions / pageSize);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            // 统计各种状态的漫展数量
            int activeCount = exhibitionService.getActiveExhibitionsCount();
            int upcomingCount = exhibitionService.getUpcomingExhibitionsCount();
            int endedCount = totalExhibitions - activeCount - upcomingCount;
            request.setAttribute("totalExhibitions", totalExhibitions);
            request.setAttribute("activeExhibitions", activeCount);
            request.setAttribute("upcomingExhibitions", upcomingCount);
            request.setAttribute("endedExhibitions", endedCount);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("exhibitions", new ArrayList<>());
            request.setAttribute("totalExhibitions", 0);
            request.setAttribute("activeExhibitions", 0);
            request.setAttribute("upcomingExhibitions", 0);
            request.setAttribute("endedExhibitions", 0);
            request.setAttribute("currentPage", 1);
            request.setAttribute("totalPages", 1);
        }
        request.getRequestDispatcher("/WEB-INF/views/ticket/admin/exhibitionsadmin.jsp").forward(request, response);
    }

    // 显示编辑表单
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Exhibition exhibition = exhibitionService.getExhibitionById(id);
        if (exhibition == null) {
            throw new BaseException(404, "漫展不存在");
        }
        // 获取该漫展下的所有票务信息
        List<Ticket> tickets = ticketService.getTicketsByExhibitionId(id);
        exhibition.setTickets(tickets);
        request.setAttribute("exhibition", exhibition);
        request.getRequestDispatcher("/WEB-INF/views/ticket/admin/exhibitionsadd.jsp").forward(request, response);
    }

    // 结束漫展
    private void endExhibition(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            exhibitionService.updateExhibitionStatus(id, 3);
            response.getWriter().write("success");
        } catch (Exception e) {
            response.getWriter().write("failed: " + e.getMessage());
        }
    }

    // 显示当前咨询用户页面
    private void showConsultingUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/ticket/admin/consultingUsers.jsp").forward(request, response);
    }

    // 获取当前咨询用户列表
    private void getConsultingUsers(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try {
            List<Map<String, Object>> users = getConsultingUsersList();
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("users", users);
            ObjectMapper mapper = new ObjectMapper();
            response.getWriter().write(mapper.writeValueAsString(result));
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "获取咨询用户列表失败");
            ObjectMapper mapper = new ObjectMapper();
            response.getWriter().write(mapper.writeValueAsString(result));
        }
    }

    // 获取聊天历史
    private void getChatHistory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String userId = request.getParameter("userId");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try {
            List<Map<String, Object>> messages = getChatMessages(userId);
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("messages", messages);
            ObjectMapper mapper = new ObjectMapper();
            response.getWriter().write(mapper.writeValueAsString(result));
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "获取聊天历史失败");
            ObjectMapper mapper = new ObjectMapper();
            response.getWriter().write(mapper.writeValueAsString(result));
        }
    }

    // 发送消息
    private void sendMessage(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String userId = request.getParameter("userId");
        String content = request.getParameter("content");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try {
            boolean success = sendMessageToUser(userId, content);
            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            result.put("message", success ? "消息发送成功" : "消息发送失败");
            ObjectMapper mapper = new ObjectMapper();
            response.getWriter().write(mapper.writeValueAsString(result));
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "发送消息失败");
            ObjectMapper mapper = new ObjectMapper();
            response.getWriter().write(mapper.writeValueAsString(result));
        }
    }

    // 获取当前咨询用户列表
    private List<Map<String, Object>> getConsultingUsersList() {
        ChatMessageService chatMessageService = new ChatMessageServiceImpl();
        List<ChatMessage> users = chatMessageService.getConsultingUsers();
        List<Map<String, Object>> result = new ArrayList<>();
        for (ChatMessage user : users) {
            Map<String, Object> userMap = new HashMap<>();
            userMap.put("id", user.getUserId());
            userMap.put("username", user.getUsername());
            userMap.put("lastConsultTime", user.getTime() != null ? user.getTime().toString() : "");
            userMap.put("isOnline", true); // 这里可以添加在线状态判断逻辑
            result.add(userMap);
        }
        return result;
    }

    // 获取聊天历史
    private List<Map<String, Object>> getChatMessages(String userId) {
        ChatMessageService chatMessageService = new ChatMessageServiceImpl();
        List<ChatMessage> messages = chatMessageService.getChatHistory(Integer.parseInt(userId));
        List<Map<String, Object>> result = new ArrayList<>();
        for (ChatMessage message : messages) {
            Map<String, Object> messageMap = new HashMap<>();
            messageMap.put("sender", message.getSender());
            messageMap.put("content", message.getContent());
            messageMap.put("time", message.getFormattedTime());
            result.add(messageMap);
        }
        return result;
    }

    // 发送消息到用户
    private boolean sendMessageToUser(String userId, String content) {
        ChatMessageService chatMessageService = new ChatMessageServiceImpl();
        ChatMessage message = new ChatMessage();
        message.setUserId(Integer.parseInt(userId));
        message.setUsername("用户" + userId);
        message.setContent(content);
        message.setSender("admin");
        message.setTime(new Timestamp(System.currentTimeMillis()));
        return chatMessageService.saveMessage(message);
    }

    // 显示售票情况页面
    private void showExhibitionSales(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int exhibitionId = Integer.parseInt(request.getParameter("id"));
        Exhibition exhibition = exhibitionService.getExhibitionById(exhibitionId);
        if (exhibition == null) {
            throw new BaseException(404, "漫展不存在");
        }
        // 获取该漫展的所有订单
        List<Order> orders = orderService.getOrdersByExhibitionId(exhibitionId);
        // 统计售票数据
        int totalOrders = orders.size();
        int paidOrders = 0;
        int cancelledOrders = 0;
        double totalRevenue = 0;
        // 获取票种信息
        List<Ticket> tickets = ticketService.getTicketsByExhibitionId(exhibitionId);
        Map<Integer, Ticket> ticketMap = new HashMap<>();
        for (Ticket ticket : tickets) {
            ticketMap.put(ticket.getId(), ticket);
        }
        // 统计每个票种的售票情况
        Map<Integer, Integer> ticketSalesCount = new HashMap<>();
        Map<Integer, Double> ticketSalesAmount = new HashMap<>();
        for (Order order : orders) {
            if ("paid".equals(order.getStatus())) { // 已支付
                paidOrders++;
                totalRevenue += order.getTotalAmount();
                // 统计票种销售
                OrderItem orderItem = orderService.getOrderItemsByOrderId(order.getId());
                if (orderItem != null && ticketMap.containsKey(orderItem.getTicketId())) {
                    int ticketId = orderItem.getTicketId();
                    ticketSalesCount.put(ticketId, ticketSalesCount.getOrDefault(ticketId, 0) + orderItem.getQuantity());
                    ticketSalesAmount.put(ticketId, ticketSalesAmount.getOrDefault(ticketId, 0.0) + orderItem.getPrice());
                }
            } else if ("cancelled".equals(order.getStatus())) { // 已取消
                cancelledOrders++;
            }
        }
        request.setAttribute("exhibition", exhibition);
        request.setAttribute("orders", orders);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("paidOrders", paidOrders);
        request.setAttribute("cancelledOrders", cancelledOrders);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("tickets", tickets);
        request.setAttribute("ticketSalesCount", ticketSalesCount);
        request.setAttribute("ticketSalesAmount", ticketSalesAmount);
        request.getRequestDispatcher("/WEB-INF/views/ticket/admin/exhibitionsales.jsp").forward(request, response);
    }

    // 显示核销情况页面
    private void showExhibitionVerify(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int exhibitionId = Integer.parseInt(request.getParameter("id"));
        Exhibition exhibition = exhibitionService.getExhibitionById(exhibitionId);
        if (exhibition == null) {
            throw new BaseException(404, "漫展不存在");
        }
        // 获取该漫展的所有已支付订单
        List<Order> orders = orderService.getOrdersByExhibitionId(exhibitionId);
        List<Order> paidOrders = new ArrayList<>();
        for (Order order : orders) {
            if ("paid".equals(order.getStatus())) { // 已支付
                paidOrders.add(order);
            }
        }
        // 统计核销数据
        int totalTickets = 0;
        int verifiedTickets = 0;
        int unverifiedTickets = 0;
        List<Map<String, Object>> orderVerifyDetails = new ArrayList<>();
        for (Order order : paidOrders) {
            OrderItem orderItem = orderService.getOrderItemsByOrderId(order.getId());
            if (orderItem != null) {
                totalTickets += orderItem.getQuantity();
                Map<String, Object> orderDetail = new HashMap<>();
                orderDetail.put("id", order.getId());
                orderDetail.put("userName", order.getUserName());
                Ticket ticket = ticketService.getTicketByorderId(order.getId());
                if (ticket != null) {
                    order.setTicketName(ticket.getName());
                }
                UserTicket userTicket = userTicketDao.getUserTicketByorderid(order.getId());
                orderDetail.put("ticketName", order.getTicketName());
                orderDetail.put("quantity", orderItem.getQuantity());
                orderDetail.put("totalPrice", orderItem.getPrice());
                orderDetail.put("createTime", order.getCreateTime());
                orderDetail.put("verifyCode", userTicket.getVerifyCode());
                orderDetail.put("verifyStatus", userTicket.getStatus());
                orderDetail.put("verifyTime", userTicket.getUseTime());
                if (userTicket.getStatus().intValue() == 1) {
                    verifiedTickets += orderItem.getQuantity();
                } else {
                    unverifiedTickets += orderItem.getQuantity();
                }
                orderVerifyDetails.add(orderDetail);
            }
        }
        request.setAttribute("exhibition", exhibition);
        request.setAttribute("orders", paidOrders);
        request.setAttribute("totalTickets", totalTickets);
        request.setAttribute("verifiedTickets", verifiedTickets);
        request.setAttribute("unverifiedTickets", unverifiedTickets);
        request.setAttribute("verifyRate", totalTickets > 0 ? String.format("%.2f", (double) verifiedTickets / totalTickets * 100) : "0");
        request.setAttribute("orderVerifyDetails", orderVerifyDetails);
        request.getRequestDispatcher("/WEB-INF/views/ticket/admin/exhibitionverify.jsp").forward(request, response);
    }

    // 获取JSON格式的售票数据
    private void getExhibitionSales(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int exhibitionId = Integer.parseInt(request.getParameter("id"));
        List<Order> orders = orderService.getOrdersByExhibitionId(exhibitionId);
        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("orders", orders);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(mapper.writeValueAsString(result));
    }

    // 获取JSON格式的核销数据
    private void getExhibitionVerify(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int exhibitionId = Integer.parseInt(request.getParameter("id"));
        List<Order> orders = orderService.getOrdersByExhibitionId(exhibitionId);
        List<Order> paidOrders = new ArrayList<>();
        for (Order order : orders) {
            if ("paid".equals(order.getStatus())) { // 已支付
                paidOrders.add(order);
            }
        }
        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("orders", paidOrders);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(mapper.writeValueAsString(result));
    }
}