# PERFORMANCE — MOTO HOP

Must run smoothly from small phones (320px width) to desktops. Degrade gracefully;
never crash on weak hardware.

## Strategy

- Mobile web first: portrait 540x960 base resolution, canvas_items stretch, expand aspect.
- Object pooling everywhere: obstacles (6 pooled nodes), audio players (6), UI built once.
- No per-frame allocations in the gameplay loop; all gameplay math is plain float math.
- All art is procedural _draw() geometry — no textures, no atlas loads, tiny build size.
- All audio is short runtime-generated PCM — no audio files shipped.
- Difficulty and every tuning constant live in src/data/difficulty.json with hard clamps.

## Web specifics

- Single-threaded export, compatibility renderer, no threads in gameplay code paths.
- Instant restart without page reload (state reset in place).
- No page scrolling: the canvas fills the viewport; UI is anchored and safe-area friendly.

## CI

Browser smoke tests assert load + boot + no horizontal scroll + tap, at 6 viewports
(320x568 up to 1920x1080), until suitable visual test hooks exist.
