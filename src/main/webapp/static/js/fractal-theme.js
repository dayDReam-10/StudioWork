(function () {
    var noticeContainer = null;
    var pendingNotices = [];
    var userStatusWebSocket = null;
    var userStatusReconnectTimer = null;
    var userStatusReconnectEnabled = true;
    var userStatusRedirectTimer = null;

    function initThemeState() {
        var root = document.documentElement;
        var body = document.body;

        if (root) {
            root.classList.add('theme-ready');
        }

        if (!body) {
            return;
        }

        body.classList.add('theme-ready');

        var syncScrollState = function () {
            body.classList.toggle('theme-scrolled', window.scrollY > 12);
        };

        syncScrollState();
        window.addEventListener('scroll', syncScrollState, { passive: true });
    }

    function normalizeNoticeMessage(value) {
        if (value === null || value === undefined) {
            return '';
        }

        if (typeof value === 'string') {
            var text = value.trim();
            if (!text) {
                return '';
            }

            if ((text.startsWith('{') && text.endsWith('}')) || (text.startsWith('[') && text.endsWith(']'))) {
                try {
                    return normalizeNoticeMessage(JSON.parse(text));
                } catch (error) {
                    return text;
                }
            }

            return text;
        }

        if (typeof value === 'object') {
            if (typeof value.message === 'string' && value.message.trim()) {
                return value.message.trim();
            }
            if (typeof value.msg === 'string' && value.msg.trim()) {
                return value.msg.trim();
            }
            if (typeof value.detail === 'string' && value.detail.trim()) {
                return value.detail.trim();
            }
            if (typeof value.error === 'string' && value.error.trim()) {
                return value.error.trim();
            }

            try {
                return JSON.stringify(value);
            } catch (error) {
                return String(value);
            }
        }

        return String(value);
    }

    function getNoticeTheme(type) {
        switch (type) {
            case 'success':
                return { title: '成功', accent: '#16a34a', icon: '✓' };
            case 'warning':
                return { title: '提示', accent: '#f59e0b', icon: '!' };
            case 'error':
                return { title: '失败', accent: '#ef4444', icon: '×' };
            case 'info':
            default:
                return { title: '提示', accent: '#2563eb', icon: 'i' };
        }
    }

    function ensureNoticeContainer() {
        if (noticeContainer && document.body && document.body.contains(noticeContainer)) {
            return noticeContainer;
        }

        if (!document.body) {
            return null;
        }

        noticeContainer = document.createElement('div');
        noticeContainer.id = 'ft-notice-container';
        noticeContainer.style.cssText = [
            'position: fixed',
            'top: 20px',
            'right: 20px',
            'z-index: 99999',
            'display: flex',
            'flex-direction: column',
            'gap: 12px',
            'width: min(360px, calc(100vw - 32px))',
            'pointer-events: none'
        ].join(';') + ';';
        document.body.appendChild(noticeContainer);
        return noticeContainer;
    }

    function closeNotice(notice) {
        if (!notice || !notice.parentNode) {
            return;
        }

        notice.style.opacity = '0';
        notice.style.transform = 'translateY(-12px) scale(0.96)';
        notice.addEventListener('transitionend', function removeNotice() {
            notice.removeEventListener('transitionend', removeNotice);
            if (notice.parentNode) {
                notice.parentNode.removeChild(notice);
            }
        });
    }

    function renderNotice(message, options) {
        var container = ensureNoticeContainer();
        if (!container) {
            pendingNotices.push({ message: message, options: options || {} });
            return null;
        }

        var normalizedMessage = normalizeNoticeMessage(message);
        var noticeOptions = options || {};
        var theme = getNoticeTheme(noticeOptions.type);
        var title = noticeOptions.title || theme.title;
        var duration = typeof noticeOptions.duration === 'number' ? noticeOptions.duration : (noticeOptions.type === 'error' ? 3800 : 2800);

        var notice = document.createElement('div');
        notice.setAttribute('role', 'status');
        notice.setAttribute('aria-live', 'polite');
        notice.style.cssText = [
            'pointer-events: auto',
            'background: rgba(255, 255, 255, 0.94)',
            'backdrop-filter: blur(18px)',
            '-webkit-backdrop-filter: blur(18px)',
            'border-radius: 18px',
            'border: 1px solid rgba(255, 255, 255, 0.72)',
            'border-left: 4px solid ' + theme.accent,
            'box-shadow: 0 18px 40px rgba(15, 23, 42, 0.14)',
            'padding: 14px 16px',
            'transform: translateY(-12px) scale(0.96)',
            'opacity: 0',
            'transition: opacity 0.24s ease, transform 0.24s ease',
            'color: #1f2937'
        ].join(';') + ';';

        var header = document.createElement('div');
        header.style.cssText = [
            'display: flex',
            'align-items: center',
            'gap: 10px',
            'margin-bottom: 6px',
            'font-weight: 700',
            'font-size: 14px',
            'color: #0f172a'
        ].join(';') + ';';

        var icon = document.createElement('span');
        icon.textContent = theme.icon;
        icon.style.cssText = [
            'display: inline-flex',
            'align-items: center',
            'justify-content: center',
            'width: 24px',
            'height: 24px',
            'border-radius: 999px',
            'background: ' + theme.accent,
            'color: #ffffff',
            'font-size: 14px',
            'font-weight: 700',
            'flex-shrink: 0'
        ].join(';') + ';';

        var titleText = document.createElement('span');
        titleText.textContent = title;

        var messageText = document.createElement('div');
        messageText.textContent = normalizedMessage;
        messageText.style.cssText = [
            'font-size: 13px',
            'line-height: 1.6',
            'color: #334155',
            'word-break: break-word',
            'white-space: pre-wrap'
        ].join(';') + ';';

        header.appendChild(icon);
        header.appendChild(titleText);
        notice.appendChild(header);
        notice.appendChild(messageText);
        container.appendChild(notice);

        window.requestAnimationFrame(function () {
            notice.style.opacity = '1';
            notice.style.transform = 'translateY(0) scale(1)';
        });

        var timer = window.setTimeout(function () {
            closeNotice(notice);
        }, duration);

        notice.addEventListener('mouseenter', function () {
            window.clearTimeout(timer);
        });

        notice.addEventListener('mouseleave', function () {
            timer = window.setTimeout(function () {
                closeNotice(notice);
            }, 900);
        });

        return notice;
    }

    function flushPendingNotices() {
        if (!pendingNotices.length) {
            return;
        }

        var queue = pendingNotices.splice(0, pendingNotices.length);
        queue.forEach(function (item) {
            renderNotice(item.message, item.options);
        });
    }

    function getUserSessionInfo() {
        return window.__FR_USER__ || {};
    }

    function shouldOpenUserStatusWebSocket() {
        var sessionInfo = getUserSessionInfo();
        return sessionInfo.loggedIn === true && sessionInfo.role === 'user' && !!sessionInfo.userId;
    }

    function getUserStatusWebSocketUrl() {
        var sessionInfo = getUserSessionInfo();
        var protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
        var contextPath = sessionInfo.contextPath || '';
        var userId = encodeURIComponent(sessionInfo.userId || '');
        var role = encodeURIComponent(sessionInfo.role || 'user');
        return protocol + window.location.host + contextPath + '/websocket/user-status?userId=' + userId + '&role=' + role;
    }

    function getLoginUrl() {
        var sessionInfo = getUserSessionInfo();
        var contextPath = sessionInfo.contextPath || '';
        return contextPath + '/user/login';
    }

    function stopUserStatusWebSocketReconnect() {
        userStatusReconnectEnabled = false;
        if (userStatusReconnectTimer) {
            window.clearTimeout(userStatusReconnectTimer);
            userStatusReconnectTimer = null;
        }
        if (userStatusRedirectTimer) {
            window.clearTimeout(userStatusRedirectTimer);
            userStatusRedirectTimer = null;
        }
    }

    function closeUserStatusWebSocket() {
        if (userStatusWebSocket) {
            try {
                userStatusWebSocket.close();
            } catch (error) {
            }
            userStatusWebSocket = null;
        }
    }

    function scheduleUserStatusReconnect() {
        if (!userStatusReconnectEnabled || !shouldOpenUserStatusWebSocket()) {
            return;
        }
        if (userStatusReconnectTimer) {
            return;
        }
        userStatusReconnectTimer = window.setTimeout(function () {
            userStatusReconnectTimer = null;
            initUserStatusWebSocket();
        }, 5000);
    }

    function handleUserStatusMessage(rawMessage) {
        var message = null;
        try {
            message = typeof rawMessage === 'string' ? JSON.parse(rawMessage) : rawMessage;
        } catch (error) {
            return;
        }

        if (!message || !message.type) {
            return;
        }

        if (message.type === 'force_logout' || message.type === 'user_banned' || message.type === 'logout') {
            stopUserStatusWebSocketReconnect();
            if (window.ftNotify) {
                window.ftNotify(message.content || '您的账户状态已变更，请重新登录', {
                    type: 'error',
                    title: '账号已封禁',
                    duration: 3200
                });
            }
            closeUserStatusWebSocket();
            userStatusRedirectTimer = window.setTimeout(function () {
                window.location.replace(getLoginUrl());
            }, 1200);
        }
    }

    function initUserStatusWebSocket() {
        if (!shouldOpenUserStatusWebSocket()) {
            return;
        }
        if (userStatusWebSocket && (userStatusWebSocket.readyState === WebSocket.OPEN || userStatusWebSocket.readyState === WebSocket.CONNECTING)) {
            return;
        }

        var wsUrl = getUserStatusWebSocketUrl();
        if (!wsUrl) {
            return;
        }

        try {
            userStatusWebSocket = new WebSocket(wsUrl);
        } catch (error) {
            scheduleUserStatusReconnect();
            return;
        }

        userStatusWebSocket.onopen = function () {
            userStatusReconnectEnabled = true;
        };

        userStatusWebSocket.onmessage = function (event) {
            handleUserStatusMessage(event.data);
        };

        userStatusWebSocket.onerror = function () {
        };

        userStatusWebSocket.onclose = function () {
            userStatusWebSocket = null;
            if (userStatusReconnectEnabled) {
                scheduleUserStatusReconnect();
            }
        };
    }

    window.addEventListener('beforeunload', function () {
        stopUserStatusWebSocketReconnect();
        closeUserStatusWebSocket();
    });

    function bootstrap() {
        initThemeState();
        ensureNoticeContainer();
        flushPendingNotices();
        initUserStatusWebSocket();
    }

    window.ftNotify = function (message, options) {
        return renderNotice(message, options || {});
    };

    window.showToast = function (message, options) {
        return renderNotice(message, options || { type: 'info', title: '提示' });
    };

    window.alert = function (message) {
        return renderNotice(message, {
            type: 'info',
            title: '提示',
            duration: 3200
        });
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', bootstrap);
    } else {
        bootstrap();
    }
})();
