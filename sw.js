const CACHE='nolleogayo-2026-v5-redesign';
const REMOTE_ASSETS=['https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js','https://unpkg.com/leaflet@1.9.4/dist/leaflet.js','https://unpkg.com/leaflet@1.9.4/dist/leaflet.css'];
const ASSETS=['./','./index.html','./style.css','./v3-overrides.css','./app.js','./config.js','./manifest.webmanifest','./data/itinerary.json','./data/places.json','./assets/maps/fukuoka-city.svg','./assets/maps/kyushu-route.svg','./assets/cashmere.webp','./assets/logo.webp','./assets/hotel_fukuoka.webp','./assets/hotel_beppu.webp','./assets/apple-touch-icon.png'];
for(const role of ['dad','mom','sister','me'])for(const style of ['ac','chi'])ASSETS.push('./assets/avatars/'+role+'-'+style+'.png');
for(const x of ['food','parking','shop','attraction','hotel','passport','memo','car','plane','weather-sun','weather-cloud','weather-rain','sticker'])ASSETS.push('./assets/icons/'+x+'.svg');
self.addEventListener('install',event=>event.waitUntil(caches.open(CACHE).then(async c=>{await c.addAll(ASSETS);await Promise.all(REMOTE_ASSETS.map(async url=>{try{const r=await fetch(url,{mode:'no-cors'});await c.put(url,r)}catch(e){/* online CDNs still work, offline fallback for these optional */}}))}).then(()=>self.skipWaiting())));
self.addEventListener('activate',event=>event.waitUntil(caches.keys().then(names=>Promise.all(names.filter(n=>n!==CACHE).map(n=>caches.delete(n)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',event=>{
 const req=event.request;
 if(req.method!=='GET')return;
 if(REMOTE_ASSETS.includes(req.url)){event.respondWith(caches.match(req).then(hit=>hit||fetch(req)));return}
 if(new URL(req.url).origin!==self.location.origin)return; // never cache API/private notes
 const url=new URL(req.url);if(!url.pathname.startsWith(new URL(self.registration.scope).pathname))return;
 event.respondWith(caches.match(req).then(cached=>{
   const fetchIt=fetch(req).then(response=>{if(response.ok && response.type==='basic'){const clone=response.clone();caches.open(CACHE).then(c=>c.put(req,clone))}return response});
   if(cached){fetchIt.catch(()=>{});return cached}
   return fetchIt.catch(()=>req.mode==='navigate'?caches.match('./index.html'):Response.error());
 }));
});
