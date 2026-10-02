// Takes the README screenshots from the web build, at an exact phone size.
//
//   flutter build web --release --dart-define-from-file=supabase.json
//   PORT=8788 node tool/serve_web.js        (in another terminal)
//   node tool/screenshots.mjs
//
// Drives a headless Chrome over the DevTools protocol (Node's built-in fetch/WebSocket, no installs),
// because Chrome's --window-size can't go narrower than ~490 px on Windows.
import { spawn } from 'node:child_process';
import { mkdirSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const APP = process.env.APP_URL ?? 'http://localhost:8788';
const OUT = new URL('../docs/screenshots/', import.meta.url);
const CHROME = process.env.CHROME ?? 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const PORT = 9333;
const PHONE = { width: 390, height: 844, deviceScaleFactor: 2, mobile: true };
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// shared_preferences on the web stores JSON-encoded values under a "flutter." prefix.
const prefs = (o) => Object.fromEntries(Object.entries(o).map(([k, v]) => [`flutter.${k}`, JSON.stringify(v)]));
const base = (locale, theme) => prefs({ 'settings.locale': locale, 'settings.themeMode': theme, 'settings.onboardingSeen': true });

const mix = {
  id: 'bahr-grill.mix', restaurantId: 'bahr-grill', sectionId: 'grill', nameAr: 'مشكل مشاوي', nameEn: 'Mixed grill',
  descAr: 'كباب وشيش طاووق وكفتة مع خبز طابون وسلطة', descEn: 'Kebab, shish tawook and kofta with taboon bread and salad',
  price: 45, artIndex: 0,
};
const family = { id: 'size.family', nameAr: 'وجبة عائلية', nameEn: 'Family meal', priceDelta: 40 };
const address = {
  id: 'demo', label: 'home', lat: 31.518, lng: 34.464, areaAr: 'الدرج، غزة', areaEn: 'Ad-Daraj, Gaza',
  landmark: 'قرب مسجد الشمعة', details: '', phone: '0591234567',
};
const cart = { restaurantId: 'bahr-grill', lines: [{ product: mix, quantity: 2, choices: [family], note: 'بدون بصل' }] };
const order = () => ({
  id: 1001, restaurantId: 'bahr-grill', restaurantAr: 'مشاوي البحر', restaurantEn: 'Al-Bahr Grill',
  lines: cart.lines, address, payment: 'cash', subtotal: 170, deliveryFee: 5, discount: 30, promoCode: 'SUFRA20',
  placedAt: new Date(Date.now() - 100_000).toISOString(), etaMin: 25, etaMax: 35, status: 'placed',
  restaurantLat: 31.524, restaurantLng: 34.442,
});

const shots = [
  { name: '01-home-ar-light', path: '/#/home', storage: base('ar', 'light') },
  { name: '02-home-en-dark', path: '/#/home', storage: base('en', 'dark') },
  { name: '03-restaurant-ar-dark', path: '/#/home/restaurant/bahr-grill', storage: base('ar', 'dark') },
  // Taps the "Mixed grill" card to open its options sheet.
  { name: '04-dish-options-ar-light', path: '/#/home/restaurant/bahr-grill', storage: base('ar', 'light'), tap: [300, 770] },
  { name: '05-checkout-ar-light', path: '/#/checkout', storage: { ...base('ar', 'light'), ...prefs({ 'cart.v1': JSON.stringify(cart), 'addresses.v1': JSON.stringify({ selectedId: 'demo', addresses: [address] }) }) } },
  { name: '06-map-ar-dark', path: '/#/address/pick', storage: base('ar', 'dark') },
  { name: '07-tracking-ar-dark', path: '/#/orders/1001', storage: () => ({ ...base('ar', 'dark'), ...prefs({ 'orders.v1': JSON.stringify([order()]) }) }) },
];

const profile = mkdtempSync(join(tmpdir(), 'sufra-shots-'));
const chrome = spawn(CHROME, [
  '--headless=new', '--disable-gpu', '--hide-scrollbars', `--remote-debugging-port=${PORT}`,
  `--user-data-dir=${profile}`, '--no-first-run', 'about:blank',
], { stdio: 'ignore' });

try {
  let target;
  for (let i = 0; i < 50 && !target; i++) {
    await sleep(200);
    try {
      target = (await (await fetch(`http://127.0.0.1:${PORT}/json/list`)).json()).find((t) => t.type === 'page');
    } catch { /* Chrome still starting */ }
  }
  if (!target) throw new Error('Chrome did not start');

  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => ws.addEventListener('open', r, { once: true }));
  let nextId = 0;
  const pending = new Map();
  ws.addEventListener('message', (e) => {
    const msg = JSON.parse(e.data);
    if (pending.has(msg.id)) {
      const { resolve, reject } = pending.get(msg.id);
      pending.delete(msg.id);
      msg.error ? reject(new Error(msg.error.message)) : resolve(msg.result);
    }
  });
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = ++nextId;
    pending.set(id, { resolve, reject });
    ws.send(JSON.stringify({ id, method, params }));
  });
  const evaluate = (expression) => send('Runtime.evaluate', { expression, awaitPromise: true });

  await send('Emulation.setDeviceMetricsOverride', PHONE);
  await send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
  mkdirSync(OUT, { recursive: true });

  // ONLY=04 node tool/screenshots.mjs  → just the shots whose name starts with "04".
  for (const shot of shots.filter((s) => !process.env.ONLY || s.name.startsWith(process.env.ONLY))) {
    const storage = typeof shot.storage === 'function' ? shot.storage() : shot.storage;
    // Same origin first so localStorage applies, then load the screen fresh.
    await send('Page.navigate', { url: `${APP}/` });
    await sleep(800);
    await evaluate(`localStorage.clear(); Object.entries(${JSON.stringify(storage)}).forEach(([k, v]) => localStorage.setItem(k, v));`);
    await send('Page.navigate', { url: `${APP}${shot.path}` });
    await evaluate('location.reload()');
    await sleep(9000); // engine, fonts, data and entrance animations
    if (shot.tap) {
      // Touch, like a finger: the page is emulating a phone.
      const [x, y] = shot.tap;
      await send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y }] });
      await sleep(80);
      await send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
      await sleep(2500);
    }
    const { data } = await send('Page.captureScreenshot', { format: 'png' });
    writeFileSync(new URL(`${shot.name}.png`, OUT), Buffer.from(data, 'base64'));
    console.log('saved', shot.name);
  }
  ws.close();
} finally {
  chrome.kill();
}
