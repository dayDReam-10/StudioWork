/*
 Navicat Premium Data Transfer

 Source Server         : 192.168.1.161
 Source Server Type    : MySQL
 Source Server Version : 50727
 Source Host           : 192.168.1.161:3306
 Source Schema         : platform

 Target Server Type    : MySQL
 Target Server Version : 50727
 File Encoding         : 65001

 Date: 09/04/2026 19:31:24
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for checkin
-- ----------------------------
DROP TABLE IF EXISTS `checkin`;
CREATE TABLE `checkin`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` int(11) NULL DEFAULT NULL COMMENT '用户id',
  `video_id` int(11) NULL DEFAULT NULL COMMENT '视频id',
  `time_create` datetime(0) NULL DEFAULT NULL COMMENT '签到时间',
  `coin_count` int(1) NULL DEFAULT NULL COMMENT '领取币数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of checkin
-- ----------------------------
INSERT INTO `checkin` VALUES (19, 2, NULL, '2026-04-09 18:10:11', 1);
INSERT INTO `checkin` VALUES (20, 1, NULL, '2026-04-09 18:41:47', 1);

-- ----------------------------
-- Table structure for favorites
-- ----------------------------
DROP TABLE IF EXISTS `favorites`;
CREATE TABLE `favorites`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` int(11) NOT NULL COMMENT '收藏者的ID',
  `video_id` int(11) NOT NULL COMMENT '被收藏视频的ID',
  `time_fav` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `only_unique_fav`(`user_id`, `video_id`) USING BTREE,
  INDEX `del_favs_video`(`video_id`) USING BTREE,
  CONSTRAINT `del_favs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `del_favs_video` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '视频收藏记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of favorites
-- ----------------------------
INSERT INTO `favorites` VALUES (1, 2, 1, '2026-04-07 16:37:42');
INSERT INTO `favorites` VALUES (2, 2, 4, '2026-04-08 12:42:45');
INSERT INTO `favorites` VALUES (3, 3, 2, '2026-04-08 14:26:12');
INSERT INTO `favorites` VALUES (5, 3, 4, '2026-04-09 15:12:03');
INSERT INTO `favorites` VALUES (7, 2, 3, '2026-04-09 18:45:41');

-- ----------------------------
-- Table structure for history
-- ----------------------------
DROP TABLE IF EXISTS `history`;
CREATE TABLE `history`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '记录标识',
  `user_id` int(11) NOT NULL COMMENT '观看者ID',
  `video_id` int(11) NOT NULL COMMENT '视频ID',
  `time_view` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '观看时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `only_user_video`(`user_id`, `video_id`) USING BTREE,
  INDEX `del_history_video`(`video_id`) USING BTREE,
  CONSTRAINT `del_history_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `del_history_video` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 170 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of history
-- ----------------------------
INSERT INTO `history` VALUES (1, 2, 1, '2026-04-07 17:30:49');
INSERT INTO `history` VALUES (4, 2, 2, '2026-04-09 18:44:46');
INSERT INTO `history` VALUES (17, 1, 2, '2026-04-09 18:43:09');
INSERT INTO `history` VALUES (18, 2, 3, '2026-04-09 19:07:21');
INSERT INTO `history` VALUES (21, 2, 4, '2026-04-09 18:46:07');
INSERT INTO `history` VALUES (30, 3, 4, '2026-04-09 19:09:45');
INSERT INTO `history` VALUES (32, 1, 4, '2026-04-09 18:41:42');
INSERT INTO `history` VALUES (33, 3, 3, '2026-04-09 19:15:36');
INSERT INTO `history` VALUES (36, 3, 2, '2026-04-09 19:16:05');
INSERT INTO `history` VALUES (48, 1, 3, '2026-04-09 18:43:25');
INSERT INTO `history` VALUES (49, 1, 1, '2026-04-08 15:15:35');

-- ----------------------------
-- Table structure for likes
-- ----------------------------
DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` int(11) NOT NULL COMMENT '点赞者的ID',
  `video_id` int(11) NOT NULL COMMENT '被点赞视频的ID',
  `time_like` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `only_unique_like`(`user_id`, `video_id`) USING BTREE,
  INDEX `del_likes_video`(`video_id`) USING BTREE,
  CONSTRAINT `del_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `del_likes_video` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '视频点赞记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of likes
-- ----------------------------
INSERT INTO `likes` VALUES (1, 2, 1, '2026-04-07 16:37:46');
INSERT INTO `likes` VALUES (2, 2, 4, '2026-04-08 12:42:36');
INSERT INTO `likes` VALUES (3, 3, 3, '2026-04-08 14:07:14');
INSERT INTO `likes` VALUES (7, 3, 4, '2026-04-09 15:28:39');
INSERT INTO `likes` VALUES (9, 1, 3, '2026-04-09 18:43:24');
INSERT INTO `likes` VALUES (11, 3, 2, '2026-04-09 19:16:04');

-- ----------------------------
-- Table structure for report
-- ----------------------------
DROP TABLE IF EXISTS `report`;
CREATE TABLE `report`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `video_id` int(11) NULL DEFAULT NULL COMMENT '视频id',
  `reason_detail` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '举报内容',
  `status` int(11) NULL DEFAULT NULL COMMENT '状态',
  `time_create` datetime(0) NULL DEFAULT NULL COMMENT '举报时间',
  `user_id` int(1) NULL DEFAULT NULL COMMENT '举报人id\r\n举报人id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '举报信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of report
-- ----------------------------
INSERT INTO `report` VALUES (1, 4, '其他原因', 2, '2026-04-09 12:54:20', 3);
INSERT INTO `report` VALUES (4, 2, '广告营销', 0, '2026-04-09 18:19:44', 2);

-- ----------------------------
-- Table structure for screen_comment
-- ----------------------------
DROP TABLE IF EXISTS `screen_comment`;
CREATE TABLE `screen_comment`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '弹幕标识',
  `video_id` int(11) NOT NULL COMMENT '所属视频ID',
  `user_id` int(11) NOT NULL COMMENT '发送者ID',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '弹幕内容',
  `video_time` float NOT NULL COMMENT '视频内出现时间(秒)',
  `time_create` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `parent_id` int(11) NULL DEFAULT NULL COMMENT '父id',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `del_comment_video`(`video_id`) USING BTREE,
  INDEX `del_comment_user`(`user_id`) USING BTREE,
  CONSTRAINT `del_comment_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `del_comment_video` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of screen_comment
-- ----------------------------
INSERT INTO `screen_comment` VALUES (2, 4, 1, '测试', 0, '2026-04-08 17:11:25', NULL);
INSERT INTO `screen_comment` VALUES (3, 3, 1, '333', 0, '2026-04-08 17:11:29', NULL);
INSERT INTO `screen_comment` VALUES (4, 4, 1, '213', 0, '2026-04-08 17:11:31', NULL);
INSERT INTO `screen_comment` VALUES (11, 4, 3, '1', 0, '2026-04-09 00:00:00', 2);
INSERT INTO `screen_comment` VALUES (12, 4, 3, '2', 0, '2026-04-09 00:00:00', 2);
INSERT INTO `screen_comment` VALUES (13, 4, 3, '1', 0, '2026-04-09 00:00:00', 2);
INSERT INTO `screen_comment` VALUES (14, 3, 3, '测试', 0, '2026-04-09 00:00:00', 0);
INSERT INTO `screen_comment` VALUES (16, 3, 3, '12323', 0, '2026-04-09 00:00:00', 15);
INSERT INTO `screen_comment` VALUES (17, 2, 2, '2', 0, '2026-04-09 00:00:00', 0);
INSERT INTO `screen_comment` VALUES (18, 2, 1, '1', 0, '2026-04-09 00:00:00', 17);

-- ----------------------------
-- Table structure for user_follows
-- ----------------------------
DROP TABLE IF EXISTS `user_follows`;
CREATE TABLE `user_follows`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` int(11) NOT NULL COMMENT '被关注者(大V)的ID',
  `follower_id` int(11) NOT NULL COMMENT '关注者(粉丝)的ID',
  `time_follow` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `only_unique_follow`(`user_id`, `follower_id`) USING BTREE,
  INDEX `del_follows_follower`(`follower_id`) USING BTREE,
  CONSTRAINT `del_follows_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `del_follows_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户关注关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_follows
-- ----------------------------
INSERT INTO `user_follows` VALUES (1, 2, 3, '2026-04-08 13:01:30');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '账号',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '/static/images/default_avatar.png' COMMENT '头像',
  `gender` tinyint(4) NULL DEFAULT 0 COMMENT '0:保密, 1:男, 2:女',
  `signature` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '这个人很懒，什么都没有留下' COMMENT '个人签名',
  `coin_count` int(11) NULL DEFAULT 0 COMMENT '硬币余额',
  `following_count` int(11) NULL DEFAULT 0 COMMENT '关注数',
  `follower_count` int(11) NULL DEFAULT 0 COMMENT '粉丝数',
  `total_like_count` int(11) NULL DEFAULT 0 COMMENT '获赞总数',
  `total_fav_count` int(11) NULL DEFAULT 0 COMMENT '被收藏总数',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'user' COMMENT 'user:用户, admin:管理员',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '1:正常, 0:封禁',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin', '123456', '/static/images/default_avatar.png', 0, '这个人很懒，什么都没有留下', 1, 0, 0, 1, 0, 'admin', 1);
INSERT INTO `users` VALUES (2, 'ding', '123456', '/static/images/default_avatar.png', 1, '测试', 0, 0, 1, 2, 3, 'user', 1);
INSERT INTO `users` VALUES (3, 'mynameis', '123456', '/static/images/default_avatar.png', 0, '测试', 11, 1, 0, 3, 2, 'user', 1);

-- ----------------------------
-- Table structure for video_coins
-- ----------------------------
DROP TABLE IF EXISTS `video_coins`;
CREATE TABLE `video_coins`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '投币者ID',
  `video_id` int(11) NOT NULL COMMENT '视频ID',
  `amount` tinyint(2) NOT NULL DEFAULT 1 COMMENT '投币数量(一般限制1-2个)',
  `time_coin` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '投币时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `only_user_video_coin`(`user_id`, `video_id`) USING BTREE,
  INDEX `del_coin_video`(`video_id`) USING BTREE,
  CONSTRAINT `del_coin_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `del_coin_video` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of video_coins
-- ----------------------------
INSERT INTO `video_coins` VALUES (1, 3, 4, 1, '2026-04-08 19:22:36');
INSERT INTO `video_coins` VALUES (2, 3, 3, 2, '2026-04-09 10:41:10');
INSERT INTO `video_coins` VALUES (3, 2, 2, 1, '2026-04-09 18:14:58');

-- ----------------------------
-- Table structure for videos
-- ----------------------------
DROP TABLE IF EXISTS `videos`;
CREATE TABLE `videos`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '视频标识',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '视频标题',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '视频文件存储路径',
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '/static/images/default_cover.png' COMMENT '视频封面图',
  `author_id` int(11) NOT NULL COMMENT 'ID(关联users.id)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '视频简介',
  `view_count` int(11) NULL DEFAULT 0 COMMENT '播放量',
  `status` tinyint(4) NULL DEFAULT 0 COMMENT '审核状态: 0-待审核, 1-通过, 2-驳回',
  `like_count` int(11) NULL DEFAULT 0 COMMENT '获赞数',
  `coin_count` int(11) NULL DEFAULT 0 COMMENT '投币数',
  `fav_count` int(11) NULL DEFAULT 0 COMMENT '收藏数',
  `screen_comment_count` int(11) NULL DEFAULT 0 COMMENT '弹幕总数',
  `time_create` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `del_video_author`(`author_id`) USING BTREE,
  CONSTRAINT `del_video_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of videos
-- ----------------------------
INSERT INTO `videos` VALUES (1, '测试标题', '/static/videos/c37bd566-ef5c-4c48-89ac-b40baabdd832.mp4', '/static/images/default_cover.png', 1, '测试', 0, 2, 1, 0, 1, 0, '2026-04-07 11:23:53');
INSERT INTO `videos` VALUES (2, '我的测试', '/static/videos/c37bd566-ef5c-4c48-89ac-b40baabdd832.mp4', '/static/images/default_cover.png', 2, '我的测试', 0, 1, 1, 2, 1, 2, '2026-04-07 17:05:23');
INSERT INTO `videos` VALUES (3, '大自然', '/static/videos/c66a85a5-77cb-44ac-bdcb-85f54fa0a067.mp4', '/static/images/default_cover.png', 2, '大自然', 0, 1, 2, 4, 1, 7, '2026-04-08 10:40:52');
INSERT INTO `videos` VALUES (4, '大海', '/static/videos/c6fb3b6e-2dc8-4500-9bf9-b655faf8d405.mp4', '/static/images/default_cover.png', 2, '大海', 0, 1, 2, 1, 2, 8, '2026-04-08 10:42:39');

SET FOREIGN_KEY_CHECKS = 1;
