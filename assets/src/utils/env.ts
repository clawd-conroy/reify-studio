/**
 * Environment detection utilities.
 *
 * Uses Vite's built-in import.meta.env which is statically replaced at build time.
 * - import.meta.env.DEV: true in dev, false in production build
 * - import.meta.env.PROD: true in production build, false in dev
 */

export const isDev = import.meta.env.DEV;
export const isProd = import.meta.env.PROD;
