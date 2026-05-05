# 视频分享与漫展票务平台

一个基于 Servlet + JSP + JDBC 的视频分享与漫展票务一体化平台。纯 Java EE 技术栈，不依赖 Spring 框架，使用 Redis 缓存、WebSocket 实时通信、Druid 连接池、内嵌 Tomcat 运行。

## 项目特点

- **零框架依赖**：不使用 Spring / Spring Boot，纯 Servlet + JSP + JDBC
- **双子系统**：视频分享平台 + 漫展票务平台
- **弹幕系统**：仿 Bilibili 视频上方飘过弹幕，支持倍速播放
- **实时通信**：WebSocket 推送用户封禁、咨询聊天、票务更新
- **Redis 缓存**：视频计数缓存与异步刷新
- **自定义连接池**：Druid 连接池管理数据库连接
- **内嵌 Tomcat**：`tomcat7-maven-plugin` 一键启动，无需外部容器
- **多维权限**：用户 / 管理员角色分离，管理员分级权限
- **定时任务**：订单超时取消、票务过期处理

## 技术栈

| 技术 | 说明 |
| --- | --- |
| JDK 8 | 项目编译运行环境 |
| Maven | 构建与依赖管理 |
| Tomcat 7 (内嵌) | Servlet 容器，tomcat7-maven-plugin |
| Servlet 4.0 | `javax.servlet-api`，`@WebServlet`、`@WebFilter`、`@MultipartConfig` |
| JSP + JSTL | 视图层渲染 |
| MySQL 8 | 主数据源，17 张业务表 |
| Redis (Jedis) | 视频计数缓存、JSON 序列化缓存 |
| Druid 1.2 | 阿里巴巴数据库连接池 |
| WebSocket | 用户状态推送、咨询聊天、票务实时更新 |
| Jackson | JSON 序列化 / 反序列化 |
| BCrypt | 用户密码加密（jBCrypt） |

## 项目结构

```text
assessment/
├── platform.sql                              # 数据库初始化脚本
├── pom.xml                                   # Maven 配置
└── src/main/
    ├── java/com/assessment/www/
    │   ├── Servlet/                          # Servlet 控制器
    │   │   ├── HomeServlet.java              # @WebServlet("/") 首页
    │   │   ├── UserServlet.java              # @WebServlet("/user/*") 用户
    │   │   ├── VideoServlet.java             # /video/* 视频上传、详情、播放、点赞、收藏、投币、评论、弹幕
    │   │   ├── AdminServlet.java             # /admin/* 管理后台
    │   │   ├── ClientServlet.java            # @WebServlet("/client/*") 用户端操作
    │   │   ├── VideoStreamServlet.java       # /static/videos/* 视频流媒体（Range 支持）
    │   │   └── ticket/                       # 票务子系统
    │   │       ├── ExhibitionServlet.java    # /ticket/* 漫展票务
    │   │       ├── AdminTicketServlet.java   # /adminticket/* 票务管理
    │   │       └── ConsultationServlet.java  # /ticket/consultation/* 咨询聊天
    │   ├── Service/                          # 业务逻辑层
    │   │   ├── UserService.java / UserServiceImpl.java
    │   │   ├── VideoService.java / VideoServiceImpl.java
    │   │   ├── CheckInService.java / CheckInServiceImpl.java
    │   │   ├── CommentService.java / CommentServiceImpl.java
    │   │   ├── ReportService.java / ReportServiceImpl.java
    │   │   └── ticket/                       # 票务业务逻辑
    │   ├── dao/                              # 数据访问层（纯 JDBC）
    │   │   ├── UserDao.java / UserDaoImpl.java
    │   │   ├── VideoDao.java / VideoDaoImpl.java
    │   │   ├── CheckInDao.java / CheckInDaoImpl.java
    │   │   ├── FavoriteDao.java / FavoriteDaoImpl.java
    │   │   ├── HistoryDao.java / HistoryDaoImpl.java
    │   │   ├── ReportDao.java / ReportDaoImpl.java
    │   │   ├── ScreenCommentDao.java / ScreenCommentDaoImpl.java
    │   │   └── ticket/                       # 票务数据访问
    │   ├── po/                               # 实体类
    │   │   ├── User.java
    │   │   ├── Video.java                    # 视频：状态（待审/通过/驳回）、可见范围（公开/粉丝/互关/私密）
    │   │   ├── ScreenComment.java            # 弹幕评论：支持 videoTime 定位
    │   │   ├── Favorite.java, History.java, Like.java
    │   │   ├── Report.java, UserFollow.java, VideoCoin.java, CheckIn.java
    │   │   └── ticket/                       # 票务实体的POJO
    │   ├── constant/
    │   │   └── Constants.java                # 全局常量：角色、状态、分页、默认头像/封面
    │   ├── exception/
    │   │   ├── BaseException.java            # 自定义运行时异常（code + message）
    │   │   └── ExceptionHandler.java         # @WebFilter 全局异常过滤器
    │   └── Util/
    │       ├── utils.java                    # 连接池工厂 + 资源关闭
    │       ├── ConnectionPool.java           # Druid 连接池配置
    │       ├── RedisUtil.java               # Redis (Jedis) 连接池与 CRUD
    │       ├── RedisJsonUtil.java           # Redis JSON 序列化工具
    │       ├── AuthUtil.java                # 登录/登出/角色/权限校验
    │       ├── CharacterEncodingFilter.java  # UTF-8 编码过滤器
    │       ├── FractalThemeFilter.java       # 主题 CSS/JS 注入过滤器
    │       ├── UserStatusWebSocketEndpoint.java   # /websocket/user-status
    │       └── ticket/                       # 票务工具与 WebSocket
    └── webapp/
        ├── WEB-INF/
        │   ├── web.xml                       # Servlet/Filter 映射、错误页、Session 配置
        │   └── views/                        # JSP 视图（34 个页面）
        │       ├── index.jsp                 # 首页视频网格
        │       ├── login.jsp / register.jsp  # 登录注册
        │       ├── upload.jsp                # 视频上传
        │       ├── videoDetail.jsp           # 视频详情 + 弹幕播放器
        │       ├── player.jsp                # 独立播放页（倍速）
        │       ├── videoList.jsp             # 搜索结果
        │       ├── myVideos.jsp              # 我的视频
        │       ├── dynamic.jsp               # 关注动态 Feed
        │       ├── profile.jsp               # 个人资料编辑
        │       ├── userProfile.jsp           # 用户主页
        │       ├── history.jsp               # 浏览历史
        │       ├── error.jsp / error/        # 错误页面
        │       ├── admin/                    # 管理后台
        │       └── ticket/                   # 票务页面
        └── static/
            ├── css/                          # 主题 CSS
            ├── js/                           # 前端 JS
            ├── images/                       # 默认头像、封面
            └── videos/                       # 上传的视频文件存储目录
```

