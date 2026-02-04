/**
 * React Component Registry for live_react
 *
 * This is the bridge between Phoenix LiveView and React. Every component
 * you want to render via `<.react name="ComponentName" />` must be exported here.
 *
 * That's it. No routing. No providers at this level. Just a map of names to components.
 *
 * In your LiveView:
 *   <.react name="DemoLayout" count={@count} />
 *
 * live_react looks up "DemoLayout" in this registry, passes the assigns as props,
 * and renders. When assigns change, it re-renders with new props.
 *
 * Boring? Yes. That's the point.
 */

import { Link } from "live_react";
import { CounterDemoLayout } from "./demos/counter/layout/CounterDemoLayout";
import { TodoDemoLayout } from "./demos/todos/layout/TodoDemoLayout";

export default {
  CounterDemoLayout,
  TodoDemoLayout,
  Link,
};
