import { defineConfig } from '@playwright/test';

const VIEWPORTS = [
  { name: 'desktop-1920x1080', width: 1920, height: 1080 },
  { name: 'laptop-1366x768', width: 1366, height: 768 },
  { name: 'mobile-portrait-390x844', width: 390, height: 844, touch: true },
  { name: 'mobile-portrait-412x915', width: 412, height: 915, touch: true },
  { name: 'mobile-landscape-844x390', width: 844, height: 390, touch: true },
];

export default defineConfig({
  testDir: '.',
  timeout: 60000,
  retries: 1,
  use: { baseURL: process.env.BASE_URL || 'http://localhost:8080' },
  projects: VIEWPORTS.map((v) => ({
    name: v.name,
    use: { viewport: { width: v.width, height: v.height }, ...(v.touch ? { hasTouch: true } : {}) },
  })),
  reporter: [['list'], ['html', { open: 'never' }]],
});
