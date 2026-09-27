# GAME DESIGN — MOTO HOP

Original IP. A cheerful one-button endless arcade game for children: a cute original
cartoon motorbike hops through a bright, Hanoi-inspired daytime city.
The genre (one-button endless obstacle dodging) is generic and not owned by anyone;
all artwork, obstacle designs, names, audio and UI in this project are original.

## Core loop

TAP → HOP → PASS OBSTACLE → +1 SCORE → CRASH (friendly) → PLAY AGAIN (instant).

- One input: tap (touch), Space / Up / left-click (desktop), gamepad A.
- Each input gives a short, forgiving upward hop. Gravity pulls the bike down.
- The bike tilts up while boosting and down while falling (gentle, never extreme).
- Crash = friendly: stars/dust feel, no gore, no injury, quick restart.

## Player bike

An original cartoon scooter: two spinning wheels, orange shell, yellow headlight,
seat, handlebar and a friendly helmeted rider silhouette. Subtle squash on hop,
wheel rotation, no real-brand logos anywhere (original fictional bike).

## Obstacles (all original, Hanoi-flavored)

Endless pairs with a guaranteed safe opening; three rotating procedural themes:

- construction barriers (striped, with edge caps)
- stacked delivery boxes
- street gates with sign boards and small lamps

Placement is seeded and deterministic for testing. Obstacle nodes are pooled —
nothing is created or destroyed during gameplay.

## Scoring

+1 per obstacle pair, passed exactly once. Big centered score, separate BEST score.
Milestones at 10 / 25 / 50 / 100 trigger a light sound + score pop, never blocking play.
Best score persists via the versioned save (graceful without storage).

## Difficulty (data-driven)

`src/data/difficulty.json` tiers, all capped by `DifficultyManager` so the game is
always playable for children:

| Score | Scroll speed | Gap |
|-------|--------------|-----|
| 0     | 180 px/s     | 320 px |
| 10    | 210           | 290 |
| 25    | 240           | 265 |
| 50    | 280           | 240 |
| 100   | 320           | 220 |
| 200+  | 340 (capped) | 210 (capped) |

Minimum gap (200 px) always exceeds the bike's collision size — mathematically
impossible gaps cannot occur.

## Game states

BOOT → MENU (title, best score, PLAY, "Tap / Space to Hop") → READY (3 2 1 GO!)
→ PLAYING → PAUSED ⇄ PLAYING → GAME_OVER (score, best, PLAY AGAIN, HOME) → READY/MENU.
Restart is in-place and instant — the browser page never reloads.

## Visual style

Bright daytime city with parallax layers: sky, far skyline, mid buildings,
trees + street lamps, road foreground. All procedural drawings, no textures.

## Audio

Original tones generated at runtime as PCM (hop, score, crash, click, milestone).
Mute button persists its preference. The game is fully playable without audio.

## Accessibility & privacy

Large buttons (min 72 px), readable outlined text, keyboard support, pause, mute,
no reliance on color alone; no analytics, cookies, login, backend, or trackers.

## Optional future (MH2 backlog)

Collectible coins/stars, milestone celebrations, cosmetic bike colors,
reduced-motion toggle, native exports. See GAME-0267+ in the Master Matrix.
