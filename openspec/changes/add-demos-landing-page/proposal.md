# Change: Add Demos Landing Page

## Why

Currently `/` routes directly to the Counter demo, making it unclear that multiple demos exist (Counter, Todos). Users need a discoverable entry point to browse available demos with visual previews and descriptions.

## What Changes

- Create a new `/demos` landing page showing all available demos as large cards (pure HEEx, no React needed)
- Each card displays: icon placeholder, title, brief description of what the demo showcases
- Cards link to their respective demo routes using standard Phoenix navigation
- Add breadcrumb navigation to individual demo pages for easy return to `/demos`
- Update root route `/` to render the demos landing page instead of Counter demo

## Impact

- Affected specs: None (new `demos-navigation` capability)
- Affected code:
  - `lib/reify_studio_web/router.ex` - New `/demos` route, update `/` route
  - `lib/reify_studio_web/pages/demos/` - New `demos_live.ex` landing page (HEEx templates only)
  - `lib/reify_studio_web/pages/demos/counter_demo.ex` - Add breadcrumb
  - `lib/reify_studio_web/pages/demos/todo_demo.ex` - Add breadcrumb
