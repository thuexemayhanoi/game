# Browser smoke tests

Playwright smoke tests for the exported Godot Web build, run in CI across five
representative viewports (desktop, laptop, mobile portrait x2, mobile landscape).
They verify: page loads, canvas appears, no fatal console errors, critical files
present, resize does not crash. Visual gameplay hooks will be added gradually.

Run locally: serve `build/web` on port 8080, then `npm ci && npx playwright test`.
