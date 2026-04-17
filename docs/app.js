/* ============================================================
   Leftover Roulette — Documentation JS
   ============================================================ */

document.addEventListener('DOMContentLoaded', () => {

  /* ---- Elements ---- */
  const sidebar  = document.getElementById('sidebar');
  const overlay  = document.getElementById('overlay');
  const navItems = document.querySelectorAll('.nav-item');
  const sections = document.querySelectorAll('.doc-section');

  /* ============================================================
     SIDEBAR — MOBILE TOGGLE
     ============================================================ */
  window.toggleSidebar = () => {
    sidebar.classList.toggle('open');
    overlay.classList.toggle('active');
  };

  window.closeSidebar = () => {
    sidebar.classList.remove('open');
    overlay.classList.remove('active');
  };

  // Close on nav item click (mobile)
  navItems.forEach(item => {
    item.addEventListener('click', () => {
      if (window.innerWidth <= 768) closeSidebar();
    });
  });

  /* ============================================================
     ACTIVE NAV — INTERSECTION OBSERVER
     ============================================================ */
  const setActive = (id) => {
    navItems.forEach(item => {
      item.classList.remove('active');
      if (item.dataset.section === id) item.classList.add('active');
    });
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) setActive(entry.target.id);
    });
  }, { rootMargin: '-15% 0px -75% 0px' });

  sections.forEach(s => observer.observe(s));

  /* ============================================================
     NAVIGATE TO SECTION
     ============================================================ */
  window.navigateTo = (id) => {
    const el = document.getElementById(id);
    if (el) el.scrollIntoView({ behavior: 'smooth' });
  };

  /* ============================================================
     SCREEN TABS
     ============================================================ */
  window.switchScreen = (screen, btn) => {
    // Swap iframe source
    const iframe = document.getElementById('screen-iframe');
    if (iframe) {
      // Fade out → swap → fade in
      iframe.style.opacity = '0';
      iframe.style.transition = 'opacity 0.2s ease';
      setTimeout(() => {
        iframe.src = `screens/${screen}.html`;
        iframe.style.opacity = '1';
      }, 200);
    }

    // Update tab states
    document.querySelectorAll('.screen-tab').forEach(t => t.classList.remove('active'));
    btn.classList.add('active');

    // Update descriptions
    document.querySelectorAll('.screen-desc').forEach(d => d.classList.remove('active'));
    const desc = document.getElementById(`screen-desc-${screen}`);
    if (desc) desc.classList.add('active');
  };

  /* ============================================================
     SIDEBAR SEARCH — simple text filter
     ============================================================ */
  const searchInput = document.getElementById('search-input');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      const q = e.target.value.trim().toLowerCase();

      if (!q) {
        navItems.forEach(i => (i.style.display = ''));
        document.querySelectorAll('.nav-group').forEach(g => (g.style.display = ''));
        return;
      }

      document.querySelectorAll('.nav-group').forEach(group => {
        const items = group.querySelectorAll('.nav-item');
        let visible = 0;
        items.forEach(item => {
          const match = item.textContent.toLowerCase().includes(q);
          item.style.display = match ? '' : 'none';
          if (match) visible++;
        });
        group.style.display = visible === 0 ? 'none' : '';
      });
    });

    // Clear search on Escape
    searchInput.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        searchInput.value = '';
        searchInput.dispatchEvent(new Event('input'));
      }
    });
  }

  /* ============================================================
     COPY CODE BLOCKS
     ============================================================ */
  document.querySelectorAll('.code-block').forEach(block => {
    const btn = document.createElement('button');
    btn.className = 'copy-btn';
    btn.textContent = 'Copy';
    btn.setAttribute('aria-label', 'Copy code');

    btn.addEventListener('click', () => {
      const text = block.querySelector('code')?.innerText ?? block.innerText;
      // Strip span tags for clean copy
      const cleanText = block.querySelector('code')?.textContent ?? block.textContent;
      navigator.clipboard.writeText(cleanText.trim()).then(() => {
        btn.textContent = 'Copied!';
        btn.classList.add('copied');
        setTimeout(() => { btn.textContent = 'Copy'; btn.classList.remove('copied'); }, 2000);
      });
    });

    const wrapper = document.createElement('div');
    wrapper.className = 'code-block-wrapper';
    block.parentNode.insertBefore(wrapper, block);
    wrapper.appendChild(btn);
    wrapper.appendChild(block);
  });

});
