# Developer Guide — Local editing, assets, and best practices

This guide gives you the most useful, practical code snippets and tools to edit this small static React-like portfolio app. It's written for the current project layout (root contains `index.html`, `app.js`, and `components/`). Use this as a living document while you add features.

## Quick goals (contract)
- Inputs: edit files in `components/`, add images to `assets/` or `trickle/assets/`, optionally run local server.
- Outputs: working site at http://localhost:8000 (or as configured), correct icons and images, no remote dependencies required after one-time download.
- Error modes: missing vendor files => console errors; ES module/imports in browser => need bundler.
- Success: page renders with icons, images, and components show as expected.

## Project structure (what to expect)
- `index.html` — main HTML file. Currently loads local `vendor/` scripts and component scripts with `type="text/babel"` (Babel does runtime JSX transpile).
- `app.js` — mounts the app and wires components together.
- `components/` — contains UI pieces like `Header.js`, `Hero.js`, etc.
- `vendor/` — local vendor files (React, ReactDOM, Babel, Tailwind loader, lucide.css and font files).
- `trickle/assets/` — example JSON project files and notes; you can add images here or create a new `assets/` folder.

## Most common edits (recipes)

1) Add or update a component (JSX in-place)
- Create `components/MyWidget.js`:

```html
<!-- index.html loads babel before these scripts so runtime transpile works -->
<script type="text/babel" src="components/MyWidget.js"></script>
```

Example component file (functional React + JSX):

```javascript
// components/MyWidget.js
function MyWidget() {
  return (
    <section className="p-6 bg-white rounded shadow">
      <h2 className="text-2xl font-bold">My Widget</h2>
      <p className="text-gray-600">This is a local JSX component.</p>
    </section>
  );
}

// Attach to global so app.js can use it (since we're not bundling modules):
window.MyWidget = MyWidget;
```

In `app.js` you can then render it with ReactDOM:

```javascript
// app.js
const root = document.getElementById('root');
ReactDOM.render(<MyWidget />, root);
```

Notes:
- Because scripts are loaded non-module and without imports, we expose components to `window` and call them from `app.js`.
- This quick approach is great for small sites and learning, but not for production.

2) Add images and logos (most frequent reason for broken visuals)
- Recommended folder: create an `assets/` folder in the project root.
- Place images like `logo.png` or `avatar.jpg` there.
- Reference them from HTML or components with relative paths. For example, in a component using plain HTML:

```html
<img src="assets/logo.png" alt="Logo" class="w-28" />
```

Important notes:
- If you use `import logo from './logo.svg'` inside components this requires a bundler (Vite/webpack) because the browser can't resolve such imports without a build-step.
- If you keep runtime Babel in the browser, use regular <img src="..."> references.

3) Lucide icons font (the icons used by the theme)
- We put `lucide.css` and its font files into `vendor/`.
- Ensure the `lucide.css` file's URLs point to `vendor/lucide.woff2` etc. (they do if you downloaded files with the provided script).
- If icons are missing, check Network tab for 404s and confirm `vendor/lucide.woff2` exists.

4) Tailwind usage
- Current approach uses the CDN-style loader (`vendor/tailwindcdn.js`) which injects Tailwind at runtime.
- For small projects this is quick. For production, consider a build step to purge unused CSS and create a compact stylesheet.

## When to move to a bundler (Vite) — recommended next step
If you start needing:
- ES module imports (import/export),
- Local asset imports (import logo from './logo.svg'),
- Faster dev HMR and a production-ready bundle,
then use Vite. Minimal steps follow.

1) Install Node + npm (if you don't have them)
- Download Node LTS from nodejs.org (or use nvm for Windows). Verify:

```powershell
node -v
npm -v
```

2) Create package.json and install Vite (example commands for PowerShell):

```powershell
npm init -y
npm install --save-dev vite
```

3) Minimal `package.json` scripts (you can edit your package.json):

```json
"scripts": {
  "dev": "vite",
  "build": "vite build",
  "preview": "vite preview --port 5000"
}
```

4) Convert `index.html` to load module script in dev/build mode (example):
- Change to load a module bundle instead of text/babel. In Vite you'd write:

```html
<script type="module" src="/src/main.js"></script>
```

- Move your components under `src/` and use standard imports:

```javascript
// src/main.js
import React from 'react'
import ReactDOM from 'react-dom'
import Header from './components/Header'
import './styles.css'

ReactDOM.createRoot(document.getElementById('root')).render(<Header/>);
```

Vite will handle JSX and asset imports.

## Common troubleshooting (fast checks)
- Blank icons/images: open DevTools Network tab, filter by "font" or "img" and look for 404s. Fix by adding files to `vendor/` or `assets/` and updating paths.
- Unexpected token "import": indicates browser tried to execute ES module import without bundler. Move to Vite or remove import syntax.
- JSX not transformed: ensure `vendor/babel.min.js` is loaded before component scripts and that script tags use `type="text/babel"`.
- Tailwind classes not applied: verify `tailwindcdn.js` is loaded and not blocked. For production, build a CSS file instead of relying on CDN loader.

## Useful snippet: add local image and fallback

```html
<!-- in a component file using raw HTML/JSX -->
<img src="assets/avatar.jpg" alt="Me" onError="this.src='assets/avatar-fallback.png'" />
```

## Quick commands (PowerShell) you will use often
- Download vendors (one-time, online):

```powershell
.\download-vendors.ps1
```

- Serve locally with Python:

```powershell
python -m http.server 8000
# open http://localhost:8000
```

- Start Vite dev server (after `npm install`):

```powershell
npm run dev
# default http://localhost:5173
```

## Recommended dev tools and VS Code extensions
- VS Code (obviously) with:
  - ESLint
  - Prettier
  - Live Server (optional)
  - Tailwind CSS IntelliSense (if you rely on Tailwind)
  - GitLens
- Node.js LTS + npm
- Browser DevTools (Network, Console, Elements)

## Best practices (short)
- Keep images in `assets/` and reference them by relative path from `index.html` or components if not using imports.
- For small edits, in-browser Babel is fine. For a growing project, migrate to a bundler (Vite) quickly.
- Cache vendor files locally (we already do this with `vendor/`) so the site is offline-capable for development.
- Use semantic HTML and small components. Keep components single-purpose; expose them on `window` when not bundling.

## Example: converting a component to a local static import (no bundler)
If you don't want runtime Babel, you can write components as plain DOM-manipulating JS:

```javascript
// components/header-vanilla.js (no JSX, no React)
(function(){
  const root = document.getElementById('root');
  const header = document.createElement('header');
  header.innerHTML = '<h1>My Site</h1>';
  root.appendChild(header);
})();
```

This approach avoids the need for Babel but trades off React niceties.

---

If you want, I can now:
- Create a minimal `package.json` and Vite setup and move the project into `src/` (I can do this automatically), or
- Scan your `components/` for remote image URLs, download those images into `assets/`, and patch component `src` attributes to local paths.

Tell me which follow-up you'd like and I'll add it (I'll also update the todo list accordingly).