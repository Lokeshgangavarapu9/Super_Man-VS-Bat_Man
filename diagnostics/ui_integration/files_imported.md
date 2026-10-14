# files_imported.md — Imported & Created Files Log

## Third-Party Files Imported

> **None.** External repositories could not be cloned (GitHub DNS unreachable during this session).
> All UI patterns were implemented from scratch using MIT-licensed reference architectures as design guides only.

---

## Files Created from Scratch (This Session)

### Core UI Components

| File | Size | License | Notes |
|------|------|---------|-------|
| `scenes/character_preview.tscn` | ~3 KB | Original | SubViewportContainer with 3D hero turntable |
| `scripts/character_preview.gd` | ~1.9 KB | Original | CharacterPreview class |
| `scenes/pause_menu.tscn` | ~5 KB | Original | Full pause overlay scene |
| `scripts/pause_menu.gd` | ~3.5 KB | Original | PauseMenu class with tabbed settings |

### Rebuilt Files (Replacing Prior Broken Implementations)

| File | Previous State | New State |
|------|---------------|-----------|
| `scenes/main_menu.tscn` | 7 disorganized buttons, no 3D preview | 4-choice primary + submenus + live CharacterPreview |
| `scripts/main_menu.gd` | Partial, missing hero logic | Complete navigation, hero select, settings |
| `scripts/city_manager.gd` | SplitScreen always visible (blank gray bug) | Single/double viewport routing fixed |
| `scripts/third_person_camera.gd` | pitch = -12.0 (raw, unscaled) | pitch = deg_to_rad(-12.0) (correct) |

### Diagnostic Files

| File | Purpose |
|------|---------|
| `diagnostics/visual_regression/capture_before.gd` | Before-state screenshot automation |
| `diagnostics/visual_regression/capture_before_extra.gd` | Additional before screenshots |
| `diagnostics/visual_regression/capture_after.gd` | After-state screenshot + runtime validation |
| `diagnostics/visual_regression/test_city_render.gd` | City render smoke test |
| `diagnostics/visual_regression/runtime_before.log` | Pre-fix runtime log |
| `diagnostics/visual_regression/runtime_after.log` | Post-fix runtime log |
| `diagnostics/visual_regression/scene_tree_notes.md` | Annotated scene tree analysis |
| `diagnostics/visual_regression/README.md` | Full visual regression report |
| `diagnostics/ui_integration/before_after.md` | This file's companion report |
| `diagnostics/ui_integration/files_imported.md` | This file |
| `THIRD_PARTY_NOTICES.md` | Open-source attribution (project root) |

---

## Reference Sources (Design Only, No Code Copied)

| Repository | URL | License | Usage |
|-----------|-----|---------|-------|
| godot-settings-menus | github.com/seloc0des/godot-settings-menus | MIT | UI architecture patterns |
| dot-ui | github.com/modcommunity/dot-ui | MIT | Screen stack & focus handling |
| Godot Engine | godotengine.org | MIT | Runtime engine |
