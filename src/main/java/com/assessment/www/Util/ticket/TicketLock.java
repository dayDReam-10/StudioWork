package com.assessment.www.Util.ticket;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

//按票种加锁工具类
public class TicketLock {
    private static final Map<Integer, Lock> ticketLocks = new ConcurrentHashMap<>();

    public static Lock getLock(Integer ticketId) {//根据票种获取对应的锁对象。
        return ticketLocks.computeIfAbsent(ticketId, id -> new ReentrantLock());
    }

    //从 Map 中移除指定票种的锁对象
    public static void removeLock(Integer ticketId) {
        ticketLocks.remove(ticketId);
    }
}