## 核心功能

### 用户模块

| 功能 | 路径 | 说明 |
| --- | --- | --- |
| 注册 | `POST /user/register` | 用户名、密码、邮箱，BCrypt 加密 |
| 登录 | `POST /user/login` | Session 认证 |
| 登出 | `GET /user/logout` | 销毁 Session |
| 个人中心 | `GET /user/me` | 查看/修改个人资料 |
| 修改资料 | `POST /user/updateProfile` | 昵称、签名、性别 |
| 修改头像 | `POST /user/updateAvatar` | `multipart/form-data` 上传 |
| 修改密码 | `POST /user/changePassword` | 校验旧密码 |
| 用户主页 | `GET /user/{userId}` | 查看他人主页和视频 |
| 签到 | `GET /client/checkin` | 每日签到获取硬币 |
| 浏览历史 | `GET /user/history` | 视频浏览记录 |

### 视频模块

| 功能 | 路径 | 说明 |
| --- | --- | --- |
| 首页推荐 | `GET /` / `GET /video/list` | 已审核通过的公开视频，按时间倒序 |
| 视频详情 | `GET /video/detail?id=` | 播放器 + 弹幕 + 评论 |
| 视频播放 | `GET /video/play?id=` | 独立播放页，支持倍速 |
| 上传视频 | `POST /video/upload` | `multipart/form-data`，最大 500MB |
| 视频流 | `GET /static/videos/*` | HTTP Range 支持，206 分段传输 |
| 搜索 | `GET /video/search?keyword=` | 标题/描述模糊搜索 |
| 我的视频 | `GET /video/myvideos` | 当前用户上传的视频 |
| 关注动态 | `GET /video/dynamic` | 关注用户的视频 Feed |
| 删除视频 | `POST /video/delete` | 仅作者本人可删除 |
| 编辑视频 | `POST /video/update` | 修改标题、封面、描述 |

### 互动模块

| 功能 | 路径 | 说明 |
| --- | --- | --- |
| 点赞/取消 | `POST /video/like` / `/unlike` | 不可重复点赞 |
| 收藏/取消 | `POST /video/favorite` / `/unfavorite` | 收藏视频 |
| 投币 | `POST /video/coin` | 每次 1-2 枚硬币 |
| 评论（弹幕） | `POST /video/comment` | 含 videoTime 定位，支持回复 |
| 删除评论 | `POST /video/deleteComment` | 评论者或视频作者可删 |
| 举报 | `POST /video/report` | 举报违规视频 |
| 关注/取关 | `POST /user/follow` / `/unfollow` | 关注其他用户 |
| 下载 | `GET /video/download?id=` | 下载视频文件 |

### 管理后台

