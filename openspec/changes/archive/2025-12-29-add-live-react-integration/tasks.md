## 1. Elixir Dependencies

- [x] 1.1 Add `live_react` to mix.exs deps
- [x] 1.2 Run `mix deps.get`

## 2. NPM Setup

- [x] 2.1 Create `assets/package.json` with dependencies (react, react-dom, vite, @vitejs/plugin-react, typescript, @types/react, @types/react-dom, live_react npm package)
- [x] 2.2 Run `npm install --prefix assets`

## 3. Vite Configuration

- [x] 3.1 Create `assets/vite.config.ts` with React plugin and live_react plugin
- [x] 3.2 Update `assets/tsconfig.json` for React JSX and strict mode
- [x] 3.3 Create `assets/react-components/index.tsx` as component registry

## 4. Phoenix Configuration

- [x] 4.1 Remove esbuild config from `config/config.exs`
- [x] 4.2 Update `config/dev.exs` watchers to use Vite dev server
- [x] 4.3 Update `config/prod.exs` if needed for Vite build
- [x] 4.4 Update mix aliases in `mix.exs` (assets.setup, assets.build, assets.deploy)

## 5. LiveView Integration

- [x] 5.1 Update `assets/js/app.js` to import and register live_react hooks
- [x] 5.2 Add `use LiveReact` or import helpers in `lib/reify_studio_web.ex`
- [x] 5.3 Update `lib/reify_studio_web/components/layouts/root.html.heex` if needed for Vite assets

## 6. Verification

- [x] 6.1 Create `assets/react-components/PingPong.tsx` test component
- [x] 6.2 Create `lib/reify_studio_web/live/ping_pong_live.ex` LiveView
- [x] 6.3 Add route for verification page
- [x] 6.4 Test pushEvent (button click -> server) - verified via WebSocket inspection
- [x] 6.5 Test reactive props (server assigns -> React props) - using props instead of handleEvent
- [x] 6.6 Verify Tailwind classes work in React components - daisyUI card/btn/stats render correctly
- [x] 6.7 Verify HMR works (change component, see update without refresh)

## 7. Cleanup

- [x] 7.1 Remove esbuild dep from mix.exs (keep tailwind)
- [x] 7.2 Update `.gitignore` for node_modules if not already present
- [x] 7.3 Run `mix precommit` to ensure everything passes
