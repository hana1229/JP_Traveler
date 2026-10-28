const CACHE='little-trip-2026-v2';
const STATIC=['./','./index.html','./styles.css','./data.js','./app.js','./firebase-config.js','./manifest.webmanifest','./assets/icon.svg',...['dad','mom','sister','me'].flatMap(p=>['forest','chiikawa'].map(s=>`./assets/${s}-${p}.webp`))];
self.addEventListener('install',ev=>{ev.waitUntil(caches.open(CACHE).then(c=>c.addAll(STATIC)).then(()=>self.skipWaiting()))});
self.addEventListener('activate',ev=>{ev.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',ev=>{if(ev.request.method!=='GET'||new URL(ev.request.url).origin!==self.location.origin)return;ev.respondWith(caches.match(ev.request).then(cached=>cached||fetch(ev.request).then(res=>{if(res.ok){const clone=res.clone();caches.open(CACHE).then(c=>c.put(ev.request,clone))}return res}).catch(()=>caches.match('./index.html'))))});
