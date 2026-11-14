/**
 * Main JavaScript for Manager & Admin Portal
 * Handles Theme Toggling, Responsive Sidebar, Dropdowns, and Table Search.
 */
(function loadSessionStatusHeartbeat() {
  if (window.__sessionStatusHeartbeatLoading || window.__sessionStatusHeartbeatStarted) return;
  window.__sessionStatusHeartbeatLoading = true;
  var source = document.currentScript && document.currentScript.src ? document.currentScript.src : '';
  var contextPath = window.__contextPath || '';
  if (!contextPath && source) {
    try {
      var path = new URL(source, window.location.href).pathname;
      var marker = '/assets/Admin_Manager/js/main.js';
      var index = path.indexOf(marker);
      contextPath = index >= 0 ? path.substring(0, index) : '';
    } catch (ignored) {
      contextPath = '';
    }
  }
  window.__contextPath = contextPath;
  var script = document.createElement('script');
  script.src = contextPath + '/assets/js/session-status.js?v=20261114-1';
  script.async = true;
  document.head.appendChild(script);
})();

(function() {
  'use strict';

  // 1. Theme Management
  // Use a new preference key so stale dark-theme values from the previous
  // Manager UI do not override the light design baseline.
  var STORAGE_THEME_KEY = 'adminHMD.colorTheme.v3';

  function readStorage(key) {
    try {
      return window.localStorage.getItem(key);
    } catch (error) {
      return null;
    }
  }

  function writeStorage(key, value) {
    try {
      window.localStorage.setItem(key, value);
    } catch (error) {
      // The layout must keep working when storage is disabled.
    }
  }

  function getSavedTheme() {
    var savedTheme = readStorage(STORAGE_THEME_KEY);

    return savedTheme === 'dark' ? 'dark' : 'light';
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    document.documentElement.setAttribute('data-bs-theme', theme);
    writeStorage(STORAGE_THEME_KEY, theme);

    var icons = document.querySelectorAll('[data-theme-icon]');
    icons.forEach(function(icon) {
      if (theme === 'dark') {
        icon.className = 'bi bi-sun-fill text-warning';
      } else {
        icon.className = 'bi bi-moon-stars';
      }
    });
  }

  // Apply saved theme immediately on script load
  applyTheme(getSavedTheme());

  document.addEventListener('DOMContentLoaded', function() {
    // Re-apply to ensure icons reflect correct state
    applyTheme(getSavedTheme());

    // Theme toggle button click
    var themeToggles = document.querySelectorAll('[data-theme-toggle]');
    themeToggles.forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        var current = document.documentElement.getAttribute('data-theme') || 'light';
        var next = current === 'dark' ? 'light' : 'dark';
        applyTheme(next);
      });
    });

    // 2. Sidebar Management
    var sidebarToggleButtons = document.querySelectorAll('[data-sidebar-toggle]');
    var sidebarBackdrops = document.querySelectorAll('[data-sidebar-close], .sidebar-backdrop');
    var SIDEBAR_MINI_KEY = 'adminHMD.sidebarMini.v2';

    function getSavedMiniState() {
      var savedState = readStorage(SIDEBAR_MINI_KEY);

      // Match the Staff order-list shell: the desktop sidebar starts expanded.
      return savedState === 'true';
    }

    function saveMiniState(isMini) {
      writeStorage(SIDEBAR_MINI_KEY, String(isMini));
    }

    function updateSidebarState() {
      var isDesktop = window.matchMedia('(min-width: 992px)').matches;
      var isMini = isDesktop && getSavedMiniState();

      document.body.classList.remove('sidebar-open');
      document.body.classList.toggle('sidebar-mini', isMini);

      sidebarToggleButtons.forEach(function(btn) {
        btn.setAttribute('aria-expanded', String(isDesktop ? !isMini : false));
      });
    }

    // Restore mini sidebar preference on desktop
    updateSidebarState();

    sidebarToggleButtons.forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();

        if (window.innerWidth >= 992) {
          // Desktop: collapse to mini sidebar
          document.body.classList.toggle('sidebar-mini');
          var isMini = document.body.classList.contains('sidebar-mini');
          saveMiniState(isMini);
          btn.setAttribute('aria-expanded', isMini ? 'false' : 'true');
        } else {
          // Mobile: slide out sidebar
          document.body.classList.toggle('sidebar-open');
          var isOpen = document.body.classList.contains('sidebar-open');
          btn.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
        }
      });
    });

    // Close sidebar on backdrop click
    sidebarBackdrops.forEach(function(backdrop) {
      backdrop.addEventListener('click', function() {
        document.body.classList.remove('sidebar-open');
        sidebarToggleButtons.forEach(function(btn) {
          btn.setAttribute('aria-expanded', 'false');
        });
      });
    });

    // Keep the correct sidebar mode when crossing the desktop breakpoint.
    window.addEventListener('resize', function() {
      updateSidebarState();
    });

    // 3. Client-side Table Search Filter
    var searchInputs = document.querySelectorAll('input[data-table-search]');
    searchInputs.forEach(function(input) {
      var tableId = input.getAttribute('data-table-search');
      var targetTable = document.getElementById(tableId);
      if (!targetTable) return;

      input.addEventListener('input', function() {
        var query = this.value.trim().toLowerCase();
        var rows = targetTable.querySelectorAll('tbody tr');

        rows.forEach(function(row) {
          // Skip empty or "no data found" rows with colspan
          if (row.querySelector('td[colspan]')) return;
          var text = row.textContent.toLowerCase();
          row.style.display = text.indexOf(query) !== -1 ? '' : 'none';
        });
      });
    });

    // 4. Safe Dropdown Behavior
    // Bootstrap 5 dropdown toggle fallback if bootstrap JS was delayed
    document.querySelectorAll('.dropdown-toggle').forEach(function(toggle) {
      toggle.addEventListener('click', function(e) {
        if (!window.bootstrap) {
          e.preventDefault();
          var menu = this.nextElementSibling;
          if (menu && menu.classList.contains('dropdown-menu')) {
            menu.classList.toggle('show');
          }
        }
      });
    });

    document.addEventListener('click', function(e) {
      if (!window.bootstrap) {
        if (!e.target.closest('.dropdown')) {
          document.querySelectorAll('.dropdown-menu.show').forEach(function(menu) {
            menu.classList.remove('show');
          });
        }
      }
    });
  });
})();
