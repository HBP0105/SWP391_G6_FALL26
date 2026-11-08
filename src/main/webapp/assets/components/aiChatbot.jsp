<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:if test="${empty requestScope.__aiChatbotRendered}">
<c:set var="__aiChatbotRendered" value="true" scope="request" />

<!-- ===== FLOATING AI SHOPPING ASSISTANT CHATBOT COMPONENT ===== -->
<style>
    /* Ensure Wishlist Toast sits above the floating chat bubble */
    #siteWishlistToast {
        bottom: 96px !important;
    }

    .ai-chatbot-Launcher {
        position: fixed;
        bottom: 24px;
        right: 24px;
        z-index: 99990;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .ai-chatbot-hint-pill {
        background: #15161D;
        color: #FFF;
        font-size: 12px;
        font-weight: 600;
        padding: 7px 13px;
        border-radius: 20px;
        box-shadow: 0 4px 14px rgba(0, 0, 0, 0.22);
        border: 1px solid rgba(209, 0, 36, 0.5);
        cursor: pointer;
        white-space: nowrap;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .ai-chatbot-hint-pill i {
        color: #D10024;
    }

    .ai-chatbot-hint-pill:hover {
        background: #D10024;
        color: #FFF;
        transform: translateY(-2px);
    }

    .ai-chatbot-hint-pill:hover i {
        color: #FFF;
    }

    .ai-chatbot-bubble-btn {
        width: 58px;
        height: 58px;
        border-radius: 50%;
        background: linear-gradient(135deg, #D10024 0%, #9b001b 100%);
        color: #FFF;
        border: 2px solid #FFF;
        box-shadow: 0 6px 20px rgba(209, 0, 36, 0.45);
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        position: relative;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        outline: none;
    }

    .ai-chatbot-bubble-btn:hover {
        transform: scale(1.07);
        box-shadow: 0 8px 25px rgba(209, 0, 36, 0.6);
    }

    .ai-chatbot-bubble-badge {
        position: absolute;
        top: -3px;
        right: -3px;
        background: #15161D;
        color: #FFF;
        font-size: 9px;
        font-weight: 700;
        padding: 2px 5px;
        border-radius: 10px;
        border: 1.5px solid #FFF;
        letter-spacing: 0.4px;
    }

    /* Chat Window */
    .ai-chatbot-window {
        position: fixed;
        bottom: 92px;
        right: 24px;
        width: 380px;
        max-width: calc(100vw - 32px);
        height: 540px;
        max-height: calc(100vh - 120px);
        background: #FFF;
        border-radius: 12px;
        box-shadow: 0 12px 40px rgba(21, 22, 29, 0.28);
        border: 1px solid #E4E7ED;
        z-index: 99991;
        display: none;
        flex-direction: column;
        overflow: hidden;
        font-family: 'Montserrat', sans-serif;
        animation: aiChatSlideUp 0.22s ease-out;
    }

    .ai-chatbot-window.open {
        display: flex;
    }

    @keyframes aiChatSlideUp {
        from {
            opacity: 0;
            transform: translateY(16px) scale(0.97);
        }
        to {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
    }

    /* Header */
    .ai-chatbot-header {
        background: #15161D;
        color: #FFF;
        padding: 14px 16px;
        border-bottom: 3px solid #D10024;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-shrink: 0;
    }

    .ai-chatbot-header-left {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .ai-chatbot-avatar {
        width: 36px;
        height: 36px;
        border-radius: 8px;
        background: #D10024;
        color: #FFF;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 17px;
        flex-shrink: 0;
    }

    .ai-chatbot-title {
        font-size: 14px;
        font-weight: 700;
        margin: 0;
        color: #FFF;
        line-height: 1.2;
    }

    .ai-chatbot-status {
        font-size: 11px;
        color: #8D99AE;
        display: flex;
        align-items: center;
        gap: 5px;
        margin-top: 2px;
    }

    .ai-chatbot-status-dot {
        width: 7px;
        height: 7px;
        border-radius: 50%;
        background: #2ECC71;
        display: inline-block;
    }

    .ai-chatbot-header-actions {
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .ai-chatbot-icon-btn {
        background: rgba(255, 255, 255, 0.08);
        border: none;
        color: #E4E7ED;
        width: 28px;
        height: 28px;
        border-radius: 6px;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 13px;
        transition: all 0.15s;
    }

    .ai-chatbot-icon-btn:hover {
        background: #D10024;
        color: #FFF;
    }

    /* Messages Container */
    .ai-chatbot-messages {
        flex: 1;
        padding: 14px;
        overflow-y: auto;
        background: #F8F9FA;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .ai-msg-row {
        display: flex;
        flex-direction: column;
        max-width: 90%;
    }

    .ai-msg-row.user {
        align-self: flex-end;
        align-items: flex-end;
    }

    .ai-msg-row.ai {
        align-self: flex-start;
        align-items: flex-start;
    }

    .ai-msg-bubble {
        padding: 10px 13px;
        border-radius: 12px;
        font-size: 12.5px;
        line-height: 1.5;
        word-break: break-word;
    }

    .ai-msg-row.user .ai-msg-bubble {
        background: #D10024;
        color: #FFF;
        border-bottom-right-radius: 3px;
    }

    .ai-msg-row.ai .ai-msg-bubble {
        background: #FFF;
        color: #2B2D42;
        border: 1px solid #E4E7ED;
        border-bottom-left-radius: 3px;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.03);
    }

    .ai-msg-time {
        font-size: 10px;
        color: #8D99AE;
        margin-top: 3px;
        padding: 0 3px;
    }

    /* Product Cards inside AI Chat */
    .ai-chat-product-list {
        display: flex;
        flex-direction: column;
        gap: 8px;
        margin-top: 8px;
        width: 100%;
    }

    .ai-chat-product-card {
        display: flex;
        align-items: center;
        gap: 10px;
        background: #FFF;
        border: 1px solid #E4E7ED;
        border-radius: 8px;
        padding: 8px 10px;
        text-decoration: none !important;
        color: #2B2D42;
        transition: all 0.18s ease;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.03);
    }

    .ai-chat-product-card:hover {
        border-color: #D10024;
        box-shadow: 0 4px 12px rgba(209, 0, 36, 0.12);
        transform: translateY(-1px);
    }

    .ai-chat-prod-img {
        width: 54px;
        height: 54px;
        object-fit: contain;
        border-radius: 6px;
        background: #FFF;
        border: 1px solid #F0F2F5;
        padding: 3px;
        flex-shrink: 0;
    }

    .ai-chat-prod-info {
        flex: 1;
        min-width: 0;
    }

    .ai-chat-prod-name {
        font-size: 12.5px;
        font-weight: 700;
        color: #2B2D42;
        margin: 0 0 3px 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        transition: color 0.15s;
    }

    .ai-chat-product-card:hover .ai-chat-prod-name {
        color: #D10024;
    }

    .ai-chat-prod-meta {
        font-size: 10.5px;
        color: #8D99AE;
        margin-bottom: 3px;
    }

    .ai-chat-prod-bottom {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 6px;
    }

    .ai-chat-prod-price {
        font-size: 12.5px;
        font-weight: 700;
        color: #D10024;
    }

    .ai-chat-prod-match {
        font-size: 10px;
        font-weight: 700;
        background: #15161D;
        color: #FFF;
        padding: 2px 6px;
        border-radius: 3px;
    }

    /* Quick Prompt Chips */
    .ai-chatbot-chips {
        padding: 7px 12px;
        background: #FFF;
        border-top: 1px solid #F0F2F5;
        display: flex;
        gap: 6px;
        overflow-x: auto;
        flex-shrink: 0;
        scrollbar-width: none;
    }

    .ai-chatbot-chips::-webkit-scrollbar {
        display: none;
    }

    .ai-chip-btn {
        background: #F4F5F7;
        border: 1px solid #E4E7ED;
        color: #2B2D42;
        font-size: 11px;
        font-weight: 600;
        padding: 4px 10px;
        border-radius: 14px;
        cursor: pointer;
        white-space: nowrap;
        transition: all 0.15s;
    }

    .ai-chip-btn:hover {
        background: #FFF0F2;
        border-color: #D10024;
        color: #D10024;
    }

    /* Input Form */
    .ai-chatbot-input-bar {
        padding: 10px 12px;
        background: #FFF;
        border-top: 1px solid #E4E7ED;
        display: flex;
        align-items: center;
        gap: 8px;
        flex-shrink: 0;
    }

    .ai-chatbot-input {
        flex: 1;
        height: 36px;
        border: 1px solid #E4E7ED;
        border-radius: 18px;
        padding: 0 14px;
        font-size: 12.5px;
        color: #2B2D42;
        outline: none;
        transition: border-color 0.2s;
    }

    .ai-chatbot-input:focus {
        border-color: #D10024;
    }

    .ai-chatbot-send-btn {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: #D10024;
        color: #FFF;
        border: none;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        flex-shrink: 0;
        transition: background 0.15s;
    }

    .ai-chatbot-send-btn:hover {
        background: #9b001b;
    }

    .ai-chatbot-send-btn:disabled {
        background: #ccc;
        cursor: not-allowed;
    }

    .ai-typing-indicator {
        font-size: 11.5px;
        color: #8D99AE;
        font-style: italic;
        padding: 6px 10px;
    }
</style>

<!-- Floating Launcher Bubble -->
<div class="ai-chatbot-Launcher" id="aiChatbotLauncher">
    <div class="ai-chatbot-hint-pill" id="aiChatbotHintPill" onclick="toggleAIChatbot()">
        <i class="fa fa-magic"></i> Ask AI Product Finder
    </div>
    <button type="button" class="ai-chatbot-bubble-btn" id="aiChatbotBubbleBtn" onclick="toggleAIChatbot()" title="AI Shopping Assistant">
        <i class="fa fa-comments" id="aiChatbotBubbleIcon"></i>
        <span class="ai-chatbot-bubble-badge">AI</span>
    </button>
</div>

<!-- Pop-up Chatbox Window -->
<div class="ai-chatbot-window" id="aiChatbotWindow">
    <div class="ai-chatbot-header">
        <div class="ai-chatbot-header-left">
            <div class="ai-chatbot-avatar">
                <i class="fa fa-magic"></i>
            </div>
            <div>
                <h4 class="ai-chatbot-title">Electro AI Assistant</h4>
                <div class="ai-chatbot-status">
                    <span class="ai-chatbot-status-dot"></span> Online • Smart Product Finder
                </div>
            </div>
        </div>
        <div class="ai-chatbot-header-actions">
            <button type="button" class="ai-chatbot-icon-btn" title="Clear conversation" onclick="clearAIChatbotHistory()">
                <i class="fa fa-trash-o"></i>
            </button>
            <button type="button" class="ai-chatbot-icon-btn" title="Minimize" onclick="toggleAIChatbot(false)">
                <i class="fa fa-minus"></i>
            </button>
        </div>
    </div>

    <div class="ai-chatbot-messages" id="aiChatbotMessages"></div>

    <div class="ai-chatbot-chips">
        <button type="button" class="ai-chip-btn" onclick="sendAIChatQuickPrompt('Wireless earbuds with ANC under 3,000,000 VND')">ANC Earbuds &lt; 3M</button>
        <button type="button" class="ai-chip-btn" onclick="sendAIChatQuickPrompt('Best over-ear headphones with long battery life')">Long Battery Headphones</button>
        <button type="button" class="ai-chip-btn" onclick="sendAIChatQuickPrompt('Earbuds for gym and running')">Sport &amp; Gym</button>
        <button type="button" class="ai-chip-btn" onclick="sendAIChatQuickPrompt('Headphones with microphone for office calls')">Office &amp; Calls</button>
    </div>

    <form class="ai-chatbot-input-bar" id="aiChatbotForm" onsubmit="submitAIChatbotMessage(event)">
        <input type="text" class="ai-chatbot-input" id="aiChatbotInput" placeholder="Ask AI to find headphones or earbuds..." autocomplete="off" />
        <button type="submit" class="ai-chatbot-send-btn" id="aiChatbotSendBtn" title="Send">
            <i class="fa fa-paper-plane"></i>
        </button>
    </form>
</div>

<script>
    (function () {
        if (window.__aiChatbotInitialized) return;
        window.__aiChatbotInitialized = true;

        var ctx = window.__contextPath || '${pageContext.request.contextPath}';
        var chatWin = document.getElementById('aiChatbotWindow');
        var msgBox = document.getElementById('aiChatbotMessages');
        var inputEl = document.getElementById('aiChatbotInput');
        var sendBtn = document.getElementById('aiChatbotSendBtn');
        var bubbleIcon = document.getElementById('aiChatbotBubbleIcon');
        var hintPill = document.getElementById('aiChatbotHintPill');

        function escapeHtml(str) {
            var d = document.createElement('div');
            d.appendChild(document.createTextNode(str || ''));
            return d.innerHTML;
        }

        function formatPriceVND(price) {
            var num = parseFloat(price);
            if (isNaN(num)) return '0 \u20ab';
            return num.toLocaleString('vi-VN') + ' \u20ab';
        }

        function buildProductCardsHtml(products) {
            if (!products || products.length === 0) return '';
            var html = '<div class="ai-chat-product-list">';
            products.forEach(function (p) {
                var imgUrl = p.imageUrl || 'assets/img/product01.png';
                var imgSrc = (imgUrl.indexOf('http') === 0 || imgUrl.indexOf('/') === 0)
                    ? imgUrl
                    : ctx + '/' + imgUrl;
                var detailUrl = ctx + '/productDetail?id=' + p.productId + (p.recommendationId ? '&recId=' + p.recommendationId : '');
                html += '<a class="ai-chat-product-card" href="' + detailUrl + '">' +
                            '<img class="ai-chat-prod-img" src="' + imgSrc + '" alt="' + escapeHtml(p.productName) + '" onerror="this.src=\'' + ctx + '/assets/img/product01.png\'" />' +
                            '<div class="ai-chat-prod-info">' +
                                '<div class="ai-chat-prod-name">' + escapeHtml(p.productName) + '</div>' +
                                '<div class="ai-chat-prod-meta">' + escapeHtml((p.brandName || 'Authentic') + ' \u2022 ' + (p.categoryName || 'Audio')) + '</div>' +
                                '<div class="ai-chat-prod-bottom">' +
                                    '<span class="ai-chat-prod-price">' + formatPriceVND(p.price) + '</span>' +
                                    '<span class="ai-chat-prod-match"><i class="fa fa-bolt"></i> ' + (p.matchPercentage || 88) + '% Match</span>' +
                                '</div>' +
                            '</div>' +
                        '</a>';
            });
            html += '</div>';
            return html;
        }

        function appendMessageToUI(sender, text, timestamp, products) {
            if (!msgBox) return;
            var row = document.createElement('div');
            row.className = 'ai-msg-row ' + (sender === 'user' ? 'user' : 'ai');

            var inner = '<div class="ai-msg-bubble">' + escapeHtml(text) + '</div>';
            if (sender === 'ai' && products && products.length > 0) {
                inner += buildProductCardsHtml(products);
            }
            if (timestamp) {
                inner += '<span class="ai-msg-time">' + escapeHtml(timestamp) + '</span>';
            }
            row.innerHTML = inner;
            msgBox.appendChild(row);
            msgBox.scrollTop = msgBox.scrollHeight;
        }

        function renderFullHistory(history) {
            if (!msgBox) return;
            msgBox.innerHTML = '';
            if (!history || history.length === 0) return;
            history.forEach(function (item) {
                appendMessageToUI(item.sender, item.text, item.timestamp, item.products);
            });
            msgBox.scrollTop = msgBox.scrollHeight;
        }

        function setWindowOpenState(open, notifyServer) {
            if (!chatWin) return;
            if (open) {
                chatWin.classList.add('open');
                if (bubbleIcon) bubbleIcon.className = 'fa fa-times';
                if (hintPill) hintPill.style.display = 'none';
                if (msgBox) msgBox.scrollTop = msgBox.scrollHeight;
                setTimeout(function () {
                    if (inputEl) inputEl.focus();
                }, 100);
            } else {
                chatWin.classList.remove('open');
                if (bubbleIcon) bubbleIcon.className = 'fa fa-comments';
                if (hintPill) hintPill.style.display = 'flex';
            }

            if (notifyServer) {
                var params = new URLSearchParams();
                params.append('action', 'toggle');
                params.append('isOpen', open ? 'true' : 'false');
                fetch(ctx + '/aiChatbot', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                    body: params.toString()
                }).catch(function () {});
            }
        }

        window.toggleAIChatbot = function (forceState) {
            var isCurrentlyOpen = chatWin && chatWin.classList.contains('open');
            var nextState = (typeof forceState === 'boolean') ? forceState : !isCurrentlyOpen;
            setWindowOpenState(nextState, true);
        };

        window.sendAIChatQuickPrompt = function (promptText) {
            if (!inputEl) return;
            inputEl.value = promptText;
            submitAIChatbotMessage(null);
        };

        window.clearAIChatbotHistory = function () {
            var params = new URLSearchParams();
            params.append('action', 'clear');
            fetch(ctx + '/aiChatbot', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: params.toString()
            })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data && data.history) {
                    renderFullHistory(data.history);
                }
            })
            .catch(function () {});
        };

        window.submitAIChatbotMessage = function (e) {
            if (e) e.preventDefault();
            if (!inputEl || !inputEl.value.trim()) return;

            var text = inputEl.value.trim();
            inputEl.value = '';

            var now = new Date();
            var timeStr = ('0' + now.getHours()).slice(-2) + ':' + ('0' + now.getMinutes()).slice(-2);
            appendMessageToUI('user', text, timeStr, []);

            // Show typing indicator
            var typingEl = document.createElement('div');
            typingEl.className = 'ai-typing-indicator';
            typingEl.innerHTML = '<i class="fa fa-circle-o-notch fa-spin"></i> AI is analyzing products...';
            msgBox.appendChild(typingEl);
            msgBox.scrollTop = msgBox.scrollHeight;

            if (sendBtn) sendBtn.disabled = true;

            var params = new URLSearchParams();
            params.append('action', 'ask');
            params.append('message', text);

            fetch(ctx + '/aiChatbot', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: params.toString()
            })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (typingEl && typingEl.parentNode) typingEl.parentNode.removeChild(typingEl);
                if (sendBtn) sendBtn.disabled = false;

                if (data && data.success) {
                    appendMessageToUI('ai', data.reply, data.timestamp, data.products || []);
                } else {
                    appendMessageToUI('ai', (data && data.message) || 'Sorry, something went wrong. Please try again.', timeStr, []);
                }
            })
            .catch(function () {
                if (typingEl && typingEl.parentNode) typingEl.parentNode.removeChild(typingEl);
                if (sendBtn) sendBtn.disabled = false;
                appendMessageToUI('ai', 'Unable to connect to AI Assistant right now. Please try again.', timeStr, []);
            });
        };

        // Load existing session conversation history on page load
        function loadSessionChatHistory() {
            fetch(ctx + '/aiChatbot')
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    if (data && data.history) {
                        renderFullHistory(data.history);
                    }
                    if (data && data.isOpen) {
                        setWindowOpenState(true, false);
                    }
                })
                .catch(function () {});
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', loadSessionChatHistory);
        } else {
            loadSessionChatHistory();
        }
    })();
</script>
</c:if>
<!-- ===== /FLOATING AI SHOPPING ASSISTANT CHATBOT COMPONENT ===== -->

