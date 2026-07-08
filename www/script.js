      document.addEventListener('DOMContentLoaded', function() {

        /* ── 1. Mobile sidebar toggle ── */
        var btn     = document.getElementById('mobile-menu-btn');
        var overlay = document.getElementById('sidebar-overlay');
        var sidebar = document.querySelector('.main-sidebar');

        function openSidebar() {
          sidebar.classList.add('sidebar-visible');
          overlay.classList.add('active');
          btn.classList.add('open');
        }
        function closeSidebar() {
          sidebar.classList.remove('sidebar-visible');
          overlay.classList.remove('active');
          btn.classList.remove('open');
        }

        if (btn) {
          btn.addEventListener('click', function() {
            sidebar.classList.contains('sidebar-visible') ? closeSidebar() : openSidebar();
          });
        }
        if (overlay) overlay.addEventListener('click', closeSidebar);

        // Auto-close sidebar when a menu tab is clicked on mobile
        document.addEventListener('click', function(e) {
          var link = e.target.closest('.sidebar-menu a');
          if (link && window.innerWidth < 992) {
            setTimeout(closeSidebar, 180);
          }
        });

        /* ── 2. Fix pagination active-button text colour ── */
        function fixPagination() {
          document.querySelectorAll('.paginate_button.current').forEach(function(el) {
            el.style.setProperty('color',            '#ffffff', 'important');
            el.style.setProperty('-webkit-text-fill-color', '#ffffff', 'important');
            el.style.setProperty('background',       '#6c63ff', 'important');
            el.style.setProperty('background-image', 'none',    'important');
            el.style.setProperty('background-color', '#6c63ff', 'important');
            el.style.setProperty('border-color',     '#6c63ff', 'important');
            el.style.setProperty('font-weight',      '700',     'important');
            // Also force any inner <a> tag
            var a = el.querySelector('a');
            if (a) {
              a.style.setProperty('color',            '#ffffff', 'important');
              a.style.setProperty('-webkit-text-fill-color', '#ffffff', 'important');
            }
          });
        }

        // Run once after a short delay (for initial tables)
        setTimeout(fixPagination, 800);

        // Watch for future DOM changes (page clicks, tab switches)
        var observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(m) {
            if (m.addedNodes.length || m.target.className) {
              fixPagination();
            }
          });
        });
        observer.observe(document.body, { subtree: true, childList: true, attributes: true, attributeFilter: ['class'] });

        // Also fire on every pagination click
        document.addEventListener('click', function(e) {
          if (e.target.closest('.dataTables_paginate')) {
            setTimeout(fixPagination, 80);
          }
        });
      });
