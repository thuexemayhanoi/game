import { test, expect } from '@playwright/test';

// Browser smoke tests for the Godot Web build.
// These verify load/boot plumbing only — no visual gameplay automation yet
// (test hooks will be added gradually; see docs/TESTING.md).

test('page loads with Godot canvas', async ({ page }) => {
  const errors: string[] = [];
  page.on('pageerror', (err) => errors.push(String(err)));
  await page.goto('/', { waitUntil: 'domcontentloaded' });
  const canvas = page.locator('canvas').first();
  await expect(canvas).toBeVisible({ timeout: 30000 });
  await page.waitForTimeout(5000);
  // No fatal JS errors during load.
  const fatal = errors.filter((e) => !e.includes('AbortError') && !e.includes('SharedArrayBuffer'));
  expect(fatal, 'fatal console errors: ' + fatal.join(' | ')).toHaveLength(0);
});

test('loading completes and engine stays alive', async ({ page }) => {
  await page.goto('/', { waitUntil: 'domcontentloaded' });
  await expect(page.locator('canvas').first()).toBeVisible({ timeout: 30000 });
  await page.waitForTimeout(8000);
  await expect(page.locator('canvas').first()).toBeVisible();
});

test('resize does not crash', async ({ page }) => {
  await page.goto('/', { waitUntil: 'domcontentloaded' });
  await expect(page.locator('canvas').first()).toBeVisible({ timeout: 30000 });
  await page.setViewportSize({ width: 320, height: 240 });
  await page.waitForTimeout(1000);
  await page.setViewportSize({ width: 1920, height: 1080 });
  await page.waitForTimeout(1000);
  await expect(page.locator('canvas').first()).toBeVisible();
});

test('no missing critical files', async ({ request }) => {
  for (const file of ['index.html', 'index.js', 'index.pck', 'index.wasm']) {
    const res = await request.get('/' + file);
    expect(res.status(), file + ' must exist').toBe(200);
  }
});
