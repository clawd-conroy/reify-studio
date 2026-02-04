/**
 * React Component Registry for live_react
 *
 * This is the bridge between Phoenix LiveView and React. Every component
 * you want to render via `<.react name="ComponentName" />` must be exported here.
 *
 * In your LiveView:
 *   <.react name="MyComponent" someProp={@value} />
 *
 * live_react looks up the name in this registry, passes the assigns as props,
 * and renders. When assigns change, it re-renders with new props.
 */

import { Link } from "live_react";

export default {
  Link,
};
