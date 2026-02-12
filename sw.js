/**
 * Service Worker for Hunter Wetlands Visitor Guide
 * Enables offline access to the app
 */

var CACHE_NAME = 'wetlands-guide-v1';
var URLS_TO_CACHE = [
  '/',
  '/index.html',
  '/css/styles.css',
  '/js/app.js',
  '/manifest.json',
  '/icons/icon.svg'
];

// Install - cache core assets
self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function (cache) {
      return cache.addAll(URLS_TO_CACHE);
    })
  );
});

// Activate - clean up old caches
self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheNames) {
      return Promise.all(
        cacheNames
          .filter(function (name) {
            return name !== CACHE_NAME;
          })
          .map(function (name) {
            return caches.delete(name);
          })
      );
    })
  );
});

// Fetch - serve from cache, fall back to network
self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request).then(function (response) {
      if (response) {
        return response;
      }
      return fetch(event.request).then(function (networkResponse) {
        // Cache successful GET responses
        if (networkResponse && networkResponse.status === 200 && event.request.method === 'GET') {
          var responseClone = networkResponse.clone();
          caches.open(CACHE_NAME).then(function (cache) {
            cache.put(event.request, responseClone);
          });
        }
        return networkResponse;
      });
    }).catch(function () {
      // Offline fallback for HTML pages
      if (event.request.headers.get('accept').indexOf('text/html') !== -1) {
        return caches.match('/index.html');
      }
    })
  );
});
