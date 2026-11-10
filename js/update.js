(function () {
  if (!('serviceWorker' in navigator)) return;
  let hadController = !!navigator.serviceWorker.controller;
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
        event.target.disabled = true;
        event.target.textContent = '更新中…';
        registration.waiting.postMessage({ type: 'SKIP_WAITING' });
      }
    });
    document.body.appendChild(banner);
  }
  navigator.serviceWorker.addEventListener('controllerchange', function () {
    if (hadController) window.location.reload();
    hadController = true;
  });
  window.addEventListener('load', function () {
    navigator.serviceWorker.register('./sw.js', { updateViaCache: 'none' }).then(function (registration) {
      function watchInstalling() {
        const worker = registration.installing;
        if (worker) worker.addEventListener('statechange', function () {
          if (worker.state === 'installed') showUpdate(registration);
        });
      }
      function checkForUpdate() {
        showUpdate(registration);
        registration.update().then(function () { showUpdate(registration); }).catch(function () {});
      }
      registration.addEventListener('updatefound', watchInstalling);
      watchInstalling();
      checkForUpdate();
      document.addEventListener('visibilitychange', function () {
        if (document.visibilityState === 'visible') checkForUpdate();
      });
      window.addEventListener('pageshow', checkForUpdate);
      window.addEventListener('focus', checkForUpdate);
      window.addEventListener('online', checkForUpdate);
      window.setInterval(function () {
        if (document.visibilityState === 'visible') checkForUpdate();
      }, 60000);
    }).catch(function (error) { console.warn('Offline support unavailable:', error); });
  });
})();
