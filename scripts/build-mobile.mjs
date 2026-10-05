import { mkdir, cp, readFile, writeFile, readdir } from 'node:fs/promises';
import { build } from 'esbuild';
import { existsSync } from 'node:fs';
await mkdir('www', { recursive: true });
for (const folder of ['Admin', 'Doctor', 'Secretary', 'Javascript', 'css']) await cp(folder, `www/${folder}`, { recursive: true });
await cp('index.html', 'www/index.html');
await build({ entryPoints: ['mobile/supabase-entry.js'], bundle: true, format: 'iife', outfile: 'www/Javascript/supabase-vendor.js', minify: true });
await build({ entryPoints: ['mobile/push.js'], bundle: true, format: 'iife', outfile: 'www/Javascript/native-push.js', minify: true, define: { ENT_FIREBASE_CONFIGURED: String(existsSync('android/app/google-services.json')) } });
await build({ entryPoints: ['mobile/camera.js'], bundle: true, format: 'iife', outfile: 'www/Javascript/native-camera.js', minify: true });
await build({ entryPoints: ['mobile/print.js'], bundle: true, format: 'iife', outfile: 'www/Javascript/native-print.js', minify: true });
for (const folder of ['', 'Admin', 'Doctor', 'Secretary']) {
    const directory = folder ? `www/${folder}` : 'www';
    for (const name of await readdir(directory)) {
        if (!name.endsWith('.html')) continue;
        const path = `${directory}/${name}`;
        const prefix = folder ? '../' : '';
        let html = await readFile(path, 'utf8');
        html = html.replace('https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2', `${prefix}Javascript/supabase-vendor.js`);
        html = html.replace('</head>', `<script src="${prefix}Javascript/native-push.js" defer></script><script src="${prefix}Javascript/native-camera.js" defer></script><script src="${prefix}Javascript/native-print.js" defer></script></head>`);
        await writeFile(path, html);
    }
}
console.log('Mobile web assets built in www.');
