/* ZDiamond CRM Service Worker v13.52 */
const APP_VERSION = "v13.52";
const CACHE_NAME = "zdiamond-crm-app-v13-52";
const APP_SHELL = ["/","/index.html","/manifest.webmanifest","/icons/icon-192.png","/icons/icon-512.png"];
self.addEventListener("install", event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(APP_SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener("activate", event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(
    keys.filter(key => key.startsWith("zdiamond-crm-app-") && key !== CACHE_NAME).map(key => caches.delete(key))
  )).then(() => self.clients.claim()));
});
self.addEventListener("message", event => {
  if(event.data && event.data.type === "SKIP_WAITING") self.skipWaiting();
});
self.addEventListener("fetch", event => {
  const req = event.request;
  if(req.method !== "GET") return;
  const url = new URL(req.url);
  if(url.hostname.includes("supabase.co") || url.hostname.includes("googleapis.com") || url.hostname.includes("accounts.google.com") || url.hostname.includes("gstatic.com")){
    event.respondWith(fetch(req)); return;
  }
  if(req.mode === "navigate" || url.pathname === "/" || url.pathname.endsWith("index.html") || url.pathname.endsWith("service-worker.js")){
    event.respondWith(fetch(req, {cache:"no-store"}).then(res => {
      const copy=res.clone();
      if(res && res.ok && url.origin===location.origin) caches.open(CACHE_NAME).then(cache=>cache.put(req, copy));
      return res;
    }).catch(()=>caches.match(req)));
    return;
  }
  event.respondWith(caches.match(req).then(cached => {
    const networkFetch=fetch(req).then(res=>{
      if(res && res.ok && url.origin===location.origin){
        const copy=res.clone();
        caches.open(CACHE_NAME).then(cache=>cache.put(req, copy));
      }
      return res;
    }).catch(()=>cached);
    return cached || networkFetch;
  }));
});
