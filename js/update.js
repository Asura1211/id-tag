(function () {
  if (!('serviceWorker' in navigator)) return;
  let updating = false;
  let banner;
  function showUpdate(registration) {
    if (!registration.waiting || !navigator.serviceWorker.controller || banner) return;
    banner = document.createElement('div');
    banner.className = 'update-notice';
    banner.setAttribute('role', 'status');
    banner.innerHTML = '<div><strong>发现新版本</strong><p>更新会刷新页面，当前演示操作会重置。</p></div><div class="update-actions"><button type="button" data-update="later">稍后</button><button type="button" data-update="now">立即更新</button></div>';
    banner.addEventListener('click', function (event) {
      const action = event.target.dataset.update;
      if (action === 'later') { banner.remove(); banner = null; }
      if (action === 'now' && registration.waiting) {
        updating = true;
        event.target.disabled = true;
        event.target.textContent = '更新中…';
        registration.waiting.postMessage({ type: 'SKIP_WAITING' });
      }
    });
    document.body.appendChild(banner);
  }
  navigator.serviceWorker.addEventListener('controllerchange', function () {
    if (updating) window.location.reload();
  });
  window.addEventListener('load', function () {
    navigator.serviceWorker.register('./sw.js', { updateViaCache: 'none' }).then(function (registration) {
      showUpdate(registration);
      registration.addEventListener('updatefound', function () {
        const worker = registration.installing;
        if (worker) worker.addEventListener('statechange', function () {
          if (worker.state === 'installed') showUpdate(registration);
        });
      });
      registration.update().catch(function () {});
      document.addEventListener('visibilitychange', function () {
        if (document.visibilityState === 'visible') registration.update().catch(function () {});
      });
    }).catch(function (error) { console.warn('Offline support unavailable:', error); });
  });
})();
