// ==UserScript==
// @name         YouTube: Hide Watched Videos
// @version      1.0.0
// @description  Hides videos (regular + shorts) that are more than 60% watched, with persistent toggle
// @author       Brett Crisp
// @match        https://*.youtube.com/*
// @grant        none
// @license      MIT
// @run-at       document-idle
// ==/UserScript==

(function () {
  'use strict';

  const STORAGE_KEY = 'yt-hide-watched';
  let hideWatched = localStorage.getItem(STORAGE_KEY) === 'true';

  function createButton(id, label, onClick) {
    const btn = document.createElement('button');
    btn.id = id;
    btn.textContent = hideWatched ? `${label} ❌` : label;
    btn.style.cssText = `
      margin-right: 8px;
      padding: 4px 8px;
      cursor: pointer;
      background: #fff;
      border: 1px solid #ccc;
      border-radius: 14px;
      font-size: 12px;
      order: -1;
    `;
    btn.addEventListener('click', () => {
      hideWatched = !hideWatched;
      localStorage.setItem(STORAGE_KEY, hideWatched);
      btn.textContent = hideWatched ? `${label} ❌` : label;
      updateVideos();
    });
    return btn;
  }

  function injectButton() {
    const container = document.querySelector('ytd-masthead #buttons');
    if (!container || document.getElementById('hide-watched-btn')) return;

    const btn = createButton('hide-watched-btn', 'Watched');
    container.insertBefore(btn, container.firstChild);
    updateVideos();
  }

  function updateVideos() {
    const videos = document.querySelectorAll('ytd-grid-video-renderer, ytd-video-renderer, ytd-rich-item-renderer');
    videos.forEach(video => {
      const progress = video.querySelector('#progress');
      if (progress && progress.style.width) {
        const percent = parseFloat(progress.style.width);
        video.style.display = (hideWatched && percent > 60) ? 'none' : '';
      } else {
        video.style.display = '';
      }
    });
  }

  // Watch for navigation
  const observer = new MutationObserver(() => injectButton());
  const header = document.querySelector('ytd-masthead');
  if (header) observer.observe(header, { childList: true, subtree: true });

  const videoObserver = new MutationObserver(updateVideos);
  videoObserver.observe(document.body, { childList: true, subtree: true });

  setTimeout(injectButton, 1200);
})();
