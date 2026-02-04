## Context

The Reify boilerplate uses a four-layer architecture where React handles UI and LiveView handles WebSocket communication. All client-server communication uses events (pushEvent/handleEvent), not REST or GraphQL. This requires integrating React components into LiveView pages.

**Stakeholders**: Developers using the boilerplate, future contributors

**Constraints**:
- Phoenix 1.8 / LiveView 1.1
- Must preserve Tailwind CSS 4.x + daisyUI setup
- TypeScript strict mode required
- HMR in development for rapid iteration

## Goals / Non-Goals

**Goals**:
- Render React components inside LiveView templates via `<.react>` helper
- Enable bidirectional event communication: pushEvent (client->server), handleEvent (server->client)
- Hot Module Replacement for React components in development
- TypeScript with strict mode enabled
- Maintain existing Tailwind/daisyUI styling pipeline

**Non-Goals**:
- Server-side rendering of React components
- React Router or client-side navigation
- State management libraries (Redux, Zustand, etc.)
- Component library integration (shadcn, MUI, etc.) - this is for the base integration only

## Decisions

### Decision 1: Use mrdotb/live_react

**Rationale**: This is the de facto standard for React-in-LiveView. It provides:
- Automatic prop serialization from LiveView assigns
- Built-in pushEvent/handleEvent plumbing
- Vite integration with HMR support
- Active maintenance and community support

**Alternatives considered**:
- **Custom WebSocket bridge**: More control but significant development effort
- **phoenix_live_react** (archive): Deprecated, no longer maintained
- **LiveView.JS + vanilla React**: No standardized prop passing, manual event wiring

### Decision 2: Vite instead of esbuild

**Rationale**: live_react requires Vite for its development server integration and HMR. Vite also provides:
- Native ESM for faster dev builds
- Better React Fast Refresh support
- Plugin ecosystem (important for future needs)

**Impact**: This is a breaking change to the asset pipeline. The esbuild configuration will be removed and replaced with Vite.

### Decision 3: Tailwind via @tailwindcss/vite plugin

**Rationale**: The `@tailwindcss/vite` plugin (Tailwind 4.x) integrates directly with Vite, providing:
- Single build tool for both JS and CSS
- Faster builds with Vite's native CSS handling
- HMR for both React components and Tailwind styles
- Simpler configuration (no separate mix tailwind watcher)

**Change from original plan**: We initially considered keeping Tailwind CLI separate, but the Vite plugin approach is cleaner and matches live_react's recommended setup.

### Decision 4: TypeScript strict mode from the start

**Rationale**: The boilerplate targets developers who want to understand their code. Strict TypeScript catches errors early and provides better IDE support. The initial setup cost is minimal.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Breaking change to asset pipeline | Clear migration path; single commit changes all config |
| Vite handles both JS and CSS | @tailwindcss/vite plugin is well-tested; simpler than separate watchers |
| live_react version compatibility | Pin to specific version; document upgrade path |
| Development environment complexity | Single Vite dev server handles everything |

## Migration Plan

1. Install live_react hex package
2. Create package.json with npm dependencies
3. Install npm dependencies (`npm install --prefix assets`)
4. Create vite.config.ts
5. Update tsconfig.json for React/strict mode
6. Remove esbuild configuration from config/config.exs
7. Update dev.exs watchers for Vite
8. Update assets.setup and assets.deploy mix aliases
9. Add live_react hooks to LiveSocket
10. Create react-components directory with index.tsx
11. Add react helper import to ReifyWeb
12. Create verification component (PingPong)

**Rollback**: Revert git commit; `npm uninstall` in assets; restore esbuild config

## Open Questions

None - the approach is well-documented in live_react's README and has been validated in production at multiple companies.
