package com.assessment.www.Util;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
//Redis JSON工具类
public class RedisJsonUtil {
    private static final ObjectMapper objectMapper = new ObjectMapper();
    //将对象序列化为JSON并存储到Redis
    public static void set(String key, Object obj) {
        try {
            String json = objectMapper.writeValueAsString(obj);
            RedisUtil.set(key, json);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
    }
    //将对象序列化为JSON并存储到Redis
    public static void setex(String key, int seconds, Object obj) {
        try {
            String json = objectMapper.writeValueAsString(obj);
            RedisUtil.setex(key, seconds, json);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
    }
    //从Redis获取JSON字符串并反序列化为对象
    public static <T> T get(String key, Class<T> clazz) {
        try {
            String json = RedisUtil.get(key);
            if (json != null) {
                return objectMapper.readValue(json, clazz);
            }
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}