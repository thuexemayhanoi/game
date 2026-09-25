import { test, expect } from '@playwright/test';

// Browser smoke over 5 viewports (1920x1080, 1366x768, 390x844, 412x915, 844x390).
// Pass criteria: canvas renders, no fatal console errors within the observation window.
const VIEWPORTS = [
  { width: 1920, height: 1080 },
  { width: 1366, height: 768 },
  { width: 390, height: 844 },
  { width: 412, height: 915 },
  { width: 844, height: 390 },
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
    await page.waitForTimeout(4000);
    const fatal = fatalErrors.filter((e) =>
      !/favicon|Slow network|WebGL|webgl|GPU|gpu|Automatic fallback/i.test(e)
    );
    expect(fatal, 'fatal errors: ' + fatal.join(' | ')).toEqual([]);
  });
}
