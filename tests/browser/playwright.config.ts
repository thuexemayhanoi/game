import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: '.',
  timeout: 90000,
  fullyParallel: true,
  retries: 0,
  reporter: 'list',
  use: {
    baseURL: 'http://localhost:8000',
  },
  webServer: {
    // Playwright runs webServer.command with cwd = the config file's directory
    // (tests/browser/), which is TWO levels below the repo root, so the web
    // build is at ../../build/web. (A single ../ was silently wrong: the
    // server started but 404'd every file, which is what broke the smoke job.)
    command: 'node serve.mjs ../../build/web 8000',
    port: 8000,
    reuseExistingServer: true,
    timeout: 20000,
  },
});
