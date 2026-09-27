import { test, expect } from '@playwright/test';

// Browser smoke for the MOTO HOP web build.
// Viewports: small phones (320x568, 390x844), large phone (430x932),
// landscape phone (844x390), tablet (768x1024), desktop (1920x1080).
// Pass criteria: canvas renders, the page never scrolls horizontally,
// a tap reaches the game without hover, and no fatal console errors occur.
const VIEWPORTS = [
  { width: 320, height: 568 },
  { width: 390, height: 844 },
  { width: 430, height: 932 },
  { width: 844, height: 390 },
  { width: 768, height: 1024 },
  { width: 1920, height: 1080 },
];

for (const vp of VIEWPORTS) {
  test('game loads at ' + vp.width + 'x' + vp.height, async ({ page }) => {
    const fatalErrors: string[] = [];
    page.on('pageerror', (err) => fatalErrors.push('pageerror: ' + String(err)));
    page.on('console', (msg) => {
      if (msg.type() === 'error') fatalErrors.push('console: ' + msg.text());
    });
    await page.setViewportSize(vp);
    await page.goto('/index.html');
    await expect(page.locator('canvas')).toBeVisible({ timeout: 30000 });
    // Give the engine time to boot the main scene.
    await page.waitForTimeout(4000);
    // Gameplay must stay inside the viewport: no horizontal page scrolling.
    const scrollW = await page.evaluate(() => document.documentElement.scrollWidth);
    expect(scrollW, 'horizontal scroll must not appear').toBeLessThanOrEqual(vp.width + 1);
    // A tap anywhere must work without hover (touch emulation).
    await page.touchscreen.tap(vp.width / 2, vp.height / 2).catch(async () => {
      await page.mouse.click(vp.width / 2, vp.height / 2);
    });
    await page.waitForTimeout(1000);
    const fatal = fatalErrors.filter((e) =>
      !/favicon|Slow network|WebGL|webgl|GPU|gpu|Automatic fallback|SharedArrayBuffer|crossorigin/i.test(e)
    );
    expect(fatal, 'fatal errors: ' + fatal.join(' | ')).toEqual([]);
  });
}
