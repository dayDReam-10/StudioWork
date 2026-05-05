package com.assessment.www.dao.ticket;

import com.assessment.www.exception.BaseException;
import com.assessment.www.po.ticket.Exhibition;
import com.assessment.www.po.ticket.Ticket;
import com.assessment.www.Util.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;

public class ExhibitionDaoImpl implements ExhibitionDao {
    @Override
    public List<Exhibition> getActiveExhibitions() {
        List<Exhibition> exhibitions = new ArrayList<>();
        String sql = "SELECT *,(SELECT GROUP_CONCAT(price SEPARATOR ',')  FROM tickets WHERE exhibition_id = exhibitions.id) AS ticket_prices FROM exhibitions WHERE status=1  ORDER BY start_time ASC";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Exhibition exhibition = new Exhibition();
                exhibition.setId(rs.getInt("id"));
                exhibition.setName(rs.getString("name"));
                exhibition.setType(rs.getString("type"));
                exhibition.setDescription(rs.getString("description"));
                exhibition.setAddress(rs.getString("address"));
                exhibition.setContactPhone(rs.getString("contact_phone"));
                exhibition.setStartTime(rs.getTimestamp("start_time"));
                exhibition.setEndTime(rs.getTimestamp("end_time"));
                exhibition.setCoverImage(rs.getString("cover_image"));
                exhibition.setStatus(rs.getInt("status"));
                exhibition.setCreateTime(rs.getTimestamp("create_time"));
                exhibition.setUpdateTime(rs.getTimestamp("update_time"));
                exhibition.setTicketprice(rs.getString("ticket_prices"));
                exhibitions.add(exhibition);
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return exhibitions;
    }

