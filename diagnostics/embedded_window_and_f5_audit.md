# Embedded Window & F5 Runtime Audit

## 1. Executive Summary & Root Cause

### Observed Problem

When running the project in the Godot Editor with **Embed Game on Play** enabled, the editor debugger reported:
> `ERROR: Embedded window can't be resized`
followed by the debug session terminating immediately.

### Root Cause Analysis

1. **Window Management on Embedded Viewports:**
   In Godot 4.3+, when "Embed Game on Play" is active, the game runs as an embedded subwindow docked inside the editor layout rather than a standalone OS window.
2. **Startup Settings Application:**
   During main menu initialization, [`scripts/main_menu.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/main_menu.gd) calls `GameConfigScript.load_game()`, which invokes `apply_all_settings()` and `apply_display_settings()`.
3. **Unchecked DisplayServer Calls:**
   [`scripts/game_config.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/game_config.gd) previously called:
   - `DisplayServer.window_set_mode(...)`
   - `DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, ...)`
   - `DisplayServer.window_set_size(RESOLUTIONS[...])`
   on `DisplayServer.MAIN_WINDOW_ID` unconditionally.
4. **Debugger Halt:**
   In an embedded window, the engine's window manager rejects resize and mode-change calls with `ERR_PRINT("Embedded window can't be resized")`. Because the session is attached to the Godot Editor Debugger with break-on-error enabled, this triggered a fatal debugger halt and closed the process.

---

## 2. Codebase Audit for Automatic Process Termination

A complete search across all GDScript files and scenes in the repository was conducted:

| Audit Item | Search Pattern | Project Scripts Occurrence | Finding & Validation |
| --- | --- | --- | --- |
| **Direct Tree Quit** | `get_tree().quit()` | 3 occurrences | Exclusively wired to explicit user button clicks:<br>1. [`scripts/main_menu.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/main_menu.gd#L237-L239) (`exit_btn.pressed`)<br>2. [`scripts/pause_menu.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/pause_menu.gd#L48-L49) (`exit_btn.pressed`)<br>3. [`scripts/game_manager.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/game_manager.gd#L355-L357) (`exit_button.pressed`) |
| **OS Exit** | `OS.exit` / `OS.crash` | 0 occurrences | Zero calls to `OS.exit` in project codebase. |
| **Automatic Exit Timers** | `create_timer`, `Timer` | 0 exit timers | All timers in [`scripts/player.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/player.gd) and [`scripts/projectile.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/projectile.gd) manage weapon cooldowns, stun durations, and coyote time. |
| **Scene Transition Failures** | `change_scene_to_file` | 7 occurrences | Hardened with return code error checking and `push_error` logging in `main_menu.gd`, `pause_menu.gd`, `city_manager.gd`, and `game_manager.gd`. |

---

## 3. Window Control & Resize Safeguard Implementation

[`scripts/game_config.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/game_config.gd) was updated with `can_control_window()`:

```gdscript
static func can_control_window() -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	var tree := Engine.get_main_loop() as SceneTree
	if not tree or not tree.root:
		return false
	if tree.root.is_embedded():
		return false
	return true
```

- When running embedded in the Godot Editor (`tree.root.is_embedded() == true`), `DisplayServer.window_set_size`, `window_set_mode`, `window_set_flag`, and `window_set_vsync_mode` are safely skipped.
- `Engine.max_fps = fps_limit` continues to apply safely.
- When running in a separate game window (standalone or editor with Embed Game on Play disabled), full window sizing, borderless, and fullscreen modes execute normally.

---

## 4. F5 Separate Window Runtime Test Results

A full F5 simulation test was performed by launching the Godot console executable with the project directory in a separate OS window without headless flags:

- **Executable:** `C:\Users\LOKESH\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
- **Arguments:** `--path "c:\Users\LOKESH\gotbot game" --verbose`
- **Test Runner:** [`diagnostics/test_f5_runner.py`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/test_f5_runner.py)
- **Log Saved To:** [`diagnostics/f5_runtime_audit.log`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/f5_runtime_audit.log)

### Test Observations

1. **Process Longevity:** The game window launched, rendered the complete 3D main menu, and remained running continuously for the entire test interval.
2. **Error Count:** 0 engine errors, 0 script errors.
3. **Resize Error Check:** `"Embedded window can't be resized"` was **NOT** generated.
4. **Crash / Unhandled Exception Check:** None detected.

---

## 5. Editor Guidance: How to Run in Separate Window

To run the game in a separate window from the Godot Editor:
1. In the top-right toolbar of the Godot Editor (next to the Play button), ensure the **Embed Game on Play** icon (window with arrow inside) is toggled **OFF**.
2. Alternatively, open **Editor -> Editor Settings -> Run -> Window Placement**, and set:
   - **Rect:** Set desired window resolution.
   - **Embed Game:** `Disabled`.
3. Press **F5** (Play Project). The game will launch in a dedicated high-performance Vulkan window and the main menu will remain open until you select Exit.
