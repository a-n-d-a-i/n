# N v2 — HTML5 / WebGL port

A source-level JavaScript port of Metanet Software's **N v2** Flash game (`Nv2.swf`).
The original ActionScript has been translated to ES modules; the Flash display
list, audio, input, and bitmap/text APIs are provided by a small custom shim,
and rendering is a custom WebGL2 renderer. There are **no runtime third-party
libraries** and **no external network services**: every asset is a local file
fetched from the same static server.

## Running

The game uses ES modules and fetches its assets, so it must be served over HTTP
(opening `index.html` via `file://` will not work). From this directory:

```sh
python3 serve.py            # http://localhost:8000
# or
python3 -m http.server 8000 # http://localhost:8000
```

Then open <http://localhost:8000/> in a browser with WebGL2 enabled.
`serve.py` is a stdlib-only convenience wrapper with caching disabled.

## Controls

| Action | Key |
| --- | --- |
| Move | Left / Right arrows |
| Jump | Z |
| Suicide | K |
| Pause | P |
| Quit (while paused) | Q |
| Toggle 2-player mode (episode select) | N |

Menus are mouse-driven, with the menu keys (arrows + Z by default) for keyboard
navigation. Progress is saved in `localStorage`. In 2-player mode the players
use Shift/A/D/T and N/&lt;/&gt;/O. All bindings (solo, co-op and menu keys),
the volume, and the ninja flavour can be changed on the settings screen.

**Gamepad:** the first connected controller drives player 1. D-pad left/right
move (the left stick also works), D-pad up or the X/Cross face button jumps,
and the D-pad/X also navigate and select in menus. No configuration is needed.

## What is included

- All 120 episodes / 600 levels, episode unlocking, and challenge mode.
- Local 2-player drop-in mode on the episode-select screen.
- Full ninja physics, ragdoll deaths, entities, particles, and sound.
- Attract-mode replays behind the main menu.
- Help, story, credits, and the pause/game-over/victory screens.
- Local progress and resume support.
- The settings screen: volume, solo/co-op/menu key rebinding, ninja flavours,
  and "clear local data" (all persisted in `localStorage`).

## What is intentionally not included

The original online features talked to `nserver.thewayoftheninja.org`:
accounts, user-created levels, server-side highscores/replays, level uploads,
and the editor entry points that were only reachable through those screens.
They are disabled; the corresponding code paths are marked
`NOT IMPLEMENTED` in `js/app.js` (and account setup in `js/game/data.js`).
The settings screen shows the offline configuration (the original hides its
account/login panel when no server database is in use). The editor itself is
not ported because it was only reachable through those online screens.

## Known limitations

- Attract-mode replays are played through the same deterministic simulator as
  normal play, but the recorded runs do not always play out exactly as they did
  in the original Flash client (the simulation is chaotic and depends on
  runtime math-library details). This only affects the background demo behind
  the main menu; levels, physics and controls are unaffected.

## Layout

- `js/flash.js` — Flash API shim: display list, `MovieClip` timelines/labels/
  frame scripts, `Graphics`, text fields, `ByteArray`, keyboard, sound, and
  `SharedObject` (backed by `localStorage`).
- `js/renderer.js` — batched WebGL2 renderer (textured quads, colour
  transforms, scissor/letterboxing).
- `js/assets.js` — asset catalogue/loader and MovieClip factories.
- `js/game/` — literal ports of the original simulation and data modules:
  math, collision, tiles, entities, ninja, ragdoll, input, editor-state
  loader, simulator, particles, graphics/sound managers, and game data.
- `js/ui.js` — menus, episode grid, HUD, dialogs, and thumbnails.
- `js/app.js` — application/state machine (episodes, replays, save/resume).
- `assets/` — prebuilt atlases, audio, fonts, levels, and replay data.

## Rebuilding assets (optional)

The prebuilt files in `assets/` are all the game needs. To regenerate them from
`Nv2.swf`, install [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler)
(`ffdec` on `PATH`), Pillow, and run:

```sh
python3 -I tools/extract_assets.py
```

FFDec is used only at build time to read the SWF's embedded art/audio, like a
texture pipeline. The game itself is translated JavaScript and does not use a
Flash runtime or Ruffle.

## Credits

**N v2** and all original game assets/levels are by Metanet Software. This
repository is an unofficial technical port; all original content remains the
property of its authors.