    @Override
    public List<Exhibition> getExhibitionsByType(String type) {
        List<Exhibition> exhibitions = new ArrayList<>();
        String sql = "SELECT *,(SELECT GROUP_CONCAT(price SEPARATOR ',') FROM tickets WHERE exhibition_id = exhibitions.id) AS ticket_prices FROM exhibitions WHERE type = ? AND status = 1 ORDER BY start_time ASC";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, type);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Exhibition exhibition = mapExhibition(rs);
                    exhibitions.add(exhibition);
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "查询漫展活动失败", e);
        }
        return exhibitions;
    }

    @Override
    public List<Exhibition> getExhibitionsByTime(String timeRange) {
        Timestamp[] timeRangeBounds = getTimeRangeBounds(timeRange);
        if (timeRangeBounds == null) {
            return getActiveExhibitions();
        }

        List<Exhibition> exhibitions = new ArrayList<>();
        String sql = "SELECT *,(SELECT GROUP_CONCAT(price SEPARATOR ',') FROM tickets WHERE exhibition_id = exhibitions.id) AS ticket_prices FROM exhibitions WHERE status = 1 AND start_time >= ? AND start_time < ? ORDER BY start_time ASC";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setTimestamp(1, timeRangeBounds[0]);
            pstmt.setTimestamp(2, timeRangeBounds[1]);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Exhibition exhibition = mapExhibition(rs);
                    exhibitions.add(exhibition);
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "查询漫展活动失败", e);
        }
        return exhibitions;
    }

    @Override
    public List<Exhibition> getExhibitionsByTypeAndTime(String type, String timeRange) {
        Timestamp[] timeRangeBounds = getTimeRangeBounds(timeRange);
        if (timeRangeBounds == null) {
            return getExhibitionsByType(type);
        }

        List<Exhibition> exhibitions = new ArrayList<>();
        String sql = "SELECT *,(SELECT GROUP_CONCAT(price SEPARATOR ',') FROM tickets WHERE exhibition_id = exhibitions.id) AS ticket_prices FROM exhibitions WHERE type = ? AND status = 1 AND start_time >= ? AND start_time < ? ORDER BY start_time ASC";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, type);
            pstmt.setTimestamp(2, timeRangeBounds[0]);
            pstmt.setTimestamp(3, timeRangeBounds[1]);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Exhibition exhibition = mapExhibition(rs);
                    exhibitions.add(exhibition);
                }
            }
        } catch (SQLException e) {
            throw new BaseException(500, "查询漫展活动失败", e);
        }
        return exhibitions;
    }

    private Timestamp[] getTimeRangeBounds(String timeRange) {
        LocalDate today = LocalDate.now();
        LocalDateTime start;
        LocalDateTime end;
        switch (timeRange) {
            case "week":
                LocalDate weekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
                start = weekStart.atStartOfDay();
                end = weekStart.plusWeeks(1).atStartOfDay();
                break;
            case "month":
                LocalDate monthStart = today.withDayOfMonth(1);
                start = monthStart.atStartOfDay();
                end = monthStart.plusMonths(1).atStartOfDay();
                break;
            default:
                return null;
        }
        return new Timestamp[]{Timestamp.valueOf(start), Timestamp.valueOf(end)};
    }

    private Exhibition mapExhibition(ResultSet rs) throws SQLException {
        Exhibition exhibition = new Exhibition();
        exhibition.setId(rs.getInt("id"));
        exhibition.setName(rs.getString("name"));
        exhibition.setType(rs.getString("type"));
        exhibition.setDescription(rs.getString("description"));
        exhibition.setAddress(rs.getString("address"));
        exhibition.setContactPhone(rs.getString("contact_phone"));
        exhibition.setStartTime(rs.getTimestamp("start_time"));
        exhibition.setEndTime(rs.getTimestamp("end_time"));
        exhibition.setCoverImage(rs.getString("cover_image"));
        exhibition.setStatus(rs.getInt("status"));
        exhibition.setCreateTime(rs.getTimestamp("create_time"));
        exhibition.setUpdateTime(rs.getTimestamp("update_time"));
        exhibition.setTicketprice(rs.getString("ticket_prices"));
        return exhibition;
    }

    @Override
    public Exhibition getExhibitionById(Integer id) {
        Exhibition exhibition = null;
        String sql = "SELECT * FROM exhibitions WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    exhibition = new Exhibition();
                    exhibition.setId(rs.getInt("id"));
                    exhibition.setName(rs.getString("name"));
                    exhibition.setType(rs.getString("type"));
                    exhibition.setDescription(rs.getString("description"));
                    exhibition.setAddress(rs.getString("address"));
                    exhibition.setContactPhone(rs.getString("contact_phone"));
                    exhibition.setStartTime(rs.getTimestamp("start_time"));
                    exhibition.setEndTime(rs.getTimestamp("end_time"));
                    exhibition.setCoverImage(rs.getString("cover_image"));
                    exhibition.setStatus(rs.getInt("status"));
                    exhibition.setCreateTime(rs.getTimestamp("create_time"));
                    exhibition.setUpdateTime(rs.getTimestamp("update_time"));
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return exhibition;
    }

    @Override
    public void addExhibition(Exhibition exhibition) {
        String sql = "INSERT INTO exhibitions (name, type, description, address, contact_phone, start_time, end_time, cover_image, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, exhibition.getName());
            pstmt.setString(2, exhibition.getType());
            pstmt.setString(3, exhibition.getDescription());
            pstmt.setString(4, exhibition.getAddress());
            pstmt.setString(5, exhibition.getContactPhone());
            pstmt.setTimestamp(6, exhibition.getStartTime());
            pstmt.setTimestamp(7, exhibition.getEndTime());
            pstmt.setString(8, exhibition.getCoverImage());
            pstmt.setInt(9, exhibition.getStatus());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public void updateExhibition(Exhibition exhibition) {
        String sql = "UPDATE exhibitions SET name = ?, type = ?, description = ?, address = ?, contact_phone = ?, start_time = ?, end_time = ?, cover_image = ?, status = ? WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, exhibition.getName());
            pstmt.setString(2, exhibition.getType());
            pstmt.setString(3, exhibition.getDescription());
            pstmt.setString(4, exhibition.getAddress());
            pstmt.setString(5, exhibition.getContactPhone());
            pstmt.setTimestamp(6, exhibition.getStartTime());
            pstmt.setTimestamp(7, exhibition.getEndTime());
            pstmt.setString(8, exhibition.getCoverImage());
            pstmt.setInt(9, exhibition.getStatus());
            pstmt.setInt(10, exhibition.getId());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public void deleteExhibition(Integer id) {
        String sql = "DELETE FROM exhibitions WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public void deleteExhibitiontickets(Integer id) {
        String sql = "DELETE FROM tickets WHERE exhibition_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new BaseException(500, "执行删除票务信息失败", e);
        }
    }

    @Override
    public int getTicketSalesCount(Integer exhibitionId) {
        int count = 0;
        String sql = "SELECT SUM(quantity) as total_sales FROM order_item WHERE ticket_id IN (SELECT id FROM tickets WHERE exhibition_id = ?)";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, exhibitionId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt("total_sales");
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return count;
    }

    @Override
    public int getTicketVerifyCount(Integer exhibitionId) {
        int count = 0;
        String sql = "SELECT COUNT(*) as verify_count FROM order_item WHERE ticket_id IN (SELECT id FROM tickets WHERE exhibition_id = ?) AND status = 1";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, exhibitionId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt("verify_count");
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return count;
    }

    @Override
    public int getUserFavoritesCount(int userId) {
        String sql = "SELECT COUNT(*) FROM user_favorites WHERE user_id = ? ";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return 0;
    }

    @Override
    public List<Exhibition> getUserFavorites(Integer userId,int page,int pagesize) {
        List<Exhibition> exhibitions = new ArrayList<>();
        String sql = "SELECT e.* FROM exhibitions e " +
                "INNER JOIN user_favorites uf ON e.id = uf.exhibition_id " +
                "WHERE uf.user_id = ? AND e.status = 1";
        int offset = (page - 1) * pagesize;
        if (offset >= 0) {
            sql += " LIMIT " + offset + "," + pagesize + " ";
        }
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Exhibition exhibition = new Exhibition();
                    exhibition.setId(rs.getInt("id"));
                    exhibition.setName(rs.getString("name"));
                    exhibition.setType(rs.getString("type"));
                    exhibition.setDescription(rs.getString("description"));
                    exhibition.setAddress(rs.getString("address"));
                    exhibition.setContactPhone(rs.getString("contact_phone"));
                    exhibition.setStartTime(rs.getTimestamp("start_time"));
                    exhibition.setEndTime(rs.getTimestamp("end_time"));
                    exhibition.setCoverImage(rs.getString("cover_image"));
                    exhibition.setStatus(rs.getInt("status"));
                    exhibition.setCreateTime(rs.getTimestamp("create_time"));
                    exhibition.setUpdateTime(rs.getTimestamp("update_time"));
                    exhibitions.add(exhibition);
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return exhibitions;
    }

    @Override
    public void addFavorite(Integer userId, Integer exhibitionId) {
        String sql = "INSERT INTO user_favorites (user_id, exhibition_id,create_time) VALUES (?, ?,now())";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, exhibitionId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public void removeFavorite(Integer userId, Integer exhibitionId) {
        String sql = "DELETE FROM user_favorites WHERE user_id = ? AND exhibition_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, exhibitionId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public boolean isFavorite(Integer userId, Integer exhibitionId) {
        String sql = "SELECT COUNT(*) FROM user_favorites WHERE user_id = ? AND exhibition_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, exhibitionId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return false;
    }

    @Override
    public List<Exhibition> getUserExhibitionHistory(Integer userId) {
        List<Exhibition> exhibitions = new ArrayList<>();
        String sql = "SELECT DISTINCT e.* FROM exhibitions e " +
                "INNER JOIN orders o ON e.id = o.exhibition_id " +
                "WHERE o.user_id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Exhibition exhibition = new Exhibition();
                    exhibition.setId(rs.getInt("id"));
                    exhibition.setName(rs.getString("name"));
                    exhibition.setType(rs.getString("type"));
                    exhibition.setDescription(rs.getString("description"));
                    exhibition.setAddress(rs.getString("address"));
                    exhibition.setContactPhone(rs.getString("contact_phone"));
                    exhibition.setStartTime(rs.getTimestamp("start_time"));
                    exhibition.setEndTime(rs.getTimestamp("end_time"));
                    exhibition.setCoverImage(rs.getString("cover_image"));
                    exhibition.setStatus(rs.getInt("status"));
                    exhibition.setCreateTime(rs.getTimestamp("create_time"));
                    exhibition.setUpdateTime(rs.getTimestamp("update_time"));
                    exhibitions.add(exhibition);
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return exhibitions;
    }

    @Override
    public int saveOrupdate(Exhibition exhibition) {
        String sql;
        if (exhibition.getId() != null) { // 更新
            sql = "UPDATE exhibitions SET name = ?, type = ?, description = ?, address = ?, contact_phone = ?, start_time = ?, end_time = ?, cover_image = ?, status = ?, update_time = NOW() WHERE id = ?";
            try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, exhibition.getName());
                pstmt.setString(2, exhibition.getType());
                pstmt.setString(3, exhibition.getDescription());
                pstmt.setString(4, exhibition.getAddress());
                pstmt.setString(5, exhibition.getContactPhone());
                pstmt.setTimestamp(6, exhibition.getStartTime());
                pstmt.setTimestamp(7, exhibition.getEndTime());
                pstmt.setString(8, exhibition.getCoverImage());
                pstmt.setInt(9, exhibition.getStatus());
                pstmt.setInt(10, exhibition.getId());
                pstmt.executeUpdate();
                return exhibition.getId();
            } catch (SQLException e) {
                throw  new BaseException(500,"操作失败",e);
            }
        } else {// 新建草稿
            sql = "INSERT INTO exhibitions (name, type, description, address, contact_phone, start_time, end_time, cover_image, status, create_time, update_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
            try (Connection conn = utils.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                pstmt.setString(1, exhibition.getName());
                pstmt.setString(2, exhibition.getType());
                pstmt.setString(3, exhibition.getDescription());
                pstmt.setString(4, exhibition.getAddress());
                pstmt.setString(5, exhibition.getContactPhone());
                pstmt.setTimestamp(6, exhibition.getStartTime());
                pstmt.setTimestamp(7, exhibition.getEndTime());
                pstmt.setString(8, exhibition.getCoverImage());
                pstmt.setInt(9, exhibition.getStatus());
                pstmt.executeUpdate();
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            } catch (SQLException e) {
                throw  new BaseException(500,"操作失败",e);
            }
        }
        return -1;
    }

    @Override
    public void addTicket(Ticket ticket) {
        String sql = "INSERT INTO tickets (exhibition_id, name, price, total_quantity, remaining_quantity, type, description, status, create_time, update_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, ticket.getExhibitionId());
            pstmt.setString(2, ticket.getName());
            pstmt.setDouble(3, ticket.getPrice());
            pstmt.setInt(4, ticket.getTotalQuantity());
            pstmt.setInt(5, ticket.getRemainingQuantity());
            pstmt.setString(6, ticket.getType());
            pstmt.setString(7, ticket.getDescription());
            pstmt.setString(8, ticket.getStatus());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }

    @Override
    public void updateTicket(Ticket ticket) {
        String sql = "update tickets set name=?, price=?, total_quantity=?,description=?,  update_time=NOW()  where id=? ";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, ticket.getName());
            pstmt.setDouble(2, ticket.getPrice());
            pstmt.setInt(3, ticket.getTotalQuantity());
            pstmt.setString(4, ticket.getDescription());
            pstmt.setInt(5, ticket.getId());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new BaseException(500, "更新票务数据失败", e);
        }
    }

    @Override
    public int getActiveExhibitionsCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) as total_count FROM exhibitions WHERE status != 2 AND status != 0";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt("total_count");
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return count;
    }

    @Override
    public int getUpcomingExhibitionsCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) as total_count FROM exhibitions WHERE status = 1 AND start_time > NOW()";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt("total_count");
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return count;
    }

    @Override
    public List<Exhibition> getRecentExhibitions(int limit) {
        List<Exhibition> exhibitions = new ArrayList<>();
        String sql = "SELECT * FROM exhibitions WHERE status = 1 ORDER BY create_time DESC LIMIT ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Exhibition exhibition = new Exhibition();
                    exhibition.setId(rs.getInt("id"));
                    exhibition.setName(rs.getString("name"));
                    exhibition.setType(rs.getString("type"));
                    exhibition.setDescription(rs.getString("description"));
                    exhibition.setAddress(rs.getString("address"));
                    exhibition.setContactPhone(rs.getString("contact_phone"));
                    exhibition.setStartTime(rs.getTimestamp("start_time"));
                    exhibition.setEndTime(rs.getTimestamp("end_time"));
                    exhibition.setCoverImage(rs.getString("cover_image"));
                    exhibition.setStatus(rs.getInt("status"));
                    exhibition.setCreateTime(rs.getTimestamp("create_time"));
                    exhibition.setUpdateTime(rs.getTimestamp("update_time"));
                    exhibitions.add(exhibition);
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return exhibitions;
    }

    @Override
    public List<Exhibition> getExhibitionsWithFilter(String search, String status, String type, int page, int pageSize) {
        List<Exhibition> exhibitions = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM exhibitions WHERE 1=1");
        // 添加搜索条件
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR description LIKE ?)");
        }
        // 添加状态筛选
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
        }
        // 添加类型筛选
        if (type != null && !type.trim().isEmpty()) {
            sql.append(" AND type = ?");
        }
        // 排序
        sql.append(" ORDER BY create_time DESC");
        // 分页
        sql.append(" LIMIT ? OFFSET ?");
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            // 设置搜索参数
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                pstmt.setString(paramIndex++, searchPattern);
                pstmt.setString(paramIndex++, searchPattern);
            }
            // 设置状态参数
            if (status != null && !status.trim().isEmpty()) {
                pstmt.setString(paramIndex++, status);
            }
            // 设置类型参数
            if (type != null && !type.trim().isEmpty()) {
                pstmt.setString(paramIndex++, type);
            }
            // 设置分页参数
            pstmt.setInt(paramIndex++, pageSize);
            pstmt.setInt(paramIndex, (page - 1) * pageSize);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Exhibition exhibition = new Exhibition();
                    exhibition.setId(rs.getInt("id"));
                    exhibition.setName(rs.getString("name"));
                    exhibition.setType(rs.getString("type"));
                    exhibition.setDescription(rs.getString("description"));
                    exhibition.setAddress(rs.getString("address"));
                    exhibition.setContactPhone(rs.getString("contact_phone"));
                    exhibition.setStartTime(rs.getTimestamp("start_time"));
                    exhibition.setEndTime(rs.getTimestamp("end_time"));
                    exhibition.setCoverImage(rs.getString("cover_image"));
                    exhibition.setStatus(rs.getInt("status"));
                    exhibition.setCreateTime(rs.getTimestamp("create_time"));
                    exhibition.setUpdateTime(rs.getTimestamp("update_time"));
                    exhibitions.add(exhibition);
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return exhibitions;
    }

    @Override
    public int getTotalExhibitionsCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) as total_count FROM exhibitions";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt("total_count");
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return count;
    }

    @Override
    public int getTotalExhibitionsCount(String search, String status, String type) {
        int count = 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) as total_count FROM exhibitions WHERE 1=1");
        // 添加搜索条件
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR description LIKE ?)");
        }
        // 添加状态筛选
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
        }
        // 添加类型筛选
        if (type != null && !type.trim().isEmpty()) {
            sql.append(" AND type = ?");
        }
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            // 设置搜索参数
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search + "%";
                pstmt.setString(paramIndex++, searchPattern);
                pstmt.setString(paramIndex++, searchPattern);
            }
            // 设置状态参数
            if (status != null && !status.trim().isEmpty()) {
                pstmt.setString(paramIndex++, status);
            }
            // 设置类型参数
            if (type != null && !type.trim().isEmpty()) {
                pstmt.setString(paramIndex, type);
            }
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt("total_count");
                }
            }
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
        return count;
    }

    @Override
    public void updateExhibitionStatus(Integer id, int status) {
        String sql = "UPDATE exhibitions SET status = ?, update_time = NOW() WHERE id = ?";
        try (Connection conn = utils.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, status);
            pstmt.setInt(2, id);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw  new BaseException(500,"操作失败",e);
        }
    }
}