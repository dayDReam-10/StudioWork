package com.assessment.www.Util;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

//Redis工具类
public class RedisUtil {
    private static JedisPool jedisPool;
    private final static String redishost = "localhost";
    private final static int redisport = 6379;
    private final static String redispassword = "";
    private final static int redisdatabase = 0;
    private final static int redistimeout = 3000;
    private final static int redismaxTotal = 50;
    private final static int redismaxIdle = 20;
    private final static int redisminIdle = 5;

    static {
        try {
            JedisPoolConfig config = new JedisPoolConfig();
            config.setMaxTotal(redismaxTotal);
            config.setMaxIdle(redismaxIdle);
            config.setMinIdle(redisminIdle);
            config.setMaxWaitMillis(redistimeout);
            if (redispassword == null || redispassword.isEmpty()) {
                jedisPool = new JedisPool(config, redishost, redisport, redistimeout);
            } else {
                jedisPool = new JedisPool(config, redishost, redisport, redistimeout, redispassword);
            }
            // 测试连接是否成功
            try (Jedis jedis = jedisPool.getResource()) {
                jedis.select(redisdatabase);
                System.out.println("Redis连接池初始化成功，连接到"+redishost+":"+redisport);
            }
        } catch (Exception e) {
            jedisPool = null;
            System.out.println("Redis 连接池初始化失败，请检查 Redis 服务是否启动");
        }
    }

    //获取Jedis实例
    public static Jedis getJedis() {
        try {
            if (jedisPool != null) {
                Jedis jedis = jedisPool.getResource();
                return jedis;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.out.println("Redis 获取连接失败: " + e.getMessage());
            return null;
        }
    }

    //关闭Jedis连接
    public static void closeJedis(Jedis jedis) {
        if (jedis != null) {
            jedis.close();
        }
    }

    //设置缓存
    public static void set(String key, String value) {
        Jedis jedis = null;
        try {
            jedis = getJedis();
            if (jedis == null) {
                return;
            }
            jedis.set(key, value);
        } catch (Exception e) {
            System.out.println("Redis 写入失败: " + e.getMessage());
        } finally {
            closeJedis(jedis);
        }
    }

    //设置缓存（带过期时间）
    public static void setex(String key, int seconds, String value) {
        Jedis jedis = null;
        try {
            jedis = getJedis();
            if (jedis == null) {
                return;
            }
            jedis.setex(key, seconds, value);
        } catch (Exception e) {
            System.out.println("Redis 写入失败: " + e.getMessage());
        } finally {
            closeJedis(jedis);
        }
    }

    //获取缓存
    public static String get(String key) {
        Jedis jedis = null;
        try {
            jedis = getJedis();
            if (jedis == null) {
                return null;
            }
            return jedis.get(key);
        } catch (Exception e) {
            System.out.println("Redis 读取失败: " + e.getMessage());
            return null;
        } finally {
            closeJedis(jedis);
        }
    }

    //删除缓存
    public static void del(String key) {
        Jedis jedis = null;
        try {
            jedis = getJedis();
            if (jedis == null) {
                return;
            }
            jedis.del(key);
        } catch (Exception e) {
            System.out.println("Redis 删除失败: " + e.getMessage());
        } finally {
            closeJedis(jedis);
        }
    }

    //判断key是否存在
    public static boolean exists(String key) {
        Jedis jedis = null;
        try {
            jedis = getJedis();
            if (jedis == null) {
                return false;
            }
            return jedis.exists(key);
        } catch (Exception e) {
            System.out.println("Redis 检查失败: " + e.getMessage());
            return false;
        } finally {
            closeJedis(jedis);
        }
    }

    //设置过期时间
    public static void expire(String key, int seconds) {
        Jedis jedis = null;
        try {
            jedis = getJedis();
            if (jedis == null) {
                return;
            }
            jedis.expire(key, seconds);
        } catch (Exception e) {
            System.out.println("Redis 设置过期失败: " + e.getMessage());
        } finally {
            closeJedis(jedis);
        }
    }
}