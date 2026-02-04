// Used by Vite SSR for server-side rendering of React components
import { getRender } from "live_react/server";
import components from "../src";

export const render = getRender(components);
