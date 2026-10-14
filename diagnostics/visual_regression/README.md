# Superhero Showdown — Visual Regression Diagnostics

## Summary of Bugs Found, Fixed & Verified

**Engine:** Godot 4.7.2 | **Date:** 2026-10-14 | **GPU:** NVIDIA RTX 3050A Laptop (Vulkan 1.4.325)

---

## Bug 1: City Gameplay Shows Blank Gray Screen

### Status: ✅ FIXED & VERIFIED

**Symptom:** Entering CITY → Single Player showed a perfectly gray viewport with the HUD (health bar, tokens, sector) rendered on top of a flat `#303030` rectangle. No 3D world, no characters, no sky.

**Root Cause:**  
`scenes/city.tscn` had a `SplitScreenContainer` (fullscreen `HBoxContainer`, anchors 0→1 both axes) as a child of the scene root. Inside it, `P1ViewportContainer` (`SubViewportContainer`, `stretch=true`, `size_flags_horizontal=3`) contained a `SubViewport` **with no Camera3D and no nodes**. Godot's rendering pipeline clears every `SubViewport` to the project's default clear color (`Environment/Defaults/default_clear_color = #303030`). Since `P1ViewportContainer` stretched to fill 100% of the screen, this gray rectangle was drawn over the entire window. The `HUD` `CanvasLayer` rendered above everything, producing the precise symptom.

**Files Changed:**  
- `scripts/city_manager.gd` — `_setup_game_mode()`:
  - **Single Player:** `split_screen_container.visible = false` → p1_camera added to `world_content` directly → root window viewport renders world natively at full resolution
  - **Double Player:** `split_screen_container.visible = true` → SubViewports receive `world_3d` + dedicated cameras

**Verification:** `after_city_gameplay.png` — full 3D coastal city with sky, buildings, plaza, fountain, trees, Crimson Weaver hero.

---

## Bug 2: Character Selection Shows No 3D Model

### Status: ✅ FIXED & VERIFIED

**Symptom:** Clicking Single Player or Double Player showed text-only cards. No rotating hero, no pedestal, no 3D viewport.

**Root Cause:**  
The old `main_menu.tscn` modals had no `SubViewportContainer` or `CharacterPreview` nodes at all. There was no script code calling `player.tscn.instantiate()` or adding it to a mount node. The preview area was just an empty `PanelContainer`.

**Files Created:**
- `scenes/character_preview.tscn` — `SubViewportContainer` → transparent `SubViewport` → `Camera3D` at (0, 1.2, 3.5) -15° tilt, key/rim/fill lights, `HeroMount` Node3D, glowing pedestal
- `scripts/character_preview.gd` — `set_hero(type_name)` API: clears existing model via `remove_child()` then instantiates `player.tscn` with physics/input disabled, sets `hero_type`, calls `set_hero_type()`, adds to `HeroMount`

**Key Fix — Queue_free Timing:** Old code called `child.queue_free()` and immediately added a new model in the same frame, causing z-fighting/ghosting. Fixed by `remove_child()` before `queue_free()`.

**Verification:** `after_character_selection.png` — Crimson Weaver rotating on glowing pedestal, red-and-blue suit visible with full 3D detail.

---

## Bug 3: Main Menu Cluttered with 7 Disorganized Buttons

### Status: ✅ FIXED & VERIFIED

**Symptom:** Main menu had 7 buttons (`Continue City`, `Single Player`, `Double Player`, `Collection`, `Settings`, `Arena`, `Quit`) with no hierarchy, no theming, no submenu structure, and no hero preview.

**Root Cause:** Organic growth without a design spec — each feature was added as a new top-level button.

**Files Changed:**
- `scenes/main_menu.tscn` — Rebuilt with exactly 4 primary buttons
- `scripts/main_menu.gd` — Full rewrite with screen-stack navigation

**New Structure:**
```
1. CITY → submenu (Single Player / Double Player / Back)
2. FIGHTING GAME → submenu (1P vs CPU / 2P vs Each Other / Back)  
3. SETTINGS → modal (volume, sensitivity, traffic, population)
4. EXIT
```

