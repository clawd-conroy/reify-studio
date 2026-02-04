## 1. Implementation

- [x] 1.1 Create `DemosLive` LiveView at `lib/reify_web/pages/demos/demos_live.ex`
- [x] 1.2 Add demo card component with icon placeholder, title, description, and link
- [x] 1.3 Style cards as ~300x400px side-by-side horizontal layout using Tailwind
- [x] 1.4 Add Counter demo card: icon, "Counter Demo" title, description of SSR vs LiveReact patterns
- [x] 1.5 Add Todos demo card: icon, "Todos Demo" title, description of event-based render lifecycle
- [x] 1.6 Update `router.ex`: add `/demos` route to `DemosLive`, change `/` to render `DemosLive`
- [x] 1.7 Add breadcrumb component to `CounterDemo` linking back to `/demos`
- [x] 1.8 Add breadcrumb component to `TodoDemo` linking back to `/demos`
- [x] 1.9 Verify navigation flow: `/` -> card click -> demo page -> breadcrumb -> `/demos`
