# Change: Add live_react Integration for React Components in LiveView

## Why

Our four-layer architecture requires React components to handle UI while LiveView manages WebSocket connections. Currently the project lacks React integration, blocking development of the Counter and Todo examples that demonstrate the event-driven pattern (pushEvent/handleEvent). The live_react library provides exactly this capability but requires switching from esbuild to Vite.

## What Changes

- **BREAKING**: Replace esbuild with Vite for JavaScript bundling
- Add `live_react` hex dependency for LiveView-React bridge
- Add npm dependencies: react, react-dom, @vitejs/plugin-react, typescript
- Configure Vite with React plugin and HMR support
- Set up `assets/react-components/` directory with TypeScript strict mode
- Update LiveSocket to include live_react hooks
- Add `<.react>` helper for rendering React components in HEEx templates

## Impact

- Affected specs: New `live-react-integration` capability
- Affected code:
  - `mix.exs` - add live_react, remove esbuild runtime dep
  - `config/config.exs` - remove esbuild config, add vite config
  - `config/dev.exs` - update watchers for vite
  - `assets/package.json` - new file with npm dependencies
  - `assets/vite.config.ts` - new Vite configuration
  - `assets/tsconfig.json` - update for React/strict mode
  - `assets/js/app.js` - add live_react hooks to LiveSocket
  - `assets/react-components/` - new directory for components
  - `lib/reify_web.ex` - import live_react helpers
