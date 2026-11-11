/**
 * Main JavaScript for Manager & Admin Portal
 * Handles Theme Toggling, Responsive Sidebar, Dropdowns, and Table Search.
 */
(function() {
  'use strict';

  // 1. Theme Management
  var STORAGE_THEME_KEY = 'managerTheme';

  function getSavedTheme() {
    return localStorage.getItem(STORAGE_THEME_KEY) || localStorage.getItem('adminTheme') || 'light';
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    document.documentElement.setAttribute('data-bs-theme', theme);
    localStorage.setItem(STORAGE_THEME_KEY, theme);
    localStorage.setItem('adminTheme', theme);

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
    var SIDEBAR_MINI_KEY = 'managerSidebarMini';

    // Restore mini sidebar preference on desktop
    if (window.innerWidth >= 992) {
      if (localStorage.getItem(SIDEBAR_MINI_KEY) === 'true') {
        document.body.classList.add('sidebar-mini');
      }
    }

    sidebarToggleButtons.forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();

        if (window.innerWidth >= 992) {
          // Desktop: collapse to mini sidebar
          document.body.classList.toggle('sidebar-mini');
          var isMini = document.body.classList.contains('sidebar-mini');
          localStorage.setItem(SIDEBAR_MINI_KEY, isMini ? 'true' : 'false');
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

    // Close mobile sidebar on window resize to desktop
    window.addEventListener('resize', function() {
      if (window.innerWidth >= 992) {
        document.body.classList.remove('sidebar-open');
      }
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
