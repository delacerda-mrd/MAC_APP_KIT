# Recipe — Stack A-G: WKWebView + canvas game loop

**Status: GUIDANCE, not a proven recipe.** Stack A's shell, build pipeline,
`app://` scheme, and audio rules are proven (FlamencoCompas-DS). Everything
below marked **UNPROVEN** has not yet survived a real project on these
machines — the first game project proves or corrects it, and this file gets
updated in that same session.

Start from `recipes/stack-a-files/` exactly as for Stack A. Differences:

- `src/app.jsx` holds the game, not a React tree. Set `SANITY_GREP=""` in
  `build.sh` if the game is vanilla JS (the default grep expects
  `ReactDOM.createRoot`). If React drives menus and vanilla JS drives the
  loop, keep the default grep and render menus into `#root`.
- `src/index.html` gets a `<canvas id="game">` alongside `#root`. Drop the
  react/react-dom script tags (and their `cp` lines in build.sh) if the game
  uses no React at all.

## Game loop skeleton (fixed timestep + rAF render)

Fixed-timestep update with an accumulator, decoupled from render, so physics
and game feel do not vary with frame rate:

```js
const STEP = 1000 / 60;        // ms per logic tick — pick from the SPEC's tick rate
const MAX_FRAME = 250;         // clamp: never simulate more than this in one frame
let acc = 0, last = 0, running = true;

function frame(now) {
  if (!running) return;                    // paused: no rAF chain, no accumulation
  let delta = now - last;
  last = now;
  if (delta > MAX_FRAME) delta = MAX_FRAME; // spiral-of-death guard after a stall
  acc += delta;
  while (acc >= STEP) { update(STEP); acc -= STEP; }
  render(acc / STEP);                       // interpolation factor for smooth motion
  requestAnimationFrame(frame);
}
```

**Pause on visibility change is mandatory, not optional.** `rAF` throttles
or stops when the window is backgrounded; without pause handling the
accumulator absorbs the entire away-time on return and the game state
desyncs (or the spiral guard silently eats it):

```js
document.addEventListener("visibilitychange", () => {
  if (document.hidden) { running = false; }
  else { running = true; last = performance.now(); acc = 0; requestAnimationFrame(frame); }
});
```

Resetting `last` and `acc` on resume is the load-bearing part — restarting
the rAF chain without it replays the away-time as one enormous delta.

## Input

Keyboard via the WKWebView: `keydown`/`keyup` on `window`, held-key state in
a `Set`, read by `update()` — never act directly in the event handler (input
must be sampled at tick rate, not at OS key-repeat rate).

**UNPROVEN / known discovery item:** some keys collide with the Swift
shell's menu shortcuts (the recipe `main.swift` installs Cmd+Q/W/X/C/V). A
game binding Cmd-anything, or wanting Space/arrows to never scroll, may need
the shell to stop installing that menu item or to forward the event. First
game project settles this and records the answer here.

## Audio

All Stack A audio rules apply (see TROUBLESHOOTING.md): lazy `AudioContext`
on first user gesture, `decodeAudioData(buf.slice(0))` always a copy. Plus:

- Schedule SFX via `AudioBufferSourceNode` started at an explicit
  `ctx.currentTime` (+ lookahead) — **never `<audio>` tags**, whose latency
  is unusable for game feedback.
- Decode every SFX buffer once at load and keep it; create a fresh
  `AudioBufferSourceNode` per playback (they are single-use).

## Persistence

`localStorage` is expected to work under the `app://` scheme — **OQ,
UNVERIFIED**. Verify on first use with a write→reload→read check. If it
fails, the fallback is the Swift shell exposing a read/write message handler
(`WKScriptMessageHandler` + `evaluateJavaScript`) backed by `UserDefaults` or
a file in Application Support. Record the outcome here either way.

## Performance budget (goes in the SPEC)

The SPEC's "Game loop & feel" section carries the numbers; the plan must
treat them as acceptance criteria, not aspirations:

- Target frame time (e.g. 60 fps = 16.7 ms; no frame > 33 ms during play)
- Entity-count ceiling the loop must sustain at that frame time
- Input-to-visible-response latency target
- Tick rate, and whether it is decoupled from render (it should be)
