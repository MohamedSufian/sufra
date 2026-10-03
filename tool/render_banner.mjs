// Renders docs/brand/banner.html to PNGs with headless Chrome (no installs):
//   node tool/render_banner.mjs
// Writes banner.png (2560×1280, for the README) and social-preview.png (1280×640, under GitHub's 1 MB limit).
import { spawn } from 'node:child_process';
import { mkdtempSync, writeFileSync, statSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const CHROME = process.env.CHROME ?? 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const PORT = 9335;
const html = fileURLToPath(new URL('../docs/brand/banner.html', import.meta.url));
const outDir = fileURLToPath(new URL('../docs/brand/', import.meta.url));
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const chrome = spawn(CHROME, ['--headless=new', '--disable-gpu', '--hide-scrollbars', '--allow-file-access-from-files',
  `--remote-debugging-port=${PORT}`, `--user-data-dir=${mkdtempSync(join(tmpdir(), 'banner-'))}`, '--no-first-run', 'about:blank'],
  { stdio: 'ignore' });
try {
  let target;
  for (let i = 0; i < 50 && !target; i++) {
    await sleep(200);
    try { target = (await (await fetch(`http://127.0.0.1:${PORT}/json/list`)).json()).find((t) => t.type === 'page'); } catch {}
  }
  if (!target) throw new Error('Chrome did not start');
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => ws.addEventListener('open', r, { once: true }));
  let id = 0;
  const pending = new Map();
  ws.addEventListener('message', (e) => {
    const m = JSON.parse(e.data);
    if (!pending.has(m.id)) return;
    const p = pending.get(m.id);
    pending.delete(m.id);
    m.error ? p.reject(new Error(m.error.message)) : p.resolve(m.result);
  });
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const i = ++id;
    pending.set(i, { resolve, reject });
    ws.send(JSON.stringify({ id: i, method, params }));
  });

  for (const [name, scale] of [['banner.png', 2], ['social-preview.png', 1]]) {
    await send('Emulation.setDeviceMetricsOverride', { width: 1280, height: 640, deviceScaleFactor: scale, mobile: false });
    await send('Page.navigate', { url: pathToFileURL(html).href });
    await sleep(2500); // fonts and images
    const { data } = await send('Page.captureScreenshot', { format: 'png' });
    const out = join(outDir, name);
    writeFileSync(out, Buffer.from(data, 'base64'));
    console.log(`wrote ${name} (${Math.round(statSync(out).size / 1024)} KB)`);
  }
  ws.close();
} finally {
  chrome.kill();
}