| 功能 | 路径 | 说明 |
| --- | --- | --- |
| 管理员登录 | `GET /admin/login` | 独立管理员登录页 |
| 仪表盘 | `GET /admin/adminindex` | 统计数据概览 |
| 用户管理 | `GET /admin/users` | 列表、搜索、封禁、解封、提升角色 |
| 视频管理 | `GET /admin/videos` | 列表、筛选、删除 |
| 待审核视频 | `GET /admin/pending` | 审核通过/驳回 |
| 举报处理 | `GET /admin/reports` | 查看并处理举报 |
| 数据导出 | `GET /admin/exportUser` | 导出用户数据 |

### 漫展票务模块

| 功能 | 路径 | 说明 |
| --- | --- | --- |
| 展会列表 | `GET /ticket/index` | 漫展活动浏览 |
| 展会详情 | `GET /ticket/exhibition-details` | 票种选择与购买 |
| 下订单 | `POST /ticket/purchase` | 生成订单 |
| 支付 | `POST /ticket/payment` | 订单支付 |
| 退款 | `POST /ticket/refund` | 申请退款 |
| 我的订单 | `GET /ticket/myorders` | 历史订单 |
| 收藏展会 | `POST /ticket/favorite` | 收藏感兴趣的展会 |
| 咨询客服 | WebSocket `/websocket/consultation` | 实时在线咨询 |
| 票务核验 | `POST /adminticket/verifyticket` | 管理员扫码核验 |
| 展会管理 | `GET /adminticket/exhibitions` | 增删改查展会 |
| 销售统计 | `GET /adminticket/statistics` | 数据分析仪表盘 |

### WebSocket 端点

| 端点 | 用途 |
| --- | --- |
| `/websocket/user-status` | 用户封禁实时通知，强制下线 |
| `/websocket/consultation` | 用户与管理员实时咨询聊天 |
| `/websocket/ticket` | 票务实时推送：库存更新、支付成功、订单变动 |

### Redis 缓存

| Key | 说明 | TTL |
| --- | --- | --- |
| `videos:count:total` | 视频总数缓存 | 300 秒，上传后即时清除 |

缓存策略：写操作先更新 MySQL，成功后清除相关 Redis 缓存，下次读取时重建。

## 数据库

17 张业务表，从 0 建库使用：

```text
platform.sql
```

核心表关系：

| 表 | 说明 |
| --- | --- |
| `users` | 用户：role（user/admin）、status（正常/封禁）、金币 |
| `videos` | 视频：status（待审/通过/驳回）、visibility（公开/粉丝/互关/私密） |
| `screen_comment` | 弹幕评论：支持 `parent_id` 楼中楼、`video_time` 弹幕时间点、`photo` 图片评论 |
| `likes` | 点赞记录（`user_id, video_id` 唯一索引） |
| `favorites` | 收藏记录 |
| `video_coins` | 投币记录（不可重复投币） |
| `user_follows` | 关注关系 |
| `history` | 浏览历史 |
| `report` | 举报记录 |
| `checkin` | 每日签到 |
| `orders` + `order_item` | 票务订单与订单明细 |
| `tickets` | 票种（价格、库存） |
| `exhibitions` | 展会主表（草稿/发布/取消/结束） |
| `user_ticket` | 用户持有的票（含核验码） |
| `chat_messages` | 咨询聊天消息 |
| `user_favorites` | 展会收藏 |

## 构建与运行

```bash
# 1. 导入数据库
mysql -u root -p < platform.sql

# 2. 确保 redis-server 已启动（可选，Redis 不可用时会降级）

# 3. 编译并启动内嵌 Tomcat
mvn clean compile tomcat7:run
```

访问：

```text
http://localhost:8081
```

管理后台：

```text
http://localhost:8081/admin/login
```

## 配置

### 数据库连接

数据库连接池通过 `ConnectionPool.java`（Druid）配置：

- 地址：`jdbc:mysql://127.0.0.1:3306/platform`
- 用户：`root`
- 密码：`123456`
- 连接池：初始 5，最大 20

### Redis

`RedisUtil.java` 中配置：

- 地址：`localhost:6379`
- 无密码，DB 0
- 连接池：最大 50，空闲 20

## 注意事项

- 项目使用 **Tomcat 7**，API 基于 `javax.servlet`，不支持 `jakarta.servlet`
- 视频上传前需确保 `src/main/webapp/static/videos/` 目录存在
- 视频播放依赖 `VideoStreamServlet`，支持 HTTP Range 分段请求，浏览器 `<video>` 标签标准兼容
- Redis 不可用时系统降级运行，缓存读写会打印堆栈但不影响主流程
- 上传的视频文件存储在本项目 `static/videos/` 目录下，非 OSS
- 票务模块定时任务（`TimerTaskManager`）需 `ServletContextListener` 启停，订单超时 30 分钟自动取消
- 管理员默认账号：`admin`，角色为 `admin`
