(function () {
    'use strict';

    if (window.__sessionStatusHeartbeatStarted) {
        return;
    }
    window.__sessionStatusHeartbeatStarted = true;

    var currentScript = document.currentScript;
    var contextPath = window.__contextPath || '';
    if (!contextPath && currentScript && currentScript.src) {
        try {
            var path = new URL(currentScript.src, window.location.href).pathname;
            var marker = '/assets/js/session-status.js';
            var markerIndex = path.indexOf(marker);
            contextPath = markerIndex >= 0 ? path.substring(0, markerIndex) : '';
        } catch (ignored) {
            contextPath = '';
        }
    }

    var wasAuthenticated = false;
    var redirecting = false;

    function goToLogin(loginUrl) {
        if (redirecting) {
            return;
        }
        redirecting = true;
        window.location.replace(loginUrl || (contextPath + '/login?reason=session-expired'));
    }

    function checkSessionStatus() {
        fetch(contextPath + '/session-status', {
            method: 'GET',
            credentials: 'same-origin',
            cache: 'no-store',
            headers: {
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            }
        }).then(function (response) {
            return response.json().catch(function () {
                return {};
            }).then(function (data) {
                if (response.status === 401 || data.active === false && data.authenticated === true) {
                    goToLogin(data.loginUrl);
                    return;
                }
                if (data.authenticated === true) {
                    wasAuthenticated = true;
                } else if (wasAuthenticated) {
                    goToLogin(contextPath + '/login?reason=session-expired');
                }
            });
        }).catch(function () {
            // A temporary network failure must not log the user out.
        });
    }

    window.setTimeout(checkSessionStatus, 300);
    window.setInterval(checkSessionStatus, 1500);
})();
