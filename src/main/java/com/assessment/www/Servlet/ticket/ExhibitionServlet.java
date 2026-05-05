package com.assessment.www.Servlet.ticket;

import com.assessment.www.Service.ticket.*;
import com.assessment.www.Util.AuthUtil;
import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ticket.Exhibition;
import com.assessment.www.po.ticket.OrderItem;
import com.assessment.www.po.ticket.Ticket;
import com.assessment.www.po.ticket.Order;
import com.assessment.www.po.User;
import com.assessment.www.Service.UserService;
import com.assessment.www.Service.UserServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

@WebServlet("/ticket/*")
public class ExhibitionServlet extends HttpServlet {//票务处理接口
    private ExhibitionService exhibitionService;
    private TicketService ticketService;
    private OrderService orderService;
    private UserService userService;
    // ---------- 限流相关 ----------
    private static final ConcurrentHashMap<Integer, RateLimitInfo> purchaseRateLimitMap = new ConcurrentHashMap<>();
    private static final int PURCHASE_LIMIT = 10;          // 限制次数
    private static final int PURCHASE_WINDOW_SECONDS = 60; // 时间窗口

    private boolean checkPurchaseRateLimit(int userId) {//检查用户购票请求是否超过频率限制 1分钟10次
        long now = System.currentTimeMillis();
        RateLimitInfo info = purchaseRateLimitMap.compute(userId, (id, existing) -> {
            if (existing == null || now - existing.windowStart > PURCHASE_WINDOW_SECONDS * 1000L) {
                return new RateLimitInfo(1, now);
            } else {
                if (existing.count < PURCHASE_LIMIT) {
                    existing.count++;
                    return existing;
                } else {
                    return existing;
                }
            }
        });
        return info.count <= PURCHASE_LIMIT;
    }

    private static class RateLimitInfo {//限流信息内部类
        int count;
        long windowStart;

        RateLimitInfo(int count, long windowStart) {
            this.count = count;
            this.windowStart = windowStart;
        }
    }