**Verification:** `after_main_menu.png` — 4 large buttons, dark navy/cyan theme, "SUPERHERO SHOWDOWN" title.

---

## Bug 4: Fighting Menu Overlapping Buttons

### Status: ✅ FIXED & VERIFIED

**Symptom:** Fighting submenu showed difficulty radio buttons visually overlapping the "FIGHT!" launch button, making them hard to distinguish and click.

**Root Cause:** Layout used flat `VBoxContainer` without spacing or grouping, difficulty selector shared row with action button.

**Fix:** `FightingSubmenu` redesigned with clear grouping:
- "1 Player vs CPU" button
- CPU Difficulty row (EASY / NORMAL / HARD as distinct labels)
- "2 Players vs Each Other" button
- "Back" button
- Each section has `HSeparator` between groups

**Verification:** `after_fighting_menu.png` — ROOFTOP FIGHTING ARENA modal, clean layout, no overlap.

---

## Bug 5: Camera Pointed Straight Down at City Start

### Status: ✅ FIXED & VERIFIED

**Symptom:** When entering city mode, the third-person camera immediately pitched to point straight at the ground, making the city completely invisible until the player manually moved the mouse.

**Root Cause:**  
`scripts/third_person_camera.gd` line 15:  
```gdscript
var pitch: float = -12.0  # WRONG — this is treated as radians, not degrees
```
The `_ready()` function clamped pitch to `clamp(pitch, deg_to_rad(-60), deg_to_rad(60))`.  
`-12.0` radians ≈ `-687°` → clamped to `deg_to_rad(-60)` = `-1.047` radians = **pointing straight down**.

**Fix:**
```gdscript
var pitch: float = deg_to_rad(-12.0)  # Correct: -12 degrees behind and above player
```

**Verification:** City appears immediately visible on enter, camera sits behind the hero looking forward.

---

## Before / After Screenshot Comparison

| Screen | Before | After |
|--------|--------|-------|
| Main Menu | `before_main_menu.png` | `after_main_menu.png` |
| City Gameplay | `before_city_gameplay.png` | `after_city_gameplay.png` |
| Character Selection | `before_character_selection.png` | `after_character_selection.png` |
| Fighting Menu | `before_fighting_menu.png` | `after_fighting_menu.png` |
| Fighting Gameplay | `before_fighting_gameplay.png` | `after_fighting_gameplay.png` |
| City Submenu | *(not captured)* | `after_city_submenu.png` |
| Double Player | *(not captured)* | `after_double_player_selection.png` |

All screenshots are in `diagnostics/visual_regression/screenshots/`.

---

## Test Suite Results

Headless automated test (`test_runner.gd`) run after all fixes:
- **10/10 scenes** parsed without errors
- **16/16 scripts** parsed without errors
- All `preload()` paths valid
- All `@onready` node paths valid

> ⚠️ Note: Headless tests do NOT catch SubViewport rendering bugs (Bug 1 & 2 above). Visual viewport capture is required. Both bugs were confirmed with `before_*.png` screenshots captured from the live Godot window.

---

## Key Lessons (Godot 4 Gotchas)

1. **SubViewport overlay trap** — Any `SubViewportContainer` in the scene tree will draw its `SubViewport` over the main window. If that SubViewport lacks an active `Camera3D`, it renders the project clear color as a solid rectangle. Always hide unused `SubViewportContainer` nodes in single-viewport modes.

2. **Queue_free() latency** — Calling `queue_free()` then immediately adding a replacement in the same frame causes one-frame z-fighting. Always use `remove_child(node)` first, then `queue_free()`.

3. **Pitch units** — `deg_to_rad()` must be used explicitly; raw float values in Godot 4 angle properties are radians.

4. **SubViewport camera requirement** — In Godot 4, each SubViewport in split-screen must have its own `Camera3D` child with `current = true` AND `SubViewport.world_3d` assigned to the shared root `World3D`.