    @Override
    public void init() {
        exhibitionService = new ExhibitionServiceImpl();
        ticketService = new TicketServiceImpl();
        orderService = new OrderServiceImpl();
        userService = new UserServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/ticket/exhibitions");
            return;
        }
        switch (pathInfo) {
            case "/index"://漫展首页
                showExhibitionList(request, response);
                break;
            case "/exhibitions/list":
                listExhibitions(request, response);
                break;
            case "/exhibition-details"://漫展详细信息
                showExhibitionDetails(request, response);
                break;
            case "/getFavorites"://收藏接口信息返回
                getFavorites(request, response);
                break;
            case "/myorders"://订单页面
                showUserOrders(request, response);
                break;
            case "/payment"://支付页面
                showPaymentPage(request, response);
                break;
            default:
                throw new BaseException(404, "页面不存在");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            throw new BaseException(400, "错误请求");
        }
        switch (pathInfo) {
            case "/favorite"://收藏
                favoriteExhibition(request, response);
                break;
            case "/unfavorite"://取消收藏
                unfavoriteExhibition(request, response);
                break;
            case "/purchase"://下订单操作
                purchaseTicket(request, response);
                break;
            case "/refundding"://发起申请退票
                processRefundding(request, response);
                break;
            case "/refund"://确认退票操作
                processRefund(request, response);
                break;
            case "/cancal"://取消订单操作
                processCancal(request, response);
                break;
            case "/doPayment"://支付操作
                dealPayment(request, response);
                break;
            default:
                throw new BaseException(404, "接口不存在");
        }
    }

    private void dealPayment(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        String orderId = request.getParameter("orderId");
        String paymentMethod = request.getParameter("paymentMethod");
        boolean flag = orderService.changeOrder(orderId, paymentMethod);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\":true,\"message\":\"支付成功\"}");
    }

    // 获取漫展列表
    private void listExhibitions(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            List<Exhibition> exhibitions = exhibitionService.getExhibitions(null, null);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"exhibitions\":[");
            for (int i = 0; i < exhibitions.size(); i++) {
                Exhibition e = exhibitions.get(i);
                json.append("{")
                        .append("\"id\":").append(e.getId()).append(",")
                        .append("\"name\":\"").append(e.getName()).append("\",")
                        .append("\"type\":\"").append(e.getType()).append("\",")
                        .append("\"description\":\"").append(e.getDescription() != null ? e.getDescription().replace("\"", "\\\"") : "").append("\",")
                        .append("\"address\":\"").append(e.getAddress()).append("\",")
                        .append("\"contactPhone\":\"").append(e.getContactPhone()).append("\",")
                        .append("\"startTime\":\"").append(e.getStartTime()).append("\",")
                        .append("\"endTime\":\"").append(e.getEndTime()).append("\",")
                        .append("\"coverImage\":\"").append(e.getCoverImage() != null ? e.getCoverImage() : "").append("\",")
                        .append("\"status\":\"").append(e.getStatus()).append("\"");
                json.append("}");
                if (i < exhibitions.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]}");
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"获取漫展列表失败\"}");
        }
    }

    // 显示展览列表
    private void showExhibitionList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        String timeRange = request.getParameter("timeRange");
        List<Exhibition> exhibitions = exhibitionService.getExhibitions(type, timeRange);
        request.setAttribute("exhibitions", exhibitions);
        request.setAttribute("currentType", type != null ? type : "all");
        request.setAttribute("currentTimeRange", timeRange != null ? timeRange : "all");
        request.getRequestDispatcher("/WEB-INF/views/ticket/index.jsp").forward(request, response);
    }

    // 显示展览详情
    private void showExhibitionDetails(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int exhibitionId = Integer.parseInt(request.getParameter("id"));
        Exhibition exhibition = exhibitionService.getExhibitionById(exhibitionId);
        if (exhibition == null) {
            throw new BaseException(404, "展览不存在");
        }
        List<Ticket> tickets = ticketService.getTicketsByExhibitionId(exhibitionId);
        request.setAttribute("exhibition", exhibition);
        request.setAttribute("tickets", tickets);
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user != null) {
            boolean isFavorited = exhibitionService.isFavorite(user.getId(), exhibitionId);
            request.setAttribute("isFavorited", isFavorited);
        }
        request.getRequestDispatcher("/WEB-INF/views/ticket/exhibitiondetails.jsp").forward(request, response);
    }

    // 显示用户订单
    private void showUserOrders(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
            page = 1;
        }
        String status = request.getParameter("status");
        List<Order> orders = orderService.getUserOrders(user.getId(), status, page, 5);
        // 填充展览名称和票种名称
        for (Order order : orders) {
            Exhibition exhibition = exhibitionService.getExhibitionById(order.getExhibitionId());
            if (exhibition != null) {
                order.setExhibitionName(exhibition.getName());
            }
            Ticket ticket = ticketService.getTicketByorderId(order.getId());
            if (ticket != null) {
                order.setTicketName(ticket.getName());
            }
        }
        int totalCount = orderService.getTotalOrderCount(user.getId(), status);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", (int) Math.ceil((double) totalCount / 10));
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/WEB-INF/views/ticket/myorders.jsp").forward(request, response);
    }

    // 收藏展览
    private void favoriteExhibition(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!AuthUtil.isLoggedIn(request)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }
        User user = AuthUtil.getCurrentUser(request);
        int exhibitionId = Integer.parseInt(request.getParameter("id"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (exhibitionService.addFavorite(user.getId(), exhibitionId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"收藏成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"收藏失败\"}");
        }
    }

    // 取消收藏展览
    private void unfavoriteExhibition(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!AuthUtil.isLoggedIn(request)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }
        User user = AuthUtil.getCurrentUser(request);
        int exhibitionId = Integer.parseInt(request.getParameter("id"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (exhibitionService.removeFavorite(user.getId(), exhibitionId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"取消收藏成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"取消收藏失败\"}");
        }
    }

    // 购票处理逻辑
    private void purchaseTicket(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!AuthUtil.isLoggedIn(request)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }
        try {
            int exhibitionId = Integer.parseInt(request.getParameter("exhibitionId"));
            int ticketId = Integer.parseInt(request.getParameter("ticketId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            User user = AuthUtil.getCurrentUser(request);
            if (!checkPurchaseRateLimit(user.getId())) {//购票限流操作
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"操作过于频繁，请稍后再试\"}");
                return;
            }
            // 验证数量限制
            if (quantity <= 0) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"购买数量必须大于0\"}");
                return;
            }
            // 验证库存
            Ticket ticket = ticketService.getTicketById(ticketId);
            if (ticket == null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"票种不存在\"}");
                return;
            }
            if (!"available".equals(ticket.getStatus())) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"该票种已停售\"}");
                return;
            }
            if (ticket.getRemainingQuantity() < quantity) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"库存不足，剩余数量：" + ticket.getRemainingQuantity() + "\"}");
                return;
            }
            // 检查个人购买限制1
            int userPurchasedCount = orderService.getUserTicketCountByTicket(user.getId(), ticketId);
            if (userPurchasedCount + quantity > 1) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"超出个人购买限制，每人最多购买1张\"}");
                return;
            }
            // 创建订单
            List<OrderItem> orderItems = new ArrayList<>();
            OrderItem item = new OrderItem();
            item.setTicketId(ticketId);
            item.setQuantity(quantity);
            item.setPrice(ticket.getPrice());
            orderItems.add(item);
            Order order = orderService.createOrder(user.getId(), exhibitionId, orderItems);
            if (order != null) {
                // 计算总价
                double totalPrice = ticket.getPrice() * quantity;
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                // 订单创建成功后返回
                response.getWriter().write(String.format(
                        "{\"success\":true,\"orderId\":%d,\"message\":\"购票成功！订单号：%d，请及时支付\",\"totalPrice\":%.2f,\"quantity\":%d}",
                        order.getId(), order.getId(), totalPrice, quantity
                ));
            } else {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"购票失败，请重试\"}");
            }
        } catch (NumberFormatException e) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"参数错误\"}");
        } catch (Exception e) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"购票失败：" + e.getMessage() + "\"}");
        }
    }

    // 处理申请退票
    private void processRefundding(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!AuthUtil.isLoggedIn(request)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }
        User user = AuthUtil.getCurrentUser(request);
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (orderService.refunddingOrder(orderId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"申请退票成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"申请退票失败\"}");
        }
    }

    // 确认处理申请退票
    private void processRefund(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!AuthUtil.isLoggedIn(request)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }
        User user = AuthUtil.getCurrentUser(request);
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (orderService.refundOrder(orderId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"确认退票成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"确认退票失败\"}");
        }
    }

    // 取消订单
    private void processCancal(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!AuthUtil.isLoggedIn(request)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }
        User user = AuthUtil.getCurrentUser(request);
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (orderService.cancelOrder(orderId)) {
            response.getWriter().write("{\"success\":true,\"message\":\"取消成功\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"取消失败\"}");
        }
    }


    private void showPaymentPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String orderIdParam = request.getParameter("orderId");
        if (orderIdParam == null || orderIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/ticket/index");
            return;
        }
        int orderId = Integer.parseInt(orderIdParam);
        Order order = orderService.getOrderById(orderId);
        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/ticket/index");
            return;
        }
        // 获取订单对应的展览和票种信息
        Exhibition exhibition = exhibitionService.getExhibitionById(order.getExhibitionId());
        Ticket ticket = ticketService.getTicketByorderId(order.getId());
        double totalAmount = order.getTotalAmount();
        int quantity = 0;
        OrderItem items = orderService.getOrderItemsByOrderId(orderId);
        if (items != null) {
            quantity = items.getQuantity();
        }
        request.setAttribute("orderId", orderId);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("quantity", quantity);
        request.setAttribute("exhibitionName", exhibition != null ? exhibition.getName() : "未知漫展");
        request.setAttribute("ticketName", ticket != null ? ticket.getName() : "未知票种");
        request.getRequestDispatcher("/WEB-INF/views/ticket/payment.jsp").forward(request, response);
    }

    // 获取用户收藏列表（分页）
    private void getFavorites(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!AuthUtil.isLoggedIn(request)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"code\":401,\"message\":\"请先登录\"}");
            return;
        }
        User user = AuthUtil.getCurrentUser(request);
        int page = 1;
        int pageSize = 10;
        try {
            page = Integer.parseInt(request.getParameter("page"));
            if (page < 1) page = 1;
        } catch (NumberFormatException ignored) {
        }
        try {
            pageSize = Integer.parseInt(request.getParameter("pageSize"));
            if (pageSize < 1) pageSize = 10;
        } catch (NumberFormatException ignored) {
        }
        int totalCount = exhibitionService.getUserFavoritesCount(user.getId());
        List<Exhibition> favorites = exhibitionService.getUserFavorites(user.getId(), page, pageSize);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.write("{\"code\":200,\"message\":\"success\",\"data\":{");
        out.write("\"list\":");
        out.write(generateExhibitionJson(favorites));
        out.write(",\"currentPage\":" + page);
        out.write(",\"totalPages\":" + totalPages);
        out.write(",\"totalCount\":" + totalCount);
        out.write("}}");
    }

    private String generateExhibitionJson(List<Exhibition> exhibitions) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < exhibitions.size(); i++) {
            if (i > 0) json.append(",");
            Exhibition e = exhibitions.get(i);
            json.append("{")
                    .append("\"id\":").append(e.getId()).append(",")
                    .append("\"name\":\"").append(escapeJson(e.getName())).append("\",")
                    .append("\"type\":\"").append(escapeJson(e.getType())).append("\",")
                    .append("\"description\":\"").append(escapeJson(e.getDescription())).append("\",")
                    .append("\"address\":\"").append(escapeJson(e.getAddress())).append("\",")
                    .append("\"startTime\":\"").append(e.getStartTime()).append("\",")
                    .append("\"endTime\":\"").append(e.getEndTime()).append("\",")
                    .append("\"coverImage\":\"").append(escapeJson(e.getCoverImage())).append("\"")
                    .append("}");
        }
        json.append("]");
        return json.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}